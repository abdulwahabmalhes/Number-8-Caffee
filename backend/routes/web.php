<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\OperationsController;
use App\Http\Controllers\ManagerController;
use App\Http\Controllers\AuthController;
use App\Http\Middleware\AdminOnlyMiddleware;

Route::get('/', function () {
    return redirect('/operations');
});

// App Store Public URLs
Route::get('/privacy-policy', function () {
    return view('legal.privacy-policy');
})->name('privacy.policy');

Route::get('/support', function () {
    return view('legal.support');
})->name('support');

// Auth Routes
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login'])->name('login.post');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// Operations Hub (Cashier, Barista, Car Delivery Dispatch)
Route::prefix('operations')->middleware('auth')->group(function () {
    Route::get('/', [OperationsController::class, 'index']);
    Route::post('/orders/{id}/status', [OperationsController::class, 'updateStatus']);
    Route::post('/orders/{id}/arrived', [OperationsController::class, 'markArrived']);
    Route::get('/orders/{id}/receipt', [OperationsController::class, 'printReceipt']);
    Route::get('/orders/{id}/sticker', [OperationsController::class, 'printSticker']);
    Route::get('/live-feed', [OperationsController::class, 'liveFeed']);
});

// Manager & Executive Analytics Portal
Route::prefix('manager')->middleware(['auth', AdminOnlyMiddleware::class])->group(function () {
    Route::get('/', [ManagerController::class, 'index']);
    
    // Customers & Orders & Reports
    Route::get('/customers', [ManagerController::class, 'customers']);
    Route::get('/orders', [ManagerController::class, 'orders']);
    Route::get('/reports', [ManagerController::class, 'reports']);
    
    // Product Management (CRUD)
    Route::post('/products', [ManagerController::class, 'storeProduct']);
    Route::post('/products/{id}/update', [ManagerController::class, 'updateProduct']);
    Route::post('/products/{id}/delete', [ManagerController::class, 'deleteProduct']);
    Route::post('/products/{id}/toggle-stock', [ManagerController::class, 'toggleProductStock']);
    
    // Category Management
    Route::post('/categories', [ManagerController::class, 'storeCategory']);
    
    // Table QR Management & Printouts
    Route::post('/tables', [ManagerController::class, 'storeTable']);
    Route::post('/tables/{id}/delete', [ManagerController::class, 'deleteTable']);
    Route::post('/tables/{id}/generate-qr', [ManagerController::class, 'generateTableQr']);
    Route::get('/tables/{id}/print', [ManagerController::class, 'printTableQr']);
    Route::get('/tables/print-all', [ManagerController::class, 'printAllTablesQr']);
});
