# COF-109: Hero Power Scaling by Progression

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd` (lignes 93-102)

---

## User Story

**En tant que** joueur,  
**Je veux** que mon héros devienne plus fort en progressant,  
**Afin de** pouvoir affronter des ennemis de plus en plus difficiles.

---

## Description

Le système de scaling de puissance récompense la progression linéaire. Plus le joueur a complété de planètes, plus son héros est puissant au début de chaque combat.

---

## Critères d'Acceptation

- [x] Puissance calculée selon `highest_planet_completed`
- [x] Table de progression :
      | Planète Complétée | Puissance | HP Mult | ATK Mult |
      |-------------------|-----------|---------|----------|
      | Aucune (-1) | 100 | 1.0x | 1.0x |
      | Mercury (0) | 150 | 1.25x | 1.2x |
      | Venus (1) | 200 | 1.5x | 1.4x |
      | Mars (2) | 280 | 1.8x | 1.7x |
      | Earth (3) | 400 | 2.2x | 2.0x |
- [x] Puissance recommandée par planète :
      | Planète | Recommandé |
      |---------|------------|
      | Mercury | 100 |
      | Venus | 140 |
      | Mars | 190 |
      | Earth | 270 |
- [x] Comparaison visuelle (couleur) puissance joueur vs recommandée

---

## Implémentation

```gdscript
const HERO_POWER_PER_PLANET := {
    -1: {"hp_mult": 1.0, "atk_mult": 1.0, "power": 100},
    0:  {"hp_mult": 1.25, "atk_mult": 1.2, "power": 150},
    1:  {"hp_mult": 1.5, "atk_mult": 1.4, "power": 200},
    2:  {"hp_mult": 1.8, "atk_mult": 1.7, "power": 280},
    3:  {"hp_mult": 2.2, "atk_mult": 2.0, "power": 400},
}

func _setup_hero() -> void:
    var highest_completed: int = SaveManager.get_highest_planet_completed()
    var power_data: Dictionary = HERO_POWER_PER_PLANET.get(highest_completed, HERO_POWER_PER_PLANET[-1])

    var hero_stats := EntityStats.new()
    hero_stats.max_hp = int(HERO_BASE_HP * power_data.hp_mult)
    hero_stats.attack = int(HERO_BASE_ATTACK * power_data.atk_mult)
```

---

## Indicateur Visuel de Puissance

```gdscript
var power_color: Color
if player_power >= recommended_power:
    power_color = Color(0.3, 1.0, 0.5)  # Vert - bon niveau
elif player_power >= recommended_power * 0.8:
    power_color = Color(1.0, 0.9, 0.3)  # Jaune - faisable
else:
    power_color = Color(1.0, 0.4, 0.3)  # Rouge - difficile
```

---

## Calcul des Stats Finales

### Exemple: Joueur ayant terminé Venus (planète 1)

```
Base HP: 150
HP Mult: 1.5
Final HP: 150 × 1.5 = 225 HP

Base ATK: 12
ATK Mult: 1.4
Final ATK: 12 × 1.4 = 16.8 → 16 ATK
```

---

## Tests de Validation

1. ✅ Nouvelle partie → hero HP = 150, ATK = 12
2. ✅ Après Mercury → hero HP = 187, ATK = 14
3. ✅ Après Venus → hero HP = 225, ATK = 16
4. ✅ Indicateur vert si power >= recommended
5. ✅ Indicateur rouge si power < 80% recommended

---

## Dépendances

- **Requiert**: `SaveManager` (COF-401), `EntityStats` (COF-102)
- **Utilisé par**: `GameCombatScene`, `LevelSelect`
