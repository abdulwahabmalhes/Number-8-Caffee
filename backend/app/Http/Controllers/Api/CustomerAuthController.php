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
            'name' => 'required|string',
        ]);

        $customer = Customer::firstOrCreate(
            ['phone' => $request->phone],
            ['name' => $request->name]
        );

        // Update name if they entered a new one
        if ($customer->name !== $request->name) {
            $customer->name = $request->name;
            $customer->save();
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
