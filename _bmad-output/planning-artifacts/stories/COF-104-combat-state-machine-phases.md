# COF-104: Combat State Machine Phases

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/core/combat/combat_state_machine.gd`

---

## User Story

**En tant que** système de combat,  
**Je veux** une machine à états,  
**Afin de** gérer les différentes phases du combat clairement.

---

## Description

`CombatStateMachine` gère les transitions entre les phases du combat : attente, combat actif, phase boss, punition, victoire et défaite.

---

## Critères d'Acceptation

- [x] Enum `State` avec les états :
  - `IDLE` - Attente avant/après combat
  - `COMBAT` - Combat actif contre vague normale
  - `BOSS_PHASE` - Combat contre le boss
  - `PUNISHED` - Joueur puni (jauge de pression)
  - `VICTORY` - Victoire de la vague/niveau
  - `DEFEAT` - Défaite (retry avec ressources)
- [x] Signaux :
  - `state_changed(old_state, new_state)`
  - `combat_started()`
  - `wave_completed(wave_number)`
  - `boss_defeated()`
  - `victory()`
  - `defeat()`
- [x] Constante `WAVES_PER_PLANET = 5`
- [x] Méthodes :
  - `start_combat()`
  - `start_boss_phase()`
  - `on_wave_cleared()`
  - `on_player_defeated()`
  - `can_player_act()` → bool

---

## Diagramme d'États

```
    ┌─────────────────────────────────────┐
    │                                     │
    v                                     │
  IDLE ──start_combat()──> COMBAT ──────┬─┤
    ^                         │         │ │
    │                         │         │ │
    │              on_wave_cleared()    │ │
    │                         │         │ │
    │                         v         │ │
    │                   [wave < 5?]     │ │
    │                    yes│   │no     │ │
    │                       │   │       │ │
    │                       │   v       │ │
    │                       │ BOSS_PHASE│ │
    │                       │     │     │ │
    │                       │     v     │ │
    │                       │ boss_died │ │
    │                       │     │     │ │
    │                       v     v     │ │
    │                     VICTORY ──────┘ │
    │                                     │
    └──────────── DEFEAT <────────────────┘
                    │
                    v
              (retry → IDLE)
```

---

## Implémentation

```gdscript
class_name CombatStateMachine
extends Node

enum State { IDLE, COMBAT, BOSS_PHASE, PUNISHED, VICTORY, DEFEAT }

signal state_changed(old_state: State, new_state: State)
signal combat_started()
signal wave_completed(wave_number: int)
signal boss_defeated()
signal victory()
signal defeat()

var current_state: State = State.IDLE
var current_wave: int = 0
const WAVES_PER_PLANET: int = 5

func can_player_act() -> bool:
    return current_state in [State.COMBAT, State.BOSS_PHASE]
```

---

## Tests de Validation

1. ✅ État initial = IDLE
2. ✅ `start_combat()` → COMBAT, signal `combat_started`
3. ✅ `on_wave_cleared()` 5 fois → VICTORY puis possibilité BOSS_PHASE
4. ✅ Boss vaincu → VICTORY, signal `boss_defeated`
5. ✅ Hero mort → DEFEAT, signal `defeat`

---

## Dépendances

- **Requiert**: `PressureGauge` (COF-106) pour connexion optionnelle
- **Utilisé par**: `CombatManager`, `GameCombatScene`
