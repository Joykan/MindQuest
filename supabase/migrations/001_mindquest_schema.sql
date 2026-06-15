CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- PROFILES
-- ============================================================
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  display_name TEXT,
  avatar_url TEXT,
  language TEXT DEFAULT 'en' CHECK (language IN ('en', 'sw')),
  age_group TEXT,
  county TEXT,
  bio TEXT,
  is_anonymous BOOLEAN DEFAULT FALSE,
  onboarding_complete BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- USER STATS
-- ============================================================
CREATE TABLE public.user_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  xp INTEGER DEFAULT 0 CHECK (xp >= 0),
  level INTEGER DEFAULT 1 CHECK (level >= 1),
  tier TEXT DEFAULT 'Newcomer' CHECK (tier IN ('Newcomer','Explorer','Warrior','Mind Master','Legend')),
  streak_days INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_sessions INTEGER DEFAULT 0,
  total_moods_logged INTEGER DEFAULT 0,
  last_active_date DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- BADGES
-- ============================================================
CREATE TABLE public.badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_sw TEXT,
  description TEXT,
  description_sw TEXT,
  icon_url TEXT,
  xp_reward INTEGER DEFAULT 50,
  category TEXT CHECK (category IN ('milestone','streak','mood','chat','quest','special')),
  criteria JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  badge_id UUID NOT NULL REFERENCES public.badges(id),
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, badge_id)
);

-- ============================================================
-- QUESTS
-- ============================================================
CREATE TABLE public.quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  title_sw TEXT,
  description TEXT,
  description_sw TEXT,
  xp_reward INTEGER DEFAULT 100,
  badge_id UUID REFERENCES public.badges(id),
  quest_type TEXT CHECK (quest_type IN ('daily','weekly','milestone','challenge')),
  steps JSONB,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_quests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  quest_id UUID NOT NULL REFERENCES public.quests(id),
  status TEXT DEFAULT 'in_progress' CHECK (status IN ('in_progress','completed','failed','skipped')),
  progress INTEGER DEFAULT 0,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  UNIQUE(user_id, quest_id)
);

-- ============================================================
-- MOOD LOGS
-- ============================================================
CREATE TABLE public.mood_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  mood_value INTEGER NOT NULL CHECK (mood_value BETWEEN 1 AND 5),
  mood_label TEXT NOT NULL,
  note TEXT,
  energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 5),
  tags TEXT[],
  logged_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- CHAT SESSIONS & MESSAGES
-- ============================================================
CREATE TABLE public.chat_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT,
  language TEXT DEFAULT 'en',
  is_crisis BOOLEAN DEFAULT FALSE,
  crisis_acknowledged BOOLEAN DEFAULT FALSE,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  message_count INTEGER DEFAULT 0
);

CREATE TABLE public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user','assistant')),
  content TEXT NOT NULL,
  is_crisis_flagged BOOLEAN DEFAULT FALSE,
  sentiment_score FLOAT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- RESOURCES
-- ============================================================
CREATE TABLE public.resources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  title_sw TEXT,
  content TEXT,
  content_sw TEXT,
  category TEXT CHECK (category IN ('article','exercise','video','helpline','tip')),
  tags TEXT[],
  is_featured BOOLEAN DEFAULT FALSE,
  view_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_resource_interactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  resource_id UUID NOT NULL REFERENCES public.resources(id),
  interaction_type TEXT CHECK (interaction_type IN ('viewed','bookmarked','completed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, resource_id, interaction_type)
);

-- ============================================================
-- CRISIS CONTACTS
-- ============================================================
CREATE TABLE public.crisis_contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_sw TEXT,
  phone TEXT,
  description TEXT,
  description_sw TEXT,
  available_hours TEXT DEFAULT '24/7',
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0
);

CREATE TABLE public.crisis_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  session_id UUID REFERENCES public.chat_sessions(id),
  trigger_keywords TEXT[],
  action_taken TEXT,
  acknowledged_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- DAILY CHECK-INS
-- ============================================================
CREATE TABLE public.daily_checkins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  checkin_date DATE NOT NULL DEFAULT CURRENT_DATE,
  mood_log_id UUID REFERENCES public.mood_logs(id),
  gratitude_note TEXT,
  goal_for_day TEXT,
  completed BOOLEAN DEFAULT FALSE,
  xp_awarded INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, checkin_date)
);

-- ============================================================
-- ACID TRANSACTION FUNCTIONS
-- ============================================================

-- Award XP + level up atomically
CREATE OR REPLACE FUNCTION award_xp_and_check_levelup(
  p_user_id UUID,
  p_xp_amount INTEGER,
  p_badge_id UUID DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_new_xp INTEGER;
  v_new_level INTEGER;
  v_new_tier TEXT;
  v_leveled_up BOOLEAN := FALSE;
  v_badge_awarded BOOLEAN := FALSE;
BEGIN
  UPDATE public.user_stats
  SET xp = xp + p_xp_amount, updated_at = NOW()
  WHERE user_id = p_user_id
  RETURNING xp INTO v_new_xp;

  v_new_level := GREATEST(1, (v_new_xp / 500) + 1);

  v_new_tier := CASE
    WHEN v_new_xp < 500  THEN 'Newcomer'
    WHEN v_new_xp < 1500 THEN 'Explorer'
    WHEN v_new_xp < 3000 THEN 'Warrior'
    WHEN v_new_xp < 5000 THEN 'Mind Master'
    ELSE 'Legend'
  END;

  UPDATE public.user_stats
  SET level = v_new_level, tier = v_new_tier, updated_at = NOW()
  WHERE user_id = p_user_id;

  IF p_badge_id IS NOT NULL THEN
    INSERT INTO public.user_badges(user_id, badge_id)
    VALUES (p_user_id, p_badge_id)
    ON CONFLICT DO NOTHING;
    GET DIAGNOSTICS v_badge_awarded = ROW_COUNT;
  END IF;

  RETURN jsonb_build_object(
    'new_xp', v_new_xp,
    'new_level', v_new_level,
    'new_tier', v_new_tier,
    'leveled_up', v_leveled_up,
    'badge_awarded', v_badge_awarded
  );
END;
$$;

-- Complete daily check-in atomically
CREATE OR REPLACE FUNCTION complete_daily_checkin(
  p_user_id UUID,
  p_mood_value INTEGER,
  p_mood_label TEXT,
  p_note TEXT DEFAULT NULL,
  p_gratitude TEXT DEFAULT NULL,
  p_goal TEXT DEFAULT NULL
) RETURNS JSONB
LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_mood_id UUID;
  v_checkin_id UUID;
  v_last_active DATE;
  v_new_streak INTEGER;
  v_xp_result JSONB;
BEGIN
  INSERT INTO public.mood_logs(user_id, mood_value, mood_label, note)
  VALUES (p_user_id, p_mood_value, p_mood_label, p_note)
  RETURNING id INTO v_mood_id;

  INSERT INTO public.daily_checkins(user_id, checkin_date, mood_log_id, gratitude_note, goal_for_day, completed, xp_awarded)
  VALUES (p_user_id, CURRENT_DATE, v_mood_id, p_gratitude, p_goal, TRUE, 30)
  ON CONFLICT (user_id, checkin_date)
  DO UPDATE SET mood_log_id = v_mood_id, gratitude_note = p_gratitude,
    goal_for_day = p_goal, completed = TRUE, xp_awarded = 30
  RETURNING id INTO v_checkin_id;

  SELECT last_active_date INTO v_last_active
  FROM public.user_stats WHERE user_id = p_user_id;

  IF v_last_active = CURRENT_DATE - 1 THEN
    UPDATE public.user_stats
    SET streak_days = streak_days + 1,
        longest_streak = GREATEST(longest_streak, streak_days + 1),
        total_moods_logged = total_moods_logged + 1,
        last_active_date = CURRENT_DATE,
        updated_at = NOW()
    WHERE user_id = p_user_id
    RETURNING streak_days INTO v_new_streak;
  ELSE
    UPDATE public.user_stats
    SET streak_days = 1,
        total_moods_logged = total_moods_logged + 1,
        last_active_date = CURRENT_DATE,
        updated_at = NOW()
    WHERE user_id = p_user_id;
    v_new_streak := 1;
  END IF;

  v_xp_result := award_xp_and_check_levelup(p_user_id, 30);

  RETURN jsonb_build_object(
    'mood_id', v_mood_id,
    'checkin_id', v_checkin_id,
    'streak', v_new_streak,
    'xp_result', v_xp_result
  );
END;
$$;

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mood_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_quests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_checkins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crisis_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_resource_interactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "own profile"   ON public.profiles       FOR ALL USING (auth.uid() = id);
CREATE POLICY "own stats"     ON public.user_stats     FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own moods"     ON public.mood_logs      FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own sessions"  ON public.chat_sessions  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own messages"  ON public.chat_messages  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own badges"    ON public.user_badges    FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own quests"    ON public.user_quests    FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own checkins"  ON public.daily_checkins FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own crisis"    ON public.crisis_events  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "own resources" ON public.user_resource_interactions FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "public badges"    ON public.badges          FOR SELECT USING (true);
CREATE POLICY "public quests"    ON public.quests          FOR SELECT USING (true);
CREATE POLICY "public resources" ON public.resources       FOR SELECT USING (true);
CREATE POLICY "public crisis"    ON public.crisis_contacts FOR SELECT USING (true);

-- ============================================================
-- SEED: Badges
-- ============================================================
INSERT INTO public.badges (name, name_sw, description, description_sw, xp_reward, category) VALUES
('First Step',      'Hatua ya Kwanza',    'Completed your first check-in',          'Umekamilisha check-in yako ya kwanza',  50,  'milestone'),
('Week Warrior',    'Shujaa wa Wiki',     '7-day streak achieved',                  'Streak ya siku 7',                      150, 'streak'),
('Mind Explorer',   'Mchunguzi wa Akili', 'Sent 10 messages to MindQuest AI',       'Umetuma ujumbe 10 kwa AI',              100, 'chat'),
('Mood Tracker',    'Mfuatiliaji Hisia',  'Logged mood 7 days in a row',            'Umerekodia hisia siku 7 mfululizo',     120, 'mood'),
('Quest Completer', 'Mkamilishaji',       'Completed your first quest',             'Umekamilisha dhamira yako ya kwanza',   200, 'quest'),
('Resilience Star', 'Nyota ya Nguvu',     'Reached Explorer tier',                  'Umefika ngazi ya Explorer',             300, 'milestone'),
('Mind Master',     'Bwana wa Akili',     'Reached Mind Master tier',               'Umefika ngazi ya Mind Master',          500, 'milestone'),
('Crisis Helper',   'Msaidizi Dharura',   'Used the crisis support feature',        'Umetumia kipengele cha dharura',        75,  'special');

-- ============================================================
-- SEED: Crisis Contacts
-- ============================================================
INSERT INTO public.crisis_contacts (name, name_sw, phone, description, description_sw, available_hours, sort_order) VALUES
('Befrienders Kenya',    'Befrienders Kenya',         '0800 723 253',      'Free emotional support helpline',        'Mstari wa bure wa msaada wa kihisia',   '24/7',              1),
('Kenya Crisis Helpline','Mstari wa Dharura Kenya',   '1190',              'National mental health crisis line',     'Mstari wa kitaifa wa dharura ya akili', '24/7',              2),
('AMREF Health Africa',  'AMREF Health Africa',       '+254 20 699 0000',  'Health support and referrals',           'Msaada wa afya na rufaa',               'Mon-Fri 8AM-5PM',   3),
('Kenya Red Cross',      'Msalaba Mwekundu wa Kenya', '+254 20 395 0000',  'Psychosocial support services',          'Huduma za msaada wa kisaikolojia',      '24/7',              4),
('Chiromo Lane Medical', 'Chiromo Lane Medical',      '+254 20 386 2724',  'Psychiatric and mental health services', 'Huduma za magonjwa ya akili',           'Mon-Sat 8AM-8PM',   5);

-- ============================================================
-- SEED: Quests
-- ============================================================
INSERT INTO public.quests (title, title_sw, description, description_sw, xp_reward, quest_type) VALUES
('Morning Mindfulness', 'Utulivu wa Asubuhi', 'Log your mood for 3 consecutive mornings', 'Rekodi hisia zako kwa asubuhi 3 mfululizo', 150, 'daily'),
('Chat Champion',       'Bingwa wa Mazungumzo','Have 5 conversations with MindQuest AI',  'Fanya mazungumzo 5 na MindQuest AI',        200, 'weekly'),
('Wellness Explorer',   'Mchunguzi wa Afya',  'Read 3 wellness articles',                 'Soma makala 3 za afya',                     100, 'weekly'),
('Gratitude Journey',   'Safari ya Shukrani', 'Write a gratitude note for 5 days',        'Andika maelezo ya shukrani kwa siku 5',     250, 'milestone');

-- ============================================================
-- SEED: Resources
-- ============================================================
INSERT INTO public.resources (title, title_sw, content, content_sw, category, tags, is_featured) VALUES
('5 Breathing Exercises for Anxiety',
 'Mazoezi 5 ya Kupumua kwa Wasiwasi',
 'Deep breathing activates your parasympathetic nervous system, helping your body calm down naturally. Try box breathing: inhale for 4 counts, hold for 4, exhale for 4, hold for 4. Repeat 4 times.',
 'Kupumua kwa kina kunasaidia mwili wako kutulia. Jaribu kupumua kwa mstatili: pumua ndani kwa hesabu 4, shikilia kwa 4, toa pumzi kwa 4, subiri kwa 4.',
 'exercise', ARRAY['anxiety','breathing','mindfulness'], TRUE),

('Understanding Depression in Youth',
 'Kuelewa Unyogovu kwa Vijana',
 'Depression is more than just feeling sad. It affects how you think, feel, and handle daily activities. Common signs include persistent sadness, loss of interest, changes in sleep or appetite, and difficulty concentrating.',
 'Unyogovu ni zaidi ya kuhisi huzuni. Unaathiri jinsi unavyofikiri, kuhisi, na kushughulikia shughuli za kila siku.',
 'article', ARRAY['depression','youth','awareness'], TRUE),

('Box Breathing Technique',
 'Mbinu ya Kupumua kwa Mstatili',
 'Box breathing is a simple technique used by athletes and military personnel to stay calm under pressure. Inhale 4 counts, hold 4, exhale 4, hold 4. Repeat 4-8 times.',
 'Kupumua kwa mstatili ni mbinu rahisi ya kutulia chini ya shinikizo.',
 'exercise', ARRAY['breathing','calm','quick'], FALSE),

('Building Emotional Resilience',
 'Kujenga Ustahimilivu wa Kihisia',
 'Resilience is the ability to bounce back from adversity. Build it by maintaining connections, accepting change, taking action, and nurturing a positive view of yourself.',
 'Ustahimilivu ni uwezo wa kurudi nyuma kutoka kwa msongo. Uijengelee kwa kudumisha mahusiano na kuwa na mtazamo mzuri.',
 'article', ARRAY['resilience','coping','strength'], TRUE),

('The 5-4-3-2-1 Grounding Technique',
 'Mbinu ya 5-4-3-2-1 ya Kujiimarisha',
 'When anxiety strikes, ground yourself: Name 5 things you can see, 4 you can touch, 3 you can hear, 2 you can smell, 1 you can taste. This brings you back to the present moment.',
 'Unapohisi wasiwasi: taja vitu 5 unavyoviona, 4 unavyoweza kugusa, 3 unazosikia, 2 unazosogomea, 1 unayoionja.',
 'exercise', ARRAY['grounding','anxiety','coping'], FALSE),

('Sleep and Mental Health',
 'Usingizi na Afya ya Akili',
 'Poor sleep and mental health are closely linked. Aim for 7-9 hours per night. Establish a bedtime routine, avoid screens 1 hour before bed, and keep your room cool and dark.',
 'Usingizi mbaya na afya ya akili vimeunganishwa kwa karibu. Lengo ni masaa 7-9 kila usiku.',
 'tip', ARRAY['sleep','mental health','routine'], FALSE);
