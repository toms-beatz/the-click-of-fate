# COF-503: Cinematic UI System

**Epic**: Cinematics  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** une interface de cinématique claire,  
**Afin de** lire les dialogues confortablement.

---

## Description

Le système de cinématique affiche des slides avec texte narratif et emoji. Le joueur peut naviguer par tap ou skipper entièrement.

---

## Critères d'Acceptation

- [x] Fond sombre avec overlay (80% opacité)
- [x] Emoji centré en grand (64px)
- [x] Texte narratif centré
- [x] Navigation par tap (n'importe où sur l'écran)
- [x] Animation de transition entre slides (fade)
- [x] Bouton "Skip" visible en haut à droite
- [x] Indicateur de progression (slide X/Y)

---

## Implémentation

````gdscript
var cinematic_layer: CanvasLayer
var is_showing_cinematic: bool = false
var cinematic_slide_index: int = 0
var current_cinematic_slides: Array = []

func _create_cinematic_ui(slides: Array) -> void:
    current_cinematic_slides = slides

    cinematic_layer = CanvasLayer.new()
    cinematic_layer.layer = 100  # Au-dessus de tout
    add_child(cinematic_layer)

    # Fond sombre
    var overlay := ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.8)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    cinematic_layer.add_child(overlay)

    # Container central
    var content := VBoxContainer.new()

























































































































- **Utilisé par**: Planet Intros (COF-501), Ending (COF-502)- **Requiert**: Rien## Dépendances---6. ✅ Indicateur de progression mis à jour5. ✅ Bouton Skip → termine immédiatement4. ✅ Dernier slide + tap → cinématique terminée3. ✅ Tap → passe au slide suivant2. ✅ Emoji et texte affichés correctement1. ✅ Cinématique affichée → overlay sombre visible## Tests de Validation---```└────────────────────────────────────┘│  1 / 3                   [TAP →]  ││                                    ││                                    ││    colony on the outer rim."       ││    family once... a beautiful      ││   "My name is Zyx-7. I had a      ││                                    ││               👽                   ││                                    ││                                    ││                         [SKIP ⏭️] │┌────────────────────────────────────┐```## Layout Visuel---```        await get_tree().create_timer(0.03).timeout        label.text += text[i]    for i in range(text.length()):    label.text = ""func _typewriter_effect(label: Label, text: String) -> void:```gdscript### Effet Typewriter (Optionnel)```    tween.tween_property(content, "modulate:a", 1.0, 0.15)    tween.tween_callback(_show_current_slide)    tween.tween_property(content, "modulate:a", 0.0, 0.15)    var tween := create_tween()func _animate_slide_transition() -> void:```gdscript### Transition entre Slides## Animations---```    progress_label.text = "%d / %d" % [cinematic_slide_index + 1, current_cinematic_slides.size()]    text_label.text = slide.text    emoji_label.text = slide.emoji    var slide: Dictionary = current_cinematic_slides[cinematic_slide_index]func _show_current_slide() -> void:        _show_current_slide()        _animate_slide_transition()    else:        _end_cinematic()    if cinematic_slide_index >= current_cinematic_slides.size():        cinematic_slide_index += 1func _next_slide() -> void:            _next_slide()        if event.pressed:    if event is InputEventMouseButton or event is InputEventScreenTouch:func _on_cinematic_input(event: InputEvent) -> void:```gdscript## Navigation---```    _show_current_slide()        overlay.gui_input.connect(_on_cinematic_input)    # Input handler        cinematic_layer.add_child(progress_label)    progress_label.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)    var progress_label := Label.new()    # Indicateur de progression        cinematic_layer.add_child(skip_btn)    skip_btn.pressed.connect(_end_cinematic)    skip_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)    skip_btn.text = "SKIP ⏭️"    var skip_btn := Button.new()    # Bouton Skip        content.add_child(text_label)    text_label.autowrap_mode = TextServer.AUTOWRAP_WORD    text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER    text_label.add_theme_font_size_override("font_size", 20)    var text_label := Label.new()    # Texte        content.add_child(emoji_label)    emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER    emoji_label.add_theme_font_size_override("font_size", 64)    var emoji_label := Label.new()    # Emoji        cinematic_layer.add_child(content)    content.alignment = BoxContainer.ALIGNMENT_CENTER    content.set_anchors_preset(Control.PRESET_CENTER)```
````
