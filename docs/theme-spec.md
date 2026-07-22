# Light/Dark Theme Spec — index.html

Add a light + dark theme. **Light is the default.** Manual toggle in Settings (no OS
auto-switch). Persist the choice; apply flash-free on load. Light palette is derived from the
Franq site-kit (light-first brand), so it must look premium, not like an inverted dark theme.

## 1. Token architecture
Replace the single `:root{...}` token block with TWO blocks: `:root` holds the LIGHT tokens
(default), and `:root[data-theme="dark"]` overrides with DARK tokens. Keep every existing token
NAME. Add three new tokens (`--track`, `--dot`, `--lima-ink`) used to flip currently-hardcoded
values (see §3).

```css
:root{ /* ===== LIGHT (default) ===== */
  --bg:#F5F7FB; --bg-deep:#EAEDF7; --card:#FFFFFF; --card-2:#EEF0F8;
  --glass:rgba(19,28,37,0.04); --glass-strong:rgba(19,28,37,0.08);
  --glass-chip:rgba(104,123,234,0.08); --glass-nav:rgba(245,247,251,0.82);
  --glass-border:rgba(19,28,37,0.10);
  --border:#E4E6F2; --border-soft:#EEF0F8;
  --track:rgba(19,28,37,0.08); --dot:rgba(19,28,37,0.16);
  --primary:#687BEA; --primary-soft:#4A5BD0; --primary-deep:#3B4794;
  --primary-ring:rgba(104,123,234,0.28); --primary-glow:rgba(104,123,234,0.14);
  --lima:#DCFF79; --lima-bg:rgba(220,255,121,0.32); --lima-ink:#4D5A16;
  --ok:#06A37A; --ok-text:#06A37A; --ok-bg:rgba(6,163,122,0.12);
  --warn:#E6952B; --warn-text:#B26A12; --warn-bg:rgba(230,149,43,0.14);
  --danger:#DC2F5B; --danger-text:#C42A54; --danger-bg:rgba(220,47,91,0.10);
  --text:#131C25; --text-sec:#495057; --text-ter:#6B7480;
  --accent:#687BEA; --accent-light:#4A5BD0; --success:#06A37A; --gold:#B26A12;
  --flame:#E6952B; --card-border:#E4E6F2;
  /* keep the existing --font-*, --r-*, --ease-* tokens unchanged in :root */
}
:root[data-theme="dark"]{ /* ===== DARK ===== */
  --bg:#131C25; --bg-deep:#0E1014; --card:#1E2738; --card-2:#2E3944;
  --glass:rgba(255,255,255,0.06); --glass-strong:rgba(255,255,255,0.10);
  --glass-chip:rgba(46,57,68,0.45); --glass-nav:rgba(14,18,26,0.82);
  --glass-border:rgba(255,255,255,0.12);
  --border:rgba(255,255,255,0.09); --border-soft:rgba(255,255,255,0.05);
  --track:rgba(255,255,255,0.06); --dot:rgba(255,255,255,0.14);
  --primary:#687BEA; --primary-soft:#8B9BFF; --primary-deep:#45529C;
  --primary-ring:rgba(104,123,234,0.35); --primary-glow:rgba(104,123,234,0.20);
  --lima:#DCFF79; --lima-bg:rgba(220,255,121,0.14); --lima-ink:#DCFF79;
  --ok:#06A37A; --ok-text:#4ADBB5; --ok-bg:rgba(6,163,122,0.16);
  --warn:#E6952B; --warn-text:#F2B45C; --warn-bg:rgba(230,149,43,0.15);
  --danger:#DC2F5B; --danger-text:#F4779A; --danger-bg:rgba(220,47,91,0.15);
  --text:#F5F7FA; --text-sec:#C7D2DE; --text-ter:#93A0B0;
  --accent:#687BEA; --accent-light:#8B9BFF; --success:#06A37A; --gold:#F2B45C;
  --flame:#E6952B; --card-border:rgba(255,255,255,0.09);
}
```
Keep the `--font-*`, radius `--r-*`, and `--ease-*` tokens exactly as they are (theme-agnostic).
Add `html{color-scheme:light dark}` is NOT wanted (we control it manually) — instead leave form
controls default; do add `transition:background-color .25s ease,color .25s ease` to `body` so
toggling feels smooth (but NOT on `*`, that's too heavy).

## 2. Toggle, persistence, flash-free apply
- `defaultState().settings` gains `theme:'light'`. (Existing saves without it → default light via
  the deep-merge already in `mergeState`; make sure the merge fills it.)
- Apply function: `function applyTheme(t){document.documentElement.setAttribute('data-theme', t==='dark'?'dark':'light'); var m=document.querySelector('meta[name=theme-color]'); if(m)m.setAttribute('content', t==='dark'?'#131C25':'#F5F7FB');}`
- Call `applyTheme(state.settings.theme)` in `loadState()` (after parse/merge) AND at the end of
  `loadProfileFromSupabase()` (after the settings merge), so a synced setting wins.
- **Flash-free:** add a tiny inline script in `<head>` (right after the font `<link>`s, before
  `<style>`) that reads the saved theme pre-paint:
  `<script>try{var s=JSON.parse(localStorage.getItem('franqQuizV3'));var t=s&&s.settings&&s.settings.theme;document.documentElement.setAttribute('data-theme',t==='dark'?'dark':'light');}catch(e){document.documentElement.setAttribute('data-theme','light');}</script>`
- Settings screen (`renderSettings`): add a NEW first row **"Modo escuro"** with a moon icon
  (Lucide moon: `<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>`) and a `.toggle` that is `on`
  when `state.settings.theme==='dark'`. Wire it to a new `toggleTheme(el)` that flips
  `state.settings.theme`, calls `applyTheme(...)`, toggles the `.toggle.on` class + `aria-checked`,
  `sfxClick()`, `saveState()`. (Match the existing toggle-row markup incl. `role="switch"`/`aria-checked`.)

## 3. Flip the currently-hardcoded theme-locked values
- Replace every hardcoded `rgba(255,255,255,0.0X)` that is a **bar/track background**
  (score-bar-wrap, timer-bar-wrap, xp-bar-wrap, profile-xp-bar, mission-prog-bar,
  splash-bar-wrap) with `var(--track)`.
- Combo dot inactive `.combo-dot{background:rgba(255,255,255,0.14)}` → `var(--dot)`.
- Any remaining hardcoded white-alpha that is a **surface** → `var(--glass)`, a **border** →
  `var(--border)` or `var(--glass-border)`, a **strong hover** → `var(--glass-strong)`.
- KEEP `color:#fff` (15×) — those are text on periwinkle/ok/danger fills, fine in both themes.
- KEEP the two `rgba(255,255,255,0.75)` / `0.6` — they're sub-label/time text on colored fills
  (play-sub on periwinkle, chat time on periwinkle) — fine in both themes.
- KEEP `.combo-badge{color:#131C25}` (dark ink on lima — fine both themes).
- Replace all 5 `color:var(--lima)` (lima used as TEXT: results win `.hl`, `.level-up-flash`,
  leaderboard `.top1 .lb-rank`, big points-float, and any other) → `var(--lima-ink)`. Lima stays
  as a FILL (combo-badge bg, splash-bar, glow, perfect-flash bg, lima-bg tints) unchanged.
- JS inline styles (notifications panel, toggle rows, etc.): the ~22 inline `rgba(255,255,255,x)`
  in template strings — swap surfaces→`var(--glass)`, borders→`var(--border)`, panel bg already
  uses `var(--bg)`. The notification panel header/tabs must read on light too.
- Confetti color array `['#687BEA','#8B9BFF','#DCFF79','#F5F7FA']`: replace `#F5F7FA` (invisible on
  light) with `#06A37A` (teal) so all four read on both themes.
- `#app` background radial glows use `rgba(104,123,234,...)` — leave (subtle on both).
- Splash `#splash` radial uses `rgba(104,123,234,0.16)` over `--bg` — leave (works on both).

## 4. Contrast checks the implementer must respect (light mode)
- `--primary-soft:#4A5BD0` on white ≈ 5.9:1 (emphasis text/serif numbers) ✓ — this is why it's
  deep in light, not the dark theme's #8B9BFF.
- `--text-ter:#6B7480` on `--bg #F5F7FB` ≈ 4.6:1 ✓ (floor).
- `--lima-ink:#4D5A16` on white ≈ 6.6:1 ✓ (Franq-sanctioned lime-on-light).
- White `#fff` on `--primary #687BEA` ≈ 3.4:1 — OK for the large/bold button labels used (≥16px
  bold); do not use white on primary for small text.
- Answer `.correct`/`.wrong` keep `var(--text)` for the answer body over the tint-bg — verify it
  reads on the light tint (it does: ink on 12% teal/pink over white).

## 5. Verify
Parse (node --check → PARSE_OK). Then confirm both themes render: `data-theme` unset/`light` =
light default; setting dark flips all surfaces. No element should stay dark-navy in light mode
(grep the file after: no raw `rgba(255,255,255` should remain as a *surface/track/border* — only
the allowed text-on-fill ones). Return a checklist (§1 palette, §2 toggle/persist/flash-free,
§3 each flip, §4 contrast) DONE/PARTIAL + notes + deviations.
