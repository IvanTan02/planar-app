# Planar

A private, responsive personal planning app that connects goals and boards to an intentional daily checklist.

## Local setup

Requirements: Node.js 20.19+, npm, and a Supabase project.

1. Install packages with 'npm install'.
2. Copy '.env.example' to '.env.local' and add the project URL and publishable key ('sb_publishable_...') from Supabase's Connect dialog.
3. In Supabase, apply 'supabase/migrations/202610080001_initial_schema.sql'.
4. Create the private owner in Authentication → Users. Public sign-up is intentionally absent. The database trigger creates the profile and initial board.
5. Run 'make dev' and open http://localhost:3000.

Without environment variables, Planar deliberately shows a setup screen. It does not simulate successful persistence.

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
