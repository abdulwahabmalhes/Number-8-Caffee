# Known Issues

## Critical legacy issues

SEC-001 through SEC-012 in `SECURITY_AUDIT.md` remain present because legacy production code was deliberately untouched. Most urgent: optional authentication, Stripe key update authorization, forged payment return, raw cards, arbitrary SQL import and committed sensitive data.

## Foundation limitations

- ERP identity is demo-only and hard-coded; no production authentication.
- Module data is local mock content; every screen shows `DEMO DATA`.
- Locale toggle sets RTL and translates shell badges/branch only; complete Arabic copy, number/date/currency formatting and font packaging remain.
- Google Fonts are remotely imported; production should self-host licensed font files and define CSP.
- Login artwork is PNG (~1.9 MB); convert/resize to responsive WebP/AVIF in the approved asset pipeline.
- No dark theme implementation despite design requirement; design tokens are ready but theme persistence/components remain.
- Minimum CSS width is desktop-oriented; tablet layout requires a separate verified responsive pass.
- `latest` npm ranges should be pinned/renovated before production; lockfile is committed.
- PHP `ext-intl` is disabled on this workstation; normal Composer install fails until enabled.
- Flutter SDK is absent, so mobile tests were not run.
- Pre-existing Laravel feature test expects HTTP 200 from `/`, but the implemented route returns HTTP 302 to `/operations`; this was confirmed with an ephemeral process-only `APP_KEY`.
