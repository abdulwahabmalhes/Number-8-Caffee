<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpAuditLog extends Model
{
    public $timestamps = false;

    protected $table = 'erp_audit_logs';

    protected $fillable = [
        'tenant_id',
        'branch_id',
        'actor_id',
        'action',
        'aggregate_id',
        'context',
        'ip_address',
        'request_id',
        'created_at',
    ];

    protected $casts = [
        'context' => 'array',
        'created_at' => 'datetime',
    ];

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(ErpTenant::class, 'tenant_id');
    }
}
