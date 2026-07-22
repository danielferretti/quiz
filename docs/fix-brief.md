# Franq Quiz — Fix Brief (pass 1: correctness + security + a11y)

This lands BEFORE the visual overhaul. Zero visual-redesign work here — only correctness,
security, accessibility, and dead-code removal. Preserve every element ID the JS queries.

## A. Security (XSS) — TOP PRIORITY, wormable

Root cause: no HTML-escaping anywhere; all remote/peer data hits `innerHTML` raw.

1. Add two helpers near the top of the script:
   ```js
   function esc(s){return String(s==null?'':s).replace(/[&<>"']/g,function(c){
     return{'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]})}
   function safeUrl(u){u=String(u==null?'':u);
     return /^(https?:\/\/|\/|data:image\/(png|jpe?g|gif|webp);base64,)/i.test(u)?u:''}
   ```
2. Escape EVERY interpolation of remote/peer/user data in innerHTML templates:
   - Chat: `renderChatTab` — `m.from`, `m.text`, `safeUrl(m.photo)` (lines ~3281-3296).
   - PvP invite modal `showIncomingChallengeModal` — `data.challenger.name/role`,
     `safeUrl(data.challenger.photo)`, `topicName` (1455-1490).
   - Matchmaking screens (sendPvpChallenge 1368, acceptPvpChallenge 1512,
     startPvpMatchReady 1605, startPvpMatch 1638): opponent/target `name`, photo.
   - openChallenge online list (2290-2298): `u.name`, `u.role`, `safeUrl(u.photo)`,
     and `u.userId` inside the onclick — validate userId is a UUID before embedding, or
     better attach the handler via addEventListener.
   - Leaderboard rows (2945-2964) + home ranking (2140-2174): `e.name` (text AND inside the
     `challengeFromRanking('...')` onclick — escape for JS string context or switch to data-attr
     + event delegation), `safeUrl(photo)`, `e.role`.
   - Notifications panel (3117-3131): `n.title`, `n.body`.
   - avatarBubble/avatarInner (1171-1187): wrap `photo` in `safeUrl()`, `getInitials(name)` is
     already safe but escape name if ever shown as text.
   - gameplay opponent (2500-2502): `game.opponent.name`, and `game.opponent.avatar` is injected
     as raw HTML — for AI opponents it's initials/emoji (safe) but for PvP it comes from
     `opponentInfo.avatar` (peer-controlled) — escape it.
3. `challengeFromRanking`/`challengeStart` receive a name string from an onclick; since names are
   now escaped at render they's fine, but prefer event delegation with data-name attributes.

Do NOT touch the Supabase anon key (public by design). Note in PROGRESS.md that server-side RLS
+ authoritative scoring must be verified in Supabase dashboard (out of scope for this file):
tables profiles, topic_stats, notifications, matches, pvp_matches, chat_messages, and the
avatars storage bucket must be auth.uid()-scoped.

## B. Correctness / logic (all traced end-to-end by the review pass)

1. **HIGH — cancelPvpChallenge leaves match channel live → seed=null desync** (1432): unlike the
   20s timeout path (1425), `cancelPvpChallenge` never calls `cleanupPvpMatch()`/removes
   `pvpMatchChannel`, so its `match:accepted` handler (1386) can still fire after cancel and drag
   the canceller into `startPvpMatchReady(matchId=null, seed=null)` → both players get different
   questions. FIX: `cancelPvpChallenge` must `cleanupPvpMatch()` (removes the channel) after
   sending the cancel broadcast. Same leak in **handleChallengeDeclined** (1576) — add cleanup.
2. **MEDIUM — endMatch not idempotent → double-counted stats** (2711): reachable twice via
   (a) quitGame→broadcastMatchFinished→endMatch then quitGame's own `gamesPlayed++` (2705),
   (b) duplicate `match:finished` during persist awaits, (c) the 60s disconnect timeout racing a
   late finish. FIX: add `if(game&&game.ended)return; game.ended=true;` at the top of endMatch;
   in quitGame, when pvpMode, do NOT also increment counters (let the finish path own it) — or
   guard the increment behind `!game.ended`.
3. **Timer initial value** (2512): rendered `10.0`, round is 20s → change to `20.0`.
4. **Tempo powerup overflow** (2676): cap `game.timeLeft=Math.min(20,game.timeLeft+5)` (bar and
   points are scaled to 20).
5. **RAF timer background-tab jump** (2533-2540): clamp `dt=Math.min(dt,0.25)` so a hidden tab
   doesn't snap the timer to 0 on return.
6. **loadState no field-merge → crash on old saves** (989): `JSON.parse(s)` returned as-is; a save
   predating `streak`/`settings` throws when `vibrate` reads `state.settings.vibration` (1151, hit
   on first showScreen) or endMatch reads `state.streak.lastDate` (2733). FIX: deep-merge loaded
   state over `defaultState()` (shallow-merge top level + merge `settings`/`streak` objects).
7. **Achievement notifications re-fire / misfire** (checkAndCreateNotifications ~1078, runs every
   match): `wins===1`, `wins===5`, `level===5`, `streak.count===7` re-fire on every subsequent
   match at that value; the "100 moedas" check subtracts `game.playerScore` from coins
   (nonsensical, 1087); the "500 pontos" crossing subtracts `game.playerScore` instead of the full
   `totalPts` (1084) so it misses the crossing; the "combo x3" branch is dead because
   `state.hasComboX3` is set during play before the check (1089 vs 2587). FIX: gate each on a
   persisted "already awarded" flag (e.g. `state.notified={}` keyed by achievement id) and pass the
   pre-match totals into the crossing checks. Keep it simple and correct; if time-boxed, at minimum
   dedupe with flags so nothing spams.
8. **PvP profile stats wrong** (1792): `pvp_played:state.gamesPlayed` writes solo+pvp total;
   `state.pvpWins` is never defined so `pvp_wins` is always 0/1. FIX: add `pvpPlayed`/`pvpWins` to
   defaultState + loadProfileFromSupabase, increment on PvP finish, write those.
9. **LOW — solo matchmaking dot interval leak** (2367): `cancelMatch` clears `matchTimeout` but the
   only `clearInterval(dotIv)` lives inside the timeout it cancels. FIX: hoist `dotIv` to a var
   `cancelMatch` can clear.
10. **LOW — overlapping incoming invites leak prior timer** (1481-1496): a 2nd invite overwrites
    `overlay.dataset.timer` without clearing the old interval → spurious auto-decline. FIX: in
    showIncomingChallengeModal, clear any existing `dataset.timer` before setting the new one.
11. **HIGH — PvP rematch race** (2773/1799): `endMatch` calls `persistPvpMatch(...)` without
    awaiting; its trailing `cleanupPvpMatch()` runs after the DB awaits, so tapping "Revanche PvP"
    (which starts a new match/channel) then having the old writes finish nukes the NEW
    `pvpMatchChannel`/id/seed. FIX: capture match identity locally in persistPvpMatch and only
    clean up if it still owns the current match (compare a captured matchId to `pvpMatchId`), or
    snapshot needed values and don't touch globals created by the rematch.
12. **HIGH — 60s disconnect timeout unscoped** (1754): the setTimeout in broadcastMatchFinished is
    neither stored nor tied to the match; during a later rematch it fires and calls `endMatch()` on
    the new game. FIX: store the id, clear it in cleanupPvpMatch, and no-op if `game.ended` or the
    match id changed.
13. **HIGH — acceptor has no readiness timeout** (1543): acceptPvpChallenge starts a 500ms ready
    retry with NO timeout; if the challenger's 20s window already expired, the acceptor is stuck on
    "Preparando partida..." forever. FIX: add a ~15s safety timeout mirroring startPvpMatch (1680)
    that toasts + cleanup + home.
14. **HIGH — quit not sent as forfeit** (2702): quitGame broadcasts a normal `match:finished` with
    the partial score (treated as final) and removes the channel without awaiting delivery. FIX:
    send `forfeit:true` in the payload (beforeunload already does), have handleOpponentFinished treat
    a forfeit as a win for the receiver, and delay channel removal briefly so the send flushes.
15. **HIGH — unvalidated PvP broadcast scores** (1731/1764): handleOpponentRoundResult /
    handleOpponentFinished accept any `cumulativeScore`/`finalScore` from anyone on the public match
    channel. FIX: ignore payloads whose `userId !== pvpOpponentInfo.userId`; clamp scores to a sane
    range (0..~2000). (Full integrity needs server-side, but this stops trivial spoofing.)
16. **HIGH — sync error ignored** (1015): the profiles update `.then()` ignores the resolved
    `{error}`; failed writes look successful and the next launch silently rolls back. FIX: check
    `res.error` and, on error, keep local as source of truth (don't overwrite from server next boot
    unless server data is newer — see #17).
17. **HIGH — startup clobbers newer local state** (1004/2017/2024): authenticated boot does
    `state=defaultState()` then `loadProfileFromSupabase()`, discarding any local save newer than the
    last debounced sync AND resetting local-only daily/mission fields. FIX: after loading the server
    profile, merge local-only fields (dailyMissions/daily counters, and any field the server doesn't
    store) from the localStorage save; if a local save exists with equal identity, prefer the higher
    of server-vs-local for monotonic counters (xp/points/coins/wins/gamesPlayed) to avoid rollback.
    Also (2024): if there is NO valid Supabase session but sb exists, an expired session on a shared
    device still enters as the old local user — acceptable for now, but note it.
18. **MEDIUM — UTC vs local date** (1209): `todayStr` uses `toISOString()` (UTC); evening plays in
    BRT cross a UTC midnight → false daily streak increment. FIX: build the date string from local
    components (getFullYear/getMonth/getDate).
19. **MEDIUM — streak-7 bonus repeats** (2741): `state.streak.count===7` grants +50 coins every win
    while count sits at 7. FIX: award once (e.g. only when it transitions to 7, gated by a flag).
20. **MEDIUM — nextRound timeout not cancelled on quit** (2623/2570/2623): the 2s
    `setTimeout(nextRound)` keeps running after quitGame → a "Rodada 2" overlay pops over home. FIX:
    store the id (e.g. `game.nextRoundTimer`), clear it in quitGame (and endMatch).
21. **MEDIUM — private profile toggle is a no-op** (1858/1303): FIX: when `settings.privateProfile`
    is on, don't `pvpPresenceChannel.track(...)` (stay invisible/unchallengeable). Note leaderboard
    hiding needs the Supabase query — out of scope; at least honor presence.
22. **MEDIUM — leaderboard tab render race** (2937): concurrent async renders can show an older
    query under a newer tab. FIX: capture `lbFilter` at call start and bail if it changed before the
    await resolves (or a monotonic request token).
23. **MEDIUM — home ranking drops the player** (1880): sub-top-20 player is sliced off; home shows
    position 0. FIX: ensure buildLeaderboard/home always appends the player row with a correct
    computed position (home already has `playerRowHtml`; verify `playerPos` is right and not 0).
24. **MEDIUM — avatar size cap mismatch** (3025): UI allows 5MB but bucket caps 2MB → always fails
    for 2–5MB. FIX: lower client cap to 2MB and message accordingly. Also (1199) only report success
    after the profile `photo_url` update resolves without error; (3315) inspect the chat insert
    `{error}` and roll back the optimistic bubble + toast on failure.
25. **LOW — timer red pulse never fires** (376): CSS `.timer-danger .timer-bar-wrap` expects a
    descendant, but JS adds `timer-danger` directly to `#timerWrap` (which IS `.timer-bar-wrap`).
    FIX (will also be handled in redesign): target `.timer-bar-wrap.timer-danger`.
26. **LOW — combo x3 medal at combo 3 but x3 multiplier at 4** (2587): align — either award the
    medal at combo≥4 or start x3 at combo 3. Recommend award at ≥4 to match the multiplier.

### Out of scope for this file (note in PROGRESS.md, do NOT attempt here)
- Server-side RLS + authoritative scoring (Supabase dashboard): profiles/topic_stats/notifications/
  matches/pvp_matches/chat_messages + avatars bucket must be `auth.uid()`-scoped; points/wins/match
  outcomes validated server-side. Client is currently authoritative (#B-security, Codex 1005).
- Service worker / offline startup (Codex:10) — separate task; single-file app has no SW.
- pvp_matches data model (both players insert self-as-player1) — needs schema decision.

## C. Accessibility

1. Viewport (line 5): remove `maximum-scale=1,user-scalable=no` (keep viewport-fit=cover).
2. Add global `:focus-visible{outline:2px solid var(--primary);outline-offset:2px}` for
   buttons/inputs/[role=button].
3. Add `@media (prefers-reduced-motion:reduce){*,*::before,*::after{
   animation-duration:.001ms!important;animation-iteration-count:1!important;
   transition-duration:.001ms!important}}` and skip confetti/particles when it matches
   (`window.matchMedia('(prefers-reduced-motion:reduce)').matches`).
4. aria-labels on icon-only buttons: home bell (2187 → "Notificações"), chat (2188 → "Chat"),
   chat send (3244 → "Enviar mensagem"), back buttons ("Voltar").
5. Login labels: add `for=`/`id` pairing (2 fields visible + 2 signup).
6. Settings toggles: `role="switch"` + `aria-checked` + `aria-label` from the row label.
7. Topic cards & home-profile: convert clickable `<div onclick>` to `<button>` (or add
   role=button + tabindex=0 + keydown Enter/Space).
8. Avatar `<img alt>`: pass the name as alt for meaningful avatars.

## D. Small UX

1. Enter-to-submit on login email/password inputs → `doLogin()`.
2. `sendChatMsg` in-flight guard (avoid double-send on rapid Enter).
3. Replace `alert()` (photo error 3025/3028, feedback 3060) with `showToast()`.
4. Audio unlock listeners (3359-3361): add `{once:true}` or remove after first successful
   unlock — currently every tap spawns an oscillator for the page's life.
5. doLogout cleanup (3070): also reset `chatMessages=[]; chatLoaded=false; notifData=[];` and
   `if(chatSubscription){sb.removeChannel(chatSubscription);chatSubscription=null}`.

## E. Dead code to remove (reduces redesign surface)

1. `.topic-bg` / `.topic-bg img` markup + `small_button.png` load (display:none) — remove the
   bgHtml emission (2260) and CSS (242-245, 323-324).
2. `hot`/`isHot` 2x path — `TOPICS_META` never sets `.hot`; either wire it or remove
   `.hot-banner`/`.hot-2x` CSS + the isHot branches (2470, 2488). Recommend remove.
3. `_lbCache` declared, never used (1803) — wire it into renderLeaderboard/renderHome with a
   short TTL (10s) OR remove. Recommend wire (fixes the perf/scroll-reset finding).
4. `.flame-reward` CSS + `claimFlameToken` never rendered — remove both.

## NOT in this pass
Visual redesign, tokens, fonts, motion language, icon unification — all handled in pass 2
against docs/design-system.md.
