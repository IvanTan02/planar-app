alter type public.task_complexity rename to task_effort;
alter table public.tasks rename column complexity to effort;
alter table public.tasks drop column acceptance_criteria;

alter type public.goal_period add value if not exists 'three_months';
alter type public.goal_period add value if not exists 'six_months';
alter type public.goal_period add value if not exists 'year';

create function public.move_epic(p_epic_id uuid, p_board_id uuid)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.epics
    where id = p_epic_id and owner_id = auth.uid() and trashed_at is null
  ) then
    raise exception 'Epic is unavailable';
  end if;

  if not exists (
    select 1 from public.boards
    where id = p_board_id and owner_id = auth.uid()
      and archived_at is null and trashed_at is null
  ) then
    raise exception 'Destination board is unavailable';
  end if;

  update public.epics
  set board_id = p_board_id
  where id = p_epic_id and owner_id = auth.uid();

  update public.tasks
  set board_id = p_board_id
  where epic_id = p_epic_id and owner_id = auth.uid();
end
$$;

create function public.trash_epic(p_epic_id uuid)
returns void
language plpgsql
security invoker
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.epics
    where id = p_epic_id and owner_id = auth.uid() and trashed_at is null
  ) then
    raise exception 'Epic is unavailable';
  end if;

  update public.tasks
  set epic_id = null
  where epic_id = p_epic_id and owner_id = auth.uid();

  update public.epics
  set trashed_at = now()
  where id = p_epic_id and owner_id = auth.uid();
end
$$;

revoke all on function public.move_epic(uuid, uuid) from public, anon;
revoke all on function public.trash_epic(uuid) from public, anon;
grant execute on function public.move_epic(uuid, uuid) to authenticated;
grant execute on function public.trash_epic(uuid) to authenticated;

notify pgrst, 'reload schema';
