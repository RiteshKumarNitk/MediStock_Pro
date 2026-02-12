-- Enable UUID extension
create extension if not exists "pgcrypto";

-- 1. Tenants Table
create table tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamp default now()
);

-- 2. Profiles Table (Link Users to Tenants)
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  tenant_id uuid references tenants(id) on delete cascade,
  role text,
  created_at timestamp default now()
);

-- 3. Products Table (Tenant Based)
create table products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references tenants(id) on delete cascade,
  name text not null,
  barcode text not null,
  gst_percent numeric,
  created_at timestamp default now(),
  unique (tenant_id, barcode)
);

create index idx_products_barcode on products(tenant_id, barcode);

-- 4. Batches Table (Tenant Based)
create table batches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references tenants(id) on delete cascade,
  product_id uuid references products(id) on delete cascade,
  batch_no text not null,
  expiry_date date not null,
  quantity integer not null,
  purchase_price numeric,
  selling_price numeric,
  created_at timestamp default now()
);

create index idx_batches_expiry on batches(tenant_id, expiry_date);

-- 5. Enable Row Level Security
alter table products enable row level security;
alter table batches enable row level security;

-- 6. RLS Policies

-- Policy for Products
create policy "Tenant can access own products"
on products
for all
using (
  tenant_id = (
    select tenant_id from profiles
    where id = auth.uid()
  )
);

-- Policy for Batches
create policy "Tenant can access own batches"
on batches
for all
using (
  tenant_id = (
    select tenant_id from profiles
    where id = auth.uid()
  )
);

-- 7. Tenant-Based Expiry Alerts View
create view expiry_alerts as
select 
  b.tenant_id,
  p.name as product_name,
  b.batch_no,
  b.expiry_date,
  b.quantity,
  (b.expiry_date - current_date) as days_remaining
from batches b
join products p on p.id = b.product_id
where b.expiry_date <= current_date + interval '30 days';

-- Grant access to the view (usually needed for authenticated users)
grant select on expiry_alerts to authenticated;
