# COF-614: Wave Counter Display

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** voir clairement la vague en cours,  
**Afin de** savoir ma progression dans le niveau.

---

## Description

L'indicateur de vague affiche "Wave X/5" et une animation de transition entre les vagues.

---

## Critères d'Acceptation

- [x] Affichage "Wave X/5" dans le HUD
- [x] Animation de transition entre vagues
- [x] Indicateur "BOSS" pour la dernière vague
- [x] Ennemis restants dans la vague affichés
- [x] Animation spéciale au début de chaque vague

---

## Implémentation

```gdscript
var wave_label: Label
var enemies_remaining_label: Label

func _setup_wave_display() -> void:
    var wave_container := VBoxContainer.new()
    wave_container.set_anchors_preset(Control.PRESET_CENTER_TOP)

    wave_label = Label.new()
    wave_label.text = "WAVE 1/5"
    wave_label.add_theme_font_size_override("font_size", 24)
    wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    wave_container.add_child(wave_label)

    enemies_remaining_label = Label.new()
    enemies_remaining_label.text = "👾 5 remaining"
    enemies_remaining_label.add_theme_font_size_override("font_size", 14)
    enemies_remaining_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    wave_container.add_child(enemies_remaining_label)

    hud_layer.add_child(wave_container)

func _update_wave_display(wave_number: int, is_boss: bool = false) -> void:
    if is_boss:
        wave_label.text = "⚠️ BOSS WAVE ⚠️"
        wave_label.add_theme_color_override("font_color", Color.RED)
    else:
        wave_label.text = "WAVE %d/5" % (wave_number + 1)
        wave_label.add_theme_color_override("font_color", Color.WHITE)
```

- **Utilisé par**: GameCombatScene- **Requiert**: WaveController (COF-112)## Dépendances---5. ✅ "Wave Clear!" affiché quand tous morts4. ✅ Enemies remaining mis à jour en temps réel3. ✅ Boss wave → texte rouge spécial2. ✅ Nouvelle vague → animation de transition1. ✅ Wave label affiche numéro correct## Tests de Validation---`        enemies_remaining_label.add_theme_color_override("font_color", Color.WHITE)        enemies_remaining_label.text = "👾 %d remaining" % count    else:        enemies_remaining_label.text = "💀 Boss HP: %d%%" % boss_hp_percent    elif count == 1 and is_boss_wave:        enemies_remaining_label.add_theme_color_override("font_color", Color.GREEN)        enemies_remaining_label.text = "✅ Wave Clear!"    if count == 0:        var count := get_tree().get_nodes_in_group("enemies").size()func _update_enemies_remaining() -> void:`gdscript## Compteur d'Ennemis---`         ↓ (fade out après 1s)└────────────────────────────────────┘│▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓││▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓││▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓││▓▓▓▓▓▓▓▓▓                         ▓▓││▓▓▓▓▓▓▓▓▓    WAVE 4               ▓▓││▓▓▓▓▓▓▓▓▓                         ▓▓││▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓││▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓││▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│┌────────────────────────────────────┐`## Transition de Vague---`├────────────────────────────────────┤│        💀 1 remaining              ││       ⚠️ BOSS WAVE ⚠️              │┌────────────────────────────────────┐`### Vague Boss`├────────────────────────────────────┤│        👾 4 remaining              ││         WAVE 3/5                   │┌────────────────────────────────────┐`### Vague Normale## Layout Visuel---`    tween.tween_callback(overlay.queue_free)    tween.tween_property(overlay, "modulate:a", 0.0, 0.3)    tween.tween_interval(1.0)    tween.tween_property(wave_text, "modulate:a", 1.0, 0.3)    wave_text.modulate.a = 0    var tween := create_tween()    # Animation        overlay.add_child(wave_text)    wave_text.add_theme_font_size_override("font_size", 48)            wave_text.text = "WAVE %d" % (wave_number + 1)    else:        wave_text.add_theme_color_override("font_color", Color.RED)        wave_text.text = "⚠️ BOSS INCOMING ⚠️"    if wave_number == 5:  # Boss wave        wave_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER    wave_text.set_anchors_preset(Control.PRESET_CENTER)    var wave_text := Label.new()        add_child(overlay)    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)    overlay.color = Color(0, 0, 0, 0.8)    var overlay := ColorRect.new()    # Créer un overlay temporairefunc _show_wave_transition(wave_number: int) -> void:`gdscript## Animation de Nouvelle Vague---
