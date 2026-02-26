create extension if not exists "pgcrypto";

-- Clean Slate (Optional: Uncomment if you want to wipe everything)
-- drop table if exists medi_stock_movements;
-- drop table if exists medi_sales_items;
-- drop table if exists medi_sales_invoices;
-- drop table if exists medi_purchase_items;
-- drop table if exists medi_purchase_invoices;
-- drop table if exists medi_batches;
-- drop table if exists medi_products;
-- drop table if exists medi_profiles;
-- drop table if exists medi_tenants;

-- ==========================================
-- 2. CORE MULTI-TENANCY
-- ==========================================

create table medi_tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  phone text,
  gstin text, -- Tenant's own GSTIN
  created_at timestamp with time zone default now()
);

create table medi_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  tenant_id uuid references medi_tenants(id) on delete cascade,
  role text not null check (role in ('super_admin', 'admin', 'staff')) default 'staff',
  name text,
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 3. INVENTORY MASTER
-- ==========================================

create table medi_products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  name text not null,
  barcode text,
  hsn_code text,
  category text,
  gst_percent numeric default 12,
  created_at timestamp with time zone default now(),
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
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 4. STOCK MOVEMENTS (The Ledger)
-- ==========================================

create table medi_stock_movements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  batch_id uuid references medi_batches(id) on delete cascade,
  type text not null check (type in ('purchase', 'sale', 'return_in', 'return_out', 'adjustment')),
  quantity integer not null, -- Positive for in, negative for out
  reference_id uuid, -- link to invoice_id or sale_id
  reason text,
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 5. PURCHASE FLOW
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
  created_at timestamp with time zone default now()
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
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 6. SALES FLOW (POS)
-- ==========================================

create table medi_sales_invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references medi_tenants(id) on delete cascade,
  invoice_number text not null, -- Unique per tenant
  customer_name text,
  customer_phone text,
  total_amount numeric not null default 0,
  tax_amount numeric not null default 0,
  discount_amount numeric default 0,
  payment_mode text check (payment_mode in ('cash', 'card', 'upi')),
  created_at timestamp with time zone default now(),
  unique (tenant_id, invoice_number)
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
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 7. SECURITY (RLS) & RBAC
-- ==========================================

-- Helper: Get Tenant ID
create or replace function public.get_tenant_id() returns uuid as $$
  select tenant_id from public.medi_profiles where id = auth.uid();
$$ language sql stable security definer;

-- Helper: Get Role
create or replace function public.get_role() returns text as $$
  select role from public.medi_profiles where id = auth.uid();
$$ language sql stable security definer;

-- Enable Row Level Security
alter table medi_tenants enable row level security;
alter table medi_profiles enable row level security;
alter table medi_products enable row level security;
alter table medi_batches enable row level security;
alter table medi_stock_movements enable row level security;
alter table medi_purchase_invoices enable row level security;
alter table medi_sales_invoices enable row level security;
alter table medi_purchase_items enable row level security;
alter table medi_sales_items enable row level security;

-- Policies: Tenants & Profiles
drop policy if exists "Tenants: Read access" on medi_tenants;
create policy "Tenants: Read access" on medi_tenants for select using (true);

drop policy if exists "Tenants: Allow signup" on medi_tenants;
create policy "Tenants: Allow signup" on medi_tenants for insert with check (true);

drop policy if exists "Profiles: Read own profile" on medi_profiles;
create policy "Profiles: Read own profile" on medi_profiles for select using (id = auth.uid());

-- Policies: Products
create policy "Products: Tenant Read" on medi_products for select using (tenant_id = public.get_tenant_id());
create policy "Products: Admin Manage" on medi_products for all using (tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin'));

-- Policies: Batches
create policy "Batches: Tenant Read" on medi_batches for select using (tenant_id = public.get_tenant_id());
create policy "Batches: Standard Insert" on medi_batches for insert with check (tenant_id = public.get_tenant_id());
create policy "Batches: Admin Update/Delete" on medi_batches for update using (tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin'));

-- Policies: Stock Movements
create policy "Movements: Tenant Access" on medi_stock_movements for all using (tenant_id = public.get_tenant_id());

-- Policies: Purchases
create policy "Purchases: Read access" on medi_purchase_invoices for select using (tenant_id = public.get_tenant_id());
create policy "Purchases: Insert access" on medi_purchase_invoices for insert with check (tenant_id = public.get_tenant_id());
create policy "Purchases: Admin Delete" on medi_purchase_invoices for delete using (tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin'));

-- Policies: Sales
create policy "Sales: Read access" on medi_sales_invoices for select using (tenant_id = public.get_tenant_id());
create policy "Sales: Insert access" on medi_sales_invoices for insert with check (tenant_id = public.get_tenant_id());
create policy "Sales: Admin Delete" on medi_sales_invoices for delete using (tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin'));

-- Policies: Item Details (Security via parent invoice)
create policy "Purchase Items: Security" on medi_purchase_items for all using (exists (select 1 from medi_purchase_invoices i where i.id = invoice_id and i.tenant_id = public.get_tenant_id()));
create policy "Sales Items: Security" on medi_sales_items for all using (exists (select 1 from medi_sales_invoices i where i.id = invoice_id and i.tenant_id = public.get_tenant_id()));

-- ==========================================
-- 8. AUTOMATION (Triggers)
-- ==========================================

-- Trigger: Update Batch Quantity
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

-- Trigger: Handle New Auth User
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.medi_profiles (id, tenant_id, role)
  values (new.id, (new.raw_user_meta_data->>'tenant_id')::uuid, coalesce(new.raw_user_meta_data->>'role', 'staff'));
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
