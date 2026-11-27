<?php

namespace App\ERP\Application\Services;

use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpGoodsReceipt;
use App\ERP\Infrastructure\Persistence\Models\ErpGoodsReceiptLine;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryBalance;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryItem;
use App\ERP\Infrastructure\Persistence\Models\ErpJournal;
use App\ERP\Infrastructure\Persistence\Models\ErpJournalLine;
use App\ERP\Infrastructure\Persistence\Models\ErpAccount;
use App\ERP\Infrastructure\Persistence\Models\ErpPOLine;
use App\ERP\Infrastructure\Persistence\Models\ErpPurchaseOrder;
use App\ERP\Infrastructure\Persistence\Models\ErpStockMovement;
use App\ERP\Infrastructure\Persistence\Models\ErpSupplier;
use App\ERP\Infrastructure\Persistence\Models\ErpSupplierInvoice;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use InvalidArgumentException;
use RuntimeException;

class PurchasingService
{
    public function createPurchaseOrder(TenantContext $context, int $branchId, array $data, ?int $userId = null): ErpPurchaseOrder
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        $supplier = ErpSupplier::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $data['supplier_id'])
            ->firstOrFail();

        return DB::transaction(function () use ($context, $branchId, $supplier, $data, $userId) {
            $poNumber = 'PO-' . date('Ymd') . '-' . strtoupper(Str::random(4));
            
            $po = ErpPurchaseOrder::create([
                'tenant_id' => $context->getTenantId(),
                'branch_id' => $branchId,
                'supplier_id' => $supplier->id,
                'po_number' => $poNumber,
                'status' => 'submitted',
                'currency' => 'AED',
                'notes' => $data['notes'] ?? null,
                'created_by' => $userId,
                'total_minor' => 0,
            ]);

            $totalMinor = 0;
            foreach ($data['lines'] as $lineData) {
                $item = ErpInventoryItem::query()
                    ->where('tenant_id', $context->getTenantId())
                    ->where('id', $lineData['inventory_item_id'])
                    ->firstOrFail();

                $unitCost = (int) ($lineData['unit_cost_minor'] ?? $item->unit_cost_minor);
                $orderedQty = (float) $lineData['ordered_quantity'];
                $lineTotal = (int) round($orderedQty * $unitCost);
                $totalMinor += $lineTotal;

                ErpPOLine::create([
                    'po_id' => $po->id,
                    'inventory_item_id' => $item->id,
                    'ordered_quantity' => $orderedQty,
                    'received_quantity' => 0,
                    'unit_cost_minor' => $unitCost,
                    'total_minor' => $lineTotal,
                ]);
            }

            $po->update(['total_minor' => $totalMinor]);
            return $po->load(['lines.item', 'supplier']);
        });
    }

    /**
     * Approves goods receipt, verifies over-receiving prevention, records append-only stock movement.
     * Valuation policy: Standard / Weighted Average Cost, recognized on Goods Receipt.
     */
    public function receiveGoods(TenantContext $context, int $poId, array $receivedLines, string $receivedBy, ?string $notes = null): ErpGoodsReceipt
    {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        return DB::transaction(function () use ($context, $poId, $receivedLines, $receivedBy, $notes) {
            $po = ErpPurchaseOrder::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('id', $poId)
                ->lockForUpdate()
                ->firstOrFail();

            if (in_array($po->status, ['received', 'cancelled'], true)) {
                throw new InvalidArgumentException("Purchase order {$po->po_number} is already {$po->status}.");
            }

            $receiptNumber = 'GRN-' . date('Ymd') . '-' . strtoupper(Str::random(4));
            $goodsReceipt = ErpGoodsReceipt::create([
                'tenant_id' => $context->getTenantId(),
                'branch_id' => $po->branch_id,
                'po_id' => $po->id,
                'receipt_number' => $receiptNumber,
                'received_at' => now(),
                'received_by' => $receivedBy,
                'notes' => $notes,
            ]);

            foreach ($receivedLines as $recv) {
                $poLine = ErpPOLine::query()->where('po_id', $po->id)->where('id', $recv['po_line_id'])->firstOrFail();
                $qtyToReceive = (float) $recv['quantity_received'];

                if ($qtyToReceive <= 0) {
                    continue;
                }

                $newTotalReceived = $poLine->received_quantity + $qtyToReceive;
                // Strict check: Prevent receiving more than ordered
                if ($newTotalReceived > $poLine->ordered_quantity) {
                    throw new InvalidArgumentException(
                        "Over-receiving prohibited: Ordered {$poLine->ordered_quantity}, previously received {$poLine->received_quantity}, attempting to receive {$qtyToReceive}."
                    );
                }

                $poLine->update(['received_quantity' => $newTotalReceived]);

                ErpGoodsReceiptLine::create([
                    'goods_receipt_id' => $goodsReceipt->id,
                    'po_line_id' => $poLine->id,
                    'inventory_item_id' => $poLine->inventory_item_id,
                    'quantity_received' => $qtyToReceive,
                    'unit_cost_minor' => $poLine->unit_cost_minor,
                ]);

                // Append-only stock movement
                $item = ErpInventoryItem::query()->where('id', $poLine->inventory_item_id)->lockForUpdate()->firstOrFail();
                $newBalance = $item->current_quantity + $qtyToReceive;

                $branchBalance = ErpInventoryBalance::firstOrCreate(
                    [
                        'tenant_id' => $context->getTenantId(),
                        'branch_id' => $po->branch_id,
                        'inventory_item_id' => $item->id,
                    ],
                    [
                        'current_quantity' => 0,
                        'reorder_threshold' => $item->reorder_threshold ?? 10,
                    ]
                );
                $branchBalance->increment('current_quantity', $qtyToReceive);

                ErpStockMovement::create([
                    'tenant_id' => $context->getTenantId(),
                    'branch_id' => $po->branch_id,
                    'inventory_item_id' => $item->id,
                    'idempotency_key' => 'GRN-MOV-' . $goodsReceipt->id . '-' . $poLine->id . '-' . microtime(true),
                    'quantity_change' => $qtyToReceive,
                    'balance_after' => $branchBalance->fresh()->current_quantity,
                    'reason' => 'purchase',
                    'reference_type' => 'goods_receipt',
                    'reference_id' => (string) $goodsReceipt->id,
                    'actor_id' => $receivedBy,
                    'created_at' => now(),
                ]);

                $item->update([
                    'current_quantity' => $newBalance,
                    'unit_cost_minor' => $poLine->unit_cost_minor,
                ]);
            }

            // Update PO status
            $allLines = $po->lines()->get();
            $allReceived = $allLines->every(fn ($l) => $l->received_quantity >= $l->ordered_quantity);
            $po->update(['status' => $allReceived ? 'received' : 'partially_received']);

            return $goodsReceipt->load('lines.item');
        });
    }

    /**
     * Creates and posts a supplier invoice, linking it to the goods receipt.
     * Posts balanced double entry journal:
     * Debit: 1050 Inventory Asset
     * Credit: 2010 Accounts Payable - Suppliers
     */
    public function createSupplierInvoice(
        TenantContext $context,
        int $poId,
        int $goodsReceiptId,
        string $invoiceNumber,
        string $invoiceDate,
        ?int $taxMinor = null
    ): ErpSupplierInvoice {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        return DB::transaction(function () use ($context, $poId, $goodsReceiptId, $invoiceNumber, $invoiceDate, $taxMinor) {
            $po = ErpPurchaseOrder::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('id', $poId)
                ->firstOrFail();

            $gr = ErpGoodsReceipt::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('id', $goodsReceiptId)
                ->with('lines')
                ->firstOrFail();

            // Strict branch and PO match check
            if ((int) $gr->po_id !== (int) $po->id || (int) $gr->branch_id !== (int) $po->branch_id) {
                throw new InvalidArgumentException(
                    "Goods receipt {$gr->receipt_number} does not match purchase order {$po->po_number} or branch {$po->branch_id}."
                );
            }

            // Prevent double invoicing of the same goods receipt
            $alreadyInvoiced = ErpSupplierInvoice::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('goods_receipt_id', $gr->id)
                ->exists();
            if ($alreadyInvoiced) {
                throw new InvalidArgumentException("Goods receipt {$gr->receipt_number} has already been invoiced.");
            }

            // Prevent duplicate invoice number for the same supplier
            $duplicateInvoice = ErpSupplierInvoice::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('supplier_id', $po->supplier_id)
                ->where('invoice_number', $invoiceNumber)
                ->exists();
            if ($duplicateInvoice) {
                throw new InvalidArgumentException("Invoice number '{$invoiceNumber}' already exists for this supplier.");
            }

            // Calculate subtotal from received goods
            $subtotalMinor = 0;
            foreach ($gr->lines as $line) {
                $subtotalMinor += (int) round($line->quantity_received * $line->unit_cost_minor);
            }

            $tax = $taxMinor ?? 0;
            $totalMinor = $subtotalMinor + $tax;

            // Create balanced journal entry
            $journalNumber = 'JRN-INV-' . date('Ymd') . '-' . strtoupper(Str::random(4));
            $period = substr($invoiceDate, 0, 7); // e.g. 2026-11

            $journal = ErpJournal::create([
                'tenant_id' => $context->getTenantId(),
                'branch_id' => $po->branch_id,
                'journal_number' => $journalNumber,
                'period' => $period,
                'description' => "Supplier Invoice {$invoiceNumber} for PO {$po->po_number}",
                'posted_at' => now(),
            ]);

            $inventoryAccount = ErpAccount::firstOrCreate(
                ['tenant_id' => $context->getTenantId(), 'code' => '1050'],
                ['name_en' => 'Raw Inventory', 'name_ar' => 'مخزون المواد الأولية', 'type' => 'asset', 'currency' => 'AED']
            );

            $apAccount = ErpAccount::firstOrCreate(
                ['tenant_id' => $context->getTenantId(), 'code' => '2010'],
                ['name_en' => 'Accounts Payable - Suppliers', 'name_ar' => 'ذمم دائنة - موردين', 'type' => 'liability', 'currency' => 'AED']
            );

            // Debit Inventory Asset
            ErpJournalLine::create([
                'journal_id' => $journal->id,
                'account_id' => $inventoryAccount->id,
                'debit_minor' => $totalMinor,
                'credit_minor' => 0,
                'memo' => "Received stock valuation for {$po->po_number}",
            ]);

            // Credit Accounts Payable
            ErpJournalLine::create([
                'journal_id' => $journal->id,
                'account_id' => $apAccount->id,
                'debit_minor' => 0,
                'credit_minor' => $totalMinor,
                'memo' => "Supplier liability {$po->supplier->name}",
            ]);

            // Invariant check: Debit === Credit
            $totalDebit = $journal->lines()->sum('debit_minor');
            $totalCredit = $journal->lines()->sum('credit_minor');
            if ($totalDebit !== $totalCredit) {
                throw new RuntimeException("Accounting invariant failure: Debit ({$totalDebit}) != Credit ({$totalCredit})");
            }

            $invoice = ErpSupplierInvoice::create([
                'tenant_id' => $context->getTenantId(),
                'supplier_id' => $po->supplier_id,
                'po_id' => $po->id,
                'goods_receipt_id' => $gr->id,
                'invoice_number' => $invoiceNumber,
                'invoice_date' => $invoiceDate,
                'subtotal_minor' => $subtotalMinor,
                'tax_minor' => $tax,
                'total_minor' => $totalMinor,
                'currency' => 'AED',
                'status' => 'posted',
                'posted_journal_id' => $journal->id,
            ]);

            return $invoice->load(['supplier', 'journal.lines']);
        });
    }
}
