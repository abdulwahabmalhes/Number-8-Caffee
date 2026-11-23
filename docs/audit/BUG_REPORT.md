# Bug Report

Security defects are detailed in `SECURITY_AUDIT.md`; identifiers below are functional/data defects.

## BUG-001 — New customer passwords are not mass assignable

- **Severity:** Critical
- **Reference:** `backend/app/Models/Customer.php:12-17`; `CustomerAuthController.php:42-46`
- **Root cause:** `password` is missing from `$fillable`.
- **Reproduction:** Register a new phone with password and inspect persisted row.
- **Business impact:** Password protection is silently absent; account takeover.
- **Recommended solution:** Add an explicit hashed cast/fillable field only as part of the versioned auth remediation.
- **Tests:** registration persists a hash, never plaintext; login challenge required.
- **Production compatibility:** Do not change alone; existing optional-password clients need migration.

## BUG-002 — Order numbers collide after at most 9,000 active values

- **Severity:** High
- **Reference:** `OrderController.php:86`; `PaymentController.php:138`; `create_orders_table.php:16`
- **Root cause:** `rand(1000,9999)` feeds a unique column without retry/collision handling.
- **Reproduction:** Stub the random generator or create an existing number then place another order returning the same value.
- **Business impact:** intermittent checkout 500s; payment session/order orphaning.
- **Recommended solution:** ULID/UUID internal ID plus human sequence scoped by tenant/branch/date; database-backed atomic allocation.
- **Tests:** parallel allocation and retry; uniqueness across branches/tenants.
- **Production compatibility:** Keep `order_number` response shape while expanding format after client display tests.

## BUG-003 — Paid status is inferred from any non-cash payment method

- **Severity:** Critical
- **Reference:** `OrderController.php:88-90`
- **Root cause:** ternary sets all non-cash methods to paid before provider verification.
- **Reproduction:** POST checkout with `payment_method=anything`.
- **Business impact:** unpaid orders enter financial and loyalty reports.
- **Recommended solution:** payment state machine driven by verified provider events/cash settlement.
- **Tests:** unsupported method rejected; pending until verification; refund transition.
- **Production compatibility:** Coordinate with current payment screen payloads.

## BUG-004 — VAT storage and receipt calculation disagree

- **Severity:** High
- **Reference:** `OrderController.php:91-93`; `PaymentController.php:150-152`; `receipt.blade.php:148-157`
- **Root cause:** orders store `tax_amount=0`, while the receipt derives VAT by dividing grand total by 1.05; table service fee is included without a clear taxable basis.
- **Reproduction:** Place an order and compare database `tax_amount` to rendered VAT.
- **Business impact:** inaccurate tax invoices and finance reports.
- **Recommended solution:** centralized minor-unit tax engine with explicit inclusive/exclusive configuration and immutable calculation breakdown.
- **Tests:** rounding, taxable service charge, refunds and invoice reconciliation.
- **Production compatibility:** Finance/legal sign-off and historical data policy required.

## BUG-005 — Status history table is unused

- **Severity:** Medium
- **Reference:** `create_order_status_histories_table.php:14-21`; `OperationsController.php:32-51`
- **Root cause:** status mutation updates only `orders`; no history record or actor is written. `OrderStatusUpdated` is never dispatched here.
- **Reproduction:** change an order status and query history.
- **Business impact:** no operational accountability, timing trail or dispute evidence.
- **Recommended solution:** transactional transition service writing actor, from/to state, reason and event via outbox.
- **Tests:** allowed transitions, history atomicity, actor attribution, replay.
- **Production compatibility:** additive table use is safe after migration rehearsal.

## BUG-006 — Branch and table can be inconsistent

- **Severity:** High
- **Reference:** `OrderController.php:23-24,72-74`; `PaymentController.php:122-135`
- **Root cause:** existence is checked independently, not table ownership.
- **Reproduction:** submit table from one branch with another branch ID.
- **Business impact:** kitchen routing and branch reporting errors.
- **Recommended solution:** validate the aggregate pair and derive branch from table for dine-in orders.
- **Tests:** mismatched pair rejected; car/takeaway explicit branch required.
- **Production compatibility:** measure current bad records before enforcing.

## BUG-007 — Payment failure leaves pending orders indefinitely

- **Severity:** Medium
- **Reference:** `PaymentController.php:140-154,223-244`
- **Root cause:** order/items are committed when Stripe returns a non-success response because a JSON response is returned from inside the transaction rather than throwing; no expiry job exists.
- **Reproduction:** make Stripe session creation fail and inspect retained `payment_pending` order.
- **Business impact:** table growth, confusing reconciliation and latest-pending fallback risk.
- **Recommended solution:** create a payment attempt first or throw/rollback; add explicit expiry/cleanup policy.
- **Tests:** provider failure rolls back or marks failed; expiry job idempotent.
- **Production compatibility:** retain audit records rather than hard-deleting payment attempts.

## BUG-008 — Existing example feature test asserts the wrong redirect behavior

- **Severity:** Low
- **Reference:** `backend/tests/Feature/ExampleTest.php:14-17`; `backend/routes/web.php:8-10`
- **Root cause:** `/` redirects to `/operations`, which redirects unauthenticated users; test expects HTTP 200.
- **Reproduction:** run the baseline suite after installing dependencies.
- **Business impact:** red CI obscures meaningful failures.
- **Recommended solution:** assert the intended redirect/login chain in a separate compatibility commit.
- **Tests:** guest redirect and authenticated operations access.
- **Production compatibility:** test-only; intentionally not changed in this foundation to avoid silently altering baseline behavior.
