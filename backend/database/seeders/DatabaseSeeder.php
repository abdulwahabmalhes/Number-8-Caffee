<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Branch;
use App\Models\Table;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Vehicle;
use App\Models\Product;
use Illuminate\Support\Str;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Roles and Permissions
        $this->call(RolesAndPermissionsSeeder::class);

        // 2. Admin User
        $admin = User::firstOrCreate(
            ['email' => 'admin@numbereight.ae'],
            [
                'name' => 'Admin Number Eight',
                'password' => bcrypt('password123'),
                'email_verified_at' => now(),
            ]
        );
        $admin->assignRole('Super Admin');

        // 3. Cashier User
        $cashier = User::firstOrCreate(
            ['email' => 'cashier@numbereight.ae'],
            [
                'name' => 'Cashier Number Eight',
                'password' => bcrypt('password123'),
                'email_verified_at' => now(),
            ]
        );
        $cashier->assignRole('Cashier');

        // 2. Menu & Tables
        $this->call(MenuSeeder::class);

        $branch = Branch::first();
        $tables = Table::all();
        $products = Product::all();

        // 3. Create Sample Table Orders
        if ($tables->isNotEmpty() && $products->isNotEmpty()) {
            $tableOrder1 = Order::create([
                'order_number' => '#NE1278',
                'branch_id' => $branch->id,
                'table_id' => $tables->first()->id,
                'order_type' => 'table',
                'subtotal' => 62.00,
                'tax_amount' => 2.00,
                'discount_amount' => 0.00,
                'grand_total' => 64.00,
                'status' => 'preparing',
                'payment_method' => 'apple_pay',
                'payment_status' => 'paid',
                'notes' => 'Extra hot milk please',
            ]);

            OrderItem::create([
                'order_id' => $tableOrder1->id,
                'product_id' => $products->first()->id,
                'quantity' => 1,
                'unit_price' => 24.00,
                'total_price' => 24.00,
                'special_instructions' => 'Large, Extra Shot, Oat Milk',
            ]);

            OrderItem::create([
                'order_id' => $tableOrder1->id,
                'product_id' => $products->skip(2)->first()->id,
                'quantity' => 1,
                'unit_price' => 22.00,
                'total_price' => 22.00,
                'special_instructions' => 'Medium, Regular Milk',
            ]);

            OrderItem::create([
                'order_id' => $tableOrder1->id,
                'product_id' => $products->skip(6)->first()->id,
                'quantity' => 1,
                'unit_price' => 16.00,
                'total_price' => 16.00,
                'special_instructions' => 'Warm',
            ]);

            // 4. Create Sample Car Service Order
            $vehicle = Vehicle::create([
                'plate_number' => '12345 أ ب',
                'plate_emirate' => 'أبوظبي',
                'vehicle_model' => 'مرسيدس G63',
                'vehicle_color' => 'أسود',
            ]);

            $carOrder = Order::create([
                'order_number' => '#NE1279',
                'branch_id' => $branch->id,
                'vehicle_id' => $vehicle->id,
                'order_type' => 'car',
                'subtotal' => 52.00,
                'tax_amount' => 2.00,
                'discount_amount' => 0.00,
                'grand_total' => 54.00,
                'status' => 'ready',
                'payment_method' => 'apple_pay',
                'payment_status' => 'paid',
                'customer_arrived_at' => now(),
                'notes' => 'Waiting in parking spot #4',
            ]);

            OrderItem::create([
                'order_id' => $carOrder->id,
                'product_id' => $products->skip(1)->first()->id,
                'quantity' => 2,
                'unit_price' => 25.00,
                'total_price' => 50.00,
                'special_instructions' => 'V60 Ethiopian Single Origin',
            ]);
        }
    }
}
