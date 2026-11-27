<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ErpCustomer extends Model
{
    protected $table = 'erp_customers';

    protected $fillable = [
        'tenant_id',
        'name',
        'phone',
        'email',
        'notes',
        'loyalty_points',
        'is_active',
    ];

    protected $casts = [
        'loyalty_points' => 'integer',
        'is_active' => 'boolean',
    ];

    public function orders(): HasMany
    {
        return $this->hasMany(ErpOrder::class, 'customer_id');
    }
}
