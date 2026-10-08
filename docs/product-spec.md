# Planar — Product specification and Codex implementation plan

Prepared by Bason (BA), 8 October 2026. Product owner: Ivan.

## 1. Instructions to Codex

You are the principal engineer implementing this app from scratch in the user's local repository. Read this document before coding. Own architecture, coding conventions, library selection, and implementation details. Build in the milestone order below, keeping the app usable after each milestone. Do not turn the product into a team project-management tool.

The user explicitly requests no dedicated QA phase, unit tests, integration tests, or automated test suites for this initial build. Do not generate test infrastructure. Run basic build/type/lint checks where available and a brief manual smoke check of the primary flow. Report what was actually checked and any remaining limitations. Acceptance criteria here describe intended behaviour, not a request for test suites.

Work autonomously on routine engineering choices. Ask only for missing credentials, blocking contradictions, or product decisions that materially change scope. Never invent Supabase credentials. If infrastructure is unavailable, complete the scaffold and migrations and document the remaining setup; do not present mock persistence as working Supabase integration.

Keep concise progress notes in docs/progress.md: completed milestone, checks, blockers, and next step. Preserve this specification in docs/product-spec.md. Separate confirmed requirements from defaults below. No deployment, billing setup, or purchases are requested.

## 2. Product purpose

A personal todo app connecting bigger goals to actionable tasks and an intentional daily plan. Users capture tasks quickly, optionally add structure, and plan tomorrow the night before so the next day has a clear starting point.

It may track a user's side-project development, but excludes teams, assignments, sprints, collaboration, organisation roles, and other project-management administration.

Planar is the working name, not a cleared public brand. A quick scan found other products using the name. Renaming should be straightforward. No trademark or domain clearance is included.

## 3. Decision status

### Confirmed by the product owner

- Responsive web app plus PWA.
- Full-stack framework with Supabase for backend/data/auth direction.
- Simple ordered Today checklist, not time slots.
- Optional Small / Medium / Large complexity; no story points.
- Users define their own boards, names, and number of boards. Work and Personal are examples only.
- Folders group boards, e.g. Side Projects contains a Todo App board.
- Tasks can be split and linked through relationships.
- Epics are optional task groups, movable between boards. A board can contain only standalone tasks, multiple epics, or both.
- Plan tomorrow the night before.
- Goals for today, this week, this month, and other periods.
- Main dashboard with goals, todos, summaries, and stats.
- Initial personal use; future user auth/monetization was envisaged, with no monetization in this build.
- Start from scratch; principal engineer owns engineering conventions.
- Blue visual theme, light and dark modes.
- Skip dedicated QA and automated test suites for the initial build.

### Recommended defaults, not explicitly approved

Use these as provisional implementation defaults and document them; do not describe them as owner-confirmed:

- Next.js App Router + TypeScript, Tailwind/shadcn-style UI, Supabase Postgres and Auth.
- Minimal private sign-in in v1 (email/password), despite public accounts being future scope. Provision the owner's account through setup; no public signup UI. This protects deployed personal data and supports multiple devices. If the owner wants auth deferred, clarify before deploying any private data.
- Online-first installable PWA; offline editing/sync and push notifications deferred.
- Fixed task statuses: Todo, In Progress, Done. List view default and optional Kanban view.
- One folder level; board belongs to zero or one folder.
- Each task belongs to one board and zero or one epic; each epic resides on one board but can move.
- One level of subtasks, inheriting their parent's board and epic.
- Epic moves carry its tasks/subtasks; moving a task to another board clears its old epic association.
- Tasks may link to multiple goals; goals can span boards.
- Cross-board dependencies allowed; related-to and blocked-by are the initial link types.
- Optional due dates, notes, and Low/Normal/High priority (Normal default).
- Daily focus is one optional statement; weekly/monthly/custom goals are separate records.
- Manual achievement of goals and completion of epics.
- One editable, renameable default board; no compulsory Work/Personal categories.
- Week starts Monday; initial timezone Asia/Kuala_Lumpur, configurable.
- Archive plus restorable Trash; no scheduled hard deletion in v1.
- Lightweight task acceptance criteria and activity history for tracking side-project work.

## 4. Information model and invariants

Folder → boards. Board → standalone tasks and optional epics. Epic → optional grouped tasks. Task → optional subtasks. Goals and daily plans are independent associations to work.

Do not make epic grouping compulsory. Complexity and all organisational fields remain optional. Board folder changes never modify tasks. Stable entity identity preserves links when moving records.

Conceptual entities (engineer owns exact schema):

| Entity | Main data and relationships |
| --- | --- |
| User preferences | Owner identity, timezone, theme choice, week start |
| Folder | Owner, name, ordering |
| Board | Owner, name, optional folder, ordering, archive/trash state |
| Epic | Owner, board, title, notes, optional target date, completion/archive state |
| Task | Owner, board, optional epic/parent, title, notes, status, complexity, priority, due date, ordering, timestamps, archive/trash state |
| Task relationship | Owner, source/target tasks, related-to or blocked-by |
| Goal | Owner, title, description, period type, start/end dates, Active/Achieved/Archived |
| Goal links | Goal to tasks and optionally epics; avoid duplicate contribution counting |
| Daily plan | Owner, local calendar date, optional focus statement |
| Daily plan item | Plan, task, position, historical display snapshot as needed |
| Task activity/completion history | Owner, task, event and timestamp; retain previous completion when reopened |

Maintain a single plan per owner/date and a single item per plan/task. Dates are local calendar dates; event timestamps are timezone-aware instants. Reordering and group moves must not partially apply. All referenced records must belong to the same owner. Enforce ownership for relationship/link records as well as primary entities.

## 5. Screens and workflows

### Navigation and capture

Desktop sidebar lists folders, their boards, and unfiled boards. Mobile navigation offers equivalent access. Global entries: Dashboard, Today, Plan Tomorrow, Goals. Epics are accessible from boards; a separate index is optional.

Quick capture requires only a title. In a board, use that board. Global capture uses the last valid selected board, falling back to the default. Provide a clear destination control. Extra fields are progressively disclosed. Task details open in a panel/dialog without losing the current view.

### Boards and folders

Create, rename, reorder, move, and archive boards. Create, rename, reorder, and delete folders. Deleting a folder moves its boards to Unfiled; it never deletes them. Do not introduce a business cap on board count in v1.

Archived boards are excluded from active picking/navigation by default but remain accessible. If a board has unfinished items in current/future plans, show an explicit review before archiving. Preserve previous plans. Avoid hidden loss of planned work.

### Tasks and relationships

Create/edit/complete/reopen tasks; add subtasks. Completing all subtasks does not automatically complete their parent. If completing a parent with unfinished children, require review and allow explicit completion without silently completing the children.

Dependencies are warnings, not enforced workflow gates. Users can progress a blocked task. Reject self-links and dependency cycles, including cross-board cycles. Related-to is symmetric; avoid duplicate inverse links.

Moving a parent moves its children. A child moves independently only after detaching from its parent. Cross-board move removes its existing epic association unless assigned to a destination epic. Preserve dependencies, goal links, and plan entries.

### Epics

Create optional epic groups and assign/remove tasks. Removing a task from an epic leaves it standalone on the same board. Moving an epic moves all its tasks and subtasks, preserving identity and other links. Deleting/trashing an epic ungroups its tasks rather than deleting them. Completion is manual; show task progress as supporting information.

### Today and Plan Tomorrow

1. Review today's unfinished tasks.
2. Choose which to carry to tomorrow; never automatically populate tomorrow with leftovers.
3. Pick tasks from any active board or create new ones.
4. Order by drag/drop with accessible move-up/down alternatives.
5. Set an optional daily focus statement.
6. Save changes automatically with visible saving/saved/error feedback.

Today resolves the current local date's plan; Plan Tomorrow resolves the next calendar day. No background midnight job is needed for rollover. Re-evaluate the date when the app regains focus and at midnight while open. Today remains editable.

Removing a plan item does not delete a task. Planning dates never change task due dates. A task may appear on different dates but not twice on the same date. Completing it updates its current status everywhere. Completed items remain visible in their plan.

Preserve past planned membership/order and event-based completion history. Reopening or later completion must not rewrite earlier completion statistics. Allow editing today's/future plans; past plans are read-only in v1. If a task was completed outside its planned day, show its current completion clearly while keeping the earlier day's historical result accurate.

### Goals

Daily focus is stored on the daily plan and displayed as today's goal. Weekly/monthly/custom goals store their own date ranges and can reference tasks/epics across boards. Goal achievement is explicit; finishing supporting tasks does not imply the outcome was achieved. Show completed/total supporting work without inventing a productivity score.

### Dashboard

Prioritise today's focus, first unfinished planned task, remaining checklist, active weekly/monthly goals, and Plan Tomorrow. Include today's completed/planned count, this week's completed task count, and a small blocked-work summary. Optional board filter must make its scope clear.

Avoid double counting: top-level tasks are counting units; subtasks appear as within-parent progress. If only a subtask is planned, it can be a daily checklist unit; if its parent is also planned, count that group once. Count unique tasks across overlapping goal/epic links. Never sum complexity into a score.

### Search and lifecycle

Search task titles and filter by board/status/complexity/due date. Archive retains data and hides it from active views. Trash is restorable; no automatic permanent purge. Trashed tasks remain identifiable in historical plans but cannot be newly planned. Restore with a valid board, prompting for a replacement if its original board is unavailable. Clarify cascading board-trash effects in the UI and preserve restoreable hierarchy.

## 6. Visual and platform requirements

Blue accents, soft neutral light backgrounds, deep navy dark backgrounds. Clean, calm, readable personal-app feel. Avoid Jira terminology beyond useful concepts such as epics. Do not show story points, velocity, sprints, or team administration.

Theme options: Light, Dark, System; persist choice and avoid theme flashing. Provide responsive layouts, keyboard access, labelled controls, focus visibility, readable contrast, and touch-friendly targets. Dragging cannot be the only way to reorder.

PWA: manifest, app icons, installation support where available, HTTPS-ready configuration. Online-first data. Show an understandable offline state and preserve unsaved input; do not claim offline persistence or queue edits without implementing safe sync. Do not cache private authenticated responses in a shared service-worker cache.

## 7. Backend and delivery boundaries

Supabase-backed persistent data, private ownership and row-level access controls. Never put privileged credentials in client code. Keep schema changes reproducible through migrations and provide environment examples without secrets. Engineer chooses server/client access patterns and appropriate atomic database operations.

Future monetization should not require rewriting ownership, but no billing tables, Stripe setup, subscription UI, or multi-tenant organisations are required now. No realtime collaboration; saved data must appear on another device when loaded/refreshed. Define concurrent update behaviour so stale saves do not silently overwrite newer edits, especially ordered plans.

Future AI integration: authorised tools for reading tasks, adding requirements, updating implementation status, and recording verification. Record as deferred scope; do not build an MCP server now. The development board belongs to the user, not separate BA/dev/QA accounts.

## 8. Implementation milestones

| Milestone | Deliverable | Exit criteria |
| --- | --- | --- |
| 1. Foundation | App scaffold, blue light/dark shell, Supabase migrations/setup, private session flow | App runs; configuration documented; private data access is scoped to owner |
| 2. Organisation and capture | Folders, boards, task CRUD, list view, task detail panel | Title-only capture works; custom boards/folders can be moved/renamed; reload retains data |
| 3. Daily loop | Today, tomorrow picker, ordering, daily focus, date rollover/history | Pick tasks across boards; tomorrow becomes Today by local date; remove preserves task; leftovers require explicit carry-forward |
| 4. Optional structure | Subtasks, movable epics, relationships, complexity, due dates, priority, Kanban | Standalone and grouped tasks coexist; group moves preserve links; circular blockers rejected |
| 5. Goals and overview | Period goals/linking, dashboard summaries, search/filter, archive/Trash | Goal achievement is manual; counts avoid duplication; history survives reopen/moves/archive |
| 6. PWA and handoff | Installability, responsive polish, empty/error/offline states, README/progress | Production build passes; primary flow manually exercised; setup and limitations clearly recorded |

Do not stop after a mock dashboard and describe the full MVP as complete. If credentials or infrastructure block a milestone, report precisely what works and what remains. Avoid unrequested dependencies or speculative future features.

## 9. Acceptance examples (not automated test requirements)

- Create a task using only a title in a custom board and reload: it remains.
- Create Side Projects folder and Todo App board, then move the board: tasks remain intact.
- Keep a board entirely standalone; create several epics in another board: both work.
- Move an epic to another board: all grouped work moves, daily-plan and goal links survive.
- Plan tomorrow using two boards and reorder: tomorrow's Today presents that order.
- Leave a task unfinished: it remains available but is not silently carried forward.
- Complete and reopen a task: current status changes; historical completion remains.
- Remove an item from Today: underlying task stays in its board.
- Attempt A blocked by B and B blocked by A: reject the cycle with a useful message.
- Finish supporting tasks: goal remains Active until explicitly achieved.
- Fail a save or lose connectivity: show truthful state and retain input for retry.
- Refresh on another device: saved changes appear; another owner cannot access these records.
- Use phone navigation and keyboard reorder; switch light/dark; install PWA where supported.

## 10. Deferred scope

Public signup/onboarding, monetization, offline editing/conflict-sync, recurring tasks/habits, reminders/push, calendar integrations/time slots, attachments, nested folders, multiple subtask levels, AI/MCP integration, team/collaboration features, automated test suites.

## 11. First prompt to Codex

Read this handoff and implement Planar from scratch. Treat Confirmed requirements as authoritative and Recommended defaults as provisional decisions you should document. Own engineering details as principal engineer. Start with a concise architecture/milestone outline, then implement the milestones in order without asking permission for routine reversible choices. No dedicated QA phase or automated test suites; run basic build/type/lint checks and a brief manual smoke check. Keep docs/progress.md current, and explain setup blockers and any incomplete functionality honestly. Do not deploy or configure billing.
