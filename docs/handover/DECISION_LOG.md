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
