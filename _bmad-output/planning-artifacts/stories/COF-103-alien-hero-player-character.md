# COF-103: Alien Hero Player Character

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/entities/alien_hero.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** un héros alien personnalisable,  
**Afin de** combattre les ennemis avec des skills et compagnons.

---

## Description

`AlienHero` est le personnage principal contrôlé indirectement par le joueur via les clics sur la zone tripartite. Il hérite de `BaseEntity` et ajoute le support des compagnons et des skills débloquables.

---

## Critères d'Acceptation

- [x] Hérite de `BaseEntity`
- [x] Système de compagnons :
  - `companions: Array[Node]`
  - `add_companion(companion)`
  - `remove_companion(companion)`
- [x] Système de skills :
  - `unlocked_skills: Array[String]`
  - `_skill_cooldowns: Dictionary`
  - `activate_skill(skill_id, cooldown)`
  - `unlock_skill(skill_id)`
  - `is_skill_ready(skill_id)`
  - `get_skill_cooldown(skill_id)`
- [x] Signaux :
  - `skill_used(skill_id: String)`
  - `companion_added(companion: Node)`
  - `boost_applied(boost_type: String)`
- [x] `apply_boost(type, value, duration)` pour les buffs temporaires

---

## Implémentation

```gdscript
class_name AlienHero
extends BaseEntity

signal skill_used(skill_id: String)
signal companion_added(companion: Node)
signal boost_applied(boost_type: String)

var companions: Array[Node] = []
var unlocked_skills: Array[String] = []
var _skill_cooldowns: Dictionary = {}

func add_companion(companion: Node) -> void:
    if companion not in companions:
        companions.append(companion)
        add_child(companion)
        companion_added.emit(companion)

func activate_skill(skill_id: String, cooldown: float) -> bool:
    if not is_skill_ready(skill_id) or skill_id not in unlocked_skills:
        return false
    _skill_cooldowns[skill_id] = cooldown
    skill_used.emit(skill_id)
    return true
```

---

## Stats de Base (MVP)

| Stat         | Valeur                      |
| ------------ | --------------------------- |
| HP           | 150 (scaled by progression) |
| Attack       | 12 (scaled by progression)  |
| Attack Speed | 1.5/s                       |
| Crit Chance  | 15%                         |
| Dodge Chance | 8%                          |

---

## Tests de Validation

1. ✅ Créer un héros, vérifier qu'il hérite de BaseEntity
2. ✅ Ajouter un compagnon → signal `companion_added` émis
3. ✅ Activer un skill non débloqué → retourne `false`
4. ✅ Débloquer puis activer un skill → retourne `true`, cooldown actif
5. ✅ Attendre cooldown → `is_skill_ready()` retourne `true`

---

## Dépendances

- **Requiert**: `BaseEntity` (COF-101), `EntityStats` (COF-102)
- **Utilisé par**: `CombatManager`, `GameCombatScene`
