<?php

namespace App\Providers;

use App\ERP\Application\Contracts\AuditLogger;
use App\ERP\Application\Contracts\BranchRepositoryInterface;
use App\ERP\Application\Contracts\StaffSessionRepositoryInterface;
use App\ERP\Application\Contracts\TenantRepositoryInterface;
use App\ERP\Application\Services\BranchAccessService;
use App\ERP\Application\Services\PermissionService;
use App\ERP\Domain\Authorization\BranchAccess;
use App\ERP\Infrastructure\Persistence\Repositories\EloquentBranchRepository;
use App\ERP\Infrastructure\Persistence\Repositories\EloquentStaffSessionRepository;
use App\ERP\Infrastructure\Persistence\Repositories\EloquentTenantRepository;
use App\ERP\Infrastructure\Services\DatabaseAuditLogger;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->singleton(AuditLogger::class, DatabaseAuditLogger::class);
        $this->app->bind(TenantRepositoryInterface::class, EloquentTenantRepository::class);
        $this->app->bind(BranchRepositoryInterface::class, EloquentBranchRepository::class);
        $this->app->bind(StaffSessionRepositoryInterface::class, EloquentStaffSessionRepository::class);
        $this->app->singleton(BranchAccess::class);
        $this->app->singleton(BranchAccessService::class);
        $this->app->singleton(PermissionService::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
