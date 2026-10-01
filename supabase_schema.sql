-- RASTY BEAUTY V2 - SUPABASE DATABASE
-- Jalankan seluruh script ini di Supabase SQL Editor.

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code text unique not null,
  customer_name text not null,
  email text not null,
  whatsapp text not null,
  address text not null,
  city text not null,
  payment_method text not null,
  status text not null default 'Menunggu Pembayaran'
    check (status in ('Menunggu Pembayaran','Diproses','Dikemas','Dikirim','Selesai','Dibatalkan')),
  total numeric(14,2) not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.order_items (
  id bigint generated always as identity primary key,
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id bigint not null,
  product_name text not null,
  price numeric(14,2) not null,
  qty integer not null check (qty > 0),
  subtotal numeric(14,2) not null
);

create index if not exists orders_created_at_idx on public.orders(created_at desc);
create index if not exists order_items_order_id_idx on public.order_items(order_id);

-- Aktifkan RLS.
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- Customer boleh membuat order dan item.
drop policy if exists "public can create orders" on public.orders;
create policy "public can create orders"
on public.orders for insert
to anon, authenticated
with check (true);

drop policy if exists "public can create order items" on public.order_items;
create policy "public can create order items"
on public.order_items for insert
to anon, authenticated
with check (true);

-- Admin membaca/mengubah order memakai akun Supabase Auth.
drop policy if exists "authenticated can read orders" on public.orders;
create policy "authenticated can read orders"
on public.orders for select
to authenticated
using (true);

drop policy if exists "authenticated can update orders" on public.orders;
create policy "authenticated can update orders"
on public.orders for update
to authenticated
using (true)
with check (true);

drop policy if exists "authenticated can read order items" on public.order_items;
create policy "authenticated can read order items"
on public.order_items for select
to authenticated
using (true);

-- Untuk produksi, policy admin sebaiknya diperketat memakai role/profile admin.
