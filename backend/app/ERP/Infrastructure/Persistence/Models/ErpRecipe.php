<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class ErpRecipe extends Model
{
    protected $table = 'erp_recipes';

    protected $fillable = [
        'tenant_id',
        'product_id',
        'variant_id',
        'name',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function product(): BelongsTo
    {
        return $this->belongsTo(ErpProduct::class, 'product_id');
    }

    public function versions(): HasMany
    {
        return $this->hasMany(ErpRecipeVersion::class, 'recipe_id');
    }

    public function activeVersion(): HasOne
    {
        return $this->hasOne(ErpRecipeVersion::class, 'recipe_id')->where('is_active', true)->latestOfMany();
    }
}
