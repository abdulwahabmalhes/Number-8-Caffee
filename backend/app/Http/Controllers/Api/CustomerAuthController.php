<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Models\Customer;

class CustomerAuthController extends Controller
{
    /**
     * Verify Firebase ID Token from Flutter Firebase Phone Auth and issue a Sanctum token.
     * Matches existing customer phone formats to prevent duplicate accounts and preserve orders/loyalty.
     */
    public function firebaseLogin(Request $request)
    {
        $request->validate([
            'id_token' => 'required|string',
            'name' => 'nullable|string|max:255',
            'password' => 'nullable|string|min:4',
        ]);

        try {
            $claims = $this->verifyFirebaseIdToken($request->id_token);
        } catch (\RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 401);
        }

        $phone = $claims['phone_number'] ?? null;
        if (empty($phone)) {
            return response()->json([
                'success' => false,
                'message' => 'رقم الهاتف غير موثق في رمز Firebase / Phone number missing in Firebase token',
            ], 422);
        }

        $variants = $this->phoneVariants($phone);
        $customer = Customer::whereIn('phone', $variants)->orderBy('id')->first();

        if ($customer) {
            if (!empty($customer->password) && $request->filled('password')) {
                if (!Hash::check($request->password, $customer->password) && $customer->password !== $request->password) {
                    return response()->json([
                        'success' => false,
                        'message' => 'كلمة المرور غير صحيحة / Incorrect password',
                    ], 422);
                }
            } elseif (empty($customer->password) && $request->filled('password')) {
                $customer->password = Hash::make($request->password);
            }

            if ($request->filled('name') && $customer->name !== $request->name) {
                $customer->name = $request->name;
            }
            $customer->otp_code = null;
            $customer->otp_expires_at = null;
            $customer->save();
        } else {
            $customer = Customer::create([
                'phone' => $phone,
                'name' => $request->name ?: 'Customer',
                'password' => $request->filled('password') ? Hash::make($request->password) : null,
            ]);
        }

        $token = $customer->createToken('customer-app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Logged in successfully',
            'token' => $token,
            'customer' => [
                'id' => $customer->id,
                'name' => $customer->name,
                'phone' => $customer->phone,
                'has_password' => !empty($customer->password),
            ],
        ]);
    }

    /**
     * Build equivalent phone number variants (e.g. +971501234567, 971501234567, 0501234567, 501234567)
     * so existing customer accounts, orders, and loyalty points are matched without duplicates.
     */
    private function phoneVariants(string $rawPhone): array
    {
        $cleaned = preg_replace('/[^0-9+]/', '', $rawPhone);
        $digits = ltrim($cleaned, '+');
        $variants = array_filter([$rawPhone, $cleaned, $digits, '+' . $digits]);

        if (str_starts_with($digits, '971') && strlen($digits) > 3) {
            $local = substr($digits, 3);
            $localNoZero = ltrim($local, '0');
            $variants[] = $localNoZero;
            $variants[] = '0' . $localNoZero;
            $variants[] = '971' . $localNoZero;
            $variants[] = '+971' . $localNoZero;
        } elseif (str_starts_with($digits, '0') && strlen($digits) >= 9) {
            $localNoZero = ltrim($digits, '0');
            $variants[] = $localNoZero;
            $variants[] = '971' . $localNoZero;
            $variants[] = '+971' . $localNoZero;
        }

        return array_values(array_unique($variants));
    }

    /**
     * Verify Firebase ID Token (RS256 JWT) against Google's public X.509 certificates.
     */
    private function verifyFirebaseIdToken(string $idToken): array
    {
        $parts = explode('.', $idToken);
        if (count($parts) !== 3) {
            throw new \RuntimeException('Invalid Firebase token format');
        }

        [$headerB64, $payloadB64, $signatureB64] = $parts;
        $header = json_decode($this->base64UrlDecode($headerB64), true);
        $payload = json_decode($this->base64UrlDecode($payloadB64), true);
        $signature = $this->base64UrlDecode($signatureB64);

        if (!is_array($header) || !is_array($payload) || $signature === '') {
            throw new \RuntimeException('Malformed Firebase token');
        }

        if (($header['alg'] ?? '') !== 'RS256' || empty($header['kid'])) {
            throw new \RuntimeException('Unsupported Firebase token algorithm');
        }

        $certs = $this->getFirebaseCertificates();
        $kid = $header['kid'];
        if (!isset($certs[$kid])) {
            Cache::forget('firebase_securetoken_x509_certs');
            $certs = $this->getFirebaseCertificates();
        }

        if (!isset($certs[$kid])) {
            throw new \RuntimeException('Firebase signing key not found');
        }

        $publicKey = openssl_pkey_get_public($certs[$kid]);
        if ($publicKey === false) {
            throw new \RuntimeException('Invalid Firebase public key');
        }

        $verified = openssl_verify(
            $headerB64 . '.' . $payloadB64,
            $signature,
            $publicKey,
            OPENSSL_ALGO_SHA256
        );

        if ($verified !== 1) {
            throw new \RuntimeException('Invalid Firebase token signature');
        }

        $projectId = env('FIREBASE_PROJECT_ID', 'number-8-509e1');
        $now = time();

        if (($payload['aud'] ?? '') !== $projectId) {
            throw new \RuntimeException('Firebase token audience mismatch');
        }
        if (($payload['iss'] ?? '') !== 'https://securetoken.google.com/' . $projectId) {
            throw new \RuntimeException('Firebase token issuer mismatch');
        }
        if (empty($payload['sub']) || !is_string($payload['sub'])) {
            throw new \RuntimeException('Firebase token subject missing');
        }
        if (($payload['exp'] ?? 0) <= $now) {
            throw new \RuntimeException('Firebase token expired');
        }
        if (($payload['iat'] ?? ($now + 1000)) > $now + 60) {
            throw new \RuntimeException('Firebase token issued in the future');
        }

        return $payload;
    }

    private function getFirebaseCertificates(): array
    {
        return Cache::remember('firebase_securetoken_x509_certs', 3600, function () {
            $response = Http::timeout(10)->get(
                'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
            );
            if (!$response->successful()) {
                throw new \RuntimeException('Unable to fetch Firebase public certificates');
            }
            $data = $response->json();
            if (!is_array($data)) {
                throw new \RuntimeException('Invalid Firebase certificates response');
            }
            return $data;
        });
    }

    private function base64UrlDecode(string $input): string
    {
        $remainder = strlen($input) % 4;
        if ($remainder) {
            $input .= str_repeat('=', 4 - $remainder);
        }
        $decoded = base64_decode(strtr($input, '-_', '+/'), true);
        return $decoded === false ? '' : $decoded;
    }

    public function sendOtp(Request $request)
    {
        $request->validate([
            'phone' => 'required|string|min:9',
            'name' => 'nullable|string',
            'password' => 'nullable|string|min:4',
        ]);

        $phone = preg_replace('/[^0-9+]/', '', $request->phone);
        $customer = Customer::where('phone', $phone)->orWhere('phone', $request->phone)->first();

        if ($customer) {
            if (!empty($customer->password) && $request->filled('password')) {
                if (!Hash::check($request->password, $customer->password) && $customer->password !== $request->password) {
                    return response()->json([
                        'success' => false,
                        'message' => 'كلمة المرور غير صحيحة / Incorrect password',
                    ], 422);
                }
            }

            if ($customer->otp_expires_at && $customer->otp_expires_at->gt(now()->addMinutes(4))) {
                return response()->json([
                    'success' => false,
                    'message' => 'يرجى الانتظار دقيقة قبل إعادة إرسال الرمز / Please wait a minute before resending',
                ], 429);
            }
        } else {
            $customer = Customer::create([
                'phone' => $phone ?: $request->phone,
                'name' => $request->name ?: 'Customer',
                'password' => $request->filled('password') ? Hash::make($request->password) : null,
            ]);
        }

        $otp = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $customer->otp_code = Hash::make($otp);
        $customer->otp_expires_at = now()->addMinutes(5);
        $customer->save();

        Log::info('Customer login OTP generated', [
            'phone' => $customer->phone,
            'otp' => $otp,
        ]);

        $response = [
            'success' => true,
            'message' => 'تم إرسال رمز التحقق بنجاح / OTP sent successfully',
            'expires_in' => 300,
        ];

        if (config('app.debug')) {
            $response['dev_otp'] = $otp;
        }

        return response()->json($response);
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'phone' => 'required|string|min:9',
            'otp' => 'required|string|size:6',
            'name' => 'nullable|string',
            'password' => 'nullable|string|min:4',
        ]);

        $phone = preg_replace('/[^0-9+]/', '', $request->phone);
        $customer = Customer::where('phone', $phone)->orWhere('phone', $request->phone)->first();

        if (!$customer || empty($customer->otp_code) || !$customer->otp_expires_at) {
            return response()->json([
                'success' => false,
                'message' => 'لم يتم طلب رمز تحقق لهذا الرقم / No OTP requested for this phone',
            ], 422);
        }

        if ($customer->otp_expires_at->isPast()) {
            return response()->json([
                'success' => false,
                'message' => 'انتهت صلاحية رمز التحقق / OTP has expired',
            ], 422);
        }

        if (!Hash::check($request->otp, $customer->otp_code) && $customer->otp_code !== $request->otp) {
            return response()->json([
                'success' => false,
                'message' => 'رمز التحقق غير صحيح / Invalid OTP code',
            ], 422);
        }

        if (!empty($customer->password) && $request->filled('password')) {
            if (!Hash::check($request->password, $customer->password) && $customer->password !== $request->password) {
                return response()->json([
                    'success' => false,
                    'message' => 'كلمة المرور غير صحيحة / Incorrect password',
                ], 422);
            }
        } elseif (empty($customer->password) && $request->filled('password')) {
            $customer->password = Hash::make($request->password);
        }

        if ($request->filled('name') && $customer->name !== $request->name) {
            $customer->name = $request->name;
        }

        $customer->otp_code = null;
        $customer->otp_expires_at = null;
        $customer->save();

        $token = $customer->createToken('customer-app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Logged in successfully',
            'token' => $token,
            'customer' => [
                'id' => $customer->id,
                'name' => $customer->name,
                'phone' => $customer->phone,
                'has_password' => !empty($customer->password),
            ],
        ]);
    }

    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'name' => 'nullable|string',
            'password' => 'nullable|string|min:4',
        ]);

        $phone = preg_replace('/[^0-9+]/', '', $request->phone);
        $customer = Customer::where('phone', $phone)->orWhere('phone', $request->phone)->first();

        if ($customer) {
            // If customer has a password, verify it
            if (!empty($customer->password) && $request->filled('password')) {
                if (!\Illuminate\Support\Facades\Hash::check($request->password, $customer->password) && $customer->password !== $request->password) {
                    return response()->json([
                        'success' => false,
                        'message' => 'كلمة المرور غير صحيحة / Incorrect password'
                    ], 422);
                }
            } elseif (empty($customer->password) && $request->filled('password')) {
                // Set password on first setup
                $customer->password = \Illuminate\Support\Facades\Hash::make($request->password);
            }

            if ($request->filled('name') && $customer->name !== $request->name) {
                $customer->name = $request->name;
            }
            $customer->save();
        } else {
            // Create new customer
            $customer = Customer::create([
                'phone' => $phone ?: $request->phone,
                'name' => $request->name ?: 'Customer',
                'password' => $request->filled('password') ? \Illuminate\Support\Facades\Hash::make($request->password) : null,
            ]);
        }

        // Generate token
        $token = $customer->createToken('customer-app')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Logged in successfully',
            'token' => $token,
            'customer' => [
                'id' => $customer->id,
                'name' => $customer->name,
                'phone' => $customer->phone,
                'has_password' => !empty($customer->password),
            ]
        ]);
    }

    /**
     * Delete customer account (Apple Review Guideline 5.1.1(v) compliance)
     */
    public function deleteAccount(Request $request)
    {
        $customer = $request->user();

        if (!$customer) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        // Revoke all Sanctum tokens
        $customer->tokens()->delete();

        // Optionally anonymize order records so order history isn't corrupted, or delete customer
        // Here we delete the customer account
        $customer->delete();

        return response()->json([
            'success' => true,
            'message' => 'Account deleted successfully',
        ]);
    }
}
