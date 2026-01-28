# 🎮 GAME DESIGNER AGENT

## Agent Identity

| Field | Value |

| **Name** | Game Designer Agent ||-------|-------|

| **Module** | Click of Fate || **Role** | Balance, Mechanics & Game Feel |

| **Reports To** | Architect Agent |

---

## 🎯 Responsabilités

2. **Progression** - Power scaling, difficulté par planète1. **Balance** - Stats des héros, ennemis, boss

3. **Pressure System** - Valeurs d'overload, durées de punition3. **Economy** - Rewards, currency amounts

4. **Game Feel** - Timings, feedback, satisfaction

## 📊 Tables de Balance Actuelles---

### Hero Power Scaling

| Progression | Power | HP | ATK | HP Mult | ATK Mult |

| New Player | 100 | 150 | 15 | 1.0x | 1.0x ||-------------|-------|-----|-----|---------|----------|

| Venus Done | 200 | 240 | 21 | 1.6x | 1.4x || Mercury Done | 150 | 195 | 18 | 1.3x | 1.2x |

| Earth Done | 400 | 375 | 30 | 2.5x | 2.0x || Mars Done | 280 | 300 | 26 | 2.0x | 1.7x |

````gdscript### Base Hero Stats












































































































































- [ ] Sessions are 3-5 minutes- [ ] Overload is annoying but not game-ending- [ ] Earth/Mortis is hard (20% success rate)- [ ] Mars is challenging (40% success rate)- [ ] Venus requires some skill (60% success rate)- [ ] New player can beat Mercury (80% success rate target)## 📋 Checklist Balance---| 2026-01-28 | Wave scaling: 1.15x | Was 1.2x, wave 5 too hard || 2026-01-27 | Attack overload: 4s | Was 5s, felt too long || 2026-01-27 | Overload per-action | Global block too punitive || 2026-01-27 | Dr. Mortis HP: 1500 | Felt too easy at 1000 ||------|--------|--------|| Date | Change | Reason |## 📝 Balance Changes Log---```# It's defined in HERO_POWER_PER_PLANET directly# Actually: Power is a label, not a calculation# Earth done: 2.5*50 + 2.0*50 = 225... wait# New player: 1.0*50 + 1.0*50 = 100var power := int(hp_mult * 50 + atk_mult * 50)```gdscript### Power Display```var dodged := randf() < dodge_chancevar dodge_chance := defender.get_effective_dodge_chance()```gdscript### Dodge Calculation```var damage := base_damage * (2.0 if is_crit else 1.0)var is_crit := randf() < attacker.get_effective_crit_chance()var base_damage := attacker.base_stats.attack```gdscript### Damage Calculation## 🔢 Formules---- Overload = feedback négatif clair- Dégâts visibles sur l'entité touchée- Chaque clic = feedback visuel### 4. Feedback Immédiat- Perfect pour mobile (sessions courtes)- 5 vagues + 1 boss = ~3-5 minutes par planète### 3. Session Length- Dr. Mortis est un vrai mur (x3 HP du boss précédent)- Le power up après victoire est tangible (+30-50%)- Chaque planète est sensiblement plus difficile### 2. Progression Satisfaisante- Le joueur doit trouver son rythme- Mais trop de clics = overload = punition- Plus tu cliques, plus tu es efficace### 1. Risk/Reward## 🎯 Design Principles---```const PRESSURE_DECAY_DELAY := 1.5  # Délai avant decayconst PRESSURE_DECAY_RATE := 8.0  # % par seconde```gdscript### Pressure Decay| Attack | 100% | 4.0s || Dodge | 100% | 3.0s || Heal | 100% | 5.0s ||--------|-----------|----------------|| Action | Threshold | Block Duration |### Overload Thresholds & Durations| Attack | +25% || Dodge | +15% || Heal | +20% ||--------|---------------|| Action | Pressure Gain |### Pressure Gain per Action## ⚡ Pressure System Balance---- REPLAY (après victoire) = garde les coins- RETRY = perd les coins de la run en cours### Retry System| Victory Bonus | 100 || Wave Clear | 25 || Enemy Kill | 5 + (wave × 2) ||-------|-----------|| Event | StarCoins |### Rewards## 💰 Economy---| DR. MORTIS | 3 | 1500 | 35 | 0.5 | 💀 || Mars Warlord | 2 | 700 | 28 | 0.6 | ⚔️ || Venus Queen | 1 | 550 | 22 | 0.8 | 👑 || Mercury Guardian | 0 | 400 | 18 | 0.7 | 🔥 ||------|--------|-----|-----|-------|-------|| Boss | Planet | HP | ATK | Speed | Emoji |### Boss Stats```const WAVE_ATK_SCALING := 1.08  # +8% ATK par vagueconst WAVE_HP_SCALING := 1.15   # +15% HP par vague```gdscript### Wave Scaling| Earth | 1.5x | 1.4x | 0.8x | Earth Defender || Mars | 1.3x | 1.2x | 0.9x | Mars Trooper || Venus | 1.0x | 1.0x | 1.0x | Venus Guard || Mercury | 0.8x | 0.7x | 1.3x | Mercury Drone ||--------|---------|----------|------------|------|| Planet | HP Mult | ATK Mult | Speed Mult | Name |### Enemy Scaling by Planet```const HERO_DODGE_CHANCE := 0.10  # 10%const HERO_CRIT_CHANCE := 0.15  # 15%const HERO_ATTACK_SPEED := 1.2  # Attaques par secondeconst HERO_BASE_ATTACK := 15const HERO_BASE_HP := 150```
````
