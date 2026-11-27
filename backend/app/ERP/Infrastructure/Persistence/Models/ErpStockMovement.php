<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpStockMovement extends Model
{
    public $timestamps = false;

    protected $table = 'erp_stock_movements';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'inventory_item_id',
        'idempotency_key',
        'quantity_change',
        'balance_after',
        'reason',
        'reference_type',
        'reference_id',
        'actor_id',
        'created_at',
    ];

    protected $casts = [
        'quantity_change' => 'float',
        'balance_after' => 'float',
        'created_at' => 'datetime',
    ];

    public function item(): BelongsTo
    {
        return $this->belongsTo(ErpInventoryItem::class, 'inventory_item_id');
    }
}
