<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpIdempotencyRecord extends Model
{
    protected $table = 'erp_idempotency_keys';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'action_type',
        'idempotency_key',
        'request_hash',
        'response_code',
        'response_body',
        'resource_id',
        'user_id',
    ];

    protected $casts = [
        'response_body' => 'array',
        'response_code' => 'integer',
    ];

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(ErpTenant::class, 'tenant_id');
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(ErpBranch::class, 'branch_id');
    }
}
