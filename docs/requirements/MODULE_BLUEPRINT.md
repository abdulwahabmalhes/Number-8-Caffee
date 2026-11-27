# ERP Module Blueprint and Acceptance Gates

| Module | Foundation contract | Next acceptance gate |
|---|---|---|
| POS | typed product/cart concepts; authoritative pricing value objects | shift-bound order, quote, cash/card split tender, receipt and void approval tested |
| KDS | order/ticket event boundary specified | private branch/station feed, timers, transitions, offline polling and alert tests |
| Inventory | append-only `StockMovement` with idempotency | UOM conversion, concurrent movement ledger, transfer pairs, count variance approvals |
| Recipes | versioned design | effective recipe version, yield/portion, cost rollup and sale deduction |
| Purchasing | document workflow design | PR→PO→GRN→invoice, three-way match and supplier balance |
| Accounting | balanced `JournalEntry` invariant | chart, posting rules, VAT, refunds, period close/reopen approval and statements |
| Employees | permission/branch model | profile, assignment, shifts, activity and approval workflow |
| CRM | isolation and ledger design | profile/consent, purchase history, immutable points and segmentation |
| Delivery | `DeliveryPlatformAdapter` port | approved sandbox credentials, signed webhook, mapping/retry/idempotency per platform |
| Analytics | reconciled projection design | KPI definitions tied to journals/orders/inventory with freshness and reconciliation |

Talabat, Deliveroo, Noon Food and Keeta are **not integrated**. Each requires commercial partnership/merchant approval, current private API documentation, credentials, webhook signing method, sandbox availability, rate limits and certification. Availability must be verified with each provider before implementation; no functionality is claimed.

AI-assisted BI is limited to narrative/exploration over reconciled read models with provenance, access control and human review. It must not post journals or present unverified financial predictions as facts.
