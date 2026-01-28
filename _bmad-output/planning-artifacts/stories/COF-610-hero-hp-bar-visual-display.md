# COF-610: Hero HP Bar Visual Display

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scenes/game_combat_scene.gd` (lignes 314-346)

---

## User Story

**En tant que** joueur,  
**Je veux** voir clairement ma barre de vie,  
**Afin de** savoir quand me soigner.

---

## Description

La barre de HP du héros est affichée sous le header avec une représentation visuelle claire du pourcentage de vie restant.

---

## Critères d'Acceptation

- [x] Barre horizontale sous le header
- [x] Couleur verte → jaune → rouge selon %HP
- [x] Affichage numérique "HP: X/Y"
- [x] Animation smooth lors des changements
- [x] Flash rouge quand dégâts reçus

---

## Implémentation

```gdscript
var hp_bar: ProgressBar
var hp_label: Label
var hp_container: HBoxContainer

func _setup_hp_bar() -> void:
    hp_container = HBoxContainer.new()
    hp_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
    hp_container.offset_top = 60  # Sous le header
    hp_container.custom_minimum_size.y = 30

    # Label HP
    hp_label = Label.new()
    hp_label.text = "HP"
    hp_label.custom_minimum_size.x = 60
    hp_container.add_child(hp_label)

    # Progress Bar
    hp_bar = ProgressBar.new()
    hp_bar.max_value = hero.stats.max_hp
    hp_bar.value = hero.stats.current_hp
    hp_bar.show_percentage = false
    hp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    hp_container.add_child(hp_bar)

    # Valeur numérique
    var hp_value := Label.new()
    hp_value.text = "%d/%d" % [hero.stats.current_hp, hero.stats.max_hp]
    hp_container.add_child(hp_value)

    hud_layer.add_child(hp_container)

func _update_hp_display() -> void:
    var current := hero.stats.current_hp
    var max_hp := hero.stats.max_hp
    var ratio := float(current) / float(max_hp)

    # Animation smooth
    var tween := create_tween()
    tween.tween_property(hp_bar, "value", current, 0.2)

    # Couleur basée sur le %
    var color: Color
    if ratio > 0.6:
        color = Color.GREEN
    elif ratio > 0.3:
        color = Color.YELLOW
    else:
        color = Color.RED

    hp_bar.modulate = color
    hp_value.text = "%d/%d" % [current, max_hp]
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│ [⏸️]    🌕 MERCURY     💰 234 SC   │
├────────────────────────────────────┤
│ HP ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░  67/100    │
├────────────────────────────────────┤
```

### États de la barre

```
100% HP (Vert):
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ 100/100

60% HP (Jaune):
▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░  60/100

25% HP (Rouge):
▓▓▓▓▓░░░░░░░░░░░░░░░  25/100
```

---

## Animation de Dégâts

```gdscript
func _on_hero_damaged(amount: int) -> void:
    _update_hp_display()

    # Flash rouge
    var tween := create_tween()
    tween.tween_property(hp_bar, "modulate", Color.WHITE, 0.05)
    tween.tween_property(hp_bar, "modulate", Color.RED, 0.1)
    tween.tween_callback(_update_hp_color)

    # Shake léger
    _shake_hp_bar()

func _shake_hp_bar() -> void:
    var original_pos := hp_container.position
    var tween := create_tween()
    tween.tween_property(hp_container, "position:x", original_pos.x + 5, 0.05)
    tween.tween_property(hp_container, "position:x", original_pos.x - 5, 0.05)
    tween.tween_property(hp_container, "position:x", original_pos.x, 0.05)
```

---

## Animation de Soin

```gdscript
func _on_hero_healed(amount: int) -> void:
    _update_hp_display()

    # Flash vert
    var tween := create_tween()
    tween.tween_property(hp_bar, "modulate", Color.WHITE, 0.1)
    tween.tween_property(hp_bar, "modulate", Color.GREEN, 0.2)
    tween.tween_callback(_update_hp_color)

    # Texte flottant "+XX"
    _spawn_floating_text("+%d" % amount, hp_bar.global_position, Color.GREEN)
```

---

## Tests de Validation

1. ✅ HP bar affichée avec valeur correcte
2. ✅ Dégâts → animation smooth de diminution
3. ✅ Couleur change selon le pourcentage
4. ✅ Flash rouge sur dégâts
5. ✅ Flash vert sur soin

---

## Dépendances

- **Requiert**: EntityStats (COF-102)
- **Utilisé par**: GameCombatScene
