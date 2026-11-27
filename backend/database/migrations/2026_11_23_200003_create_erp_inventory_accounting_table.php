<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('erp_inventory_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->string('sku', 50);
            $table->string('name_en', 255);
            $table->string('name_ar', 255);
            $table->string('unit', 30)->default('kg');
            $table->decimal('current_quantity', 12, 3)->default(0);
            $table->decimal('reorder_threshold', 12, 3)->default(10);
            $table->unsignedBigInteger('unit_cost_minor')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['tenant_id', 'sku']);
        });

        Schema::create('erp_stock_movements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained('erp_branches')->cascadeOnDelete();
            $table->foreignId('inventory_item_id')->constrained('erp_inventory_items')->cascadeOnDelete();
            $table->string('idempotency_key', 100);
            $table->decimal('quantity_change', 12, 3);
            $table->decimal('balance_after', 12, 3);
            $table->string('reason', 50); // sale, purchase, adjustment, waste
            $table->string('reference_type', 50)->nullable();
            $table->string('reference_id', 50)->nullable();
            $table->string('actor_id', 50);
            $table->timestamp('created_at')->useCurrent();

            $table->unique(['tenant_id', 'idempotency_key']);
        });

        Schema::create('erp_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->string('code', 30);
            $table->string('name_en', 100);
            $table->string('name_ar', 100);
            $table->string('type', 30); // asset, liability, equity, revenue, expense
            $table->string('currency', 3)->default('AED');
            $table->timestamps();

            $table->unique(['tenant_id', 'code']);
        });

        Schema::create('erp_journals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->nullable()->constrained('erp_branches')->nullOnDelete();
            $table->string('journal_number', 50);
            $table->string('period', 20); // e.g. 2026-11
            $table->string('description', 255);
            $table->timestamp('posted_at')->useCurrent();
            $table->unsignedBigInteger('created_by')->nullable();
            $table->timestamps();

            $table->unique(['tenant_id', 'journal_number']);
        });

        Schema::create('erp_journal_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('journal_id')->constrained('erp_journals')->cascadeOnDelete();
            $table->foreignId('account_id')->constrained('erp_accounts')->cascadeOnDelete();
            $table->unsignedBigInteger('debit_minor')->default(0);
            $table->unsignedBigInteger('credit_minor')->default(0);
            $table->string('memo', 255)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('erp_journal_lines');
        Schema::dropIfExists('erp_journals');
        Schema::dropIfExists('erp_accounts');
        Schema::dropIfExists('erp_stock_movements');
        Schema::dropIfExists('erp_inventory_items');
    }
};
