# Deployment Strategy

## Environments

Local → isolated CI → sanitized staging → owner-approved production. Each uses distinct database, Stripe test account, secrets, queues, Reverb keys and object storage. Production data must never be copied to development without an approved anonymization process.

## Packaging

- Build `erp-desktop` into versioned static assets; host at a separate origin/subdomain or isolated Laravel path with CSP.
- Deploy additive backend code/routes behind `ERP_ENABLED=false` until validation.
- Run queue workers separately with health checks and graceful restart.
- Use private WebSocket channels and HTTPS only.

## Release sequence

1. Backup and verified restore rehearsal.
2. Deploy backward-compatible code with features disabled.
3. Run additive online migrations from an approved release pipeline—not an agent shell.
4. Enable internal tenant/branch for pilot users.
5. Monitor errors, queue lag, payment reconciliation, order totals and audit events.
6. Expand by branch; retain immediate feature-flag rollback.

Database rollback avoids destructive down migrations: disable feature, restore compatible code, and leave additive tables until reviewed. Payment/accounting releases require reconciliation before and after enablement.

## This branch

No deployment manifest or production pipeline mutation is included. Sites publication was intentionally skipped. The branch is a local foundation and documentation handover only.
