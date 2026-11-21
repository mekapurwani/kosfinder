-- Allow authenticated users to read the profiles table through RLS.
-- This table-level grant is required for policy checks and direct profile reads.
grant select on table public.profiles to authenticated;

-- Keep profiles private: authenticated users can only read their own profile.
alter table public.profiles enable row level security;

drop policy if exists "Profiles are readable by their owner"
  on public.profiles;

create policy "Profiles are readable by their owner"
on public.profiles
for select
to authenticated
using (auth.uid() = id);

-- Keep insert profiles limited to the user creating their own profile.
drop policy if exists "Users can insert their own profile"
  on public.profiles;

create policy "Users can insert their own profile"
on public.profiles
for insert
to authenticated
with check (auth.uid() = id);

-- Keep the kos insert policy limited to the authenticated pemilik_kos owner.
drop policy if exists "Owners can insert their own kos"
  on public.kos;

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
