<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

use App\Models\Branch;
use App\Models\Table;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Support\Str;

class MenuSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Create Branches
        $branch = Branch::create([
            'name_ar' => 'فرع الخبيصي',
            'name_en' => 'Al Khabisi Branch',
            'location' => 'Al Ain',
            'working_hours' => '07:00 AM - 12:00 AM',
            'is_active' => true,
        ]);

        // 2. Create Tables with secure tokens
        for ($i = 1; $i <= 10; $i++) {
            $tableNumber = str_pad((string)$i, 2, '0', STR_PAD_LEFT);
            Table::create([
                'branch_id' => $branch->id,
                'table_number' => $tableNumber,
                'qr_token' => Str::random(32),
                'is_active' => true,
            ]);
        }

        // 3. Create Categories
        $categoriesData = [
            'Breakfast' => 'فطور',
            'Croissant' => 'كرواسون',
            'Brewed Coffee' => 'قهوة مقطرة',
            'Hot Caffeinated Drinks' => 'مشروبات ساخنة',
            'Cold Caffeinated Drinks' => 'مشروبات باردة',
            'Matcha' => 'ماتشا',
            'Chilled & Refreshing' => 'مشروبات منعشة',
            'ACAI' => 'أساي',
            'Desserts' => 'حلويات',
            'Burger' => 'برجر',
            'Pasta' => 'باستا',
        ];

        $categories = [];
        $order = 1;
        foreach ($categoriesData as $en => $ar) {
            $categories[$en] = Category::create([
                'name_en' => $en,
                'name_ar' => $ar,
                'sort_order' => $order++,
            ]);
        }

        // 4. Create Products
        $products = [
            ['cat' => 'Breakfast', 'en' => 'Balaleet', 'ar' => 'بلاليط', 'price' => 35],
            ['cat' => 'Breakfast', 'en' => 'Signature Breakfast', 'ar' => 'فطور سجنتشر', 'price' => 45],
            ['cat' => 'Croissant', 'en' => 'Butter Croissant', 'ar' => 'كرواسون زبدة', 'price' => 15],
            ['cat' => 'Brewed Coffee', 'en' => 'Aeropress', 'ar' => 'ايروبريس', 'price' => 22],
            ['cat' => 'Brewed Coffee', 'en' => 'Chemex', 'ar' => 'كيمكس', 'price' => 25],
            ['cat' => 'Brewed Coffee', 'en' => 'Cold Brew', 'ar' => 'كولد برو', 'price' => 28],
            ['cat' => 'Brewed Coffee', 'en' => 'V60', 'ar' => 'في 60', 'price' => 25],
            ['cat' => 'Hot Caffeinated Drinks', 'en' => 'Cappuccino', 'ar' => 'كابتشينو', 'price' => 20],
            ['cat' => 'Hot Caffeinated Drinks', 'en' => 'Flat White', 'ar' => 'فلات وايت', 'price' => 22],
            ['cat' => 'Hot Caffeinated Drinks', 'en' => 'Spanish Hot', 'ar' => 'سبانش ساخن', 'price' => 24],
            ['cat' => 'Cold Caffeinated Drinks', 'en' => 'Spanish Cold', 'ar' => 'سبانش بارد', 'price' => 26],
            ['cat' => 'Cold Caffeinated Drinks', 'en' => 'Pistachio Latte', 'ar' => 'بستاشيو لاتيه', 'price' => 28],
            ['cat' => 'Matcha', 'en' => 'Matcha Latte', 'ar' => 'ماتشا لاتيه', 'price' => 28],
            ['cat' => 'Chilled & Refreshing', 'en' => 'Fresh Orange Juice', 'ar' => 'عصير برتقال طازج', 'price' => 20],
            ['cat' => 'ACAI', 'en' => 'Acai Bowl', 'ar' => 'أساي بول', 'price' => 42],
            ['cat' => 'Desserts', 'en' => 'Chocolate Pudding', 'ar' => 'بودنغ الشوكولاتة', 'price' => 32],
            ['cat' => 'Burger', 'en' => 'Classic Burger', 'ar' => 'برجر كلاسيك', 'price' => 45],
            ['cat' => 'Pasta', 'en' => 'Truffle Pasta', 'ar' => 'باستا ترافل', 'price' => 55],
        ];

        foreach ($products as $index => $prod) {
            Product::create([
                'category_id' => $categories[$prod['cat']]->id,
                'name_en' => $prod['en'],
                'name_ar' => $prod['ar'],
                'price' => $prod['price'],
                'is_available' => true,
                'preparation_time' => 10,
                'sort_order' => $index + 1,
            ]);
        }
    }
}
