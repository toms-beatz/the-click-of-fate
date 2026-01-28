# COF-404: Upgrades Persistence System

**Epic**: Save & Persistence  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/autoload/save_manager.gd` (lignes 300-315)

---

## User Story

**En tant que** joueur,  
**Je veux** que mes upgrades soient sauvegardés,  
**Afin de** bénéficier de mes investissements en SC.

---

## Description

Les upgrades sont des améliorations permanentes achetées avec des SC. Chaque upgrade a un niveau qui augmente les stats du héros.

---

## Critères d'Acceptation

- [x] Structure d'upgrades :
  - `heal_power` - Puissance de soin
  - `max_hp` - PV maximum
  - `dodge_chance` - Chance d'esquive
  - `attack_power` - Dégâts
- [x] Méthodes :
  - `get_upgrade_level(upgrade_id)` → int
  - `increase_upgrade(upgrade_id)` → void
- [x] Sauvegarde automatique après modification

---

## Implémentation

```gdscript
# Structure dans data
"upgrades": {
    "heal_power": 0,
    "max_hp": 0,
    "dodge_chance": 0,
    "attack_power": 0
}

func get_upgrade_level(upgrade_id: String) -> int:
    return data["upgrades"].get(upgrade_id, 0)

func increase_upgrade(upgrade_id: String) -> void:
    if data["upgrades"].has(upgrade_id):
        data["upgrades"][upgrade_id] += 1
        save_game()
```

---

## Configuration des Upgrades (Profile Menu)

```gdscript
const UPGRADES_CONFIG := {
    "max_hp": {
        "name": "PV Max",
        "icon": "❤️",
        "base_value": 100,
        "per_level": 15,       # +15 HP par niveau
        "base_cost": 50,
        "cost_multiplier": 1.5,
        "max_level": 20,
    },
    "attack_power": {
        "name": "Dégâts",
        "icon": "⚔️",
        "base_value": 10,
        "per_level": 2,        # +2 ATK par niveau
        "base_cost": 75,
        "cost_multiplier": 1.6,
        "max_level": 20,
    },
    "dodge_chance": {
        "name": "Esquive",
        "icon": "💨",
        "base_value": 5,
        "per_level": 2,        # +2% par niveau
        "base_cost": 100,
        "cost_multiplier": 1.7,
        "max_level": 15,
    },
    "heal_power": {
        "name": "Soin",
        "icon": "💚",
        "base_value": 8,
        "per_level": 2,        # +2 heal par niveau
        "base_cost": 60,
        "cost_multiplier": 1.5,
        "max_level": 20,
    }
}
```

---

## Formule de Coût

```gdscript
func _get_upgrade_cost(upgrade_id: String, current_level: int) -> int:
    var config := UPGRADES_CONFIG[upgrade_id]
    return int(config["base_cost"] * pow(config["cost_multiplier"], current_level))

# Exemple pour max_hp:
# Niveau 0→1: 50 SC
# Niveau 1→2: 50 × 1.5 = 75 SC
# Niveau 2→3: 75 × 1.5 = 112 SC
# Niveau 5→6: 50 × 1.5^5 = 379 SC
```

---

## Application des Upgrades

```gdscript
# Dans le calcul des stats du héros
var hp_upgrade := SaveManager.get_upgrade_level("max_hp")
var final_hp := base_hp + (hp_upgrade * 15)

var atk_upgrade := SaveManager.get_upgrade_level("attack_power")
var final_atk := base_atk + (atk_upgrade * 2)
```

---

## Tests de Validation

1. ✅ `get_upgrade_level("max_hp")` → 0 au début
2. ✅ `increase_upgrade("max_hp")` → niveau devient 1
3. ✅ Sauvegarde automatique après upgrade
4. ✅ Niveau max respecté
5. ✅ Coût augmente exponentiellement

---

## Dépendances

- **Requiert**: SaveManager structure (COF-401), Currency (COF-402)
- **Utilisé par**: Profile Menu, Combat (stats héros)
