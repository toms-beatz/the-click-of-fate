# 🎨 UI/UX DEVELOPER AGENT

## Agent Identity

| Field | Value |

| **Name** | UI/UX Developer Agent ||-------|-------|

| **Module** | Click of Fate || **Role** | Interface & Visual Feedback |

| **Reports To** | Architect Agent |

---

## 🎯 Responsabilités

2. **HUD** - HP bars, pressure bars, wave counter1. **Click Zone** - Tripartite button avec zones colorées

3. **Cinematics** - Intro slides, ending sequence4. **Floating Texts** - Damage numbers, status effects3. **Menus** - Main menu, level select, options, pause

4. **Responsive Design** - Adaptation à tous les écrans mobiles

---

## 📁 Fichiers Sous Ma Responsabilité

scripts/ui/```

├── click_zone_button.gd

└── options_menu.gd├── level_select.gd├── main_menu.gd

scenes/

├── game_combat_scene.gd # Sections HUD et visuels

    ├── level_select.tscn    ├── main_menu.tscn└── ui/

    └── options_menu.tscn

---```

## ⚠️ Contraintes Connues

### 1. Responsive Sizing

````gdscript


















































































































































- [ ] Labels en anglais- [ ] Testé sur aspect ratios: 16:9, 18:9, 20:9- [ ] Textes flottants sur la bonne entité- [ ] Pas de pixels fixes > 200px- [ ] Tailles avec `mini()` ou `SIZE_EXPAND_FILL`- [ ] Toutes les positions sont relatives (%)## 📋 Checklist Avant Commit---```    tween.tween_callback(flash.queue_free)    tween.tween_property(flash, "color:a", 0.0, 0.3)    var tween := create_tween()        effects_layer.add_child(flash)    flash.mouse_filter = Control.MOUSE_FILTER_IGNORE    flash.color = color    flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)    var flash := ColorRect.new()func _create_screen_flash(color: Color) -> void:```gdscript### Screen Flash```        await get_tree().create_timer(0.03).timeout        label.text = current_text        current_text += full_text[i]    for i in range(full_text.length()):    var current_text := ""func _typewriter_effect(label: Label, full_text: String) -> void:```gdscript### Typewriter Effect```    tween.chain().tween_callback(label.queue_free)    tween.tween_property(label, "modulate:a", 0.0, 0.8)    tween.tween_property(label, "position:y", pos.y - 60, 0.8)    tween.set_parallel(true)    var tween := create_tween()        effects_layer.add_child(label)    label.z_index = 100    label.position = pos    label.add_theme_color_override("font_color", color)    label.add_theme_font_size_override("font_size", adjusted_size)    var adjusted_size: int = int(float(size) * minf(1.0, viewport_size.x / 720.0))    var viewport_size: Vector2 = get_viewport().get_visible_rect().size    label.text = text    var label := Label.new()func _show_floating_text(text: String, pos: Vector2, color: Color, size: int = 24) -> void:```gdscript### Floating Text## 🔧 Patterns UI---| COF-040 | English UI | 3 || COF-033 | Visual Feedback Positions | 3 || COF-032 | Responsive UI | 8 || COF-031 | Ending Cinematic | 3 || COF-030 | Intro Cinematics | 5 || COF-020 | Planet Selection | 8 || COF-004 | Tripartite Click Zone | 8 ||----|-------|--------|| ID | Titre | Points |## 📝 Stories Complétées---```window/handheld/orientation=1window/stretch/aspect="keep_height"  # IMPORTANT!window/stretch/mode="canvas_items"window/size/viewport_height=1280window/size/viewport_width=720[display]```ini## 📐 project.godot Settings---| **Defeat** | `Color(0.9, 0.3, 0.3)` | Rouge || **Victory** | `Color(1.0, 0.85, 0.3)` | Or || **Currency** | `Color(1.0, 0.85, 0.3)` | Or || **Enemy HP** | `Color(0.9, 0.2, 0.2)` | Rouge || **Hero HP** | `Color(0.2, 0.9, 0.3)` | Vert || **Attack Zone** | `Color(0.8, 0.2, 0.15)` | Rouge - zone droite || **Dodge Zone** | `Color(0.6, 0.35, 0.9)` | Violet - zone centre || **Heal Zone** | `Color(0.15, 0.5, 0.8)` | Bleu - zone gauche ||---------|-------|-------|| Element | Color | Usage |## 🎨 Palette de Couleurs---```margin_container.add_theme_constant_override("margin_bottom", 30)margin_container.add_theme_constant_override("margin_top", 50)# Marges pour safe area```gdscript### 5. Safe Area (Encoches)```var center := Vector2(viewport.x * 0.5 - 80, viewport.y * 0.30)# Messages CENTRÉS (victory, wave, boss)var enemy_pos := enemy_container.position + Vector2(0, -80)# Actions sur l'ENNEMI (attaque, dégâts infligés)var hero_pos := hero_container.position + Vector2(50, -50)# Actions sur le HÉROS (heal, shield, dégâts reçus)```gdscript### 4. Floating Text Positions```bottom_container.anchor_top = 0.78  # Commence à 78% de la hauteurbottom_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)# Pour les containers en bas d'écran```gdscript### 3. Anchors pour Containers```hero_container.position = Vector2(vp.x * 0.12, vp.y * 0.35)var vp: Vector2 = get_viewport().get_visible_rect().size# ✅ POSITIONS EN POURCENTAGEhero_container.position = Vector2(80, 450)# ❌ POSITIONS FIXES```gdscript### 2. Positions Relatives```button.size_flags_horizontal = Control.SIZE_EXPAND_FILLbutton.custom_minimum_size = Vector2(0, 110)  # Largeur flexiblevar viewport: Vector2 = get_viewport().get_visible_rect().size# ✅ TAILLES ADAPTATIVESbutton.custom_minimum_size = Vector2(680, 130)# ❌ TAILLES FIXES
````
