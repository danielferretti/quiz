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
