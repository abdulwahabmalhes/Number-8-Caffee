<?php

namespace App\ERP\Http\Controllers;

use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpProduct;
use App\ERP\Infrastructure\Persistence\Models\ErpProductBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpProductVariant;
use App\ERP\Infrastructure\Persistence\Models\ErpRecipe;
use App\ERP\Infrastructure\Persistence\Models\ErpRecipeLine;
use App\ERP\Infrastructure\Persistence\Models\ErpRecipeVersion;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ProductController
{
    public function index(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $query = ErpProduct::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('is_archived', false)
            ->with(['variants', 'recipes.activeVersion.lines.item', 'branchSettings']);

        if ($search = $request->query('q')) {
            $query->where(function ($q) use ($search) {
                $q->where('name_en', 'like', "%{$search}%")
                  ->orWhere('name_ar', 'like', "%{$search}%")
                  ->orWhere('sku', 'like', "%{$search}%");
            });
        }

        if ($category = $request->query('category')) {
            $query->where('category', $category);
        }

        return response()->json([
            'products' => $query->orderBy('id', 'desc')->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $validated = $request->validate([
            'sku' => 'required|string|max:50',
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'category' => 'required|string|max:100',
            'station_code' => 'nullable|string|max:50',
            'variants' => 'required|array|min:1',
            'variants.*.name_en' => 'required|string|max:100',
            'variants.*.name_ar' => 'required|string|max:100',
            'variants.*.price_minor' => 'required|integer|min:0',
            'variants.*.is_default' => 'nullable|boolean',
            'recipe_lines' => 'nullable|array',
            'recipe_lines.*.inventory_item_id' => 'required_with:recipe_lines|integer',
            'recipe_lines.*.quantity' => 'required_with:recipe_lines|numeric|min:0.0001',
            'recipe_lines.*.unit' => 'required_with:recipe_lines|string|max:20',
        ]);

        $product = DB::transaction(function () use ($context, $validated) {
            $product = ErpProduct::create([
                'tenant_id' => $context->getTenantId(),
                'sku' => $validated['sku'],
                'name_en' => $validated['name_en'],
                'name_ar' => $validated['name_ar'],
                'category' => $validated['category'],
                'station_code' => $validated['station_code'] ?? 'HOT_BAR',
                'is_active' => true,
                'is_archived' => false,
            ]);

            foreach ($validated['variants'] as $v) {
                ErpProductVariant::create([
                    'tenant_id' => $context->getTenantId(),
                    'product_id' => $product->id,
                    'name_en' => $v['name_en'],
                    'name_ar' => $v['name_ar'],
                    'price_minor' => $v['price_minor'],
                    'is_default' => $v['is_default'] ?? false,
                ]);
            }

            if (!empty($validated['recipe_lines'])) {
                $recipe = ErpRecipe::create([
                    'tenant_id' => $context->getTenantId(),
                    'product_id' => $product->id,
                    'name' => "Standard Recipe for {$product->name_en}",
                    'is_active' => true,
                ]);

                $version = ErpRecipeVersion::create([
                    'recipe_id' => $recipe->id,
                    'version_number' => 1,
                    'is_active' => true,
                    'effective_from' => now(),
                ]);

                foreach ($validated['recipe_lines'] as $rl) {
                    ErpRecipeLine::create([
                        'recipe_version_id' => $version->id,
                        'inventory_item_id' => $rl['inventory_item_id'],
                        'quantity' => $rl['quantity'],
                        'unit' => $rl['unit'],
                    ]);
                }
            }

            return $product->load(['variants', 'recipes.activeVersion.lines.item']);
        });

        return response()->json($product, 201);
    }

    public function archive(Request $request, int $id): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $product = ErpProduct::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $id)
            ->firstOrFail();

        $product->update(['is_archived' => true]);

        return response()->json(['success' => true]);
    }
}
