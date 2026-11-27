<?php

namespace Tests\Feature\ERP;

use App\ERP\Infrastructure\Persistence\Models\ErpAuditLog;
use App\ERP\Infrastructure\Persistence\Models\ErpBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpTenant;
use App\ERP\Infrastructure\Persistence\Models\ErpTenantUser;
use App\ERP\Infrastructure\Persistence\Models\ErpUserBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpUserPermission;
use App\Models\Customer;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ErpSessionTest extends TestCase
{
    use RefreshDatabase;

    private ErpTenant $tenant;
    private ErpBranch $branch1;
    private ErpBranch $branch2;
    private User $staffUser;
    private User $adminUser;

    protected function setUp(): void
    {
        parent::setUp();

        config(['erp.enabled' => true]);

        // Create Tenant
        $this->tenant = ErpTenant::create([
            'slug' => 'number-eight',
            'name' => 'NUMBER EIGHT',
            'status' => 'active',
        ]);

        // Create Branches
        $this->branch1 = ErpBranch::create([
            'tenant_id' => $this->tenant->id,
            'name' => 'Dubai Flagship',
            'code' => 'DXB-01',
            'is_active' => true,
        ]);

        $this->branch2 = ErpBranch::create([
            'tenant_id' => $this->tenant->id,
            'name' => 'Abu Dhabi Branch',
            'code' => 'AUH-01',
            'is_active' => true,
        ]);

        // Create Staff User (assigned only to branch1)
        $this->staffUser = User::factory()->create([
            'name' => 'Mariam Al Mansoori',
            'email' => 'mariam@no8.ae',
        ]);

        ErpTenantUser::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->staffUser->id,
            'role' => 'Branch Manager',
            'is_tenant_admin' => false,
            'is_active' => true,
        ]);

        ErpUserBranch::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->staffUser->id,
            'branch_id' => $this->branch1->id,
            'is_default' => true,
        ]);

        ErpUserPermission::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->staffUser->id,
            'permission' => 'pos.use',
        ]);

        ErpUserPermission::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->staffUser->id,
            'permission' => 'dashboard.view',
        ]);

        // Create Tenant Admin User (not assigned to any branch explicitly)
        $this->adminUser = User::factory()->create([
            'name' => 'Owner Admin',
            'email' => 'admin@no8.ae',
        ]);

        ErpTenantUser::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->adminUser->id,
            'role' => 'Tenant Administrator',
            'is_tenant_admin' => true,
            'is_active' => true,
        ]);
    }

    public function test_returns_404_when_erp_feature_is_disabled(): void
    {
        config(['erp.enabled' => false]);

        $response = $this->getJson('/api/erp/v1/session');

        $response->assertStatus(404);
        $response->assertJsonPath('error.code', 'erp_disabled');
    }

    public function test_unauthenticated_request_is_denied(): void
    {
        $response = $this->getJson('/api/erp/v1/session');

        $response->assertStatus(401);
        $response->assertJsonPath('error.code', 'unauthenticated');
        $this->assertNotEmpty($response->headers->get('X-Request-ID'));
    }

    public function test_customer_credentials_cannot_access_erp(): void
    {
        $customer = Customer::create([
            'name' => 'Customer Test',
            'phone' => '971501112233',
        ]);

        Sanctum::actingAs($customer);

        $response = $this->getJson('/api/erp/v1/session');

        $response->assertStatus(403);
        $response->assertJsonPath('error.code', 'forbidden');
    }

    public function test_user_without_tenant_membership_is_denied(): void
    {
        $unassignedUser = User::factory()->create([
            'email' => 'stranger@example.com',
        ]);

        $this->actingAs($unassignedUser);

        $response = $this->getJson('/api/erp/v1/session');

        $response->assertStatus(403);
        $response->assertJsonPath('error.code', 'tenant_access_denied');
    }

    public function test_user_requesting_wrong_tenant_is_denied(): void
    {
        $otherTenant = ErpTenant::create([
            'slug' => 'other-tenant',
            'name' => 'Other Tenant',
            'status' => 'active',
        ]);

        $this->actingAs($this->staffUser);

        $response = $this->getJson('/api/erp/v1/session', [
            'X-Tenant-Slug' => $otherTenant->slug,
        ]);

        $response->assertStatus(403);
        $response->assertJsonPath('error.code', 'tenant_access_denied');
    }

    public function test_user_requesting_unassigned_branch_is_denied(): void
    {
        $this->actingAs($this->staffUser);

        $response = $this->getJson('/api/erp/v1/session', [
            'X-Branch-ID' => (string) $this->branch2->id,
        ]);

        $response->assertStatus(403);
        $response->assertJsonPath('error.code', 'branch_access_denied');
    }

    public function test_user_with_allowed_branch_succeeds_and_returns_session(): void
    {
        $this->actingAs($this->staffUser);

        $response = $this->getJson('/api/erp/v1/session', [
            'X-Branch-ID' => (string) $this->branch1->id,
        ]);

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'user' => ['id', 'name', 'email'],
            'tenant' => ['id', 'slug', 'name'],
            'role',
            'is_tenant_admin',
            'assigned_branches' => [
                '*' => ['id', 'name', 'code', 'is_default'],
            ],
            'active_branch' => ['id', 'name', 'code'],
            'permissions',
        ]);

        $response->assertJsonPath('user.email', 'mariam@no8.ae');
        $response->assertJsonPath('tenant.slug', 'number-eight');
        $response->assertJsonPath('role', 'Branch Manager');
        $response->assertJsonPath('is_tenant_admin', false);
        $response->assertJsonPath('active_branch.id', $this->branch1->id);
        $this->assertContains('pos.use', $response->json('permissions'));
        $this->assertContains('dashboard.view', $response->json('permissions'));
        $this->assertNotEmpty($response->headers->get('X-Request-ID'));
    }

    public function test_tenant_administrator_override_is_audited(): void
    {
        $this->actingAs($this->adminUser);

        $response = $this->getJson('/api/erp/v1/session', [
            'X-Branch-ID' => (string) $this->branch2->id,
        ]);

        $response->assertStatus(200);
        $response->assertJsonPath('is_tenant_admin', true);
        $response->assertJsonPath('active_branch.id', $this->branch2->id);

        // Verify audit log has the admin override record
        $this->assertDatabaseHas('erp_audit_logs', [
            'tenant_id' => $this->tenant->id,
            'branch_id' => $this->branch2->id,
            'actor_id' => (string) $this->adminUser->id,
            'action' => 'branch.admin_override',
            'aggregate_id' => (string) $this->branch2->id,
        ]);

        $auditLog = ErpAuditLog::query()
            ->where('action', 'branch.admin_override')
            ->first();

        $this->assertNotNull($auditLog);
        $this->assertSame('Tenant administrator accessed unassigned branch', $auditLog->context['reason']);
    }
}
