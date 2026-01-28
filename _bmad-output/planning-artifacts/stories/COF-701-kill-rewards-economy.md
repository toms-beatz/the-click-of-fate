# COF-701: Kill Rewards Economy

**Epic**: Economy  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** gagner des Solar Credits en tuant des ennemis,  
**Afin de** progresser et acheter des améliorations.

---

## Description

Chaque ennemi tué donne une récompense en SC. Les récompenses sont collectées pendant le run et confirmées à la victoire.

---

## Critères d'Acceptation

- [x] Kill ennemi normal = +8 SC
- [x] Kill boss = récompense de victoire incluse
- [x] Affichage "+X SC" en texte flottant
- [x] Compteur visible dans le HUD
- [x] SC confirmés seulement à la victoire

---

## Constantes

```gdscript
const ENEMY_KILL_REWARD := 8   # SC par kill
const WAVE_COMPLETE_REWARD := 25   # SC par vague terminée
const LEVEL_VICTORY_REWARD := 100  # SC pour victoire finale
```

---

## Implémentation

```gdscript
var coins_earned_this_run: int = 0
var enemies_killed_this_run: int = 0

func _on_enemy_killed(enemy: BaseEnemy) -> void:
    # Ajouter la récompense
    coins_earned_this_run += ENEMY_KILL_REWARD
    enemies_killed_this_run += 1

    # Statistiques
    SaveManager.add_kills(1)

    # Feedback visuel
    _spawn_floating_text("+%d SC" % ENEMY_KILL_REWARD,
        enemy.global_position, Color.YELLOW, 0.8)

    # Mettre à jour HUD
    _update_currency_display()

func _on_wave_completed(wave_number: int) -> void:
    coins_earned_this_run += WAVE_COMPLETE_REWARD

    # Feedback
    _spawn_floating_text("+%d SC Wave Bonus!" % WAVE_COMPLETE_REWARD,
        Vector2(360, 300), Color.GOLD, 1.2)

    _update_currency_display()

func _on_level_victory() -> void:
    coins_earned_this_run += LEVEL_VICTORY_REWARD

    # Confirmer tous les gains
    SaveManager.add_currency(coins_earned_this_run)

    _show_victory_screen()
```

---

## Flow de Récompenses

```
Combat Start
    │
    ├── start_session() → mémorise SC initial
    │
    ├── Kill Enemy → +8 SC (compteur local)
    │   └── texte flottant "+8 SC"
    │
    ├── Wave Complete → +25 SC
    │   └── texte flottant "+25 SC Wave Bonus!"
    │
    └── Outcome:
        │
        ├── VICTORY:
        │   └── add_currency(coins_earned_this_run)
        │       → SC confirmés définitivement
        │
        └── DEFEAT:
            └── restore_session_currency()
                → SC retournent au début de session
```

---

## Affichage HUD

```
┌────────────────────────────────────┐
│ [⏸️]    MERCURY     💰 +192 SC    │  ← Run en cours
│                                    │
│ Total: 1,234 SC                    │  ← Total confirmé
└────────────────────────────────────┘
```

---

## Calcul à la Victoire

```gdscript
func _calculate_victory_rewards() -> Dictionary:
    return {
        "wave_bonus": waves_completed * WAVE_COMPLETE_REWARD,
        "kill_bonus": enemies_killed_this_run * ENEMY_KILL_REWARD,
        "victory_bonus": LEVEL_VICTORY_REWARD,
        "total": coins_earned_this_run
    }

# Exemple pour Mercury (5 vagues, 24 kills):
# Wave bonus: 5 × 25 = 125 SC
# Kill bonus: 24 × 8 = 192 SC
# Victory: 100 SC
# TOTAL: 417 SC
```

---

## Tests de Validation

1. ✅ Kill ennemi → +8 SC affiché
2. ✅ Vague terminée → +25 SC bonus
3. ✅ Victoire → SC ajoutés au compte
4. ✅ Défaite → SC NON ajoutés
5. ✅ HUD mis à jour en temps réel

---

## Dépendances

- **Requiert**: SaveManager currency (COF-402)
- **Utilisé par**: Combat, Victory Screen
