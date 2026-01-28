# COF-609: HUD Combat Header Display

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scenes/game_combat_scene.gd` (lignes 300+)

---

## User Story

**En tant que** joueur en combat,  
**Je veux** voir les informations importantes en haut de l'écran,  
**Afin de** suivre ma progression de niveau.

---

## Description

Le HUD header affiche les informations essentielles du combat : vague actuelle, planète, monnaie, et bouton pause.

---

## Critères d'Acceptation

- [x] Bouton Pause en haut à gauche (⏸️)
- [x] Indicateur de vague "Wave X/5"
- [x] Nom de la planète actuelle
- [x] Monnaie collectée pendant le run
- [x] Mise à jour en temps réel

---

## Implémentation

```gdscript
var hud_layer: CanvasLayer
var wave_label: Label
var planet_label: Label
var currency_label: Label

func _setup_hud() -> void:
    hud_layer = CanvasLayer.new()
    hud_layer.layer = 10
    add_child(hud_layer)

    var header := HBoxContainer.new()
    header.set_anchors_preset(Control.PRESET_TOP_WIDE)
    header.custom_minimum_size.y = 60

    # Bouton Pause
    var pause_btn := Button.new()
    pause_btn.text = "⏸️"
    pause_btn.pressed.connect(_on_pause_pressed)
    header.add_child(pause_btn)

    # Spacer
    header.add_child(Control.new())

    # Info container
    var info := VBoxContainer.new()

    # Planète
    planet_label = Label.new()
    planet_label.text = _get_planet_name(current_planet)
    info.add_child(planet_label)

    # Wave
    wave_label = Label.new()
    wave_label.text = "Wave 1/5"
    info.add_child(wave_label)

    header.add_child(info)

    # Spacer
    header.add_child(Control.new())

    # Currency
    currency_label = Label.new()
    currency_label.text = "💰 0 SC"
    header.add_child(currency_label)

    hud_layer.add_child(header)

func _update_hud() -> void:
    wave_label.text = "Wave %d/5" % (current_wave + 1)
    currency_label.text = "💰 %d SC" % coins_earned_this_run
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│ [⏸️]    🌕 MERCURY     💰 234 SC   │
│         Wave 3/5                   │
├────────────────────────────────────┤
│                                    │
│          (Zone de combat)          │
│                                    │
```

---

## Données des Planètes

```gdscript
const PLANET_NAMES := {
    0: "🌕 MERCURY",
    1: "🌒 VENUS",
    2: "🔴 MARS",
    3: "🌍 EARTH",
}

func _get_planet_name(index: int) -> String:
    return PLANET_NAMES.get(index, "UNKNOWN")
```

---

## Mise à Jour Dynamique

```gdscript
# Appelé quand une vague commence
func _on_wave_started(wave_number: int) -> void:
    current_wave = wave_number
    _update_hud()

    # Animation flash pour nouvelle vague
    var tween := create_tween()
    tween.tween_property(wave_label, "modulate", Color.YELLOW, 0.2)
    tween.tween_property(wave_label, "modulate", Color.WHITE, 0.3)

# Appelé quand un ennemi est tué
func _on_enemy_killed_reward(amount: int) -> void:
    coins_earned_this_run += amount
    _update_hud()

    # Animation "+8" qui monte
    _spawn_floating_text("+%d" % amount, currency_label.global_position)
```

---

## Tests de Validation

1. ✅ HUD affiché dès le début du combat
2. ✅ Wave label mis à jour à chaque vague
3. ✅ Currency augmente quand ennemi tué
4. ✅ Nom de planète correct
5. ✅ Bouton Pause fonctionne

---

## Dépendances

- **Requiert**: Rien (UI de base)
- **Utilisé par**: GameCombatScene
