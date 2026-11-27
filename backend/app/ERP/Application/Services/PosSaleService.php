<?php

namespace App\ERP\Application\Services;

use App\ERP\Application\Exceptions\InsufficientStockException;
use App\ERP\Application\Services\IdempotencyService;
use App\ERP\Domain\Tenancy\TenantContext;
use App\ERP\Infrastructure\Persistence\Models\ErpAccount;
use App\ERP\Infrastructure\Persistence\Models\ErpCustomer;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryBalance;
use App\ERP\Infrastructure\Persistence\Models\ErpInventoryItem;
use App\ERP\Infrastructure\Persistence\Models\ErpJournal;
use App\ERP\Infrastructure\Persistence\Models\ErpJournalLine;
use App\ERP\Infrastructure\Persistence\Models\ErpKitchenTicket;
use App\ERP\Infrastructure\Persistence\Models\ErpOrder;
use App\ERP\Infrastructure\Persistence\Models\ErpOrderLine;
use App\ERP\Infrastructure\Persistence\Models\ErpProduct;
use App\ERP\Infrastructure\Persistence\Models\ErpProductBranch;
use App\ERP\Infrastructure\Persistence\Models\ErpProductVariant;
use App\ERP\Infrastructure\Persistence\Models\ErpRecipe;
use App\ERP\Infrastructure\Persistence\Models\ErpStockMovement;
use App\ERP\Infrastructure\Persistence\Models\ErpTender;
use App\ERP\Infrastructure\Persistence\Models\ErpTicketItem;
use App\ERP\Infrastructure\Security\DatabaseSafetyGuard;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class PosSaleService
{
    private const VAT_RATE = 0.05; // UAE 5% VAT

    public function __construct(
        private readonly IdempotencyService $idempotencyService
    ) {
    }

    public function calculateQuote(TenantContext $context, int $branchId, array $items): array
    {
        $calculatedItems = [];
        $subtotalMinor = 0;

        foreach ($items as $item) {
            $product = ErpProduct::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('id', $item['product_id'])
                ->firstOrFail();

            $variant = null;
            if (!empty($item['variant_id'])) {
                $variant = ErpProductVariant::query()
                    ->where('product_id', $product->id)
                    ->where('id', $item['variant_id'])
                    ->firstOrFail();
            }

            // Check branch override
            $branchSetting = ErpProductBranch::query()
                ->where('tenant_id', $context->getTenantId())
                ->where('branch_id', $branchId)
                ->where('product_id', $product->id)
                ->where('variant_id', $variant?->id)
                ->first();

            $unitPriceMinor = $branchSetting?->price_override_minor 
                ?? $variant?->price_minor 
                ?? 0;

            $quantity = (int) ($item['quantity'] ?? 1);
            $lineSubtotal = $unitPriceMinor * $quantity;
            $lineTax = (int) round($lineSubtotal * self::VAT_RATE);
            $lineTotal = $lineSubtotal + $lineTax;

            $subtotalMinor += $lineSubtotal;

            $calculatedItems[] = [
                'product_id' => $product->id,
                'variant_id' => $variant?->id,
                'sku' => $product->sku,
                'name_en' => $product->name_en . ($variant ? " ({$variant->name_en})" : ''),
                'name_ar' => $product->name_ar . ($variant ? " ({$variant->name_ar})" : ''),
                'station_code' => $product->station_code,
                'quantity' => $quantity,
                'unit_price_minor' => $unitPriceMinor,
                'subtotal_minor' => $lineSubtotal,
                'tax_minor' => $lineTax,
                'total_minor' => $lineTotal,
                'selected_options' => $item['selected_options'] ?? [],
            ];
        }

        $taxMinor = (int) round($subtotalMinor * self::VAT_RATE);
        $totalMinor = $subtotalMinor + $taxMinor;

        return [
            'subtotal_minor' => $subtotalMinor,
            'tax_minor' => $taxMinor,
            'total_minor' => $totalMinor,
            'currency' => 'AED',
            'vat_rate' => self::VAT_RATE,
            'items' => $calculatedItems,
        ];
    }

    /**
     * Executes atomic, idempotent cash sale checkout:
     * - Enforces idempotency key
     * - Verifies sufficient recipe stock (prevents negative balance)
     * - Saves order and order lines with recipe snapshot
     * - Deducts inventory append-only
     * - Dispatches station kitchen tickets
     * - Posts balanced double-entry journal (Debit Cash 1010, Credit Revenue 4010 & VAT 2020)
     */
    public function checkoutCash(
        TenantContext $context,
        int $branchId,
        array $data,
        string $idempotencyKey,
        ?int $userId = null
    ): ErpOrder {
        DatabaseSafetyGuard::assertIsolatedLocalSqlite();

        $result = $this->idempotencyService->execute(
            tenantId: $context->getTenantId(),
            branchId: $branchId,
            actionType: 'pos_checkout',
            idempotencyKey: $idempotencyKey,
            requestPayload: $data,
            callback: function () use ($context, $branchId, $data, $idempotencyKey, $userId) {
                return DB::transaction(function () use ($context, $branchId, $data, $idempotencyKey, $userId) {
                    $quote = $this->calculateQuote($context, $branchId, $data['items']);
                    $customer = null;
                    if (!empty($data['customer_id'])) {
                        $customer = ErpCustomer::query()
                            ->where('tenant_id', $context->getTenantId())
                            ->where('id', $data['customer_id'])
                            ->first();
                    }

            // 2. Pre-flight recipe ingredient requirements and stock verification
            $ingredientRequirements = []; // [inventory_item_id => ['required' => float, 'item' => ErpInventoryItem]]
            $recipeSnapshots = [];

            foreach ($quote['items'] as $index => $itemData) {
                // Find active recipe for product and variant
                $recipe = ErpRecipe::query()
                    ->where('tenant_id', $context->getTenantId())
                    ->where('product_id', $itemData['product_id'])
                    ->where(function ($q) use ($itemData) {
                        $q->where('variant_id', $itemData['variant_id'])
                          ->orWhereNull('variant_id');
                    })
                    ->first();

                $activeVersion = $recipe?->activeVersion()->with('lines.item')->first();
                $snapshot = [];

                if ($activeVersion) {
                    foreach ($activeVersion->lines as $line) {
                        $needed = $line->quantity * $itemData['quantity'];
                        $itemId = $line->inventory_item_id;

                        if (!isset($ingredientRequirements[$itemId])) {
                            $invItem = ErpInventoryItem::query()
                                ->where('tenant_id', $context->getTenantId())
                                ->where('id', $itemId)
                                ->lockForUpdate()
                                ->firstOrFail();

                            $ingredientRequirements[$itemId] = [
                                'required' => 0.0,
                                'item' => $invItem,
                            ];
                        }

                        $ingredientRequirements[$itemId]['required'] += $needed;

                        $snapshot[] = [
                            'item_id' => $line->inventory_item_id,
                            'name_en' => $line->item->name_en,
                            'name_ar' => $line->item->name_ar,
                            'quantity' => $line->quantity,
                            'unit' => $line->unit,
                        ];
                    }
                }

                $recipeSnapshots[$index] = [
                    'version_id' => $activeVersion?->id,
                    'snapshot' => $snapshot,
                ];
            }

                    // Verify branch stock availability: prevent negative stock
                    foreach ($ingredientRequirements as $itemId => $req) {
                        /** @var ErpInventoryItem $invItem */
                        $invItem = $req['item'];
                        $required = $req['required'];

                        $branchBalance = ErpInventoryBalance::firstOrCreate(
                            [
                                'tenant_id' => $context->getTenantId(),
                                'branch_id' => $branchId,
                                'inventory_item_id' => $itemId,
                            ],
                            [
                                'current_quantity' => 0,
                                'reorder_threshold' => $invItem->reorder_threshold ?? 10,
                            ]
                        );

                        if ($branchBalance->current_quantity < $required) {
                            throw new InsufficientStockException(
                                "Cannot complete sale: Insufficient stock for '{$invItem->name_en}' at branch {$branchId} (Available: {$branchBalance->current_quantity} {$invItem->unit}, Required: {$required} {$invItem->unit})."
                            );
                        }
                    }

            // 3. Create Order
            $orderNumber = '#NE' . rand(10000, 99999);
            $order = ErpOrder::create([
                'tenant_id' => $context->getTenantId(),
                'branch_id' => $branchId,
                'customer_id' => $customer?->id,
                'guest_name' => $data['guest_name'] ?? ($customer ? null : 'Guest Customer'),
                'order_number' => $orderNumber,
                'idempotency_key' => $idempotencyKey,
                'order_type' => $data['order_type'] ?? 'dine_in',
                'status' => 'preparing',
                'notes' => $data['notes'] ?? null,
                'subtotal_minor' => $quote['subtotal_minor'],
                'tax_minor' => $quote['tax_minor'],
                'total_minor' => $quote['total_minor'],
                'currency' => 'AED',
                'created_by' => $userId,
            ]);

            // 4. Create Order Lines & Snapshot
            $stationItems = [];
            foreach ($quote['items'] as $index => $itemData) {
                $rs = $recipeSnapshots[$index];
                $orderLine = ErpOrderLine::create([
                    'order_id' => $order->id,
                    'product_id' => $itemData['product_id'],
                    'variant_id' => $itemData['variant_id'],
                    'recipe_version_id' => $rs['version_id'],
                    'sku' => $itemData['sku'],
                    'name_en' => $itemData['name_en'],
                    'name_ar' => $itemData['name_ar'],
                    'quantity' => $itemData['quantity'],
                    'unit_price_minor' => $itemData['unit_price_minor'],
                    'subtotal_minor' => $itemData['subtotal_minor'],
                    'tax_minor' => $itemData['tax_minor'],
                    'total_minor' => $itemData['total_minor'],
                    'selected_options' => $itemData['selected_options'],
                    'recipe_snapshot' => $rs['snapshot'],
                ]);

                $station = $itemData['station_code'] ?: 'HOT_BAR';
                $stationItems[$station][] = [
                    'order_line_id' => $orderLine->id,
                    'item_name' => $itemData['name_en'],
                    'quantity' => $itemData['quantity'],
                    'modifiers' => $itemData['selected_options'],
                ];
            }

            // 5. Create Tender (Cash payment recorded)
            ErpTender::create([
                'order_id' => $order->id,
                'payment_method' => 'cash',
                'amount_minor' => $quote['total_minor'],
                'currency' => 'AED',
                'reference' => 'CASH-POS-' . $order->id,
                'status' => 'captured',
            ]);

                    // 6. Deduct Inventory Movements Append-Only with Atomic DB level check
                    foreach ($ingredientRequirements as $itemId => $req) {
                        /** @var ErpInventoryItem $invItem */
                        $invItem = $req['item'];
                        $deductQty = $req['required'];

                        // Atomic conditional update on branch balance: guarantees non-negative balance
                        $affected = DB::table('erp_inventory_balances')
                            ->where('tenant_id', $context->getTenantId())
                            ->where('branch_id', $branchId)
                            ->where('inventory_item_id', $itemId)
                            ->where('current_quantity', '>=', $deductQty)
                            ->decrement('current_quantity', $deductQty, ['updated_at' => now()]);

                        if ($affected === 0) {
                            $avail = DB::table('erp_inventory_balances')
                                ->where('tenant_id', $context->getTenantId())
                                ->where('branch_id', $branchId)
                                ->where('inventory_item_id', $itemId)
                                ->value('current_quantity') ?? 0;

                            throw new InsufficientStockException(
                                "Cannot complete sale: Insufficient stock for '{$invItem->name_en}' at branch {$branchId} (Available: {$avail} {$invItem->unit}, Required: {$deductQty} {$invItem->unit})."
                            );
                        }

                        $branchBalance = ErpInventoryBalance::where('tenant_id', $context->getTenantId())
                            ->where('branch_id', $branchId)
                            ->where('inventory_item_id', $itemId)
                            ->first();

                        $newBalance = $branchBalance ? (float) $branchBalance->current_quantity : 0;

                        ErpStockMovement::create([
                            'tenant_id' => $context->getTenantId(),
                            'branch_id' => $branchId,
                            'inventory_item_id' => $invItem->id,
                            'idempotency_key' => 'SALE-MOV-' . $order->id . '-' . $itemId,
                            'quantity_change' => -$deductQty,
                            'balance_after' => $newBalance,
                            'reason' => 'sale',
                            'reference_type' => 'order',
                            'reference_id' => (string) $order->id,
                            'actor_id' => (string) ($userId ?: 'pos-cashier'),
                            'created_at' => now(),
                        ]);

                        $invItem->decrement('current_quantity', $deductQty);
                    }

            // 7. Dispatch Station Kitchen Tickets
            foreach ($stationItems as $stationCode => $items) {
                $ticket = ErpKitchenTicket::create([
                    'tenant_id' => $context->getTenantId(),
                    'branch_id' => $branchId,
                    'order_id' => $order->id,
                    'ticket_number' => 'K-' . rand(100, 999),
                    'station_code' => $stationCode,
                    'status' => 'new',
                    'notes' => $order->notes,
                ]);

                foreach ($items as $it) {
                    ErpTicketItem::create([
                        'ticket_id' => $ticket->id,
                        'order_line_id' => $it['order_line_id'],
                        'item_name' => $it['item_name'],
                        'quantity' => $it['quantity'],
                        'modifiers' => $it['modifiers'],
                        'status' => 'pending',
                    ]);
                }
            }

            // 8. Post Balanced Double-Entry Journal
            $journalNumber = 'JRN-SALE-' . date('Ymd') . '-' . strtoupper(Str::random(4));
            $period = date('Y-m');

            $journal = ErpJournal::create([
                'tenant_id' => $context->getTenantId(),
                'branch_id' => $branchId,
                'journal_number' => $journalNumber,
                'period' => $period,
                'description' => "Cash Sale Order {$order->order_number}",
                'posted_at' => now(),
                'created_by' => $userId,
            ]);

            $cashAccount = ErpAccount::firstOrCreate(
                ['tenant_id' => $context->getTenantId(), 'code' => '1010'],
                ['name_en' => 'Cash on Hand', 'name_ar' => 'النقد في الصندوق', 'type' => 'asset', 'currency' => 'AED']
            );

            $revenueAccount = ErpAccount::firstOrCreate(
                ['tenant_id' => $context->getTenantId(), 'code' => '4010'],
                ['name_en' => 'Beverage Revenue', 'name_ar' => 'إيرادات المشروبات', 'type' => 'revenue', 'currency' => 'AED']
            );

            $vatAccount = ErpAccount::firstOrCreate(
                ['tenant_id' => $context->getTenantId(), 'code' => '2020'],
                ['name_en' => 'VAT Output Tax (5%)', 'name_ar' => 'ضريبة القيمة المضافة المحصلة', 'type' => 'liability', 'currency' => 'AED']
            );

            // Debit: Cash on Hand (Total amount received)
            ErpJournalLine::create([
                'journal_id' => $journal->id,
                'account_id' => $cashAccount->id,
                'debit_minor' => $quote['total_minor'],
                'credit_minor' => 0,
                'memo' => "Cash received for {$order->order_number}",
            ]);

            // Credit: Revenue (Subtotal)
            ErpJournalLine::create([
                'journal_id' => $journal->id,
                'account_id' => $revenueAccount->id,
                'debit_minor' => 0,
                'credit_minor' => $quote['subtotal_minor'],
                'memo' => "Net sales for {$order->order_number}",
            ]);

            // Credit: VAT Output Tax (Tax amount)
            if ($quote['tax_minor'] > 0) {
                ErpJournalLine::create([
                    'journal_id' => $journal->id,
                    'account_id' => $vatAccount->id,
                    'debit_minor' => 0,
                    'credit_minor' => $quote['tax_minor'],
                    'memo' => "5% UAE VAT for {$order->order_number}",
                ]);
            }

            // Invariant assertion: Total Debits must equal Total Credits
            $debits = $journal->lines()->sum('debit_minor');
            $credits = $journal->lines()->sum('credit_minor');
            if ($debits !== $credits) {
                throw new RuntimeException("Sale journal imbalance: Debits ({$debits}) != Credits ({$credits})");
            }

            // 9. Update Customer Loyalty if customer provided
            if ($customer) {
                $pointsEarned = (int) floor($quote['total_minor'] / 1000); // 1 point per 10 AED
                $customer->increment('loyalty_points', $pointsEarned);
            }

                    return [
                        'code' => 201,
                        'body' => $order->id,
                        'resource_id' => $order->id,
                    ];
                });
            },
            userId: $userId
        );

        $orderId = (int) ($result['resource_id'] ?? $result['body']);
        $order = ErpOrder::query()
            ->where('tenant_id', $context->getTenantId())
            ->where('id', $orderId)
            ->firstOrFail()
            ->load(['lines', 'tenders', 'customer']);

        $order->wasRecentlyCreated = !($result['is_replay'] ?? false);
        return $order;
    }
}
