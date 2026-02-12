# MediStock Pro - Multi-Tenant Architecture

## Overview
MediStock Pro uses a **Row Level Security (RLS)** based multi-tenant architecture on Supabase. This ensures that each medical store (tenant) can only access its own data, even though all data resides in the same database tables.

## Core Concepts

### 1. Tenants
- **Table**: `tenants`
- Represents a single medical store.
- Identified by a unique `id` (UUID).

### 2. User-Tenant Linking
- **Table**: `profiles`
- Links a Supabase Auth user (`auth.users`) to a specific Tenant (`tenants`).
- Every query uses this link to determine which data the user can access.

### 3. Data Isolation
- **Tables**: `products`, `batches`
- Every business table includes a `tenant_id` column.
- **RLS Policies**: Automatically filter rows based on the logged-in user's `tenant_id`.

## Database Schema

### Tables

#### `tenants`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID | Primary Key |
| `name` | Text | Store Name |

#### `profiles`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID | References `auth.users(id)` |
| `tenant_id` | UUID | References `tenants(id)` |
| `role` | Text | User Role (e.g., Admin, Staff) |

#### `products`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID | Primary Key |
| `tenant_id` | UUID | References `tenants(id)` |
| `barcode` | Text | Unique per tenant |

#### `batches`
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | UUID | Primary Key |
| `tenant_id` | UUID | References `tenants(id)` |
| `product_id` | UUID | References `products(id)` |
| `expiry_date` | Date | Expiry Date |

### Views

#### `expiry_alerts`
A view that lists batches expiring within 30 days.
- **Columns**: `tenant_id`, `product_name`, `batch_no`, `expiry_date`, `quantity`, `days_remaining`
- **Security**: Inherits RLS from underlying tables (Supabase Auth context mimics the user).

## Security Policies (RLS)

### Generic Policy Pattern
```sql
using (
  tenant_id = (
    select tenant_id from profiles
    where id = auth.uid()
  )
)
```
This policy is applied to `products` and `batches` to ensure users can only Select, Insert, Update, or Delete rows belonging to their assigned tenant.

## Usage (Frontend)

When querying from the frontend (e.g., Flutter), **you do not need to manually filter by `tenant_id`**. The RLS policy automatically handles it.

```dart
// Example: Fetching expiry alerts
final expiry = await supabase
  .from('expiry_alerts')
  .select();
// Returns only data for the user's tenant
```
