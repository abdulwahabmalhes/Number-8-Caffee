<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpOrderLine extends Model
{
    protected $table = 'erp_order_lines';

    protected $fillable = [
        'order_id',
        'product_id',
        'variant_id',
        'recipe_version_id',
        'sku',
        'name_en',
        'name_ar',
        'quantity',
        'unit_price_minor',
        'subtotal_minor',
        'tax_minor',
        'total_minor',
        'selected_options',
        'recipe_snapshot',
    ];

    protected $casts = [
        'quantity' => 'integer',
        'unit_price_minor' => 'integer',
        'subtotal_minor' => 'integer',
        'tax_minor' => 'integer',
        'total_minor' => 'integer',
        'selected_options' => 'array',
        'recipe_snapshot' => 'array',
    ];

    public function order(): BelongsTo
    {
        return $this->belongsTo(ErpOrder::class, 'order_id');
    }
}
