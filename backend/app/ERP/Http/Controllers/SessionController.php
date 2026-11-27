<?php

namespace App\ERP\Http\Controllers;

use App\ERP\Application\Contracts\StaffSessionRepositoryInterface;
use App\ERP\Domain\Tenancy\TenantContext;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SessionController
{
    public function __construct(
        private readonly StaffSessionRepositoryInterface $sessionRepository
    ) {
    }

    public function show(Request $request): JsonResponse
    {
        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');

        $sessionData = $this->sessionRepository->getSession($context, (int) $request->user()->id);

        return response()->json($sessionData);
    }
}
