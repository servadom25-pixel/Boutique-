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

-- Import initial du catalogue historique E-TECH.
-- Les lignes déjà présentes ne sont pas écrasées : tu peux ensuite modifier les prix depuis l'admin.
insert into public.apps (name, emoji, prices)
select v.name, v.emoji, v.prices::jsonb
from (values
 ('Iron pro max','📺','{"12":4000}'),
 ('Lynx','🎬','{"1":600,"3":900,"6":1500,"12":2500}'),
 ('Mi star','📡','{"1":600,"3":800,"6":1500,"12":2000}'),
 ('Fosto','🛰️','{"12":3000}'),
 ('Atlas pro','🛰️','{"12":4000}'),
 ('King 360','🛰️','{"12":8500}'),
 ('Vanilla','🛰️','{"12":1500}'),
 ('Funcam','🛰️','{"12":2000}'),
 ('Forever','🛰️','{"12":4000}'),
 ('Hi share premium','🛰️','{"12":3500}')
) as v(name,emoji,prices)
where not exists (
 select 1 from public.apps a where lower(a.name)=lower(v.name)
);
