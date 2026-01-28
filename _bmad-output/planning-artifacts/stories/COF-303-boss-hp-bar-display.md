# COF-303: Boss HP Bar Display

**Epic**: Boss System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** une barre de vie visible pour le boss,  
**Afin de** suivre ma progression dans le combat.

---

## Description

La barre de vie du boss doit être proéminente et montrer clairement les PV restants. Elle utilise la couleur de la planète et doit s'initialiser avec max_hp (pas current_hp).

---

## Critères d'Acceptation

- [x] Barre affichant `max_hp` au spawn (pas current_hp)
- [x] Couleur correspondant à la planète
- [x] Mise à jour en temps réel quand le boss prend des dégâts
- [x] Position visible (sous le boss ou en haut de l'écran)
- [x] Largeur plus grande que les barres d'ennemis normaux

---

## Implémentation

```gdscript
var boss_hp_bar: ProgressBar

func _create_boss_hp_bar(boss_data: Dictionary) -> void:
    var viewport_size: Vector2 = get_viewport().get_visible_rect().size

    # Barre de vie du boss (pleine largeur)
    boss_hp_bar = ProgressBar.new()
    boss_hp_bar.name = "BossHPBar"
    boss_hp_bar.custom_minimum_size = Vector2(viewport_size.x * 0.6, 20)
    boss_hp_bar.max_value = boss_data.hp  # IMPORTANT: utiliser max_hp, pas current_hp
    boss_hp_bar.value = boss_data.hp
    boss_hp_bar.show_percentage = false

    # Style avec couleur du boss
    var style := StyleBoxFlat.new()
    style.bg_color = boss_data.color
    style.corner_radius_top_left = 4
    style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4
    style.corner_radius_bottom_right = 4
    boss_hp_bar.add_theme_stylebox_override("fill", style)

    # Background sombre
    var bg_style := StyleBoxFlat.new()
    bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
    boss_hp_bar.add_theme_stylebox_override("background", bg_style)

    hud_layer.add_child(boss_hp_bar)

func _update_boss_hp(current_hp: int) -> void:
    if boss_hp_bar:
        boss_hp_bar.value = current_hp
```

---

## Bug Corrigé : HP Bar à 0 au spawn

### Problème

```gdscript
# MAUVAIS: current_hp peut être à 0 si l'entité vient d'être créée
boss_hp_bar.max_value = current_boss.current_hp
```

### Solution

```gdscript
# CORRECT: utiliser max_hp depuis les données de config
boss_hp_bar.max_value = boss_data.hp  # ou current_boss.base_stats.max_hp
boss_hp_bar.value = boss_data.hp
```

---

## Position de la Barre

```
┌────────────────────────────────────┐
│ 👽 HERO     🪐 EARTH     BOSS 💀  │
│ [████████]   ⚔️ BOSS    [████████]│  <- HP Bars
│                                    │
│                                    │
│    🦸              💀              │
│   HERO            BOSS             │
│                                    │
│ ════════════════════════════════   │  <- Boss HP Bar (grande)
│                                    │
└────────────────────────────────────┘
```

---

## Tests de Validation

1. ✅ Boss spawn → HP bar à 100% (pas 0%)
2. ✅ Boss prend 100 dégâts → barre diminue proportionnellement
3. ✅ Couleur de la barre = couleur du boss
4. ✅ Barre visible clairement pendant tout le combat

---

## Dépendances

- **Requiert**: Boss Data (COF-301), Boss Visual (COF-302)
- **Utilisé par**: `GameCombatScene`
