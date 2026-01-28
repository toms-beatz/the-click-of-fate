# COF-304: Boss Phase Transition

**Epic**: Boss System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** une transition claire vers le boss,  
**Afin de** me préparer au combat final de la planète.

---

## Description

Après avoir terminé les 5 vagues normales, le joueur doit recevoir une notification claire que le boss arrive. Un message "BOSS INCOMING!" et des effets visuels marquent la transition.

---

## Critères d'Acceptation

- [x] Message "BOSS INCOMING!" affiché après vague 5
- [x] Wave label mis à jour : "⚔️ BOSS FIGHT!"
- [x] Effets visuels de transition (flash, shake)
- [x] Délai avant spawn du boss (~2 secondes)
- [x] Musique/ambiance change (préparé pour audio)

---

## Implémentation

```gdscript
func _start_boss_phase() -> void:
    is_boss_wave = true

    # Afficher message d'alerte
    _show_boss_alert()

    # Mettre à jour le label de vague
    if wave_label:
        wave_label.text = "⚔️ BOSS FIGHT!"
        wave_label.add_theme_color_override("font_color", Color.RED)

    # Attendre avant spawn
    await get_tree().create_timer(2.0).timeout

    # Spawn le boss
    _spawn_boss()

func _show_boss_alert() -> void:
    var alert := Label.new()
    alert.text = "⚠️ BOSS INCOMING! ⚠️"
    alert.add_theme_font_size_override("font_size", 32)
    alert.add_theme_color_override("font_color", Color.RED)
    alert.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    alert.set_anchors_preset(Control.PRESET_CENTER)

    hud_layer.add_child(alert)

    # Animation
    var tween := create_tween()
    tween.tween_property(alert, "modulate:a", 0.0, 0.3).set_delay(1.5)
    tween.tween_callback(alert.queue_free)

    # Screen shake
    _shake_screen(0.5, 10.0)
```

---

## Flow de Transition

```
Vague 5 terminée
       │
       ▼
 wave_cleared()
       │
       ▼
 current_wave >= 5 ?
       │ oui
       ▼
 _start_boss_phase()
       │
       ├── "BOSS INCOMING!" affiché
       ├── wave_label = "BOSS FIGHT!"
       ├── screen shake
       ├── attendre 2 secondes
       │
       ▼
 _spawn_boss()
       │
       ├── créer visuel boss
       ├── créer HP bar
       └── configurer combat
```

---

## Effets Visuels

### Screen Shake

```gdscript
func _shake_screen(duration: float, intensity: float) -> void:
    var original_pos := combat_zone.position
    var elapsed := 0.0

    while elapsed < duration:
        var offset := Vector2(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        combat_zone.position = original_pos + offset
        await get_tree().process_frame
        elapsed += get_process_delta_time()

    combat_zone.position = original_pos
```

### Flash Rouge

```gdscript
func _flash_screen_red() -> void:
    var flash := ColorRect.new()
    flash.color = Color(1.0, 0.0, 0.0, 0.3)
    flash.set_anchors_preset(Control.PRESET_FULL_RECT)
    hud_layer.add_child(flash)

    var tween := create_tween()
    tween.tween_property(flash, "modulate:a", 0.0, 0.5)
    tween.tween_callback(flash.queue_free)
```

---

## Tests de Validation

1. ✅ Vague 5 terminée → "BOSS INCOMING!" affiché
2. ✅ Wave label change en "⚔️ BOSS FIGHT!"
3. ✅ Screen shake pendant la transition
4. ✅ Boss spawn après ~2 secondes
5. ✅ Joueur peut se préparer pendant la transition

---

## Dépendances

- **Requiert**: Wave Controller (COF-108), Boss Data (COF-301)
- **Utilisé par**: `GameCombatScene`
