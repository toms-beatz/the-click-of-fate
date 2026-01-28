# COF-106: Pressure Gauge Anti-Spam System

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/core/systems/pressure_gauge.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** un système de pression anti-spam,  
**Afin d'** être forcé à varier mes actions stratégiquement.

---

## Description

Le `PressureGauge` est le CŒUR du gameplay. Chaque action (Heal/Dodge/Attack) a sa propre jauge qui s'incrémente au clic. Si une jauge atteint 100, CETTE action est bloquée pendant une durée variable. Le decay automatique permet de récupérer.

---

## Critères d'Acceptation

- [x] 3 jauges séparées : Heal, Dodge, Attack
- [x] Incréments par clic :
  - Heal: +25 (le plus dangereux)
  - Dodge: +20
  - Attack: +8 (le plus léger)
- [x] Seuil d'overload : 100
- [x] Decay automatique : 5 points/seconde par jauge
- [x] Punition PAR ACTION (pas globale) :
  - Heal overload: 5s bloqué
  - Dodge overload: 4s bloqué
  - Attack overload: 3s bloqué
- [x] Signaux :
  - `pressure_changed(action_type, current_value)`
  - `punishment_started(duration)`
  - `punishment_ended()`
  - `action_blocked(action_type)`

---

## Implémentation

```gdscript
class_name PressureGauge
extends Node

const PRESSURE_INCREMENT := {
    &"heal": 25.0,
    &"dodge": 20.0,
    &"attack": 8.0
}

const PUNISHMENT_DURATION := {
    &"heal": 5.0,
    &"dodge": 4.0,
    &"attack": 3.0
}

const PRESSURE_THRESHOLD := 100.0
const DECAY_RATE := 5.0

var _pressures: Dictionary = {
    &"heal": 0.0,
    &"dodge": 0.0,
    &"attack": 0.0
}

var _blocked_actions: Dictionary = {
    &"heal": false,
    &"dodge": false,
    &"attack": false
}

func register_click(action_type: StringName) -> bool:
    if _blocked_actions.get(action_type, false):
        action_blocked.emit(action_type)
        return false

    _pressures[action_type] += PRESSURE_INCREMENT.get(action_type, 10.0)

    if _pressures[action_type] >= PRESSURE_THRESHOLD:
        _trigger_overload(action_type)

    pressure_changed.emit(action_type, _pressures[action_type])
    return true
```

---

## Stratégie de Jeu

### Exemple de rotation safe

```
HEAL → DODGE → ATTACK → ATTACK → ATTACK → HEAL → ...
       (decay pendant les attacks permet de re-heal)
```

### Piège à éviter

```
HEAL → HEAL → HEAL → HEAL → OVERLOAD! (5s sans heal)
```

---

## Visualisation des Jauges

```
HEAL   [████████░░░░░░░░░░░░] 40/100  (+25/clic)
DODGE  [██████░░░░░░░░░░░░░░] 30/100  (+20/clic)
ATTACK [████░░░░░░░░░░░░░░░░] 20/100  (+8/clic)

Decay: -5/seconde pour chaque jauge
```

---

## Tests de Validation

1. ✅ Clic HEAL 4x → jauge à 100, action bloquée
2. ✅ Attendre 5s → action HEAL débloquée
3. ✅ Decay de 5/s → jauge à 0 après 20s sans clic
4. ✅ Action bloquée → signal `action_blocked` émis
5. ✅ Autres actions restent disponibles pendant un overload

---

## Dépendances

- **Requiert**: Rien
- **Utilisé par**: `CombatManager` (COF-105), `ClickZoneButton` (COF-107)
