<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpRecipeLine extends Model
{
    protected $table = 'erp_recipe_lines';

    protected $fillable = [
        'recipe_version_id',
        'inventory_item_id',
        'quantity',
        'unit',
    ];

    protected $casts = [
        'quantity' => 'float',
    ];

    public function item(): BelongsTo
    {
        return $this->belongsTo(ErpInventoryItem::class, 'inventory_item_id');
    }
}
