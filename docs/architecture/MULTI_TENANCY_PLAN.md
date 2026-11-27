# Future SaaS Multi-Tenancy Plan

## Model

Start with shared database/shared schema and mandatory `tenant_id` on new ERP tables. This matches current scale while preserving a future path to tenant-per-database for regulated or large customers.

## Phases

1. Create tenant and membership tables; seed one tenant representing NUMBER EIGHT in staging.
2. Add nullable tenant keys to new ERP and selected legacy mapping tables only.
3. Backfill in batches, reconcile row counts/totals, then make ERP keys non-null.
4. Apply global query scopes plus explicit repository predicates and database composite indexes/unique keys beginning with tenant.
5. Add tenant-aware cache keys, queues, object paths, event channels, rate limits, exports and observability.
6. Test cross-tenant attacks and operational restore/export per tenant.

## Guardrails

Never accept tenant identity directly from request body. Resolve from authenticated membership/host and validate branch membership. Background jobs carry immutable tenant context. Super-admin cross-tenant support uses time-bound approval and full audit.

## Legacy compatibility

Legacy tables remain mapped to the single NUMBER EIGHT tenant. The Flutter app never needs a tenant field during this phase. No production backfill is authorized by these documents.
