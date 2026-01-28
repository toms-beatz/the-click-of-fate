# COF-601: Main Menu Initial Screen

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/ui/main_menu.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** un menu principal fonctionnel,  
**Afin de** naviguer vers les différentes sections du jeu.

---

## Description

Le Main Menu est l'écran d'accueil du jeu avec le titre et les boutons de navigation vers les sous-menus.

---

## Critères d'Acceptation

- [x] Titre du jeu affiché : "CLICK OF FATE" avec emoji 🎮
- [x] Boutons de navigation :
  - Play → Level Select
  - Profile → Profile Menu
  - Shop → Shop Menu
  - Options → Options Menu
  - Quit → Ferme l'application
- [x] Affichage de la monnaie actuelle
- [x] Connexion SaveManager pour les données
- [x] Transitions fluides vers sous-menus

---

## Implémentation

```gdscript
extends Control

@onready var currency_label := $CurrencyLabel

func _ready() -> void:
    _setup_buttons()
    _update_currency_display()
    SaveManager.currency_changed.connect(_update_currency_display)

func _update_currency_display() -> void:
    currency_label.text = "💰 %d SC" % SaveManager.get_currency()

func _on_play_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func _on_profile_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/profile_menu.tscn")

func _on_shop_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/shop_menu.tscn")

func _on_options_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/ui/options_menu.tscn")

func _on_quit_pressed() -> void:
    get_tree().quit()
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│  💰 1234 SC                        │
│                                    │
│                                    │
│          🎮 CLICK OF FATE          │
│                                    │
│                                    │
│         ┌──────────────┐           │
│         │   ▶️  PLAY    │           │
│         └──────────────┘           │
│         ┌──────────────┐           │
│         │  👤 PROFILE  │           │
│         └──────────────┘           │
│         ┌──────────────┐           │
│         │   🛒 SHOP    │           │
│         └──────────────┘           │
│         ┌──────────────┐           │
│         │  ⚙️ OPTIONS  │           │
│         └──────────────┘           │
│         ┌──────────────┐           │
│         │   🚪 QUIT    │           │
│         └──────────────┘           │
└────────────────────────────────────┘
```

---

## Style des Boutons

```gdscript
func _create_menu_button(text: String, emoji: String) -> Button:
    var btn := Button.new()
    btn.text = "%s %s" % [emoji, text]
    btn.custom_minimum_size = Vector2(200, 50)
    btn.add_theme_font_size_override("font_size", 20)
    return btn
```

---

## Tests de Validation

1. ✅ Lancement du jeu → Main Menu affiché
2. ✅ Currency affiché correctement
3. ✅ Bouton Play → Level Select
4. ✅ Bouton Profile → Profile Menu
5. ✅ Bouton Quit → Application fermée

---

## Dépendances

- **Requiert**: SaveManager (COF-401)
- **Utilisé par**: Point d'entrée du jeu
