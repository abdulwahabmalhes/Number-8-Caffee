<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpProductBranch extends Model
{
    protected $table = 'erp_product_branch';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'product_id',
        'variant_id',
        'price_override_minor',
        'is_available',
    ];

    protected $casts = [
        'price_override_minor' => 'integer',
        'is_available' => 'boolean',
    ];

    public function branch(): BelongsTo
    {
        return $this->belongsTo(ErpBranch::class, 'branch_id');
    }

    public function product(): BelongsTo
    {
        return $this->belongsTo(ErpProduct::class, 'product_id');
    }
}
