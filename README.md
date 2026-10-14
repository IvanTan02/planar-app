# Planar

A private, responsive personal planning app that connects goals and boards to an intentional daily checklist.

## Local setup

Requirements: Node.js 20.19+, npm, and a Supabase project.

1. Install packages with 'npm install'.
2. Copy '.env.example' to '.env.local' and add the project URL and publishable key ('sb_publishable_...') from Supabase's Connect dialog.
3. In Supabase, apply 'supabase/migrations/202610080001_initial_schema.sql'.
4. For restricted development, create the permitted user in Authentication → Users and place its UUID in `PLANAR_ALLOWED_USER_IDS`. The database trigger creates the profile and initial board.
5. Run 'make dev' and open http://localhost:3000.

Without environment variables, Planar deliberately shows a setup screen. It does not simulate successful persistence.

## Environment access

Development and preview deployments should use dedicated Supabase Auth users and set `PLANAR_ALLOWED_USER_IDS` to their UUIDs. When this allowlist is present, every other account is rejected after authentication. Create additional development accounts through Supabase Authentication → Users and append their UUIDs as a comma-separated list.

Self-service registration is controlled independently with `PLANAR_SIGNUP_ENABLED`. Keep it `false` for local and preview deployments. For production, set it to `true`, leave `PLANAR_ALLOWED_USER_IDS` unset, and copy every development UUID into `PLANAR_BLOCKED_USER_IDS`. This prevents development identities from signing into the production app even though both deployments share one Supabase Auth project. A UUID cannot appear in both lists.

```env
# Development / preview
PLANAR_SIGNUP_ENABLED=false
PLANAR_ALLOWED_USER_IDS=<dev-user-uuid>,<another-dev-user-uuid>
PLANAR_BLOCKED_USER_IDS=

# Production
PLANAR_SIGNUP_ENABLED=true
PLANAR_ALLOWED_USER_IDS=
PLANAR_BLOCKED_USER_IDS=<dev-user-uuid>,<another-dev-user-uuid>
```

Both modes use the same tables. RLS separates rows by the authenticated user's `owner_id`; the deployment access lists determine which identities may enter each app deployment.

Set `NEXT_PUBLIC_SITE_URL` to the exact deployment origin so confirmation emails return to `/auth/callback`. Configure the same production, preview, and localhost URLs in Supabase Auth URL Configuration. The signup switch and user access lists are server-only; never prefix them with `NEXT_PUBLIC_`.

## Commands

- 'make help' — list all local commands
- 'make install' — install pinned dependencies
- 'make env' — create '.env.local' without overwriting an existing file
- 'make ca' — prepare Node's CA bundle from the macOS system keychain
- 'make dev' — start the development server
- 'make test' or 'make check' — run lint, type-check, and production-build verification
- 'make start' — run a previously built production server

The Make targets wrap the corresponding npm scripts. There is intentionally no automated test suite in this initial build; 'make test' runs every available static and build check.

On macOS, Make exports the public certificates trusted by the System keychain into the ignored '.local/system-ca.pem' file and passes that bundle to Node. This keeps Supabase HTTPS working on managed networks that inspect TLS. Do not work around certificate errors with 'NODE_TLS_REJECT_UNAUTHORIZED=0'.

- 'npm run dev' — development server
- 'npm run typecheck' — TypeScript verification
- 'npm run lint' — ESLint
- 'npm run build' — optimized production build

## Data and security

All product tables use row-level security tied to the authenticated user's ID. The browser receives only the Supabase publishable key. Planar does not use a secret or legacy 'service_role' key. Ordered daily-plan replacement is performed by one version-aware database function to prevent partial or silently stale saves.

The PWA is online-first. Its service worker caches only the manifest and icon; authenticated pages and private responses are never put in a shared cache. Offline edits are not queued.

## Product documentation

- 'docs/product-spec.md' — source product handoff
- 'docs/architecture.md' — engineering decisions
- 'docs/progress.md' — milestone status, checks, and limitations
