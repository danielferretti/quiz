<!-- PROGRESS — progress changelog for /command.
     Append a dated block when you SHIP something meaningful or HIT a blocker.
     Newest entry on top. 1-3 lines per block. Outcomes, not steps.
     A line phrased as a blocker ("Blocked: waiting on X from <name>") can become
     a waiting-on in /command. This file is read by ~/Franq/command/projects-poll.py.

FORMAT:
## YYYY-MM-DD
- <what shipped / what changed / what's blocked>
-->

## 2026-07-22 (later)
- Fixed iOS-only gameplay/chat text overlap: added `-webkit-text-size-adjust:100%` (Safari was inflating question glyphs past their box on iPhone 15 Pro Max) + `flex:0 0 auto` safety on gameplay question/answers. Centered the JOGAR card text so it clears its giant-corner shape.
- Added game-feel layer: floating "+N" on correct, player-score count-up, correct/wrong screen flash, combo escalation glow (lima at x4), correct-chip pop, richer countdown pop, results coin count-up, "Perfeito!" flourish on 5/5 — plus new SFX (coin ching, level-up arpeggio, round-start swoosh, combo-break). All gated on the sound + reduced-motion settings; effect nodes auto-remove (no leaks).
- Supabase project was paused (not deleted) → resumed; backend live again, no code change needed. Added `supabase/setup.sql` (one-paste schema+RLS+seed) for future rebuilds. Recommend disabling "Confirm email" in Auth settings; free tier re-pauses after ~7d idle.

## 2026-07-22
- Shipped full GUI overhaul: quiz now wears the Franq site-kit design language (ink surfaces, Nib Pro serif for titles/scores/timer, periwinkle accents, lima for celebration only, glass overlays, giant-corner hero cards). Replaced the old purple/Inter theme end-to-end, unified icons to one inline-SVG set (dropped PNG play buttons + emoji chrome), embedded the Franq mark, and added motion (answer shake/pop, staggered reveals, spring countdowns). Verified all 11 screens in-browser at 390px, no console errors.
- Shipped pass-1 hardening on index.html: HTML-escaping (esc/safeUrl) across all remote/peer innerHTML sinks (chat, PvP invites, matchmaking, leaderboard, home ranking, notifications), PvP channel-lifecycle fixes (idempotent endMatch, scoped disconnect/rematch timers, forfeit handling, score clamping), state deep-merge + counter-rollback guard, achievement/streak dedupe, and a11y (focus-visible, reduced-motion, aria-labels, keyboard-activatable cards).
- Review: 4 adversarial reviewers (Codex + 3 Opus passes on correctness/security/UX). Headline was a wormable stored XSS (session-token theft via chat/PvP names) — now fixed.
- Blocked: server-side RLS + authoritative scoring must be verified in the Supabase dashboard (client is currently authoritative on points/wins/outcomes) — see below.
- Out of scope for this file — must be verified in the Supabase dashboard: server-side RLS + authoritative scoring for tables profiles, topic_stats, notifications, matches, pvp_matches, chat_messages, and the avatars storage bucket (all must be auth.uid()-scoped; the client is currently authoritative on points/wins/outcomes). Also deferred: PWA service worker / offline startup (single-file app has no SW) and the pvp_matches data model (both players insert self-as-player1 — needs a schema decision).