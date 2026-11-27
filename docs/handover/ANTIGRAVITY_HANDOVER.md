# Antigravity Technical Handover

## Read order

1. `SECURITY_AUDIT.md` and `PRODUCTION_RISK_ASSESSMENT.md`
2. `REPOSITORY_AUDIT.md`, `DATABASE_AUDIT.md`, `API_COMPATIBILITY.md`
3. all `docs/architecture/*`
4. `IMPLEMENTATION_STATUS.md`, `NEXT_TASKS.md`, `KNOWN_ISSUES.md`, `TEST_RESULTS.md`

## Current product and live boundaries

NUMBER EIGHT runs a Laravel 12 backend, Flutter customer app, Blade operations/manager dashboards and Filament order admin. The Flutter app defaults to `https://no8.ae/api/v1`. Existing mobile APIs, Flutter source, Blade/CSS/JS, database migrations and `main` are production-sensitive and were not changed. Do not deploy, migrate production, alter credentials, rewrite history, merge or modify live UI without explicit owner approval.

## Existing architecture/data/API

The legacy model is branches/tables; category/product/options; customer/vehicle; orders/items/item options/status history; offers/settings; users/Spatie roles; Sanctum tokens. `/api/v1` consumers and response dependencies are enumerated in `API_COMPATIBILITY.md`. Operations and manager controllers query shared tables directly and have no tenant/branch policy layer.

## Critical findings

Optional-password account takeover; customer-authorized Stripe-key overwrite; forged Stripe return success; client-controlled payment amounts/fake simulators; raw PAN/CVC server handling; public receipt/status enumeration; weak staff roles/no branch scoping; arbitrary SQL import; sensitive data and token hashes in tracked SQL dumps; default credentials; public broadcast channel; option/table/branch validation gaps. Treat `SECURITY_AUDIT.md` as the source of truth.

## Changes made

- Created this branch from `main` commit `b083fc6`.
- Added audit, architecture, requirements, testing and handover documents.
- Added isolated `erp-desktop` React/TypeScript/Vite shell with routing, permission-aware navigation, API client, error boundary, locale/RTL context, demo dashboard, POS, inventory and module placeholders.
- Added original generated login art and copied the verified existing logo.
- Added pure Laravel ERP domain foundations for Money, pricing, provider-confirmed payment matching, balanced journals, stock movements and branch access; added application ports for audit, idempotency and delivery platforms.
- Completed P1 & P2: Full Operational Cycle:
  - Database schema and migrations (`erp_*` prefix) for Tenancy, Branches, Staff Users, Permissions, Audit Logs, Catalog Orders, Kitchen Tickets, Inventory & Accounting, Products & Recipe BOMs, Suppliers & Purchasing (PO, Goods Receipts, Supplier Invoices), and Isolated ERP Customers.
  - `DatabaseSafetyGuard`: strictly halts execution if the database connection is not local SQLite (`database/erp-development.sqlite`) or SQLite in-memory for testing.
  - `PurchasingService`: PO generation, partial and remaining receipt with append-only stock ledger movements, strict over-receiving prevention, and supplier invoice posting with balanced double-entry journals (Debit Inventory Asset 1050 / Credit Accounts Payable 2010).
  - `PosSaleService`: Server-side price & tax calculation in minor units (UAE fils, 5% VAT), atomic idempotent checkout, pre-flight recipe stock checks (throws `InsufficientStockException` on insufficient quantity), append-only recipe stock deduction, station ticket dispatch, and balanced sales journals (Debit Cash 1010 / Credit Revenue 4010 & VAT 2020).
  - `KitchenService`: State transitions (`new` -> `preparing` -> `ready` -> `completed`) with persistent elapsed timers and branch/station filtering.
  - `ProductsPage`, `SuppliersPage`, `CustomersPage` desktop ERP frontend interfaces added in `erp-desktop` with full bilingual English/Arabic RTL support, forms, dialogs, and live API connectivity with explicit demo mode fallback.
  - Test suites: 39 PHPUnit tests (345 assertions) and 11 Vitest tests (100% passing), verifying all acceptance criteria from `ANTIGRAVITY_ERP_OPERATIONS_PROMPT.md`, `ANTIGRAVITY_ERP_BRANCH_AND_DATA_PROMPT.md`, and `ANTIGRAVITY_ERP_FINAL_WIRING_PROMPT.md` (supplier read branch scoping, accounting period scoping, client-side retry idempotency, live screen wiring, branch-scoped balances, idempotency replay/conflict, 3-way match, atomic conditional decrements, cross-branch isolation).
- No legacy runtime file, Flutter app, or `/api/v1` contract was edited.

## New architecture

An additive Laravel modular monolith under `app/ERP` with `/api/erp/v1`, separate staff auth, tenant/branch policies, transactional outbox, append-only stock/accounting/payment ledgers and a desktop React client. Existing tables are accessed initially through an anti-corruption/read adapter. See `SYSTEM_ARCHITECTURE.md` and `MODULE_DEPENDENCIES.md`.

## Frontend structure

`erp-desktop/src/app` owns router/auth/error boundary; `layouts` shell; `components` shared primitives; `modules` pages; `services` API; `types` contracts; `i18n` locale/RTL; `styles` design system. All numbers are labeled demo data and no API is connected.

## Completed vs incomplete

Completed: architecture/audit; isolated shell; dashboard/POS/inventory demonstrations; RTL direction mechanism; typed API client; domain invariants/contracts; original asset; local tests/build/browser QA.

Incomplete by design: production identity, ERP APIs/migrations/persistence, all real workflows, KDS real-time, payments, printers, inventory ledger, recipes, purchasing, accounting persistence/reports, employees, CRM, delivery adapters and deployment. No delivery provider is claimed working.

## Migration strategy

Create new prefixed ERP tables additively; map legacy IDs; expand/backfill/validate/contract; use sanitized staging and reconciliations; no destructive down migrations. Legacy API/table behavior stays stable until contract tests and mobile rollout authorize change.

## Environment and commands

See `ENVIRONMENT_SETUP.md`. Backend needs PHP 8.2+, Composer and `ext-intl`; this workstation had `intl` disabled. Frontend needs Node 22.12+ recommended and npm. Required environment variable names are documented without values.

## Design assets

The verified logo and generated PNG live in `erp-desktop/public/assets`. Exact generation status/prompt is in `DESIGN_ASSETS.md`. No other imagery is claimed generated.

## Exact next task

P2: Catalog / pricing quote and order idempotency slice (branch-scoped availability, server-side quote calculator, minor-unit price snapshots, and idempotent order placement). Do not connect production or modify `/api/v1`.

## Phase acceptance criteria

- **Identity/tenancy:** cross-tenant and unassigned-branch requests are denied; explicit admin override audited; mobile API unchanged.
- **POS/payments:** authoritative quote, idempotent order and exact provider verification; no PAN/CVC; split tender/refund reconciliation.
- **KDS:** private branch/station events, allowed transitions, timers and polling fallback.
- **Inventory/recipes:** UOM-safe append-only movements, concurrent deduction, versioned recipes/cost rollup.
- **Purchasing/accounting:** traceable documents, three-way match, balanced journals, VAT/refunds, closed periods.
- **Workforce/CRM/integrations/analytics:** scoped consent/permissions, immutable ledgers, approved provider sandbox tests and reconciled KPI provenance.
- **Release:** security review, full tests, backup restore rehearsal, staged rollout and owner approval.
