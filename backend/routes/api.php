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
    Route::delete('/customer/account', [CustomerAuthController::class, 'deleteAccount'])->middleware('auth:sanctum');

    Route::post('/scan-qr', [TableController::class, 'scanQr']);
    Route::get('/menu', [MenuController::class, 'index']);
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
