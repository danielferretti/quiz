# Game-Feel Brief — more motion + sound FX (index.html)

Goal: make Franq Quiz feel like a polished arcade game — juicy feedback on every correct
answer, escalating combos, satisfying rewards. ADDITIVE ONLY. Do not change scoring, timer,
PvP, or Supabase logic, and do not rename/remove any element id. Single self-contained file.

Guardrails:
- Sounds: every new sfx must respect `state.settings.sfx` (the existing `playTone` already
  gates on it — reuse it; don't play audio directly). Keep tones short (<400ms) and use the
  existing WebAudio `audioCtx`/`playTone(freq,dur,type,gain,freqEnd)` helper.
- Motion: every new visual effect must be skipped when `reducedMotion()` returns true
  (helper already exists), and CSS animations must already be neutralized by the existing
  `@media (prefers-reduced-motion:reduce)` block — add new keyframes but rely on that block.
- Effects must be `position:fixed; pointer-events:none; z-index` above content but below modals
  (use z-index ~350, below the 500 tutorial / 999 level-up). Auto-remove DOM nodes after they
  finish (no leaks).
- Verify parse at the end (node --check on the extracted script → PARSE_OK).

## A. Sound FX — enrich + add (near the existing sfx* functions ~line 950-990)
1. Punch up existing: `sfxCorrect` → a bright rising two-note chime (e.g. 660→990 then 1320);
   `sfxWrong` → a short descending "buzz" (keep it soft, not harsh); keep `sfxCombo(n)` rising
   with n (already does — make the top end brighter).
2. Add new (all gated via playTone, so they auto-respect the sfx setting):
   - `sfxCoin()` — quick two-tick "ching" (~1400→2000, tiny gain) for coin gains.
   - `sfxLevelUp()` — ascending 4-note arpeggio (e.g. 523,659,784,1047) for level-ups.
   - `sfxRoundStart()` — soft upward "swoosh" (sine sweep ~300→700).
   - `sfxCombo` already exists; add `sfxComboBreak()` — a soft downward blip when a combo of ≥3
     is lost (call it in the wrong/timeUp path only when previous combo was ≥3).
3. Wire them:
   - `sfxRoundStart()` in `showRoundOverlay` (when the "Rodada N" overlay appears).
   - `sfxLevelUp()` in `endMatch` when `state.level>oldLevel` (alongside the existing vibrate).
   - `sfxCoin()` in `endMatch` right before/around showing the coins value, and in
     `claimFlameToken` if still present.
   - `sfxComboBreak()` in `selectAnswer` (wrong branch) and `timeUp()` when the combo being
     reset was ≥3.

## B. Juice — visual feedback (CSS keyframes + small JS spawns)

1. **Floating "+N" on correct** — in `selectAnswer` correct branch, after computing `pts`,
   spawn a floating label near the player score (`#pScore`) that rises ~40px and fades over
   ~800ms. Text `"+"+pts`. Serif. Color: `--primary-soft` normally, `--lima` when
   `game.combo>=4` (big combo). Add `.points-float` CSS + `@keyframes pointsFloat`. Remove node
   on animationend. Skip if `reducedMotion()`.
2. **Player score count-up** — replace the instant `document.getElementById('pScore').textContent=game.playerScore`
   in `selectAnswer` with a short count-up (reuse the existing `animateScoreCountUp(elId,target,dur)`
   helper — pass ~500ms). Keep the final value exactly `game.playerScore`.
3. **Correct/Wrong screen flash** — a fixed full-screen vignette overlay that flashes once:
   green radial for correct, red radial for wrong. Add `.fx-flash` (fixed, inset:0,
   pointer-events:none, z-index:350, opacity 0) with `.fx-flash.correct` /
   `.fx-flash.wrong` background radial-gradients, and `@keyframes fxFlash`
   (0%→ ~0.5 opacity → 0). Spawn+remove in `selectAnswer` / `timeUp`. Subtle — max opacity ~0.35.
   Skip if `reducedMotion()`.
4. **Combo escalation glow** — when `game.combo>=3` after a correct answer, flash a brief
   inset edge-glow (a fixed overlay with `box-shadow: inset 0 0 60px <color>` or a radial ring),
   periwinkle at combo 3, `--lima` at combo>=4. Add `.combo-glow` + `@keyframes comboGlow`
   (~600ms fade). One node, auto-removed. Skip if `reducedMotion()`.
5. **Correct letter-chip pop** — when an answer is marked `.correct`, give its `.letter` chip a
   quick scale pop. Add a CSS rule: `.answer-btn.correct .letter{animation:chipPop .35s var(--ease-spring)}`
   with `@keyframes chipPop{0%{transform:scale(1)}50%{transform:scale(1.25)}100%{transform:scale(1)}}`.
6. **Countdown digit pop** — the `.match-countdown` already springs; bump the scale range so it
   reads more explosive (0.5→1.18→1). (CSS only.)
7. **Results coins count-up** — in `endMatch` results markup, animate the coins value (the
   `.result-coins` number) up from 0 with the count-up helper (~700ms), synced with `sfxCoin()`.
8. **Perfect round celebration** — if `game.correctCount===5` (perfect) in `endMatch`, in
   addition to existing confetti, briefly show a serif "Perfeito!" lima flourish (reuse the
   level-up-flash style or a lightweight `.perfect-flash`, auto-dismiss ~1.2s). Skip heavy
   version if `reducedMotion()` (then just the text, no confetti — confetti is already gated).

## C. Keep it tasteful
Lima stays scarce: only combo>=4 glow/float, victory, level-up, perfect. Everything else is
periwinkle/semantic. Don't add sound to routine navigation taps (keep `sfxClick` where it is).
Don't animate layout props (width/height) on cards — transform/opacity only for the new fx.

When done: run the node --check parse verification and a quick grep to confirm the new sfx
functions and CSS classes exist. Return a concise checklist (A1-3, B1-8, C) DONE/PARTIAL with
one-line notes + deviations. Report only.
