# COF-605: Options Menu Volume Sliders

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scripts/ui/options_menu.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** ajuster les paramètres du jeu,  
**Afin de** personnaliser mon expérience.

---

## Description

Le Options Menu permet de modifier le volume de la musique, des effets sonores, et d'activer/désactiver les vibrations.

---

## Critères d'Acceptation

- [x] Slider Music Volume (0% - 100%)
- [x] Slider SFX Volume (0% - 100%)
- [x] Toggle Vibration (On/Off)
- [x] Sauvegarde automatique des changements
- [x] Valeurs chargées au lancement

---

## Implémentation

```gdscript
extends Control

@onready var music_slider := $MusicSlider
@onready var sfx_slider := $SFXSlider
@onready var vibration_toggle := $VibrationToggle

func _ready() -> void:
    _load_settings()
    _connect_signals()

func _load_settings() -> void:
    var settings := SaveManager.get_settings()
    music_slider.value = settings.get("music_volume", 0.8) * 100
    sfx_slider.value = settings.get("sfx_volume", 1.0) * 100
    vibration_toggle.button_pressed = settings.get("vibration_enabled", true)

func _connect_signals() -> void:
    music_slider.value_changed.connect(_on_music_changed)
    sfx_slider.value_changed.connect(_on_sfx_changed)
    vibration_toggle.toggled.connect(_on_vibration_toggled)

func _on_music_changed(value: float) -> void:
    var volume := value / 100.0
    SaveManager.set_music_volume(volume)
    # TODO: Apply to AudioServer
    _update_music_label(value)

func _on_sfx_changed(value: float) -> void:
    var volume := value / 100.0
    SaveManager.set_sfx_volume(volume)
    # TODO: Apply to AudioServer
    _update_sfx_label(value)

func _on_vibration_toggled(enabled: bool) -> void:
    SaveManager.set_vibration_enabled(enabled)
    _update_vibration_label(enabled)

    # Test vibration pour feedback
    if enabled:
        Input.vibrate_handheld(50)
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│  ← Back          OPTIONS           │
│                                    │
│  AUDIO                             │
│  ┌──────────────────────────────┐  │
│  │ 🎵 Music Volume         80%  │  │
│  │ ├──────────────●──────────┤  │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │ 🔊 SFX Volume          100%  │  │
│  │ ├───────────────────────●┤   │  │
│  └──────────────────────────────┘  │
│                                    │
│  FEEDBACK                          │
│  ┌──────────────────────────────┐  │
│  │ 📳 Vibration           [ON]  │  │
│  └──────────────────────────────┘  │
│                                    │
│  ABOUT                             │
│  ┌──────────────────────────────┐  │
│  │ Click of Fate v1.0           │  │
│  │ © 2025                       │  │
│  └──────────────────────────────┘  │
│                                    │
│                                    │
└────────────────────────────────────┘
```

---

## Création des Sliders

```gdscript
func _create_slider(name: String, default_value: float) -> HSlider:
    var container := HBoxContainer.new()

    var label := Label.new()
    label.text = name
    container.add_child(label)

    var slider := HSlider.new()
    slider.min_value = 0
    slider.max_value = 100
    slider.value = default_value * 100
    slider.custom_minimum_size.x = 200
    container.add_child(slider)

    var value_label := Label.new()
    value_label.text = "%d%%" % (default_value * 100)
    container.add_child(value_label)

    return container
```

---

## Application Audio (Préparé)

```gdscript
func _apply_volume_to_bus(bus_name: String, linear_volume: float) -> void:
    var bus_index := AudioServer.get_bus_index(bus_name)
    if bus_index >= 0:
        var db := linear_to_db(linear_volume)
        AudioServer.set_bus_volume_db(bus_index, db)
```

---

## Tests de Validation

1. ✅ Sliders chargent valeurs sauvegardées
2. ✅ Modifier slider → sauvegarde automatique
3. ✅ Toggle vibration → test vibration si activé
4. ✅ Relancer le jeu → valeurs conservées
5. ✅ Labels mis à jour en temps réel

---

## Dépendances

- **Requiert**: SaveManager settings (COF-407)
- **Utilisé par**: Main Menu navigation
