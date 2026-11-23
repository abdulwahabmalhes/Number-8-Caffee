# Existing Mobile API Compatibility

## Frozen legacy contract

The Flutter client consumes `/api/v1`; this namespace is frozen for the ERP foundation. No route, controller, payload, status string or authentication behavior was changed.

| Method/path | Auth | Flutter consumer | Response dependency |
|---|---|---|---|
| POST `/auth/login` | public | `phone_auth_screen.dart:83` | `success`, `token`, `customer` |
| DELETE `/customer/account` | Sanctum | `auth_provider.dart:79` | `success` |
| POST `/scan-qr` | public | `table_qr_screen.dart:52,103` | table/branch payload |
| GET `/menu` | public | `menu_provider.dart:5` | categories/products/options |
| GET `/offers` | public | `offers_screen.dart:111` | offers list |
| POST `/coupons/validate` | public | `cart_screen.dart:55` | discount decision |
| GET `/loyalty/config` | public | `loyalty_punch_screen.dart:32` | `target_cups`, `free_cup_number` |
| GET `/stripe/config` | public | `payment_screen.dart:48` | configuration flags/key |
| POST `/stripe/create-checkout-session` | Sanctum | `payment_screen.dart:111` | URL, session/order numbers |
| POST `/stripe/verify-payment` | public | `payment_screen.dart:256,383` | `is_paid`, status |
| POST `/checkout` | Sanctum | `payment_screen.dart:187` | `success`, `order_number` |
| GET `/orders` | Sanctum | order history/loyalty/profile | eager-loaded order graph |
| GET `/orders/{order_number}/status` | public | tracking screen | status/payment/full order |

Other Stripe routes are present even if no current call site was found. They must be treated as public contracts until access logs prove otherwise.

## Compatibility policy

- New ERP endpoints live under `/api/erp/v1` and use staff session authentication, CSRF protection, permission policies and tenant/branch context.
- Do not reuse customer Sanctum tokens for ERP staff access.
- Add contract snapshots around the table above before any remediation.
- Security fixes that must alter legacy semantics require a staged mobile release, telemetry, sunset window and rollback.
- An anti-corruption layer should translate legacy orders into ERP read models/events; the ERP must not write legacy tables directly during phase one.

## Compatibility test requirements

Snapshot status codes and JSON keys for every route; authenticate customer versus staff principals; cover both `#NE1234` and encoded order-number handling; verify Arabic/English content; pin price/option payload types; ensure legacy response additions are optional and removals never occur without a version bump.
