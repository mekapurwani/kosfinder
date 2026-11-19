create extension if not exists "pgcrypto";

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  role text not null check (role in ('pencari_kos', 'pemilik_kos')),
  created_at timestamptz not null default now()
);

create table public.kos (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  address_area text not null,
  monthly_price numeric not null check (monthly_price >= 0),
  description text not null,
  whatsapp_number text not null,
  status text not null check (status in ('Tersedia', 'Penuh')),
  created_at timestamptz not null default now()
);

create index kos_created_at_idx on public.kos (created_at desc);
create index kos_owner_id_idx on public.kos (owner_id);
create index kos_name_idx on public.kos (name);
create index kos_address_area_idx on public.kos (address_area);

alter table public.profiles enable row level security;
alter table public.kos enable row level security;

create policy "Profiles are readable by their owner"
on public.profiles
for select
to authenticated
using (auth.uid() = id);

create policy "Users can insert their own profile"
on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

create policy "Kos is publicly readable"
on public.kos
for select
to anon, authenticated
using (true);

create policy "Owners can insert their own kos"
on public.kos
for insert
to authenticated
with check (
  auth.uid() = owner_id
  and exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'pemilik_kos'
  )
);

create policy "Owners can update their own kos"
on public.kos
for update
to authenticated
using (
  auth.uid() = owner_id
  and exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'pemilik_kos'
  )
)
with check (
  auth.uid() = owner_id
  and exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'pemilik_kos'
  )
);

create policy "Owners can delete their own kos"
on public.kos
for delete
to authenticated
using (
  auth.uid() = owner_id
  and exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'pemilik_kos'
  )
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', ''),
    coalesce(new.raw_user_meta_data ->> 'role', 'pencari_kos')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();