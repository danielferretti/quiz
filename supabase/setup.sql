-- ============================================================
-- Franq Quiz — COMPLETE SETUP (paste into Supabase SQL Editor)
-- Run once on a fresh project. Order: schema -> pvp -> storage -> seed.
-- ============================================================

-- ===== PART 1/4: schema, RLS, triggers, leaderboard views, realtime =====
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

-- ===== PART 2/4: PvP matches table + profile pvp columns =====
-- ============================================================
-- PvP Match Results
-- ============================================================

CREATE TABLE public.pvp_matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id TEXT NOT NULL,
  topic_key TEXT NOT NULL,
  player1_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  player2_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  player1_score INTEGER NOT NULL DEFAULT 0,
  player2_score INTEGER NOT NULL DEFAULT 0,
  player1_correct INTEGER NOT NULL DEFAULT 0,
  player2_correct INTEGER NOT NULL DEFAULT 0,
  winner_id UUID REFERENCES public.profiles(id),
  status TEXT NOT NULL DEFAULT 'completed' CHECK (status IN ('completed', 'forfeit', 'disconnect')),
  seed BIGINT NOT NULL,
  played_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_pvp_players ON public.pvp_matches(player1_id, played_at DESC);
CREATE INDEX idx_pvp_p2 ON public.pvp_matches(player2_id, played_at DESC);

ALTER TABLE public.pvp_matches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "pvp_select" ON public.pvp_matches
  FOR SELECT USING (auth.uid() = player1_id OR auth.uid() = player2_id);

CREATE POLICY "pvp_insert" ON public.pvp_matches
  FOR INSERT WITH CHECK (auth.uid() = player1_id OR auth.uid() = player2_id);

-- Add PvP stats to profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS pvp_wins INTEGER NOT NULL DEFAULT 0;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS pvp_played INTEGER NOT NULL DEFAULT 0;

-- ===== PART 3/4: avatars storage bucket + policies =====
-- Create avatars storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 2097152, ARRAY['image/jpeg','image/png','image/webp','image/gif'])
ON CONFLICT (id) DO NOTHING;

-- Allow authenticated users to upload their own avatar
CREATE POLICY "avatars_upload" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

-- Allow authenticated users to update (overwrite) their own avatar
CREATE POLICY "avatars_update" ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

-- Allow anyone to read avatars
CREATE POLICY "avatars_read" ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- ===== PART 4/4: seed leaderboard + demo chat (fake profiles) =====
-- ============================================================
-- Part 2: Seed data (run AFTER Part 1)
-- Temporarily drops FK so fake profiles can be inserted
-- ============================================================

-- Drop FK constraint temporarily
ALTER TABLE public.profiles DROP CONSTRAINT profiles_id_fkey;

-- Also drop FK on child tables that reference profiles
ALTER TABLE public.topic_stats DROP CONSTRAINT topic_stats_user_id_fkey;
ALTER TABLE public.chat_messages DROP CONSTRAINT chat_messages_user_id_fkey;

-- Insert seed profiles
DO $$
DECLARE
  seed_id UUID;
  names TEXT[] := ARRAY[
    'Francisco Tavares', 'Karen Lopes', 'Marcio Godoy',
    'Rafael Costa', 'Juliana Lima', 'Pedro Almeida',
    'Fernanda Rocha', 'Lucas Mendes', 'Beatriz Ferreira',
    'Thiago Souza', 'Ana Carolina', 'Roberto Nunes',
    'Camila Vieira', 'Diego Santos', 'Mariana Oliveira'
  ];
  roles TEXT[] := ARRAY[
    'Personal Banker', 'Personal Banker', 'Analista de Investimentos',
    'Assessor Financeiro', 'Personal Banker', 'Gerente de Carteira',
    'Especialista Private', 'Personal Banker', 'Analista de Compliance',
    'Consultor de Câmbio', 'Personal Banker', 'Assessor Financeiro',
    'Personal Banker', 'Gerente de Carteira', 'Especialista Private'
  ];
  avatars TEXT[] := ARRAY[
    '👩‍💼', '👨‍💼', '👩‍💻', '🧑‍💼', '👩‍🦰', '👨‍🦱',
    '👩‍🏫', '👨‍💻', '👩‍⚖️', '🧑‍✈️', '👩‍💼', '👨‍💼',
    '👩‍🦰', '👨‍💻', '👩‍💼'
  ];
  points_arr INT[] := ARRAY[
    1720, 1580, 1450, 1320, 1180, 1050,
    980, 870, 760, 650, 540, 430, 350, 280, 190
  ];
  levels_arr INT[] := ARRAY[
    5, 5, 4, 4, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1
  ];
  topics TEXT[] := ARRAY['mercado', 'investimentos', 'compliance', 'atendimento', 'cambio', 'previdencia'];
BEGIN
  FOR i IN 1..array_length(names, 1) LOOP
    seed_id := gen_random_uuid();

    INSERT INTO public.profiles (id, name, role, avatar, level, total_points, games_played, wins, coins)
    VALUES (
      seed_id, names[i], roles[i], avatars[i], levels_arr[i], points_arr[i],
      floor(random() * 30 + 5)::int,
      floor(random() * 20 + 3)::int,
      floor(random() * 200 + 20)::int
    );

    FOR j IN 1..array_length(topics, 1) LOOP
      IF random() > 0.4 THEN
        INSERT INTO public.topic_stats (user_id, topic_key, points, played)
        VALUES (seed_id, topics[j], floor(random() * (points_arr[i] / 3) + 50)::int, floor(random() * 10 + 1)::int);
      END IF;
    END LOOP;
  END LOOP;
END $$;

-- Seed chat messages
INSERT INTO public.chat_messages (user_id, user_name, message, created_at)
SELECT id, 'Francisco Tavares', 'Boa sorte a todos no quiz! 🎯', now() - interval '2 hours'
FROM public.profiles WHERE name = 'Francisco Tavares' LIMIT 1;

INSERT INTO public.chat_messages (user_id, user_name, message, created_at)
SELECT id, 'Karen Lopes', 'Quem topa um desafio de Compliance? ⚖️', now() - interval '1 hour'
FROM public.profiles WHERE name = 'Karen Lopes' LIMIT 1;

INSERT INTO public.chat_messages (user_id, user_name, message, created_at)
SELECT id, 'Marcio Godoy', 'Acabei de fazer 5/5 em Home Equity! 💪', now() - interval '30 minutes'
FROM public.profiles WHERE name = 'Marcio Godoy' LIMIT 1;

-- Refresh leaderboards
REFRESH MATERIALIZED VIEW public.leaderboard_global;
REFRESH MATERIALIZED VIEW public.leaderboard_by_topic;

-- Re-add FK constraints (NOT VALID = don't check existing seed rows)
ALTER TABLE public.profiles
  ADD CONSTRAINT profiles_id_fkey
  FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE NOT VALID;

ALTER TABLE public.topic_stats
  ADD CONSTRAINT topic_stats_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

ALTER TABLE public.chat_messages
  ADD CONSTRAINT chat_messages_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
