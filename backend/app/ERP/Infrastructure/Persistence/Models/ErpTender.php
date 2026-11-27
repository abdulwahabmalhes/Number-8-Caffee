<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpTender extends Model
{
    protected $table = 'erp_tenders';

    protected $fillable = [
        'order_id',
        'payment_method',
        'amount_minor',
        'currency',
        'reference',
        'status',
    ];

    protected $casts = [
        'amount_minor' => 'integer',
    ];

    public function order(): BelongsTo
    {
        return $this->belongsTo(ErpOrder::class, 'order_id');
    }
}
