# COF-405: Equipment Persistence System

**Epic**: Save & Persistence  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scripts/autoload/save_manager.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** que mon équipement soit sauvegardé,  
**Afin de** garder mes items achetés entre les sessions.

---

## Description

Le système d'équipement permet d'équiper des armes, armures et casques qui donnent des bonus de stats. Les équipements possédés et équipés sont persistés.

---

## Critères d'Acceptation

- [x] 3 slots d'équipement : `weapon`, `armor`, `helmet`
- [x] Liste des équipements possédés : `owned_equipment`
- [x] Méthodes :
  - `get_equipped(slot)` → String (ID)
  - `set_equipped(slot, item_id)` → void
  - `owns_equipment(item_id)` → bool
  - `add_equipment(item_id)` → void

---

## Implémentation

```gdscript
# Structure dans data
"equipment": {
    "weapon": "",
    "armor": "",
    "helmet": ""
},
"owned_equipment": []

func get_equipped(slot: String) -> String:
    return data["equipment"].get(slot, "")

func set_equipped(slot: String, item_id: String) -> void:
    if slot in ["weapon", "armor", "helmet"]:
        data["equipment"][slot] = item_id
        save_game()

func owns_equipment(item_id: String) -> bool:
    return item_id in data["owned_equipment"]

func add_equipment(item_id: String) -> void:
    if item_id not in data["owned_equipment"]:
        data["owned_equipment"].append(item_id)
        save_game()
```

---

## Équipements Disponibles

### Armes (Bonus Dégâts)

| ID           | Nom           | Coût    | Bonus      |
| ------------ | ------------- | ------- | ---------- |
| sword_basic  | Épée Basique  | 200 SC  | +5 Dégâts  |
| sword_flame  | Lame de Feu   | 800 SC  | +12 Dégâts |
| sword_cosmic | Épée Cosmique | 2500 SC | +25 Dégâts |

### Armures (Bonus Esquive)

| ID           | Nom             | Coût    | Bonus        |
| ------------ | --------------- | ------- | ------------ |
| armor_light  | Armure Légère   | 250 SC  | +5% Esquive  |
| armor_shadow | Armure d'Ombre  | 900 SC  | +10% Esquive |
| armor_cosmic | Armure Cosmique | 3000 SC | +18% Esquive |

### Casques (Bonus Soin)

| ID            | Nom             | Coût    | Bonus    |
| ------------- | --------------- | ------- | -------- |
| helmet_basic  | Casque Basique  | 180 SC  | +3 Soin  |
| helmet_nature | Casque Nature   | 700 SC  | +8 Soin  |
| helmet_cosmic | Casque Cosmique | 2200 SC | +15 Soin |

---

## Application des Bonus

```gdscript
# Dans Profile Menu
const EQUIPMENT_DATA := {
    "sword_basic": {"type": "weapon", "bonus": {"attack_power": 5}},
    "sword_flame": {"type": "weapon", "bonus": {"attack_power": 12}},
    # ...
}

func _calculate_player_power() -> int:
    var power := 50  # Base

    # Bonus des équipements
    for slot in ["weapon", "armor", "helmet"]:
        var equipped := SaveManager.get_equipped(slot)
        if equipped != "" and EQUIPMENT_DATA.has(equipped):
            var equip_data := EQUIPMENT_DATA[equipped]
            for stat in equip_data["bonus"]:
                power += equip_data["bonus"][stat]

    return power
```

---

## Flow d'Achat et d'Équipement

```
1. Joueur dans le Shop
2. Clique "Acheter sword_flame" (800 SC)
3. spend_currency(800) → true
4. add_equipment("sword_flame")
5. owned_equipment = ["sword_flame"]

6. Joueur dans Profile
7. Clique "Équiper sword_flame"
8. set_equipped("weapon", "sword_flame")
9. equipment.weapon = "sword_flame"
```

---

## Tests de Validation

1. ✅ `get_equipped("weapon")` → "" au début
2. ✅ Acheter item → apparaît dans owned_equipment
3. ✅ Équiper item → slot mis à jour
4. ✅ Relancer le jeu → équipement conservé
5. ✅ Bonus appliqués au calcul de puissance

---

## Dépendances

- **Requiert**: SaveManager (COF-401), Currency (COF-402)
- **Utilisé par**: Shop Menu, Profile Menu, Combat
