<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpProductVariant extends Model
{
    protected $table = 'erp_product_variants';

    protected $fillable = [
        'tenant_id',
        'product_id',
        'name_en',
        'name_ar',
        'price_minor',
        'is_default',
    ];

    protected $casts = [
        'price_minor' => 'integer',
        'is_default' => 'boolean',
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(ErpProduct::class, 'product_id');
    }
}
