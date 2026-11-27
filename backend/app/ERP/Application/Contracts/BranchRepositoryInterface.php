<?php

namespace App\ERP\Application\Contracts;

use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpBranch;
use Illuminate\Support\Collection;

interface BranchRepositoryInterface
{
    public function findForTenant(TenantContext $context, int $branchId): ?ErpBranch;

    /** @return Collection<int, ErpBranch> */
    public function allForTenant(TenantContext $context): Collection;

    /** @return Collection<int, ErpBranch> */
    public function findAssignedForUser(TenantContext $context, int $userId): Collection;
}
