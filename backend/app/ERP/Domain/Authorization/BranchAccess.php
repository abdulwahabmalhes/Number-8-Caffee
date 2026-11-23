<?php

namespace App\ERP\Domain\Authorization;

final class BranchAccess
{
    /** @param list<int> $assignedBranchIds */
    public function allows(int $requestedBranchId, array $assignedBranchIds, bool $isTenantAdministrator = false): bool
    {
        return $isTenantAdministrator || in_array($requestedBranchId, $assignedBranchIds, true);
    }
}
