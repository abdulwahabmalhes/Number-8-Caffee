<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpPurchaseOrder extends Model
{
    protected $table = 'erp_purchase_orders';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'supplier_id',
        'po_number',
        'status',
        'total_minor',
        'currency',
        'notes',
        'created_by',
    ];

    protected $casts = [
        'total_minor' => 'integer',
    ];

    public function supplier(): BelongsTo
    {
        return $this->belongsTo(ErpSupplier::class, 'supplier_id');
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(ErpBranch::class, 'branch_id');
    }

    public function lines(): HasMany
    {
        return $this->hasMany(ErpPOLine::class, 'po_id');
    }

    public function goodsReceipts(): HasMany
    {
        return $this->hasMany(ErpGoodsReceipt::class, 'po_id');
    }

    public function invoices(): HasMany
    {
        return $this->hasMany(ErpSupplierInvoice::class, 'po_id');
    }
}
