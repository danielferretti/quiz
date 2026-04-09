---
tags:
  - project/quiz
  - type/brd
  - status/active
  - topic/gamification
aliases:
  - Franq Quiz
  - Quiz BRD
---

# Franq Quiz - Business Requirements Document (BRD)

**Product:** Franq Quiz
**Tagline:** "Acesse. Ofereça. Realize."
**Version:** 1.0 (MVP)
**Date:** 2026-03-10
**Platform:** Mobile-first web application (max-width 430px, PWA-capable)

---

## 1. Executive Summary

Franq Quiz is a gamified knowledge quiz platform designed for **Franq Open Bank** employees. Players compete in 1v1 matches across financial industry topics, earn points and virtual currency, climb leaderboards, unlock medals, and level up their profiles. The product aims to increase engagement with institutional knowledge, foster peer competition, and reinforce financial literacy across the organization.

---

## 2. Business Objectives

| # | Objective |
|---|-----------|
| O1 | Drive continuous learning of financial products, compliance, and customer service topics among Franq employees |
| O2 | Encourage healthy competition and peer engagement through challenges and rankings |
| O3 | Increase knowledge retention via gamification mechanics (points, coins, levels, medals) |
| O4 | Provide management visibility into employee knowledge levels via leaderboard data |
| O5 | Create a rewarding experience that motivates regular participation |

---

## 3. User Personas

| Persona | Description |
|---------|-------------|
| **Player** | A Franq Open Bank employee (e.g., Personal Banker, Gerente de Agencia, Analista de Investimentos, Assessor Financeiro, Especialista Private, Gerente de Carteira, Consultor de Cambio, Analista de Compliance) who logs in with their name and role |

---

## 4. Functional Requirements

### 4.1 Authentication & Onboarding

| Rule ID | Rule | Details |
|---------|------|---------|
| AUTH-01 | Login requires full name and role | Name is mandatory; role defaults to "Personal Banker" if left empty |
| AUTH-02 | Splash screen with loading bar | Animated loading (0-100%) before showing login screen |
| AUTH-03 | Logout returns to login screen | Session state is reset to login |

### 4.2 Topic Management

| Rule ID | Rule | Details |
|---------|------|---------|
| TOP-01 | 8 quiz topics available | Mercado Financeiro, Produtos de Investimento, Compliance & Regulacao, Atendimento ao Cliente, Cambio & Internacional, Previdencia Privada, Renda Fixa, Renda Variavel |
| TOP-02 | Each topic has a minimum of 10 questions | Questions are multiple-choice with exactly 4 options and 1 correct answer |
| TOP-03 | "Hot" topic designation | One topic can be tagged as `hot`, granting a **2x points** multiplier and featured placement ("Topico da Hora") |
| TOP-04 | Home screen shows up to 4 topics | The hot topic is always shown first, followed by 3 randomly selected others |
| TOP-05 | Topic grid displays player level and random ranking position | Each tile shows current player level and a simulated ranking position |

### 4.3 Matchmaking

| Rule ID | Rule | Details |
|---------|------|---------|
| MAT-01 | Two play modes | **Quick Play** (player selects a topic) and **Challenge** (player selects an opponent) |
| MAT-02 | Opponent matching | System randomly selects from a pool of 10 AI opponents, each with name, role, and avatar |
| MAT-03 | Matchmaking flow | 2-second search phase -> opponent reveal -> 3-second countdown -> match starts |
| MAT-04 | Match cancellation | Player can cancel during the search phase; cancellation is disabled after opponent is found |
| MAT-05 | Challenge mode | Shows 5 randomly selected opponents from the pool; selecting one starts a match on a random topic |

### 4.4 Gameplay

| Rule ID | Rule | Details |
|---------|------|---------|
| GAM-01 | Match structure | 5 rounds per match, each with 1 question |
| GAM-02 | Question selection | 5 questions randomly selected from the chosen topic's question bank (no repeats within a match) |
| GAM-03 | Timer per question | **10 seconds** per question; timer decreases in 0.1s increments |
| GAM-04 | Timer visual states | > 50% remaining = green ("safe"), 25-50% = yellow ("warning"), < 25% = red ("danger" with pulse animation) |
| GAM-05 | Audio warning | Sound effect plays when timer reaches 3 seconds remaining |
| GAM-06 | Time-up behavior | If time expires, the question is marked as incorrect; the correct answer is highlighted |
| GAM-07 | Round 5 automatic bonus | The final round (round 5) automatically activates **double points** |
| GAM-08 | Answer feedback | Correct answer: green highlight + success sound. Wrong answer: red highlight on selected + green on correct + error sound + vibration |
| GAM-09 | Inter-round transition | 2-second delay after answer reveal, then round overlay for 1.5 seconds |
| GAM-10 | Quit match penalty | Quitting mid-match forfeits the game; no rewards are granted |

### 4.5 Scoring System

| Rule ID | Rule | Details |
|---------|------|---------|
| SCR-01 | Base points per correct answer | `max(5, round(timeLeft * 2))` — faster answers earn more points (max ~20 pts) |
| SCR-02 | Double points modifier | When active (round 5 or power-up), points per correct answer are multiplied by 2 |
| SCR-03 | Coins per correct answer | +2 coins per correct answer during the match |
| SCR-04 | Score bar visualization | Dynamic bar showing proportional score between player and opponent |

### 4.6 AI Opponent Behavior

| Rule ID | Rule | Details |
|---------|------|---------|
| OPP-01 | Opponent correct answer probability | **55%** chance to answer correctly on each question |
| OPP-02 | Opponent points per correct answer | Random value between **5 and 19** points (floor of random * 15 + 5) |
| OPP-03 | Opponent answers on time-up | Even when the player runs out of time, the opponent still has its 55% chance to score |

### 4.7 Power-Ups

| Rule ID | Power-Up | Cost | Effect | Constraint |
|---------|----------|------|--------|------------|
| PU-01 | **Time Extra** (⏱️) | 10 coins | Adds +5 seconds to the current timer (capped at 15s) | One-time use per match |
| PU-02 | **50/50** (✂️) | 15 coins | Eliminates 2 incorrect answers, leaving the correct answer and 1 distractor | One-time use per match |
| PU-03 | **Pontos x2** (2️⃣) | 20 coins | Activates double points for the current question | One-time use per match |
| PU-04 | Availability rules | — | Power-ups are locked (greyed out) if the player doesn't have enough coins; disabled after use; cannot be used after answering |

### 4.8 Rewards & Post-Match

| Rule ID | Reward Type | Condition | Points | Coins |
|---------|-------------|-----------|--------|-------|
| RWD-01 | Correct answers | Per correct answer during match | (based on SCR-01) | +2 per correct |
| RWD-02 | Match completion | Finishing the match | +50 pts | +10 coins |
| RWD-03 | Victory bonus | Winning the match (score > opponent) | +50 pts | +5 coins |
| RWD-04 | Perfect match bonus | All 5 answers correct | +50 pts | +2 coins |
| RWD-05 | Total points | Sum of all point sources | Accumulates to player profile | — |
| RWD-06 | Total coins | Sum of all coin sources | — | Added to remaining match coins balance |
| RWD-07 | Match outcomes | 3 possible results | Win, Draw, or Loss | Visual: green/purple/red banner |

### 4.9 Progression System

| Rule ID | Rule | Details |
|---------|------|---------|
| PRG-01 | XP equals total points earned | Every point earned also counts as XP |
| PRG-02 | Level-up threshold | Starting XP requirement: **100 XP**; each level increases the requirement by **1.3x** (compounding) |
| PRG-03 | Level-up reward | +10 coins granted automatically on each level-up |
| PRG-04 | Multi-level up | If XP gained exceeds the threshold, excess carries over and can trigger multiple level-ups in one match |
| PRG-05 | Initial player state | Level 1, 0 XP, 50 starting coins, 0 points |

**Level Progression Table (calculated):**

| Level | XP Required | Cumulative XP |
|-------|-------------|---------------|
| 1 -> 2 | 100 | 100 |
| 2 -> 3 | 130 | 230 |
| 3 -> 4 | 169 | 399 |
| 4 -> 5 | 219 | 618 |
| 5 -> 6 | 285 | 903 |
| 6 -> 7 | 371 | 1,274 |
| 7 -> 8 | 482 | 1,756 |

### 4.10 Leaderboard

| Rule ID | Rule | Details |
|---------|------|---------|
| LDB-01 | Global leaderboard | Shows top 20 players ranked by total points |
| LDB-02 | Topic-specific tabs | Leaderboard can be filtered by "Geral" (overall) or by each of the 8 topics |
| LDB-03 | Player highlight | Current player's entry is visually highlighted in the list |
| LDB-04 | Ranking medals | Top 3 positions use gold/silver/bronze visual indicators (emoji medals) |
| LDB-05 | Reset cycle | Leaderboard displays a countdown timer (e.g., "Reseta em 5d 12h") indicating periodic resets |
| LDB-06 | Dynamic positioning | Player is inserted into the leaderboard based on their total points, then the list is re-sorted |

### 4.11 Medals / Achievements

| Rule ID | Medal | Unlock Condition |
|---------|-------|-----------------|
| MDL-01 | Primeira Vitoria (🎯) | Win 1 match |
| MDL-02 | 5 Vitorias (🔥) | Win 5 matches |
| MDL-03 | 10 Partidas (⭐) | Play 10 matches |
| MDL-04 | 500 Pontos (💎) | Accumulate 500 total points |
| MDL-05 | Nivel 5 (👑) | Reach level 5 |
| MDL-06 | Partida Perfeita (🏆) | Get all 5 answers correct in a single match |
| MDL-07 | Top 3 Ranking (🎖️) | Reach top 3 on the leaderboard |
| MDL-08 | 100 Moedas (💰) | Accumulate 100 coins |

### 4.12 Profile

| Rule ID | Rule | Details |
|---------|------|---------|
| PRF-01 | Stats displayed | Games played, win rate (%), total points, coins, level, total wins |
| PRF-02 | Medals gallery | Shows all 8 medals with earned/locked state |
| PRF-03 | Profile info | Name, role, level, avatar |

### 4.13 Settings

| Rule ID | Setting | Default | Type |
|---------|---------|---------|------|
| SET-01 | Sound Effects (SFX) | ON | Toggle |
| SET-02 | Music | ON | Toggle |
| SET-03 | Vibration | ON | Toggle |
| SET-04 | Notifications | ON | Toggle |
| SET-05 | Private Profile | OFF | Toggle |
| SET-06 | Send Feedback | — | Action button |
| SET-07 | Logout | — | Action button |

---

## 5. Virtual Economy Summary

### 5.1 Coin Sources (Inflow)

| Source | Amount |
|--------|--------|
| Initial balance | 50 coins |
| Correct answer (in-match) | +2 per correct |
| Match completion | +10 |
| Victory | +5 |
| Perfect match | +2 |
| Level-up | +10 |

### 5.2 Coin Sinks (Outflow)

| Sink | Cost |
|------|------|
| Power-Up: Time Extra | 10 coins |
| Power-Up: 50/50 | 15 coins |
| Power-Up: Pontos x2 | 20 coins |

### 5.3 Economy Estimate (per match)

| Scenario | Coins earned | Max coins spent | Net |
|----------|-------------|----------------|-----|
| Win (5/5 correct, no power-ups) | 10 + 5 + 2 + 10 = 27 | 0 | +27 |
| Win (3/5 correct, 1 power-up) | 6 + 5 + 10 = 21 | 10-20 | +1 to +11 |
| Loss (1/5 correct, no power-ups) | 2 + 10 = 12 | 0 | +12 |

---

## 6. Content / Question Bank

### 6.1 Topics and Question Count

| Topic | ID | Questions | Hot Topic |
|-------|----|-----------|-----------|
| Mercado Financeiro | `mercado` | 10 | Yes (2x points) |
| Produtos de Investimento | `investimentos` | 10 | No |
| Compliance & Regulacao | `compliance` | 10 | No |
| Atendimento ao Cliente | `atendimento` | 10 | No |
| Cambio & Internacional | `cambio` | 10 | No |
| Previdencia Privada | `previdencia` | 10 | No |
| Renda Fixa | `rendafixa` | 10 | No |
| Renda Variavel | `rendavariavel` | 10 | No |

**Total:** 80 questions across 8 topics

### 6.2 Question Format

- **Type:** Single-choice, 4 options
- **Correct answer:** Always identified by index (position 0 = first option in all current questions)
- **Language:** Brazilian Portuguese
- **Domain:** Financial industry knowledge relevant to banking professionals

---

## 7. User Flows

### 7.1 Core Game Flow

```
Splash -> Login -> Home -> Select Topic -> Matchmaking (2s search + 3s countdown)
-> Round 1..5 (10s timer each) -> Results Screen -> Rematch / New Topic / Home
```

### 7.2 Challenge Flow

```
Home -> "Desafiar" -> Select Opponent Modal -> Random Topic Assigned
-> Matchmaking -> Gameplay -> Results
```

### 7.3 Navigation Structure

| Screen | Access |
|--------|--------|
| Home | Bottom nav, post-results |
| Topics | Bottom nav, home shortcut |
| Leaderboard | Bottom nav, post-results |
| Profile | Bottom nav, home icon |
| Settings | Home gear icon |
| Matchmaking | Topic selection / challenge |
| Gameplay | Post-matchmaking |
| Results | Post-gameplay |

**Bottom navigation** is visible on: Home, Topics, Leaderboard, Profile.
**Bottom navigation** is hidden on: Splash, Login, Matchmaking, Gameplay, Results, Settings.

---

## 8. Non-Functional Requirements

| # | Requirement | Details |
|---|-------------|---------|
| NF-01 | Mobile-first responsive design | Max-width 430px, PWA meta tags, safe-area support |
| NF-02 | Haptic feedback | Vibration on interactions (30ms click, 50ms power-up, 100ms opponent found, 200ms wrong answer) |
| NF-03 | Audio feedback | Web Audio API-based sound effects for clicks, correct/wrong answers, countdown, win/lose, power-up activation |
| NF-04 | Animations | Screen transitions (slide), confetti on victory, timer pulse, shimmer effects, bounce-in, fade-up |
| NF-05 | Offline capability | MVP runs entirely client-side (no backend); all state is in-memory |
| NF-06 | Pull-to-refresh prevention | Touch scroll behavior prevented at top of screen |

---

## 9. Known MVP Limitations & Future Considerations

| # | Limitation | Suggested Evolution |
|---|-----------|-------------------|
| L-01 | No persistent data storage | Add backend API + database for user accounts, scores, and match history |
| L-02 | AI opponents only (no real PvP) | Implement real-time multiplayer via WebSocket |
| L-03 | Correct answer always at index 0 | Randomize answer order at render time to prevent pattern exploitation |
| L-04 | Static question bank (80 questions) | Admin panel for question CRUD; expand to 50+ per topic |
| L-05 | No real authentication | Integrate with Franq Open Bank SSO/identity provider |
| L-06 | Leaderboard is simulated | Backend-driven real leaderboard with periodic resets |
| L-07 | Medal "Partida Perfeita" and "Top 3 Ranking" never unlock | Wire up actual tracking logic for these achievements |
| L-08 | Challenge mode uses random topic | Allow challenger to pick topic when challenging |
| L-09 | No push notifications | Implement for challenge invitations and leaderboard updates |
| L-10 | Coin economy not backed by real rewards | Define reward catalog (e.g., badges, gift cards, recognition) redeemable with coins |
| L-11 | Settings toggles have no real effect (music, notifications, privacy) | Implement actual music playback, notification system, and profile visibility control |
| L-12 | Hot topic is hardcoded | Make hot topic configurable (admin-driven, time-based rotation) |

---

## 10. Glossary

| Term | Definition |
|------|-----------|
| **Coins (Moedas)** | Virtual currency earned through gameplay, spent on power-ups |
| **Points (Pontos)** | Score metric that determines leaderboard ranking |
| **XP** | Experience points (equal to points earned) driving the level system |
| **Power-Up** | Single-use in-match boosts purchasable with coins |
| **Hot Topic (Topico da Hora)** | Featured topic with a 2x points multiplier |
| **Match** | A 5-round 1v1 quiz duel between the player and an opponent |
| **Medal (Medalha)** | Achievement badge unlocked by reaching milestones |

---

## See also

- [[product-os/roadmap/ROADMAP|Product Roadmap]] — company product roadmap
- [[personality-quiz|Tech Games Personality Quiz]] — theme selection quiz (gamification overlap)
- [[business_glossary|Business Glossary]] — Franq entity definitions
- [[company-profile|Company Profile]] — company overview
