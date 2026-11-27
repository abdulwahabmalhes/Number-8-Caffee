<?php

namespace App\ERP\Http\Controllers;

use App\ERP\Application\Services\BranchAccessService;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryBalance;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryItem;
use App\ERP\Infrastructure\Persistence\Models\ErpRecipe;
use App\ERP\Infrastructure\Persistence\Models\ErpStockMovement;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class InventoryController
{
    public function __construct(
        private readonly BranchAccessService $branchAccessService
    ) {
    }

    public function items(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($context->getActiveBranchId() ?? $request->header('X-Branch-ID') ?? 1);
        $this->branchAccessService->assertBranchAccess($context, $branchId);

        $items = ErpInventoryItem::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('is_active', true)
            ->orderBy('name_en')
            ->get()
            ->map(function (ErpInventoryItem $item) use ($context, $branchId) {
                $branchBal = ErpInventoryBalance::query()
                    ->where('tenant_id', $context->getTenantId())
                    ->where('branch_id', $branchId)
                    ->where('inventory_item_id', $item->id)
                    ->first();

                return [
                    'id' => $item->id,
                    'sku' => $item->sku,
                    'name_en' => $item->name_en,
                    'name_ar' => $item->name_ar,
                    'unit' => $item->unit,
                    'current_quantity' => $branchBal ? (float) $branchBal->current_quantity : 0.0,
                    'reorder_threshold' => $branchBal ? (float) $branchBal->reorder_threshold : (float) $item->reorder_threshold,
                    'unit_cost_minor' => $item->unit_cost_minor,
                    'is_active' => $item->is_active,
                ];
            });

        return response()->json([
            'branch_id' => $branchId,
            'items' => $items,
        ]);
    }

    public function storeItem(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $validated = $request->validate([
            'sku' => 'required|string|max:50',
            'name_en' => 'required|string|max:255',
            'name_ar' => 'required|string|max:255',
            'unit' => 'required|string|max:30',
            'reorder_threshold' => 'nullable|numeric|min:0',
            'unit_cost_minor' => 'nullable|integer|min:0',
            'initial_quantity' => 'nullable|numeric|min:0',
        ]);

        $item = DB::transaction(function () use ($context, $validated, $request) {
            $item = ErpInventoryItem::create([
                'tenant_id' => $context->getTenantId(),
                'sku' => $validated['sku'],
                'name_en' => $validated['name_en'],
                'name_ar' => $validated['name_ar'],
                'unit' => $validated['unit'],
                'reorder_threshold' => $validated['reorder_threshold'] ?? 10,
                'unit_cost_minor' => $validated['unit_cost_minor'] ?? 0,
                'current_quantity' => 0,
                'is_active' => true,
            ]);

            $initQty = (float) ($validated['initial_quantity'] ?? 0);
            if ($initQty > 0) {
                $branchId = (int) ($request->header('X-Branch-ID') ?? $context->getActiveBranchId() ?? 1);
                ErpStockMovement::create([
                    'tenant_id' => $context->getTenantId(),
                    'branch_id' => $branchId,
                    'inventory_item_id' => $item->id,
                    'idempotency_key' => 'INIT-MOV-' . $item->id . '-' . microtime(true),
                    'quantity_change' => $initQty,
                    'balance_after' => $initQty,
                    'reason' => 'adjustment',
                    'reference_type' => 'opening_balance',
                    'reference_id' => (string) $item->id,
                    'actor_id' => $request->user()?->name ?? 'Admin',
                    'created_at' => now(),
                ]);

                $item->update(['current_quantity' => $initQty]);
            }

            return $item;
        });

        return response()->json($item, 201);
    }

    public function recordWaste(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($request->header('X-Branch-ID') ?? $context->getActiveBranchId() ?? 1);

        $validated = $request->validate([
            'inventory_item_id' => 'required|integer',
            'quantity' => 'required|numeric|min:0.001',
            'notes' => 'required|string|max:255',
        ]);

        $movement = DB::transaction(function () use ($context, $branchId, $validated, $request) {
            $item = ErpInventoryItem::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('id', $validated['inventory_item_id'])
                ->lockForUpdate()
                ->firstOrFail();

            $wasteQty = (float) $validated['quantity'];
            $newBalance = max(0, $item->current_quantity - $wasteQty);

            $mov = ErpStockMovement::create([
                'tenant_id' => $context->getTenantId(),
                'branch_id' => $branchId,
                'inventory_item_id' => $item->id,
                'idempotency_key' => 'WASTE-' . $item->id . '-' . microtime(true),
                'quantity_change' => -$wasteQty,
                'balance_after' => $newBalance,
                'reason' => 'waste',
                'reference_type' => 'manual_waste',
                'reference_id' => $validated['notes'],
                'actor_id' => $request->user()?->name ?? 'Staff User',
                'created_at' => now(),
            ]);

            $item->update(['current_quantity' => $newBalance]);

            return $mov->load('item');
        });

        return response()->json($movement, 201);
    }

    public function movements(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($context->getActiveBranchId() ?? $request->header('X-Branch-ID') ?? 1);
        $this->branchAccessService->assertBranchAccess($context, $branchId);

        $movements = ErpStockMovement::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('branch_id', $branchId)
            ->with('item')
            ->orderBy('id', 'desc')
            ->limit(100)
            ->get();

        return response()->json([
            'branch_id' => $branchId,
            'movements' => $movements,
        ]);
    }
}
