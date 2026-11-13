-- E-TECH / back-office
-- À exécuter dans Supabase > SQL Editor.
-- Remplacez l'email ci-dessous par l'email qui servira à se connecter à /admin.
create extension if not exists pgcrypto;

create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  created_at timestamptz not null default now()
);

-- Après avoir créé l'utilisateur dans Supabase Auth, ajoutez-le ainsi :
-- insert into public.admin_users(user_id,email)
-- select id, email from auth.users where email = 'VOTRE_EMAIL_ADMIN';

create or replace function public.is_admin()
returns boolean language sql stable security definer
set search_path = public
as $$
  select exists(select 1 from public.admin_users where user_id = auth.uid());
$$;

create table if not exists public.customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null,
  created_at timestamptz not null default now(),
  unique(phone)
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text default '',
  price numeric(12,2) not null default 0 check (price >= 0),
  currency text not null default 'DA',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text unique,
  customer_id uuid references public.customers(id) on delete set null,
  customer_name text not null,
  customer_phone text not null,
  items jsonb not null default '[]'::jsonb,
  total numeric(12,2) not null default 0,
  currency text not null default 'DA',
  status text not null default 'pending'
    check (status in ('pending','confirmed','processing','shipped','completed','cancelled')),
  payment_method text default '',
  payment_status text not null default 'unpaid'
    check (payment_status in ('unpaid','proof_received','paid','refunded')),
  payment_reference text default '',
  notes text default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references public.customers(id) on delete set null,
  order_id uuid references public.orders(id) on delete set null,
  service_name text not null,
  start_date date,
  expiry_date date,
  status text not null default 'active'
    check (status in ('active','expired','suspended','cancelled')),
  notes text default '',
  created_at timestamptz not null default now()
);

create index if not exists orders_created_at_idx on public.orders(created_at desc);
create index if not exists orders_customer_phone_idx on public.orders(customer_phone);
create index if not exists subscriptions_expiry_idx on public.subscriptions(expiry_date);

alter table public.admin_users enable row level security;
alter table public.customers enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.subscriptions enable row level security;

drop policy if exists "admin users readable by self" on public.admin_users;
create policy "admin users readable by self" on public.admin_users
for select to authenticated using (user_id = auth.uid());

drop policy if exists "public read active products" on public.products;
create policy "public read active products" on public.products
for select to anon, authenticated using (active = true or public.is_admin());

drop policy if exists "admins manage products" on public.products;
create policy "admins manage products" on public.products
for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "public create customers" on public.customers;
create policy "public create customers" on public.customers
for insert to anon, authenticated with check (true);

drop policy if exists "admins read customers" on public.customers;
create policy "admins read customers" on public.customers
for select to authenticated using (public.is_admin());

drop policy if exists "admins update customers" on public.customers;
create policy "admins update customers" on public.customers
for update to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "public create orders" on public.orders;
create policy "public create orders" on public.orders
for insert to anon, authenticated with check (
  status = 'pending' and payment_status in ('unpaid','proof_received')
);

drop policy if exists "admins manage orders" on public.orders;
create policy "admins manage orders" on public.orders
for all to authenticated using (public.is_admin()) with check (public.is_admin());

drop policy if exists "admins manage subscriptions" on public.subscriptions;
create policy "admins manage subscriptions" on public.subscriptions
for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- Important : aucune lecture publique des commandes, clients ou abonnements.
