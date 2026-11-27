<?php

namespace App\ERP\Application\Services;

use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpTenantUser;
use App\ERP\Infrastructure\Persistence\Models\ErpUserPermission;

class PermissionService
{
    /** @var list<string> */
    private readonly array $allowedPermissions;

    public function __construct()
    {
        $this->allowedPermissions = (array) config('erp.permissions', []);
    }

    public function can(TenantContext $context, int $userId, string $permission): bool
    {
        // Permission must be in allow-list
        if (! in_array($permission, $this->allowedPermissions, true)) {
            return false;
        }

        // Check if user is tenant admin
        $isTenantAdmin = ErpTenantUser::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('user_id', $userId)
            ->where('is_active', true)
            ->value('is_tenant_admin');

        if ($isTenantAdmin) {
            return true;
        }

        // Deny by default: check explicit user permission in tenant
        return ErpUserPermission::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('user_id', $userId)
            ->where('permission', $permission)
            ->exists();
    }
}
