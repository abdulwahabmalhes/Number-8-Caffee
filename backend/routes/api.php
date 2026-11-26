<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\TableController;
use App\Http\Controllers\Api\MenuController;
use App\Http\Controllers\Api\OrderController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

use App\Http\Controllers\Api\CustomerAuthController;

// Phase 4 APIs
Route::prefix('v1')->group(function () {
    Route::post('/auth/login', [CustomerAuthController::class, 'login']);
    Route::post('/auth/firebase-login', [CustomerAuthController::class, 'firebaseLogin']);
    Route::post('/auth/send-otp', [CustomerAuthController::class, 'sendOtp']);
    Route::post('/auth/verify-otp', [CustomerAuthController::class, 'verifyOtp']);
    Route::delete('/customer/account', [CustomerAuthController::class, 'deleteAccount'])->middleware('auth:sanctum');

    Route::post('/scan-qr', [TableController::class, 'scanQr']);
    Route::get('/menu', [MenuController::class, 'index']);
    Route::get('/offers', [\App\Http\Controllers\Api\OfferApiController::class, 'index']);
    Route::post('/coupons/validate', [\App\Http\Controllers\Api\OfferApiController::class, 'validateCoupon']);
    Route::get('/loyalty/config', function () {
        $target = (int)\App\Models\Setting::get('loyalty_target_cups', 8);
        if ($target <= 0) $target = 8;
        return response()->json([
            'success' => true,
            'target_cups' => $target,
            'free_cup_number' => $target + 1,
        ]);
    });
    Route::get('/stripe/config', [\App\Http\Controllers\Api\PaymentController::class, 'getConfig']);
    Route::post('/stripe/update-keys', [\App\Http\Controllers\Api\PaymentController::class, 'updateKeys'])->middleware('auth:sanctum');
    Route::post('/stripe/process-card-payment', [\App\Http\Controllers\Api\PaymentController::class, 'processCardPayment'])->middleware('auth:sanctum');
    Route::post('/stripe/process-wallet-payment', [\App\Http\Controllers\Api\PaymentController::class, 'processWalletPayment'])->middleware('auth:sanctum');
    Route::post('/stripe/create-payment-intent', [\App\Http\Controllers\Api\PaymentController::class, 'createPaymentIntent'])->middleware('auth:sanctum');
    Route::post('/stripe/create-checkout-session', [\App\Http\Controllers\Api\PaymentController::class, 'createCheckoutSession'])->middleware('auth:sanctum');
    Route::post('/stripe/verify-payment', [\App\Http\Controllers\Api\PaymentController::class, 'verifyPayment']);
    Route::get('/stripe/checkout-return', [\App\Http\Controllers\Api\PaymentController::class, 'checkoutReturn']);
    Route::post('/checkout', [OrderController::class, 'checkout'])->middleware('auth:sanctum');
    Route::get('/orders', [OrderController::class, 'index'])->middleware('auth:sanctum');
    Route::get('/orders/{order_number}/status', [OrderController::class, 'status']);
});
