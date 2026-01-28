# COF-204: Toxic Behavior Venus Enemies

**Epic**: Enemy System  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scripts/entities/behaviors/toxic_behavior.gd`

---

## User Story

**En tant que** joueur sur Venus,  
**Je veux** affronter des ennemis empoisonneurs,  
**Afin de** gérer la pression de dégâts dans le temps.

---

## Description

Les ennemis de Venus sont des "Toxins" qui infligent du poison. Chaque attaque applique un DoT (Damage over Time) qui force le joueur à utiliser HEAL plus souvent.

---

## Critères d'Acceptation

- [x] Poison: 2 DPS pendant 5 secondes
- [x] Stats normales (pas de modification HP/ATK)
- [x] `behavior_name = "Toxic (Venus)"`
- [x] Méthode statique `apply_poison_to(target)` pour faciliter l'application

---

## Implémentation

```gdscript
class_name ToxicBehavior
extends EnemyBehavior

const POISON_DPS := 2
const POISON_DURATION := 5.0

func _init() -> void:
    behavior_name = "Toxic (Venus)"

func apply(enemy: BaseEnemy) -> void:
    # Stats normales, pas de modification
    pass

func process(enemy: BaseEnemy, _delta: float) -> void:
    # Le poison est géré via apply_poison_to après attaque
    pass

static func apply_poison_to(target: BaseEntity) -> void:
    if not target or not target.is_alive:
        return

    var poison_timer := Timer.new()
    poison_timer.wait_time = 1.0
    poison_timer.one_shot = false
    target.add_child(poison_timer)

    var ticks_remaining := int(POISON_DURATION)

    poison_timer.timeout.connect(func():
        if target.is_alive:
            target.take_damage(POISON_DPS, false)
        ticks_remaining -= 1
        if ticks_remaining <= 0:
            poison_timer.stop()
            poison_timer.queue_free()
    )

    poison_timer.start()
```

---

## Caractéristiques de Gameplay

### Points Forts

- Dégâts persistants (DoT)
- Force l'utilisation de HEAL
- Cumul possible de poison

### Points Faibles

- Stats de base normales
- Pas de burst damage

### Stratégie du Joueur

- HEAL devient prioritaire
- Gérer la jauge de pression HEAL
- Tuer vite pour éviter accumulation

---

## Calcul du Poison

```
Poison DPS: 2
Duration: 5 secondes
Total Damage: 2 × 5 = 10 dégâts

Si 3 ennemis touchent:
3 × 10 = 30 dégâts de poison !
```

---

## Intégration avec Combat

```gdscript
# Dans le système d'attaque ennemi
func _on_enemy_attacked(target, damage, is_crit):
    if enemy.behavior is ToxicBehavior:
        ToxicBehavior.apply_poison_to(target)
```

---

## Tests de Validation

1. ✅ Ennemi Venus attaque → poison appliqué
2. ✅ Poison inflige 2 DPS pendant 5s
3. ✅ Timer nettoyé après expiration
4. ✅ `behavior_name` = "Toxic (Venus)"

---

## Dépendances

- **Requiert**: `EnemyBehavior` (COF-202)
- **Utilisé par**: `BaseEnemy` sur Venus
