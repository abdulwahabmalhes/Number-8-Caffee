# NUMBER EIGHT Repository Audit

Audit date: 2026-11-23 (Asia/Dubai)

Baseline: `main` at `b083fc60cb3032707bed52474b501ea08ad9539e`

Working branch: `feature/restaurant-erp-foundation`

## Safety boundary

This audit was performed from a fresh clone. No production host, database, payment service, deployment, environment file, Blade view, Flutter source, or existing API contract was changed. The repository has no tracked `.env`. Tests use SQLite in memory. Existing defects are documented, not silently repaired.

## What the system currently does

NUMBER EIGHT is a Laravel 12 backend plus Flutter customer application and two server-rendered operations surfaces. The Flutter client calls `https://no8.ae/api/v1` by default (`frontend/lib/core/api_client.dart:7-52`) for menu, QR/table resolution, offers/coupons, customer token login, checkout, Stripe payment, order tracking, account deletion and loyalty history. Laravel also serves:

- authenticated operations dashboard, order status changes, car arrival, receipt and sticker printing;
- manager dashboard, product/options/table/offer management, reporting and catalog SQL backup/restore;
- Filament order administration;
- public privacy/support pages, public receipts and invoices;
- public `orders` broadcast channel using Reverb-compatible events.

## Implementation map

| Area | Actual implementation | Audit conclusion |
|---|---|---|
| Customer identity | Sanctum tokens issued by phone/name/password login | Critical account takeover path; see SEC-001 |
| Staff identity | Laravel session auth + Spatie roles | Roles exist but permission records are not defined; manager middleware is deny-list based |
| Catalog | Category/product/option models and manager CRUD | Shared globally; no branch-specific availability/pricing |
| Ordering | `OrderController`, `PaymentController`, DB transaction | Server reloads base prices, but modifier ownership/availability and payment truth are unsafe |
| Payments | Direct Stripe HTTP calls, hosted checkout and simulators | Multiple critical integrity/PCI/idempotency failures |
| Operations/KDS | Blade dashboard with polling/live feed and receipt/sticker views | All-branch queries; status history model is not written |
| Broadcasting | `OrderCreated`, `OrderStatusUpdated` on public channel `orders` | Event payload is an Eloquent order; channel is not tenant/branch isolated |
| Loyalty | Count of paid customer orders plus configurable target | No immutable loyalty ledger; susceptible to payment/order integrity faults |
| QR ordering | table tokens and `/scan-qr` | Token uniqueness exists; table/branch authorization is not coupled to order branch |
| Car pickup | vehicle records and arrival timestamp | Plate number is global and not tied to customer/tenant |
| Reporting | collection-based daily/monthly calculations | Loads broad datasets; VAT presentation conflicts with stored tax values |
| Printing | browser-rendered 80mm receipt and 50mm sticker | No printer protocol/queue/retry/audit; public receipt exposure |
| Tests | two Laravel example tests and one Flutter widget test | No meaningful production regression/security coverage |
| Deployment | Laravel/Vite/Reverb configuration and compiled Flutter web in `public/app` | Assumes a single deployed Laravel application and database |

## Code quality and operational observations

- Domain logic is concentrated in controllers; there are no application services, repositories, policies, DTOs, idempotency records or audit logger.
- Most commerce models use `protected $guarded = []`, increasing mass-assignment risk if controller patterns evolve.
- `Setting::get()` can create the settings table at runtime (`backend/app/Models/Setting.php:52-74`), bypassing migration discipline.
- Order creation catches and suppresses broadcast failures (`OrderController.php:132-137`); payment paths also suppress verification/broadcast exceptions.
- Events implement `ShouldBroadcast` while the default broadcast connection is `null`; live behavior depends entirely on deployment environment.
- Queue jobs default to the database driver, with `after_commit` false (`backend/config/queue.php:38-45`). No project-specific jobs, retry policy or monitoring exists.
- The existing mobile app is a direct consumer of response shapes and status strings. It stores bearer tokens in `SharedPreferences`, not a platform secure store (`frontend/lib/providers/auth_provider.dart:39-74`).
- Committed SQL dumps are data exports, not deterministic fixtures, and include sensitive operational records. See SEC-009.

## Production compatibility rule

The new ERP uses the additive namespace `/api/erp/v1` and additive `app/ERP` code. Existing `/api/v1`, Flutter, Blade, database migrations and production UI remain unchanged. Any remediation of existing findings must be released independently behind contract tests, migration rehearsal, owner approval and rollback planning.

## Audit limits

No production environment, server configuration, database contents, Stripe dashboard, DNS, TLS, App Store build, Reverb process or third-party delivery platform account was accessed. Flutter tooling is unavailable on the audit host. Findings describe repository behavior and must be confirmed against an authorized staging clone before production remediation.
