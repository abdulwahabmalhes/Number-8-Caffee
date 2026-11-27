<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('erp_products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->string('sku', 50);
            $table->string('name_en', 255);
            $table->string('name_ar', 255);
            $table->string('category', 100);
            $table->string('station_code', 50)->default('HOT_BAR');
            $table->boolean('is_active')->default(true);
            $table->boolean('is_archived')->default(false);
            $table->timestamps();

            $table->unique(['tenant_id', 'sku']);
        });

        Schema::create('erp_product_variants', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('product_id')->constrained('erp_products')->cascadeOnDelete();
            $table->string('name_en', 100);
            $table->string('name_ar', 100);
            $table->unsignedBigInteger('price_minor');
            $table->boolean('is_default')->default(false);
            $table->timestamps();
        });

        Schema::create('erp_product_branch', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('branch_id')->constrained('erp_branches')->cascadeOnDelete();
            $table->foreignId('product_id')->constrained('erp_products')->cascadeOnDelete();
            $table->unsignedBigInteger('variant_id')->nullable();
            $table->unsignedBigInteger('price_override_minor')->nullable();
            $table->boolean('is_available')->default(true);
            $table->timestamps();

            $table->unique(['tenant_id', 'branch_id', 'product_id', 'variant_id'], 'erp_prod_branch_unique');
        });

        Schema::create('erp_recipes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('tenant_id')->constrained('erp_tenants')->cascadeOnDelete();
            $table->foreignId('product_id')->constrained('erp_products')->cascadeOnDelete();
            $table->unsignedBigInteger('variant_id')->nullable();
            $table->string('name', 255);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('erp_recipe_versions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('recipe_id')->constrained('erp_recipes')->cascadeOnDelete();
            $table->unsignedInteger('version_number')->default(1);
            $table->boolean('is_active')->default(true);
            $table->timestamp('effective_from')->useCurrent();
            $table->timestamps();
        });

        Schema::create('erp_recipe_lines', function (Blueprint $table) {
            $table->id();
            $table->foreignId('recipe_version_id')->constrained('erp_recipe_versions')->cascadeOnDelete();
            $table->foreignId('inventory_item_id')->constrained('erp_inventory_items')->cascadeOnDelete();
            $table->decimal('quantity', 12, 4);
            $table->string('unit', 30)->default('kg');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('erp_recipe_lines');
        Schema::dropIfExists('erp_recipe_versions');
        Schema::dropIfExists('erp_recipes');
        Schema::dropIfExists('erp_product_branch');
        Schema::dropIfExists('erp_product_variants');
        Schema::dropIfExists('erp_products');
    }
};
