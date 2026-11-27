<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpOrder extends Model
{
    protected $table = 'erp_orders';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'customer_id',
        'guest_name',
        'order_number',
        'idempotency_key',
        'order_type',
        'status',
        'notes',
        'subtotal_minor',
        'tax_minor',
        'total_minor',
        'currency',
        'created_by',
    ];

    protected $casts = [
        'subtotal_minor' => 'integer',
        'tax_minor' => 'integer',
        'total_minor' => 'integer',
    ];

    public function lines(): HasMany
    {
        return $this->hasMany(ErpOrderLine::class, 'order_id');
    }

    public function tenders(): HasMany
    {
        return $this->hasMany(ErpTender::class, 'order_id');
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(ErpCustomer::class, 'customer_id');
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(ErpBranch::class, 'branch_id');
    }
}
