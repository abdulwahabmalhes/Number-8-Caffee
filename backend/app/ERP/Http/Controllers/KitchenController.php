<?php

namespace App\ERP\Http\Controllers;

use App\ERP\Application\Services\BranchAccessService;
use App\ERP\Application\Services\KitchenService;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpKitchenTicket;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class KitchenController
{
    public function __construct(
        private readonly KitchenService $kitchenService,
        private readonly BranchAccessService $branchAccessService
    ) {
    }

    public function index(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($request->header('X-Branch-ID') ?? $context->getActiveBranchId() ?? 1);
        $this->branchAccessService->assertBranchAccess($context, $branchId);

        $station = $request->query('station');
        $status = $request->query('status');

        $tickets = $this->kitchenService->getBranchTickets(
            context: $context,
            branchId: $branchId,
            stationCode: $station,
            status: $status
        );

        return response()->json([
            'branch_id' => $branchId,
            'tickets' => $tickets,
        ]);
    }

    public function updateStatus(Request $request, int $id): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $ticket = ErpKitchenTicket::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $id)
            ->firstOrFail();

        $this->branchAccessService->assertBranchAccess($context, $ticket->branch_id);

        $validated = $request->validate([
            'status' => 'required|string|in:preparing,ready,completed',
        ]);

        $ticket = $this->kitchenService->updateTicketStatus(
            context: $context,
            ticketId: $id,
            nextStatus: $validated['status']
        );

        return response()->json($ticket);
    }
}
