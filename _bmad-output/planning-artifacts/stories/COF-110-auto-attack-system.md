# COF-110: Auto-Attack System

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/core/entities/base_entity.gd` (lignes 82-96)

---

## User Story

**En tant que** spectateur d'auto-battler,  
**Je veux** que le héros attaque automatiquement,  
**Afin de** me concentrer sur les actions tactiques (Heal/Dodge/Attack).

---

## Description

L'auto-attaque est le cœur du gameplay "auto-battler". Le héros et les ennemis attaquent automatiquement leur cible à intervalles réguliers basés sur leur `attack_speed`.

---

## Critères d'Acceptation

- [x] Timer interne basé sur `attack_speed`
- [x] Attaque automatique sur `current_target` quand vivant
- [x] Émission du signal `attacked(target, damage, is_crit)`
- [x] Support des modificateurs de crit/esquive
- [x] Arrêt si `can_act = false` ou `is_alive = false`
- [x] Arrêt si cible morte

---

## Implémentation

```gdscript
var _attack_timer: float = 0.0

func _process(delta: float) -> void:
    if not is_alive or not can_act:
        return

    _update_modifiers(delta)
    _process_auto_attack(delta)

func _process_auto_attack(delta: float) -> void:
    if not current_target or not current_target.is_alive:
        return

    if not base_stats:
        return

    _attack_timer += delta
    var attack_interval := base_stats.get_attack_interval()

    if _attack_timer >= attack_interval:
        _attack_timer = 0.0
        perform_attack(current_target)

func perform_attack(target: BaseEntity) -> void:
    if not target or not target.is_alive:
        return

    var damage := base_stats.calculate_attack_damage(_get_attack_modifiers())
    var is_crit := base_stats.roll_critical(_get_crit_bonus())

    if is_crit:
        damage = int(damage * base_stats.crit_multiplier)

    target.take_damage(damage, is_crit)
    attacked.emit(target, damage, is_crit)
```

---

## Calcul de l'Intervalle

```
attack_speed = 1.5 attaques/seconde
attack_interval = 1.0 / 1.5 = 0.667 secondes

Chaque 0.667s, une attaque est effectuée.
```

---

## Flow d'une Attaque

```
_process_auto_attack()
    │
    ├── target existe et vivant ?
    │       │ non → return
    │       │ oui ↓
    │
    ├── timer >= interval ?
    │       │ non → return
    │       │ oui ↓
    │
    ├── reset timer
    │
    ├── calculer dégâts + mods
    │
    ├── roll crit ?
    │       │ oui → damage × crit_multiplier
    │       │ non → damage normal
    │
    ├── target.take_damage(damage, is_crit)
    │
    └── attacked.emit(target, damage, is_crit)
```

---

## Tests de Validation

1. ✅ Hero avec attack_speed 1.5 → attaque toutes les ~0.67s
2. ✅ Ennemi mort → hero arrête d'attaquer
3. ✅ Hero mort → plus d'auto-attaque
4. ✅ Crit appliqué correctement (×1.5 par défaut)
5. ✅ Signal `attacked` émis à chaque attaque

---

## Dépendances

- **Requiert**: `EntityStats` (COF-102)
- **Utilisé par**: `AlienHero`, `BaseEnemy`, tout combattant
