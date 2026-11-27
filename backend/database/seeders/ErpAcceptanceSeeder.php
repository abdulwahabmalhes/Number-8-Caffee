<?php

namespace Database\Seeders;

use App\ERP\Infrastructure\Persistence\Models\ErpAccount;
use App\ERP\Infrastructure\Persistence\Models\ErpBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryBalance;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryItem;
use App\ERP\Infrastructure\Persistence\Models\ErpStation;
use App\ERP\Infrastructure\Persistence\Models\ErpTenant;
use App\ERP\Infrastructure\Persistence\Models\ErpTenantUser;
use App\ERP\Infrastructure\Persistence\Models\ErpUserBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpUserPermission;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class ErpAcceptanceSeeder extends Seeder
{
    public function run(): void
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        // 1. Create Mock Demo Tenant
        $tenant = ErpTenant::firstOrCreate(
            ['slug' => 'number-eight'],
            [
                'name' => 'NUMBER EIGHT Restaurant Group',
                'status' => 'active',
                'settings' => ['currency' => 'AED', 'vat_rate' => 0.05],
            ]
        );

        // 2. Create Branches: Dubai Flagship & Abu Dhabi Branch
        $dubaiBranch = ErpBranch::firstOrCreate(
            ['tenant_id' => $tenant->id, 'code' => 'DXB-01'],
            ['name' => 'Dubai Flagship', 'is_active' => true]
        );

        $auhBranch = ErpBranch::firstOrCreate(
            ['tenant_id' => $tenant->id, 'code' => 'AUH-01'],
            ['name' => 'Abu Dhabi Branch', 'is_active' => true]
        );

        // 3. Create Stations
        ErpStation::firstOrCreate(
            ['tenant_id' => $tenant->id, 'branch_id' => $dubaiBranch->id, 'code' => 'HOT_BAR'],
            ['name_en' => 'Hot Espresso Bar', 'name_ar' => 'بار القهوة الساخنة', 'is_active' => true]
        );

        ErpStation::firstOrCreate(
            ['tenant_id' => $tenant->id, 'branch_id' => $auhBranch->id, 'code' => 'HOT_BAR'],
            ['name_en' => 'Hot Espresso Bar', 'name_ar' => 'بار القهوة الساخنة', 'is_active' => true]
        );

        // 4. Create Users: Dubai Manager & Abu Dhabi Manager & Tenant Admin
        $dubaiManager = User::firstOrCreate(
            ['email' => 'mariam@no8.ae'],
            ['name' => 'Mariam Al Mansoori', 'password' => Hash::make('Secret123!')]
        );

        $auhManager = User::firstOrCreate(
            ['email' => 'khalid@no8.ae'],
            ['name' => 'Khalid Al Shamsi', 'password' => Hash::make('Secret123!')]
        );

        $adminUser = User::firstOrCreate(
            ['email' => 'admin@no8.ae'],
            ['name' => 'Owner Administrator', 'password' => Hash::make('Secret123!')]
        );

        // 5. Tenant User Memberships
        ErpTenantUser::firstOrCreate(
            ['tenant_id' => $tenant->id, 'user_id' => $dubaiManager->id],
            ['role' => 'Branch Manager', 'is_tenant_admin' => false, 'is_active' => true]
        );

        ErpTenantUser::firstOrCreate(
            ['tenant_id' => $tenant->id, 'user_id' => $auhManager->id],
            ['role' => 'Branch Manager', 'is_tenant_admin' => false, 'is_active' => true]
        );

        ErpTenantUser::firstOrCreate(
            ['tenant_id' => $tenant->id, 'user_id' => $adminUser->id],
            ['role' => 'Tenant Administrator', 'is_tenant_admin' => true, 'is_active' => true]
        );

        // 6. Branch Assignments
        ErpUserBranch::firstOrCreate(
            ['tenant_id' => $tenant->id, 'user_id' => $dubaiManager->id, 'branch_id' => $dubaiBranch->id],
            ['is_default' => true]
        );

        ErpUserBranch::firstOrCreate(
            ['tenant_id' => $tenant->id, 'user_id' => $auhManager->id, 'branch_id' => $auhBranch->id],
            ['is_default' => true]
        );

        // 7. Permissions
        $standardPermissions = [
            'dashboard.view', 'pos.use', 'kitchen.view', 'inventory.view', 
            'inventory.adjust', 'purchasing.approve', 'accounting.view', 'accounting.post', 'reports.view'
        ];

        foreach ([$dubaiManager->id, $auhManager->id] as $uid) {
            foreach ($standardPermissions as $perm) {
                ErpUserPermission::firstOrCreate(
                    ['tenant_id' => $tenant->id, 'user_id' => $uid, 'permission' => $perm]
                );
            }
        }

        // 8. Accounts Chart
        $accounts = [
            ['code' => '1010', 'name_en' => 'Cash on Hand', 'name_ar' => 'النقد في الصندوق', 'type' => 'asset'],
            ['code' => '1020', 'name_en' => 'Card Receivables', 'name_ar' => 'مستحقات أجهزة الدفع', 'type' => 'asset'],
            ['code' => '1050', 'name_en' => 'Raw Inventory', 'name_ar' => 'مخزون المواد الأولية', 'type' => 'asset'],
            ['code' => '2010', 'name_en' => 'Accounts Payable - Suppliers', 'name_ar' => 'ذمم دائنة - موردين', 'type' => 'liability'],
            ['code' => '2020', 'name_en' => 'VAT Output Tax (5%)', 'name_ar' => 'ضريبة القيمة المضافة المحصلة', 'type' => 'liability'],
            ['code' => '4010', 'name_en' => 'Beverage Revenue', 'name_ar' => 'إيرادات المشروبات', 'type' => 'revenue'],
            ['code' => '5010', 'name_en' => 'COGS - Raw Materials', 'name_ar' => 'تكلفة البضاعة المباعة', 'type' => 'expense'],
            ['code' => '5030', 'name_en' => 'Inventory Waste & Spoilage', 'name_ar' => 'مصاريف تالف وهدر المخزون', 'type' => 'expense'],
        ];

        foreach ($accounts as $acc) {
            ErpAccount::firstOrCreate(
                ['tenant_id' => $tenant->id, 'code' => $acc['code']],
                ['name_en' => $acc['name_en'], 'name_ar' => $acc['name_ar'], 'type' => $acc['type'], 'currency' => 'AED']
            );
        }

        // 9. Standard Raw Inventory Items
        $items = [
            ['sku' => 'COF-BEANS', 'name_en' => 'Specialty Espresso Coffee Beans', 'name_ar' => 'بن قهوة إسبريسو مختصة', 'unit' => 'kg', 'unit_cost_minor' => 8000, 'reorder_threshold' => 10],
            ['sku' => 'MILK-FRESH', 'name_en' => 'Fresh Barista Milk', 'name_ar' => 'حليب طازج للباريستا', 'unit' => 'L', 'unit_cost_minor' => 600, 'reorder_threshold' => 20],
            ['sku' => 'MILK-OAT', 'name_en' => 'Oat Milk Barista Edition', 'name_ar' => 'حليب شوفان باريستا', 'unit' => 'L', 'unit_cost_minor' => 1400, 'reorder_threshold' => 10],
            ['sku' => 'CUP-08OZ', 'name_en' => 'Takeaway Paper Cup 8oz', 'name_ar' => 'أكواب ورقية سفري 8 أونصة', 'unit' => 'pcs', 'unit_cost_minor' => 50, 'reorder_threshold' => 100],
        ];

        foreach ($items as $it) {
            $createdItem = ErpInventoryItem::firstOrCreate(
                ['tenant_id' => $tenant->id, 'sku' => $it['sku']],
                [
                    'name_en' => $it['name_en'],
                    'name_ar' => $it['name_ar'],
                    'unit' => $it['unit'],
                    'unit_cost_minor' => $it['unit_cost_minor'],
                    'reorder_threshold' => $it['reorder_threshold'],
                    'current_quantity' => 0,
                    'is_active' => true,
                ]
            );

            // Seed isolated branch balance for Dubai & Abu Dhabi
            foreach ([$dubaiBranch->id, $auhBranch->id] as $bId) {
                ErpInventoryBalance::firstOrCreate(
                    [
                        'tenant_id' => $tenant->id,
                        'branch_id' => $bId,
                        'inventory_item_id' => $createdItem->id,
                    ],
                    [
                        'current_quantity' => 0,
                        'reorder_threshold' => $it['reorder_threshold'],
                    ]
                );
            }
        }
    }
}
