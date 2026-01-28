# COF-612: Enemy HP Bars Floating

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/entities/base_enemy.gd` (lignes 89-130)

---

## User Story

**En tant que** joueur,  
**Je veux** voir les HP des ennemis,  
**Afin de** prioriser mes cibles.

---

## Description

Chaque ennemi a une barre de HP flottante au-dessus de sa tête qui montre son état de santé actuel.

---

## Critères d'Acceptation

- [x] HP bar au-dessus de chaque ennemi
- [x] Largeur proportionnelle aux HP max
- [x] Animation smooth de diminution
- [x] Disparaît à la mort
- [x] Flash rouge sur dégâts

---

## Implémentation

```gdscript
# Dans BaseEnemy
var hp_bar: ProgressBar
var hp_bar_background: ColorRect

func _setup_hp_bar() -> void:
    var bar_container := Control.new()
    bar_container.position = Vector2(-30, -50)  # Au-dessus du sprite
    bar_container.z_index = 10

    # Background
    hp_bar_background = ColorRect.new()
    hp_bar_background.color = Color(0.2, 0.2, 0.2, 0.8)
    hp_bar_background.size = Vector2(60, 8)
    bar_container.add_child(hp_bar_background)

    # Foreground (actual HP)
    hp_bar = ProgressBar.new()
    hp_bar.max_value = stats.max_hp
    hp_bar.value = stats.current_hp
    hp_bar.show_percentage = false
    hp_bar.size = Vector2(60, 8)
    hp_bar.add_theme_stylebox_override("fill", _create_hp_fill_style())
    bar_container.add_child(hp_bar)

    add_child(bar_container)

func _create_hp_fill_style() -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color.RED
    return style
```

---

## Layout Visuel

```
        ┌──────────┐
        │▓▓▓▓▓▓░░░░│  ← HP Bar (60×8 pixels)
        └──────────┘
            👾        ← Enemy sprite
```

---

## Mise à Jour des HP

```gdscript
func _on_hp_changed() -> void:
    var target_value := stats.current_hp

    # Animation smooth
    var tween := create_tween()
    tween.tween_property(hp_bar, "value", target_value, 0.2)

    # Flash rouge
    tween.parallel().tween_property(hp_bar, "modulate", Color.WHITE, 0.05)
    tween.tween_property(hp_bar, "modulate", Color.RED, 0.1)

func _on_death() -> void:
    # Fade out de la HP bar
    var tween := create_tween()
    tween.tween_property(hp_bar_background, "modulate:a", 0.0, 0.3)
    tween.parallel().tween_property(hp_bar, "modulate:a", 0.0, 0.3)
```

---

## Taille Variable selon Max HP

```gdscript
func _calculate_hp_bar_width() -> float:
    # Plus l'ennemi a de HP, plus la barre est large
    var base_width := 40.0
    var hp_factor := stats.max_hp / 50.0  # 50 HP = base
    return clampf(base_width * hp_factor, 30, 100)

# Exemples:
# 50 HP → 40px
# 100 HP → 80px
# 25 HP → 30px (minimum)
# 200 HP (boss) → 100px (maximum)
```

---

## Position Dynamique

```gdscript
func _process(_delta: float) -> void:
    # La HP bar suit l'ennemi
    hp_bar_container.global_position = global_position + Vector2(-30, -50)

    # Rester visible même si ennemi sort de l'écran (clamp)
    hp_bar_container.global_position.x = clampf(
        hp_bar_container.global_position.x,
        10, get_viewport_rect().size.x - 70
    )
```

---

## Couleur selon le Type d'Ennemi

```gdscript
func _get_hp_color_for_type() -> Color:
    match enemy_type:
        EnemyType.FAST:
            return Color.CYAN  # Mercury
        EnemyType.TOXIC:
            return Color.PURPLE  # Venus
        EnemyType.REGEN:
            return Color.ORANGE  # Mars
        EnemyType.TANK:
            return Color.DARK_GREEN  # Earth
        _:
            return Color.RED
```

---

## Tests de Validation

1. ✅ HP bar apparaît au-dessus de l'ennemi
2. ✅ Dégâts → bar diminue avec animation
3. ✅ Flash rouge visible sur hit
4. ✅ Mort → bar disparaît
5. ✅ Bar suit le mouvement de l'ennemi

---

## Dépendances

- **Requiert**: EntityStats (COF-102), BaseEnemy (COF-201)
- **Utilisé par**: Tous les ennemis
