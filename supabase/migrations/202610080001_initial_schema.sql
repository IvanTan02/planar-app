create extension if not exists pgcrypto;
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
create type task_status as enum ('todo','in_progress','done');
create type task_complexity as enum ('small','medium','large');
create type task_priority as enum ('low','normal','high');
create type relationship_kind as enum ('related_to','blocked_by');
create type goal_period as enum ('week','month','custom');
create type goal_status as enum ('active','achieved','archived');

create table profiles (id uuid primary key references auth.users(id) on delete cascade, timezone text not null default 'Asia/Kuala_Lumpur', theme text not null default 'system' check(theme in ('light','dark','system')), week_starts_on smallint not null default 1 check(week_starts_on between 0 and 6), last_board_id uuid, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table folders (id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade, name text not null check(length(trim(name)) between 1 and 80), position integer not null default 0, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table boards (id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade, folder_id uuid references folders(id) on delete set null, name text not null check(length(trim(name)) between 1 and 80), position integer not null default 0, archived_at timestamptz, trashed_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
alter table profiles add constraint profiles_last_board_fk foreign key(last_board_id) references boards(id) on delete set null;
create table epics (id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade, board_id uuid not null references boards(id), title text not null check(length(trim(title)) between 1 and 200), notes text not null default '', target_date date, position integer not null default 0, completed_at timestamptz, archived_at timestamptz, trashed_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create table tasks (id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade, board_id uuid not null references boards(id), epic_id uuid references epics(id) on delete set null, parent_id uuid references tasks(id) on delete set null, title text not null check(length(trim(title)) between 1 and 300), notes text not null default '', acceptance_criteria text not null default '', status task_status not null default 'todo', complexity task_complexity, priority task_priority not null default 'normal', due_date date, position integer not null default 0, archived_at timestamptz, trashed_at timestamptz, version integer not null default 1, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), check(parent_id is null or parent_id<>id));
create table task_relationships (id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade, source_task_id uuid not null references tasks(id) on delete cascade, target_task_id uuid not null references tasks(id) on delete cascade, kind relationship_kind not null, created_at timestamptz not null default now(), check(source_task_id<>target_task_id), unique(source_task_id,target_task_id,kind));
create table goals (id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade, title text not null check(length(trim(title)) between 1 and 200), description text not null default '', period goal_period not null, start_date date not null, end_date date not null, status goal_status not null default 'active', achieved_at timestamptz, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), check(end_date>=start_date));
create table goal_tasks (owner_id uuid not null references profiles(id) on delete cascade, goal_id uuid not null references goals(id) on delete cascade, task_id uuid not null references tasks(id) on delete cascade, primary key(goal_id,task_id));
create table goal_epics (owner_id uuid not null references profiles(id) on delete cascade, goal_id uuid not null references goals(id) on delete cascade, epic_id uuid not null references epics(id) on delete cascade, primary key(goal_id,epic_id));
create table daily_plans (id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade, plan_date date not null, focus text not null default '', version integer not null default 1, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(owner_id,plan_date));
create table daily_plan_items (id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade, plan_id uuid not null references daily_plans(id) on delete cascade, task_id uuid references tasks(id) on delete set null, position integer not null default 0, title_snapshot text not null, completion_snapshot boolean, created_at timestamptz not null default now(), unique(plan_id,task_id));
create table task_activity (id uuid primary key default gen_random_uuid(), owner_id uuid not null references profiles(id) on delete cascade, task_id uuid not null references tasks(id) on delete cascade, event text not null check(event in ('created','completed','reopened','moved','archived','restored')), occurred_at timestamptz not null default now(), metadata jsonb not null default '{}');
create index tasks_owner_board_active on tasks(owner_id,board_id,position) where trashed_at is null;
create index tasks_owner_status on tasks(owner_id,status) where trashed_at is null and archived_at is null;
create index task_activity_owner_time on task_activity(owner_id,occurred_at desc);
create index daily_plans_owner_date on daily_plans(owner_id,plan_date);
create index goals_owner_period on goals(owner_id,start_date,end_date) where status='active';

create function touch_record() returns trigger language plpgsql set search_path='' as $$ begin new.updated_at=now(); if tg_table_name in ('tasks','daily_plans') then new.version=old.version+1; end if; return new; end $$;
create trigger touch_profiles before update on profiles for each row execute function touch_record();
create trigger touch_folders before update on folders for each row execute function touch_record();
create trigger touch_boards before update on boards for each row execute function touch_record();
create trigger touch_epics before update on epics for each row execute function touch_record();
create trigger touch_tasks before update on tasks for each row execute function touch_record();
create trigger touch_goals before update on goals for each row execute function touch_record();
create trigger touch_plans before update on daily_plans for each row execute function touch_record();
create function private.provision_owner() returns trigger security definer set search_path='' language plpgsql as $$ begin insert into public.profiles(id) values(new.id) on conflict(id) do nothing; insert into public.boards(owner_id,name) select new.id,'My Board' where not exists(select 1 from public.boards where owner_id=new.id); return new; end $$;
revoke all on function private.provision_owner() from public, anon, authenticated;
create trigger provision_owner_after_signup after insert on auth.users for each row execute function private.provision_owner();
insert into profiles(id) select id from auth.users on conflict(id) do nothing;
insert into boards(owner_id,name) select p.id,'My Board' from profiles p where not exists(select 1 from boards b where b.owner_id=p.id);
create function record_task_status() returns trigger set search_path='' language plpgsql as $$ begin if tg_op='INSERT' then insert into public.task_activity(owner_id,task_id,event) values(new.owner_id,new.id,'created'); elsif old.status is distinct from new.status then insert into public.task_activity(owner_id,task_id,event) values(new.owner_id,new.id,case when new.status='done' then 'completed' else 'reopened' end); end if; return new; end $$;
create trigger record_task_status_after after insert or update on tasks for each row execute function record_task_status();
create function reject_block_cycle() returns trigger set search_path='' language plpgsql as $$ begin if new.kind='blocked_by' and exists(with recursive chain(id) as (select target_task_id from public.task_relationships where kind='blocked_by' and source_task_id=new.target_task_id union select r.target_task_id from public.task_relationships r join chain c on r.source_task_id=c.id where r.kind='blocked_by') select 1 from chain where id=new.source_task_id) then raise exception 'This dependency would create a cycle'; end if; return new; end $$;
create trigger reject_block_cycle_before before insert or update on task_relationships for each row execute function reject_block_cycle();
revoke all on function touch_record() from public, anon, authenticated;
revoke all on function record_task_status() from public, anon, authenticated;
revoke all on function reject_block_cycle() from public, anon, authenticated;

alter table profiles enable row level security; alter table folders enable row level security; alter table boards enable row level security; alter table epics enable row level security; alter table tasks enable row level security; alter table task_relationships enable row level security; alter table goals enable row level security; alter table goal_tasks enable row level security; alter table goal_epics enable row level security; alter table daily_plans enable row level security; alter table daily_plan_items enable row level security; alter table task_activity enable row level security;
create policy owner_access on profiles for all to authenticated using(id=(select auth.uid())) with check(id=(select auth.uid()));
do $$ declare t text; begin foreach t in array array['folders','boards','epics','tasks','task_relationships','goals','goal_tasks','goal_epics','daily_plans','daily_plan_items','task_activity'] loop execute format('create policy owner_access on %I for all to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()))',t); end loop; end $$;
grant usage on schema public to authenticated;
grant select,insert,update,delete on all tables in schema public to authenticated;
revoke all on all tables in schema public from anon;

create function save_daily_plan(p_date date,p_focus text,p_task_ids uuid[],p_expected_version integer default null) returns public.daily_plans security invoker set search_path='' language plpgsql as $$
declare p public.daily_plans; t public.tasks; i integer;
begin
 insert into public.daily_plans(owner_id,plan_date,focus) values(auth.uid(),p_date,coalesce(p_focus,'')) on conflict(owner_id,plan_date) do update set focus=excluded.focus where p_expected_version is null or daily_plans.version=p_expected_version returning * into p;
 if p.id is null then raise exception 'Plan changed elsewhere. Refresh before saving again.'; end if;
 if cardinality(p_task_ids)<>(select count(distinct x) from unnest(p_task_ids) x) then raise exception 'A task can appear only once per plan'; end if;
 delete from public.daily_plan_items where plan_id=p.id;
 for i in 1..coalesce(cardinality(p_task_ids),0) loop
  select * into t from public.tasks where id=p_task_ids[i] and owner_id=auth.uid() and trashed_at is null;
  if t.id is null then raise exception 'A selected task is unavailable'; end if;
  insert into public.daily_plan_items(owner_id,plan_id,task_id,position,title_snapshot) values(auth.uid(),p.id,t.id,i-1,t.title);
 end loop; return p;
end $$;
revoke all on function save_daily_plan(date,text,uuid[],integer) from public, anon;
grant execute on function save_daily_plan(date,text,uuid[],integer) to authenticated;
notify pgrst, 'reload schema';
