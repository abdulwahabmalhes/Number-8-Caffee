<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // 1. Branch-scoped Inventory Balances
        Schema::create('erp_inventory_balances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained('erp_branches')->cascadeOnDelete();
            $table->foreignId('inventory_item_id')->constrained('erp_inventory_items')->cascadeOnDelete();
            $table->decimal('current_quantity', 12, 3)->default(0);
            $table->decimal('reorder_threshold', 12, 3)->default(10);
            $table->timestamps();

            $table->unique(['tenant_id', 'branch_id', 'inventory_item_id'], 'erp_inv_balance_branch_unique');
        });

        // 2. Persistent Centralized Idempotency Ledger
        Schema::create('erp_idempotency_keys', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained('erp_branches')->cascadeOnDelete();
            $table->string('action_type', 50); // e.g. pos_checkout, goods_receipt
            $table->string('idempotency_key', 120);
            $table->string('request_hash', 64); // SHA-256 of canonicalized payload
            $table->integer('response_code')->default(200);
            $table->json('response_body');
            $table->string('resource_id', 50)->nullable();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->timestamps();

            $table->unique(
                ['tenant_id', 'branch_id', 'action_type', 'idempotency_key'],
                'erp_idempotency_tenant_branch_unique'
            );
        });

        // 3. Backfill inventory balances from existing branch stock movements
        $movements = DB::table('erp_stock_movements')
            ->select('tenant_id', 'branch_id', 'inventory_item_id', DB::raw('SUM(quantity_change) as total_qty'))
            ->groupBy('tenant_id', 'branch_id', 'inventory_item_id')
            ->get();

        foreach ($movements as $m) {
            DB::table('erp_inventory_balances')->updateOrInsert(
                [
                    'tenant_id' => $m->tenant_id,
                    'branch_id' => $m->branch_id,
                    'inventory_item_id' => $m->inventory_item_id,
                ],
                [
                    'current_quantity' => (float) $m->total_qty,
                    'updated_at' => now(),
                    'created_at' => now(),
                ]
            );
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('erp_idempotency_keys');
        Schema::dropIfExists('erp_inventory_balances');
    }
};
