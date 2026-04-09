# Replit Prompt — FRANQ QUIZ

> **Attachments to include when pasting this prompt into Replit:**
> 1. `design/new_mockup_quiz.png` — the high-definition mockup of the home screen
> 2. `franq-quiz-v3.html` — the complete working reference implementation (single HTML file, ~2 180 lines)
> 3. All files inside `design/img/` — SVG icons, PNG button backgrounds, and JPG profile photos

---

## What to build

Rebuild **FRANQ QUIZ** — a mobile-first quiz game for bank employees (language: Brazilian Portuguese). The app should be a **single-page web application optimized for iPhone 12 Pro (390 × 844)**. Use the attached mockup image as the pixel-perfect visual reference and the attached `franq-quiz-v3.html` as the full functional reference.

---

## Tech stack

- **Vanilla HTML / CSS / JavaScript** — no frameworks, no build step
- **Google Fonts**: Inter (weights 300–900)
- **All assets** are local (SVGs, PNGs, JPGs in a `design/img/` folder)
- **LocalStorage** for state persistence
- **Web Audio API** for sound effects
- **PWA-ready** meta tags (mobile-web-app-capable, theme-color)

---

## Design system

| Token | Value |
|---|---|
| Background | `#1C2133` |
| Card | `rgba(255,255,255,0.06)` with `rgba(255,255,255,0.08)` border |
| Accent | `#687BEA` / light `#8899FD` |
| Success | `#10B981` |
| Danger | `#EF4444` |
| Gold | `#FFD700` |
| Flame | `#FF6B35` |
| Text | `#FFFFFF` / secondary `rgba(255,255,255,0.55)` / tertiary `rgba(255,255,255,0.35)` |
| Border radius | cards `18px`, buttons `12px`, large `24px` |
| Font | Inter, sans-serif |
| Max width | `390px` (centered in viewport) |

---

## Screens (11 total)

### 1. Splash
- Centered logo (lightning bolt ⚡), animated title "FRANQ QUIZ", tagline "Acesse. Ofereça. Realize."
- Progress bar that fills over ~2.5 s, then auto-transitions to Login (or Home if already logged in)

### 2. Login
- Name input, Role input (default "Personal Banker")
- "ENTRAR" primary button → saves state → goes to Home
- Shows 3-step tutorial overlay on first login

### 3. Home (see mockup image)
- **Header**: profile photo (circular, lime-green border ring `#A3D977`) + name + "Role | Nível {roman numeral}". Tapping the avatar opens Settings. Top-right: chat button SVG → opens Chat screen.
- **Play buttons**: two side-by-side cards using `big_button.png` (purple blob shape) as an `<img>` background with content overlaid. Left = "JOGAR" (icon_jogar.svg, subtitle "Partida rápida"), Right = "DESAFIAR" (icon_desafiar.svg, subtitle "Escolha um oponente"). These are the biggest interactive elements — make them prominent.
- **Tópicos section**: "Tópicos" title + "Ver todos →" link. 3-column grid of square cards using `small_button.png` (sage/olive green) as an `<img>` background, with topic SVG icon + topic name overlaid in dark text (`#3A4A3C`). 6 topics shown on home (the first 6 by homeOrder).
- **Ranking section**: "Ranking" title + "Ver todos →" link. Top 3 players shown: rank number, trophy medal SVGs (medal.svg), circular profile photo, name, "Role | Nivel", score, purple "DESAFIAR" button. Plus a "Você" row at the bottom showing current player position.
- **Bottom nav**: 4 tabs — Início (menu_inicio.svg), Tópicos (menu_topicos.svg), Ranking (menu_ranking.svg), Perfil (menu_perfil.svg). Fixed at bottom, dark blurred background.

### 4. Topics (full screen)
- Back button + "Tópicos" title
- 3-column grid of ALL 8 topics using same `small_button.png` card style
- Each shows SVG icon, name, points + games played meta text
- Clicking a topic starts a match

### 5. Chat
- Back button + two tabs: "Novidades" / "Chat Bankers"
- **Novidades tab**: vertical feed of news cards (bonuses, challenges, events, ranking updates). Each card has a colored icon, title, description, timestamp, and optional action button.
- **Chat Bankers tab**: group chat with message bubbles (profile photos, names for others, right-aligned for "me"). Input bar at bottom with send button. Auto-replies from other bankers after sending a message.

### 6. Matchmaking
- Shows topic name, player VS opponent layout with avatars
- "Buscando oponente..." with animated dots
- After 2s reveals opponent, then 3-2-1 countdown → starts gameplay

### 7. Gameplay
- Top bar: topic name, round counter, quit button
- Score bars for both players
- Timer bar (green→yellow→red) + countdown number (15s per question)
- Question text + 4 answer buttons (A/B/C/D)
- Combo indicator (consecutive correct answers)
- 3 power-ups: 50/50, Extra Time (+5s), Skip
- After answering: shows correct/wrong state + explanation card
- 5 rounds per match

### 8. Results
- Win/Draw/Loss banner with score comparison
- Rewards breakdown (points, coins, XP)
- XP progress bar with level-up animation
- "Review answers" expandable section
- "Jogar Novamente" + "Início" buttons

### 9. Leaderboard
- Filter tabs: Geral + one per topic
- Reset countdown timer
- List of 20 entries: rank, medals, avatar photo, name, role, points, "DESAFIAR" button
- Current player highlighted with accent border

### 10. Profile
- Large avatar with photo, name, role, rank
- XP progress bar
- 6-cell stats grid (Partidas, Vitórias%, Pontos, Moedas, Wins, Nível)
- Medals section (10 medals, locked ones grayed out)

### 11. Settings
- Back button + "Configurações" title
- Toggle rows: Sound FX, Music, Vibration, Notifications, Private Profile
- "Enviar Feedback" button
- "Sair da Conta" danger button (clears localStorage)

---

## Data

### 8 Topics (mapped to question banks)
| Key | Display Name | SVG Icon | homeOrder |
|---|---|---|---|
| mercado | Tópico Surpresa | icon_surpresa.svg | 0 |
| investimentos | Consórcios | icon_consorcio.svg | 1 |
| compliance | Compliance | icon_compliance.svg | 2 |
| atendimento | Home Equity | icon_he.svg | 3 |
| cambio | Crédito Imobiliário | icon_ci.svg | 4 |
| previdencia | Auto | icon_auto.svg | 5 |
| rendafixa | Renda Fixa | icon_ci.svg | 6 |
| rendavariavel | Renda Variável | icon_he.svg | 7 |

- "Tópico Surpresa" picks a random topic when clicked
- Each topic has 10 questions with 4 answers (first is correct), explanation, and difficulty (1-3)

### 10 Opponents
- 3 with profile photos (Francisco Tavares, Karen Lopes, Marcio Godoy)
- 7 with emoji avatars as fallback

### 6 Rank tiers
Estagiário Franq → Assessor → Especialista → Sênior → Master Franq → Lenda Franq

### Game mechanics
- 5 rounds per match, 15s timer per question
- Scoring: base 100 pts + time bonus (up to 100 extra) + combo multiplier
- 3 power-ups per match (50/50, +5s, Skip) costing coins
- Daily missions (3 random from pool of 5)
- Weekly leaderboard reset
- XP/leveling system with exponential curve

---

## Design assets (in `design/img/`)

| File | Usage |
|---|---|
| `big_button.png` | Purple blob background for JOGAR/DESAFIAR buttons |
| `small_button.png` | Sage/olive green background for topic cards |
| `small_button_banner.png` | "+10 pts" diagonal banner (optional) |
| `icon_jogar.svg` | Racing flags icon for Play button |
| `icon_desafiar.svg` | Challenge/person icon for Challenge button |
| `icon_surpresa.svg` | Gift/question icon for Surprise topic |
| `icon_consorcio.svg` | Briefcase icon for Consórcios |
| `icon_compliance.svg` | Lock icon for Compliance |
| `icon_he.svg` | Dollar icon for Home Equity |
| `icon_ci.svg` | House icon for Crédito Imobiliário |
| `icon_auto.svg` | Car icon for Auto |
| `chat_button.svg` | Chat bubble for top-right button |
| `medal.svg` | Yellow trophy for rankings |
| `menu_inicio.svg` | Home nav icon |
| `menu_topicos.svg` | Topics nav icon |
| `menu_ranking.svg` | Ranking nav icon |
| `menu_perfil.svg` | Profile nav icon |
| `profile_picture.jpg` | Default user profile photo |
| `profile_francisco.jpg` | Francisco Tavares photo |
| `profile_karen.jpg` | Karen Lopes photo |
| `profile_marcio.jpg` | Marcio Godoy photo |

---

## Key implementation details

- **Button images are blob shapes**: `big_button.png` and `small_button.png` are NOT rectangular. Use them as `<img>` elements inside a container, with content absolutely positioned on top. Do NOT use them as `background-image` on rectangular divs — that clips the organic shape. Use `drop-shadow` CSS filter for the shadow effect.
- **Screen system**: All screens are `.screen` divs that toggle via `display:none/flex`. One `showScreen(id)` function manages transitions.
- **Avatar border**: Only the main user avatar on the home header gets the lime-green (#A3D977) 2.5px border ring. Ranking/chat avatars have no border.
- **Animations**: Use CSS keyframe animations (fadeInUp, bounceIn, slideInRight, etc.) with staggered `animation-delay` for a polished feel.
- **Sound**: Web Audio API tone generation (sine/square/sawtooth waves) — no audio files needed.
- **State**: Single `franqQuizV3` localStorage key, JSON serialized. Default 50 coins, level 1.

---

## Priority

1. Match the mockup image pixel-perfectly for the Home screen
2. Make all screens functional and navigable
3. Polish animations, transitions, and micro-interactions
4. Ensure all 8 topic question banks work with the gameplay loop
