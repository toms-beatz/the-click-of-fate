# COF-703: Power Recommendation Per Planet

**Epic**: Economy  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scripts/ui/level_select.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** savoir si je suis assez fort pour une planète,  
**Afin de** ne pas perdre mon temps.

---

## Description

Chaque planète affiche un "Power recommandé" et le compare au Power actuel du joueur pour guider ses choix.

---

## Critères d'Acceptation

- [x] Power recommandé par planète affiché
- [x] Comparaison avec Power du joueur
- [x] Indicateur visuel (vert/jaune/rouge)
- [x] Tooltip explicatif

---

## Power par Planète

```gdscript
const PLANET_POWER := {
    0: 100,   # Mercury - Power recommandé 100
    1: 150,   # Venus - Power recommandé 150
    2: 200,   # Mars - Power recommandé 200
    3: 280,   # Earth - Power recommandé 280
}
```

---

## Calcul du Power Joueur

```gdscript
func _calculate_player_power() -> int:
    var power := 50  # Base

    # Bonus des upgrades (+5 power par niveau)
    for upgrade_id in ["max_hp", "attack_power", "dodge_chance", "heal_power"]:
        var level := SaveManager.get_upgrade_level(upgrade_id)
        power += level * 5

    # Bonus des équipements
    for slot in ["weapon", "armor", "helmet"]:
        var equipped := SaveManager.get_equipped(slot)
        if equipped != "" and EQUIPMENT_DATA.has(equipped):
            power += _get_equipment_power_value(equipped)

    return power

func _get_equipment_power_value(item_id: String) -> int:
    var item_data := EQUIPMENT_DATA.get(item_id, {})
    var power := 0
    for stat in item_data.get("bonus", {}):
        power += item_data["bonus"][stat]
    return power
```

---

## Implémentation

```gdscript
func _create_planet_button(planet_index: int) -> Button:
    var btn := Button.new()
    var planet_data := PLANET_DATA[planet_index]
    var required_power: int = PLANET_POWER[planet_index]
    var player_power := _calculate_player_power()

    # Ratio de puissance
    var power_ratio := float(player_power) / float(required_power)

    # Indicateur de difficulté
    var difficulty_indicator: String
    var difficulty_color: Color

    if power_ratio >= 1.2:
        difficulty_indicator = "✅ Easy"
        difficulty_color = Color.GREEN
    elif power_ratio >= 0.9:
        difficulty_indicator = "⚠️ Normal"
        difficulty_color = Color.YELLOW
    elif power_ratio >= 0.7:
        difficulty_indicator = "🔶 Hard"
        difficulty_color = Color.ORANGE
    else:
        difficulty_indicator = "💀 Very Hard"
        difficulty_color = Color.RED

    # Texte du bouton
    btn.text = """
    %s %s
    Power: %d (You: %d)
    %s
    """ % [planet_data.emoji, planet_data.name,
           required_power, player_power, difficulty_indicator]

    return btn
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│  LEVEL SELECT                      │
│                                    │
│  Your Power: ⚡ 175                │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ 🌕 Mercury                   │  │
│  │ Required: 100  (You: 175)    │  │
│  │ ✅ Easy                       │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ 🌒 Venus                     │  │
│  │ Required: 150  (You: 175)    │  │
│  │ ⚠️ Normal                    │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ 🔴 Mars                      │  │
│  │ Required: 200  (You: 175)    │  │
│  │ 🔶 Hard                      │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ 🌍 Earth                     │  │
│  │ Required: 280  (You: 175)    │  │
│  │ 💀 Very Hard                 │  │
│  └──────────────────────────────┘  │
└────────────────────────────────────┘
```

---

## Seuils de Difficulté

| Ratio Power | Indicateur   | Couleur |
| ----------- | ------------ | ------- |
| ≥ 120%      | ✅ Easy      | Vert    |
| 90-119%     | ⚠️ Normal    | Jaune   |
| 70-89%      | 🔶 Hard      | Orange  |
| < 70%       | 💀 Very Hard | Rouge   |

---

## Progression Suggérée

Pour battre confortablement chaque planète:

| Planète | Power Min | Upgrades Suggérés                           |
| ------- | --------- | ------------------------------------------- |
| Mercury | 100       | Base (50) + quelques upgrades               |
| Venus   | 150       | ~10 niveaux d'upgrades total                |
| Mars    | 200       | ~20 niveaux d'upgrades + équipement basique |
| Earth   | 280       | ~30 niveaux d'upgrades + bon équipement     |

---

## Tests de Validation

1. ✅ Power recommandé affiché par planète
2. ✅ Power joueur comparé visuellement
3. ✅ Indicateur vert si suréquipé
4. ✅ Indicateur rouge si sous-équipé
5. ✅ Power recalculé après upgrades

---

## Dépendances

- **Requiert**: Profile Menu power calc (COF-603)
- **Utilisé par**: Level Select
