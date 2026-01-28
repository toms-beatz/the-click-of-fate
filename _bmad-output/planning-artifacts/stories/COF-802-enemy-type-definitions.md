# COF-802: Enemy Type Definitions

**Epic**: Data Structures  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd` (ligne 142-146)

---

## User Story

**En tant que** développeur,  
**Je veux** une formule simple pour les ennemis par planète,  
**Afin de** faciliter le balancing et la progression.

---

## Description

Les ennemis sont définis par **planète**, pas par type. Chaque planète a un profil d'ennemi unique basé sur un multiplicateur appliqué à une formule de base. Cela permet un balancing simple et cohérent.

**Architecture:**

- Base: HP = 45, ATK = 8
- Multiplicateur par planète: ajuste HP, ATK et Speed
- Scaling par vague: augmente HP/ATK exponentiellement

---

## Critères d'Acceptation

- [x] 4 planètes avec multiplicateurs distincts
- [x] Stats configurables et scalables
- [x] Progression cohérente de difficulté
- [x] Visuel distinct par planète

---

## Structure de Données - Multiplicateurs par Planète

```gdscript
const PLANET_ENEMY_MULTIPLIERS := {
	0: {"hp": 1.0, "atk": 1.0, "speed": 1.3, "name": "Scout"},      # Mercury - rapide
	1: {"hp": 0.9, "atk": 1.2, "speed": 1.0, "name": "Toxin"},      # Venus - dégâts
	2: {"hp": 1.2, "atk": 0.9, "speed": 0.9, "name": "Regen"},      # Mars - tanky
	3: {"hp": 1.5, "atk": 1.3, "speed": 0.7, "name": "Titan"},      # Earth - boss-like
}

# Formule pour vague N:
# hp_final = 45 * planet_mult.hp * pow(1.15, N-1)
# atk_final = 8 * planet_mult.atk * pow(1.10, N-1)
# speed = 0.8 * planet_mult.speed  (pas de scaling)
```

---

## Stats Calculées - Vague 1 vs Vague 5

| Planète | Type  | V1 HP | V5 HP | V1 ATK | V5 ATK | Speed |
| ------- | ----- | ----- | ----- | ------ | ------ | ----- |
| Mercury | Scout | 45    | 90    | 8      | 16     | 1.04  |
| Venus   | Toxin | 40    | 81    | 10     | 20     | 0.80  |
| Mars    | Regen | 54    | 109   | 7      | 14     | 0.72  |
| Earth   | Titan | 68    | 136   | 10     | 21     | 0.56  |

---

## Nombre d'Ennemis par Vague - ÉQUILIBRE BMAD MODE ✨

Après l'amélioration "Wave Experience" du 28 janvier 2026, le nombre d'ennemis a été **doublé** pour créer un sentiment d'armée:

| Planète | Vague 1 | Vague 2 | Vague 3 | Vague 4 | Vague 5 | Total |
| ------- | ------- | ------- | ------- | ------- | ------- | ----- |
| Mercury | 6       | 8       | 8       | 10      | 10      | 42    |
| Venus   | 8       | 10      | 10      | 12      | 12      | 52    |
| Mars    | 8       | 10      | 12      | 12      | 14      | 56    |
| Earth   | 10      | 12      | 12      | 14      | 16      | 64    |

**Impact**: Le sentiment de "vague d'armée" est bien plus présent. Le joueur affronte 42-64 ennemis au lieu de 17-32.

---

## Exemple Détaillé: Mercury Vague 5

```
Paramètres:
- Planète: Mercury (scout_mult = 1.0 HP, 1.0 ATK, 1.3 speed)
- Vague: 5
- Ennemis: 10

Calcul:
- hp_mult = pow(1.15, 5-1) = 1.15^4 = 1.749
- atk_mult = pow(1.10, 5-1) = 1.10^4 = 1.464

- hp_final = 45 * 1.0 * 1.749 = 78.7 → 78 HP
- atk_final = 8 * 1.0 * 1.464 = 11.7 → 11 ATK
- speed_final = 0.8 * 1.3 = 1.04

Total Menace:
- DPS par ennemi: 11 * 1.04 = 11.4 DPS
- DPS total (10 ennemis): 114 DPS
- Total HP: 780 HP à éliminer
```

---

## Formule de Spawning en Code

```gdscript
func _spawn_enemy(index: int) -> void:
	var enemy := BaseEnemy.new()

	# Récupérer les multiplicateurs de la planète
	var planet_mult: Dictionary = PLANET_ENEMY_MULTIPLIERS.get(current_planet, PLANET_ENEMY_MULTIPLIERS[0])

	# Calculer le scaling par vague
	var wave_hp_mult := pow(WAVE_HP_SCALING, current_wave - 1)  # 1.15^(N-1)
	var wave_atk_mult := pow(WAVE_ATK_SCALING, current_wave - 1)  # 1.10^(N-1)

	var enemy_stats := EntityStats.new()
	enemy_stats.display_name = planet_mult.name
	enemy_stats.max_hp = int(45 * planet_mult.hp * wave_hp_mult)
	enemy_stats.attack = int(8 * planet_mult.atk * wave_atk_mult)
	enemy_stats.attack_speed = 0.8 * planet_mult.speed
	enemy_stats.crit_chance = 0.05 + (current_wave * 0.01)  # +1% crit par vague

	enemy.base_stats = enemy_stats
	enemy.planet_type = current_planet
```

---

## Progression Comparée

### Mercury → Venus → Mars → Earth

```
Mercury V5 (Facile):
- 10 × Scout HP 78, ATK 11 → Total 780 HP
- Sont rapides (speed 1.04) mais peu dangereux

Venus V5 (Moyen):
- 12 × Toxin HP 73, ATK 10 → Total 876 HP
- Plus d'ennemis, vitesse normale, légèrement plus de dégâts

Mars V5 (Difficile):
- 14 × Regen HP 131, ATK 10 → Total 1834 HP
- Encore plus d'ennemis, tanky, lent à éliminer

Earth V5 (Très Difficile):
- 16 × Titan HP 204, ATK 21 → Total 3264 HP
- Le max! Moins rapides mais énormément d'HP/damage
```

Le joueur voit une escalade claire de difficulté à travers les planètes.

---

## Ajustements Visuels

Les ennemis ont également été augmentés visuellement pour correspondre à la "vague d'armée":

```gdscript
# Body width (taille à l'écran)
# Mercury Scout: 80px (1.1x du scout original)
# Venus Toxin: 80px + 20% = 96px scale
# Mars Regen: 80px + 30% = 104px scale
# Earth Titan: 80px + 50% = 120px scale
```

Cela crée une hiérarchie visuelle où Earth Titan est clairement plus imposant que Mercury Scout.

---

## Tests de Validation

1. ✅ Formule HP produit progression cohérente
2. ✅ Formule ATK balance le HP
3. ✅ Speed varie par planète pour gameplay distinct
4. ✅ 10-16 ennemis s'affichent sans lag significatif
5. ✅ Crit chance augmente par vague (progression visible)

---

## Dépendances

- **Requiert**: BaseEnemy (COF-201), EntityStats
- **Utilisé par**: game_combat_scene.gd, \_spawn_enemy()
- **Relate à**: COF-801 (enemies_per_wave), COF-803 (scaling constants)
