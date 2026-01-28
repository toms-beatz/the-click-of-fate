# COF-608: Defeat Screen Retry Option

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur ayant perdu,  
**Je veux** pouvoir réessayer ou quitter,  
**Afin de** ne pas être frustré par la défaite.

---

## Description

L'écran de défaite s'affiche quand le héros meurt. Il offre l'option de retry (recommencer la planète) ou de retourner au menu. La monnaie gagnée pendant la session est restaurée.

---

## Critères d'Acceptation

- [x] Titre "DEFEAT 💀"
- [x] Affichage des statistiques (vagues atteintes, kills)
- [x] Bouton "Retry" → recommence la planète
- [x] Bouton "Main Menu" → retour menu
- [x] Monnaie restaurée au début de session

---

## Implémentation

```gdscript
func _show_defeat_screen() -> void:
    # Restaurer la monnaie de la session
    SaveManager.restore_session_currency()

    # Enregistrer la mort
    SaveManager.retry_level()  # Incrémente total_deaths

    _create_defeat_ui({
        "waves_reached": current_wave,
        "enemies_killed": enemies_killed_this_run,
        "time": combat_time
    })

func _create_defeat_ui(stats: Dictionary) -> void:
    var defeat_layer := CanvasLayer.new()
    defeat_layer.layer = 100
    add_child(defeat_layer)

    # Overlay rouge sombre
    var overlay := ColorRect.new()
    overlay.color = Color(0.3, 0, 0, 0.85)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    defeat_layer.add_child(overlay)

    var content := VBoxContainer.new()
    content.set_anchors_preset(Control.PRESET_CENTER)

    # Titre
    var title := Label.new()
    title.text = "💀 DEFEAT 💀"
    title.add_theme_font_size_override("font_size", 40)
    title.add_theme_color_override("font_color", Color.RED)
    content.add_child(title)

    # Statistiques
    var stats_text := """
    Waves Reached: %d / 5
    Enemies Killed: %d
    Time Survived: %s

    ⚠️ Currency restored to session start
    """ % [stats.waves_reached, stats.enemies_killed, _format_time(stats.time)]

    var stats_label := Label.new()
    stats_label.text = stats_text
    content.add_child(stats_label)

    # Conseil
    var tip := Label.new()
    tip.text = "💡 TIP: Upgrade your stats in the Profile menu!"
    tip.add_theme_font_size_override("font_size", 14)
    content.add_child(tip)

    # Boutons
    var retry_btn := Button.new()
    retry_btn.text = "🔄 RETRY"
    retry_btn.pressed.connect(_retry_level)

    var menu_btn := Button.new()
    menu_btn.text = "🏠 Main Menu"
    menu_btn.pressed.connect(_return_to_menu)

    content.add_child(retry_btn)
    content.add_child(menu_btn)

    defeat_layer.add_child(content)
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│                                    │
│         💀 DEFEAT 💀               │
│                                    │
│    ZYX-7 HAS FALLEN                │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  STATISTICS                  │  │
│  │  ───────────────────────     │  │
│  │  Waves Reached:    3 / 5     │  │
│  │  Enemies Killed:   18        │  │
│  │  Time Survived:    2:15      │  │
│  │                              │  │
│  │  ⚠️ Currency restored to     │  │
│  │     session start            │  │
│  └──────────────────────────────┘  │
│                                    │
│  💡 TIP: Upgrade your stats in    │
│     the Profile menu!             │
│                                    │
│   ┌──────────────────────────┐     │
│   │      🔄 RETRY            │     │
│   └──────────────────────────┘     │
│   ┌──────────────────────────┐     │
│   │      🏠 Main Menu        │     │
│   └──────────────────────────┘     │
│                                    │
└────────────────────────────────────┘
```

---

## Flow de Retry

```
Défaite
    │
    ├── restore_session_currency()
    │   └── SC revient au niveau du début de session
    │
    ├── retry_level()
    │   ├── current_wave = 0
    │   └── total_deaths += 1
    │
    └── Player choisit:
        │
        ├── RETRY
        │   └── Recharge la scène
        │
        └── MENU
            └── Retour au Main Menu
```

---

## Retry vs Menu

```gdscript
func _retry_level() -> void:
    # Recommencer la même planète
    SaveManager.start_session()  # Nouvelle session
    get_tree().reload_current_scene()

func _return_to_menu() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
```

---

## Conseils Dynamiques

```gdscript
const DEFEAT_TIPS := [
    "💡 TIP: Upgrade your stats in the Profile menu!",
    "💡 TIP: Don't spam clicks - watch your Pressure gauge!",
    "💡 TIP: Heal when below 50% HP for best efficiency.",
    "💡 TIP: Dodge is most effective against big attacks.",
    "💡 TIP: Better equipment can be bought in the Shop!",
]

func _get_random_tip() -> String:
    return DEFEAT_TIPS[randi() % DEFEAT_TIPS.size()]
```

---

## Tests de Validation

1. ✅ Héros meurt → écran défaite affiché
2. ✅ SC restauré au début de session
3. ✅ Retry → recommence wave 0
4. ✅ Statistiques affichées correctement
5. ✅ total_deaths incrémenté

---

## Dépendances

- **Requiert**: SaveManager (COF-401, COF-402, COF-403)
- **Utilisé par**: GameCombatScene après mort du héros
