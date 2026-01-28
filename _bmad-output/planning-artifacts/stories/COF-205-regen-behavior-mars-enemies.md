# COF-205: Regen Behavior Mars Enemies

**Epic**: Enemy System  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scripts/entities/behaviors/regen_behavior.gd`

---

## User Story

**En tant que** joueur sur Mars,  
**Je veux** affronter des ennemis régénérants,  
**Afin de** maintenir une pression constante sur eux.

---

## Description

Les ennemis de Mars sont des "Regens" qui récupèrent 1% de leurs PV max chaque seconde. Le joueur doit infliger des dégâts soutenus pour les tuer.

---

## Critères d'Acceptation

- [x] Régénération: 1% max HP par seconde
- [x] Stats normales (pas de modification initiale)
- [x] `behavior_name = "Regen (Mars)"`
- [x] Accumulateur pour éviter heal chaque frame

---

## Implémentation

```gdscript
class_name RegenBehavior
extends EnemyBehavior

const REGEN_PERCENT_PER_SEC := 0.01

var _regen_accumulator: float = 0.0

func _init() -> void:
    behavior_name = "Regen (Mars)"

func apply(enemy: BaseEnemy) -> void:
    # Stats normales
    pass

func process(enemy: BaseEnemy, delta: float) -> void:
    if not enemy.is_alive or not enemy.base_stats:
        return

    _regen_accumulator += delta

    if _regen_accumulator >= 1.0:
        _regen_accumulator -= 1.0

        # Régénérer 1% des PV max
        var regen_amount := int(enemy.base_stats.max_hp * REGEN_PERCENT_PER_SEC)
        if regen_amount > 0:
            enemy.heal(regen_amount)
```

---

## Caractéristiques de Gameplay

### Points Forts

- Récupère constamment des PV
- Combat prolongé si pas de DPS
- Force l'agressivité

### Points Faibles

- Stats de base normales
- Régénération faible face au burst

### Stratégie du Joueur

- ACTION ATTACK prioritaire
- Maintenir la pression
- Ne pas laisser traîner le combat

---

## Calcul de la Régénération

```
Enemy Max HP: 60
Regen/sec: 60 × 0.01 = 0.6 → 0 HP (int)

Enemy Max HP: 100
Regen/sec: 100 × 0.01 = 1 HP

En 10 secondes: +10 HP récupérés
```

---

## Pourquoi l'Accumulateur ?

Sans accumulateur, on appellerait `heal()` 60 fois par seconde avec des valeurs minuscules. L'accumulateur permet :

- Moins d'appels (1/seconde)
- Valeurs de heal significatives
- Meilleure performance

---

## Tests de Validation

1. ✅ Ennemi Mars créé → comportement Regen actif
2. ✅ Après 1s → HP augmente de ~1%
3. ✅ Ennemi mort → pas de régénération
4. ✅ `behavior_name` = "Regen (Mars)"

---

## Dépendances

- **Requiert**: `EnemyBehavior` (COF-202)
- **Utilisé par**: `BaseEnemy` sur Mars
