<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('erp_customers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->string('name', 255);
            $table->string('phone', 50)->nullable();
            $table->string('email', 100)->nullable();
            $table->text('notes')->nullable();
            $table->unsignedBigInteger('loyalty_points')->default(0);
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['tenant_id', 'phone']);
        });

        Schema::table('erp_orders', function (Blueprint $table) {
            $table->unsignedBigInteger('customer_id')->nullable()->after('branch_id');
            $table->string('guest_name', 100)->nullable()->after('customer_id');
            $table->text('notes')->nullable()->after('status');
        });

        Schema::table('erp_order_lines', function (Blueprint $table) {
            $table->unsignedBigInteger('variant_id')->nullable()->after('product_id');
            $table->unsignedBigInteger('recipe_version_id')->nullable()->after('variant_id');
            $table->json('recipe_snapshot')->nullable()->after('selected_options');
        });
    }

    public function down(): void
    {
        Schema::table('erp_order_lines', function (Blueprint $table) {
            $table->dropColumn(['variant_id', 'recipe_version_id', 'recipe_snapshot']);
        });

        Schema::table('erp_orders', function (Blueprint $table) {
            $table->dropColumn(['customer_id', 'guest_name', 'notes']);
        });

        Schema::dropIfExists('erp_customers');
    }
};
