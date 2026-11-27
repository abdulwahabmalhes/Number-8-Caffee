<?php

namespace App\ERP\Application\Contracts;

use App\ERP\Domain\Tenancy\TenantContext;

interface StaffSessionRepositoryInterface
{
    /** @return array<string, mixed> */
    public function getSession(TenantContext $context, int $userId): array;
}
