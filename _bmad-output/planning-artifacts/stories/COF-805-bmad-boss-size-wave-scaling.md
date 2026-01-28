# COF-805: BMAD Mode - Boss Size & Wave Difficulty Scaling

**Epic**: BMAD Mode - Difficulty Balance  
**Status**: 📋 READY FOR IMPLEMENTATION  
**Priority**: High  
**Target Files**:

- `scenes/game_combat_scene.gd` (Boss visual, wave scaling)

---

## User Story

**En tant que** joueur,  
**Je veux** que le boss soit impressionnant et que chaque vague gagnée me rend plus fort,  
**Afin de** sentir une progression continue et que les dernières vagues ne soient pas trop écrasantes.

---

## Context

Après les changements BMAD Mode du 28 janvier 2026 (COF-801, COF-802, COF-804):

- Les ennemis sont maintenant plus nombreux et plus compacts
- Les vagues deviennent exponentiellement plus difficiles
- Le boss actuel n'est pas assez impressionnant visuellement
- Les dernières vagues (Wave 5) sont trop compliquées pour la plupart des joueurs

**Problème identifié**:

1. Boss trop petit comparé aux ennemis reguliers (25% viewport)
2. Pas de progression de puissance en cours de combat
3. Vague 5 avec 16 ennemis (Earth) = 3264 HP à éliminer = impossibilité

**Solution**:

1. Boss occupe **60% de l'espace** de son côté (bien plus imposant)
2. Ajouter un **boost progressif du joueur à chaque vague** complétée (+10% ATK/HP tous les vagues)

---

## Critères d'Acceptation

### Boss Visual

- [x] Boss prend **60% de la largeur** de son côté du screen
- [x] Boss est visiblement plus grand que les ennemis réguliers
- [x] Dr. Mortis (final boss) est **encore plus grand** (75% de l'espace)
- [x] Tous les éléments visuels du boss scale proportionnellement
- [x] Barre de vie du boss reste lisible et bien positionnée
- [x] Pas de clipping avec le container enemy

### Wave Difficulty Scaling

- [x] Après chaque vague complétée, le joueur reçoit un boost
- [x] Boost: **+10% ATK et +10% HP maximal** par vague
- [x] Boost s'accumule (vague 2 = +10%, vague 3 = +20%, etc)
- [x] Boost ajusté visuellement dans la UI
- [x] Boost réinitialise au début de chaque planète
- [x] Boss fight utilise le boost de la vague 5

### Balance Result

- [x] Wave 1: Normal difficulty (baseline)
- [x] Wave 2: +10% joueur vs ennemis normaux
- [x] Wave 3: +20% joueur
- [x] Wave 4: +30% joueur
- [x] Wave 5: +40% joueur vs boss standard
- [x] Chaque vague se sent progressivement plus faisable

---

## Spécifications Techniques

### 1. Boss Visual Size - 60% Viewport

**Ancien système** (avant):

```gdscript
var base_size: int = mini(180, int(viewport_size.x * 0.25))  # Max 25% de la largeur
var size_mult: float = 1.4 if is_final_boss else 1.0
visual.custom_minimum_size = Vector2(base_size, base_size * 1.1) * size_mult
```

**Nouveau système** (TARGET):

```gdscript
# Boss Visual - 60% de l'espace (TARGET)
var base_size: int = mini(432, int(viewport_size.x * 0.60))  # 60% de la largeur!
var size_mult: float = 1.25 if is_final_boss else 1.0  # Dr. Mortis: 75% total
visual.custom_minimum_size = Vector2(base_size, base_size * 1.1) * size_mult
```

**Localisation**: `scenes/game_combat_scene.gd`, fonction `_create_boss_visual()`, ligne ~2184

**Calcul**:

- Mercury/Venus/Mars boss: 720 \* 0.60 = 432px width
- Dr. Mortis (final): 432 \* 1.25 = 540px width (75% effective)
- Height: proportional (width \* 1.1)

**Before/After**:

- Before: 180px base (25% viewport)
- After: 432px base (60% viewport) = **+240% larger!**
- Final boss: 432 \* 1.25 = 540px (75% viewport)

---

### 2. Wave Difficulty Scaling - Progressive Boost

**Ancien système** (avant):

```gdscript
func _on_wave_cleared() -> void:
	coins_earned_this_run += WAVE_CLEAR_BONUS
	SaveManager.add_currency(WAVE_CLEAR_BONUS)
	# ... rien de plus pour le joueur
```

**Nouveau système** (TARGET):

```gdscript
# Variable à ajouter en haut du script:
var wave_bonus_multiplier: float = 1.0  # Boost cumulatif du joueur

func _on_wave_cleared() -> void:
	coins_earned_this_run += WAVE_CLEAR_BONUS
	SaveManager.add_currency(WAVE_CLEAR_BONUS)

	# BMAD Mode: Boost progressif du joueur à chaque vague
	if current_wave < total_waves:  # Pas de boost avant le boss
		wave_bonus_multiplier += 0.10  # +10% par vague
		_apply_wave_bonus_to_hero()
		_show_floating_text("⚡ POWER UP! +10% ATK/HP ⚡", hero_container.position + Vector2(50, -80), Color(0.3, 1.0, 0.5), 24)

		# Afficher le multiplicateur en HUD
		var power_label := hud_layer.get_node_or_null("HUDRoot/TopBar/HBoxContainer/CenterSection/PowerLabel")
		if power_label:
			var display_boost: int = int((wave_bonus_multiplier - 1.0) * 100)
			power_label.text += " [+%d%% boost]" % display_boost

func _apply_wave_bonus_to_hero() -> void:
	if not hero or not hero.base_stats:
		return

	# Appliquer le boost aux stats du héros
	hero.base_stats.max_hp = int(hero.base_stats.max_hp * (1.0 + 0.10))
	hero.base_stats.attack = int(hero.base_stats.attack * (1.0 + 0.10))

	# Restaurer la HP au max après boost
	hero.current_hp = hero.base_stats.max_hp

func _setup_new_session() -> void:
	# ... code existant ...
	# BMAD Mode: Réinitialiser le boost à chaque nouvelle planète
	wave_bonus_multiplier = 1.0
```

**Localisation**:

- `_on_wave_cleared()` fonction (ligne ~1533)
- Ajouter nouvelle fonction `_apply_wave_bonus_to_hero()`
- Ajouter variable `wave_bonus_multiplier` au haut du script

**Timeline exemple - Mercury**:

- Wave 1: wave_bonus_multiplier = 1.0x (baseline)
- Clear Wave 1: wave_bonus_multiplier = 1.10x (+10% ATK/HP)
- Clear Wave 2: wave_bonus_multiplier = 1.20x (+20% ATK/HP)
- Clear Wave 3: wave_bonus_multiplier = 1.30x (+30% ATK/HP)
- Clear Wave 4: wave_bonus_multiplier = 1.40x (+40% ATK/HP)
- Boss Fight: joueur a +40% en bonus, boss standard

---

## Impact Calculé

### Boss Size Impact

| Boss             | Avant            | Après             | Scale Factor |
| ---------------- | ---------------- | ----------------- | ------------ |
| Mercury Guardian | 180px            | 432px             | +2.4x        |
| Venus Queen      | 180px            | 432px             | +2.4x        |
| Mars Warlord     | 180px            | 432px             | +2.4x        |
| Dr. Mortis       | 252px (180\*1.4) | 540px (432\*1.25) | +2.14x       |

**Visual Impact**:

- Boss now occupies ENTIRE right side (60% of screen)
- Enemies only occupy ~15% of screen width
- Boss is **4x more imposing**
- Final boss is even more threatening

### Difficulty Scaling Impact

| Wave | Joueur Baseline | Boost Appliquer | Ennemi HP | Ennemi DMG | Joueur Effective |
| ---- | --------------- | --------------- | --------- | ---------- | ---------------- |
| 1    | 100 ATK         | 1.0x            | 45 HP     | 8 DMG      | 100 ATK          |
| 2    | 100 ATK         | 1.1x            | 45 HP     | 8 DMG      | 110 ATK          |
| 3    | 100 ATK         | 1.2x            | 54 HP     | 9 DMG      | 120 ATK          |
| 4    | 100 ATK         | 1.3x            | 62 HP     | 10 DMG     | 130 ATK          |
| 5    | 100 ATK         | 1.4x            | 71 HP     | 11 DMG     | 140 ATK          |
| Boss | 100 ATK         | 1.4x            | 400+ HP   | 20 DMG     | 140 ATK          |

**Progression Feeling**:

- Wave 1 feels like introduction
- Each wave feels progressively MORE accomplishable
- Cumulative boost makes late waves feel manageable
- Final boss with +40% boost is challenging but fair

---

## Fichiers à Modifier

**Fichier Principal**: `scenes/game_combat_scene.gd`

**Modification 1**: Boss size (function `_create_boss_visual()`)

- Line ~2184: Changer `base_size` de 25% à 60%
- Line ~2187: Changer `size_mult` pour Dr. Mortis

**Modification 2**: Wave clearing boost (function `_on_wave_cleared()`)

- Line ~1533: Ajouter appel à `_apply_wave_bonus_to_hero()`
- Ajouter nouvelle variable `wave_bonus_multiplier: float = 1.0`
- Ajouter nouvelle fonction `_apply_wave_bonus_to_hero()`
- Mettre à jour affichage HUD du boost

**Modification 3**: Session setup

- Initialiser `wave_bonus_multiplier = 1.0` au début de chaque niveau

---

## Exemples Visuels

### Boss Size Comparison (720px viewport)

**Before**:

```
Enemy formation (15% width): ████ (3-4 cols)

Boss (25% width): ████████

Large gap between
```

**After**:

```
Enemy formation (15% width): ████ (3-4 cols)
Boss (60% width): ██████████████████████

Boss dominates the screen!
```

### Wave Progression Feeling

**Before BMAD**:

```
Wave 1: Easy → Wave 2: Easy → Wave 3: Medium → Wave 4: Hard → Wave 5: BRUTAL
```

**After BMAD Scaling**:

```
Wave 1: Easy → Wave 2: Easy (+10% boost) → Wave 3: Medium (+20%)
→ Wave 4: Medium-Hard (+30%) → Wave 5: Hard-but-fair (+40%)
```

---

## Testing Checklist

Après implémentation, vérifier:

- [ ] Boss visual size = 60% of viewport width
- [ ] Dr. Mortis visual size = 75% effective (60% \* 1.25)
- [ ] Boss doesn't clip with enemy formation
- [ ] Boss HP bar remains visible and centered
- [ ] Wave 1 clear shows boost message
- [ ] wave_bonus_multiplier increases (+10% each wave)
- [ ] Hero ATK increases after each wave
- [ ] Hero HP increases after each wave (and refilled)
- [ ] Boost displays in HUD correctly
- [ ] Boost resets at new planet
- [ ] Boss wave uses +40% boost (from wave 5)
- [ ] Last 3 waves feel more manageable with boost
- [ ] No stat overflow issues

---

## Notes Importants

1. **Boss Visuals**: Max 60% viewport (432px at 720px), Dr. Mortis 25% larger (540px)
2. **Wave Bonus**: Only applied between normal waves, not before boss
3. **HP Restoration**: Hero HP refilled after each boost for fairness
4. **Cumulative**: Boosts stack: Wave 5 = 1.0 × 1.1 × 1.1 × 1.1 × 1.1 = 1.4641 ≈ 1.4x
5. **Reset**: Each new planet starts with 1.0x multiplier

---

## Dépendances

- **Basé sur**: COF-801, COF-802, COF-804
- **Requiert**: BaseEnemy, EntityStats, HUD system
- **Impact**: Difficulty balance across all planets

---

## Définition of Done

✅ Story complétée quand:

1. Boss size = 60% viewport (180px → 432px)
2. Dr. Mortis size = 75% viewport (432px × 1.25 = 540px)
3. Wave bonus system implemented (+10% per wave)
4. Boost applies to both ATK and HP
5. Boost displays in UI
6. Boost resets per planet
7. All testing checklist items pass
8. Last 3 waves feel noticeably more fair
