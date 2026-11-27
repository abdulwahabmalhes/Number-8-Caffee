# Test Results — 2026-11-23

Environment: Windows, PHP 8.2.12, Composer 2.9.5, Node 22.18.0, npm 10.9.3. Flutter unavailable. No production service/database/payment endpoint was used.

| Command | Result |
|---|---|
| `composer install --no-interaction --prefer-dist --ignore-platform-req=ext-intl` | Passed for local test tooling; not an acceptable production substitute |
| `php vendor/bin/phpunit tests/Unit/ERP --testdox` | Passed: 7 tests, 12 assertions |
| `php artisan test tests/Feature/ERP` | Passed: 13 tests, 63 assertions |
| `php artisan test tests/Feature/LegacyApi` | Passed: 5 tests, 22 assertions |
| `php artisan test tests/Feature/ERP/OperationalCycleAcceptanceTest.php` | Passed: 6 tests, 203 assertions (Full 6-step operational cycle) |
| `php artisan test tests/Feature/ERP/BranchIsolationAndIdempotencyTest.php` | Passed: 8 tests, 49 assertions (Branch-scoped balances, idempotency replay/conflict, 3-way match, cross-branch access, supplier show scoping, accounting period scoping, missing key rejection, POS race replay) |
| `php artisan test tests/Unit/ERP tests/Feature/ERP tests/Feature/LegacyApi` | Passed: 39 tests, 345 assertions |
| `npm run typecheck` (erp-desktop) | Passed: 0 TypeScript errors |
| `npm test` (erp-desktop) | Passed: 3 files, 11 tests |
| `npm run build` (erp-desktop) | Passed: JS 448.34 kB (131.89 kB gzip), CSS 25.77 kB (6.11 kB gzip) |
| Local HTTP preview | Passed: HTTP 200 at http://127.0.0.1:5173/ |
| Browser QA | Passed: Dashboard, POS, KDS, Products, Suppliers, Customers, Inventory, Accounting, Employees, Reports, full Arabic/English and RTL support |
| `flutter test` / `flutter analyze` | Not run: Flutter executable unavailable |

The test suite now covers:
1. Pure domain invariants (pricing, payment matching, branch access, stock movement, balanced double-entry journals).
2. Tenancy & branch isolation (unauthenticated 401, wrong tenant 403, unassigned branch 403, allowed branch 200, audited tenant-admin override, disabled ERP 404).
3. Deny-by-default and allow-list permission enforcement.
4. Legacy mobile `/api/v1` route and response contract snapshots (`loyalty/config`, `stripe/config`, `menu`, `offers`, `scan-qr`).
5. Complete 6-step operational cycle acceptance suite:
   - Step 1: Dubai manager defines supplier, product "Latte" with 2 variants, recipe (beans & milk) mapped to `HOT_BAR`, and demo customer.
   - Step 2: PO creation, partial receipt, remaining receipt, over-receiving prevention, and supplier invoice posting with balanced journal.
   - Step 3: Cash sale to registered customer, cash sale to guest, quote in fils, 5% VAT, recipe stock deduction, station ticket created, customer loyalty updated, balanced journal.
   - Step 4: Kitchen display status transitions `new` -> `preparing` -> `ready` -> `completed` with timestamps and persistence.
   - Step 5: Multi-tenant and branch isolation (Abu Dhabi cannot access Dubai), and idempotency key replay preventing duplicate orders, tickets, stock deductions, and journals.
   - Step 6: Insufficient stock failure (422) and atomic rollback with zero orphan artifacts.
6. Desktop UI testing:
   - Permission-aware shell rendering and explicit demo label.
   - Session adapter live and demo mode fallback.
   - Kitchen Display System (KDS) station routing and tickets.
   - Products & Recipes catalog management and recipe BOMs.
   - Suppliers & Purchasing orders and goods receipt.
   - Customers directory & purchase history.
   - Accounting general ledger and balanced double-entry validation.
   - Employees RBAC and branch access list.
   - Reports executive KPIs and sales reconciliation.
