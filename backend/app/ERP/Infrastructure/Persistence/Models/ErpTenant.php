<?php

namespace App\ERP\Infrastructure\Persistence\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class ErpTenant extends Model
{
    protected $table = 'erp_tenants';

    protected $fillable = [
        'ulid',
        'slug',
        'name',
        'status',
        'settings',
    ];

    protected $casts = [
        'settings' => 'array',
    ];

    protected static function booted(): void
    {
        static::creating(function (ErpTenant $tenant) {
            if (empty($tenant->ulid)) {
                $tenant->ulid = (string) Str::ulid();
            }
        });
    }

    public function branches(): HasMany
    {
        return $this->hasMany(ErpBranch::class, 'tenant_id');
    }

    public function tenantUsers(): HasMany
    {
        return $this->hasMany(ErpTenantUser::class, 'tenant_id');
    }
}
