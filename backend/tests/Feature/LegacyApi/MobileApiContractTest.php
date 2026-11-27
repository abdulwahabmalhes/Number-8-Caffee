<?php

namespace Tests\Feature\LegacyApi;

use App\Models\Branch;
use App\Models\Category;
use App\Models\Offer;
use App\Models\Product;
use App\Models\Setting;
use App\Models\Table;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class MobileApiContractTest extends TestCase
{
    use RefreshDatabase;

    public function test_loyalty_config_endpoint_contract(): void
    {
        Setting::set('loyalty_target_cups', 8);

        $response = $this->getJson('/api/v1/loyalty/config');

        $response->assertStatus(200);
        $response->assertJson([
            'success' => true,
            'target_cups' => 8,
            'free_cup_number' => 9,
        ]);
    }

    public function test_stripe_config_endpoint_contract(): void
    {
        $response = $this->getJson('/api/v1/stripe/config');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'is_configured',
            'is_live',
            'is_sandbox',
            'publishable_key',
        ]);
    }

    public function test_menu_endpoint_contract(): void
    {
        $category = new Category;
        $category->name_en = 'Coffee';
        $category->name_ar = 'قهوة';
        $category->sort_order = 1;
        $category->is_active = true;
        $category->save();

        $product = new Product;
        $product->category_id = $category->id;
        $product->name_en = 'Espresso';
        $product->name_ar = 'إسبريسو';
        $product->description_en = 'Rich single origin';
        $product->description_ar = 'قهوة مختصة';
        $product->price = 18.00;
        $product->is_available = true;
        $product->save();

        $response = $this->getJson('/api/v1/menu');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'data' => [
                '*' => ['id', 'name_en', 'name_ar', 'products'],
            ],
        ]);
    }

    public function test_offers_endpoint_contract(): void
    {
        $offer = new Offer;
        $offer->title_en = 'Welcome Offer';
        $offer->title_ar = 'عرض ترحيبي';
        $offer->coupon_code = 'WELCOME10';
        $offer->discount_type = 'percentage';
        $offer->discount_value = 10;
        $offer->is_active = true;
        $offer->save();

        $response = $this->getJson('/api/v1/offers');

        $response->assertStatus(200);
        $response->assertJsonStructure([
            'success',
            'data',
        ]);
    }

    public function test_scan_qr_endpoint_contract(): void
    {
        $branch = new Branch;
        $branch->name_en = 'Flagship';
        $branch->name_ar = 'الفرع الرئيسي';
        $branch->save();

        $table = new Table;
        $table->branch_id = $branch->id;
        $table->table_number = 'T-01';
        $table->qr_token = 'unique-test-token-12345';
        $table->is_active = true;
        $table->save();

        $response = $this->postJson('/api/v1/scan-qr', [
            'qr_token' => 'unique-test-token-12345',
        ]);

        $response->assertStatus(200);
        $response->assertJson([
            'success' => true,
            'branch_id' => $branch->id,
            'table_id' => $table->id,
            'table_number' => 'T-01',
            'branch_name' => 'Flagship',
        ]);
        $this->assertNotEmpty($response->json('session_id'));
    }
}
