# COF-908: Apply Upgrades & Equipment Stats to Combat

**Epic**: Core Combat  
**Status**: ✅ DONE  
**Priority**: CRITICAL  
**Sprint**: Current

---

## User Story

**En tant que** joueur,  
**Je veux** que mes upgrades achetés et mon équipement aient un effet réel,  
**Afin de** sentir ma progression et que mes investissements en SC comptent.

---

## Problème Identifié

### 🔴 BUG CRITIQUE : Les stats achetées n'ont AUCUN impact sur le gameplay !

**Analyse du code actuel :**

1. **`game_combat_scene.gd` (lignes 430-436)** - Stats du héros :
   ```gdscript
   hero_stats.max_hp = int(HERO_BASE_HP * hp_mult)      # ❌ Ignore upgrade max_hp
   hero_stats.attack = int(HERO_BASE_ATTACK * atk_mult) # ❌ Ignore upgrade attack_power
   hero_stats.dodge_chance = HERO_DODGE_CHANCE          # ❌ Ignore upgrade dodge_chance
   ```

2. **`combat_manager.gd` (lignes 33-35)** - Actions du joueur :
   ```gdscript
   const BASE_HEAL_PERCENT := 0.13   # ❌ Hardcodé, ignore heal_power upgrade
   const BASE_DODGE_BONUS := 0.20    # ❌ Hardcodé, ignore dodge_chance upgrade
   const BASE_ATTACK_DAMAGE := 10    # ❌ Hardcodé, ignore attack_power upgrade
   ```

3. **`profile_menu.gd`** - Upgrades définis mais jamais utilisés :
   - `max_hp`: +15 HP/niveau → **NON APPLIQUÉ**
   - `attack_power`: +2 ATK/niveau → **NON APPLIQUÉ**
   - `dodge_chance`: +2% esquive/niveau → **NON APPLIQUÉ**
   - `heal_power`: +2 soin/niveau → **NON APPLIQUÉ**

4. **Equipment** - Bonus définis mais jamais utilisés :
   - Armes: +5 à +25 ATK → **NON APPLIQUÉ**
   - Armures: +5% à +18% Dodge → **NON APPLIQUÉ**
   - Casques: +3 à +15 Heal → **NON APPLIQUÉ**

---

## Critères d'Acceptation

### Stats du Héros
- [ ] `max_hp` doit inclure : `HERO_BASE_HP * hp_mult + (upgrade_level * 15) + equipment_bonus`
- [ ] `attack` doit inclure : `HERO_BASE_ATTACK * atk_mult + (upgrade_level * 2) + equipment_bonus`
- [ ] `dodge_chance` doit inclure : `HERO_DODGE_CHANCE + (upgrade_level * 0.02) + equipment_bonus`

### Actions de Combat
- [ ] Heal doit être augmenté par `heal_power` upgrade et équipement casque
- [ ] Dodge bonus doit être augmenté par `dodge_chance` upgrade et équipement armure
- [ ] Attack damage doit être augmenté par `attack_power` upgrade et équipement arme

### Affichage
- [ ] Les stats affichées dans le profil doivent correspondre aux stats réelles en combat

---

## Implémentation

### 1. Modifier `game_combat_scene.gd` - Fonction `_setup_hero()`

```gdscript
func _setup_hero() -> void:
	hero = AlienHero.new()
	hero.name = "AlienHero"
	
	# Calculer la puissance du héros basée sur la progression
	var highest_completed: int = -1
	if SaveManager:
		highest_completed = SaveManager.get_highest_planet_completed()
	
	var power_data: Dictionary = HERO_POWER_PER_PLANET.get(highest_completed, HERO_POWER_PER_PLANET[-1])
	var hp_mult: float = power_data.hp_mult
	var atk_mult: float = power_data.atk_mult
	
	# ===== NOUVEAU: Récupérer les bonus des upgrades =====
	var hp_upgrade_bonus := 0
	var atk_upgrade_bonus := 0
	var dodge_upgrade_bonus := 0.0
	
	if SaveManager:
		hp_upgrade_bonus = SaveManager.get_upgrade_level("max_hp") * 15
		atk_upgrade_bonus = SaveManager.get_upgrade_level("attack_power") * 2
		dodge_upgrade_bonus = SaveManager.get_upgrade_level("dodge_chance") * 0.02
	
	# ===== NOUVEAU: Récupérer les bonus des équipements =====
	var equip_hp_bonus := 0
	var equip_atk_bonus := 0
	var equip_dodge_bonus := 0.0
	var equip_heal_bonus := 0
	
	if SaveManager:
		equip_atk_bonus = _get_equipment_bonus("attack_power")
		equip_dodge_bonus = _get_equipment_bonus("dodge_chance") * 0.01  # % en décimal
		equip_heal_bonus = _get_equipment_bonus("heal_power")
	
	# Appliquer toutes les stats
	var hero_stats := EntityStats.new()
	hero_stats.display_name = "Alien Hero"
	hero_stats.max_hp = int(HERO_BASE_HP * hp_mult) + hp_upgrade_bonus + equip_hp_bonus
	hero_stats.attack = int(HERO_BASE_ATTACK * atk_mult) + atk_upgrade_bonus + equip_atk_bonus
	hero_stats.attack_speed = HERO_ATTACK_SPEED
	hero_stats.crit_chance = HERO_CRIT_CHANCE
	hero_stats.dodge_chance = HERO_DODGE_CHANCE + dodge_upgrade_bonus + equip_dodge_bonus
	hero.base_stats = hero_stats
	
	# Stocker le heal bonus pour le combat manager
	_heal_power_bonus = SaveManager.get_upgrade_level("heal_power") * 2 + equip_heal_bonus if SaveManager else 0
	
	print("[GameCombat] Hero stats with upgrades - HP: %d, ATK: %d, Dodge: %.1f%%" % [
		hero_stats.max_hp, hero_stats.attack, hero_stats.dodge_chance * 100
	])


## Calcule le bonus d'équipement pour une stat donnée
func _get_equipment_bonus(stat: String) -> int:
	if not SaveManager:
		return 0
	
	var total_bonus := 0
	var equipment_data := {
		"sword_basic": {"attack_power": 5},
		"sword_flame": {"attack_power": 12},
		"sword_cosmic": {"attack_power": 25},
		"armor_light": {"dodge_chance": 5},
		"armor_shadow": {"dodge_chance": 10},
		"armor_cosmic": {"dodge_chance": 18},
		"helmet_basic": {"heal_power": 3},
		"helmet_nature": {"heal_power": 8},
		"helmet_cosmic": {"heal_power": 15},
	}
	
	for slot in ["weapon", "armor", "helmet"]:
		var equipped := SaveManager.get_equipped(slot)
		if equipped != "" and equipment_data.has(equipped):
			total_bonus += equipment_data[equipped].get(stat, 0)
	
	return total_bonus
```

### 2. Modifier `combat_manager.gd` - Utiliser les bonus dynamiques

```gdscript
## Bonus de heal calculé avec upgrades/équipement (set par game_combat_scene)
var heal_power_bonus: int = 0

## Action HEAL: Soigne le héros avec bonus
func _do_heal() -> void:
	if not hero or not hero.is_alive:
		return
	
	hero_pose_changed.emit(&"special", 0.5)
	
	# Calcul du heal avec les bonus
	var base_heal := int(hero.base_stats.max_hp * BASE_HEAL_PERCENT)
	var total_heal := base_heal + heal_power_bonus
	
	var healed := hero.heal(total_heal)
	if healed > 0:
		hero_healed.emit(healed)
```

### 3. Variables à ajouter dans `game_combat_scene.gd`

```gdscript
## Bonus de heal des upgrades/équipements
var _heal_power_bonus: int = 0
```

Et passer ce bonus au combat_manager après setup :
```gdscript
combat_manager.heal_power_bonus = _heal_power_bonus
```

---

## Fichiers à Modifier

| Fichier | Modifications |
|---------|---------------|
| `scenes/game_combat_scene.gd` | `_setup_hero()`, ajouter `_get_equipment_bonus()`, variable `_heal_power_bonus` |
| `scripts/core/combat/combat_manager.gd` | Modifier `_do_heal()` pour utiliser `heal_power_bonus` |

---

## Tests de Validation

1. [ ] Sans upgrades: HP = 150, ATK = 12, Dodge = 8%
2. [ ] Avec max_hp niveau 5: HP = 150 + 75 = 225
3. [ ] Avec attack_power niveau 5: ATK = 12 + 10 = 22
4. [ ] Avec dodge_chance niveau 5: Dodge = 8% + 10% = 18%
5. [ ] Avec heal_power niveau 5: Heal augmenté de +10 HP
6. [ ] Avec épée cosmique équipée: ATK +25
7. [ ] Avec armure cosmique équipée: Dodge +18%
8. [ ] Avec casque cosmique équipé: Heal +15

---

## Impact sur l'Expérience Joueur

**Avant (BUG):**
- Le joueur achète des upgrades → Aucun effet visible
- Frustration garantie, impression d'arnaque

**Après (CORRIGÉ):**
- Chaque upgrade a un effet mesurable
- Le joueur voit sa puissance augmenter
- Motivation à farmer des SC

---

## Priorité

🔴 **CRITIQUE** - Ce bug rend le système de progression complètement inutile. Les joueurs qui achètent des upgrades pensent progresser mais en réalité leurs stats sont identiques.

---

## Dépendances

- **Requiert**: SaveManager (COF-401), Upgrades persistence (COF-404), Equipment (COF-405)
- **Utilisé par**: Combat gameplay, Progression feeling

---

## Estimation

**Effort**: 2-3 heures
**Complexité**: Moyenne
**Risque**: Faible (modifications localisées)
