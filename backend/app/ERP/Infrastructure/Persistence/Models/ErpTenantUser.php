<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ErpTenantUser extends Model
{
    protected $table = 'erp_tenant_users';

    protected $fillable = [
        'tenant_id',
        'user_id',
        'role',
        'is_tenant_admin',
        'is_active',
    ];

    protected $casts = [
        'is_tenant_admin' => 'boolean',
        'is_active' => 'boolean',
    ];

    public function tenant(): BelongsTo
    {
        return $this->belongsTo(ErpTenant::class, 'tenant_id');
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
