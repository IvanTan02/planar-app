# Implementation progress

Updated: 8 October 2026 (Asia/Kuala_Lumpur)

## Provisional decisions

- Adopted Next.js App Router, TypeScript, Supabase Auth/Postgres, and custom CSS. The current Next.js 16.4.0 release is pinned after Next 15 failed its production compile under the available Node runtime.
- Private email/password sign-in with owner provisioning; no public registration UI.
- Direct authenticated Supabase client mutations guarded by RLS. No service-role credential exists in the app.
- Fixed Todo / In progress / Done states, one folder level, one subtask level, and the recommended priority/complexity defaults.
- Native move-up/down controls are the accessible ordering mechanism. Pointer drag-and-drop is not included in this initial handoff.
- Online-first PWA with only public icon/manifest caching; no offline write queue.

## Milestones

### 1. Foundation — complete

- Next.js/TypeScript scaffold, responsive blue light/dark shell, manifest, setup state, private session flow.
- Reproducible Supabase migration with owner profiles, entities, indexes, RLS, initial board provisioning, event history, cycle rejection, and atomic/version-aware plan saves.
- Configuration and architecture documented.

### 2. Organisation and capture — complete

- Title-only global and board capture.
- Folder creation/deletion (board unfiling is enforced by the foreign key), custom boards, board list, task editing, and a non-destructive detail dialog.
- Data loads from Supabase on refresh; no mock persistence.

### 3. Daily loop — complete

- Today and tomorrow resolve from the Kuala Lumpur local calendar date.
- Cross-board task picker, focus statement, explicit unfinished-work carry-forward, removal without task deletion, and accessible ordering.
- Visible saving/error state; focus and minute checks re-evaluate date rollover. Historical plan rows and title snapshots remain stored.

### 4. Optional structure — substantially complete

- Optional complexity, priority, dates, acceptance criteria, subtasks, standalone tasks, epic grouping, list/Kanban switch, and blocked-by links.
- Database rejects blocker cycles. Dependencies remain warnings.
- Remaining UI limitation: epic move/edit and related-to link management are represented in the schema but do not yet have dedicated controls. Subtask detail editing requires opening it through a filtered/search result rather than its parent panel.

### 5. Goals and overview — substantially complete

- Explicitly achieved period goals, dashboard focus/first task/counts, task search filters, board archive review, restorable task/board Trash, and activity-based weekly completions.
- Remaining UI limitation: task/epic goal-link management and board/folder rename/reorder controls are not yet exposed. The blocked dashboard count is a review prompt rather than a calculated count.

### 6. PWA and handoff — complete

- Installable manifest/icon, responsive layouts, empty/error/offline states, theme persistence without flash, keyboard reordering, README, and pinned dependencies.
- Service worker intentionally excludes authenticated routes and private data.

## Checks performed

- 'npm run typecheck' — passed.
- 'npm run lint' — passed with no errors; four non-blocking hook/config warnings remain.
- 'npm run build' — passed on Next.js 16.4.0 / Node.js 23.2.0.
- Build-time smoke check covered setup rendering and route generation for '/', '/login', '/auth/callback', and '/api/auth/signout'.

## Blockers and limitations

- No Supabase credentials were supplied, so authenticated persistence and the end-to-end create/reload flow could not be exercised against live infrastructure. The app truthfully shows setup guidance without them.
- No automated tests were created, per the product owner's instruction.
- npm reports five high-severity advisories in the installed dependency tree. No forced breaking upgrades were applied; reassess with 'npm audit' before deployment.
- Deployment, billing, public signup, offline sync, notifications, and MCP/AI integration remain deferred.

## Next step

Apply the Supabase migration, provision the owner account, add '.env.local', and manually exercise the primary capture → tomorrow plan → Today → complete/reopen flow. Then close the remaining milestone 4–5 UI limitations above.
