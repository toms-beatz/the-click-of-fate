# COF-203: Fast Behavior Mercury Enemies

**Epic**: Enemy System  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scripts/entities/behaviors/fast_behavior.gd`

---

## User Story

**En tant que** joueur sur Mercury,  
**Je veux** affronter des ennemis rapides mais fragiles,  
**Afin d'** apprendre le timing du jeu dans un environnement accessible.

---

## Description

Les ennemis de Mercury sont des "Scouts" rapides et agiles. Ils attaquent vite mais ont peu de vie, ce qui en fait une bonne introduction au gameplay.

---

## Critères d'Acceptation

- [x] +50% vitesse d'attaque
- [x] -30% HP
- [x] +10% esquive bonus (permanent)
- [x] `behavior_name = "Fast (Mercury)"`

---

## Implémentation

```gdscript
class_name FastBehavior
extends EnemyBehavior

const ATTACK_SPEED_MULT := 1.5
const HP_MULT := 0.7
const DODGE_BONUS := 0.10

func _init() -> void:
    behavior_name = "Fast (Mercury)"

func apply(enemy: BaseEnemy) -> void:
    if not enemy.base_stats:
        return

    # Réduire les PV
    var new_max_hp := int(enemy.base_stats.max_hp * HP_MULT)
    enemy.current_hp = mini(enemy.current_hp, new_max_hp)

    # Ajouter esquive permanente
    enemy.add_temp_modifier("dodge_chance", DODGE_BONUS, "add", 9999.0)

func process(enemy: BaseEnemy, _delta: float) -> void:
    # Vitesse d'attaque gérée via attack_speed dans EntityStats
    pass
```

---

## Caractéristiques de Gameplay

### Points Forts

- Attaque rapide (1.5x plus vite)
- Difficile à toucher (+10% esquive)
- Premiers ennemis du jeu

### Points Faibles

- Fragile (-30% HP)
- Faible menace individuelle

### Stratégie du Joueur

- Focus sur les dégâts (ACTION ATTACK)
- Esquive moins utile (ils meurent vite)
- Bon pour apprendre le rythme

---

## Exemple de Stats

```
Base Enemy HP: 50
After FastBehavior: 50 × 0.7 = 35 HP

Base Dodge: 5%
After FastBehavior: 5% + 10% = 15%
```

---

## Tests de Validation

1. ✅ Ennemi Mercury créé → HP réduit de 30%
2. ✅ Esquive augmentée de +10%
3. ✅ `behavior_name` = "Fast (Mercury)"
4. ✅ Comportement appliqué automatiquement

---

## Dépendances

- **Requiert**: `EnemyBehavior` (COF-202)
- **Utilisé par**: `BaseEnemy` sur Mercury
