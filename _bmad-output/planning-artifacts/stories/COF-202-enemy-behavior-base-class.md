# COF-202: Enemy Behavior Base Class

**Epic**: Enemy System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/entities/behaviors/enemy_behavior.gd`

---

## User Story

**En tant que** game designer,  
**Je veux** un système de comportements modulaires,  
**Afin de** créer des ennemis variés sans dupliquer le code.

---

## Description

`EnemyBehavior` est une classe de base légère (RefCounted, pas Node) qui définit l'interface pour tous les comportements d'ennemis. Chaque planète a son propre comportement qui modifie les stats ou ajoute des effets.

---

## Critères d'Acceptation

- [x] Classe `EnemyBehavior` extends `RefCounted`
- [x] `behavior_name: String` pour debug
- [x] Méthode `apply(enemy)` - modifications initiales (appelé 1 fois à ready)
- [x] Méthode `process(enemy, delta)` - effets continus (appelé chaque frame)

---

## Implémentation

```gdscript
class_name EnemyBehavior
extends RefCounted

var behavior_name: String = "Base"

## Applique les modifications initiales à l'ennemi
## Appelé une fois à _ready()
func apply(enemy: BaseEnemy) -> void:
    pass  # Override dans les sous-classes

## Traitement chaque frame (effets continus)
## Appelé dans _process()
func process(enemy: BaseEnemy, delta: float) -> void:
    pass  # Override si nécessaire
```

---

## Sous-classes Disponibles

```
EnemyBehavior (base)
    ├── FastBehavior     # Mercury
    ├── ToxicBehavior    # Venus
    ├── RegenBehavior    # Mars
    └── TankBehavior     # Earth
```

---

## Pourquoi RefCounted ?

- **Performance** : Pas de Node overhead
- **Légèreté** : Pas de signaux, pas de \_process natif
- **Simplicité** : Juste des données et méthodes
- **Garbage Collection** : Automatique quand plus référencé

---

## Pattern d'Utilisation

```gdscript
# Dans BaseEnemy._apply_planet_behavior()
behavior = FastBehavior.new()
behavior.apply(self)  # Modifications initiales

# Dans BaseEnemy._process()
if behavior and is_alive:
    behavior.process(self, delta)  # Effets continus
```

---

## Tests de Validation

1. ✅ Créer un EnemyBehavior → `behavior_name = "Base"`
2. ✅ `apply()` peut être surchargé
3. ✅ `process()` peut être surchargé
4. ✅ Pas de fuite mémoire (RefCounted)

---

## Dépendances

- **Requiert**: Rien
- **Utilisé par**: `BaseEnemy`, `FastBehavior`, `ToxicBehavior`, `RegenBehavior`, `TankBehavior`
