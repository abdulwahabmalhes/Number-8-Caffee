# Technology Stack

## Decision

Use the existing Laravel 12/PHP 8.2 backend and add React + TypeScript + Vite for the ERP desktop frontend.

| Layer | Selection | Why | Maintenance implications |
|---|---|---|---|
| Backend | Laravel 12 modular monolith | Existing team/runtime, queues, policies, validation, DB transactions | Enforce module boundaries; avoid controller-heavy growth |
| Frontend | React + strict TypeScript + Vite | Dense desktop UI ecosystem, typed contracts, fast isolated build | Separate npm lifecycle and accessibility discipline |
| Routing | React Router | Mature nested desktop shell routing | Guard routes and server permissions independently |
| UI | CSS design tokens + Lucide icons initially | Small dependency surface, RTL-friendly logical CSS | Extract a component package only after patterns stabilize |
| Data | Fetch client + future TanStack Query after real API | Foundation avoids premature state library | Add caching only with endpoint semantics |
| Database | Existing supported relational DB; MySQL-compatible production assumed | Fits transactions/accounting/inventory | Confirm exact production engine/version before migrations |
| Async | Laravel queues + transactional outbox | Reliable retries and integration decoupling | Worker monitoring, DLQ and idempotency required |
| Real-time | Laravel Reverb/private branch channels | Existing package/configuration | Authenticated minimal DTO events only |
| Testing | PHPUnit 11, Vitest, Testing Library; future Playwright | Unit/domain and UI behavior coverage | Add staging contract/E2E suite before integration |

## Why not extend Blade or Flutter

Existing Blade screens are production surfaces explicitly frozen. Flutter serves customers well but a desktop ERP needs dense grids, keyboard workflows, browser-based deployment and a broad enterprise component/testing ecosystem. A separate React application avoids coupling ERP release cadence to the mobile app.

## Version policy

The foundation currently uses `latest` npm tags to generate a lockfile during setup. Before a production release, pin an approved Node LTS, commit the lockfile, enable dependency scanning and define a quarterly upgrade process. PHP versions remain governed by `composer.lock` and Laravel support windows.
