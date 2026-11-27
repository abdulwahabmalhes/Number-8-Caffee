# Development Environment Setup

## Prerequisites

- Git; PHP 8.2+ with `intl`, `mbstring`, PDO SQLite for tests; Composer 2
- Node 22.12+ recommended and npm
- Flutter compatible with Dart 3.11 for mobile work (not installed on audit host)
- Separate local/sanitized database only; Stripe test credentials only

## Clone and branch

```powershell
git clone https://github.com/abdulwahabmalhes/Number-8-Caffee.git
git switch feature/restaurant-erp-foundation
```

## Backend

```powershell
Set-Location backend
composer install
Copy-Item .env.erp.example .env
New-Item -ItemType File -Force database/erp-development.sqlite
php artisan key:generate
php artisan test
```

Do not use Composer's `setup` script until a safe local `.env` and isolated DB are verified because it runs migrations with `--force`.

Required variable names (never commit values): `APP_ENV`, `APP_KEY`, `APP_URL`, `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, `SESSION_DRIVER`, `QUEUE_CONNECTION`, `BROADCAST_CONNECTION`, `REVERB_APP_ID`, `REVERB_APP_KEY`, `REVERB_APP_SECRET`, `REVERB_HOST`, `REVERB_PORT`, `REVERB_SCHEME`, `STRIPE_KEY`, `STRIPE_SECRET`, `STRIPE_WEBHOOK_SECRET`.

## ERP desktop

```powershell
Set-Location erp-desktop
Copy-Item .env.example .env.local
npm install
npm run dev
npm run typecheck
npm test
npm run build
```

`VITE_ERP_API_BASE_URL` and `VITE_ERP_DEMO_MODE` are public build configuration, never secrets.

## Mobile

```powershell
Set-Location frontend
flutter pub get
flutter test
flutter analyze
```

Do not point mobile/dev builds at production for destructive or payment tests.
