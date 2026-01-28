# COF-108: Wave Controller Enemy Spawning

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/core/combat/wave_controller.gd`

---

## User Story

**En tant que** système de combat,  
**Je veux** un contrôleur de vagues,  
**Afin de** spawner les ennemis selon un timing et des patterns définis.

---

## Description

Le `WaveController` gère le spawning des ennemis pendant le combat. Il lit les données de `PlanetData` et `WaveData` pour savoir quand et quoi spawner.

---

## Critères d'Acceptation

- [x] Configuration via `PlanetData` Resource
- [x] Spawn avec :
  - Délai initial par groupe
  - Intervalle entre spawns
  - Nombre d'ennemis par groupe
- [x] Détection automatique de fin de vague (tous morts)
- [x] Transition vers phase boss après 5 vagues
- [x] Signaux :
  - `wave_started(wave_number)`
  - `wave_cleared()`
  - `enemy_spawned(enemy)`
  - `boss_phase_started()`

---

## Implémentation

```gdscript
class_name WaveController
extends Node

signal wave_started(wave_number: int)
signal wave_cleared()
signal enemy_spawned(enemy: BaseEnemy)
signal boss_phase_started()

@export var enemy_container: Node
@export var default_enemy_scene: PackedScene
@export var spawn_position: Vector2 = Vector2(500, 300)

var current_planet_data: PlanetData = null
var current_wave_index: int = 0
var active_enemies: Array[BaseEnemy] = []

func start_wave() -> void:
    if current_wave_index >= current_planet_data.waves.size():
        _start_boss_wave()
        return

    var wave_data := current_planet_data.waves[current_wave_index]
    wave_started.emit(wave_data.wave_number)

    if wave_data.start_delay > 0:
        await get_tree().create_timer(wave_data.start_delay).timeout

    _spawn_wave(wave_data)
```

---

## Configuration des Vagues

### Nombre d'ennemis par vague

```gdscript
const ENEMIES_PER_WAVE := [2, 3, 3, 4, 5]
```

### Scaling par vague

```gdscript
const WAVE_HP_SCALING := 1.15   # +15% HP par vague
const WAVE_ATK_SCALING := 1.1   # +10% ATK par vague
```

---

## Flow de Spawning

```
start_wave()
    │
    ├── wave < 5 ?
    │       │
    │       ▼
    │   spawn enemies with delays
    │       │
    │       ▼
    │   wait all enemies dead
    │       │
    │       ▼
    │   wave_cleared()
    │       │
    │       ▼
    │   current_wave_index++
    │       │
    │       └── loop
    │
    └── wave >= 5 ?
            │
            ▼
        boss_phase_started()
```

---

## Tests de Validation

1. ✅ `start_wave()` sur vague 1 → spawn 2 ennemis
2. ✅ Tuer tous les ennemis → signal `wave_cleared`
3. ✅ 5 vagues terminées → signal `boss_phase_started`
4. ✅ Délai entre spawns respecté
5. ✅ Ennemis positionnés côté droit

---

## Dépendances

- **Requiert**: `PlanetData` (COF-801), `WaveData` (COF-802), `BaseEnemy` (COF-201)
- **Utilisé par**: `GameCombatScene`
