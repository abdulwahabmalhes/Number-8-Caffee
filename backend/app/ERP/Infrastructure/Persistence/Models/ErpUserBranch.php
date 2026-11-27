<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpUserBranch extends Model
{
    protected $table = 'erp_user_branch';

    protected $fillable = [
        'tenant_id',
        'user_id',
        'branch_id',
        'is_default',
    ];

    protected $casts = [
        'is_default' => 'boolean',
    ];

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(ErpTenant::class, 'tenant_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function branch(): BelongsTo
    {
        return $this->belongsTo(ErpBranch::class, 'branch_id');
    }
}
