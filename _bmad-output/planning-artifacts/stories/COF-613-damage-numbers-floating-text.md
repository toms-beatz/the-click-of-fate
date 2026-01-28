# COF-613: Damage Numbers Floating Text

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** voir les dégâts infligés en texte flottant,  
**Afin de** comprendre l'impact de mes actions.

---

## Description

Les dégâts, soins et autres valeurs importantes apparaissent en texte flottant qui monte et disparaît.

---

## Critères d'Acceptation

- [x] Texte apparaît à la position de l'entité touchée
- [x] Animation: monte + fade out
- [x] Couleurs distinctes:
  - Rouge pour dégâts subis
  - Blanc pour dégâts infligés
  - Vert pour soins
  - Jaune pour SC gagnés
- [x] Taille variable selon l'importance (crits plus gros)

---

## Implémentation

```gdscript
func _spawn_floating_text(text: String, position: Vector2, color: Color = Color.WHITE, scale: float = 1.0) -> void:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", int(24 * scale))
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color.BLACK)
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    label.position = position
    label.z_index = 100
    label.pivot_offset = label.size / 2

    add_child(label)

    # Animation
    var tween := create_tween()
    tween.set_parallel(true)

    # Monte de 50 pixels
    tween.tween_property(label, "position:y", position.y - 50, 0.8)

    # Fade out après un délai
    tween.tween_property(label, "modulate:a", 0.0, 0.4).set_delay(0.4)

    # Scale up puis down pour effet "pop"
    tween.tween_property(label, "scale", Vector2(1.2, 1.2) * scale, 0.1)
    tween.tween_property(label, "scale", Vector2.ONE * scale, 0.1).set_delay(0.1)

    # Cleanup
    tween.chain().tween_callback(label.queue_free)
```

---

## Types de Texte Flottant

```gdscript
enum FloatingTextType {
    DAMAGE_DEALT,    # Blanc - dégâts infligés aux ennemis
    DAMAGE_TAKEN,    # Rouge - dégâts reçus par le héros
    HEAL,            # Vert - soins
    CURRENCY,        # Jaune - SC gagnés
    DODGE,           # Cyan - esquive
    CRITICAL,        # Orange/gros - coup critique
    OVERLOAD,        # Rouge/flash - action en overload
}

func _get_floating_text_config(type: FloatingTextType) -> Dictionary:
    match type:
        FloatingTextType.DAMAGE_DEALT:
            return {"color": Color.WHITE, "scale": 1.0, "prefix": "-"}
        FloatingTextType.DAMAGE_TAKEN:
            return {"color": Color.RED, "scale": 1.2, "prefix": "-"}
        FloatingTextType.HEAL:
            return {"color": Color.GREEN, "scale": 1.0, "prefix": "+"}
        FloatingTextType.CURRENCY:
            return {"color": Color.YELLOW, "scale": 0.8, "prefix": "+"}
        FloatingTextType.DODGE:
            return {"color": Color.CYAN, "scale": 1.0, "prefix": ""}
        FloatingTextType.CRITICAL:
            return {"color": Color.ORANGE, "scale": 1.5, "prefix": "CRIT! "}
        FloatingTextType.OVERLOAD:
            return {"color": Color.RED, "scale": 0.9, "prefix": ""}
    return {"color": Color.WHITE, "scale": 1.0, "prefix": ""}
```

---

## Utilisation

```gdscript
# Dégâts infligés à un ennemi
func _on_enemy_damaged(enemy: BaseEnemy, amount: int) -> void:
    _spawn_floating_text("-%d" % amount, enemy.global_position, Color.WHITE)

# Dégâts reçus par le héros
func _on_hero_damaged(amount: int) -> void:
    _spawn_floating_text("-%d" % amount, hero.global_position, Color.RED, 1.2)

# Soin
func _on_hero_healed(amount: int) -> void:
    _spawn_floating_text("+%d" % amount, hero.global_position, Color.GREEN)

# Esquive
func _on_hero_dodged() -> void:
    _spawn_floating_text("DODGE!", hero.global_position, Color.CYAN)

# SC gagné
func _on_currency_gained(amount: int) -> void:
    _spawn_floating_text("+%d SC" % amount, enemy.global_position, Color.YELLOW, 0.8)

# Action en overload
func _on_overload_action() -> void:
    _spawn_floating_text("OVERLOAD!", hero.global_position, Color.RED, 0.9)
```

---

## Layout Visuel

```
        -15     ← Dégâts infligés (blanc, monte)
         ↑
        👾      ← Ennemi


     +12 SC     ← SC gagné (jaune, plus petit)
         ↑


    DODGE!      ← Esquive (cyan)
        ↑
       👽       ← Héros

    -25         ← Dégâts reçus (rouge, plus gros)
```

---

## Variation pour Critiques

```gdscript
func _spawn_critical_text(amount: int, position: Vector2) -> void:
    # Effet plus dramatique
    var label := Label.new()
    label.text = "CRIT! -%d" % amount
    label.add_theme_font_size_override("font_size", 36)
    label.add_theme_color_override("font_color", Color.ORANGE)

    # Animation avec shake
    var tween := create_tween()
    tween.tween_property(label, "rotation", 0.1, 0.05)
    tween.tween_property(label, "rotation", -0.1, 0.05)
    tween.tween_property(label, "rotation", 0, 0.05)
    # ... reste de l'animation
```

---

## Tests de Validation

1. ✅ Texte apparaît à la bonne position
2. ✅ Animation monte + fade out
3. ✅ Couleurs correctes par type
4. ✅ Taille variable (crits plus gros)
5. ✅ Texte disparaît après animation

---

## Dépendances

- **Requiert**: Rien (UI standalone)
- **Utilisé par**: Combat system, tous les events
