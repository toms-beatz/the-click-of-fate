# COF-406: Statistics Tracking System

**Epic**: Save & Persistence  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scripts/autoload/save_manager.gd` (lignes 318-335)

---

## User Story

**En tant que** joueur,  
**Je veux** voir mes statistiques de jeu,  
**Afin de** suivre mes accomplissements et ma progression globale.

---

## Description

Le système de statistiques enregistre toutes les actions du joueur pour créer un historique de jeu : ennemis tués, morts, boss vaincus, temps de jeu, etc.

---

## Critères d'Acceptation

- [x] Statistiques trackées :
  - `total_kills` - Nombre total d'ennemis tués
  - `total_deaths` - Nombre de morts du joueur
  - `bosses_defeated` - Array des boss vaincus (IDs)
  - `play_time_seconds` - Temps de jeu total
  - `total_currency_earned` - SC total gagné (historique)
- [x] Méthodes :
  - `add_kills(count)` → void
  - `record_boss_defeated(boss_id)` → void
  - `add_play_time(seconds)` → void

---

## Implémentation

```gdscript
# Structure dans data
"statistics": {
    "total_kills": 0,
    "total_deaths": 0,
    "bosses_defeated": [],
    "play_time_seconds": 0,
    "total_currency_earned": 0
}

func add_kills(count: int) -> void:
    data["statistics"]["total_kills"] += count

func record_boss_defeated(boss_id: String) -> void:
    if boss_id not in data["statistics"]["bosses_defeated"]:
        data["statistics"]["bosses_defeated"].append(boss_id)
    save_game()

func add_play_time(seconds: int) -> void:
    data["statistics"]["play_time_seconds"] += seconds
```

---

## Intégration avec le Combat

```gdscript
# Dans GameCombatScene
func _on_enemy_died(enemy: BaseEnemy) -> void:
    SaveManager.add_kills(1)
    coins_earned_this_run += ENEMY_KILL_REWARD

func _on_boss_died() -> void:
    var boss_id := "boss_planet_%d" % current_planet
    SaveManager.record_boss_defeated(boss_id)

func _on_hero_died() -> void:
    # retry_level() incrémente déjà total_deaths
    pass
```

---

## Affichage des Statistiques

```gdscript
# Dans Profile Menu ou écran dédié
func _display_stats() -> void:
    var stats := SaveManager.data["statistics"]

    print("Total Kills: %d" % stats["total_kills"])
    print("Total Deaths: %d" % stats["total_deaths"])
    print("Bosses Defeated: %d / 4" % stats["bosses_defeated"].size())
    print("Play Time: %s" % _format_time(stats["play_time_seconds"]))
    print("Total SC Earned: %d" % stats["total_currency_earned"])

func _format_time(seconds: int) -> String:
    var hours := seconds / 3600
    var minutes := (seconds % 3600) / 60
    return "%dh %dm" % [hours, minutes]
```

---

## Boss IDs

| Boss             | ID            |
| ---------------- | ------------- |
| Mercury Guardian | boss_planet_0 |
| Venus Queen      | boss_planet_1 |
| Mars Warlord     | boss_planet_2 |
| DR. MORTIS       | boss_planet_3 |

---

## Utilisation Future

Ces statistiques peuvent servir pour :

- 🏆 Achievements ("Tuer 1000 ennemis")
- 📊 Leaderboards
- 📈 Écran de statistiques détaillées
- 🎮 Conditions de déblocage

---

## Tests de Validation

1. ✅ Tuer ennemi → `total_kills` +1
2. ✅ Mourir → `total_deaths` +1
3. ✅ Battre boss → ajouté à `bosses_defeated`
4. ✅ Boss déjà battu → pas de doublon
5. ✅ `total_currency_earned` augmente même si currency dépensée

---

## Dépendances

- **Requiert**: SaveManager structure (COF-401)
- **Utilisé par**: Profile Menu, Achievements (futur)
