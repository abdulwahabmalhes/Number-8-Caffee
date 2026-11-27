# Decision Log

| Date | Decision | Rationale | Consequence |
|---|---|---|---|
| 2026-11-23 | Preserve `main`; create required feature branch | Production safety | All work isolated |
| 2026-11-23 | Do not remediate legacy defects in this pass | Mobile/live compatibility and explicit instruction | Findings are documented; owner must prioritize fixes |
| 2026-11-23 | Laravel modular monolith | Existing stack and lower operational overhead | Strong internal boundaries required |
| 2026-11-23 | Separate React/TypeScript/Vite ERP | Desktop density, keyboard workflows and independent release cadence | Separate frontend toolchain |
| 2026-11-23 | Reserve `/api/erp/v1` | Prevent legacy mobile contract collision | Anti-corruption layer needed |
| 2026-11-23 | Shared-schema tenant spine for future SaaS | Practical migration path | Tenant key mandatory on new rows |
| 2026-11-23 | Minor-unit money and append-only ledgers | Determinism/reconciliation | Conversion at system boundaries |
| 2026-11-23 | Provider-confirmed payment state only | Prevent forgery | Webhook/idempotency architecture required |
| 2026-11-23 | No delivery-provider implementation | No approved API access/docs | Adapter contract only |
| 2026-11-23 | Local-only Site workflow; no publication | User prohibits deployment | Build artifact only |
| 2026-11-23 | Preserve generated artwork as PNG | Built-in generation succeeded; WebP converter unavailable | Optimize/convert before production |
| 2026-11-23 | Additive migrations for `erp_tenants`, `erp_branches`, `erp_tenant_users`, `erp_user_branch`, `erp_user_permissions`, `erp_audit_logs` | Tenant & branch isolation | Schema is isolated and non-breaking for legacy tables |
| 2026-11-23 | Audited tenant administrator override for branch access | Security compliance | Unassigned branch access by tenant admin is explicitly recorded in `erp_audit_logs` |
| 2026-11-23 | Frontend session adapter with explicit demo mode fallback | Safe desktop decoupling | Demo mode is explicitly labeled and retained when API is absent or disabled |
| 2026-11-26 | `DatabaseSafetyGuard` execution barrier | Zero production interference | Strictly prevents execution on any non-local SQLite connection |
| 2026-11-26 | Physical stock recognition on Goods Receipt, Liability on Invoice | Strict three-way match | Prevents double-counting inventory, prevents over-receiving (`received > ordered`), and posts balanced journals |
| 2026-11-26 | Recipe BOM snapshot on sales order lines | Historical record immutability | Preserves exact recipe lines and pricing at checkout so future catalog edits don't distort history |
| 2026-11-26 | Pre-flight recipe ingredient availability check | Negative stock prevention | Throws `InsufficientStockException` (HTTP 422) and executes atomic rollback if stock is insufficient |
| 2026-11-26 | Mandatory Idempotency-Key header on POS sales checkout | Duplicate transaction protection | Prevents duplicate orders, duplicate stock deductions, duplicate KDS tickets, and duplicate journals on network retry |
| 2026-11-26 | Decouple branch stock balances (`erp_inventory_balances`) from tenant catalog items | Branch-scoped physical stock isolation | Allows each branch to hold independent physical quantities while sharing item definitions. Updates use atomic conditional decrements (`current_quantity >= ?`) to guarantee zero negative stock |
| 2026-11-26 | Persistent Multi-Action Idempotency Ledger (`erp_idempotency_keys`) with SHA-256 Request Fingerprinting | Consistent replay & anti-tampering protection | Applied to `pos_checkout` and `goods_receipt`. Exact matches return cached responses; altered payloads with the same key are rejected with `409 Conflict` (`idempotency_conflict`) |
| 2026-11-26 | Strict Three-Way Match & Branch Verification on Supplier Invoicing | Prevent cross-branch and duplicate invoicing fraud | Validates that Goods Receipts strictly match the PO's branch and cannot be invoiced more than once, returning `goods_receipt_already_invoiced` on duplicates |
| 2026-11-27 | Scope Supplier show endpoint and accounting journals/balances by branch and period | Branch & Period Data Isolation | Restricts operational POs, receipts, and invoices on shared suppliers to the staff user's authorized branch; scopes journal queries, chart of accounts, and VAT reports by branch and period |
| 2026-11-27 | Persistent Idempotency-Key per intended user action in Desktop POS & Purchasing UI | Client-side Retry Safety | Preserves the same idempotency key across client retries of the same intended checkout or goods receipt until confirmed by the server, generating fresh keys only on new actions |
