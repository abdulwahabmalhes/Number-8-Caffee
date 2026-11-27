<?php

use App\ERP\Http\Controllers\AccountingController;
use App\ERP\Http\Controllers\CustomerController;
use App\ERP\Http\Controllers\InventoryController;
use App\ERP\Http\Controllers\KitchenController;
use App\ERP\Http\Controllers\PosController;
use App\ERP\Http\Controllers\ProductController;
use App\ERP\Http\Controllers\SessionController;
use App\ERP\Http\Controllers\SupplierController;
use App\ERP\Http\Middleware\EnsureErpEnabled;
use App\ERP\Http\Middleware\ErpRequestId;
use App\ERP\Http\Middleware\ErpStaffSession;
use Illuminate\Support\Facades\Route;

Route::prefix('api/erp/v1')
    ->middleware([
        EnsureErpEnabled::class,
        ErpRequestId::class,
        'api',
        ErpStaffSession::class,
    ])
    ->group(function () {
        // Staff Session & Identity
        Route::get('/session', [SessionController::class, 'show']);

        // Products & Recipes
        Route::get('/products', [ProductController::class, 'index']);
        Route::post('/products', [ProductController::class, 'store']);
        Route::post('/products/{id}/archive', [ProductController::class, 'archive']);

        // Suppliers & Purchasing
        Route::get('/suppliers', [SupplierController::class, 'index']);
        Route::post('/suppliers', [SupplierController::class, 'store']);
        Route::get('/suppliers/{id}', [SupplierController::class, 'show']);
        Route::post('/purchasing/orders', [SupplierController::class, 'createPurchaseOrder']);
        Route::post('/purchasing/orders/{poId}/receive', [SupplierController::class, 'receiveGoods']);
        Route::post('/purchasing/orders/{poId}/invoice', [SupplierController::class, 'createInvoice']);

        // Customers
        Route::get('/customers', [CustomerController::class, 'index']);
        Route::post('/customers', [CustomerController::class, 'store']);
        Route::get('/customers/{id}', [CustomerController::class, 'show']);

        // POS & Cash Sales
        Route::get('/pos/catalog', [PosController::class, 'catalog']);
        Route::post('/pos/quote', [PosController::class, 'quote']);
        Route::post('/pos/checkout', [PosController::class, 'checkout']);

        // Kitchen Display (KDS)
        Route::get('/kitchen/tickets', [KitchenController::class, 'index']);
        Route::post('/kitchen/tickets/{id}/status', [KitchenController::class, 'updateStatus']);

        // Inventory
        Route::get('/inventory/items', [InventoryController::class, 'items']);
        Route::post('/inventory/items', [InventoryController::class, 'storeItem']);
        Route::post('/inventory/waste', [InventoryController::class, 'recordWaste']);
        Route::get('/inventory/movements', [InventoryController::class, 'movements']);

        // Accounting & VAT
        Route::get('/accounting/journals', [AccountingController::class, 'journals']);
        Route::get('/accounting/accounts', [AccountingController::class, 'accounts']);
        Route::get('/accounting/vat-report', [AccountingController::class, 'vatReport']);
    });
