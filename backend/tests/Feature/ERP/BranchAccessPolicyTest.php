<?php

namespace Tests\Feature\ERP;

use App\ERP\Application\Contracts\AuditLogger;
use App\ERP\Application\Services\BranchAccessService;
use App\ERP\Application\Services\PermissionService;
use App\ERP\Domain\Authorization\BranchAccess;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpTenant;
use App\ERP\Infrastructure\Persistence\Models\ErpTenantUser;
use App\ERP\Infrastructure\Persistence\Models\ErpUserPermission;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BranchAccessPolicyTest extends TestCase
{
    use RefreshDatabase;

    private ErpTenant $tenant;
    private ErpBranch $branch;
    private User $user;

    protected function setUp(): void
    {
        parent::setUp();

        $this->tenant = ErpTenant::create([
            'slug' => 'test-tenant',
            'name' => 'Test Tenant',
        ]);

        $this->branch = ErpBranch::create([
            'tenant_id' => $this->tenant->id,
            'name' => 'Branch A',
            'code' => 'BR-A',
        ]);

        $this->user = User::factory()->create();
    }

    public function test_branch_access_service_denies_unassigned_branch_for_regular_staff(): void
    {
        $context = new TenantContext($this->tenant);
        $auditLogger = $this->createMock(AuditLogger::class);
        $auditLogger->expects($this->never())->method('record');

        $service = new BranchAccessService(new BranchAccess, $auditLogger);

        $allowed = $service->canAccessBranch(
            context: $context,
            userId: (int) $this->user->id,
            requestedBranchId: 999,
            assignedBranchIds: [1, 2],
            isTenantAdministrator: false
        );

        $this->assertFalse($allowed);
    }

    public function test_branch_access_service_records_audit_for_admin_override(): void
    {
        $context = new TenantContext($this->tenant);
        $auditLogger = $this->createMock(AuditLogger::class);
        $auditLogger->expects($this->once())
            ->method('record')
            ->with(
                (string) $this->user->id,
                'branch.admin_override',
                '999',
                $this->callback(function (array $ctx) {
                    return $ctx['branch_id'] === 999 && $ctx['tenant_id'] === $this->tenant->id;
                })
            );

        $service = new BranchAccessService(new BranchAccess, $auditLogger);

        $allowed = $service->canAccessBranch(
            context: $context,
            userId: (int) $this->user->id,
            requestedBranchId: 999,
            assignedBranchIds: [1, 2],
            isTenantAdministrator: true,
            requestId: 'req-123'
        );

        $this->assertTrue($allowed);
    }

    public function test_permission_service_denies_unauthorized_permission_by_default(): void
    {
        $context = new TenantContext($this->tenant);
        $service = new PermissionService;

        $this->assertFalse($service->can($context, (int) $this->user->id, 'accounting.post'));
    }

    public function test_permission_service_allows_explicit_permission(): void
    {
        $context = new TenantContext($this->tenant);

        ErpUserPermission::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->user->id,
            'permission' => 'pos.use',
        ]);

        $service = new PermissionService;

        $this->assertTrue($service->can($context, (int) $this->user->id, 'pos.use'));
        $this->assertFalse($service->can($context, (int) $this->user->id, 'accounting.post'));
    }

    public function test_permission_service_allows_all_for_tenant_admin(): void
    {
        $context = new TenantContext($this->tenant);

        ErpTenantUser::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->user->id,
            'role' => 'Administrator',
            'is_tenant_admin' => true,
            'is_active' => true,
        ]);

        $service = new PermissionService;

        $this->assertTrue($service->can($context, (int) $this->user->id, 'pos.use'));
        $this->assertTrue($service->can($context, (int) $this->user->id, 'accounting.post'));
        $this->assertFalse($service->can($context, (int) $this->user->id, 'some.unknown.arbitrary.permission'));
    }
}
