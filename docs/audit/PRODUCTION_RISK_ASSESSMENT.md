# Production Risk Assessment

## Overall rating: Critical

The live application should be assumed exposed to account takeover, payment-state forgery, runtime Stripe-key replacement, arbitrary SQL execution by weakly authorized staff identities, public order enumeration and repository data leakage. This rating is based on source behavior, not a production penetration test.

## Risk register

| Risk | Likelihood | Impact | Evidence | Safe next action |
|---|---|---|---|---|
| Customer takeover | High | Critical | SEC-001 | Owner-approved emergency auth containment and token revocation |
| Stripe credential replacement | High | Critical | SEC-002 | Firewall/disable route; rotate keys through secret manager |
| Fraudulent paid orders | High | Critical | SEC-003/004 | Webhook verification and reconciliation; preserve return UX |
| PCI exposure | Medium/High | Critical | SEC-005 | Stop server PAN/CVC handling after mobile cutover |
| Database compromise via import | Medium | Critical | SEC-008 | Disable import and replace with safe importer |
| Repository privacy incident | Confirmed | Critical | SEC-009 | Incident response; do not rewrite history without approval |
| Cross-branch disclosure/mutation | High | High | SEC-007/011/012 | Permission and branch policy layer |
| Tax/accounting inaccuracy | High | High | BUG-004 | Finance-approved calculation/reconciliation design |

## Change risk controls

1. Freeze production changes except owner-approved containment.
2. Create an authorized staging clone using sanitized data and test Stripe credentials only.
3. Add observability and compatibility tests before changing `/api/v1`.
4. Release ERP additively with a separate frontend, route namespace and tables.
5. Use canary/feature flags, backups with verified restore, migration dry runs and rollback checkpoints.
6. Require two-person approval for payments, accounting periods, data imports and production secrets.

## Actions not performed

No production scan, credential validation, Stripe request, server login, migration, database connection, deployment, branch merge, history rewrite or main-branch change was performed. Each requires explicit owner authorization and appropriately scoped access.
