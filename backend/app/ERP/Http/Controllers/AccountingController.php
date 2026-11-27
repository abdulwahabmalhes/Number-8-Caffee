<?php

namespace App\ERP\Http\Controllers;

use App\ERP\Application\Services\BranchAccessService;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpAccount;
use App\ERP\Infrastructure\Persistence\Models\ErpJournal;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AccountingController
{
    public function __construct(
        private readonly BranchAccessService $branchAccessService
    ) {
    }

    public function journals(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($context->getActiveBranchId() ?? $request->header('X-Branch-ID') ?? $request->query('branch_id'));
        if ($branchId <= 0) {
            return response()->json([
                'error' => [
                    'code' => 'invalid_branch',
                    'message' => 'A valid branch must be specified for journal queries.',
                ],
            ], 400);
        }
        $this->branchAccessService->assertBranchAccess($context, $branchId);

        $query = ErpJournal::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('branch_id', $branchId);

        $period = $request->query('period');
        if ($period) {
            $query->where('period', $period);
        }

        $journals = $query->with(['lines.account', 'branch'])
            ->orderBy('id', 'desc')
            ->limit(100)
            ->get();

        return response()->json([
            'branch_id' => $branchId,
            'period' => $period,
            'journals' => $journals,
        ]);
    }

    public function accounts(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($context->getActiveBranchId() ?? $request->header('X-Branch-ID') ?? $request->query('branch_id'));
        if ($branchId > 0) {
            $this->branchAccessService->assertBranchAccess($context, $branchId);
        }

        $period = $request->query('period');

        $journalQuery = ErpJournal::query()
            ->where('tenant_id', $context->getTenantId());

        if ($branchId > 0) {
            $journalQuery->where('branch_id', $branchId);
        }
        if ($period) {
            $journalQuery->where('period', $period);
        }
        $journalIds = $journalQuery->pluck('id');

        $accounts = ErpAccount::query()
            ->where('tenant_id', $context->getTenantId())
            ->with(['lines' => function ($q) use ($journalIds) {
                $q->whereIn('journal_id', $journalIds)
                  ->select('id', 'journal_id', 'account_id', 'debit_minor', 'credit_minor');
            }])
            ->get()
            ->map(function (ErpAccount $acc) {
                $totalDebit = $acc->lines->sum('debit_minor');
                $totalCredit = $acc->lines->sum('credit_minor');
                $balance = in_array($acc->type, ['asset', 'expense'], true) 
                    ? ($totalDebit - $totalCredit) 
                    : ($totalCredit - $totalDebit);

                return [
                    'id' => $acc->id,
                    'code' => $acc->code,
                    'name_en' => $acc->name_en,
                    'name_ar' => $acc->name_ar,
                    'type' => $acc->type,
                    'balance_minor' => $balance,
                ];
            });

        return response()->json([
            'branch_id' => $branchId > 0 ? $branchId : null,
            'period' => $period,
            'accounts' => $accounts,
        ]);
    }

    public function vatReport(Request $request): JsonResponse
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        /** @var TenantContext $context */
        $context = $request->attributes->get('erp_context');
        $branchId = (int) ($context->getActiveBranchId() ?? $request->header('X-Branch-ID') ?? $request->query('branch_id'));
        if ($branchId > 0) {
            $this->branchAccessService->assertBranchAccess($context, $branchId);
        }

        $period = $request->query('period') ?? date('Y-m');

        $journalQuery = ErpJournal::query()
            ->where('tenant_id', $context->getTenantId());

        if ($branchId > 0) {
            $journalQuery->where('branch_id', $branchId);
        }
        if ($period) {
            $journalQuery->where('period', $period);
        }
        $journalIds = $journalQuery->pluck('id');

        $vatAccount = ErpAccount::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('code', '2020')
            ->first();

        $outputVatMinor = 0;
        if ($vatAccount && $journalIds->isNotEmpty()) {
            $outputVatMinor = (int) DB::table('erp_journal_lines')
                ->where('account_id', $vatAccount->id)
                ->whereIn('journal_id', $journalIds)
                ->sum('credit_minor');
        }
        $standardRatedSalesMinor = (int) round($outputVatMinor / 0.05);

        return response()->json([
            'period' => $period,
            'branch_id' => $branchId > 0 ? $branchId : null,
            'rate' => 0.05,
            'standard_rated_sales_minor' => $standardRatedSalesMinor,
            'output_tax_minor' => $outputVatMinor,
            'recoverable_input_tax_minor' => 0,
            'net_payable_minor' => $outputVatMinor,
            'is_formal_declaration_ready' => false,
            'disclaimer' => 'Preliminary experimental 5% VAT calculation; requires certified CPA review prior to formal UAE FTA filing.',
        ]);
    }
}

