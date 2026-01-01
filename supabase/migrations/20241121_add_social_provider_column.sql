-- Add social_provider column to users table
-- This column stores the social login provider (e.g., 'GOOGLE', 'APPLE')
ALTER TABLE public.users ADD COLUMN social_provider text;
