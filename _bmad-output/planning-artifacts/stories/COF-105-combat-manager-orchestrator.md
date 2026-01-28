# COF-105: Combat Manager Orchestrator

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/core/combat/combat_manager.gd`

---

## User Story

**En tant que** système de combat,  
**Je veux** un orchestrateur central,  
**Afin de** coordonner les actions joueur et l'auto-combat.

---

## Description

`CombatManager` est le chef d'orchestre du combat. Il reçoit les inputs du joueur (via ClickZoneButton), vérifie avec la PressureGauge, exécute les actions, et coordonne le héros avec les ennemis.

---

## Critères d'Acceptation

- [x] Constantes d'actions :
  - `BASE_HEAL_PERCENT = 0.13` (13% des PV max)
  - `BASE_DODGE_BONUS = 0.20` (+20% esquive)
  - `DODGE_BUFF_DURATION = 4.0` secondes
  - `BASE_ATTACK_DAMAGE = 10` dégâts directs
  - `ATTACK_CLICK_CRIT_BONUS = 0.10` (+10% crit)
- [x] Connexion avec `ClickZoneButton`, `PressureGauge`, `StateMachine`
- [x] Actions :
  - `_do_heal()` - Soigne le héros de 13% max HP
  - `_do_dodge()` - +20% esquive pendant 4s
  - `_do_attack()` - +10% crit 2s + 10 dégâts directs à l'ennemi
- [x] Gestion de la liste `active_enemies`
- [x] Signaux :
  - `player_action(action, success)`
  - `critical_hit(damage)`
  - `dodge_success()`
  - `hero_healed(amount)`
  - `hero_pose_changed(pose_name, duration)`

---

## Implémentation

```gdscript
class_name CombatManager
extends Node

const BASE_HEAL_PERCENT := 0.13
const BASE_DODGE_BONUS := 0.20
const BASE_ATTACK_DAMAGE := 10
const DODGE_BUFF_DURATION := 4.0
const ATTACK_CLICK_CRIT_BONUS := 0.10

@export var state_machine: CombatStateMachine
@export var pressure_gauge: PressureGauge
@export var hero: BaseEntity

var active_enemies: Array[BaseEntity] = []

func _on_zone_pressed(zone: StringName) -> void:
    if not state_machine or not state_machine.can_player_act():
        return

    var accepted := pressure_gauge.register_click(zone)
    if accepted:
        _execute_action(zone)
        player_action.emit(zone, true)
    else:
        player_action.emit(zone, false)
```

---

## Flow des Actions

### HEAL

```
1. Joueur touche zone HEAL
2. PressureGauge.register_click("heal") → accepted?
3. Si oui: hero.heal_percent(0.13)
4. Signal hero_healed émis
5. Pose "special" pendant 0.5s
```

### DODGE

```
1. Joueur touche zone DODGE
2. PressureGauge.register_click("dodge") → accepted?
3. Si oui: hero.add_temp_modifier("dodge_chance", 0.20, "add", 4.0)
4. Pose "dodge" pendant 0.4s
```

### ATTACK

```
1. Joueur touche zone ATTACK
2. PressureGauge.register_click("attack") → accepted?
3. Si oui:
   - hero.add_temp_modifier("crit_chance", 0.10, "add", 2.0)
   - first_enemy.take_damage(10, false)
4. Pose random "attack_1/2/3" pendant 0.35s
```

---

## Tests de Validation

1. ✅ Clic HEAL → héros soigné de ~13% max HP
2. ✅ Clic DODGE → esquive augmentée pendant 4s
3. ✅ Clic ATTACK → ennemi prend 10 dégâts + crit bonus actif
4. ✅ Action refusée par PressureGauge → signal `player_action(_, false)`

---

## Dépendances

- **Requiert**: `CombatStateMachine` (COF-104), `PressureGauge` (COF-106), `AlienHero` (COF-103)
- **Utilisé par**: `GameCombatScene`
