<?php

namespace App\ERP\Application\Services;

use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpKitchenTicket;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Database\Eloquent\Collection;
use InvalidArgumentException;

class KitchenService
{
    /** @return Collection<int, ErpKitchenTicket> */
    public function getBranchTickets(TenantContext $context, int $branchId, ?string $stationCode = null, ?string $status = null): Collection
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        $query = ErpKitchenTicket::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('branch_id', $branchId)
            ->with(['items', 'order']);

        if ($stationCode && $stationCode !== 'ALL') {
            $query->where('station_code', $stationCode);
        }

        if ($status) {
            $query->where('status', $status);
        } else {
            $query->where('status', '!=', 'completed');
        }

        return $query->orderBy('id', 'desc')->get();
    }

    public function updateTicketStatus(TenantContext $context, int $ticketId, string $nextStatus): ErpKitchenTicket
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        $ticket = ErpKitchenTicket::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $ticketId)
            ->firstOrFail();

        $validTransitions = [
            'new' => ['preparing'],
            'preparing' => ['ready'],
            'ready' => ['completed'],
        ];

        if (!isset($validTransitions[$ticket->status]) || !in_array($nextStatus, $validTransitions[$ticket->status], true)) {
            // Allow idempotency if already in nextStatus
            if ($ticket->status === $nextStatus) {
                return $ticket->load(['items', 'order']);
            }
            throw new InvalidArgumentException("Invalid transition from '{$ticket->status}' to '{$nextStatus}'.");
        }

        $ticket->status = $nextStatus;
        if ($nextStatus === 'preparing' && !$ticket->started_at) {
            $ticket->started_at = now();
        } elseif ($nextStatus === 'ready' && !$ticket->ready_at) {
            $ticket->ready_at = now();
        } elseif ($nextStatus === 'completed' && !$ticket->completed_at) {
            $ticket->completed_at = now();
        }

        $ticket->save();

        return $ticket->load(['items', 'order']);
    }
}
