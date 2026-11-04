<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_number')->unique();
            $table->foreignId('branch_id')->constrained()->cascadeOnDelete();
            $table->foreignId('table_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('customer_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('vehicle_id')->nullable()->constrained()->nullOnDelete();
            
            $table->string('order_type')->default('table'); // table or car
            
            $table->decimal('subtotal', 10, 2)->default(0);
            $table->decimal('tax_amount', 10, 2)->default(0);
            $table->decimal('discount_amount', 10, 2)->default(0);
            $table->decimal('grand_total', 10, 2)->default(0);
            
            $table->string('status')->default('new'); // new, accepted, preparing, ready, delivered, cancelled
            $table->string('payment_method')->nullable();
            $table->string('payment_status')->default('pending'); // pending, paid, failed, refunded, pay_at_cashier
            
            $table->text('notes')->nullable();
            
            $table->timestamp('expected_arrival_time')->nullable();
            $table->timestamp('customer_arrived_at')->nullable();
            $table->timestamp('delivered_at')->nullable();
            $table->unsignedBigInteger('delivered_by')->nullable(); // staff id
            
            $table->string('session_id')->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
