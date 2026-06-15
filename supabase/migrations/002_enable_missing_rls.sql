-- ============================================================
-- 002: Enable RLS on tables that were missing it
-- Run this in your Supabase SQL Editor to fix RLS warnings
-- ============================================================

-- These tables had policies created but RLS was never enabled
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crisis_contacts ENABLE ROW LEVEL SECURITY;

-- Verify: existing policies should now be enforced
-- public.badges     → "public badges" (SELECT for all)
-- public.quests     → "public quests" (SELECT for all)  
-- public.resources  → "public resources" (SELECT for all)
-- public.crisis_contacts → "public crisis" (SELECT for all)
