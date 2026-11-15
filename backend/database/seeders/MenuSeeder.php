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
        $branch = Branch::firstOrCreate(
            ['name_en' => 'Al Khabisi Branch'],
            [
                'name_ar' => 'فرع الخبيصي',
                'location' => 'Al Ain',
                'working_hours' => '07:00 AM - 12:00 AM',
                'is_active' => true,
            ]
        );

        // 2. Create Tables with secure tokens
        for ($i = 1; $i <= 10; $i++) {
            $tableNumber = str_pad((string)$i, 2, '0', STR_PAD_LEFT);
            Table::firstOrCreate(
                ['table_number' => $tableNumber],
                [
                    'branch_id' => $branch->id,
                    'qr_token' => Str::random(32),
                    'is_active' => true,
                ]
            );
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
            $categories[$en] = Category::firstOrCreate(
                ['name_en' => $en],
                [
                    'name_ar' => $ar,
                    'sort_order' => $order++,
                    'is_active' => true,
                ]
            );
        }

        // 4. Create or Update Products with High-Resolution Verified Authentic Images
        $products = [
            [
                'cat' => 'Breakfast',
                'en' => 'Balaleet',
                'ar' => 'بلاليط',
                'price' => 35,
                'image' => 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Breakfast',
                'en' => 'Signature Breakfast',
                'ar' => 'فطور سجنتشر',
                'price' => 45,
                'image' => 'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Croissant',
                'en' => 'Butter Croissant',
                'ar' => 'كرواسون زبدة',
                'price' => 15,
                'image' => 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Brewed Coffee',
                'en' => 'Aeropress',
                'ar' => 'ايروبريس',
                'price' => 22,
                'image' => 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Brewed Coffee',
                'en' => 'Chemex',
                'ar' => 'كيمكس',
                'price' => 25,
                'image' => 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Brewed Coffee',
                'en' => 'Cold Brew',
                'ar' => 'كولد برو',
                'price' => 28,
                'image' => 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Brewed Coffee',
                'en' => 'V60',
                'ar' => 'في 60',
                'price' => 25,
                'image' => 'https://images.unsplash.com/photo-1498603536246-15572faa67a6?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Hot Caffeinated Drinks',
                'en' => 'Cappuccino',
                'ar' => 'كابتشينو',
                'price' => 20,
                'image' => 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Hot Caffeinated Drinks',
                'en' => 'Flat White',
                'ar' => 'فلات وايت',
                'price' => 22,
                'image' => 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Hot Caffeinated Drinks',
                'en' => 'Spanish Hot',
                'ar' => 'سبانش ساخن',
                'price' => 24,
                'image' => 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Cold Caffeinated Drinks',
                'en' => 'Spanish Cold',
                'ar' => 'سبانش بارد',
                'price' => 26,
                'image' => 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Cold Caffeinated Drinks',
                'en' => 'Pistachio Latte',
                'ar' => 'بستاشيو لاتيه',
                'price' => 28,
                'image' => 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Matcha',
                'en' => 'Matcha Latte',
                'ar' => 'ماتشا لاتيه',
                'price' => 28,
                'image' => 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Chilled & Refreshing',
                'en' => 'Fresh Orange Juice',
                'ar' => 'عصير برتقال طازج',
                'price' => 20,
                'image' => 'https://images.unsplash.com/photo-1613478223719-2ab802602423?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'ACAI',
                'en' => 'Acai Bowl',
                'ar' => 'أساي بول',
                'price' => 42,
                'image' => 'https://images.unsplash.com/photo-1590301157890-4810ed352733?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Desserts',
                'en' => 'Chocolate Pudding',
                'ar' => 'بودنغ الشوكولاتة',
                'price' => 32,
                'image' => 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Burger',
                'en' => 'Classic Burger',
                'ar' => 'برجر كلاسيك',
                'price' => 45,
                'image' => 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=400&auto=format&fit=crop',
            ],
            [
                'cat' => 'Pasta',
                'en' => 'Truffle Pasta',
                'ar' => 'باستا ترافل',
                'price' => 55,
                'image' => 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=400&auto=format&fit=crop',
            ],
        ];

        foreach ($products as $index => $prod) {
            Product::updateOrCreate(
                ['name_en' => $prod['en']],
                [
                    'category_id' => $categories[$prod['cat']]->id,
                    'name_ar' => $prod['ar'],
                    'price' => $prod['price'],
                    'image' => $prod['image'],
                    'is_available' => true,
                    'preparation_time' => 10,
                    'sort_order' => $index + 1,
                ]
            );
        }
    }
}
