# Module Dependencies

```mermaid
flowchart TD
  Access[Identity / tenancy / access] --> POS
  Access --> Kitchen
  Access --> Inventory
  Access --> Purchasing
  Access --> Accounting
  Catalog[Catalog / pricing] --> POS
  Catalog --> Recipes
  POS --> Payments
  POS --> Kitchen
  POS --> CRM
  Recipes --> Inventory
  Purchasing --> Inventory
  Purchasing --> Accounting
  POS --> Accounting
  Inventory --> Accounting
  Payments --> Accounting
  POS --> Integrations
  Kitchen --> Integrations
  POS --> Reporting
  Inventory --> Reporting
  Accounting --> Reporting
```

Dependencies are one-way through application ports/events. Reporting may read projections but cannot mutate source modules. Accounting consumes approved business events; it never queries controller request payloads. Delivery adapters depend on integration contracts, not the order aggregate implementation.

## Implementation sequence

Identity/tenant/branch → catalog/pricing → POS/order state → verified payments → KDS → inventory/UOM → recipes/costing → purchasing → accounting → workforce/CRM → delivery adapters → advanced analytics.
