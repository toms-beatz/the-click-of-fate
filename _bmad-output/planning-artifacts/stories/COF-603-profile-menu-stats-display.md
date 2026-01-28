# COF-603: Profile Menu Stats Display

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/ui/profile_menu.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** voir mon profil et mes statistiques,  
**Afin de** suivre ma progression et mes accomplissements.

---

## Description

Le Profile Menu affiche les stats du joueur, le Power calculé, et permet d'acheter des upgrades permanents.

---

## Critères d'Acceptation

- [x] Affichage du Power total calculé
- [x] Stats du héros (HP, ATK, Dodge, Heal)
- [x] Liste des upgrades avec niveaux actuels
- [x] Coût du prochain niveau
- [x] Bouton "Upgrade" pour acheter

---

## Calcul du Power

```gdscript
func _calculate_player_power() -> int:
    var power := 50  # Base

    # Bonus des upgrades
    for upgrade_id in UPGRADES_CONFIG:
        var level := SaveManager.get_upgrade_level(upgrade_id)
        power += level * 5  # +5 power par niveau d'upgrade

    # Bonus des équipements
    for slot in ["weapon", "armor", "helmet"]:
        var equipped := SaveManager.get_equipped(slot)
        if equipped != "":
            power += _get_equipment_power(equipped)

    return power
```

---

## Configuration des Upgrades

```gdscript
const UPGRADES_CONFIG := {
    "max_hp": {
        "name": "PV Max",
        "icon": "❤️",
        "base_value": 100,
        "per_level": 15,
        "base_cost": 50,
        "cost_multiplier": 1.5,
        "max_level": 20,
    },
    "attack_power": {
        "name": "Dégâts",
        "icon": "⚔️",
        "base_value": 10,
        "per_level": 2,
        "base_cost": 75,
        "cost_multiplier": 1.6,
        "max_level": 20,
    },
    "dodge_chance": {
        "name": "Esquive",
        "icon": "💨",
        "base_value": 5,
        "per_level": 2,
        "base_cost": 100,
        "cost_multiplier": 1.7,
        "max_level": 15,
    },
    "heal_power": {
        "name": "Soin",
        "icon": "💚",
        "base_value": 8,
        "per_level": 2,
        "base_cost": 60,
        "cost_multiplier": 1.5,
        "max_level": 20,
    }
}
```

---

## Implémentation

```gdscript
extends Control

func _ready() -> void:
    _display_power()
    _display_stats()
    _create_upgrade_rows()
    SaveManager.currency_changed.connect(_refresh_ui)

func _display_power() -> void:
    var power := _calculate_player_power()
    $PowerLabel.text = "⚡ POWER: %d" % power

func _display_stats() -> void:
    var hp := 100 + SaveManager.get_upgrade_level("max_hp") * 15
    var atk := 10 + SaveManager.get_upgrade_level("attack_power") * 2
    var dodge := 5 + SaveManager.get_upgrade_level("dodge_chance") * 2
    var heal := 8 + SaveManager.get_upgrade_level("heal_power") * 2

    $StatsContainer/HPLabel.text = "❤️ HP: %d" % hp
    $StatsContainer/ATKLabel.text = "⚔️ ATK: %d" % atk
    $StatsContainer/DodgeLabel.text = "💨 Dodge: %d%%" % dodge
    $StatsContainer/HealLabel.text = "💚 Heal: %d" % heal

func _create_upgrade_rows() -> void:
    for upgrade_id in UPGRADES_CONFIG:
        var row := _create_upgrade_row(upgrade_id)
        $UpgradesContainer.add_child(row)

func _on_upgrade_pressed(upgrade_id: String) -> void:
    var current_level := SaveManager.get_upgrade_level(upgrade_id)
    var cost := _get_upgrade_cost(upgrade_id, current_level)

    if SaveManager.spend_currency(cost):
        SaveManager.increase_upgrade(upgrade_id)
        _refresh_ui()
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│  ← Back          PROFILE           │
│                                    │
│        ⚡ POWER: 175                │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ ❤️ HP: 145    ⚔️ ATK: 16     │  │
│  │ 💨 Dodge: 9%  💚 Heal: 12    │  │
│  └──────────────────────────────┘  │
│                                    │
│  UPGRADES                          │
│  ┌──────────────────────────────┐  │
│  │ ❤️ PV Max      Lv.3/20       │  │
│  │ +15 HP/level   Cost: 169 SC  │  │
│  │               [UPGRADE]      │  │
│  └──────────────────────────────┘  │
│  ┌──────────────────────────────┐  │
│  │ ⚔️ Dégâts      Lv.3/20       │  │
│  │ +2 ATK/level   Cost: 245 SC  │  │
│  │               [UPGRADE]      │  │
│  └──────────────────────────────┘  │
│  ...                               │
│                                    │
│  💰 1234 SC                        │
└────────────────────────────────────┘
```

---

## Tests de Validation

1. ✅ Power calculé inclut upgrades + équipement
2. ✅ Stats affichent valeurs avec upgrades appliqués
3. ✅ Cliquer Upgrade → dépense SC, augmente niveau
4. ✅ Pas assez de SC → bouton disabled
5. ✅ Max level atteint → "MAX" affiché

---

## Dépendances

- **Requiert**: SaveManager upgrades (COF-404), Currency (COF-402)
- **Utilisé par**: Main Menu navigation
