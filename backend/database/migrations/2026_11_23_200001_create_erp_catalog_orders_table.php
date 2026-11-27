<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('erp_orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained('erp_branches')->cascadeOnDelete();
            $table->string('order_number', 50);
            $table->string('idempotency_key', 100)->nullable();
            $table->string('order_type', 30)->default('dine_in');
            $table->string('status', 30)->default('pending');
            $table->unsignedBigInteger('subtotal_minor')->default(0);
            $table->unsignedBigInteger('tax_minor')->default(0);
            $table->unsignedBigInteger('total_minor')->default(0);
            $table->string('currency', 3)->default('AED');
            $table->unsignedBigInteger('created_by')->nullable();
            $table->timestamps();

            $table->unique(['tenant_id', 'order_number']);
            $table->unique(['tenant_id', 'idempotency_key']);
        });

        Schema::create('erp_order_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('erp_orders')->cascadeOnDelete();
            $table->unsignedBigInteger('product_id')->nullable();
            $table->string('sku', 50)->nullable();
            $table->string('name_en', 255);
            $table->string('name_ar', 255);
            $table->unsignedInteger('quantity')->default(1);
            $table->unsignedBigInteger('unit_price_minor');
            $table->unsignedBigInteger('subtotal_minor');
            $table->unsignedBigInteger('tax_minor');
            $table->unsignedBigInteger('total_minor');
            $table->json('selected_options')->nullable();
            $table->timestamps();
        });

        Schema::create('erp_tenders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('erp_orders')->cascadeOnDelete();
            $table->string('payment_method', 30); // cash, card, gift_card
            $table->unsignedBigInteger('amount_minor');
            $table->string('currency', 3)->default('AED');
            $table->string('reference', 100)->nullable();
            $table->string('status', 30)->default('captured'); // captured, refunded
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('erp_tenders');
        Schema::dropIfExists('erp_order_lines');
        Schema::dropIfExists('erp_orders');
    }
};
