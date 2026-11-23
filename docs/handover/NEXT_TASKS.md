# Next Tasks

## P0 — Owner/security coordination (outside ordinary development)

- Triage SEC-001/002/003/005/008/009 with the owner/security/privacy team.
- Revoke tokens/rotate credentials and decide emergency route containment through approved production operations.
- Decide coordinated repository data cleanup/history rewrite; do not force-push from this branch.

## P1 — Exact next development task

Build isolated identity/tenancy/branch foundations:

1. Add `erp_tenants`, ERP branch membership and additive permission records using SQLite-only tests.
2. Add repository interfaces/implementations that require tenant context.
3. Add staff session `/api/erp/v1/session` behind a disabled-by-default ERP route group.
4. Add allow-list permissions, branch policy and explicit audited tenant-admin override.
5. Add API tests for unauthenticated, wrong tenant, wrong branch, allowed branch and mobile `/api/v1` route snapshot.
6. Replace frontend demo identity through an adapter that retains demo mode without pretending it is live.

Acceptance: all isolation tests pass; no legacy file/route response changes; migrations target only test/sanitized development; docs updated.

## Subsequent sequence

P2 catalog/pricing quote and order idempotency; P3 verified payments/cash/split/refunds; P4 KDS; P5 stock/UOM/recipes; P6 purchasing; P7 accounting/tax/periods; P8 employees/CRM; P9 approved delivery adapters; P10 reconciled reporting and hardening.
