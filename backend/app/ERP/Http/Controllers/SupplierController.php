<?php

namespace App\ERP\Http\Controllers;

use App\ERP\Application\Exceptions\IdempotencyConflictException;
use App\ERP\Application\Services\BranchAccessService;
use App\ERP\Application\Services\IdempotencyService;
use App\ERP\Application\Services\PurchasingService;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpPurchaseOrder;
use App\ERP\Infrastructure\Persistence\Models\ErpSupplier;
use App\ERP\Infrastructure\Persistence\Models\ErpSupplierInvoice;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use InvalidArgumentException;

class SupplierController
{
    public function __construct(
        private readonly PurchasingService $purchasingService,
        private readonly BranchAccessService $branchAccessService,
        private readonly IdempotencyService $idempotencyService
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $query = ErpSupplier::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('is_active', true)
            ->withCount('purchaseOrders');

        if ($search = $request->query('q')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%")
                  ->orWhere('tax_number', 'like', "%{$search}%");
            });
        }

        return response()->json([
            'suppliers' => $query->orderBy('name')->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'contact_name' => 'nullable|string|max:100',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:100',
            'tax_number' => 'nullable|string|max:50',
            'address' => 'nullable|string|max:255',
        ]);

        $supplier = ErpSupplier::create([
            'tenant_id' => $context->getTenantId(),
            'name' => $validated['name'],
            'contact_name' => $validated['contact_name'] ?? null,
            'phone' => $validated['phone'] ?? null,
            'email' => $validated['email'] ?? null,
            'tax_number' => $validated['tax_number'] ?? null,
            'address' => $validated['address'] ?? null,
            'is_active' => true,
        ]);

        return response()->json($supplier, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $branchId = (int) ($context->getActiveBranchId() ?? $request->header('X-Branch-ID') ?? $request->query('branch_id'));
        if ($branchId > 0) {
            $this->branchAccessService->assertBranchAccess($context, $branchId);
        }

        $supplier = ErpSupplier::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $id)
            ->with([
                'purchaseOrders' => function ($query) use ($branchId) {
                    if ($branchId > 0) {
                        $query->where('branch_id', $branchId);
                    }
                    $query->with(['lines.item', 'goodsReceipts.lines.item', 'invoices']);
                },
            ])
            ->firstOrFail();

        return response()->json($supplier);
    }

    public function createPurchaseOrder(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($request->input('branch_id') ?? $context->getActiveBranchId() ?? $request->header('X-Branch-ID'));
        $this->branchAccessService->assertBranchAccess($context, $branchId);

        $validated = $request->validate([
            'supplier_id' => 'required|integer',
            'branch_id' => 'nullable|integer',
            'lines' => 'required|array|min:1',
            'lines.*.inventory_item_id' => 'required|integer',
            'lines.*.ordered_quantity' => 'required|numeric|min:0.01',
            'lines.*.unit_cost_minor' => 'nullable|integer|min:0',
            'notes' => 'nullable|string',
        ]);

        $po = $this->purchasingService->createPurchaseOrder(
            context: $context,
            branchId: $branchId,
            data: $validated,
            userId: $request->user()?->id
        );

        return response()->json($po, 201);
    }

    public function receiveGoods(Request $request, int $poId): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $po = ErpPurchaseOrder::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $poId)
            ->firstOrFail();

        $this->branchAccessService->assertBranchAccess($context, $po->branch_id);

        $idempotencyKey = $request->header('Idempotency-Key') ?? $request->input('idempotency_key');
        if (empty($idempotencyKey)) {
            return response()->json([
                'error' => [
                    'code' => 'missing_idempotency_key',
                    'message' => 'Idempotency-Key header is required for receiving goods.',
                    'request_id' => $request->header('X-Request-ID'),
                ],
            ], 400);
        }

        $validated = $request->validate([
            'lines' => 'required|array|min:1',
            'lines.*.po_line_id' => 'required|integer',
            'lines.*.quantity_received' => 'required|numeric|min:0.001',
            'received_by' => 'nullable|string|max:100',
            'notes' => 'nullable|string',
        ]);

        $receivedBy = $request->input('received_by') ?? $request->user()?->name ?? 'Staff User';

        try {
            $requestPayload = array_merge($validated, ['po_id' => $poId]);

            $result = $this->idempotencyService->execute(
                tenantId: $context->getTenantId(),
                branchId: $po->branch_id,
                actionType: 'goods_receipt',
                idempotencyKey: (string) $idempotencyKey,
                requestPayload: $requestPayload,
                callback: function () use ($context, $poId, $validated, $receivedBy) {
                    $receipt = $this->purchasingService->receiveGoods(
                        context: $context,
                        poId: $poId,
                        receivedLines: $validated['lines'],
                        receivedBy: $receivedBy,
                        notes: $validated['notes'] ?? null
                    );

                    return [
                        'code' => 201,
                        'body' => $receipt->toArray(),
                        'resource_id' => $receipt->id,
                    ];
                },
                userId: $request->user()?->id
            );

            $response = response()->json($result['body'], $result['code']);
            if (! empty($result['is_replay']) || ! empty($result['replayed'])) {
                $response->header('X-Idempotent-Replay', 'true');
            }

            return $response;
        } catch (IdempotencyConflictException $e) {
            return response()->json([
                'error' => [
                    'code' => 'idempotency_conflict',
                    'message' => $e->getMessage(),
                ],
            ], 409);
        } catch (InvalidArgumentException $e) {
            return response()->json([
                'error' => [
                    'code' => 'over_receipt_rejected',
                    'message' => $e->getMessage(),
                ],
            ], 400);
        }
    }

    public function createInvoice(Request $request, int $poId): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $po = ErpPurchaseOrder::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $poId)
            ->firstOrFail();

        $this->branchAccessService->assertBranchAccess($context, $po->branch_id);

        $validated = $request->validate([
            'goods_receipt_id' => 'required|integer',
            'invoice_number' => 'required|string|max:50',
            'invoice_date' => 'required|date',
            'tax_minor' => 'nullable|integer|min:0',
        ]);

        try {
            $invoice = $this->purchasingService->createSupplierInvoice(
                context: $context,
                poId: $poId,
                goodsReceiptId: (int) $validated['goods_receipt_id'],
                invoiceNumber: $validated['invoice_number'],
                invoiceDate: $validated['invoice_date'],
                taxMinor: $validated['tax_minor'] ?? null
            );

            return response()->json($invoice, 201);
        } catch (InvalidArgumentException $e) {
            $errorCode = str_contains($e->getMessage(), 'already been invoiced')
                ? 'goods_receipt_already_invoiced'
                : 'invalid_invoice';

            return response()->json([
                'error' => [
                    'code' => $errorCode,
                    'message' => $e->getMessage(),
                ],
            ], 400);
        }
    }
}
