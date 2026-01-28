# COF-607: Victory Screen Display

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur ayant terminé un niveau,  
**Je veux** voir un écran de victoire,  
**Afin de** célébrer et voir mes récompenses.

---

## Description

L'écran de victoire s'affiche après avoir battu le boss d'une planète. Il montre les récompenses et permet de continuer ou retourner au menu.

---

## Critères d'Acceptation

- [x] Titre "VICTORY! 🎉"
- [x] Affichage des récompenses (SC gagnés)
- [x] Statistiques du niveau (kills, temps)
- [x] Bouton "Continue" → planète suivante
- [x] Bouton "Menu" → retour au menu principal

---

## Implémentation

```gdscript
func _show_victory_screen() -> void:
    # Calculer les récompenses
    var wave_rewards := waves_completed * WAVE_COMPLETE_REWARD  # 25 SC × vagues
    var kill_rewards := enemies_killed_this_run * ENEMY_KILL_REWARD  # 8 SC × kills
    var boss_reward := BOSS_KILL_REWARD  # 100 SC
    var total_rewards := wave_rewards + kill_rewards + boss_reward

    # Ajouter les récompenses
    SaveManager.add_currency(total_rewards)

    # Avancer la progression
    SaveManager.advance_planet()

    # Créer l'UI
    _create_victory_ui(total_rewards, {
        "waves": wave_rewards,
        "kills": kill_rewards,
        "boss": boss_reward,
        "enemies_killed": enemies_killed_this_run,
        "time": combat_time
    })

func _create_victory_ui(total: int, details: Dictionary) -> void:
    var victory_layer := CanvasLayer.new()
    victory_layer.layer = 100
    add_child(victory_layer)

    # Overlay
    var overlay := ColorRect.new()
    overlay.color = Color(0, 0.3, 0, 0.85)  # Vert sombre
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    victory_layer.add_child(overlay)

    var content := VBoxContainer.new()
    content.set_anchors_preset(Control.PRESET_CENTER)

    # Titre
    var title := Label.new()
    title.text = "🎉 VICTORY! 🎉"
    title.add_theme_font_size_override("font_size", 40)
    content.add_child(title)

    # Détails récompenses
    var rewards_text := """
    Waves Cleared: +%d SC
    Enemies Killed (%d): +%d SC
    Boss Defeated: +%d SC
    ─────────────────
    TOTAL: +%d SC
    """ % [details.waves, details.enemies_killed, details.kills, details.boss, total]

    var rewards_label := Label.new()
    rewards_label.text = rewards_text
    content.add_child(rewards_label)

    # Boutons
    var continue_btn := Button.new()
    continue_btn.text = "▶️ Continue to Next Planet"
    continue_btn.pressed.connect(_continue_to_next_planet)

    var menu_btn := Button.new()
    menu_btn.text = "🏠 Main Menu"
    menu_btn.pressed.connect(_return_to_menu)

    content.add_child(continue_btn)
    content.add_child(menu_btn)

    victory_layer.add_child(content)
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│                                    │
│       🎉 VICTORY! 🎉               │
│                                    │
│    PLANET MERCURY CLEARED!         │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  REWARDS                     │  │
│  │  ───────────────────────     │  │
│  │  Waves Cleared:      +125 SC │  │
│  │  Enemies Killed (24): +192 SC│  │
│  │  Boss Defeated:      +100 SC │  │
│  │  ───────────────────────     │  │
│  │  TOTAL:             +417 SC  │  │
│  └──────────────────────────────┘  │
│                                    │
│    Time: 3:45                      │
│                                    │
│   ┌──────────────────────────┐     │
│   │  ▶️ Continue to Venus    │     │
│   └──────────────────────────┘     │
│   ┌──────────────────────────┐     │
│   │      🏠 Main Menu        │     │
│   └──────────────────────────┘     │
│                                    │
└────────────────────────────────────┘
```

---

## Récompenses de Victoire

| Source                           | Montant    |
| -------------------------------- | ---------- |
| Par vague                        | +25 SC     |
| Par kill                         | +8 SC      |
| Boss                             | +100 SC    |
| **Exemple (5 vagues, 24 kills)** | **417 SC** |

---

## Animations (Optionnelles)

```gdscript
# Confettis ou particules
func _spawn_confetti() -> void:
    var particles := CPUParticles2D.new()
    particles.emitting = true
    particles.amount = 50
    particles.gravity = Vector2(0, 100)
    # ... configuration confettis
```

---

## Tests de Validation

1. ✅ Boss battu → écran victoire affiché
2. ✅ Récompenses calculées correctement
3. ✅ SC ajoutés au compte
4. ✅ Continue → charge planète suivante
5. ✅ Dernière planète (Earth) → écran spécial

---

## Dépendances

- **Requiert**: SaveManager progression (COF-403)
- **Utilisé par**: GameCombatScene après victoire boss
