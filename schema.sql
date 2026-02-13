-- Enable UUID extension
create extension if not exists "pgcrypto";

-- 1. Tenants Table
create table medi_tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamp default now()
);

-- 2. Profiles Table (Link Users to Tenants)
create table medi_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  tenant_id uuid references medi_tenants(id) on delete cascade,
  role text,
  created_at timestamp default now()
);

-- 3. Products Table (Tenant Based)
create table medi_products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  name text not null,
  barcode text not null,
  gst_percent numeric,
  created_at timestamp default now(),
  unique (tenant_id, barcode)
);

create index idx_medi_products_barcode on medi_products(tenant_id, barcode);

-- 4. Batches Table (Tenant Based)
create table medi_batches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  product_id uuid references medi_products(id) on delete cascade,
  batch_no text not null,
  expiry_date date not null,
  quantity integer not null,
  purchase_price numeric,
  selling_price numeric,
  created_at timestamp default now()
);

create index idx_medi_batches_expiry on medi_batches(tenant_id, expiry_date);

-- 5. Enable Row Level Security
alter table medi_products enable row level security;
alter table medi_batches enable row level security;

-- 6. RLS Policies

-- Policy for Products
create policy "Tenant can access own products"
on medi_products
for all
using (
  tenant_id = (
    select tenant_id from medi_profiles
    where id = auth.uid()
  )
);

-- Policy for Batches
create policy "Tenant can access own batches"
on medi_batches
for all
using (
  tenant_id = (
    select tenant_id from medi_profiles
    where id = auth.uid()
  )
);

-- 7. Tenant-Based Expiry Alerts View
create view medi_expiry_alerts as
select 
  b.tenant_id,
  p.name as product_name,
  b.batch_no,
  b.expiry_date,
  b.quantity,
  (b.expiry_date - current_date) as days_remaining
from medi_batches b
join medi_products p on p.id = b.product_id
where b.expiry_date <= current_date + interval '30 days';

-- Grant access to the view
grant select on medi_expiry_alerts to authenticated;
-- 8. Trigger to create profile on sign up
-- Pass tenant_id in user_metadata during signUp
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.medi_profiles (id, tenant_id, role)
  values (
    new.id, 
    (new.raw_user_meta_data->>'tenant_id')::uuid, 
    coalesce(new.raw_user_meta_data->>'role', 'Admin')
  );
  return new;
end;
$$ language plpgsql security definer;

-- Trigger should be created after the tables exist
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
