# Next Tasks

## P0 — Owner/security coordination (outside ordinary development)

- Triage SEC-001/002/003/005/008/009 with the owner/security/privacy team.
- Revoke tokens/rotate credentials and decide emergency route containment through approved production operations.
- Decide coordinated repository data cleanup/history rewrite; do not force-push from this branch.

## P1 — Isolated identity/tenancy/branch foundations (COMPLETED)

1. Add `erp_tenants`, ERP branch membership and additive permission records using SQLite-only tests: **Complete**.
2. Add repository interfaces/implementations that require tenant context: **Complete** (`TenantRepositoryInterface`, `BranchRepositoryInterface`, `StaffSessionRepositoryInterface`, `AuditLogger`).
3. Add staff session `/api/erp/v1/session` behind a disabled-by-default ERP route group: **Complete** (protected by `EnsureErpEnabled`, `ErpRequestId`, `ErpStaffSession`).
4. Add allow-list permissions, branch policy and explicit audited tenant-admin override: **Complete** (`BranchAccessService`, `PermissionService`, `erp_audit_logs`).
5. Add API tests for unauthenticated, wrong tenant, wrong branch, allowed branch and mobile `/api/v1` route snapshot: **Complete** (25 tests, 97 assertions).
6. Replace frontend demo identity through an adapter that retains demo mode without pretending it is live: **Complete** (`sessionAdapter.ts` + tests).

## P2 — Catalog / purchasing / sales operational cycle (COMPLETED)

1. Branch-scoped product catalog, versioned recipes BOM and preparation station routing: **Complete**.
2. Vetted suppliers, purchase orders, partial & full goods receipt with over-receiving prevention, and supplier invoices: **Complete**.
3. POS quote calculator with 5% VAT in minor units (UAE fils), guest checkout, and registered customer loyalty: **Complete**.
4. Atomic cash checkout with `Idempotency-Key` duplicate protection, pre-flight stock verification (preventing negative inventory), append-only stock deduction, and balanced double-entry journals: **Complete**.
5. Real-time Kitchen Display System (KDS) state machine (`new` -> `preparing` -> `ready` -> `completed`) with persistent elapsed timers: **Complete**.
6. Desktop ERP UI modules for Products, Suppliers, Customers, POS, KDS, Inventory, Accounting, Employees, Reports with live API connectivity and demo fallback: **Complete**.
7. Full operational cycle acceptance test suite (`tests/Feature/ERP/OperationalCycleAcceptanceTest.php`, 6 tests, 203 assertions): **Complete**.
8. Branch-scoped inventory balances decoupling (`erp_inventory_balances`) with atomic SQL conditional decrements: **Complete**.
9. Multi-action persistent idempotency ledger (`erp_idempotency_keys`) with SHA-256 fingerprinting, replay caching, and 409 Conflict rejection: **Complete**.
10. Strict 3-way match invoice validation and cross-branch isolation test suite (`BranchIsolationAndIdempotencyTest.php`, 4 tests, 32 assertions): **Complete**.

## P3 — Payment gateways sandbox, hardware printers & production preparation (NEXT)

1. Payment Provider Webhook/Sandbox Adapter (Stripe Terminal / Network International) with provider-verified matching.
2. ESC/POS hardware receipt and kitchen order ticket printer driver integration.
3. Multi-currency support and FTA electronic VAT return export format validation.
4. Coordinated staging rehearsal with owner-authorized data migration.
