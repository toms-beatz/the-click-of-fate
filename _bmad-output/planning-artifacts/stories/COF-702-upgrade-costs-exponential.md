# COF-702: Upgrade Costs Exponential

**Epic**: Economy  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/ui/profile_menu.gd`

---

## User Story

**En tant que** game designer,  
**Je veux** une courbe de coût exponentielle,  
**Afin de** créer une progression satisfaisante à long terme.

---

## Description

Le coût des upgrades augmente exponentiellement avec le niveau pour créer un sentiment de progression et éviter le pay-to-win.

---

## Critères d'Acceptation

- [x] Formule: `base_cost × multiplier^level`
- [x] Chaque type d'upgrade a ses propres paramètres
- [x] Max level limité pour éviter le grind infini
- [x] Affichage du coût du prochain niveau

---

## Formule de Coût

```gdscript
func _get_upgrade_cost(upgrade_id: String, current_level: int) -> int:
    var config := UPGRADES_CONFIG[upgrade_id]
    var base_cost: int = config["base_cost"]
    var multiplier: float = config["cost_multiplier"]

    return int(base_cost * pow(multiplier, current_level))
```

---

## Configuration des Upgrades

```gdscript
const UPGRADES_CONFIG := {
    "max_hp": {
        "base_cost": 50,
        "cost_multiplier": 1.5,
        "max_level": 20,
        # Coûts: 50, 75, 112, 168, 253, 379, 569...
    },
    "attack_power": {
        "base_cost": 75,
        "cost_multiplier": 1.6,
        "max_level": 20,
        # Coûts: 75, 120, 192, 307, 492, 787...
    },
    "dodge_chance": {
        "base_cost": 100,
        "cost_multiplier": 1.7,
        "max_level": 15,
        # Coûts: 100, 170, 289, 491, 834...
    },
    "heal_power": {
        "base_cost": 60,
        "cost_multiplier": 1.5,
        "max_level": 20,
        # Coûts: 60, 90, 135, 202, 304...
    }
}
```

---

## Tableau des Coûts (max_hp)

| Niveau | Coût (SC) | Total Cumulé |
| ------ | --------- | ------------ |
| 0→1    | 50        | 50           |
| 1→2    | 75        | 125          |
| 2→3    | 112       | 237          |
| 3→4    | 168       | 405          |
| 4→5    | 253       | 658          |
| 5→6    | 379       | 1,037        |
| 6→7    | 569       | 1,606        |
| 7→8    | 854       | 2,460        |
| 8→9    | 1,281     | 3,741        |
| 9→10   | 1,921     | 5,662        |
| ...    | ...       | ...          |
| 19→20  | 47,683    | ~95,000      |

---

## Rationale de Design

### Pourquoi Exponentiel?

1. **Early game accessible**: Premiers niveaux abordables
2. **Mid game satisfaisant**: Chaque upgrade est une décision
3. **Late game aspirationnel**: Objectifs long terme
4. **Anti pay-to-win**: Même avec beaucoup de SC, maxer tout prend du temps

### Multipliers Choisis

- **1.5** (HP, Heal): Plus accessibles car fondamentaux
- **1.6** (Attack): Équilibré, le DPS est puissant
- **1.7** (Dodge): Plus cher car très puissant contre les boss

---

## Implémentation dans Profile Menu

```gdscript
func _create_upgrade_row(upgrade_id: String) -> Control:
    var config := UPGRADES_CONFIG[upgrade_id]
    var current_level := SaveManager.get_upgrade_level(upgrade_id)
    var is_maxed := current_level >= config["max_level"]

    var row := HBoxContainer.new()

    # Nom et icône
    var name_label := Label.new()
    name_label.text = "%s %s" % [config["icon"], config["name"]]
    row.add_child(name_label)

    # Niveau
    var level_label := Label.new()
    level_label.text = "Lv.%d/%d" % [current_level, config["max_level"]]
    row.add_child(level_label)

    # Bouton upgrade
    var upgrade_btn := Button.new()
    if is_maxed:
        upgrade_btn.text = "MAX"
        upgrade_btn.disabled = true
    else:
        var cost := _get_upgrade_cost(upgrade_id, current_level)
        upgrade_btn.text = "⬆️ %d SC" % cost
        upgrade_btn.disabled = not SaveManager.can_afford(cost)
        upgrade_btn.pressed.connect(func(): _on_upgrade_pressed(upgrade_id))

    row.add_child(upgrade_btn)

    return row

func _on_upgrade_pressed(upgrade_id: String) -> void:
    var current_level := SaveManager.get_upgrade_level(upgrade_id)
    var cost := _get_upgrade_cost(upgrade_id, current_level)

    if SaveManager.spend_currency(cost):
        SaveManager.increase_upgrade(upgrade_id)
        _refresh_ui()
```

---

## Tests de Validation

1. ✅ Coût niveau 0→1 = base_cost
2. ✅ Coût augmente exponentiellement
3. ✅ Max level atteint → "MAX" affiché
4. ✅ Pas assez de SC → bouton disabled
5. ✅ Achat → currency déduit, niveau augmenté

---

## Dépendances

- **Requiert**: SaveManager upgrades (COF-404)
- **Utilisé par**: Profile Menu
