# COF-606: Pause Menu Ingame

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur en combat,  
**Je veux** pouvoir mettre le jeu en pause,  
**Afin de** faire une pause ou accéder aux options.

---

## Description

Le menu pause overlay permet de suspendre le combat et offre des options : continuer, options, ou retour au menu principal.

---

## Critères d'Acceptation

- [x] Bouton Pause visible pendant le combat (⏸️)
- [x] Pause → jeu gelé (process tree pausé)
- [x] Overlay avec options :
  - Resume → reprend le combat
  - Options → paramètres (sans quitter)
  - Main Menu → retour au menu (confirmer perte de progression)
- [x] Signal `paused` / `resumed`

---

## Implémentation

```gdscript
var is_paused: bool = false
var pause_layer: CanvasLayer

func _on_pause_pressed() -> void:
    if is_paused:
        _resume_game()
    else:
        _pause_game()

func _pause_game() -> void:
    is_paused = true
    get_tree().paused = true
    _show_pause_menu()

func _resume_game() -> void:
    is_paused = false
    get_tree().paused = false
    _hide_pause_menu()

func _show_pause_menu() -> void:
    pause_layer = CanvasLayer.new()
    pause_layer.layer = 50
    pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS  # Important!
    add_child(pause_layer)

    var overlay := ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.7)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    pause_layer.add_child(overlay)

    var menu := VBoxContainer.new()
    menu.set_anchors_preset(Control.PRESET_CENTER)

    var title := Label.new()
    title.text = "⏸️ PAUSED"
    title.add_theme_font_size_override("font_size", 32)
    menu.add_child(title)

    var resume_btn := _create_pause_button("▶️ Resume", _resume_game)
    var options_btn := _create_pause_button("⚙️ Options", _show_pause_options)
    var quit_btn := _create_pause_button("🚪 Main Menu", _confirm_quit)

    menu.add_child(resume_btn)
    menu.add_child(options_btn)
    menu.add_child(quit_btn)

    pause_layer.add_child(menu)
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│  [⏸️]  Wave 3/5        💰 234 SC   │
│ ─────────────────────────────────  │
│ ▓▓▓▓▓▓▓▓░░░░░░░░ HP 67/100        │
│                                    │
│  ┌────────────────────────────┐   │
│  │                            │   │
│  │       ⏸️ PAUSED            │   │
│  │                            │   │
│  │    ┌────────────────┐      │   │
│  │    │  ▶️ Resume     │      │   │
│  │    └────────────────┘      │   │
│  │    ┌────────────────┐      │   │
│  │    │  ⚙️ Options    │      │   │
│  │    └────────────────┘      │   │
│  │    ┌────────────────┐      │   │
│  │    │  🚪 Main Menu  │      │   │
│  │    └────────────────┘      │   │
│  │                            │   │
│  └────────────────────────────┘   │
│                                    │
│ ┌────────────────────────────────┐ │
│ │  💚 HEAL  │ 💨 DODGE │ ⚔️ ATK  │ │
│ └────────────────────────────────┘ │
└────────────────────────────────────┘
```

---

## Confirmation de Quitter

```gdscript
func _confirm_quit() -> void:
    var confirm := ConfirmationDialog.new()
    confirm.dialog_text = "Return to main menu?\nYou will lose current wave progress."
    confirm.confirmed.connect(_quit_to_menu)
    confirm.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(confirm)
    confirm.popup_centered()

func _quit_to_menu() -> void:
    SaveManager.restore_session_currency()  # Restaurer SC
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
```

---

## PROCESS_MODE Important

```gdscript
# Le pause menu doit fonctionner PENDANT la pause
pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
# Les boutons aussi
resume_btn.process_mode = Node.PROCESS_MODE_ALWAYS
```

---

## Input Handling

```gdscript
func _input(event: InputEvent) -> void:
    # Touche Escape ou bouton Back Android
    if event.is_action_pressed("ui_cancel"):
        if is_paused:
            _resume_game()
        else:
            _pause_game()
```

---

## Tests de Validation

1. ✅ Bouton Pause → jeu gelé
2. ✅ Ennemis et timer arrêtés
3. ✅ Resume → reprend exactement où c'était
4. ✅ Main Menu → confirmation requise
5. ✅ Options → paramètres accessibles

---

## Dépendances

- **Requiert**: Options Menu (COF-605)
- **Utilisé par**: GameCombatScene
