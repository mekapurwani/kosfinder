alter table public.kos
  add column if not exists room_count integer not null default 0
  constraint kos_room_count_nonnegative check (room_count >= 0);

update public.kos
set status = 'Penuh'
where room_count = 0
  and status <> 'Penuh';

create or replace function public.sync_kos_status_from_room_count()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.room_count = 0 then
    new.status = 'Penuh';
  end if;
  return new;
end;
$$;

drop trigger if exists kos_sync_status_from_room_count
  on public.kos;

create trigger kos_sync_status_from_room_count
before insert or update of room_count, status
on public.kos
for each row
execute function public.sync_kos_status_from_room_count();
