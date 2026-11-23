# Security Audit

Severity scale: Critical = immediate compromise/material financial risk; High = likely unauthorized access or major integrity loss; Medium = meaningful weakness requiring planned remediation; Low = defense-in-depth.

## SEC-001 — Customer account takeover by optional password

- **Severity:** Critical
- **References:** `backend/app/Http/Controllers/Api/CustomerAuthController.php:13-50`; `backend/app/Models/Customer.php:12-17`; `frontend/lib/screens/phone_auth_screen.dart:74-83,229-243`
- **Root cause:** Existing customers are authenticated when no password is supplied. Password verification runs only when both stored and submitted passwords exist. New-customer mass assignment omits `password` from `$fillable`, so the supplied hash is normally discarded. Phone ownership is never verified although OTP columns exist.
- **Reproduction:** POST `/api/v1/auth/login` with a known phone and any name, omit password; observe a new all-abilities Sanctum token. For a new phone, submit a password, then inspect that the model fillable policy does not persist it.
- **Business impact:** Full access to customer order history, loyalty, account deletion and any Sanctum-protected customer endpoint; enables payment-key attack in SEC-002.
- **Recommended solution:** Introduce verified OTP or password challenge, normalized unique E.164 phones, rate limiting, token expiry/revocation and a mobile migration flow. Do not change the live endpoint until legacy-client compatibility and staged rollout are approved.
- **Tests:** existing customer without challenge rejected; OTP expiry/replay/rate-limit; password hash persistence; token scopes/expiry; legacy app upgrade path.
- **Production compatibility:** Requires versioned auth behavior or feature-flagged transition because the current Flutter screen treats password as optional.

## SEC-002 — Any customer token can overwrite Stripe keys

- **Severity:** Critical
- **References:** `backend/routes/api.php:31`; `backend/app/Http/Controllers/Api/PaymentController.php:398-432`
- **Root cause:** `/stripe/update-keys` requires only `auth:sanctum`; customer tokens have `*` abilities. The controller writes attacker-controlled values directly into `.env` and returns configuration metadata.
- **Reproduction:** Obtain a customer token through SEC-001, POST arbitrary `publishable_key` and `secret_key`, then observe the application environment file is rewritten.
- **Business impact:** Payment diversion/outage, credential destruction, possible environment-file injection and persistent production compromise.
- **Recommended solution:** Remove the public/mobile route; manage secrets out-of-band in the hosting secret store; enforce a narrowly scoped audited administrative workflow with re-authentication. Rotate Stripe keys after containment.
- **Tests:** customer/branch staff denied; `.env` immutable at runtime; secret values never returned/logged; admin workflow uses secret manager.
- **Production compatibility:** Emergency owner-approved remediation is warranted but must coordinate mobile behavior and deployment configuration.

## SEC-003 — Stripe return query marks an order paid without provider verification

- **Severity:** Critical
- **References:** `backend/app/Http/Controllers/Api/PaymentController.php:258-300`; `backend/routes/api.php:37`
- **Root cause:** `status=success` is trusted. Order lookup accepts supplied order number, a notes substring, or the latest pending Stripe order; no Stripe API verification, webhook signature, amount, currency or metadata match occurs.
- **Reproduction:** Request `/api/v1/stripe/checkout-return?status=success&order_number=<pending order>` or omit the order to target the latest pending record.
- **Business impact:** Unpaid orders become paid and enter preparation; cross-customer order activation and direct revenue loss.
- **Recommended solution:** Make the return page read-only; transition payment state only from a signature-verified Stripe webhook or server retrieval matched to stored provider session, order, amount and currency under an idempotent transaction.
- **Tests:** forged return rejected/no mutation; wrong session/order/amount/currency rejected; replay idempotent; valid signed webhook transitions once.
- **Production compatibility:** Preserve the return-page URL/UX but remove mutation only after webhook readiness and monitored staging rollout.

## SEC-004 — Client-controlled payment amounts and false success simulators

- **Severity:** Critical
- **References:** `PaymentController.php:438-451,509-528,572-579,585-646,652-709`; `OrderController.php:88-90`
- **Root cause:** Payment endpoints charge the request `amount`, do not bind intents to a server-priced order, return successful mock IDs when configuration is absent/fails, and checkout trusts a client `payment_method`/`payment_reference` to label non-cash orders paid.
- **Reproduction:** Create a payment intent for AED 1 while constructing a higher-value order; call wallet/card endpoints with missing configuration; submit checkout with a non-cash method and arbitrary reference.
- **Business impact:** Underpayment, unpaid orders recorded as paid, reconciliation failure and fake payment references.
- **Recommended solution:** Create immutable server-side payment attempts from priced orders; accept only provider tokens; verify final amount/currency/status; prohibit simulators outside a guarded local/test environment.
- **Tests:** amount tampering, fake reference, missing config, duplicate attempt, provider failure and successful exact-match cases.
- **Production compatibility:** Introduce a versioned payment flow and retain old responses during a tightly bounded client upgrade window.

## SEC-005 — Raw cardholder data handled by Laravel server

- **Severity:** Critical
- **References:** `PaymentController.php:438-496`
- **Root cause:** PAN, expiry and CVC are submitted to the application and forwarded to Stripe. This expands PCI DSS scope and risks sensitive authentication data reaching logs, tracing, proxies or error tooling.
- **Reproduction:** Inspect request schema and live-mode Stripe payment-method creation.
- **Business impact:** Severe compliance, breach and contractual exposure.
- **Recommended solution:** Remove raw-card endpoint; use Stripe-hosted Checkout or official client-side SDK/Elements so the server receives only a provider token. Conduct PCI incident/compliance review.
- **Tests:** server endpoints reject PAN/CVC fields; log scrub tests; integration uses Stripe test tokens only.
- **Production compatibility:** Coordinate mobile release before removing the old route; never test with live cards.

## SEC-006 — Public guessable order status and receipts expose data

- **Severity:** High
- **References:** `backend/routes/api.php:40`; `backend/routes/web.php:22-24`; `OrderController.php:154-170`; `OperationsController.php:97-104`; `resources/views/operations/receipt.blade.php:85-163`
- **Root cause:** Four-digit order numbers are used as bearer identifiers. Status returns the complete order graph; receipts accept order number or numeric database ID and expose vehicle plate, line items and totals.
- **Reproduction:** Enumerate `#NE1000`–`#NE9999` or `/receipt/1` and observe successful records.
- **Business impact:** Customer/order/vehicle disclosure and operational intelligence leakage.
- **Recommended solution:** Require authenticated ownership or signed, expiring, high-entropy receipt links; return a minimal status DTO; rate-limit enumeration.
- **Tests:** anonymous enumeration denied; signed URL expiry/tamper; owner can access only own order; response field allow-list.
- **Production compatibility:** QR/receipt links require a dual-link transition and regenerated future receipts.

## SEC-007 — Weak role checks and no branch authorization

- **Severity:** High
- **References:** `backend/app/Http/Middleware/AdminOnlyMiddleware.php:14-22`; `backend/routes/web.php:35-75`; `OperationsController.php:12-87`; `RolesAndPermissionsSeeder.php:21-26`
- **Root cause:** Manager access blocks only Cashier and Barista; any authenticated user without those roles is allowed. Roles have no permissions. Operations queries and mutations span all branches.
- **Reproduction:** Authenticate a staff user with no role or `Handover`, access `/manager`; authenticate any operations user and query/update another branch's order ID.
- **Business impact:** Unauthorized catalog/report/backup changes and cross-branch data access.
- **Recommended solution:** Allow-list permissions through policies, require branch assignment in every query/command, deny by default, and record privileged actions.
- **Tests:** role/permission matrix; unassigned branch denial; global admin explicit override; IDOR mutation tests.
- **Production compatibility:** Inventory current users/roles before enforcement to prevent lockout.

## SEC-008 — Arbitrary SQL execution through catalog restore

- **Severity:** Critical
- **References:** `ManagerController.php:829-847`; `backend/routes/web.php:73`
- **Root cause:** An uploaded file of any type is passed to `DB::unprepared` with no parser, statement allow-list, signature, size limit or transaction boundary.
- **Reproduction:** As any manager-allowed account, upload SQL containing destructive or privilege-changing statements.
- **Business impact:** Complete database compromise, data destruction/exfiltration and persistent application takeover.
- **Recommended solution:** Disable the endpoint; replace it with validated, schema-versioned JSON/CSV import jobs in an isolated database transaction with dry-run and approval. Database backups belong to infrastructure tooling.
- **Tests:** reject SQL/executable content, oversize files and unauthorized roles; verify atomic dry-run and audit record.
- **Production compatibility:** Disabling requires explicit owner approval; provide a safe operational backup procedure first.

## SEC-009 — Sensitive production-like data and token hashes committed to Git

- **Severity:** Critical
- **References:** `backend/database/seed_data.sql:31-33,143-178,228-229`; `backend/database/restore_dashboard_data.sql:169-171`; additional order rows in those dumps
- **Root cause:** Database exports were committed as seed/restore material. They include customer names and phone numbers, vehicle data, password hashes, payment/order references and Sanctum token hashes.
- **Reproduction:** Clone the repository and inspect the SQL files/history.
- **Business impact:** Privacy breach, offline password attack, operational exposure and possible token risk if hashes/related secrets remain usable.
- **Recommended solution:** Treat as an incident: revoke all tokens, rotate default/staff credentials and affected provider secrets, determine repository access scope, notify privacy/security owners, create sanitized deterministic fixtures, then remove data from current tree and history using an owner-approved coordinated rewrite.
- **Tests:** secret/PII scanning in CI; sanitized fixture validation; no production exports in repository.
- **Production compatibility:** History rewrite/force push is explicitly prohibited without owner approval and coordination; this branch only documents the finding.

## SEC-010 — Default seeded staff credentials

- **Severity:** High
- **References:** `backend/database/seeders/DatabaseSeeder.php:23-42`; `backend/database/seeders/AdminSeeder.php:17-22`
- **Root cause:** Predictable email/password combinations are hard-coded; SQL dumps contain corresponding staff hashes.
- **Reproduction:** Run seeders in an exposed environment or attempt documented defaults against an unchanged deployment.
- **Business impact:** Administrative/operations account compromise.
- **Recommended solution:** Development-only factories using generated one-time credentials, environment guard, forced reset and production seed prohibition; rotate existing users immediately.
- **Tests:** production environment refuses demo seeder; generated secrets not logged; first-login reset.
- **Production compatibility:** Credential rotation requires owner-controlled communication and recovery plan.

## SEC-011 — Public broadcast channel and over-broad event payload

- **Severity:** High
- **References:** `backend/app/Events/OrderCreated.php:12-35`; `OrderStatusUpdated.php:12-35`; `backend/routes/channels.php:3-7`
- **Root cause:** Order events broadcast on public `Channel('orders')`; no branch/tenant channel authorization exists and the public model is serialized.
- **Reproduction:** Connect to configured broadcaster and subscribe to `orders` without channel authorization.
- **Business impact:** Real-time order information leakage across users/branches.
- **Recommended solution:** Use private tenant/branch channels, authorized memberships and minimal event DTOs with no PII.
- **Tests:** unauthenticated/wrong-branch subscription denied; payload allow-list; revoked membership disconnect behavior.
- **Production compatibility:** Existing dashboard listener must support a transition channel before cutover.

## SEC-012 — Modifier/branch relationships not validated during pricing

- **Severity:** High
- **References:** `OrderController.php:33-47,97-129`; `PaymentController.php:49-81,156-189`; `OrderController.php:72-74`
- **Root cause:** Any option ID can be attached to any product, including unavailable options; table and branch are independently accepted/defaulted, so a table can belong to a different branch. Product availability is not enforced.
- **Reproduction:** Submit an option belonging to an unrelated group/product or pair a table from branch A with branch B.
- **Business impact:** Price manipulation, impossible kitchen tickets, reporting contamination and cross-branch records.
- **Recommended solution:** Server-side catalog aggregate validation: product/branch availability, allowed modifier groups, min/max selections, table-branch match and immutable price snapshots.
- **Tests:** unrelated/disabled modifier rejected; unavailable product rejected; table/branch mismatch rejected; concurrent catalog change snapshots correctly.
- **Production compatibility:** Validate against observed mobile payloads and stage warning telemetry before strict rejection.

## Required immediate owner actions

1. Treat SEC-002, SEC-003, SEC-005, SEC-008 and SEC-009 as incident-level findings.
2. Revoke Sanctum tokens and rotate Stripe/staff credentials through approved production channels.
3. Disable or firewall key update and SQL import routes after business-owner approval.
4. Preserve forensic evidence; do not rewrite Git history until access scope and coordination are complete.
5. Build an authorized staging clone for remediation and mobile compatibility testing.
