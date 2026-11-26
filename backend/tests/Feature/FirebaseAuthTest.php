<?php

namespace Tests\Feature;

use App\Models\Customer;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class FirebaseAuthTest extends TestCase
{
    use RefreshDatabase;

    private function createTestKeyPairAndCert(): array
    {
        $privKey = openssl_pkey_new([
            'private_key_bits' => 2048,
            'private_key_type' => OPENSSL_KEYTYPE_RSA,
        ]);

        $csr = openssl_csr_new(['commonName' => 'firebase-test'], $privKey);
        $x509 = openssl_csr_sign($csr, null, $privKey, 1);
        openssl_x509_export($x509, $certPem);

        return [$privKey, $certPem];
    }

    private function signJwt(array $header, array $payload, $privKey): string
    {
        $b64 = fn (string $data) => rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
        $signingInput = $b64(json_encode($header)) . '.' . $b64(json_encode($payload));
        openssl_sign($signingInput, $signature, $privKey, OPENSSL_ALGO_SHA256);

        return $signingInput . '.' . $b64($signature);
    }

    public function test_firebase_login_links_existing_customer_without_duplicates(): void
    {
        [$privKey, $certPem] = $this->createTestKeyPairAndCert();
        $kid = 'test-key-1';

        Cache::flush();
        Http::fake([
            'https://www.googleapis.com/robot/v1/metadata/x509/*' => Http::response([
                $kid => $certPem,
            ], 200),
        ]);

        // Existing customer stored in local format (050...)
        $existing = Customer::create([
            'name' => 'Test Customer',
            'phone' => '0501234567',
        ]);

        $projectId = env('FIREBASE_PROJECT_ID', 'number-8-509e1');
        $now = time();
        $idToken = $this->signJwt(
            ['alg' => 'RS256', 'typ' => 'JWT', 'kid' => $kid],
            [
                'iss' => 'https://securetoken.google.com/' . $projectId,
                'aud' => $projectId,
                'sub' => 'firebase-uid-123',
                'phone_number' => '+971501234567',
                'iat' => $now - 10,
                'exp' => $now + 3600,
            ],
            $privKey
        );

        $response = $this->postJson('/api/v1/auth/firebase-login', [
            'id_token' => $idToken,
            'name' => 'Test Customer Updated',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'customer' => [
                    'id' => $existing->id,
                    'name' => 'Test Customer Updated',
                ],
            ]);

        $this->assertDatabaseCount('customers', 1);
    }

    public function test_firebase_login_rejects_invalid_token(): void
    {
        $response = $this->postJson('/api/v1/auth/firebase-login', [
            'id_token' => 'not.a.valid.jwt',
        ]);

        $response->assertStatus(401)
            ->assertJson(['success' => false]);
    }
}
