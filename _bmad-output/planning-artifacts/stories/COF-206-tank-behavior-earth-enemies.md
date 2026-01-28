# COF-206: Tank Behavior Earth Enemies

**Epic**: Enemy System  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scripts/entities/behaviors/tank_behavior.gd`

---

## User Story

**En tant que** joueur sur Earth,  
**Je veux** affronter des ennemis ultra-résistants,  
**Afin de** me préparer au combat final contre Dr. Mortis.

---

## Description

Les ennemis de Earth sont des "Titans" avec haute défense et beaucoup de PV. Ils représentent le défi ultime avant le boss final. Aucune faiblesse exploitable.

---

## Critères d'Acceptation

- [x] +50% défense
- [x] +30% HP
- [x] Aucune faiblesse
- [x] `behavior_name = "Tank (Earth)"`

---

## Implémentation

```gdscript
class_name TankBehavior
extends EnemyBehavior

const DEFENSE_MULT := 1.5
const HP_MULT := 1.3

func _init() -> void:
    behavior_name = "Tank (Earth)"

func apply(enemy: BaseEnemy) -> void:
    if not enemy.base_stats:
        return

    # Augmenter les PV
    var bonus_hp := int(enemy.base_stats.max_hp * (HP_MULT - 1.0))
    enemy.current_hp += bonus_hp

    # Ajouter défense permanente
    var bonus_defense := enemy.base_stats.defense * (DEFENSE_MULT - 1.0)
    enemy.add_temp_modifier("defense", bonus_defense, "add", 9999.0)

func process(enemy: BaseEnemy, _delta: float) -> void:
    # Les tanks n'ont pas d'effet spécial continu
    pass
```

---

## Caractéristiques de Gameplay

### Points Forts

- Très résistants (+50% DEF, +30% HP)
- Difficiles à tuer
- Derniers ennemis avant le boss

### Points Faibles

- Aucune faiblesse notable
- Pas d'effet spécial actif

### Stratégie du Joueur

- Combat d'endurance
- Équilibrer HEAL et ATTACK
- Gérer ses ressources pour le boss

---

## Calcul des Stats

```
Base HP: 60
After Tank: 60 × 1.3 = 78 HP

Base Defense: 5
After Tank: 5 × 1.5 = 7.5 → +2.5 Defense bonus
Total Defense: 5 + 2.5 = 7.5

Hero ATK 16 vs Tank DEF 7:
Damage = 16 - 7 = 9 (au lieu de 11)
```

---

## Comparaison avec Autres Comportements

| Planète   | HP Mod   | Defense Mod | Effet Spécial |
| --------- | -------- | ----------- | ------------- |
| Mercury   | -30%     | -           | +10% esquive  |
| Venus     | -        | -           | Poison DoT    |
| Mars      | -        | -           | Regen 1%/s    |
| **Earth** | **+30%** | **+50%**    | **Aucun**     |

---

## Difficulté Progressive

```
Mercury: Rapides mais fragiles (apprentissage)
Venus: Dégâts dans le temps (gestion HEAL)
Mars: Régénération (maintien pression)
Earth: Pure résistance (test d'endurance)
```

---

## Tests de Validation

1. ✅ Ennemi Earth créé → HP +30%
2. ✅ Défense +50% appliquée
3. ✅ Pas d'effet `process()` spécial
4. ✅ `behavior_name` = "Tank (Earth)"

---

## Dépendances

- **Requiert**: `EnemyBehavior` (COF-202)
- **Utilisé par**: `BaseEnemy` sur Earth
