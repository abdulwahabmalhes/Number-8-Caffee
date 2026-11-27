<?php

namespace App\ERP\Application\Services;

use App\ERP\Application\Contracts\AuditLogger;
use App\ERP\Domain\Authorization\BranchAccess;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpTenantUser;
use App\ERP\Infrastructure\Persistence\Models\ErpUserBranch;

class BranchAccessService
{
    public function __construct(
        private readonly BranchAccess $branchAccess,
        private readonly AuditLogger $auditLogger
    ) {
    }

    /**
     * @param list<int> $assignedBranchIds
     */
    public function canAccessBranch(
        TenantContext $context,
        int $userId,
        int $requestedBranchId,
        array $assignedBranchIds,
        bool $isTenantAdministrator,
        ?string $requestId = null
    ): bool {
        $allowed = $this->branchAccess->allows($requestedBranchId, $assignedBranchIds, $isTenantAdministrator);

        if (! $allowed) {
            return false;
        }

        // Audited tenant-admin override:
        if ($isTenantAdministrator && ! in_array($requestedBranchId, $assignedBranchIds, true)) {
            $this->auditLogger->record(
                actorId: (string) $userId,
                action: 'branch.admin_override',
                aggregateId: (string) $requestedBranchId,
                context: [
                    'tenant_id' => $context->getTenantId(),
                    'branch_id' => $requestedBranchId,
                    'request_id' => $requestId,
                    'reason' => 'Tenant administrator accessed unassigned branch',
                ]
            );
        }

        return true;
    }

    public function assertBranchAccess(
        TenantContext $context,
        int $branchId,
        ?int $userId = null,
        ?string $requestId = null
    ): void {
        if ($branchId <= 0) {
            abort(response()->json([
                'error' => [
                    'code' => 'invalid_branch',
                    'message' => 'A valid branch must be specified.',
                    'request_id' => $requestId,
                    'fields' => (object) [],
                ],
            ], 400));
        }

        $resolvedUserId = $userId ?? $context->getUserId();

        if ($resolvedUserId) {
            $tenantUser = ErpTenantUser::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('user_id', $resolvedUserId)
                ->first();

            $isTenantAdmin = (bool) ($tenantUser?->is_tenant_admin ?? false);

            $assignedBranchIds = ErpUserBranch::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('user_id', $resolvedUserId)
                ->pluck('branch_id')
                ->map(fn ($id) => (int) $id)
                ->all();
        } else {
            $isTenantAdmin = false;
            $assignedBranchIds = [];
        }

        $allowed = $this->canAccessBranch(
            context: $context,
            userId: (int) ($resolvedUserId ?? 0),
            requestedBranchId: $branchId,
            assignedBranchIds: $assignedBranchIds,
            isTenantAdministrator: $isTenantAdmin,
            requestId: $requestId
        );

        if (! $allowed) {
            abort(response()->json([
                'error' => [
                    'code' => 'branch_access_denied',
                    'message' => 'You do not have access to this branch.',
                    'request_id' => $requestId,
                    'fields' => (object) [],
                ],
            ], 403));
        }
    }
}
