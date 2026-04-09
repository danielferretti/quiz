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
