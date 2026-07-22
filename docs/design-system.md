# Franq Quiz — Design System Spec (site-kit dialect, mobile game)

Source of truth for the 2026-07 GUI overhaul. Derived from `~/Franq/ui-design/franq-site-kit/`
(the franq.com.br public design language) adapted to a 390px dark mobile game.
Everything here overrides the previous indigo→purple/Inter/gold theme.

## Direction

**"Franq editorial, gamified."** Dark ink surfaces, Nib Pro serif for every hero moment
(titles, scores, countdowns, big numbers), flat Azul-Franqueza fills for all interaction,
periwinkle for emphasis text, and **lima as the single celebration color** — combo peaks,
victory, level-up. No purple. No gold. No gradients as fills (only radial glows + glass tints).
Depth comes from surface contrast and glass, not box-shadows.

## 1. Tokens (replace `:root` entirely)

```css
:root{
  /* surfaces */
  --bg:#131C25;            /* ink — Azul Dark, the dominant field */
  --bg-deep:#0E1014;       /* near-black depths: nav base, gameplay bg */
  --card:#1E2738;          /* ink-card — opaque navy content card */
  --card-2:#2E3944;        /* slate — secondary card tone, hover/pressed */
  --glass:rgba(255,255,255,.08);
  --glass-chip:rgba(46,57,68,.45);
  --glass-nav:rgba(19,28,37,.78);
  --glass-border:rgba(255,255,255,.14);
  --border:rgba(255,255,255,.09);
  /* brand */
  --primary:#687BEA;       /* Azul Franqueza — ALL interactive fill work */
  --primary-soft:#8B9BFF;  /* periwinkle — emphasis TEXT on dark */
  --primary-deep:#45529C;  /* pressed states */
  --primary-ring:rgba(104,123,234,.35);
  --primary-glow:rgba(104,123,234,.18);
  --lima:#DCFF79;          /* celebration only — see scarcity rule */
  --lima-bg:rgba(220,255,121,.14);
  /* semantic (beFranq family) */
  --ok:#06A37A; --ok-text:#4ADBB5; --ok-bg:rgba(6,163,122,.16);
  --warn:#E6952B; --warn-text:#F2B45C; --warn-bg:rgba(230,149,43,.15);
  --danger:#DC2F5B; --danger-text:#F07092; --danger-bg:rgba(220,47,91,.14);
  /* text */
  --text:#F5F7FA;          /* on-dark headlines */
  --text-sec:#C7D2DE;      /* cool blue-white body — the signature, never white opacities */
  --text-ter:#7C8899;
  /* type */
  --font-serif:'Nibpro','DM Serif Display',Georgia,serif;
  --font-sans:'DM Sans',system-ui,sans-serif;
  /* shape */
  --r-card:20px; --r-btn:16px; --r-lg:24px; --r-pill:999px;
  --r-giant:24px 24px 24px 72px;   /* the giant corner — hero elements only */
  /* motion */
  --ease:cubic-bezier(0.4,0,0.2,1); --ease-enter:cubic-bezier(0,0,0.2,1);
  --ease-exit:cubic-bezier(0.4,0,1,1); --ease-spring:cubic-bezier(0.34,1.56,0.64,1);
}
```

Delete every occurrence of: `#8B5CF6` (purple), `#FFD700`/`--gold`, `#FF6B35`/`--flame`,
`#10B981`, `#EF4444`, `#161B2E`, `#A3D977` (avatar ring green), Inter. Coins/streak recolor
to `--warn`/`--warn-text` (amber). Old `--accent` maps to `--primary`, `--accent-light` → `--primary-soft`.

## 2. Typography

- **Nib Pro** self-hosted: file `assets/fonts/nib-semibold-pro.woff2` already in repo.
  ```css
  @font-face{font-family:'Nibpro';src:url('assets/fonts/nib-semibold-pro.woff2') format('woff2');
    font-weight:500;font-style:normal;font-display:swap}
  ```
  Add `<link rel="preload" href="assets/fonts/nib-semibold-pro.woff2" as="font" type="font/woff2" crossorigin>`.
- **DM Sans** stays on Google Fonts (400;500;600;700 — drop 800/900, drop Inter entirely).
- Serif goes on: screen titles, splash title, result banner text, all BIG numbers
  (timer number, player scores, countdown digits, VS, result score compare, stat values,
  level number, leaderboard points). Serif is `font-weight:500`, tight leading (1.02–1.08),
  letter-spacing -0.01em. Nothing below title/number level is serif.
- **Eyebrow style** for section labels ("TÓPICOS", "RANKING", "MISSÕES", "JOGADORES ONLINE"):
  DM Sans 600, 11px, uppercase, letter-spacing .08em, color `--primary-soft`.
- Body on dark = `--text-sec` (#C7D2DE), never `rgba(255,255,255,.65)`.
- Headlines mixed-case (never all-caps — caps are for eyebrows only). Buttons: DM Sans 600,
  normal case ("Jogar", not "JOGAR").

## 3. Signature shapes & surfaces

- **Giant corner** (`border-radius:var(--r-giant)`) on AT MOST one element per screen:
  home JOGAR card (bottom-left balloon), result banner, splash logo tile. It's a silhouette,
  not a default.
- **Cards**: opaque `--card` with 1px `--border`, radius 20. Glass (`--glass` + blur 20px +
  `--glass-border`) for overlays: bottom sheet, modals, bottom nav, powerup chips.
- **Buttons**: primary CTA = flat `--primary` fill, radius `--r-pill` (the site's pill
  button), DM Sans 600 16px, icon AFTER label. Secondary = glass pill (`--glass` +
  `--glass-border`). Destructive = `--danger-bg` fill + `--danger-text` text.
- **No box-shadows** except: glass nav elevation `0 -8px 30px rgba(0,0,0,.35)` and modal
  `0 16px 48px rgba(0,0,0,.5)`. Depth = surface contrast.
- **Garnish** (sparingly): `.glow` — fixed radial `--primary-glow` blob, one per screen max
  (splash, results). Replace the current body radial-gradients with two brand glows
  (indigo top-left, faint periwinkle bottom-right; kill the purple one).

## 4. Lima discipline (scarcity rule)

Lima appears in exactly these places and nowhere else:
1. Combo badge at x2/x3 multiplier (`--lima` fill, `#131C25` text) + the 4th/5th combo dots.
2. Victory: the word "Vitória" highlight / winning score in results.
3. Level-up flash number.
4. Splash progress bar fill.
One lima element visible per screen, maximum. Lima is NEVER a large fill, never on light.

## 5. Per-screen notes

- **Splash**: ink field + one indigo glow. Logo = white Franq mark (inline SVG from
  `assets/brand/franq-mark.svg`, `currentColor`) on `--card` tile with giant corner. Title
  "Franq Quiz" in serif (keep letter-pop animation, recolor to `--text` with "Quiz" in
  periwinkle). Progress bar lima. Kill the spinning ring + purple gradient tile + particles→
  keep particles but token colors, subtler (opacity .2).
- **Login**: eyebrow "BEM-VINDO" + serif title "Entrar no Franq Quiz". Inputs: `--card` fill,
  radius 16, focus ring `--primary-ring` (box-shadow 0 0 0 3px). CTA pill "Entrar".
- **Home**: header w/ avatar (ring → 2px `--primary`), name DM Sans 700, role+rank in
  `--text-ter`. **Replace PNG play buttons** (`big_button.png`) with CSS cards: JOGAR =
  `--primary` fill card w/ giant corner + white mark watermark + serif "Jogar"; DESAFIAR =
  glass card w/ periwinkle serif. Icon chips top-right = `--glass-chip`. Section headers →
  eyebrows. Topic tiles: `--card`, radius 16, existing SVG icons. Ranking rows unchanged
  structurally, points in serif periwinkle.
- **Topics**: same tiles; header w/ glass back chip + serif title.
- **Matchmaking/countdown**: serif VS + countdown digits (72px serif, spring pop per digit),
  players on glass chips. "VAI!" in lima? NO — countdown "VAI!" in periwinkle (lima budget
  is for results).
- **Gameplay**: bg `--bg-deep` for focus. Topic label = eyebrow. Timer number serif 24px.
  Timer bar: `--ok`→`--warn`→`--danger` fills. Question text 16px DM Sans 600 `--text`.
  Answer buttons: `--card` radius 16, letter chip glass; correct = `--ok-bg` fill +
  `--ok` border + white text; wrong = `--danger-bg`/`--danger` + **shake keyframe**
  (translateX ±4px, 300ms). Powerups = glass chips with inline SVG icons (clock, scissors→
  use "split" icon, x2 badge), cost in amber. Combo dots → `--primary`; badge lima at ≥x2.
  Score digits serif.
- **Results**: banner card w/ giant corner: win = `--ok-bg` + serif "Vitória!" w/ lima
  highlight word; draw = `--card` + periwinkle "Empate"; loss = `--danger-bg` + serif
  "Não foi dessa vez". Score compare serif 40px. Rewards list: labels `--text-sec`, values
  serif `--ok-text`; coins amber. XP bar `--primary` fill. Confetti recolor:
  [#687BEA,#8B9BFF,#DCFF79,#F5F7FA]. Count-up animation on points value.
- **Leaderboard**: pill-tabs (glass track, `--primary` active pill). Top-3 rows: 1st gets
  lima number?? NO — 1st = periwinkle serif number + small crown SVG; keep me-row
  `--primary-glow` bg. Points serif.
- **Profile**: avatar ring `--primary`, name serif 24px, stat values serif periwinkle,
  medals: `--card` tiles, earned = periwinkle stroke icons, locked = 25% opacity.
- **Settings**: toggle track `--card-2`, ON = `--primary` (exists). Danger button per
  button spec. Version footer `--text-ter`.
- **Chat/Notifications**: header glass, tab pills like leaderboard, bubbles: them = `--card`,
  me = `--primary`; news icons → glass chips w/ stroke SVGs (no emoji).
- **Modals/sheets** (challenge sheet, PvP invite, tutorial): glass card, radius 24 top,
  grabber handle 36×4px `--border`, serif titles, eyebrow section labels.
- **Bottom nav**: `--glass-nav` + blur 24, active item = periwinkle text + icon, with a
  3px×16px rounded indicator bar under? NO — active = periwinkle + `--glass` pill behind
  icon. Labels 10px DM Sans 600 normal-case (drop uppercase).

## 6. Motion language

Keep the existing animation infra (`.anim-fiu` etc. + stagger). Changes:
1. **Screen enter**: keep fadeInUp 400ms stagger; add `.screen.active` a subtle 250ms fade.
2. **Answer wrong**: add shake. **Answer correct**: quick scale pop 1→1.04→1 (250ms spring).
3. **Countdown digits**: spring scale-in per digit (exists via bounceIn — retune to 350ms).
4. **Combo badge**: springBounce (exists), lima.
5. **Results**: staggered reveal (banner → score → rewards rows 60ms apart → XP fill 1s).
   Points count-up via rAF ~800ms.
6. **Nav taps**: icon scale .9→1 spring on tab switch.
7. **Toast**: slide-down from top with spring, glass card.
8. **prefers-reduced-motion**: global media query killing all animations/transitions to
   .001ms — MISSING today, must add.
All animations ≤500ms except XP fill/count-ups (~1s). Never animate layout properties
(width/height on cards) — transform+opacity only; timer/XP bars use width (fine, contained).

## 7. Icons

One dialect: Lucide-style inline SVG, `viewBox="0 0 24 24" fill="none" stroke="currentColor"
stroke-width="2" stroke-linecap="round" stroke-linejoin="round"`. Sizes: nav 22, chips 18,
inline 16. Replace ALL emoji glyphs in UI chrome: powerups (⏱✂️2️⃣→ timer/scissors/zap-x2),
missions (🎯→target etc.), explanation 💡→lightbulb, challenge ⚔️→swords, 🤖→bot, coins 🪙→
custom coin (circle + "F"?)→ simple circle-dollar Lucide "coins" glyph recolored amber,
medals (exists as SVG, restyle stroke to currentColor). Topic icons: keep existing
`design/img/icon_*.svg` files. Emoji stays ONLY inside question/explanation CONTENT text
(pt-BR content may contain them) and avatar emoji fallbacks for AI opponents.

## 8. Hard constraints

- Zero game-logic changes in the design pass (bug fixes land separately, before).
- Preserve all element IDs the JS queries (`timerBar`, `pScore`, `ans0..3`, `notifBadge`…)
  and all `esc()` escaping calls added by the security fix pass.
- Keep 390px max-width shell, safe-area paddings, `touch-action`, min 44px touch targets
  (upgrade the ones below 44px: ranking-challenge-btn, chat tabs, news-action).
- PT-BR copy with proper accents; chrome copy stays PT-BR.
- Single-file constraint stays (CSS inline in `<style>`), fonts/images as repo files.
- Contrast: all text ≥4.5:1 against its surface (`--text-ter` on `--card` is the floor —
  verify #7C8899 on #1E2738 ≈ 4.6:1 ✓). Timer/score never below 14px.
