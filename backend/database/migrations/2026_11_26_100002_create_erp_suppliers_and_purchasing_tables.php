<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('erp_suppliers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->string('name', 255);
            $table->string('contact_name', 100)->nullable();
            $table->string('phone', 50)->nullable();
            $table->string('email', 100)->nullable();
            $table->string('tax_number', 50)->nullable();
            $table->string('address', 255)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('erp_purchase_orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained('erp_branches')->cascadeOnDelete();
            $table->foreignId('supplier_id')->constrained('erp_suppliers')->cascadeOnDelete();
            $table->string('po_number', 50);
            $table->string('status', 30)->default('draft'); // draft, submitted, partially_received, received, cancelled
            $table->unsignedBigInteger('total_minor')->default(0);
            $table->string('currency', 3)->default('AED');
            $table->text('notes')->nullable();
            $table->unsignedBigInteger('created_by')->nullable();
            $table->timestamps();

            $table->unique(['tenant_id', 'po_number']);
        });

        Schema::create('erp_po_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('po_id')->constrained('erp_purchase_orders')->cascadeOnDelete();
            $table->foreignId('inventory_item_id')->constrained('erp_inventory_items')->cascadeOnDelete();
            $table->decimal('ordered_quantity', 12, 3);
            $table->decimal('received_quantity', 12, 3)->default(0);
            $table->unsignedBigInteger('unit_cost_minor');
            $table->unsignedBigInteger('total_minor');
            $table->timestamps();
        });

        Schema::create('erp_goods_receipts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained('erp_branches')->cascadeOnDelete();
            $table->foreignId('po_id')->constrained('erp_purchase_orders')->cascadeOnDelete();
            $table->string('receipt_number', 50);
            $table->timestamp('received_at')->useCurrent();
            $table->string('received_by', 100)->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->unique(['tenant_id', 'receipt_number']);
        });

        Schema::create('erp_goods_receipt_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('goods_receipt_id')->constrained('erp_goods_receipts')->cascadeOnDelete();
            $table->foreignId('po_line_id')->constrained('erp_po_lines')->cascadeOnDelete();
            $table->foreignId('inventory_item_id')->constrained('erp_inventory_items')->cascadeOnDelete();
            $table->decimal('quantity_received', 12, 3);
            $table->unsignedBigInteger('unit_cost_minor');
            $table->timestamps();
        });

        Schema::create('erp_supplier_invoices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('supplier_id')->constrained('erp_suppliers')->cascadeOnDelete();
            $table->foreignId('po_id')->nullable()->constrained('erp_purchase_orders')->nullOnDelete();
            $table->foreignId('goods_receipt_id')->nullable()->constrained('erp_goods_receipts')->nullOnDelete();
            $table->string('invoice_number', 50);
            $table->date('invoice_date');
            $table->unsignedBigInteger('subtotal_minor');
            $table->unsignedBigInteger('tax_minor')->default(0);
            $table->unsignedBigInteger('total_minor');
            $table->string('currency', 3)->default('AED');
            $table->string('status', 30)->default('pending'); // pending, posted, paid
            $table->foreignId('posted_journal_id')->nullable()->constrained('erp_journals')->nullOnDelete();
            $table->timestamps();

            $table->unique(['tenant_id', 'invoice_number']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('erp_supplier_invoices');
        Schema::dropIfExists('erp_goods_receipt_lines');
        Schema::dropIfExists('erp_goods_receipts');
        Schema::dropIfExists('erp_po_lines');
        Schema::dropIfExists('erp_purchase_orders');
        Schema::dropIfExists('erp_suppliers');
    }
};
