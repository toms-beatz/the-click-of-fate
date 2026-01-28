# COF-201: Base Enemy Entity Class

**Epic**: Enemy System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/entities/base_enemy.gd`

---

## User Story

**En tant que** système de combat,  
**Je veux** une classe de base pour les ennemis,  
**Afin de** créer des variantes par planète avec comportements uniques.

---

## Description

`BaseEnemy` hérite de `BaseEntity` et ajoute les spécificités des ennemis : type de planète d'origine, valeur de loot, et comportement automatique selon la planète.

---

## Critères d'Acceptation

- [x] Hérite de `BaseEntity`
- [x] Enum `PlanetType` : MERCURY, VENUS, MARS, EARTH
- [x] `loot_value: int` - Récompense SC à la mort
- [x] `behavior: EnemyBehavior` - Comportement selon planète
- [x] Application automatique du comportement à `_ready()`
- [x] Signal `died` connecté au système de loot

---

## Implémentation

```gdscript
class_name BaseEnemy
extends BaseEntity

enum PlanetType { MERCURY, VENUS, MARS, EARTH }

@export var planet_type: PlanetType = PlanetType.MERCURY
@export var loot_value: int = 5

var behavior: EnemyBehavior = null

func _ready() -> void:
    super._ready()
    _apply_planet_behavior()

func _process(delta: float) -> void:
    super._process(delta)
    if behavior and is_alive:
        behavior.process(self, delta)

func _apply_planet_behavior() -> void:
    match planet_type:
        PlanetType.MERCURY:
            behavior = FastBehavior.new()
        PlanetType.VENUS:
            behavior = ToxicBehavior.new()
        PlanetType.MARS:
            behavior = RegenBehavior.new()
        PlanetType.EARTH:
            behavior = TankBehavior.new()

    if behavior:
        behavior.apply(self)
```

---

## Comportements par Planète

| Planète | Comportement  | Caractéristique            |
| ------- | ------------- | -------------------------- |
| Mercury | FastBehavior  | Rapide, fragile, esquiveur |
| Venus   | ToxicBehavior | Poison sur hit             |
| Mars    | RegenBehavior | Régénération 1%/s          |
| Earth   | TankBehavior  | Tank avec haute défense    |

---

## Valeurs de Loot

```gdscript
const ENEMY_KILL_REWARD := 8  # SC par ennemi tué
```

---

## Tests de Validation

1. ✅ Créer ennemi Mercury → `FastBehavior` appliqué
2. ✅ Créer ennemi Venus → `ToxicBehavior` appliqué
3. ✅ Ennemi meurt → `loot_value` récupérable
4. ✅ Comportement `.process()` appelé chaque frame

---

## Dépendances

- **Requiert**: `BaseEntity` (COF-101), `EnemyBehavior` (COF-202)
- **Utilisé par**: `WaveController`, `GameCombatScene`
