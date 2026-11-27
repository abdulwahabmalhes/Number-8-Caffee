<?php

namespace Tests\Feature\ERP;

use App\ERP\Infrastructure\Persistence\Models\ErpAccount;
use App\ERP\Infrastructure\Persistence\Models\ErpBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpCustomer;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryBalance;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryItem;
use App\ERP\Infrastructure\Persistence\Models\ErpJournal;
use App\ERP\Infrastructure\Persistence\Models\ErpKitchenTicket;
use App\ERP\Infrastructure\Persistence\Models\ErpOrder;
use App\ERP\Infrastructure\Persistence\Models\ErpProduct;
use App\ERP\Infrastructure\Persistence\Models\ErpPurchaseOrder;
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
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OperationalCycleAcceptanceTest extends TestCase
{
    use RefreshDatabase;

    private ErpTenant $tenant;
    private ErpBranch $dubaiBranch;
    private ErpBranch $auhBranch;
    private User $dubaiManager;
    private User $auhManager;
    private ErpInventoryItem $beansItem;
    private ErpInventoryItem $milkItem;

    protected function setUp(): void
    {
        parent::setUp();

        config(['erp.enabled' => true]);

        // 1. Create Tenant
        $this->tenant = ErpTenant::create([
            'slug' => 'number-eight',
            'name' => 'NUMBER EIGHT',
            'status' => 'active',
            'settings' => ['currency' => 'AED', 'vat_rate' => 0.05],
        ]);

        // 2. Create Branches
        $this->dubaiBranch = ErpBranch::create([
            'tenant_id' => $this->tenant->id,
            'name' => 'Dubai Flagship',
            'code' => 'DXB-01',
            'is_active' => true,
        ]);

        $this->auhBranch = ErpBranch::create([
            'tenant_id' => $this->tenant->id,
            'name' => 'Abu Dhabi Branch',
            'code' => 'AUH-01',
            'is_active' => true,
        ]);

        // 3. Create Stations
        ErpStation::create([
            'tenant_id' => $this->tenant->id,
            'branch_id' => $this->dubaiBranch->id,
            'code' => 'HOT_BAR',
            'name_en' => 'Hot Bar',
            'name_ar' => 'البار الساخن',
            'is_active' => true,
        ]);

        ErpStation::create([
            'tenant_id' => $this->tenant->id,
            'branch_id' => $this->auhBranch->id,
            'code' => 'HOT_BAR',
            'name_en' => 'Hot Bar',
            'name_ar' => 'البار الساخن',
            'is_active' => true,
        ]);

        // 4. Create Standard Accounts Chart
        $accounts = [
            ['code' => '1010', 'name_en' => 'Cash on Hand', 'name_ar' => 'النقد في الصندوق', 'type' => 'asset'],
            ['code' => '1050', 'name_en' => 'Raw Inventory', 'name_ar' => 'مخزون المواد الأولية', 'type' => 'asset'],
            ['code' => '2010', 'name_en' => 'Accounts Payable - Suppliers', 'name_ar' => 'ذمم دائنة - موردين', 'type' => 'liability'],
            ['code' => '2020', 'name_en' => 'VAT Output Tax (5%)', 'name_ar' => 'ضريبة القيمة المضافة المحصلة', 'type' => 'liability'],
            ['code' => '4010', 'name_en' => 'Beverage Revenue', 'name_ar' => 'إيرادات المشروبات', 'type' => 'revenue'],
        ];

        foreach ($accounts as $acc) {
            ErpAccount::create([
                'tenant_id' => $this->tenant->id,
                'code' => $acc['code'],
                'name_en' => $acc['name_en'],
                'name_ar' => $acc['name_ar'],
                'type' => $acc['type'],
                'currency' => 'AED',
            ]);
        }

        // 5. Create Standard Inventory Items
        $this->beansItem = ErpInventoryItem::create([
            'tenant_id' => $this->tenant->id,
            'sku' => 'COF-BEANS',
            'name_en' => 'Specialty Espresso Coffee Beans',
            'name_ar' => 'بن قهوة إسبريسو مختصة',
            'unit' => 'kg',
            'unit_cost_minor' => 8000, // 80.00 AED/kg
            'current_quantity' => 0,
            'reorder_threshold' => 10,
            'is_active' => true,
        ]);

        $this->milkItem = ErpInventoryItem::create([
            'tenant_id' => $this->tenant->id,
            'sku' => 'MILK-FRESH',
            'name_en' => 'Fresh Barista Milk',
            'name_ar' => 'حليب طازج للباريستا',
            'unit' => 'L',
            'unit_cost_minor' => 600, // 6.00 AED/L
            'current_quantity' => 0,
            'reorder_threshold' => 20,
            'is_active' => true,
        ]);

        foreach ([$this->dubaiBranch->id, $this->auhBranch->id] as $bId) {
            ErpInventoryBalance::create([
                'tenant_id' => $this->tenant->id,
                'branch_id' => $bId,
                'inventory_item_id' => $this->beansItem->id,
                'current_quantity' => 0,
                'reorder_threshold' => 10,
            ]);
            ErpInventoryBalance::create([
                'tenant_id' => $this->tenant->id,
                'branch_id' => $bId,
                'inventory_item_id' => $this->milkItem->id,
                'current_quantity' => 0,
                'reorder_threshold' => 20,
            ]);
        }

        // 6. Create Staff: Dubai Manager & Abu Dhabi Manager
        $this->dubaiManager = User::factory()->create([
            'name' => 'Mariam Al Mansoori',
            'email' => 'mariam@no8.ae',
        ]);

        ErpTenantUser::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->dubaiManager->id,
            'role' => 'Branch Manager',
            'is_tenant_admin' => false,
            'is_active' => true,
        ]);

        ErpUserBranch::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->dubaiManager->id,
            'branch_id' => $this->dubaiBranch->id,
            'is_default' => true,
        ]);

        $this->auhManager = User::factory()->create([
            'name' => 'Khalid Al Shamsi',
            'email' => 'khalid@no8.ae',
        ]);

        ErpTenantUser::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->auhManager->id,
            'role' => 'Branch Manager',
            'is_tenant_admin' => false,
            'is_active' => true,
        ]);

        ErpUserBranch::create([
            'tenant_id' => $this->tenant->id,
            'user_id' => $this->auhManager->id,
            'branch_id' => $this->auhBranch->id,
            'is_default' => true,
        ]);

        // Permissions for both managers
        $permissions = [
            'dashboard.view',
            'pos.use',
            'kitchen.view',
            'inventory.view',
            'inventory.adjust',
            'purchasing.approve',
            'accounting.view',
            'accounting.post'
        ];

        foreach ([$this->dubaiManager->id, $this->auhManager->id] as $uid) {
            foreach ($permissions as $perm) {
                ErpUserPermission::create([
                    'tenant_id' => $this->tenant->id,
                    'user_id' => $uid,
                    'permission' => $perm,
                ]);
            }
        }
    }

    private function actingAsDubaiStaff(): void
    {
        $this->actingAs($this->dubaiManager);
    }

    private function actingAsAuhStaff(): void
    {
        $this->actingAs($this->auhManager);
    }

    private function defaultHeaders(int $branchId): array
    {
        return [
            'X-Tenant-Slug' => 'number-eight',
            'X-Branch-ID' => (string) $branchId,
        ];
    }

    /**
     * Requirement 1: Dubai manager creates supplier, product "Latte" with 2 variants,
     * recipe with beans & milk at HOT_BAR, and a customer.
     */
    public function test_step_1_create_supplier_product_with_recipe_and_customer(): array
    {
        $this->actingAsDubaiStaff();
        $headers = $this->defaultHeaders($this->dubaiBranch->id);

        // 1. Create Supplier
        $supplierRes = $this->withHeaders($headers)->postJson('/api/erp/v1/suppliers', [
            'name' => 'Al Ameed Coffee Trading',
            'contact_name' => 'Rashid Al Nuaimi',
            'phone' => '+971501234567',
            'email' => 'orders@alameedcoffee.ae',
            'tax_number' => 'TRN-100234567800003',
            'address' => 'Al Quoz Industrial Area 3, Dubai',
        ]);
        $supplierRes->assertStatus(201);
        $supplierId = $supplierRes->json('id');
        $this->assertDatabaseHas('erp_suppliers', ['id' => $supplierId, 'name' => 'Al Ameed Coffee Trading']);

        // 2. Create Product "Latte" with 2 variants & recipe at HOT_BAR
        $productRes = $this->withHeaders($headers)->postJson('/api/erp/v1/products', [
            'sku' => 'LATTE-STD',
            'name_en' => 'Café Latte',
            'name_ar' => 'لاتيه كافيه',
            'category' => 'Hot Coffee',
            'station_code' => 'HOT_BAR',
            'variants' => [
                [
                    'name_en' => 'Regular 8oz',
                    'name_ar' => 'عادي 8 أونصة',
                    'price_minor' => 2000, // 20.00 AED
                    'is_default' => true,
                ],
                [
                    'name_en' => 'Large 12oz',
                    'name_ar' => 'كبير 12 أونصة',
                    'price_minor' => 2400, // 24.00 AED
                    'is_default' => false,
                ],
            ],
            'recipe_lines' => [
                [
                    'inventory_item_id' => $this->beansItem->id,
                    'quantity' => 0.018, // 18g espresso beans
                    'unit' => 'kg',
                ],
                [
                    'inventory_item_id' => $this->milkItem->id,
                    'quantity' => 0.200, // 200ml milk
                    'unit' => 'L',
                ],
            ],
        ]);
        $productRes->assertStatus(201);
        $productId = $productRes->json('id');
        $regularVariantId = $productRes->json('variants.0.id');

        $this->assertDatabaseHas('erp_products', ['id' => $productId, 'sku' => 'LATTE-STD']);
        $this->assertDatabaseHas('erp_recipes', ['product_id' => $productId]);

        // 3. Create Customer
        $customerRes = $this->withHeaders($headers)->postJson('/api/erp/v1/customers', [
            'name' => 'Sultan Al Qasimi',
            'phone' => '+971501112233',
            'email' => 'sultan@example.ae',
            'notes' => 'Prefers oat milk when available',
        ]);
        $customerRes->assertStatus(201);
        $customerId = $customerRes->json('id');
        $this->assertDatabaseHas('erp_customers', ['id' => $customerId, 'name' => 'Sultan Al Qasimi']);

        return [
            'supplier_id' => $supplierId,
            'product_id' => $productId,
            'regular_variant_id' => $regularVariantId,
            'customer_id' => $customerId,
        ];
    }

    /**
     * Requirement 2: Purchase order, partial receipt, remaining receipt, verify actual inventory,
     * over-receiving prevention, and balanced supplier invoice posting.
     */
    public function test_step_2_purchasing_cycle_partial_and_full_receipt_and_invoice(): array
    {
        $setup = $this->test_step_1_create_supplier_product_with_recipe_and_customer();
        $this->actingAsDubaiStaff();
        $headers = $this->defaultHeaders($this->dubaiBranch->id);

        // 1. Create PO: 50 kg beans @ 8000 fils, 100 L milk @ 600 fils
        $poRes = $this->withHeaders($headers)->postJson('/api/erp/v1/purchasing/orders', [
            'supplier_id' => $setup['supplier_id'],
            'notes' => 'Weekly flagship inventory replenishment',
            'lines' => [
                [
                    'inventory_item_id' => $this->beansItem->id,
                    'ordered_quantity' => 50,
                    'unit_cost_minor' => 8000,
                ],
                [
                    'inventory_item_id' => $this->milkItem->id,
                    'ordered_quantity' => 100,
                    'unit_cost_minor' => 600,
                ],
            ],
        ]);
        $poRes->assertStatus(201);
        $poId = $poRes->json('id');
        // Total should be: (50 * 8000) + (100 * 600) = 400,000 + 60,000 = 460,000 fils
        $this->assertEquals(460000, $poRes->json('total_minor'));

        $beansPoLineId = collect($poRes->json('lines'))->firstWhere('inventory_item_id', $this->beansItem->id)['id'];
        $milkPoLineId = collect($poRes->json('lines'))->firstWhere('inventory_item_id', $this->milkItem->id)['id'];

        // 2. Partial Receipt: 20 kg beans, 40 L milk
        $receipt1Res = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => 'gr-part1-' . Str::uuid()]))
            ->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", [
                'received_by' => 'Mariam Al Mansoori',
                'notes' => 'First partial delivery from morning shipment',
                'lines' => [
                    [
                        'po_line_id' => $beansPoLineId,
                        'quantity_received' => 20,
                    ],
                    [
                        'po_line_id' => $milkPoLineId,
                        'quantity_received' => 40,
                    ],
                ],
            ]);
        $receipt1Res->assertStatus(201);
        $gr1Id = $receipt1Res->json('id');

        // Check intermediate stock
        $this->beansItem->refresh();
        $this->milkItem->refresh();
        $this->assertEquals(20.0, (float) $this->beansItem->current_quantity);
        $this->assertEquals(40.0, (float) $this->milkItem->current_quantity);

        // 3. Test Over-Receiving Prevention: Attempt to receive 50 kg beans (remaining is 30 kg)
        $overReceiveRes = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => 'gr-over-' . Str::uuid()]))
            ->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", [
                'received_by' => 'Mariam Al Mansoori',
                'lines' => [
                    [
                        'po_line_id' => $beansPoLineId,
                        'quantity_received' => 50, // 20 + 50 = 70 > 50 ordered
                    ],
                ],
            ]);
        $overReceiveRes->assertStatus(400);

        // 4. Remaining Receipt: 30 kg beans, 60 L milk
        $receipt2Res = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => 'gr-part2-' . Str::uuid()]))
            ->postJson("/api/erp/v1/purchasing/orders/{$poId}/receive", [
                'received_by' => 'Mariam Al Mansoori',
                'notes' => 'Afternoon final shipment',
                'lines' => [
                    [
                        'po_line_id' => $beansPoLineId,
                        'quantity_received' => 30,
                    ],
                    [
                        'po_line_id' => $milkPoLineId,
                        'quantity_received' => 60,
                    ],
                ],
            ]);
        $receipt2Res->assertStatus(201);
        $gr2Id = $receipt2Res->json('id');

        // Verify final inventory balances
        $this->beansItem->refresh();
        $this->milkItem->refresh();
        $this->assertEquals(50.0, (float) $this->beansItem->current_quantity);
        $this->assertEquals(100.0, (float) $this->milkItem->current_quantity);

        // Verify PO status is 'received'
        $po = ErpPurchaseOrder::find($poId);
        $this->assertEquals('received', $po->status);

        // 5. Post Supplier Invoice for Goods Receipt 1 & 2
        // Subtotal for GR1: (20 * 8000) + (40 * 600) = 160000 + 24000 = 184000 fils
        $invRes = $this->withHeaders($headers)->postJson("/api/erp/v1/purchasing/orders/{$poId}/invoice", [
            'goods_receipt_id' => $gr1Id,
            'invoice_number' => 'INV-AMEED-2026-001',
            'invoice_date' => '2026-11-26',
        ]);
        $invRes->assertStatus(201);
        $journalId = $invRes->json('posted_journal_id');
        $this->assertNotNull($journalId);

        // Verify Journal Debits = Credits
        $journal = ErpJournal::with('lines')->find($journalId);
        $this->assertNotNull($journal);
        $totalDebit = $journal->lines->sum('debit_minor');
        $totalCredit = $journal->lines->sum('credit_minor');
        $this->assertEquals($totalDebit, $totalCredit);
        $this->assertEquals(184000, $totalDebit);

        return array_merge($setup, [
            'po_id' => $poId,
        ]);
    }

    /**
     * Requirement 3: Cash sales to customer and guest, minor units quote, 5% VAT,
     * station ticket generation, recipe stock deduction, balanced journals.
     */
    public function test_step_3_cash_sales_customer_and_guest_with_recipe_deduction_and_journals(): array
    {
        $setup = $this->test_step_2_purchasing_cycle_partial_and_full_receipt_and_invoice();
        $this->actingAsDubaiStaff();
        $headers = $this->defaultHeaders($this->dubaiBranch->id);

        $initialBeans = (float) $this->beansItem->fresh()->current_quantity;
        $initialMilk = (float) $this->milkItem->fresh()->current_quantity;

        // 1. Sale to Customer (1 Regular Latte @ 2000 fils + 5% VAT = 2100 fils)
        $quoteRes = $this->withHeaders($headers)->postJson('/api/erp/v1/pos/quote', [
            'items' => [
                [
                    'product_id' => $setup['product_id'],
                    'variant_id' => $setup['regular_variant_id'],
                    'quantity' => 1,
                ],
            ],
        ]);
        $quoteRes->assertStatus(200);
        $this->assertEquals(2000, $quoteRes->json('subtotal_minor'));
        $this->assertEquals(100, $quoteRes->json('tax_minor')); // 5% of 2000 = 100 fils
        $this->assertEquals(2100, $quoteRes->json('total_minor'));

        $idempotencyKey1 = 'order-sale-' . Str::uuid();
        $sale1Res = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => $idempotencyKey1]))
            ->postJson('/api/erp/v1/pos/checkout', [
                'customer_id' => $setup['customer_id'],
                'order_type' => 'dine_in',
                'notes' => 'Extra hot please',
                'items' => [
                    [
                        'product_id' => $setup['product_id'],
                        'variant_id' => $setup['regular_variant_id'],
                        'quantity' => 1,
                    ],
                ],
            ]);
        $sale1Res->assertStatus(201);
        $order1Id = $sale1Res->json('id');
        $this->assertEquals(2100, $sale1Res->json('total_minor'));
        $this->assertEquals($setup['customer_id'], $sale1Res->json('customer_id'));

        // Verify Customer loyalty points incremented
        $customer = ErpCustomer::find($setup['customer_id']);
        $this->assertGreaterThan(0, $customer->loyalty_points);

        // Verify Kitchen Ticket created for HOT_BAR
        $ticket1 = ErpKitchenTicket::where('order_id', $order1Id)->first();
        $this->assertNotNull($ticket1);
        $this->assertEquals('HOT_BAR', $ticket1->station_code);
        $this->assertEquals('new', $ticket1->status);

        // Verify Recipe deduction: Beans (-0.018 kg), Milk (-0.200 L)
        $this->assertEquals($initialBeans - 0.018, (float) $this->beansItem->fresh()->current_quantity);
        $this->assertEquals($initialMilk - 0.200, (float) $this->milkItem->fresh()->current_quantity);

        // Verify balanced journal for sale 1 (Debit Cash 2100, Credit Revenue 2000, Credit VAT 100)
        $journal1 = ErpJournal::where('branch_id', $this->dubaiBranch->id)
            ->where('description', 'like', "%Order {$sale1Res->json('order_number')}%")
            ->with('lines')
            ->first();
        $this->assertNotNull($journal1);
        $debit1 = $journal1->lines->sum('debit_minor');
        $credit1 = $journal1->lines->sum('credit_minor');
        $this->assertEquals($debit1, $credit1);
        $this->assertEquals(2100, $debit1);

        // 2. Separate Sale to Guest (2 Regular Lattes = 4000 subtotal + 200 tax = 4200 fils)
        $idempotencyKey2 = 'order-sale-' . Str::uuid();
        $sale2Res = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => $idempotencyKey2]))
            ->postJson('/api/erp/v1/pos/checkout', [
                'guest_name' => 'Walk-in Guest',
                'order_type' => 'takeaway',
                'items' => [
                    [
                        'product_id' => $setup['product_id'],
                        'variant_id' => $setup['regular_variant_id'],
                        'quantity' => 2,
                    ],
                ],
            ]);
        $sale2Res->assertStatus(201);
        $order2Id = $sale2Res->json('id');
        $this->assertEquals(4200, $sale2Res->json('total_minor'));
        $this->assertNull($sale2Res->json('customer_id'));
        $this->assertEquals('Walk-in Guest', $sale2Res->json('guest_name'));

        // Recipe stock deducted again: Beans (-0.036 kg), Milk (-0.400 L)
        $this->assertEqualsWithDelta($initialBeans - 0.054, (float) $this->beansItem->fresh()->current_quantity, 0.0001);
        $this->assertEqualsWithDelta($initialMilk - 0.600, (float) $this->milkItem->fresh()->current_quantity, 0.0001);

        return array_merge($setup, [
            'ticket_id' => $ticket1->id,
            'idempotency_key_1' => $idempotencyKey1,
            'sale1_payload' => [
                'customer_id' => $setup['customer_id'],
                'order_type' => 'dine_in',
                'notes' => 'Extra hot please',
                'items' => [
                    [
                        'product_id' => $setup['product_id'],
                        'variant_id' => $setup['regular_variant_id'],
                        'quantity' => 1,
                    ],
                ],
            ],
        ]);
    }

    /**
     * Requirement 4: Kitchen display status transitions (new -> preparing -> ready -> completed)
     * and persistence across fetches.
     */
    public function test_step_4_kitchen_display_status_transitions_and_persistence(): void
    {
        $setup = $this->test_step_3_cash_sales_customer_and_guest_with_recipe_deduction_and_journals();
        $this->actingAsDubaiStaff();
        $headers = $this->defaultHeaders($this->dubaiBranch->id);
        $ticketId = $setup['ticket_id'];

        // 1. Fetch tickets from KDS
        $kdsRes = $this->withHeaders($headers)->getJson('/api/erp/v1/kitchen/tickets?station=HOT_BAR');
        $kdsRes->assertStatus(200);
        $this->assertTrue(collect($kdsRes->json('tickets'))->contains('id', $ticketId));

        // 2. Transition: new -> preparing
        $prepRes = $this->withHeaders($headers)->postJson("/api/erp/v1/kitchen/tickets/{$ticketId}/status", [
            'status' => 'preparing',
        ]);
        $prepRes->assertStatus(200);
        $this->assertEquals('preparing', $prepRes->json('status'));
        $this->assertNotNull($prepRes->json('started_at'));

        // 3. Transition: preparing -> ready
        $readyRes = $this->withHeaders($headers)->postJson("/api/erp/v1/kitchen/tickets/{$ticketId}/status", [
            'status' => 'ready',
        ]);
        $readyRes->assertStatus(200);
        $this->assertEquals('ready', $readyRes->json('status'));
        $this->assertNotNull($readyRes->json('ready_at'));

        // 4. Transition: ready -> completed
        $doneRes = $this->withHeaders($headers)->postJson("/api/erp/v1/kitchen/tickets/{$ticketId}/status", [
            'status' => 'completed',
        ]);
        $doneRes->assertStatus(200);
        $this->assertEquals('completed', $doneRes->json('status'));
        $this->assertNotNull($doneRes->json('completed_at'));

        // 5. Verify persistence on reload: active tickets query no longer includes completed ticket
        $activeRes = $this->withHeaders($headers)->getJson('/api/erp/v1/kitchen/tickets?station=HOT_BAR');
        $activeRes->assertStatus(200);
        $this->assertFalse(collect($activeRes->json('tickets'))->contains('id', $ticketId));

        // Explicit status filter finds it
        $completedRes = $this->withHeaders($headers)->getJson('/api/erp/v1/kitchen/tickets?status=completed');
        $completedRes->assertStatus(200);
        $this->assertTrue(collect($completedRes->json('tickets'))->contains('id', $ticketId));
    }

    /**
     * Requirement 5: Branch isolation (Abu Dhabi cannot see or mutate Dubai)
     * and Idempotency key duplicate protection.
     */
    public function test_step_5_branch_isolation_and_idempotency_duplicate_protection(): void
    {
        $setup = $this->test_step_3_cash_sales_customer_and_guest_with_recipe_deduction_and_journals();

        // 1. Branch Isolation: Abu Dhabi manager attempts to access Dubai branch (DXB-01) -> 403 Forbidden
        $this->actingAsAuhStaff();
        $unauthBranchHeaders = $this->defaultHeaders($this->dubaiBranch->id);

        $res = $this->withHeaders($unauthBranchHeaders)->getJson('/api/erp/v1/kitchen/tickets');
        $res->assertStatus(403);

        // Abu Dhabi querying their own branch sees 0 Dubai tickets
        $auhHeaders = $this->defaultHeaders($this->auhBranch->id);
        $auhTicketsRes = $this->withHeaders($auhHeaders)->getJson('/api/erp/v1/kitchen/tickets');
        $auhTicketsRes->assertStatus(200);
        $this->assertEmpty($auhTicketsRes->json('tickets'));

        // 2. Idempotency Key Replay: Resubmitting identical checkout returns cached response and does NOT re-deduct or create duplicate
        $this->actingAsDubaiStaff();
        $dubaiHeaders = $this->defaultHeaders($this->dubaiBranch->id);

        $beansBefore = (float) $this->beansItem->fresh()->current_quantity;
        $orderCountBefore = ErpOrder::count();
        $journalCountBefore = ErpJournal::count();

        $replayRes = $this->withHeaders(array_merge($dubaiHeaders, ['Idempotency-Key' => $setup['idempotency_key_1']]))
            ->postJson('/api/erp/v1/pos/checkout', $setup['sale1_payload']);
        $replayRes->assertSuccessful();

        // Verify counts and quantities remained identical
        $this->assertEquals($orderCountBefore, ErpOrder::count());
        $this->assertEquals($journalCountBefore, ErpJournal::count());
        $this->assertEquals($beansBefore, (float) $this->beansItem->fresh()->current_quantity);

        // 3. Idempotency Conflict: Resubmitting SAME key with ALTERED payload must be rejected with 409 Conflict
        $conflictRes = $this->withHeaders(array_merge($dubaiHeaders, ['Idempotency-Key' => $setup['idempotency_key_1']]))
            ->postJson('/api/erp/v1/pos/checkout', [
                'customer_id' => $setup['customer_id'],
                'items' => [
                    [
                        'product_id' => $setup['product_id'],
                        'variant_id' => $setup['regular_variant_id'],
                        'quantity' => 5, // altered quantity!
                    ],
                ],
            ]);
        $conflictRes->assertStatus(409);
        $conflictRes->assertJsonPath('error.code', 'idempotency_conflict');
    }

    /**
     * Requirement 6: Insufficient stock scenario and atomic transaction rollback.
     * Verifies that when inventory is insufficient, the checkout fails with 422
     * and leaves zero orphan orders, tickets, stock movements, or journals.
     */
    public function test_step_6_insufficient_stock_rejection_and_atomic_rollback(): void
    {
        $setup = $this->test_step_1_create_supplier_product_with_recipe_and_customer();
        $this->actingAsDubaiStaff();
        $headers = $this->defaultHeaders($this->dubaiBranch->id);

        // Note: Inventory current_quantity for beans and milk is currently 0.0
        $this->assertEquals(0.0, (float) $this->beansItem->current_quantity);

        $ordersBefore = ErpOrder::count();
        $ticketsBefore = ErpKitchenTicket::count();
        $movementsBefore = ErpStockMovement::count();
        $journalsBefore = ErpJournal::count();

        $failRes = $this->withHeaders(array_merge($headers, ['Idempotency-Key' => 'insufficient-stock-' . Str::uuid()]))
            ->postJson('/api/erp/v1/pos/checkout', [
                'guest_name' => 'Failed Order Guest',
                'items' => [
                    [
                        'product_id' => $setup['product_id'],
                        'variant_id' => $setup['regular_variant_id'],
                        'quantity' => 1,
                    ],
                ],
            ]);

        // Expect 422 Unprocessable Content due to InsufficientStockException
        $failRes->assertStatus(422);
        $failRes->assertJsonStructure(['error' => ['code', 'message']]);

        // Assert no orphan artifacts exist
        $this->assertEquals($ordersBefore, ErpOrder::count());
        $this->assertEquals($ticketsBefore, ErpKitchenTicket::count());
        $this->assertEquals($movementsBefore, ErpStockMovement::count());
        $this->assertEquals($journalsBefore, ErpJournal::count());
    }
}
