<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpInventoryItem extends Model
{
    protected $table = 'erp_inventory_items';

    protected $fillable = [
        'tenant_id',
        'sku',
        'name_en',
        'name_ar',
        'unit',
        'current_quantity',
        'reorder_threshold',
        'unit_cost_minor',
        'is_active',
    ];

    protected $casts = [
        'current_quantity' => 'float',
        'reorder_threshold' => 'float',
        'unit_cost_minor' => 'integer',
        'is_active' => 'boolean',
    ];

    public function movements(): HasMany
    {
        return $this->hasMany(ErpStockMovement::class, 'inventory_item_id');
    }
}
