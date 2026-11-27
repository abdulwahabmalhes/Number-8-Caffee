<?php

namespace App\ERP\Infrastructure\Persistence\Repositories;

use App\ERP\Application\Contracts\BranchRepositoryInterface;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpUserBranch;
use Illuminate\Support\Collection;

class EloquentBranchRepository implements BranchRepositoryInterface
{
    public function findForTenant(TenantContext $context, int $branchId): ?ErpBranch
    {
        return ErpBranch::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $branchId)
            ->first();
    }

    public function allForTenant(TenantContext $context): Collection
    {
        return ErpBranch::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('is_active', true)
            ->get();
    }

    public function findAssignedForUser(TenantContext $context, int $userId): Collection
    {
        $branchIds = ErpUserBranch::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('user_id', $userId)
            ->pluck('branch_id');

        return ErpBranch::query()
            ->where('tenant_id', $context->getTenantId())
            ->whereIn('id', $branchIds)
            ->where('is_active', true)
            ->get();
    }
}
