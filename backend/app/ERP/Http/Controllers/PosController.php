<?php

namespace App\ERP\Http\Controllers;

use App\ERP\Application\Exceptions\IdempotencyConflictException;
use App\ERP\Application\Exceptions\InsufficientStockException;
use App\ERP\Application\Services\BranchAccessService;
use App\ERP\Application\Services\PosSaleService;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpProduct;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PosController
{
    public function __construct(
        private readonly PosSaleService $posSaleService,
        private readonly BranchAccessService $branchAccessService
    ) {
    }

    public function catalog(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($request->header('X-Branch-ID') ?? $context->getActiveBranchId() ?? 1);
        $this->branchAccessService->assertBranchAccess($context, $branchId);
        $this->branchAccessService->assertBranchAccess($context, $branchId);

        $products = ErpProduct::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('is_archived', false)
            ->where('is_active', true)
            ->with(['variants', 'branchSettings' => fn ($q) => $q->where('branch_id', $branchId)])
            ->get();

        // Project available products with price overrides
        $catalog = $products->map(function (ErpProduct $p) use ($branchId) {
            $variants = $p->variants->map(function ($v) use ($p, $branchId) {
                $override = $p->branchSettings->firstWhere('variant_id', $v->id);
                return [
                    'id' => $v->id,
                    'name_en' => $v->name_en,
                    'name_ar' => $v->name_ar,
                    'price_minor' => $override?->price_override_minor ?? $v->price_minor,
                    'is_default' => (bool) $v->is_default,
                    'is_available' => $override?->is_available ?? true,
                ];
            });

            return [
                'id' => $p->id,
                'sku' => $p->sku,
                'name_en' => $p->name_en,
                'name_ar' => $p->name_ar,
                'category' => $p->category,
                'station_code' => $p->station_code,
                'variants' => $variants,
            ];
        });

        return response()->json([
            'branch_id' => $branchId,
            'catalog' => $catalog,
        ]);
    }

    public function quote(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($request->header('X-Branch-ID') ?? $context->getActiveBranchId() ?? 1);
        $this->branchAccessService->assertBranchAccess($context, $branchId);

        $validated = $request->validate([
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|integer',
            'items.*.variant_id' => 'nullable|integer',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.selected_options' => 'nullable|array',
        ]);

        $quote = $this->posSaleService->calculateQuote($context, $branchId, $validated['items']);

        return response()->json($quote);
    }

    public function checkout(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($request->header('X-Branch-ID') ?? $context->getActiveBranchId() ?? 1);
        $this->branchAccessService->assertBranchAccess($context, $branchId);

        $idempotencyKey = $request->header('Idempotency-Key') ?? $request->input('idempotency_key');
        if (empty($idempotencyKey)) {
            return response()->json([
                'error' => [
                    'code' => 'missing_idempotency_key',
                    'message' => 'Mutating sales operations require an Idempotency-Key header.',
                    'request_id' => $request->header('X-Request-ID'),
                ],
            ], 400);
        }

        $validated = $request->validate([
            'customer_id' => 'nullable|integer',
            'guest_name' => 'nullable|string|max:100',
            'order_type' => 'nullable|string|in:dine_in,takeaway,car_pickup',
            'notes' => 'nullable|string',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|integer',
            'items.*.variant_id' => 'nullable|integer',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.selected_options' => 'nullable|array',
        ]);

        try {
            $order = $this->posSaleService->checkoutCash(
                context: $context,
                branchId: $branchId,
                data: $validated,
                idempotencyKey: (string) $idempotencyKey,
                userId: $request->user()?->id
            );

            $status = $order->wasRecentlyCreated ? 201 : 200;
            return response()->json($order, $status);
        } catch (\App\ERP\Application\Exceptions\InsufficientStockException $e) {
            return response()->json([
                'error' => [
                    'code' => 'insufficient_stock',
                    'message' => $e->getMessage(),
                ],
            ], 422);
        } catch (\App\ERP\Application\Exceptions\IdempotencyConflictException $e) {
            return response()->json([
                'error' => [
                    'code' => 'idempotency_conflict',
                    'message' => $e->getMessage(),
                    'request_id' => $request->header('X-Request-ID'),
                ],
            ], 409);
        }
    }
}
