<?php

namespace App\ERP\Application\Contracts;

use App\ERP\Infrastructure\Persistence\Models\ErpTenant;

interface TenantRepositoryInterface
{
    public function findById(int $id): ?ErpTenant;

    public function findBySlug(string $slug): ?ErpTenant;

    public function save(ErpTenant $tenant): void;
}
