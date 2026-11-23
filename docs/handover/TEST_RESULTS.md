# Test Results — 2026-11-23

Environment: Windows, PHP 8.2.12, Composer 2.9.5, Node 22.18.0, npm 10.9.3. Flutter unavailable. No production service/database/payment endpoint was used.

| Command | Result |
|---|---|
| `composer install --no-interaction --prefer-dist` | Blocked: PHP `ext-intl` missing |
| `composer install --no-interaction --prefer-dist --ignore-platform-req=ext-intl` | Passed for local test tooling; not an acceptable production substitute |
| `php vendor/bin/phpunit tests/Unit/ERP --testdox` | Passed: 7 tests, 12 assertions |
| `php artisan test` (without local key) | 8 passed, 1 failed at boot because `APP_KEY` is absent; no `.env` was created |
| `php artisan test` with ephemeral process-only test key | 8 passed, 1 failed (14 assertions): pre-existing `ExampleTest` expects 200 from `/`, actual behavior is 302 redirect |
| `npm install` | Passed; 0 reported vulnerabilities |
| `npm run typecheck` | Passed |
| `npm test` | Passed: 1 file, 1 test |
| `npm run build` | Passed after final accessibility review: JS 339.16 kB (106.95 kB gzip), CSS 13.36 kB (3.93 kB gzip) |
| Local HTTP preview | Passed: HTTP 200 |
| Browser QA | Passed visually: dashboard, POS, inventory, permission-hidden Team item, explicit demo state and RTL layout |
| `flutter test` / `flutter analyze` | Not run: Flutter executable unavailable |

The new PHP suite covers pricing/tax/service calculation, exact verified payment match, branch access, stock movement validity and balanced journals. Integrated auth/order/payment/branch/database and legacy API contract tests remain next-phase work.
