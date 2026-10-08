# Architecture

Planar is a Next.js App Router application with a small authenticated client workspace backed directly by Supabase. Supabase Auth owns sessions; Postgres row-level security scopes every entity and join row to the signed-in owner. The browser uses the anonymous project key, never a privileged key.

The UI is organized around one responsive workspace because the product is a cohesive personal workflow rather than separate administrative screens. Data mutations update local state only after Supabase confirms them. Daily-plan replacement uses a database function so ordering is atomic and stale versions fail visibly.

## Provisional decisions

- Next.js App Router and TypeScript.
- Supabase email/password auth with no public sign-up route.
- Direct authenticated Supabase client access protected by RLS.
- Fixed task states: Todo, In progress, Done.
- Single folder level and single subtask level.
- Native buttons for accessible reordering; drag-and-drop is deferred until it can retain equivalent keyboard behavior.
- Online-first PWA. The service worker caches only public assets, never authenticated API/data responses.
- Asia/Kuala_Lumpur and Monday week start are initial profile defaults.
