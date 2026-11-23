# ERP Test Strategy

## Pyramid

- Pure domain tests: money, pricing, tax rounding, payment verification, state machines, UOM, stock and journals.
- Application tests: transactions, idempotency, policies, branch/tenant isolation, audit/outbox atomicity.
- API contract tests: `/api/erp/v1` schemas and frozen `/api/v1` mobile snapshots.
- Integration tests: Stripe test-mode webhooks, queue retries, Reverb private channels, printer adapter fakes and approved delivery sandboxes.
- UI tests: components/accessibility/RTL plus Playwright desktop workflows at 1920×1080, 1440×900 and 1366×768.
- Reconciliation tests: order=tenders, stock subledger, journal debits=credits, VAT invoice and reporting totals.

## Mandatory release cases

Authentication challenge/rate limit/session revocation; permission matrix; cross-tenant/branch IDOR; forged/replayed/wrong-amount payment; concurrent order number/idempotency; modifier/product availability; simultaneous stock deductions; transfer pair atomicity; unbalanced/closed-period journal; refunds/reversals; legacy API snapshot and Flutter smoke test.

All external payment tests use Stripe test keys and official test tokens. Never use live cards or production endpoints.
