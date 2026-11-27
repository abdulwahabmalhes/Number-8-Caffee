<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpGoodsReceipt extends Model
{
    protected $table = 'erp_goods_receipts';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'po_id',
        'receipt_number',
        'received_at',
        'received_by',
        'notes',
    ];

    protected $casts = [
        'received_at' => 'datetime',
    ];

    public function purchaseOrder(): BelongsTo
    {
        return $this->belongsTo(ErpPurchaseOrder::class, 'po_id');
    }

    public function lines(): HasMany
    {
        return $this->hasMany(ErpGoodsReceiptLine::class, 'goods_receipt_id');
    }
}
