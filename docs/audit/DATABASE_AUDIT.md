# Database Audit

## Existing schema

The database is a single-tenant, single-catalog relational model: users/roles, branches/tables, categories/products/options, customers/vehicles, orders/items/options/status history, banners/offers/settings, Sanctum tokens, sessions/cache/jobs. Foreign keys are generally present. Orders require a branch and snapshot item prices but product deletions cascade through historical order items (`create_order_items_table.php:16-17`), which is unsuitable for financial retention.

## Findings

| ID | Severity | Reference | Root cause / impact | Recommendation / tests / compatibility |
|---|---|---|---|---|
| DB-001 | Critical | `database/seed_data.sql:31-229`, `restore_dashboard_data.sql:169-171` | Operational exports with PII, hashes and tokens are tracked. Privacy and credential exposure. | Incident response and sanitized fixtures; CI PII/secret scans. History rewrite needs owner approval; see SEC-009. |
| DB-002 | High | `create_orders_table.php:17`; branch/table migrations | No `tenant_id`; user/customer assignment to branch absent. Future SaaS isolation cannot be enforced. | Add nullable tenant spine in additive migrations, backfill/validate, then enforce. Tests for tenant/branch isolation. |
| DB-003 | High | `create_order_items_table.php:17` | `cascadeOnDelete` product destroys historical sale lines. | Restrict/soft-delete products; retain snapshots. Test product retirement preserves invoices. Requires rehearsed FK migration. |
| DB-004 | High | orders decimal columns; controllers | Decimal math is converted to floats in PHP. Rounding and reconciliation drift risk. | Domain minor units or decimal value object; boundary/rounding tests. Preserve legacy columns during dual-write. |
| DB-005 | High | orders `status`, `payment_status`, `order_type` strings | No DB/state-transition constraints. Invalid values can enter through future code/import SQL. | Application enums + transition service; optional check constraints after data audit. |
| DB-006 | High | `customers.phone` nullable/non-unique | Multiple identities and ambiguous login lookup. | Normalized E.164 unique index after dedupe; compatibility migration. |
| DB-007 | Medium | `vehicles.plate_number` plain/global | Vehicle is not owned by customer or tenant; collisions/privacy ambiguity. | tenant/customer link and normalized composite uniqueness; migration tests. |
| DB-008 | Medium | `orders.session_id` nullable/no index; no payment table | Idempotency and provider references are stored in `notes`. | Add payment attempts/events with unique provider IDs and idempotency keys. |
| DB-009 | Medium | status history schema | `user_id` has no FK and history is unused. | Actor polymorphism or staff FK, from/to/reason timestamps, append-only controls. |
| DB-010 | Medium | `Setting::get()` runtime DDL | Model can create schema during requests, bypassing migrations/least privilege. | Remove runtime DDL after verified migration; test read-only DB user behavior. |
| DB-011 | Medium | broad `cascadeOnDelete` relationships | Deleting branch/category/options can erase or invalidate history. | Retire master data, restrict deletes, immutable snapshots. |
| DB-012 | Medium | no inventory/accounting/audit tables | ERP traceability is absent. | Add append-only ledgers using the design in `docs/architecture/DATABASE_DESIGN.md`. |

## Migration safety strategy

Only forward, additive, backward-compatible migrations should be introduced initially: new ERP tables, nullable tenant/branch keys and indexes created with online-capable procedures. Use expand/backfill/validate/contract phases, database backups verified by restore rehearsal, row-count/checksum reconciliation and a documented rollback. Never run these against production from an AI agent or this branch.
