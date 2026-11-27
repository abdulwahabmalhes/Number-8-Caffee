<?php

namespace App\ERP\Http\Middleware;

use App\ERP\Application\Contracts\BranchRepositoryInterface;
use App\ERP\Application\Contracts\TenantRepositoryInterface;
use App\ERP\Application\Services\BranchAccessService;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpTenantUser;
use App\ERP\Infrastructure\Persistence\Models\ErpUserBranch;
use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class ErpStaffSession
{
    public function __construct(
        private readonly TenantRepositoryInterface $tenantRepository,
        private readonly BranchRepositoryInterface $branchRepository,
        private readonly BranchAccessService $branchAccessService
    ) {
    }

    public function handle(Request $request, Closure $next): Response
    {
        $requestId = $request->header('X-Request-ID');
        $user = $request->user();

        // 1. Must be authenticated and must be staff User model
        if (! $user) {
            return response()->json([
                'error' => [
                    'code' => 'unauthenticated',
                    'message' => 'Authentication required for ERP access.',
                    'request_id' => $requestId,
                    'fields' => (object) [],
                ],
            ], 401);
        }

        if (! ($user instanceof User)) {
            return response()->json([
                'error' => [
                    'code' => 'forbidden',
                    'message' => 'Customer credentials cannot access ERP.',
                    'request_id' => $requestId,
                    'fields' => (object) [],
                ],
            ], 403);
        }

        // 2. Resolve Tenant
        $tenantIdHeader = $request->header('X-Tenant-ID');
        $tenantSlugHeader = $request->header('X-Tenant-Slug');
        $tenant = null;

        if ($tenantIdHeader) {
            $tenant = $this->tenantRepository->findById((int) $tenantIdHeader);
        } elseif ($tenantSlugHeader) {
            $tenant = $this->tenantRepository->findBySlug((string) $tenantSlugHeader);
        } else {
            // Find first active tenant user belongs to
            $userTenant = ErpTenantUser::query()
                ->where('user_id', $user->id)
                ->where('is_active', true)
                ->first();

            if ($userTenant) {
                $tenant = $this->tenantRepository->findById((int) $userTenant->tenant_id);
            }
        }

        if (! $tenant || $tenant->status !== 'active') {
            return response()->json([
                'error' => [
                    'code' => 'tenant_access_denied',
                    'message' => 'You do not have access to this tenant.',
                    'request_id' => $requestId,
                    'fields' => (object) [],
                ],
            ], 403);
        }

        // Check user membership in tenant
        $tenantUser = ErpTenantUser::query()
            ->where('tenant_id', $tenant->id)
            ->where('user_id', $user->id)
            ->where('is_active', true)
            ->first();

        if (! $tenantUser) {
            return response()->json([
                'error' => [
                    'code' => 'tenant_access_denied',
                    'message' => 'You do not have access to this tenant.',
                    'request_id' => $requestId,
                    'fields' => (object) [],
                ],
            ], 403);
        }

        $context = new TenantContext($tenant, null, (int) $user->id);

        // 3. Resolve and validate requested Branch if provided
        $branchIdHeader = $request->header('X-Branch-ID');
        if ($branchIdHeader !== null && $branchIdHeader !== '') {
            $requestedBranchId = (int) $branchIdHeader;
            $branch = $this->branchRepository->findForTenant($context, $requestedBranchId);

            if (! $branch) {
                return response()->json([
                    'error' => [
                        'code' => 'branch_not_found',
                        'message' => 'The requested branch was not found in this tenant.',
                        'request_id' => $requestId,
                        'fields' => (object) [],
                    ],
                ], 404);
            }

            $assignedBranchIds = ErpUserBranch::query()
                ->where('tenant_id', $tenant->id)
                ->where('user_id', $user->id)
                ->pluck('branch_id')
                ->map(fn ($id) => (int) $id)
                ->all();

            $canAccess = $this->branchAccessService->canAccessBranch(
                context: $context,
                userId: (int) $user->id,
                requestedBranchId: $requestedBranchId,
                assignedBranchIds: $assignedBranchIds,
                isTenantAdministrator: (bool) $tenantUser->is_tenant_admin,
                requestId: $requestId
            );

            if (! $canAccess) {
                return response()->json([
                    'error' => [
                        'code' => 'branch_access_denied',
                        'message' => 'You do not have access to this branch.',
                        'request_id' => $requestId,
                        'fields' => (object) [],
                    ],
                ], 403);
            }

            $context = $context->withActiveBranch($branch);
        }

        $request->attributes->set('erp_context', $context);
        app()->instance(TenantContext::class, $context);

        return $next($request);
    }
}
