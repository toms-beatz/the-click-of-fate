# COF-101: Base Entity Class for All Combat Units

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/core/entities/base_entity.gd`

---

## User Story

**En tant que** système de combat,  
**Je veux** une classe de base pour toutes les entités,  
**Afin de** gérer PV, attaque, défense, esquive et mort de manière uniforme.

---

## Description

`BaseEntity` est la classe mère héritée par le héros, les ennemis et les boss. Elle centralise toute la logique commune de combat : points de vie, dégâts, soins, mort, et auto-attaque.

---

## Critères d'Acceptation

- [x] Classe `BaseEntity` extends `Node2D`
- [x] Signaux émis :
  - `damaged(amount: int, is_crit: bool)`
  - `healed(amount: int)`
  - `died()`
  - `attacked(target: BaseEntity, damage: int, is_crit: bool)`
  - `dodged()`
  - `hp_changed(current: int, max_hp: int)`
- [x] Propriétés :
  - `current_hp: int`
  - `is_alive: bool`
  - `can_act: bool`
  - `current_target: BaseEntity`
  - `base_stats: EntityStats` (Resource)
- [x] Auto-attaque sur la cible courante basée sur `attack_speed`
- [x] Système de modificateurs temporaires (buffs/debuffs)
- [x] Méthodes publiques :
  - `take_damage(amount, is_crit)`
  - `heal(amount)`
  - `heal_percent(percent)`
  - `perform_attack(target)`
  - `reset()`
  - `add_temp_modifier(stat, value, type, duration)`

---

## Implémentation

```gdscript
class_name BaseEntity
extends Node2D

signal damaged(amount: int, is_crit: bool)
signal healed(amount: int)
signal died()
signal attacked(target: BaseEntity, damage: int, is_crit: bool)
signal dodged()
signal hp_changed(current: int, max_hp: int)

@export var base_stats: EntityStats
var current_hp: int = 0
var is_alive: bool = true
var can_act: bool = true
var current_target: BaseEntity = null
var _temp_modifiers: Dictionary = {}
var _attack_timer: float = 0.0
```

---

## Tests de Validation

1. ✅ Créer une entité avec 100 HP
2. ✅ Infliger 30 dégâts → HP = 70, signal `damaged` émis
3. ✅ Soigner de 20 → HP = 90, signal `healed` émis
4. ✅ Infliger 100 dégâts → HP = 0, `is_alive = false`, signal `died` émis
5. ✅ Auto-attaque cible toutes les X secondes selon `attack_speed`

---

## Dépendances

- **Requiert**: `EntityStats` Resource (COF-102)
- **Utilisé par**: `AlienHero`, `BaseEnemy`, tous les combattants
