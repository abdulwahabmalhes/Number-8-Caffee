# Master Prompt for Google Antigravity

You are continuing NUMBER EIGHT Restaurant ERP development. Before writing code, read every file in `docs/handover`, `docs/audit`, `docs/architecture`, `docs/requirements` and `docs/testing`. Confirm the current Git branch is `feature/restaurant-erp-foundation`, inspect uncommitted work and preserve it.

Production safety overrides all other goals:

1. Never modify, delete, reset, force-push or merge `main`.
2. Never deploy, access production data, run production migrations/seeders or alter production secrets/payments/endpoints.
3. Do not change Flutter, `/api/v1`, Blade dashboards or existing production UI/contracts without explicit owner approval and a versioned compatibility plan.
4. Do not test live payments. Never accept PAN/CVC through the ERP backend.
5. Do not remove sensitive Git history without owner-approved incident coordination.
6. Document existing defects separately; all remediation needs tests, compatibility analysis and rollback.

Continue on the same feature branch. The exact next task is the isolated ERP identity/tenant/branch slice described in `NEXT_TASKS.md`. Use additive migrations only against SQLite/sanitized development, `/api/erp/v1`, deny-by-default permissions and exhaustive tenant/branch tests. Do not claim delivery integrations or production readiness without approved credentials and verified tests.

After each increment update `IMPLEMENTATION_STATUS.md`, `DECISION_LOG.md`, `KNOWN_ISSUES.md`, `TEST_RESULTS.md` and this handover. Report actual commands/results only. Do not merge or deploy.
