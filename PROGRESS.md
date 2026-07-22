<!-- PROGRESS — progress changelog for /command.
     Append a dated block when you SHIP something meaningful or HIT a blocker.
     Newest entry on top. 1-3 lines per block. Outcomes, not steps.
     A line phrased as a blocker ("Blocked: waiting on X from <name>") can become
     a waiting-on in /command. This file is read by ~/Franq/command/projects-poll.py.

FORMAT:
## YYYY-MM-DD
- <what shipped / what changed / what's blocked>
-->

## 2026-07-22
- Shipped full GUI overhaul: quiz now wears the Franq site-kit design language (ink surfaces, Nib Pro serif for titles/scores/timer, periwinkle accents, lima for celebration only, glass overlays, giant-corner hero cards). Replaced the old purple/Inter theme end-to-end, unified icons to one inline-SVG set (dropped PNG play buttons + emoji chrome), embedded the Franq mark, and added motion (answer shake/pop, staggered reveals, spring countdowns). Verified all 11 screens in-browser at 390px, no console errors.
- Shipped pass-1 hardening on index.html: HTML-escaping (esc/safeUrl) across all remote/peer innerHTML sinks (chat, PvP invites, matchmaking, leaderboard, home ranking, notifications), PvP channel-lifecycle fixes (idempotent endMatch, scoped disconnect/rematch timers, forfeit handling, score clamping), state deep-merge + counter-rollback guard, achievement/streak dedupe, and a11y (focus-visible, reduced-motion, aria-labels, keyboard-activatable cards).
- Review: 4 adversarial reviewers (Codex + 3 Opus passes on correctness/security/UX). Headline was a wormable stored XSS (session-token theft via chat/PvP names) — now fixed.
- Blocked: server-side RLS + authoritative scoring must be verified in the Supabase dashboard (client is currently authoritative on points/wins/outcomes) — see below.
- Out of scope for this file — must be verified in the Supabase dashboard: server-side RLS + authoritative scoring for tables profiles, topic_stats, notifications, matches, pvp_matches, chat_messages, and the avatars storage bucket (all must be auth.uid()-scoped; the client is currently authoritative on points/wins/outcomes). Also deferred: PWA service worker / offline startup (single-file app has no SW) and the pvp_matches data model (both players insert self-as-player1 — needs a schema decision).