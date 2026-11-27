<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpProduct extends Model
{
    protected $table = 'erp_products';

    protected $fillable = [
        'tenant_id',
        'sku',
        'name_en',
        'name_ar',
        'category',
        'station_code',
        'is_active',
        'is_archived',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'is_archived' => 'boolean',
    ];

    public function variants(): HasMany
    {
        return $this->hasMany(ErpProductVariant::class, 'product_id');
    }

    public function recipes(): HasMany
    {
        return $this->hasMany(ErpRecipe::class, 'product_id');
    }

    public function branchSettings(): HasMany
    {
        return $this->hasMany(ErpProductBranch::class, 'product_id');
    }
}
