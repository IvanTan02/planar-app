# Planar

A private, responsive personal planning app that connects goals and boards to an intentional daily checklist.

## Local setup

Requirements: Node.js 20.19+, npm, and a Supabase project.

1. Install packages with 'npm install'.
2. Copy '.env.example' to '.env.local' and add the project URL and anonymous key.
3. In Supabase, apply 'supabase/migrations/202610080001_initial_schema.sql'.
4. Create the private owner in Authentication → Users. Public sign-up is intentionally absent. The database trigger creates the profile and initial board.
5. Run 'npm run dev' and open http://localhost:3000.

Without environment variables, Planar deliberately shows a setup screen. It does not simulate successful persistence.

## Commands

- 'npm run dev' — development server
- 'npm run typecheck' — TypeScript verification
- 'npm run lint' — ESLint
- 'npm run build' — optimized production build

## Data and security

All product tables use row-level security tied to the authenticated user's ID. The browser receives only the Supabase anonymous key. Ordered daily-plan replacement is performed by one version-aware database function to prevent partial or silently stale saves.

The PWA is online-first. Its service worker caches only the manifest and icon; authenticated pages and private responses are never put in a shared cache. Offline edits are not queued.

## Product documentation

- 'docs/product-spec.md' — source product handoff
- 'docs/architecture.md' — engineering decisions
- 'docs/progress.md' — milestone status, checks, and limitations
