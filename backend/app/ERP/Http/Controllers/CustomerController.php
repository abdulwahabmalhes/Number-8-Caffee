<?php

namespace App\ERP\Http\Controllers;

use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpCustomer;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerController
{
    public function index(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $query = ErpCustomer::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('is_active', true)
            ->withCount('orders');

        if ($search = $request->query('q')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        }

        return response()->json([
            'customers' => $query->orderBy('name')->get(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:50',
            'email' => 'nullable|email|max:100',
            'notes' => 'nullable|string',
        ]);

        $customer = ErpCustomer::create([
            'tenant_id' => $context->getTenantId(),
            'name' => $validated['name'],
            'phone' => $validated['phone'] ?? null,
            'email' => $validated['email'] ?? null,
            'notes' => $validated['notes'] ?? null,
            'is_active' => true,
            'loyalty_points' => 0,
        ]);

        return response()->json($customer, 201);
    }

    public function show(Request $request, int $id): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $customer = ErpCustomer::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $id)
            ->with(['orders.lines', 'orders.tenders'])
            ->firstOrFail();

        return response()->json($customer);
    }
}
