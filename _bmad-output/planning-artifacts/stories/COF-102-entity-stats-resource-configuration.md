# COF-102: Entity Stats Resource Configuration

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/core/stats/entity_stats.gd`

---

## User Story

**En tant que** game designer,  
**Je veux** une Resource pour définir les stats de base,  
**Afin de** configurer chaque entité via l'Inspector sans code.

---

## Description

`EntityStats` est une Resource Godot (.tres) qui définit l'ADN statistique de chaque type d'entité. Elle ne doit jamais être modifiée à runtime - les valeurs sont copiées dans l'entité.

---

## Critères d'Acceptation

- [x] `display_name: String` - Nom d'affichage
- [x] `max_hp: int` - Range 1-10000
- [x] `attack: int` - Range 1-1000
- [x] `attack_speed: float` - Range 0.1-10.0 (attaques/seconde)
- [x] `defense: int` - Range 0-500
- [x] `crit_chance: float` - Range 0.0-1.0 (0-100%)
- [x] `crit_multiplier: float` - Range 1.0-5.0
- [x] `dodge_chance: float` - Range 0.0-0.95 (cap 95%)
- [x] `move_speed: float` - Range 0-500 pixels/s
- [x] Méthodes utilitaires :
  - `calculate_attack_damage(modifiers)`
  - `roll_critical(bonus)`
  - `roll_dodge(bonus)`
  - `get_attack_interval()`
  - `calculate_damage_taken(damage, defense_mod)`
  - `duplicate_for_runtime()`

---

## Implémentation

```gdscript
class_name EntityStats
extends Resource

@export var display_name: String = "Entity"
@export_range(1, 10000, 1) var max_hp: int = 100
@export_range(1, 1000, 1) var attack: int = 10
@export_range(0.1, 10.0, 0.1) var attack_speed: float = 1.0
@export_range(0, 500, 1) var defense: int = 0
@export_range(0.0, 1.0, 0.01) var crit_chance: float = 0.05
@export_range(1.0, 5.0, 0.1) var crit_multiplier: float = 1.5
@export_range(0.0, 1.0, 0.01) var dodge_chance: float = 0.05
@export_range(0.0, 500.0, 1.0) var move_speed: float = 100.0
```

---

## Formules de Calcul

### Dégâts infligés

```
final_attack = base_attack + additive_mods
final_attack *= multiplicative_mods
```

### Dégâts reçus

```
damage_taken = max(1, incoming_damage - total_defense)
```

### Intervalle d'attaque

```
interval = 1.0 / attack_speed
```

---

## Tests de Validation

1. ✅ Créer une Resource avec 100 HP, 10 ATK
2. ✅ `get_attack_interval()` avec speed 2.0 → 0.5s
3. ✅ `roll_critical()` avec 50% chance → ~50% succès sur 1000 essais
4. ✅ `calculate_damage_taken(50, 10)` → 40 dégâts

---

## Dépendances

- **Requiert**: Rien
- **Utilisé par**: `BaseEntity`, `AlienHero`, `BaseEnemy`
