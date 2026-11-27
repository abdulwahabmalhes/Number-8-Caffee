<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpInventoryBalance extends Model
{
    protected $table = 'erp_inventory_balances';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'inventory_item_id',
        'current_quantity',
        'reorder_threshold',
    ];

    protected $casts = [
        'current_quantity' => 'decimal:3',
        'reorder_threshold' => 'decimal:3',
    ];

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(ErpTenant::class, 'tenant_id');
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(ErpBranch::class, 'branch_id');
    }

    public function item(): BelongsTo
    {
        return $this->belongsTo(ErpInventoryItem::class, 'inventory_item_id');
    }
}
