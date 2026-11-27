<?php

namespace App\ERP\Infrastructure\Persistence\Repositories;

use App\ERP\Application\Contracts\TenantRepositoryInterface;
use App\ERP\Infrastructure\Persistence\Models\ErpTenant;

class EloquentTenantRepository implements TenantRepositoryInterface
{
    public function findById(int $id): ?ErpTenant
    {
        return ErpTenant::query()->where('id', $id)->first();
    }

    public function findBySlug(string $slug): ?ErpTenant
    {
        return ErpTenant::query()->where('slug', $slug)->first();
    }

    public function save(ErpTenant $tenant): void
    {
        $tenant->save();
    }
}
