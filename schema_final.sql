-- ==========================================
-- 1. INITIAL SETUP & EXTENSIONS
-- ==========================================
create extension if not exists "pgcrypto";

-- ==========================================
-- 2. CORE MULTI-TENANCY (Tables)
-- ==========================================

create table if not exists public.medi_tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  phone text,
  gstin text,
  created_at timestamp with time zone default now()
);

create table if not exists public.medi_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  tenant_id uuid references public.medi_tenants(id) on delete cascade,
  role text not null check (role in ('super_admin', 'admin', 'staff')) default 'staff',
  name text,
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 3. INVENTORY MASTER
-- ==========================================

create table if not exists public.medi_products (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.medi_tenants(id) on delete cascade,
  name text not null,
  barcode text,
  hsn_code text,
  category text,
  gst_percent numeric default 12,
  created_at timestamp with time zone default now(),
  unique (tenant_id, name),
  unique (tenant_id, barcode)
);

create table if not exists public.medi_batches (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.medi_tenants(id) on delete cascade,
  product_id uuid references public.medi_products(id) on delete cascade,
  batch_no text not null,
  expiry_date date not null,
  quantity integer not null default 0,
  purchase_price numeric,
  mrp numeric,
  selling_price numeric,
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 4. STOCK MOVEMENTS
-- ==========================================

create table if not exists public.medi_stock_movements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.medi_tenants(id) on delete cascade,
  batch_id uuid references public.medi_batches(id) on delete cascade,
  type text not null check (type in ('purchase', 'sale', 'return_in', 'return_out', 'adjustment')),
  quantity integer not null,
  reference_id uuid,
  reason text,
  created_at timestamp with time zone default now()
);

-- ==========================================
-- 5. PURCHASE FLOW
-- ==========================================

create table if not exists public.medi_purchase_invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.medi_tenants(id) on delete cascade,
  invoice_number text not null,
  vendor_name text,
  vendor_gstin text,
  total_amount numeric not null default 0,
  tax_amount numeric not null default 0,
  image_url text,
  created_at timestamp with time zone default now()
);

create table if not exists public.medi_purchase_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references public.medi_purchase_invoices(id) on delete cascade,
  product_id uuid references public.medi_products(id),
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

create table if not exists public.medi_sales_invoices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid references public.medi_tenants(id) on delete cascade,
  invoice_number text not null,
  customer_name text,
  customer_phone text,
  total_amount numeric not null default 0,
  tax_amount numeric not null default 0,
  discount_amount numeric default 0,
  payment_mode text check (payment_mode in ('cash', 'card', 'upi')),
  created_at timestamp with time zone default now(),
  unique (tenant_id, invoice_number)
);

create table if not exists public.medi_sales_items (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid references public.medi_sales_invoices(id) on delete cascade,
  batch_id uuid references public.medi_batches(id),
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

-- Enable Row Level Security (Always safe to run)
alter table public.medi_tenants enable row level security;
alter table public.medi_profiles enable row level security;
alter table public.medi_products enable row level security;
alter table public.medi_batches enable row level security;
alter table public.medi_stock_movements enable row level security;
alter table public.medi_purchase_invoices enable row level security;
alter table public.medi_sales_invoices enable row level security;
alter table public.medi_purchase_items enable row level security;
alter table public.medi_sales_items enable row level security;

-- Clean existing policies to avoid conflicts
do $$
begin
  -- Drop policies if they exist (safe way)
  drop policy if exists "Tenants: Read access" on medi_tenants;
  drop policy if exists "Tenants: Allow signup" on medi_tenants;
  drop policy if exists "Profiles: Read own profile" on medi_profiles;
  drop policy if exists "Products: Tenant Read" on medi_products;
  drop policy if exists "Products: Admin Manage" on medi_products;
  drop policy if exists "Batches: Tenant Read" on medi_batches;
  drop policy if exists "Batches: Standard Insert" on medi_batches;
  drop policy if exists "Batches: Admin Update/Delete" on medi_batches;
  drop policy if exists "Movements: Tenant Access" on medi_stock_movements;
  drop policy if exists "Purchases: Read access" on medi_purchase_invoices;
  drop policy if exists "Purchases: Insert access" on medi_purchase_invoices;
  drop policy if exists "Purchases: Admin Delete" on medi_purchase_invoices;
  drop policy if exists "Sales: Read access" on medi_sales_invoices;
  drop policy if exists "Sales: Insert access" on medi_sales_invoices;
  drop policy if exists "Sales: Admin Delete" on medi_sales_invoices;
  drop policy if exists "Purchase Items: Security" on medi_purchase_items;
  drop policy if exists "Sales Items: Security" on medi_sales_items;
exception when others then null;
end $$;

-- 1. Tenants Policies
create policy "Tenants: Read access" on public.medi_tenants for select using (true);
create policy "Tenants: Allow signup" on public.medi_tenants for insert with check (true);

-- 2. Profiles Policies
create policy "Profiles: Read own profile" on public.medi_profiles for select using (id = auth.uid());

-- 3. Products Policies
create policy "Products: Tenant Read" on public.medi_products for select using (tenant_id = public.get_tenant_id());
create policy "Products: Admin Manage" on public.medi_products for all using (tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin'));

-- 4. Batches Policies
create policy "Batches: Tenant Read" on public.medi_batches for select using (tenant_id = public.get_tenant_id());
create policy "Batches: Standard Insert" on public.medi_batches for insert with check (tenant_id = public.get_tenant_id());
create policy "Batches: Admin Update/Delete" on public.medi_batches for update using (tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin'));

-- 5. Stock Movements Policies
create policy "Movements: Tenant Access" on public.medi_stock_movements for all using (tenant_id = public.get_tenant_id());

-- 6. Purchases Policies
create policy "Purchases: Read access" on public.medi_purchase_invoices for select using (tenant_id = public.get_tenant_id());
create policy "Purchases: Insert access" on public.medi_purchase_invoices for insert with check (tenant_id = public.get_tenant_id());
create policy "Purchases: Admin Delete" on public.medi_purchase_invoices for delete using (tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin'));

-- 7. Sales Policies
create policy "Sales: Read access" on public.medi_sales_invoices for select using (tenant_id = public.get_tenant_id());
create policy "Sales: Insert access" on public.medi_sales_invoices for insert with check (tenant_id = public.get_tenant_id());
create policy "Sales: Admin Delete" on public.medi_sales_invoices for delete using (tenant_id = public.get_tenant_id() and public.get_role() in ('admin', 'super_admin'));

-- 8. Item Details Policies
create policy "Purchase Items: Security" on public.medi_purchase_items for all using (exists (select 1 from public.medi_purchase_invoices i where i.id = invoice_id and i.tenant_id = public.get_tenant_id()));
create policy "Sales Items: Security" on public.medi_sales_items for all using (exists (select 1 from public.medi_sales_invoices i where i.id = invoice_id and i.tenant_id = public.get_tenant_id()));

-- ==========================================
-- 8. AUTOMATION (Triggers & Functions)
-- ==========================================

-- Function: Update Batch Quantity
create or replace function public.update_batch_qty()
returns trigger as $$
begin
  update public.medi_batches 
  set quantity = quantity + new.quantity
  where id = new.batch_id;
  return new;
end;
$$ language plpgsql security definer;

-- Drop and recreate trigger
drop trigger if exists tr_update_batch_qty on public.medi_stock_movements;
create trigger tr_update_batch_qty
after insert on public.medi_stock_movements
for each row execute procedure public.update_batch_qty();

-- Function: Handle New Auth User
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.medi_profiles (id, tenant_id, role)
  values (new.id, (new.raw_user_meta_data->>'tenant_id')::uuid, coalesce(new.raw_user_meta_data->>'role', 'staff'));
  return new;
end;
$$ language plpgsql security definer;

-- Drop and recreate trigger
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
