create table if not exists public.apps (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 emoji text not null default '📺',
 prices jsonb not null default '{}'::jsonb,
 active boolean not null default true,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
alter table public.apps enable row level security;
drop policy if exists "public read active apps" on public.apps;
create policy "public read active apps" on public.apps
for select to anon, authenticated using (active = true or public.is_admin());
drop policy if exists "admins manage apps" on public.apps;
create policy "admins manage apps" on public.apps
for all to authenticated using (public.is_admin()) with check (public.is_admin());
