<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('erp_stations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained('erp_branches')->cascadeOnDelete();
            $table->string('code', 50);
            $table->string('name_en', 100);
            $table->string('name_ar', 100);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['tenant_id', 'branch_id', 'code']);
        });

        Schema::create('erp_kitchen_tickets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained('erp_branches')->cascadeOnDelete();
            $table->foreignId('order_id')->nullable()->constrained('erp_orders')->nullOnDelete();
            $table->string('ticket_number', 50);
            $table->string('station_code', 50)->default('HOT_BAR');
            $table->string('status', 30)->default('new'); // new, preparing, ready, completed
            $table->text('notes')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('ready_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index(['tenant_id', 'branch_id', 'status']);
        });

        Schema::create('erp_ticket_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('ticket_id')->constrained('erp_kitchen_tickets')->cascadeOnDelete();
            $table->unsignedBigInteger('order_line_id')->nullable();
            $table->string('item_name', 255);
            $table->unsignedInteger('quantity')->default(1);
            $table->json('modifiers')->nullable();
            $table->string('status', 30)->default('pending'); // pending, preparing, ready
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('erp_ticket_items');
        Schema::dropIfExists('erp_kitchen_tickets');
        Schema::dropIfExists('erp_stations');
    }
};
