<?php

namespace Tests\Feature\ERP;

use App\ERP\Application\Contracts\AuditLogger;
use App\ERP\Application\Exceptions\IdempotencyConflictException;
use App\ERP\Application\Exceptions\InsufficientStockException;
use App\ERP\Application\Services\IdempotencyService;
use App\ERP\Application\Services\PosSaleService;
use App\ERP\Application\Services\PurchasingService;
use App\ERP\Domain\Authorization\BranchAccess;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpAccount;
use App\ERP\Infrastructure\Persistence\Models\ErpBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpGoodsReceipt;
use App\ERP\Infrastructure\Persistence\Models\ErpIdempotencyRecord;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryBalance;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryItem;
use App\ERP\Infrastructure\Persistence\Models\ErpProduct;
use App\ERP\Infrastructure\Persistence\Models\ErpPurchaseOrder;
use App\ERP\Infrastructure\Persistence\Models\ErpPurchaseOrderLine;
use App\ERP\Infrastructure\Persistence\Models\ErpStation;
use App\ERP\Infrastructure\Persistence\Models\ErpStockMovement;
use App\ERP\Infrastructure\Persistence\Models\ErpSupplier;
use App\ERP\Infrastructure\Persistence\Models\ErpTenant;
use App\ERP\Infrastructure\Persistence\Models\ErpTenantUser;
use App\ERP\Infrastructure\Persistence\Models\ErpUserBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpUserPermission;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Str;
use Tests\TestCase;

class BranchIsolationAndIdempotencyTest extends TestCase
{
    use RefreshDatabase;

    private ErpTenant $tenant;
    private ErpBranch $dubaiBranch;
    private ErpBranch $auhBranch;
    private User $dubaiUser;
    private User $auhUser;
    private ErpInventoryItem $coffeeBeans;
    private ErpSupplier $supplier;

    protected function setUp(): void
    {
        parent::setUp();
        config(['erp.enabled' => true]);

        $this->tenant = ErpTenant::create([
            'slug' => 'number-eight',
            'name' => 'NUMBER EIGHT',
            'status' => 'active',
            'settings' => ['currency' => 'AED', 'vat_rate' => 0.05],
        ]);

        $this->dubaiBranch = ErpBranch::create([
            'tenant_id' => $this->tenant->id,
            'name' => 'Dubai Branch',
            'code' => 'DXB-01',
            'is_active' => true,
        ]);

        $this->auhBranch = ErpBranch::create([
            'tenant_id' => $this->tenant->id,
            'name' => 'Abu Dhabi Branch',
            'code' => 'AUH-01',
            'is_active' => true,
        ]);

        // Standard accounts
        $accounts = [
            ['code' => '1010', 'name_en' => 'Cash', 'type' => 'asset'],
            ['code' => '1050', 'name_en' => 'Raw Inventory', 'type' => 'asset'],
            ['code' => '2010', 'name_en' => 'Accounts Payable', 'type' => 'liability'],
            ['code' => '2020', 'name_en' => 'VAT Output', 'type' => 'liability'],
            ['code' => '4010', 'name_en' => 'Revenue', 'type' => 'revenue'],
        ];
        foreach ($accounts as $acc) {
            ErpAccount::create([
                'tenant_id' => $this->tenant->id,
                'code' => $acc['code'],
                'name_en' => $acc['name_en'],
                'name_ar' => $acc['name_en'],
                'type' => $acc['type'],
                'currency' => 'AED',
            ]);
        }

        $this->coffeeBeans = ErpInventoryItem::create([
            'tenant_id' => $this->tenant->id,
            'sku' => 'COF-ETH-01',
            'name_en' => 'Ethiopian Yirgacheffe Beans',
            'name_ar' => 'بن إثيوبي يرغاتشيفي',
            'unit' => 'kg',
            'unit_cost_minor' => 7500,
            'current_quantity' => 0,
            'reorder_threshold' => 5,
            'is_active' => true,
        ]);

        // Branch balances
        ErpInventoryBalance::create([
            'tenant_id' => $this->tenant->id,
            'branch_id' => $this->dubaiBranch->id,
            'inventory_item_id' => $this->coffeeBeans->id,
            'current_quantity' => 0,
            'reorder_threshold' => 5,
        ]);

        ErpInventoryBalance::create([
            'tenant_id' => $this->tenant->id,
            'branch_id' => $this->auhBranch->id,
            'inventory_item_id' => $this->coffeeBeans->id,
            'current_quantity' => 0,
            'reorder_threshold' => 5,
        ]);

        $this->supplier = ErpSupplier::create([
            'tenant_id' => $this->tenant->id,
            'name' => 'Gulf Beans Roasters',
            'contact_name' => 'Khalid Al Ali',
            'email' => 'khalid@gulfbeans.ae',
            'is_active' => true,
        ]);

        // Dubai Staff
        $this->dubaiUser = User::factory()->create(['email' => 'dubai.manager@number-eight.local']);
        ErpTenantUser::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->dubaiUser->id,
            'role' => 'manager',
            'is_tenant_admin' => false,
            'status' => 'active',
        ]);
        ErpUserBranch::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->dubaiUser->id,
            'branch_id' => $this->dubaiBranch->id,
            'role' => 'manager',
            'is_default' => true,
        ]);

        // Abu Dhabi Staff
        $this->auhUser = User::factory()->create(['email' => 'auh.manager@number-eight.local']);
        ErpTenantUser::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->auhUser->id,
            'role' => 'manager',
            'is_tenant_admin' => false,
            'status' => 'active',
        ]);
        ErpUserBranch::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->auhUser->id,
            'branch_id' => $this->auhBranch->id,
            'role' => 'manager',
            'is_default' => true,
        ]);

        // Permissions for both
        $permissions = ['pos.view', 'pos.create', 'purchasing.manage', 'inventory.view', 'kitchen.view', 'accounting.view'];
        foreach ([$this->dubaiUser->id, $this->auhUser->id] as $uid) {
            foreach ($permissions as $p) {
                ErpUserPermission::create([
                    'tenant_id' => $this->tenant->id,
                    'user_id' => $uid,
                    'permission' => $p,
                ]);
            }
        }
    }

    private function headers(int $branchId): array
    {
        return [
            'X-Tenant-Slug' => 'number-eight',
            'X-Branch-ID' => (string) $branchId,
        ];
    }

    /**
     * Requirement 1: Branch-scoped inventory balances decoupling.
     * Receiving goods in Dubai strictly updates Dubai balance and leaves Abu Dhabi at 0.
     */
    public function test_branch_scoped_inventory_balances_isolation(): void
    {
        $this->actingAs($this->dubaiUser);
        $headers = $this->headers($this->dubaiBranch->id);

        // Create PO in Dubai
        $poRes = $this->withHeaders($headers)->postJson('/api/erp/v1/purchasing/orders', [
            'supplier_id' => $this->supplier->id,
            'lines' => [
                [
                    'inventory_item_id' => $this->coffeeBeans->id,
                    'ordered_quantity' => 25.0,
                    'unit_cost_minor' => 7500,
                ],
            ],
        ]);
        $poRes->assertStatus(201);
        $poId = $poRes->json('id');
        $poLineId = $poRes->json('lines.0.id');

        // Receive 25kg in Dubai
        $grRes = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => 'gr-dxb-' . Str::uuid()]))
            ->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", [
                'received_by' => 'Dubai Receiver',
                'delivery_note_ref' => 'DN-DXB-001',
                'lines' => [
                    [
                        'po_line_id' => $poLineId,
                        'quantity_received' => 25.0,
                    ],
                ],
            ]);
        $grRes->assertStatus(201);

        // Assert Dubai balance is 25.0
        $dxbBalance = ErpInventoryBalance::where('branch_id', $this->dubaiBranch->id)
            ->where('inventory_item_id', $this->coffeeBeans->id)
            ->value('current_quantity');
        $this->assertEquals(25.0, (float) $dxbBalance);

        // Assert Abu Dhabi balance remains strictly 0.0
        $auhBalance = ErpInventoryBalance::where('branch_id', $this->auhBranch->id)
            ->where('inventory_item_id', $this->coffeeBeans->id)
            ->value('current_quantity');
        $this->assertEquals(0.0, (float) $auhBalance);
    }

    /**
     * Requirement 2: Multi-action idempotency ledger.
     * Verifies cached replay on identical request and 409 Conflict on payload tampering.
     */
    public function test_idempotency_service_replay_and_conflict(): void
    {
        $this->actingAs($this->dubaiUser);
        $headers = $this->headers($this->dubaiBranch->id);

        $poRes = $this->withHeaders($headers)->postJson('/api/erp/v1/purchasing/orders', [
            'supplier_id' => $this->supplier->id,
            'lines' => [
                [
                    'inventory_item_id' => $this->coffeeBeans->id,
                    'ordered_quantity' => 10.0,
                    'unit_cost_minor' => 7500,
                ],
            ],
        ]);
        $poId = $poRes->json('id');
        $poLineId = $poRes->json('lines.0.id');

        $idemKey = 'goods-receipt-unique-' . Str::uuid();
        $payload1 = [
            'delivery_note_ref' => 'DN-IDEM-01',
            'lines' => [
                [
                    'po_line_id' => $poLineId,
                    'quantity_received' => 5.0,
                ],
            ],
        ];

        // First attempt -> 201 Created
        $res1 = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => $idemKey]))
            ->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", $payload1);
        $res1->assertStatus(201);
        $receiptId = $res1->json('id');

        // Check DB ledger
        $this->assertDatabaseHas('erp_idempotency_keys', [
            'tenant_id' => $this->tenant->id,
            'branch_id' => $this->dubaiBranch->id,
            'action_type' => 'goods_receipt',
            'idempotency_key' => $idemKey,
        ]);

        // Replay with identical payload -> 201 (cached response), no extra stock movement or balance increase
        $res2 = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => $idemKey]))
            ->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", $payload1);
        $res2->assertStatus(201);
        $this->assertEquals($receiptId, $res2->json('id'));
        $this->assertEquals('true', $res2->headers->get('X-Idempotent-Replay'));

        $this->assertEquals(1, ErpGoodsReceipt::where('po_id', $poId)->count());
        $this->assertEquals(5.0, (float) ErpInventoryBalance::where('branch_id', $this->dubaiBranch->id)
            ->where('inventory_item_id', $this->coffeeBeans->id)
            ->value('current_quantity'));

        // Replay with ALTERED payload (tampered quantity 10.0 instead of 5.0) -> 409 Conflict
        $tamperedPayload = [
            'delivery_note_ref' => 'DN-IDEM-01',
            'lines' => [
                [
                    'po_line_id' => $poLineId,
                    'quantity_received' => 10.0,
                ],
            ],
        ];

        $res3 = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => $idemKey]))
            ->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", $tamperedPayload);
        $res3->assertStatus(409);
        $res3->assertJsonPath('error.code', 'idempotency_conflict');
    }

    /**
     * Requirement 3: Cross-branch invoice protection & 3-way match validation.
     * Cannot invoice a Goods Receipt belonging to another branch or another PO.
     * Cannot invoice the same Goods Receipt twice.
     */
    public function test_three_way_match_invoicing_validation(): void
    {
        $this->actingAs($this->dubaiUser);
        $dubaiHeaders = $this->headers($this->dubaiBranch->id);

        // Dubai PO & Receipt
        $poRes = $this->withHeaders($dubaiHeaders)->postJson('/api/erp/v1/purchasing/orders', [
            'supplier_id' => $this->supplier->id,
            'lines' => [
                [
                    'inventory_item_id' => $this->coffeeBeans->id,
                    'ordered_quantity' => 10.0,
                    'unit_cost_minor' => 7500,
                ],
            ],
        ]);
        $poId = $poRes->json('id');
        $poLineId = $poRes->json('lines.0.id');

        $grRes = $this->withHeaders(array_merge($dubaiHeaders, ['Idempotency-Key' => 'gr-3way-' . Str::uuid()]))
            ->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", [
                'delivery_note_ref' => 'DN-3WAY-01',
                'lines' => [
                    [
                        'po_line_id' => $poLineId,
                        'quantity_received' => 10.0,
                    ],
                ],
            ]);
        $grId = $grRes->json('id');

        // 1. Abu Dhabi staff attempts to invoice Dubai receipt -> 403 Forbidden
        $this->actingAs($this->auhUser);
        $auhHeaders = $this->headers($this->auhBranch->id);
        $crossRes = $this->withHeaders($auhHeaders)->postJson("/api/erp/v1/purchasing/orders/{$poId}/invoice", [
            'goods_receipt_id' => $grId,
            'invoice_number' => 'INV-CROSS-001',
            'invoice_date' => now()->toDateString(),
            'tax_minor' => 3750,
        ]);
        $crossRes->assertStatus(403);

        // 2. Dubai staff invoices legitimate receipt -> 201 Created
        $this->actingAs($this->dubaiUser);
        $invRes1 = $this->withHeaders($dubaiHeaders)->postJson("/api/erp/v1/purchasing/orders/{$poId}/invoice", [
            'goods_receipt_id' => $grId,
            'invoice_number' => 'INV-LEGIT-001',
            'invoice_date' => now()->toDateString(),
            'tax_minor' => 3750,
        ]);
        $invRes1->assertStatus(201);

        // 3. Attempting to invoice the exact same Goods Receipt a second time -> 400 Bad Request
        $invRes2 = $this->withHeaders($dubaiHeaders)->postJson("/api/erp/v1/purchasing/orders/{$poId}/invoice", [
            'goods_receipt_id' => $grId,
            'invoice_number' => 'INV-DUPLICATE-002',
            'invoice_date' => now()->toDateString(),
            'tax_minor' => 3750,
        ]);
        $invRes2->assertStatus(400);
        $invRes2->assertJsonPath('error.code', 'goods_receipt_already_invoiced');
    }

    /**
     * Requirement 4: Strict cross-branch authorization.
     * Abu Dhabi staff cannot view or mutate Dubai data across POS, Inventory, and Accounting.
     */
    public function test_strict_cross_branch_access_denials(): void
    {
        $this->actingAs($this->auhUser);

        // Abu Dhabi user sending header for Dubai branch -> 403 Forbidden
        $unauthHeaders = $this->headers($this->dubaiBranch->id);

        $this->withHeaders($unauthHeaders)->getJson('/api/erp/v1/pos/catalog')->assertStatus(403);
        $this->withHeaders($unauthHeaders)->getJson('/api/erp/v1/inventory/items')->assertStatus(403);
        $this->withHeaders($unauthHeaders)->getJson('/api/erp/v1/accounting/journals')->assertStatus(403);
        $this->withHeaders($unauthHeaders)->getJson('/api/erp/v1/kitchen/tickets')->assertStatus(403);
    }

    /**
     * Requirement 5: Supplier details scoped to authorized branch.
     * General contact card is visible, but operational POs are strictly filtered.
     */
    public function test_supplier_show_scoped_to_authorized_branch(): void
    {
        // 1. Dubai staff creates PO for shared supplier
        $this->actingAs($this->dubaiUser);
        $dubaiHeaders = $this->headers($this->dubaiBranch->id);

        $poRes = $this->withHeaders($dubaiHeaders)->postJson('/api/erp/v1/purchasing/orders', [
            'supplier_id' => $this->supplier->id,
            'lines' => [
                [
                    'inventory_item_id' => $this->coffeeBeans->id,
                    'ordered_quantity' => 15.0,
                    'unit_cost_minor' => 7500,
                ],
            ],
        ]);
        $poRes->assertStatus(201);
        $poId = $poRes->json('id');

        // Dubai staff viewing supplier sees Dubai PO
        $supDxbRes = $this->withHeaders($dubaiHeaders)->getJson("/api/erp/v1/suppliers/{$this->supplier->id}");
        $supDxbRes->assertStatus(200);
        $this->assertNotEmpty($supDxbRes->json('purchase_orders'));
        $this->assertEquals($poId, $supDxbRes->json('purchase_orders.0.id'));

        // 2. Abu Dhabi staff viewing the same shared supplier sees 0 Dubai POs
        $this->actingAs($this->auhUser);
        $auhHeaders = $this->headers($this->auhBranch->id);

        $supAuhRes = $this->withHeaders($auhHeaders)->getJson("/api/erp/v1/suppliers/{$this->supplier->id}");
        $supAuhRes->assertStatus(200);
        $this->assertEquals($this->supplier->name, $supAuhRes->json('name')); // General info available
        $this->assertEmpty($supAuhRes->json('purchase_orders')); // Operational POs filtered out!
    }

    /**
     * Requirement 6: Accounting branch and period scoping.
     * Journals, account balances, and VAT report strictly filter to branch and period.
     */
    public function test_accounting_period_and_branch_scoping(): void
    {
        $this->actingAs($this->dubaiUser);
        $dubaiHeaders = $this->headers($this->dubaiBranch->id);

        // Dubai PO, Receipt, and Invoice for period 2026-11
        $poRes = $this->withHeaders($dubaiHeaders)->postJson('/api/erp/v1/purchasing/orders', [
            'supplier_id' => $this->supplier->id,
            'lines' => [
                [
                    'inventory_item_id' => $this->coffeeBeans->id,
                    'ordered_quantity' => 10.0,
                    'unit_cost_minor' => 8000,
                ],
            ],
        ]);
        $poId = $poRes->json('id');
        $poLineId = $poRes->json('lines.0.id');

        $grRes = $this->withHeaders(array_merge($dubaiHeaders, ['Idempotency-Key' => 'gr-acct-' . Str::uuid()]))
            ->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", [
                'delivery_note_ref' => 'DN-ACCT-01',
                'lines' => [
                    [
                        'po_line_id' => $poLineId,
                        'quantity_received' => 10.0,
                    ],
                ],
            ]);
        $grId = $grRes->json('id');

        $invRes = $this->withHeaders($dubaiHeaders)->postJson("/api/erp/v1/purchasing/orders/{$poId}/invoice", [
            'goods_receipt_id' => $grId,
            'invoice_number' => 'INV-ACCT-2026-11',
            'invoice_date' => '2026-11-27',
            'tax_minor' => 4000,
        ]);
        $invRes->assertStatus(201);

        // 1. Query journals with period=2026-11 -> finds journal
        $jRes1 = $this->withHeaders($dubaiHeaders)->getJson('/api/erp/v1/accounting/journals?period=2026-11');
        $jRes1->assertStatus(200);
        $this->assertNotEmpty($jRes1->json('journals'));

        // 2. Query journals with period=2026-12 -> finds 0 journals
        $jRes2 = $this->withHeaders($dubaiHeaders)->getJson('/api/erp/v1/accounting/journals?period=2026-12');
        $jRes2->assertStatus(200);
        $this->assertEmpty($jRes2->json('journals'));

        // 3. Query accounts for Dubai -> Raw Inventory (1050) has balance
        $accDxbRes = $this->withHeaders($dubaiHeaders)->getJson('/api/erp/v1/accounting/accounts?period=2026-11');
        $accDxbRes->assertStatus(200);
        $rawInv = collect($accDxbRes->json('accounts'))->firstWhere('code', '1050');
        $this->assertEquals(84000, $rawInv['balance_minor']);

        // 4. Query accounts for Abu Dhabi -> Raw Inventory has 0 balance!
        $this->actingAs($this->auhUser);
        $auhHeaders = $this->headers($this->auhBranch->id);
        $accAuhRes = $this->withHeaders($auhHeaders)->getJson('/api/erp/v1/accounting/accounts?period=2026-11');
        $accAuhRes->assertStatus(200);
        $rawInvAuh = collect($accAuhRes->json('accounts'))->firstWhere('code', '1050');
        $this->assertEquals(0, $rawInvAuh['balance_minor']);
    }

    /**
     * Requirement 7: Goods receipt requires Idempotency-Key.
     */
    public function test_goods_receipt_requires_idempotency_key(): void
    {
        $this->actingAs($this->dubaiUser);
        $dubaiHeaders = $this->headers($this->dubaiBranch->id);

        $poRes = $this->withHeaders($dubaiHeaders)->postJson('/api/erp/v1/purchasing/orders', [
            'supplier_id' => $this->supplier->id,
            'lines' => [
                [
                    'inventory_item_id' => $this->coffeeBeans->id,
                    'ordered_quantity' => 5.0,
                    'unit_cost_minor' => 7500,
                ],
            ],
        ]);
        $poId = $poRes->json('id');
        $poLineId = $poRes->json('lines.0.id');

        // Missing Idempotency-Key header -> 400 Bad Request
        $res = $this->withHeaders($dubaiHeaders)->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", [
            'delivery_note_ref' => 'DN-NO-KEY',
            'lines' => [
                [
                    'po_line_id' => $poLineId,
                    'quantity_received' => 5.0,
                ],
            ],
        ]);

        $res->assertStatus(400);
        $res->assertJsonPath('error.code', 'missing_idempotency_key');
    }

    /**
     * Requirement 8: POS Checkout idempotency replay & conflict protection.
     * Prevents double sales, duplicate tickets, duplicate recipe deductions, and duplicate journals.
     */
    public function test_pos_checkout_idempotency_replay_and_conflict(): void
    {
        $this->actingAs($this->dubaiUser);
        $dubaiHeaders = $this->headers($this->dubaiBranch->id);

        // Seed stock for beans
        $dxbBalance = ErpInventoryBalance::where('branch_id', $this->dubaiBranch->id)
            ->where('inventory_item_id', $this->coffeeBeans->id)
            ->first();
        $dxbBalance->update(['current_quantity' => 10.0]);
        $this->coffeeBeans->update(['current_quantity' => 10.0]);

        // Create product with recipe
        $station = ErpStation::create([
            'tenant_id' => $this->tenant->id,
            'branch_id' => $this->dubaiBranch->id,
            'code' => 'HOT_BAR',
            'name_en' => 'Hot Bar',
            'name_ar' => 'البار الساخن',
            'is_active' => true,
        ]);

        $prodRes = $this->withHeaders($dubaiHeaders)->postJson('/api/erp/v1/products', [
            'sku' => 'V60-ETH',
            'name_en' => 'V60 Ethiopian Drip',
            'name_ar' => 'قهوة مقطرة إثيوبية',
            'category' => 'Filter Coffee',
            'station_code' => 'HOT_BAR',
            'variants' => [
                ['name_en' => 'Single Cup', 'name_ar' => 'كوب واحد', 'price_minor' => 2500, 'is_default' => true],
            ],
            'recipe_lines' => [
                ['inventory_item_id' => $this->coffeeBeans->id, 'quantity' => 0.020, 'unit' => 'kg'],
            ],
        ]);
        $prodRes->assertStatus(201);
        $productId = $prodRes->json('id');
        $variantId = $prodRes->json('variants.0.id');

        $idemKey = 'pos-race-' . Str::uuid();
        $payload = [
            'guest_name' => 'Sara Al Harthi',
            'order_type' => 'dine_in',
            'items' => [
                ['product_id' => $productId, 'variant_id' => $variantId, 'quantity' => 1],
            ],
        ];

        // 1. First checkout attempt -> 201 Created
        $res1 = $this->withHeaders(array_merge($dubaiHeaders, ['Idempotency-Key' => $idemKey]))
            ->postJson('/api/erp/v1/pos/checkout', $payload);
        $res1->assertStatus(201);
        $orderId = $res1->json('id');

        // Stock balance decreased to 10 - 0.020 = 9.980
        $this->assertEquals(9.980, (float) $dxbBalance->fresh()->current_quantity);

        // 2. Replaying identical checkout with same Idempotency-Key -> 200 OK (cached response)
        $res2 = $this->withHeaders(array_merge($dubaiHeaders, ['Idempotency-Key' => $idemKey]))
            ->postJson('/api/erp/v1/pos/checkout', $payload);
        $res2->assertStatus(200);
        $this->assertEquals($orderId, $res2->json('id'));

        // Assert no duplicate stock deduction happened (still 9.980)
        $this->assertEquals(9.980, (float) $dxbBalance->fresh()->current_quantity);

        // 3. Submitting same Idempotency-Key with altered payload (quantity 3) -> 409 Conflict
        $tamperedPayload = [
            'guest_name' => 'Sara Al Harthi',
            'order_type' => 'dine_in',
            'items' => [
                ['product_id' => $productId, 'variant_id' => $variantId, 'quantity' => 3],
            ],
        ];
        $res3 = $this->withHeaders(array_merge($dubaiHeaders, ['Idempotency-Key' => $idemKey]))
            ->postJson('/api/erp/v1/pos/checkout', $tamperedPayload);
        $res3->assertStatus(409);
        $res3->assertJsonPath('error.code', 'idempotency_conflict');
    }
}
