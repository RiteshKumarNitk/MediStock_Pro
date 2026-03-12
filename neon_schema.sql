-- ==========================================
-- 1. INITIAL SETUP & EXTENSIONS
-- ==========================================
create extension if not exists "pgcrypto";

-- ==========================================
-- 2. CORE MULTI-TENANCY & AUTH (Custom)
-- ==========================================

create table if not exists public.medi_tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text,
  phone text,
  gstin text,
  created_at timestamp with time zone default now()
);

-- Custom Users table to replace auth.users
create table if not exists public.medi_users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  password_hash text not null,
  created_at timestamp with time zone default now()
);

create table if not exists public.medi_profiles (
  id uuid primary key references public.medi_users(id) on delete cascade,
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
-- 7. AUTOMATION (Triggers & Functions)
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
$$ language plpgsql;

-- Drop and recreate trigger
drop trigger if exists tr_update_batch_qty on public.medi_stock_movements;
create trigger tr_update_batch_qty
after insert on public.medi_stock_movements
for each row execute procedure public.update_batch_qty();
