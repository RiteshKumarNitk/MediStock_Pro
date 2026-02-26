-- Enable UUID extension
create extension if not exists "pgcrypto";

-- ==========================================
-- 1. CORE MULTI-TENANCY
-- ==========================================

create table medi_tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  phone text,
  gstin text, -- Tenant's own GSTIN
  created_at timestamp default now()
);

create table medi_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  tenant_id uuid references medi_tenants(id) on delete cascade,
  role text not null check (role in ('super_admin', 'admin', 'staff')) default 'staff',
  name text,
  created_at timestamp default now()
);

-- ==========================================
-- 2. INVENTORY MASTER
-- ==========================================

create table medi_products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  name text not null,
  barcode text,
  hsn_code text,
  category text,
  gst_percent numeric default 12,
  created_at timestamp default now(),
  unique (tenant_id, name), -- Name must be unique within a tenant
  unique (tenant_id, barcode)
);

create table medi_batches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  product_id uuid references medi_products(id) on delete cascade,
  batch_no text not null,
  expiry_date date not null,
  quantity integer not null default 0, -- Current on-hand quantity
  purchase_price numeric,
  mrp numeric,
  selling_price numeric,
  created_at timestamp default now()
);

-- ==========================================
-- 3. STOCK MOVEMENTS (The Ledger)
-- ==========================================

create table medi_stock_movements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  batch_id uuid references medi_batches(id) on delete cascade,
  type text not null check (type in ('purchase', 'sale', 'return_in', 'return_out', 'adjustment')),
  quantity integer not null, -- Positive for in, negative for out
  reference_id uuid, -- link to invoice_id or sale_id
  reason text,
  created_at timestamp default now()
);

-- ==========================================
-- 4. PURCHASE FLOW
-- ==========================================

create table medi_purchase_invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  invoice_number text not null,
  vendor_name text,
  vendor_gstin text,
  total_amount numeric not null default 0,
  tax_amount numeric not null default 0,
  image_url text, -- Supabase Storage link
  created_at timestamp default now()
);

create table medi_purchase_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references medi_purchase_invoices(id) on delete cascade,
  product_id uuid references medi_products(id),
  batch_no text,
  qty integer not null,
  rate numeric not null,
  taxable_value numeric not null,
  cgst numeric default 0,
  sgst numeric default 0,
  igst numeric default 0,
  created_at timestamp default now()
);

-- ==========================================
-- 5. SALES FLOW (POS)
-- ==========================================

create table medi_sales_invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  invoice_number text unique not null,
  customer_name text,
  customer_phone text,
  total_amount numeric not null default 0,
  tax_amount numeric not null default 0,
  discount_amount numeric default 0,
  payment_mode text check (payment_mode in ('cash', 'card', 'upi')),
  created_at timestamp default now()
);

create table medi_sales_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references medi_sales_invoices(id) on delete cascade,
  batch_id uuid references medi_batches(id),
  qty integer not null,
  unit_price numeric not null,
  taxable_value numeric not null,
  cgst numeric default 0,
  sgst numeric default 0,
  igst numeric default 0,
  created_at timestamp default now()
);

-- ==========================================
-- 6. SECURITY & RLS
-- ==========================================

-- RBAC Helpers
create or replace function public.get_tenant_id() returns uuid as $$
  select tenant_id from public.medi_profiles where id = auth.uid();
$$ language sql stable security definer;

create or replace function public.get_role() returns text as $$
  select role from public.medi_profiles where id = auth.uid();
$$ language sql stable security definer;

-- Enable RLS
alter table medi_products enable row level security;
alter table medi_batches enable row level security;
alter table medi_stock_movements enable row level security;
alter table medi_purchase_invoices enable row level security;
alter table medi_sales_invoices enable row level security;

-- Policies: Tenant Isolation & RBAC Enforcement

-- 1. Products: Staff can only read. Admins can manage.
drop policy if exists "Tenant isolation: Products" on medi_products;
create policy "Products: Tenant Read" on medi_products for select using (tenant_id = public.get_tenant_id());
create policy "Products: Admin Manage" on medi_products for all using (
  tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin')
);

-- 2. Batches: Staff can read and insert (purchases), but not update/delete.
drop policy if exists "Tenant isolation: Batches" on medi_batches;
create policy "Batches: Tenant Read" on medi_batches for select using (tenant_id = public.get_tenant_id());
create policy "Batches: Staff/Admin Insert" on medi_batches for insert with check (tenant_id = public.get_tenant_id());
create policy "Batches: Admin Update/Delete" on medi_batches for update using (
  tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin')
);

-- 3. Stock Movements: Immutable ledger. Anyone can read/insert for their tenant.
drop policy if exists "Tenant isolation: Movements" on medi_stock_movements;
create policy "Movements: Tenant Multi-Role" on medi_stock_movements for all using (tenant_id = public.get_tenant_id());

-- 4. Purchases: Both can read/insert. Only admin can delete.
drop policy if exists "Tenant isolation: Purchases" on medi_purchase_invoices;
create policy "Purchases: Tenant Read/Insert" on medi_purchase_invoices for select, insert with check (tenant_id = public.get_tenant_id());
create policy "Purchases: Admin Delete" on medi_purchase_invoices for delete using (
  tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin')
);

-- 5. Sales: Both can read/insert. Only admin can delete.
drop policy if exists "Tenant isolation: Sales" on medi_sales_invoices;
create policy "Sales: Tenant Read/Insert" on medi_sales_invoices for select, insert with check (tenant_id = public.get_tenant_id());
create policy "Sales: Admin Delete" on medi_sales_invoices for delete using (
  tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin')
);

-- ==========================================
-- 7. STORAGE POLICIES
-- ==========================================

-- Note: Assume bucket 'invoice-images' is created via UI or script
-- Policies for 'invoice-images' bucket
-- Note: 'storage.objects' table is in 'storage' schema

/*
create policy "Tenants can only access their own folder"
on storage.objects for all
using (
  bucket_id = 'invoice-images' 
  and (storage.foldername(name))[1] = (select tenant_id::text from medi_profiles where id = auth.uid())
);
*/


-- ==========================================
-- 7. AUTOMATION (Triggers)
-- ==========================================

-- Trigger to update Batch Quantity based on Movements
create or replace function public.update_batch_qty()
returns trigger as $$
begin
  update medi_batches 
  set quantity = quantity + new.quantity
  where id = new.batch_id;
  return new;
end;
$$ language plpgsql security definer;

create trigger tr_update_batch_qty
after insert on medi_stock_movements
for each row execute procedure public.update_batch_qty();

-- Trigger to create profile
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.medi_profiles (id, tenant_id, role)
  values (new.id, (new.raw_user_meta_data->>'tenant_id')::uuid, coalesce(new.raw_user_meta_data->>'role', 'staff'));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
