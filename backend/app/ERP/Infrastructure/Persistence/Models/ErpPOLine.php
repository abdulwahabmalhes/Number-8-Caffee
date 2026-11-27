<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpPOLine extends Model
{
    protected $table = 'erp_po_lines';

    protected $fillable = [
        'po_id',
        'inventory_item_id',
        'ordered_quantity',
        'received_quantity',
        'unit_cost_minor',
        'total_minor',
    ];

    protected $casts = [
        'ordered_quantity' => 'float',
        'received_quantity' => 'float',
        'unit_cost_minor' => 'integer',
        'total_minor' => 'integer',
    ];

    public function item(): BelongsTo
    {
        return $this->belongsTo(ErpInventoryItem::class, 'inventory_item_id');
    }
}
