# Supabase SQL Schema - PCB Defect Scanner

Copy and paste the following SQL into your **Supabase SQL Editor** to set up your database and storage policies.

```sql
-- ==========================================
-- 1. RESET (Optional - Use with caution)
-- ==========================================
-- DROP TABLE IF EXISTS public.defects;
-- DROP TABLE IF EXISTS public.inspections;
-- DROP TABLE IF EXISTS public.profiles;

-- ==========================================
-- 2. TABLES DEFINITIONS
-- ==========================================

-- Profiles: Extended user data
CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username text UNIQUE,
  email text,
  phone text,
  profession text,
  avatar_url text, -- URL for profile picture
  updated_at timestamp with time zone DEFAULT now()
);

-- Inspections: Header records for scans
CREATE TABLE IF NOT EXISTS public.inspections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  timestamp timestamp with time zone DEFAULT now(),
  status text CHECK (status IN ('pass', 'fail')),
  image_url text, -- Link to pcb_images bucket
  device_info jsonb,
  defect_count int DEFAULT 0
);

-- Defects: Detailed findings for each inspection
CREATE TABLE IF NOT EXISTS public.defects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  inspection_id uuid REFERENCES public.inspections(id) ON DELETE CASCADE,
  class_name text NOT NULL,
  confidence float4 NOT NULL,
  severity text CHECK (severity IN ('low', 'medium', 'high')),
  location_info text,
  bounding_box jsonb NOT NULL -- Format: {"x": 0.1, "y": 0.2, "w": 0.05, "h": 0.05}
);

-- ==========================================
-- 3. STORAGE BUCKETS SETUP
-- ==========================================
-- Create buckets for images (You can also do this in the Supabase UI)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('pcb_images', 'pcb_images', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- 4. AUTH TRIGGERS
-- ==========================================

-- Function to automatically create a profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, email)
  VALUES (
    new.id, 
    new.raw_user_meta_data->>'username', 
    new.email
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to execute function after auth.users insert
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ==========================================
-- 5. SECURITY (RLS)
-- ==========================================

-- For development, we disable RLS to allow direct testing from Flutter
ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.inspections DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.defects DISABLE ROW LEVEL SECURITY;

-- Storage Policies (Allow all for development)
CREATE POLICY "Public Access" ON storage.objects FOR ALL USING (true);
```

## Implementation Notes

### User Fields Reference
The `profiles` table now supports all requested fields:
- `username`
- `email`
- `phone`
- `profession`
- `avatar_url` (For the profile picture)

### Saving Scanned Images
- Upload images to the `pcb_images` bucket.
- Store the resulting URL in `inspections.image_url`.

### Updating Profile Picture
- Upload the new photo to the `avatars` bucket.
- Update the `avatar_url` field in the `profiles` table for the corresponding user.
 db+++ blessingtig007@gmail.com
- host   same