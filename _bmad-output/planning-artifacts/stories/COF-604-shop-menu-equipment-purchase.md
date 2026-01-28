# COF-604: Shop Menu Equipment Purchase

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/ui/shop_menu.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** acheter de l'équipement dans le shop,  
**Afin de** améliorer mes stats de combat.

---

## Description

Le Shop Menu affiche les équipements disponibles à l'achat avec leur prix et leurs bonus. Les items déjà possédés sont marqués comme tels.

---

## Critères d'Acceptation

- [x] 3 catégories : Weapons, Armors, Helmets
- [x] Affichage du prix et des bonus
- [x] Items possédés marqués "OWNED"
- [x] Bouton "BUY" fonctionnel
- [x] Affichage de la monnaie actuelle

---

## Données d'Équipement

```gdscript
const EQUIPMENT_DATA := {
    # Weapons (+ATK)
    "sword_basic": {"name": "Épée Basique", "type": "weapon", "cost": 200, "bonus": {"attack_power": 5}},
    "sword_flame": {"name": "Lame de Feu", "type": "weapon", "cost": 800, "bonus": {"attack_power": 12}},
    "sword_cosmic": {"name": "Épée Cosmique", "type": "weapon", "cost": 2500, "bonus": {"attack_power": 25}},

    # Armors (+Dodge)
    "armor_light": {"name": "Armure Légère", "type": "armor", "cost": 250, "bonus": {"dodge_chance": 5}},
    "armor_shadow": {"name": "Armure d'Ombre", "type": "armor", "cost": 900, "bonus": {"dodge_chance": 10}},
    "armor_cosmic": {"name": "Armure Cosmique", "type": "armor", "cost": 3000, "bonus": {"dodge_chance": 18}},

    # Helmets (+Heal)
    "helmet_basic": {"name": "Casque Basique", "type": "helmet", "cost": 180, "bonus": {"heal_power": 3}},
    "helmet_nature": {"name": "Casque Nature", "type": "helmet", "cost": 700, "bonus": {"heal_power": 8}},
    "helmet_cosmic": {"name": "Casque Cosmique", "type": "helmet", "cost": 2200, "bonus": {"heal_power": 15}},
}
```

---

## Implémentation

```gdscript
extends Control

func _ready() -> void:
    _create_shop_tabs()
    _display_weapons()
    SaveManager.currency_changed.connect(_refresh_currency)

func _create_shop_tabs() -> void:
    var tabs := $TabContainer
    tabs.add_tab("⚔️ Weapons")
    tabs.add_tab("🛡️ Armors")
    tabs.add_tab("🪖 Helmets")

func _display_items_of_type(type: String) -> void:
    var container := $ItemsContainer
    _clear_container(container)

    for item_id in EQUIPMENT_DATA:
        var item_data: Dictionary = EQUIPMENT_DATA[item_id]
        if item_data.type == type:
            var item_card := _create_item_card(item_id, item_data)
            container.add_child(item_card)

func _create_item_card(item_id: String, data: Dictionary) -> Control:
    var card := PanelContainer.new()
    var vbox := VBoxContainer.new()

    var name_label := Label.new()
    name_label.text = data.name

    var bonus_label := Label.new()
    bonus_label.text = _format_bonus(data.bonus)

    var is_owned := SaveManager.owns_equipment(item_id)

    var action_btn := Button.new()
    if is_owned:
        action_btn.text = "✅ OWNED"
        action_btn.disabled = true
    else:
        action_btn.text = "💰 %d SC" % data.cost
        action_btn.disabled = not SaveManager.can_afford(data.cost)
        action_btn.pressed.connect(func(): _on_buy_pressed(item_id))

    vbox.add_child(name_label)
    vbox.add_child(bonus_label)
    vbox.add_child(action_btn)
    card.add_child(vbox)

    return card

func _on_buy_pressed(item_id: String) -> void:
    var cost: int = EQUIPMENT_DATA[item_id].cost
    if SaveManager.spend_currency(cost):
        SaveManager.add_equipment(item_id)
        # Auto-equip if slot empty
        var type: String = EQUIPMENT_DATA[item_id].type
        if SaveManager.get_equipped(type) == "":
            SaveManager.set_equipped(type, item_id)
        _refresh_ui()
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│  ← Back          SHOP    💰 1234   │
│                                    │
│  ┌──────┬──────┬──────┐            │
│  │⚔️ Wpn│🛡️ Arm│🪖 Hlm│            │
│  └──────┴──────┴──────┘            │
│                                    │
│  ┌────────────────────────────────┐│
│  │  ⚔️ Épée Basique              ││
│  │  +5 Dégâts                    ││
│  │  [ 💰 200 SC ]                ││
│  └────────────────────────────────┘│
│                                    │
│  ┌────────────────────────────────┐│
│  │  🔥 Lame de Feu               ││
│  │  +12 Dégâts                   ││
│  │  [ ✅ OWNED ]                 ││
│  └────────────────────────────────┘│
│                                    │
│  ┌────────────────────────────────┐│
│  │  ✨ Épée Cosmique             ││
│  │  +25 Dégâts                   ││
│  │  [ 💰 2500 SC ]               ││
│  └────────────────────────────────┘│
└────────────────────────────────────┘
```

---

## Auto-Équipement

```gdscript
# Si le joueur achète un item et que le slot est vide,
# on l'équipe automatiquement
func _on_buy_pressed(item_id: String) -> void:
    # ... achat ...
    var type: String = EQUIPMENT_DATA[item_id].type
    if SaveManager.get_equipped(type) == "":
        SaveManager.set_equipped(type, item_id)
```

---

## Tests de Validation

1. ✅ Onglets affichent les bonnes catégories
2. ✅ Item acheté → "OWNED" affiché
3. ✅ Pas assez de SC → bouton grisé
4. ✅ Achat réussi → SC déduit
5. ✅ Auto-équipement si slot vide

---

## Dépendances

- **Requiert**: SaveManager equipment (COF-405), Currency (COF-402)
- **Utilisé par**: Main Menu navigation
