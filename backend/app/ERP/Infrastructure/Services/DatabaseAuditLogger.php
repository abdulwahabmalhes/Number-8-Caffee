<?php

namespace App\ERP\Infrastructure\Services;

use App\ERP\Application\Contracts\AuditLogger;
use App\ERP\Infrastructure\Persistence\Models\ErpAuditLog;

class DatabaseAuditLogger implements AuditLogger
{
    public function record(string $actorId, string $action, string $aggregateId, array $context = []): void
    {
        $tenantId = isset($context['tenant_id']) ? (int) $context['tenant_id'] : null;
        $branchId = isset($context['branch_id']) ? (int) $context['branch_id'] : null;
        $requestId = isset($context['request_id']) ? (string) $context['request_id'] : null;
        $ipAddress = isset($context['ip_address']) ? (string) $context['ip_address'] : request()?->ip();

        ErpAuditLog::query()->create([
            'tenant_id' => $tenantId,
            'branch_id' => $branchId,
            'actor_id' => $actorId,
            'action' => $action,
            'aggregate_id' => $aggregateId,
            'context' => $context,
            'ip_address' => $ipAddress,
            'request_id' => $requestId,
        ]);
    }
}
