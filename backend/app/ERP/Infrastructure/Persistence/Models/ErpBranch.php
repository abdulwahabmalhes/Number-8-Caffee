<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpBranch extends Model
{
    protected $table = 'erp_branches';

    protected $fillable = [
        'tenant_id',
        'name',
        'code',
        'legacy_branch_id',
        'is_active',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'legacy_branch_id' => 'integer',
    ];

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(ErpTenant::class, 'tenant_id');
    }
}
