# COF-602: Level Select Planet Buttons

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/ui/level_select.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** sélectionner une planète à jouer,  
**Afin de** choisir mon niveau de difficulté.

---

## Description

L'écran Level Select affiche les 4 planètes avec leur état (débloquée/verrouillée) et permet de lancer le combat.

---

## Critères d'Acceptation

- [x] 4 planètes affichées verticalement :
  - 🌕 Mercury - Power 100
  - 🌒 Venus - Power 150
  - 🔴 Mars - Power 200
  - 🌍 Earth - Power 280
- [x] Planètes verrouillées grisées avec 🔒
- [x] Planète suivante débloquée après victoire
- [x] Affichage du Power recommandé
- [x] Bouton "PLAY" lance le combat

---

## Données des Planètes

```gdscript
const PLANET_DATA := {
    0: {"name": "Mercury", "emoji": "🌕", "power": 100, "waves": 5},
    1: {"name": "Venus", "emoji": "🌒", "power": 150, "waves": 5},
    2: {"name": "Mars", "emoji": "🔴", "power": 200, "waves": 5},
    3: {"name": "Earth", "emoji": "🌍", "power": 280, "waves": 5},
}
```

---

## Implémentation

```gdscript
extends Control

var selected_planet: int = -1

func _ready() -> void:
    _create_planet_list()
    _update_lock_states()

func _create_planet_list() -> void:
    var container := $PlanetContainer

    for planet_index in range(4):
        var planet_data: Dictionary = PLANET_DATA[planet_index]
        var planet_btn := _create_planet_button(planet_index, planet_data)
        container.add_child(planet_btn)

func _create_planet_button(index: int, data: Dictionary) -> Button:
    var btn := Button.new()
    btn.custom_minimum_size = Vector2(300, 80)
    btn.pressed.connect(func(): _on_planet_selected(index))
    return btn

func _update_lock_states() -> void:
    var highest_completed := SaveManager.get_highest_planet_completed()

    for i in range(4):
        var is_unlocked := i <= highest_completed + 1
        var btn := $PlanetContainer.get_child(i)
        var data := PLANET_DATA[i]

        if is_unlocked:
            btn.text = "%s %s\nPower: %d" % [data.emoji, data.name, data.power]
            btn.disabled = false
        else:
            btn.text = "🔒 %s\nLOCKED" % data.name
            btn.disabled = true
            btn.modulate = Color(0.5, 0.5, 0.5)

func _on_planet_selected(index: int) -> void:
    selected_planet = index
    $PlayButton.disabled = false
    _highlight_selected_planet()

func _on_play_pressed() -> void:
    if selected_planet >= 0:
        SaveManager.data["current_planet"] = selected_planet
        SaveManager.data["current_wave"] = 0
        SaveManager.save_game()
        get_tree().change_scene_to_file("res://scenes/game_combat_scene.tscn")
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│  ← Back          LEVEL SELECT      │
│                                    │
│    ┌────────────────────────────┐  │
│    │  🌕 Mercury                │  │
│    │  Power: 100    ★☆☆☆       │  │
│    └────────────────────────────┘  │
│                                    │
│    ┌────────────────────────────┐  │
│    │  🌒 Venus                  │  │
│    │  Power: 150    ★★☆☆       │  │
│    └────────────────────────────┘  │
│                                    │
│    ┌────────────────────────────┐  │
│    │  🔒 Mars                   │  │
│    │  LOCKED                    │  │
│    └────────────────────────────┘  │
│                                    │
│    ┌────────────────────────────┐  │
│    │  🔒 Earth                  │  │
│    │  LOCKED                    │  │
│    └────────────────────────────┘  │
│                                    │
│         [  ▶️ PLAY  ]              │
└────────────────────────────────────┘
```

---

## Logique de Déblocage

```
Début → Mercury débloquée

Mercury battu → Venus débloquée
Venus battu → Mars débloquée
Mars battu → Earth débloquée

highest_planet_completed:
-1 = aucune → Mercury seul jouable
 0 = Mercury → Venus jouable
 1 = Venus → Mars jouable
 2 = Mars → Earth jouable
 3 = Earth → Jeu terminé
```

---

## Tests de Validation

1. ✅ Nouvelle partie → seul Mercury débloqué
2. ✅ Mercury battu → Venus débloqué
3. ✅ Planète verrouillée → bouton grisé + disabled
4. ✅ Sélection planète → highlight visuel
5. ✅ PLAY → lance le combat avec bonne planète

---

## Dépendances

- **Requiert**: SaveManager progression (COF-403)
- **Utilisé par**: Main Menu navigation
