<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\OptionGroup;
use App\Models\Option;
use App\Models\Product;

class OptionGroupsSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Beans Selection
        $beansGroup = OptionGroup::firstOrCreate(
            ['name_en' => 'Beans Selection'],
            [
                'name_ar' => 'نوع حبوب البن',
                'is_required' => false,
                'is_multiple' => false,
                'min_choices' => 0,
                'max_choices' => 1,
            ]
        );
        $beansOptions = [
            ['name_ar' => 'إثيوبي - يرقاتشيفي (نوتات زهرية وفاكهية)', 'name_en' => 'Ethiopian Yirgacheffe (Floral & Fruity)', 'price' => 0],
            ['name_ar' => 'كولومبي سوبريمو (شوكولاتة ومكسرات)', 'name_en' => 'Colombian Supremo (Chocolate & Nutty)', 'price' => 3],
            ['name_ar' => 'كوستاريكا تارازو (حمضية متوازنة وعسل)', 'name_en' => 'Costa Rica Tarrazu (Balanced & Honey)', 'price' => 4],
            ['name_ar' => 'خلطة نمبر 8 الخاصة', 'name_en' => 'Number 8 Signature House Blend', 'price' => 2],
            ['name_ar' => 'منزوع الكافيين (Decaf)', 'name_en' => 'Decaf Colombian', 'price' => 0],
        ];
        foreach ($beansOptions as $opt) {
            Option::firstOrCreate(
                ['option_group_id' => $beansGroup->id, 'name_en' => $opt['name_en']],
                ['name_ar' => $opt['name_ar'], 'additional_price' => $opt['price'], 'is_available' => true]
            );
        }

        // 2. Temperature
        $tempGroup = OptionGroup::firstOrCreate(
            ['name_en' => 'Temperature'],
            [
                'name_ar' => 'درجة الحرارة',
                'is_required' => false,
                'is_multiple' => false,
                'min_choices' => 0,
                'max_choices' => 1,
            ]
        );
        $tempOptions = [
            ['name_ar' => 'ساخن (Hot)', 'name_en' => 'Hot', 'price' => 0],
            ['name_ar' => 'بارد مع ثلج (Iced)', 'name_en' => 'Iced', 'price' => 0],
            ['name_ar' => 'قليل الثلج (Less Ice)', 'name_en' => 'Less Ice', 'price' => 0],
        ];
        foreach ($tempOptions as $opt) {
            Option::firstOrCreate(
                ['option_group_id' => $tempGroup->id, 'name_en' => $opt['name_en']],
                ['name_ar' => $opt['name_ar'], 'additional_price' => $opt['price'], 'is_available' => true]
            );
        }

        // 3. Milk Choice
        $milkGroup = OptionGroup::firstOrCreate(
            ['name_en' => 'Milk Choice'],
            [
                'name_ar' => 'نوع الحليب',
                'is_required' => false,
                'is_multiple' => false,
                'min_choices' => 0,
                'max_choices' => 1,
            ]
        );
        $milkOptions = [
            ['name_ar' => 'حليب كامل الدسم طازج', 'name_en' => 'Fresh Whole Milk', 'price' => 0],
            ['name_ar' => 'حليب خالي الدسم', 'name_en' => 'Skimmed Milk', 'price' => 0],
            ['name_ar' => 'حليب شوفان عضوي (Oat Milk)', 'name_en' => 'Organic Oat Milk', 'price' => 4],
            ['name_ar' => 'حليب لوز (Almond Milk)', 'name_en' => 'Almond Milk', 'price' => 5],
            ['name_ar' => 'حليب جوز الهند (Coconut Milk)', 'name_en' => 'Coconut Milk', 'price' => 4],
        ];
        foreach ($milkOptions as $opt) {
            Option::firstOrCreate(
                ['option_group_id' => $milkGroup->id, 'name_en' => $opt['name_en']],
                ['name_ar' => $opt['name_ar'], 'additional_price' => $opt['price'], 'is_available' => true]
            );
        }

        // 4. Extra Shots & Flavors
        $extrasGroup = OptionGroup::firstOrCreate(
            ['name_en' => 'Extra Shots & Flavors'],
            [
                'name_ar' => 'إضافات ونكهات',
                'is_required' => false,
                'is_multiple' => true,
                'min_choices' => 0,
                'max_choices' => 5,
            ]
        );
        $extrasOptions = [
            ['name_ar' => 'شوت إسبريسو إضافي', 'name_en' => 'Extra Espresso Shot', 'price' => 4],
            ['name_ar' => 'سيرب فانيلا', 'name_en' => 'Vanilla Syrup', 'price' => 3],
            ['name_ar' => 'سيرب كراميل مملح', 'name_en' => 'Salted Caramel Syrup', 'price' => 3],
            ['name_ar' => 'صوص شوكولاتة بلجيكية', 'name_en' => 'Belgian Chocolate Drizzle', 'price' => 4],
        ];
        foreach ($extrasOptions as $opt) {
            Option::firstOrCreate(
                ['option_group_id' => $extrasGroup->id, 'name_en' => $opt['name_en']],
                ['name_ar' => $opt['name_ar'], 'additional_price' => $opt['price'], 'is_available' => true]
            );
        }

        // 5. Acai & Dessert Toppings
        $toppingsGroup = OptionGroup::firstOrCreate(
            ['name_en' => 'Extra Toppings'],
            [
                'name_ar' => 'إضافات وتوبينج',
                'is_required' => false,
                'is_multiple' => true,
                'min_choices' => 0,
                'max_choices' => 6,
            ]
        );
        $toppingsOptions = [
            ['name_ar' => 'جرانولا مقرمشة إضافية', 'name_en' => 'Extra Crunchy Granola', 'price' => 3],
            ['name_ar' => 'زبدة فول سوداني عضوية', 'name_en' => 'Organic Peanut Butter', 'price' => 4],
            ['name_ar' => 'توت مشكل وفراولة طازجة', 'name_en' => 'Fresh Mixed Berries', 'price' => 5],
            ['name_ar' => 'شرائح موز طازجة', 'name_en' => 'Fresh Banana Slices', 'price' => 2],
            ['name_ar' => 'بذور الشيا ورقائق جوز الهند', 'name_en' => 'Chia Seeds & Coconut Flakes', 'price' => 3],
            ['name_ar' => 'عسل طبيعي', 'name_en' => 'Pure Natural Honey', 'price' => 3],
        ];
        foreach ($toppingsOptions as $opt) {
            Option::firstOrCreate(
                ['option_group_id' => $toppingsGroup->id, 'name_en' => $opt['name_en']],
                ['name_ar' => $opt['name_ar'], 'additional_price' => $opt['price'], 'is_available' => true]
            );
        }

        // Link Option Groups to Products
        $products = Product::all();
        foreach ($products as $prod) {
            $name = strtolower($prod->name_en . ' ' . $prod->name_ar);
            $groupIds = [];

            // If it's V60, Chemex, Cold Drip, Filter Coffee
            if (str_contains($name, 'v60') || str_contains($name, 'chemex') || str_contains($name, 'drip') || str_contains($name, 'filter') || str_contains($name, 'مقطرة')) {
                $groupIds[] = $beansGroup->id;
                $groupIds[] = $tempGroup->id;
            }
            // If it's Latte, Cappuccino, Flat White, Spanish Latte, Cortado
            elseif (str_contains($name, 'latte') || str_contains($name, 'لاتيه') || str_contains($name, 'cappuccino') || str_contains($name, 'كابتشينو') || str_contains($name, 'flat white') || str_contains($name, 'cortado')) {
                $groupIds[] = $milkGroup->id;
                $groupIds[] = $tempGroup->id;
                $groupIds[] = $extrasGroup->id;
                $groupIds[] = $beansGroup->id;
            }
            // If it's Espresso, Americano
            elseif (str_contains($name, 'espresso') || str_contains($name, 'اسبريسو') || str_contains($name, 'americano') || str_contains($name, 'امريكانو')) {
                $groupIds[] = $beansGroup->id;
                $groupIds[] = $tempGroup->id;
                $groupIds[] = $extrasGroup->id;
            }
            // If it's Acai, Bowl, Dessert, Cake, Croissant
            elseif (str_contains($name, 'acai') || str_contains($name, 'آساي') || str_contains($name, 'cake') || str_contains($name, 'كيك') || str_contains($name, 'croissant') || str_contains($name, 'كرواسون')) {
                $groupIds[] = $toppingsGroup->id;
            } else {
                // Default drink/food options
                $groupIds[] = $tempGroup->id;
                $groupIds[] = $extrasGroup->id;
            }

            if (!empty($groupIds)) {
                $prod->optionGroups()->syncWithoutDetaching($groupIds);
            }
        }
    }
}

