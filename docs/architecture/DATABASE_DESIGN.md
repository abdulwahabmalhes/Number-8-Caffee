# ERP Database Design

## Design rules

1. Every ERP business row carries `tenant_id`; branch-owned rows also carry `branch_id`.
2. Money uses integer minor units plus ISO currency; quantities use fixed precision and UOM.
3. Ledgers are append-only. Corrections create reversing entries, never destructive edits.
4. Human references are separate from UUID/ULID primary identifiers.
5. Provider payloads are encrypted/redacted and retained according to policy.
6. `created_by`, `updated_by`, source and correlation IDs support traceability.

## Proposed bounded tables

| Domain | Tables (initial) | Key constraints |
|---|---|---|
| Tenancy | `erp_tenants`, `erp_branches`, `erp_user_branch` | unique tenant slug; unique membership |
| Access | existing users + ERP permissions, `erp_approval_requests` | deny-by-default roles; scoped approvals |
| POS | `erp_shifts`, `erp_cash_drawer_sessions`, `erp_orders`, `erp_order_lines`, `erp_order_line_modifiers`, `erp_tenders` | unique idempotency/order ref; immutable snapshots |
| Payments | `erp_payment_attempts`, `erp_payment_events`, `erp_refunds` | unique provider+external ID; state constraints |
| Kitchen | `erp_kitchen_tickets`, `erp_ticket_items`, `erp_stations`, `erp_station_assignments` | order-line linkage; transition timestamps |
| Inventory | `erp_inventory_items`, `erp_uoms`, `erp_uom_conversions`, `erp_stock_locations`, `erp_stock_movements`, `erp_stock_counts` | idempotency key; signed quantity; no updates to movements |
| Recipes | `erp_recipes`, `erp_recipe_versions`, `erp_recipe_lines` | one active version; effective dates |
| Purchasing | `erp_suppliers`, `erp_purchase_orders`, `erp_po_lines`, `erp_goods_receipts`, `erp_supplier_invoices` | document sequence; three-way match refs |
| Accounting | `erp_accounts`, `erp_journals`, `erp_journal_lines`, `erp_periods`, `erp_tax_codes` | debit=credit per currency; closed-period guard |
| CRM | `erp_customer_profiles`, `erp_loyalty_ledger`, `erp_segments` | points append-only; consent metadata |
| Integration | `erp_external_accounts`, `erp_external_orders`, `erp_webhook_receipts`, `erp_outbox` | unique delivery/provider event IDs |
| Governance | `erp_audit_log`, `erp_idempotency_keys` | append-only hash/correlation; request hash uniqueness |

## Core transaction examples

- **Sale completion:** lock order; confirm tenders equal total; post revenue/VAT/cash journal; append recipe stock movements; close order; write audit/outbox atomically.
- **Goods receipt:** lock PO remaining quantities; append receipt and stock movements; update received projection; publish event.
- **Refund:** create refund tender, reversal journal and stock disposition decision linked to original documents.

## Migration from legacy

Do not rename or repurpose legacy tables. Create ERP tables alongside them. Import/reference legacy orders through an anti-corruption layer using `legacy_order_id` mappings. Begin read-only, reconcile counts/totals, then selectively dual-write behind a feature flag. No production migration is included.
