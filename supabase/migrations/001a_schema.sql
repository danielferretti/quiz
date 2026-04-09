-- ============================================================
-- Part 1: Tables, Views, RLS, Triggers (no seed data)
-- ============================================================

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT 'Jogador',
  role TEXT NOT NULL DEFAULT 'Personal Banker',
  avatar TEXT NOT NULL DEFAULT '🧑‍💼',
  photo_url TEXT,
  level INTEGER NOT NULL DEFAULT 1,
  xp INTEGER NOT NULL DEFAULT 0,
  coins INTEGER NOT NULL DEFAULT 50,
  total_points INTEGER NOT NULL DEFAULT 0,
  wins INTEGER NOT NULL DEFAULT 0,
  games_played INTEGER NOT NULL DEFAULT 0,
  has_perfect_match BOOLEAN NOT NULL DEFAULT FALSE,
  has_combo_x3 BOOLEAN NOT NULL DEFAULT FALSE,
  max_combo INTEGER NOT NULL DEFAULT 0,
  streak_count INTEGER NOT NULL DEFAULT 0,
  streak_last_date DATE,
  settings JSONB NOT NULL DEFAULT '{"sfx":true,"music":false,"vibration":true,"notifications":true,"privateProfile":false}',
  tutorial_seen BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.topic_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  topic_key TEXT NOT NULL,
  points INTEGER NOT NULL DEFAULT 0,
  played INTEGER NOT NULL DEFAULT 0,
  UNIQUE(user_id, topic_key)
);

CREATE TABLE public.matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  topic_key TEXT NOT NULL,
  opponent_name TEXT NOT NULL,
  player_score INTEGER NOT NULL DEFAULT 0,
  opponent_score INTEGER NOT NULL DEFAULT 0,
  correct_count INTEGER NOT NULL DEFAULT 0,
  max_combo INTEGER NOT NULL DEFAULT 0,
  result TEXT NOT NULL CHECK (result IN ('win', 'loss', 'draw')),
  points_earned INTEGER NOT NULL DEFAULT 0,
  coins_earned INTEGER NOT NULL DEFAULT 0,
  played_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_photo TEXT,
  message TEXT NOT NULL CHECK (char_length(message) <= 500),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  read BOOLEAN NOT NULL DEFAULT FALSE,
  data JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_matches_user ON public.matches(user_id, played_at DESC);
CREATE INDEX idx_chat_created ON public.chat_messages(created_at DESC);
CREATE INDEX idx_notifications_user ON public.notifications(user_id, read, created_at DESC);
CREATE INDEX idx_topic_stats_user ON public.topic_stats(user_id);
CREATE INDEX idx_profiles_points ON public.profiles(total_points DESC);

-- Leaderboard views
CREATE MATERIALIZED VIEW public.leaderboard_global AS
SELECT p.id AS user_id, p.name, p.role, p.avatar, p.photo_url, p.level, p.total_points,
  RANK() OVER (ORDER BY p.total_points DESC) AS rank
FROM public.profiles p WHERE p.total_points > 0;
CREATE UNIQUE INDEX ON public.leaderboard_global (user_id);

CREATE MATERIALIZED VIEW public.leaderboard_by_topic AS
SELECT ts.user_id, p.name, p.role, p.avatar, p.photo_url, p.level, ts.topic_key, ts.points,
  RANK() OVER (PARTITION BY ts.topic_key ORDER BY ts.points DESC) AS rank
FROM public.topic_stats ts JOIN public.profiles p ON p.id = ts.user_id WHERE ts.points > 0;
CREATE UNIQUE INDEX ON public.leaderboard_by_topic (user_id, topic_key);

-- RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topic_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_insert" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "topic_stats_select" ON public.topic_stats FOR SELECT USING (true);
CREATE POLICY "topic_stats_insert" ON public.topic_stats FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "topic_stats_update" ON public.topic_stats FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "matches_select" ON public.matches FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "matches_insert" ON public.matches FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "chat_select" ON public.chat_messages FOR SELECT USING (true);
CREATE POLICY "chat_insert" ON public.chat_messages FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "notifications_select" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "notifications_update" ON public.notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "notifications_insert" ON public.notifications FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Jogador'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'Personal Banker')
  );
  INSERT INTO public.notifications (user_id, type, title, body)
  VALUES (NEW.id, 'system', 'Bem-vindo ao Franq Quiz! 🎉', 'Jogue partidas, acumule pontos e suba no ranking. Boa sorte!');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_profile_updated
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Refresh leaderboards RPC
CREATE OR REPLACE FUNCTION public.refresh_leaderboards()
RETURNS VOID AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.leaderboard_global;
  REFRESH MATERIALIZED VIEW CONCURRENTLY public.leaderboard_by_topic;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enable realtime for chat
ALTER PUBLICATION supabase_realtime ADD TABLE public.chat_messages;
