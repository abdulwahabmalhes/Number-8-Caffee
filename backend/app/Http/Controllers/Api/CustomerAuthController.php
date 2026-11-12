<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Customer;

class CustomerAuthController extends Controller
{
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
