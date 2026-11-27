<?php

namespace App\ERP\Infrastructure\Persistence\Repositories;

use App\ERP\Application\Contracts\StaffSessionRepositoryInterface;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpTenantUser;
use App\ERP\Infrastructure\Persistence\Models\ErpUserBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpUserPermission;
use App\Models\User;

class EloquentStaffSessionRepository implements StaffSessionRepositoryInterface
{
    public function getSession(TenantContext $context, int $userId): array
    {
        $user = User::query()->findOrFail($userId);

        $tenantUser = ErpTenantUser::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('user_id', $userId)
            ->where('is_active', true)
            ->first();

        $isTenantAdmin = (bool) ($tenantUser?->is_tenant_admin ?? false);
        $role = $tenantUser?->role ?? 'staff';

        $userBranches = ErpUserBranch::query()
            ->with('branch')
            ->where('tenant_id', $context->getTenantId())
            ->where('user_id', $userId)
            ->get();

        $assignedBranches = $userBranches->map(function (ErpUserBranch $ub) {
            return [
                'id' => (int) $ub->branch->id,
                'name' => $ub->branch->name,
                'code' => $ub->branch->code,
                'is_default' => (bool) $ub->is_default,
            ];
        })->values()->all();

        $activeBranch = $context->getActiveBranch();
        if (! $activeBranch && count($assignedBranches) > 0) {
            $default = $userBranches->firstWhere('is_default', true) ?? $userBranches->first();
            $activeBranch = $default?->branch;
        }

        $permissions = ErpUserPermission::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('user_id', $userId)
            ->pluck('permission')
            ->values()
            ->all();

        // If tenant admin, grant all configured permissions
        if ($isTenantAdmin) {
            $allPerms = (array) config('erp.permissions', []);
            $permissions = array_values(array_unique(array_merge($permissions, $allPerms)));
        }

        return [
            'user' => [
                'id' => (int) $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
            'tenant' => [
                'id' => $context->getTenantId(),
                'slug' => $context->getTenant()->slug,
                'name' => $context->getTenant()->name,
            ],
            'role' => $role,
            'is_tenant_admin' => $isTenantAdmin,
            'assigned_branches' => $assignedBranches,
            'active_branch' => $activeBranch ? [
                'id' => (int) $activeBranch->id,
                'name' => $activeBranch->name,
                'code' => $activeBranch->code,
            ] : null,
            'permissions' => $permissions,
        ];
    }
}
