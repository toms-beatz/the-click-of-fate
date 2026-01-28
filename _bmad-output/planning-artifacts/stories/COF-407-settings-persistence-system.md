# COF-407: Settings Persistence System

**Epic**: Save & Persistence  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scripts/autoload/save_manager.gd` (lignes 338-385)

---

## User Story

**En tant que** joueur,  
**Je veux** que mes paramètres soient sauvegardés,  
**Afin de** ne pas les reconfigurer à chaque lancement.

---

## Description

Les paramètres du jeu (volume, vibrations) sont persistés dans le SaveManager et appliqués automatiquement au chargement.

---

## Critères d'Acceptation

- [x] Paramètres sauvegardés :
  - `music_volume` - 0.0 à 1.0 (défaut 0.8)
  - `sfx_volume` - 0.0 à 1.0 (défaut 1.0)
  - `vibration_enabled` - boolean (défaut true)
- [x] Méthodes spécifiques :
  - `get_music_volume()` / `set_music_volume(volume)`
  - `get_sfx_volume()` / `set_sfx_volume(volume)`
  - `is_vibration_enabled()` / `set_vibration_enabled(enabled)`
- [x] Méthode générique :
  - `get_settings()` → Dictionary
  - `set_setting(key, value)` → void

---

## Implémentation

```gdscript
# Structure dans data
"settings": {
    "music_volume": 0.8,
    "sfx_volume": 1.0,
    "vibration_enabled": true
}

func get_music_volume() -> float:
    return data["settings"].get("music_volume", 0.8)

func set_music_volume(volume: float) -> void:
    data["settings"]["music_volume"] = clampf(volume, 0.0, 1.0)
    save_game()

func get_sfx_volume() -> float:
    return data["settings"].get("sfx_volume", 1.0)

func set_sfx_volume(volume: float) -> void:
    data["settings"]["sfx_volume"] = clampf(volume, 0.0, 1.0)
    save_game()

func is_vibration_enabled() -> bool:
    return data["settings"].get("vibration_enabled", true)

func set_vibration_enabled(enabled: bool) -> void:
    data["settings"]["vibration_enabled"] = enabled
    save_game()

func get_settings() -> Dictionary:
    return data.get("settings", {})

func set_setting(key: String, value: Variant) -> void:
    if data["settings"].has(key):
        data["settings"][key] = value
    save_game()
```

---

## Utilisation dans Options Menu

```gdscript
# Chargement
func _load_settings() -> void:
    var settings := SaveManager.get_settings()
    music_slider.value = settings.get("music_volume", 0.8)
    sfx_slider.value = settings.get("sfx_volume", 1.0)
    vibration_toggle.button_pressed = settings.get("vibration_enabled", true)

# Modification
func _on_music_changed(value: float) -> void:
    SaveManager.set_setting("music_volume", value)
    # TODO: Appliquer au bus audio

func _on_sfx_changed(value: float) -> void:
    SaveManager.set_setting("sfx_volume", value)
    # TODO: Appliquer au bus audio

func _on_vibration_toggled(enabled: bool) -> void:
    SaveManager.set_setting("vibration_enabled", enabled)
```

---

## Application Audio (Préparé)

```gdscript
# À implémenter avec le système audio
func _apply_audio_settings() -> void:
    var music_vol := SaveManager.get_music_volume()
    var sfx_vol := SaveManager.get_sfx_volume()

    AudioServer.set_bus_volume_db(
        AudioServer.get_bus_index("Music"),
        linear_to_db(music_vol)
    )
    AudioServer.set_bus_volume_db(
        AudioServer.get_bus_index("SFX"),
        linear_to_db(sfx_vol)
    )
```

---

## Application Vibration

```gdscript
func vibrate_if_enabled(duration_ms: int = 50) -> void:
    if SaveManager.is_vibration_enabled():
        Input.vibrate_handheld(duration_ms)
```

---

## Tests de Validation

1. ✅ Premier lancement → valeurs par défaut (0.8, 1.0, true)
2. ✅ Modifier music_volume → sauvegardé
3. ✅ Relancer le jeu → settings conservés
4. ✅ Clamp appliqué (pas de volume > 1.0)
5. ✅ Vibration désactivée → pas de vibration

---

## Dépendances

- **Requiert**: SaveManager structure (COF-401)
- **Utilisé par**: Options Menu, Audio System (futur)
