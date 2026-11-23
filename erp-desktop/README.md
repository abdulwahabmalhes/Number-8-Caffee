# NUMBER EIGHT ERP Desktop Foundation

An isolated React + TypeScript + Vite desktop ERP shell. It does not replace the Flutter app, Laravel Blade dashboard, or any production API contract.

## Local development

```powershell
Copy-Item .env.example .env.local
npm install
npm run dev
```

The UI starts in explicit demonstration mode with local mock data. `VITE_ERP_API_BASE_URL` reserves the future `/api/erp/v1` namespace; no endpoint is connected in this foundation.

## Verification

```powershell
npm run typecheck
npm test
npm run build
```

See `../docs/handover/ENVIRONMENT_SETUP.md` and `../docs/architecture/API_DESIGN.md` before integrating backend data.
