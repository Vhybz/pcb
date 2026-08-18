# Supabase Schema - PCB Defect Scanner

## Tables

### 1. `profiles`
Stores user-specific information.
- `id`: uuid (primary key, references auth.users.id)
- `full_name`: text
- `institution`: text (e.g., "Sunyani Technical University")
- `avatar_url`: text
- `updated_at`: timestamp with time zone

### 2. `inspections`
Stores metadata for each PCB scan.
- `id`: uuid (primary key, default gen_random_uuid())
- `user_id`: uuid (references auth.users.id)
- `timestamp`: timestamp with time zone (default now())
- `status`: text (e.g., 'pass', 'fail')
- `image_url`: text (URL to the stored image in Supabase Storage)
- `device_info`: jsonb (optional metadata about the device)

### 3. `defects`
Stores individual defect findings for an inspection.
- `id`: uuid (primary key, default gen_random_uuid())
- `inspection_id`: uuid (references inspections.id, on delete cascade)
- `class_name`: text (e.g., 'mouse_bite', 'short')
- `confidence`: float4
- `severity`: text (e.g., 'low', 'medium', 'high')
- `location_info`: text (textual description of location)
- `bounding_box`: jsonb (stores {x, y, width, height})

## Storage Buckets

### `pcb_images`
- Stores original images taken during scans.
- Access Policy: Authenticated users can read their own images; can upload to their own folder.

## Database Functions & Triggers

### `handle_new_user()`
Automatically creates a profile entry when a new user signs up.

```sql
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

## RLDP (Row Level Security Policies)

- **Inspections**: `auth.uid() == user_id` for Select, Insert.
- **Defects**: Select based on parent inspection accessibility.
- **Profiles**: `auth.uid() == id` for Select, Update.
