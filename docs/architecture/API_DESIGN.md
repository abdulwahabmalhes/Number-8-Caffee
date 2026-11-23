# ERP API Design

## Namespace and rules

- Base: `/api/erp/v1`; legacy `/api/v1` remains frozen.
- Browser staff authentication: Laravel Sanctum stateful session, HttpOnly secure cookies, CSRF and re-authentication for sensitive actions.
- Every request resolves tenant and permitted branch server-side; a requested branch is never trusted without policy evaluation.
- JSON uses minor-unit money objects, ISO-8601 UTC timestamps and stable error envelopes.
- Mutating endpoints require `Idempotency-Key`; responses include `X-Request-ID`.
- Cursor pagination, explicit filters and sparse/allow-listed resources prevent overfetch/PII leakage.

```json
{
  "error": {
    "code": "branch_access_denied",
    "message": "You do not have access to this branch.",
    "request_id": "01J...",
    "fields": {}
  }
}
```

## Initial resource contracts

| Method/path | Permission | Purpose |
|---|---|---|
| GET `/session` | staff | identity, tenant, branches, permissions |
| GET `/catalog/products` | `pos.use` | branch price/availability projection |
| POST `/orders/quote` | `pos.use` | authoritative totals from product/modifier IDs |
| POST `/orders` | `pos.use` | idempotent order creation from accepted quote |
| POST `/orders/{id}/transitions` | scoped permission | explicit state transition/reason |
| POST `/orders/{id}/tenders` | `payments.take` | cash/provider tender; never PAN/CVC |
| GET `/kitchen/tickets` | `kitchen.view` | branch/station projection |
| POST `/stock-movements` | `inventory.adjust` | approved append-only movement |
| POST `/journals` | `accounting.post` | balanced controlled journal |

## Event contract

Events include `event_id`, `event_type`, `schema_version`, `occurred_at`, `tenant_id`, `branch_id`, `aggregate_id`, `correlation_id` and a minimal payload. Consumers ignore unknown additive fields; breaking schemas increment version.

## Payment verification

Return pages never mutate financial state. A webhook receipt is signature-verified, stored idempotently, retrieved/validated against provider if needed, matched to stored order reference, exact amount/currency and allowed state, then applied transactionally.
