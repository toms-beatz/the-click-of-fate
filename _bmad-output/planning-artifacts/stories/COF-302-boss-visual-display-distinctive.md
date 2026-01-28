# COF-302: Boss Visual Display Distinctive

**Epic**: Boss System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** voir le boss avec un visuel distinctif,  
**Afin de** comprendre immédiatement que c'est un combat spécial.

---

## Description

Les boss doivent être visuellement imposants et distinctifs par rapport aux ennemis normaux. Sprite plus grand, couleur unique, et emoji représentatif.

---

## Critères d'Acceptation

- [x] Sprite plus grand que les ennemis normaux (~1.5x)
- [x] Couleur unique correspondant à la planète
- [x] Emoji représentatif affiché
- [x] Animation d'apparition spéciale
- [x] Glow/outline pour distinction

---

## Implémentation

```gdscript
func _create_boss_visual(boss_data: Dictionary) -> void:
    var viewport_size: Vector2 = get_viewport().get_visible_rect().size

    # Container pour le boss (plus grand que les ennemis)
    boss_visual = Control.new()
    boss_visual.name = "BossVisual"

    # Taille du boss: 1.5x un ennemi normal
    var boss_size := mini(180, int(viewport_size.x * 0.25))

    # Glow derrière le boss
    var glow := ColorRect.new()
    glow.color = boss_data.color
    glow.color.a = 0.3
    glow.size = Vector2(boss_size + 40, boss_size + 40)
    glow.position = Vector2(-20, -20)
    boss_visual.add_child(glow)

    # Corps du boss
    var body := ColorRect.new()
    body.color = boss_data.color
    body.size = Vector2(boss_size, boss_size)
    boss_visual.add_child(body)

    # Emoji du boss
    var emoji_label := Label.new()
    emoji_label.text = boss_data.emoji
    emoji_label.add_theme_font_size_override("font_size", 48)
    emoji_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    emoji_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    boss_visual.add_child(emoji_label)

    enemy_container.add_child(boss_visual)
```

---

## Comparaison Visuelle

| Élément          | Ennemi Normal | Boss            |
| ---------------- | ------------- | --------------- |
| Taille           | 12% viewport  | 25% viewport    |
| Glow             | Non           | Oui (30% alpha) |
| Emoji            | Petit         | Grand (48px)    |
| Animation entrée | Fade in       | Shake + scale   |

---

## Couleurs par Boss

```
Mercury Guardian: Color(1.0, 0.5, 0.2)  # Orange vif
Venus Queen:      Color(0.8, 0.9, 0.2)  # Jaune-vert
Mars Warlord:     Color(0.9, 0.4, 0.3)  # Rouge sombre
DR. MORTIS:       Color(0.6, 0.2, 0.8)  # Violet sinistre
```

---

## Animation d'Apparition

```gdscript
func _animate_boss_entrance() -> void:
    boss_visual.modulate.a = 0.0
    boss_visual.scale = Vector2(0.5, 0.5)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(boss_visual, "modulate:a", 1.0, 0.5)
    tween.tween_property(boss_visual, "scale", Vector2(1.0, 1.0), 0.5)\
        .set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
```

---

## Tests de Validation

1. ✅ Boss spawn → visuel plus grand que les ennemis
2. ✅ Couleur correspond à la planète
3. ✅ Emoji affiché et lisible
4. ✅ Glow visible derrière le boss
5. ✅ Animation d'entrée smooth

---

## Dépendances

- **Requiert**: Boss Data (COF-301)
- **Utilisé par**: `GameCombatScene`
