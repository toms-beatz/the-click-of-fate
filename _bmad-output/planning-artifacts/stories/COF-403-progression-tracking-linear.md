# COF-403: Progression Tracking Linear

**Epic**: Save & Persistence  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/autoload/save_manager.gd` (lignes 240-280)

---

## User Story

**En tant que** joueur,  
**Je veux** que ma progression soit linéaire,  
**Afin de** ne pas perdre d'avancement à la mort.

---

## Description

Le jeu utilise une progression linéaire : le joueur ne perd JAMAIS de niveau. À la mort, il recommence la planète mais garde tout son équipement, upgrades et monnaie (avant la session).

---

## Critères d'Acceptation

- [x] `current_planet: int` - Index 0-3 (Mercury → Earth)
- [x] `current_wave: int` - Index 0-5 (5 vagues + boss)
- [x] `highest_planet_completed: int` - -1 à 3 (pour débloquer planètes)
- [x] Méthodes :
  - `get_current_planet()` → int
  - `get_current_wave()` → int
  - `get_highest_planet_completed()` → int
  - `advance_wave()` - Passe à la vague suivante
  - `advance_planet()` - Termine la planète, passe à la suivante
  - `retry_level()` - Recommence la planète (garde tout)

---

## Implémentation

```gdscript
func get_current_planet() -> int:
    return data.get("current_planet", 0)

func get_current_wave() -> int:
    return data.get("current_wave", 0)

func get_highest_planet_completed() -> int:
    return data.get("highest_planet_completed", -1)

func advance_wave() -> void:
    data["current_wave"] = get_current_wave() + 1
    progression_changed.emit()
    save_game()

func advance_planet() -> void:
    var current := get_current_planet()
    data["highest_planet_completed"] = maxi(data["highest_planet_completed"], current)
    data["current_planet"] = mini(current + 1, 3)  # Max 4 planètes
    data["current_wave"] = 0
    progression_changed.emit()
    save_game()

func retry_level() -> void:
    data["current_wave"] = 0  # Recommence la planète
    data["statistics"]["total_deaths"] += 1
    progression_changed.emit()
    save_game()
```

---

## Flow de Progression

```
Nouvelle partie
    │
    ▼
Planet 0 (Mercury), Wave 0
    │
    ├── Kill all enemies → advance_wave()
    │   Wave 1, 2, 3, 4, 5
    │
    ├── Beat boss → advance_planet()
    │   highest_completed = 0
    │   current_planet = 1 (Venus)
    │   current_wave = 0
    │
    ├── Die on Venus → retry_level()
    │   current_wave = 0
    │   (keep currency, upgrades, etc.)
    │
    └── ...repeat until Earth boss beaten
```

---

## Déblocage des Planètes

```gdscript
# Dans LevelSelect
var highest_completed := SaveManager.get_highest_planet_completed()

for planet_index in range(4):
    var is_unlocked := planet_index <= highest_completed + 1
    # Planet 0 toujours dispo
    # Planet 1 dispo si 0 complétée
    # etc.
```

---

## Philosophie de Design

> "Le joueur ne perd JAMAIS rien d'important."

- ✅ Monnaie gagnée sur les niveaux réussis : GARDÉE
- ✅ Upgrades achetés : GARDÉS
- ✅ Équipement : GARDÉ
- ✅ Planètes débloquées : GARDÉES
- ⚠️ Monnaie de la session en cours sur défaite : RESTAURÉE

---

## Tests de Validation

1. ✅ Nouvelle partie → planet 0, wave 0
2. ✅ `advance_wave()` 6x → wave devient 6 (boss)
3. ✅ `advance_planet()` → planet 1, wave 0, highest = 0
4. ✅ `retry_level()` → wave 0, planet inchangée
5. ✅ Planet 2 verrouillée si highest_completed < 1

---

## Dépendances

- **Requiert**: SaveManager structure (COF-401)
- **Utilisé par**: LevelSelect, Combat, menus
