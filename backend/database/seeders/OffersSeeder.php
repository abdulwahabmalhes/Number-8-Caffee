<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Offer;

class OffersSeeder extends Seeder
{
    public function run(): void
    {
        $offers = [
            [
                'title_ar' => 'خصم 20% على القهوة المختصة',
                'title_en' => '20% Off Specialty Coffee',
                'description_ar' => 'استمتع بخصم 20% على جميع مشروبات الإسبريسو والفلتر طوال اليوم',
                'description_en' => 'Enjoy 20% off all espresso and handcrafted brews all day',
                'image' => 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=600&auto=format&fit=crop',
                'coupon_code' => 'N8OFF20',
                'discount_type' => 'percentage',
                'discount_value' => 20.0,
                'min_order_amount' => 0.0,
                'is_active' => true,
            ],
            [
                'title_ar' => 'خصم 15 درهم لطلبات السيارة',
                'title_en' => '15 AED Off Car Pickup',
                'description_ar' => 'كوبون خاص لخدمة استلام قهوتك من السيارة أمام الكافيه',
                'description_en' => 'Special discount on all curbside car pickup orders',
                'image' => 'https://images.unsplash.com/photo-1520050206274-a1ae44613e6d?q=80&w=600&auto=format&fit=crop',
                'coupon_code' => 'CAR15',
                'discount_type' => 'fixed',
                'discount_value' => 15.0,
                'min_order_amount' => 40.0,
                'is_active' => true,
            ],
            [
                'title_ar' => 'عرض بوكس القهوة والحلى',
                'title_en' => 'Dessert & Coffee Bundle',
                'description_ar' => 'خصم 10 دراهم عند طلب الحلى مع قهوتك المفضلة',
                'description_en' => '10 AED discount when ordering dessert with coffee',
                'image' => 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=600&auto=format&fit=crop',
                'coupon_code' => 'SWEET10',
                'discount_type' => 'fixed',
                'discount_value' => 10.0,
                'min_order_amount' => 30.0,
                'is_active' => true,
            ],
        ];

        foreach ($offers as $data) {
            Offer::updateOrCreate(
                ['coupon_code' => $data['coupon_code']],
                $data
            );
        }
    }
}
