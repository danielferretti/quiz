# JS Render Propagation Brief — apply the new design system to render strings

The `<style>` block of index.html has ALREADY been replaced with the new Franq design system
(ink surfaces, Nib Pro serif, periwinkle `--primary-soft`, lima `--lima` for celebration,
glass overlays, giant corners). New/updated CSS classes are the contract — your job is to update
the JavaScript render strings + a couple of static HTML blocks so they emit markup matching the
new classes, replace emoji glyphs with inline SVG icons, and drop old hardcoded colors/PNGs.

DO NOT touch the `<style>` block. DO NOT change game logic. PRESERVE every element id the JS
queries and every `esc()`/`safeUrl()` call added earlier. Keep it a single self-contained file.
Portuguese copy stays Portuguese, but change ALL-CAPS button/label text to mixed-case where noted
(the new type system uses caps only for eyebrows, which CSS handles via text-transform).

## Icon set — use these exact inline SVGs (Lucide, stroke=currentColor). Color comes from the parent.
Wrap each where the class expects `svg`. Base attrs: `viewBox="0 0 24 24" fill="none"
stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"`.
- play (JOGAR): `<polygon points="6 3 20 12 6 21 6 3"/>`
- swords (DESAFIAR/challenge): `<polyline points="14.5 17.5 3 6 3 3 6 3 17.5 14.5"/><line x1="13" x2="19" y1="19" y2="13"/><line x1="16" x2="20" y1="16" y2="20"/><line x1="19" x2="21" y1="21" y2="19"/><polyline points="14.5 6.5 18 3 21 3 21 6 17.5 9.5"/><line x1="5" x2="9" y1="14" y2="18"/><line x1="7" x2="4" y1="17" y2="20"/><line x1="3" x2="5" y1="19" y2="21"/>`
- clock (Tempo Extra): `<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>`
- scissors (50/50): `<circle cx="6" cy="6" r="3"/><path d="M8.12 8.12 12 12"/><path d="M20 4 8.12 15.88"/><circle cx="6" cy="18" r="3"/><path d="M14.8 14.8 20 20"/>`
- zap (Pontos x2): `<polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>`
- coin (🪙): `<circle cx="12" cy="12" r="8"/><path d="M9.5 9.5h3.5a1.5 1.5 0 0 1 0 3H9.5m0 0v2.5m0-5.5V7"/>` (use size 16, color amber via parent)
- lightbulb (Sabia?): `<path d="M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5"/><path d="M9 18h6"/><path d="M10 22h4"/>`
- bell (notif): `<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>`
- chat/message (chat entry): `<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>`
- send (chat send): `<path d="m22 2-7 20-4-9-9-4Z"/><path d="M22 2 11 13"/>`
- arrow-left (back): `<path d="m12 19-7-7 7-7"/><path d="M19 12H5"/>`
- close-x: `<path d="M18 6 6 18"/><path d="M6 6l12 12"/>`
- book (Revisar): `<path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"/>`
- camera (photo edit): `<path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z"/><circle cx="12" cy="13" r="3"/>`
- refresh (Revanche): `<path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M8 16H3v5"/>`
- gift (news bonus): `<rect x="3" y="8" width="18" height="4" rx="1"/><path d="M12 8v13"/><path d="M19 12v7a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2v-7"/><path d="M7.5 8a2.5 2.5 0 0 1 0-5A4.8 8 0 0 1 12 8a4.8 8 0 0 1 4.5-5 2.5 2.5 0 0 1 0 5"/>`
- megaphone (news info): `<path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/>`
- flame (news event): `<path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/>`
- trophy (news/ranking): `<path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/><path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/><path d="M4 22h16"/><path d="M10 14.66V17c0 .55-.47.98-.97 1.21C7.85 18.75 7 20.24 7 22"/><path d="M14 14.66V17c0 .55.47.98.97 1.21C16.15 18.75 17 20.24 17 22"/><path d="M18 2H6v7a6 6 0 0 0 12 0V2Z"/>`
- graduation (tutorial 1): `<path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/>`
- target (tutorial/missions): `<circle cx="12" cy="12" r="10"/><circle cx="12" cy="12" r="6"/><circle cx="12" cy="12" r="2"/>`
- franq mark (watermark, splash, login logo): two-path mark —
  `<svg viewBox="0 0 58 58" fill="currentColor" xmlns="http://www.w3.org/2000/svg"><path d="M45.4725 28.843C45.4725 19.6407 37.9966 12.1552 28.8061 12.1552C19.6156 12.1552 12.1397 19.6407 12.1397 28.843C12.1397 38.0452 19.6156 45.5307 28.8061 45.5307V57.6859C12.9627 57.6859 0 44.7066 0 28.843C0 12.9793 12.8942 0 28.8061 0C44.6495 0 57.6122 12.9107 57.6122 28.843H45.4725Z"/><path d="M28.8061 28.843H40.9458C40.9458 38.0452 48.4217 45.5307 57.6122 45.5307V57.6859C41.7689 57.6859 28.8061 44.7753 28.8061 28.843Z"/></svg>`
  (this is also in assets/brand/franq-mark.svg — you may read it.)

## Edits (each references the function; find current line by name — line numbers drift as you edit)

1. **Splash static HTML** (`<div id="splash">`): replace the `.splash-logo` `<img src="design/img/logo.png">`
   with the inline franq-mark SVG (CSS sizes `.splash-logo svg`). Remove the old inline width/height
   style on it.
2. **runSplash** title builder: the letters spell "FRANQ QUIZ". Add class `accent` (in addition to
   `letter`) to the letters of the word "QUIZ" so they render periwinkle (`.splash-title .letter.accent`).
3. **Login static HTML** (`<div id="login">`): `.login-logo-icon` img → inline franq-mark SVG. Add an
   eyebrow above the title: `<div class="eyebrow login-eyebrow">Bem-vindo</div>`. Change the login
   title default text to serif is automatic (CSS). Change the button labels: doLogin/toggleLoginMode
   set `ENTRAR`/`CRIAR CONTA`/`ENTRANDO...`/`CRIANDO...` — change to mixed case `Entrar`/`Criar conta`/
   `Entrando...`/`Criando...` (both the static button and the JS `.textContent` assignments).
4. **avatarBubble** and **avatarInner**: replace the inline
   `background:linear-gradient(135deg,var(--accent),#8B5CF6)...` initials style with
   `background:var(--card-2);color:var(--primary-soft)` (keep the border rules from the class for
   avatarBubble; avatarInner's inner div keeps `border-radius:50%`). Photos still go through safeUrl().
5. **renderHome play buttons**: replace BOTH `.play-btn` blocks (the ones using
   `<div class="play-bg"><img big_button.png></div>` and `play-icon-img` from icon_jogar/desafiar.svg)
   with the new card markup:
   - `<button class="play-btn primary" onclick="quickPlay()"><div class="play-watermark">[FRANQ MARK SVG]</div><div class="play-content"><div class="play-icon">[play svg 26]</div><div class="play-label">Jogar</div><div class="play-sub">Partida rápida</div></div></button>`
   - `<button class="play-btn ghost" onclick="openChallenge()"><div class="play-content"><div class="play-icon">[swords svg 26]</div><div class="play-label">Desafiar</div><div class="play-sub">Escolha um oponente</div></div></button>`
   Remove all references to big_button.png / icon_jogar.svg / icon_desafiar.svg in home.
6. **renderHome header icon buttons** (notif bell + chat): replace the two inline-styled `<button>`s
   with `<button class="icon-chip" aria-label="Notificações" onclick="toggleNotifications()">[bell svg]<span class="notif-badge" id="notifBadge" ...>0</span></button>` and
   `<button class="icon-chip" aria-label="Chat" onclick="showScreen('chat')">[chat svg]</button>`.
   Keep id="notifBadge"; restyle the badge inline to: `position:absolute;top:-4px;right:-4px;min-width:16px;height:16px;padding:0 4px;border-radius:8px;background:var(--danger);font-size:9px;font-weight:700;color:#fff;display:none;align-items:center;justify-content:center`.
   Make the home-profile a `<button class="home-profile">` (keep onclick).
7. **renderTopics / topic cards**: no icon change (keep the topic svgIcon `<img>`). Just confirm the
   card markup matches `.topic-card`/`.topic-content`/`.topic-icon-img`/`.topic-name`/`.topic-meta`
   (it does). Back button: use `[arrow-left svg]` instead of the `←` char inside `.back-btn`
   (everywhere `.back-btn` uses `←`: topics, settings, chat, notif panel).
8. **playRound gameplay**: (a) `.game-topic` — replace `game.topicMeta.icon` emoji with the topic's
   `svgIcon` as a 14px inline `<img>` if present (`<img src="'+safeUrl(game.topicMeta.svgIcon)+'" style="width:14px;height:14px">`), else omit; keep the name. (b) `.game-round` "Rodada X/5" +
   `⭐2x`/`🔥2x` suffixes: the hot path was removed; keep only the `game.round===4` bonus but render it
   as ` · x2` text (no emoji). (c) timer initial already `20.0`. (d) powerups: replace each powerup
   button's emoji + `<br>` layout with:
   `<button class="powerup-btn ..." id="puTempo" onclick="usePowerup('tempo')"><span class="pu-icon">[clock svg 18]</span>Tempo Extra<span class="pu-cost">10 [coin svg 12]</span></button>`
   (scissors for fiftyFifty, zap for double; costs 15/20). Keep the id and the class-state logic
   (`used`/`locked`). (e) combo dots: when `i>=4` and active, add class `hot` (lima) — change the dot
   builder to `'<div class="combo-dot'+(i<=game.combo?(i>=4?' active hot':' active'):'')+'"></div>'`
   in BOTH playRound and updateComboDisplay.
9. **showExplanation**: `💡 Sabia?` → `[lightbulb svg]` + `<strong>Sabia?</strong>`.
10. **timeUp / selectAnswer**: no markup change needed (classes handle correct/wrong + shake/pop).
11. **endMatch results**: (a) banner: for win emit `Vitória<span class="hl">!</span>`, draw `Empate`,
    loss `Não foi dessa vez` (drop ALL-CAPS "VITÓRIA!/EMPATE/DERROTA"). (b) score compare: change the
    two spans to `<span class="me-score">0</span><span class="vs-x">VS</span><span class="opp-score">0</span>`
    (keep ids animPlayerScore/animOppScore). (c) rewards card title `📋 Recompensas` → `Recompensas`
    (as an eyebrow: `<div class="eyebrow" style="margin-bottom:10px">Recompensas</div>`). Reward-val
    coin `🪙` → `[coin svg 12]`. (d) result-coins `🪙` → `[coin svg 18]`. (e) xp-label: drop
    `rank.emoji`, keep `Nível X — Title`. (f) level-up-flash: `🎉 NÍVEL X!` → `Nível X!` (CSS makes it
    lima serif). (g) reward rows coin emoji likewise. (h) Revanche buttons: `⚔️ Revanche PvP` →
    `[swords svg] Revanche`, `🔄 Revanche` → `[refresh svg] Revanche`, `📚 Novo Tópico` →
    `[book svg]`? use no icon or a grid icon — keep simple: `Novo tópico` (secondary), `Início`
    (secondary). Use `.btn-secondary` for the two non-primary actions.
12. **toggleReview**: button `📖 Revisar Perguntas`/`📖 Ocultar Revisão` → `[book svg] Revisar
    perguntas` / `[book svg] Ocultar revisão`. Review items `💡` → `[lightbulb svg]`. The ✅/❌ answer
    markers: replace with small check/x — you may keep as text `✓`/`✗` colored by the answer class
    (`.correct-answer`/`.wrong-answer`), NOT emoji.
13. **spawnConfetti colors**: change the `colors` array to
    `['#687BEA','#8B9BFF','#DCFF79','#F5F7FA']`.
14. **renderLeaderboard**: DESAFIAR buttons already use data-attr delegation — keep. Title "Ranking"
    stays serif (class). Tab labels unchanged. Top-1 crown: leave as is (CSS gives top1 lima number).
    Reset text unchanged.
15. **renderProfile**: photo edit `📷` → wrap in `<label class="profile-photo-edit" for="photoUpload">
    [camera svg 15]</label>`. Rank pill: drop `rank.emoji` and the inline `rank.color` border — use the
    plain `.rank-pill` class with `rank.title` text only (periwinkle default). Stat values already
    serif via class. Medals: ensure MEDAL_DEFS icons use `stroke="currentColor"` (CSS colors them
    periwinkle) — if any medal icon has a hardcoded stroke/fill color, change it to currentColor/none.
16. **renderSettings**: setting icons — remove inline `stroke="currentColor" ... opacity:0.6` inline and
    the `style="vertical-align..."`; rely on `.setting-label svg`. Keep the icon paths. Feedback button
    uses `.btn-feedback` + `[chat svg]`; danger button `.btn-danger`. Toggle markup unchanged (a11y
    attrs added earlier stay).
17. **Notifications panel** (toggleNotifications): (a) panel bg → `background:var(--bg)`. (b) header bg →
    `var(--glass-nav)`. (c) title uses serif (add class or `font-family:var(--font-serif)`). (d) the two
    tab `<button>`s → `<div class="chat-tabs"><button class="chat-tab ${active}">Notificações</button>
    <button class="chat-tab ${active}">Novidades</button></div>`. (e) back button → `.back-btn` with
    `[arrow-left svg]`. (f) the per-notification icon SVGs currently hardcode `stroke="#FFD700"` /
    `var(--accent-light)` / `var(--success)` — recolor: achievement→`var(--lima)`, system→
    `var(--primary-soft)`, default→`var(--ok-text)`.
18. **renderNewsTab**: replace each news `icon` emoji with the matching inline SVG by `type`
    (bonus→gift, challenge→swords, info→megaphone, event→flame, and the two remaining
    `🏆`/`💰`/`📢` → trophy/coin/megaphone). The `.news-icon.{type}` class colors them. Put the SVG
    inside `<div class="news-icon {type}">[svg]</div>`.
19. **renderChat**: title → `<div class="chat-title">Chat Bankers</div>`. Send button `➤` →
    `<button class="chat-send-btn" aria-label="Enviar mensagem" onclick="sendChatMsg()">[send svg]</button>`.
    Back button `[arrow-left svg]`.
20. **openChallenge sheet**: add `<div class="sheet-grabber"></div>` as the first child of the sheet.
    Title `⚔️ Escolha seu Oponente` → `Escolha seu oponente` (serif via class) + keep the close-x but
    use `[close-x svg]`. Section titles: online `[online-dot] Jogadores online (n)`,
    AI `🤖 OPONENTES IA` → `Oponentes IA` (the `.challenge-section-title` is an eyebrow; drop the robot
    emoji or use a small `[bot]`—simplest: no icon). Fight buttons use `.challenge-fight-btn` (already).
21. **showIncomingChallengeModal**: title `⚔️ DESAFIO!` → `Desafio!` (serif). Keep avatar/name/role
    (already escaped). Accept/decline buttons: make Accept `.btn-primary` (`[swords svg] Aceitar`),
    Decline `.btn-secondary` (`Recusar`).
22. **startPvpCountdown**: the 72px digits — wrap in serif and periwinkle: use
    `<div style="...font-family:var(--font-serif);font-weight:500;color:var(--primary-soft)">`; "VAI!"
    → periwinkle serif too (drop the green). Also the matchmaking "VS" text → wrap with class
    `vs-text` where feasible (optional, low priority).
23. **showToast**: replace the inline cssText with `t.className='toast anim-fiu'` (the `.toast` class
    exists). Keep the auto-dismiss logic.
24. **renderTutorialStep**: step icons `📚/⏱️/🏆` → `[graduation]/[clock]/[trophy]` inside
    `<div class="tutorial-icon">[svg]</div>`. Button label already fine.

When done:
1. Verify parse: `node -e "const fs=require('fs');const h=fs.readFileSync('/Users/DanielFerretti1/Franq/quiz/index.html','utf8');const m=h.match(/<script>([\s\S]*)<\/script>\s*<\/body>/);fs.writeFileSync('/tmp/quiz-check.js',m[1]);" && node --check /tmp/quiz-check.js && echo PARSE_OK`
2. `grep -n "#8B5CF6\|big_button\|icon_jogar\|icon_desafiar\|\\\\u{1F" index.html` — confirm no purple,
   no dropped PNGs, and that UI-chrome emoji are gone (emoji remaining ONLY inside question/explanation
   CONTENT strings in the QUESTIONS data and AI-opponent avatar fallbacks is fine).

Return a concise checklist (1-24) DONE/PARTIAL/SKIPPED + one-line notes + any deviations. Your final
message is consumed by an orchestrator — report only.
