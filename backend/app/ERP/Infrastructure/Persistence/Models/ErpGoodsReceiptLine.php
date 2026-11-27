<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpGoodsReceiptLine extends Model
{
    protected $table = 'erp_goods_receipt_lines';

    protected $fillable = [
        'goods_receipt_id',
        'po_line_id',
        'inventory_item_id',
        'quantity_received',
        'unit_cost_minor',
    ];

    protected $casts = [
        'quantity_received' => 'float',
        'unit_cost_minor' => 'integer',
    ];

    public function item(): BelongsTo
    {
        return $this->belongsTo(ErpInventoryItem::class, 'inventory_item_id');
    }
}
