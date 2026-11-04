<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

use Spatie\Permission\Models\Role;
use Spatie\Permission\Models\Permission;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Reset cached roles and permissions
        app()[\Spatie\Permission\PermissionRegistrar::class]->forgetCachedPermissions();

        // create roles and assign created permissions
        Role::firstOrCreate(['name' => 'Super Admin', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'Branch Manager', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'Cashier', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'Barista', 'guard_name' => 'web']);
        Role::firstOrCreate(['name' => 'Handover', 'guard_name' => 'web']);
    }
}
