<?php

namespace App\ERP\Domain\Tenancy;

use App\ERP\Infrastructure\Persistence\Models\ErpBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpTenant;

final class TenantContext
{
    public function __construct(
        private readonly ErpTenant $tenant,
        private readonly ?ErpBranch $activeBranch = null,
        private readonly ?int $userId = null
    ) {
    }

    public function getTenant(): ErpTenant
    {
        return $this->tenant;
    }

    public function getTenantId(): int
    {
        return (int) $this->tenant->id;
    }

    public function getActiveBranch(): ?ErpBranch
    {
        return $this->activeBranch;
    }

    public function getActiveBranchId(): ?int
    {
        return $this->activeBranch ? (int) $this->activeBranch->id : null;
    }

    public function getUserId(): ?int
    {
        return $this->userId;
    }

    public function withActiveBranch(?ErpBranch $branch): self
    {
        return new self($this->tenant, $branch, $this->userId);
    }
}
