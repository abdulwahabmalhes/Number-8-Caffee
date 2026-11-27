<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpSupplier extends Model
{
    protected $table = 'erp_suppliers';

    protected $fillable = [
        'tenant_id',
        'name',
        'contact_name',
        'phone',
        'email',
        'tax_number',
        'address',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function purchaseOrders(): HasMany
    {
        return $this->hasMany(ErpPurchaseOrder::class, 'supplier_id');
    }
}
