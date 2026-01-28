# COF-802: Enemy Type Definitions

**Epic**: Data Structures  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/data/enemy_data.gd` (concept)

---

## User Story

**En tant que** développeur,  
**Je veux** des définitions claires des types d'ennemis,  
**Afin de** facilement créer de nouveaux ennemis variés.

---

## Description

Chaque type d'ennemi a des stats de base et un comportement associé. Les données sont séparées de la logique pour faciliter le balancing.

---

## Critères d'Acceptation

- [x] 4 types d'ennemis définis (Fast, Toxic, Regen, Tank)
- [x] Stats configurables: HP, Damage, Speed, Attack Speed
- [x] Comportement associé (behavior script)
- [x] Variantes visuelles (emoji, couleur)

---

## Structure de Données

```gdscript
const ENEMY_TYPES := {
    "fast": {
        "name": "Mercury Scout",
        "emoji": "💨",
        "color": Color.CYAN,
        "stats": {
            "hp": 30,
            "damage": 8,
            "move_speed": 120.0,
            "attack_speed": 2.5,
        },
        "behavior": "fast",
        "description": "Rapide mais fragile. Attaque souvent.",
        "scale": 0.8,
    },

    "toxic": {
        "name": "Venus Spitter",
        "emoji": "☠️",
        "color": Color.PURPLE,
        "stats": {
            "hp": 50,
            "damage": 10,
            "move_speed": 80.0,
            "attack_speed": 1.5,
            "poison_damage": 3,  # DPS poison
            "poison_duration": 4.0,
        },
        "behavior": "toxic",
        "description": "Applique du poison. Dégâts sur la durée.",
        "scale": 1.0,
    },

    "regen": {
        "name": "Mars Brute",
        "emoji": "🔄",
        "color": Color.ORANGE,
        "stats": {
            "hp": 80,
            "damage": 15,
            "move_speed": 70.0,
            "attack_speed": 1.2,
            "regen_rate": 5,  # HP/seconde
        },
        "behavior": "regen",
        "description": "Se régénère. Tuer rapidement!",
        "scale": 1.2,
    },

    "tank": {
        "name": "Earth Titan",
        "emoji": "🛡️",
        "color": Color.DARK_GREEN,
        "stats": {
            "hp": 150,
            "damage": 20,
            "move_speed": 50.0,
            "attack_speed": 0.8,
            "damage_reduction": 0.2,  # 20% reduction
        },
        "behavior": "tank",
        "description": "Très résistant. Priorité basse.",
        "scale": 1.4,
    },
}
```

---

## Factory d'Ennemis

```gdscript
func _spawn_enemy(type_id: String) -> BaseEnemy:
    var type_data := ENEMY_TYPES.get(type_id, {})
    if type_data.is_empty():
        push_error("Unknown enemy type: %s" % type_id)
        return null

    var enemy := BaseEnemy.new()

    # Stats
    var stats := type_data["stats"]
    enemy.stats.max_hp = stats["hp"]
    enemy.stats.current_hp = stats["hp"]
    enemy.stats.damage = stats["damage"]
    enemy.move_speed = stats["move_speed"]
    enemy.attack_cooldown = 1.0 / stats["attack_speed"]

    # Visuel
    enemy.emoji = type_data["emoji"]
    enemy.modulate = type_data["color"]
    enemy.scale = Vector2.ONE * type_data.get("scale", 1.0)

    # Comportement
    var behavior := _create_behavior(type_data["behavior"])
    enemy.set_behavior(behavior)

    return enemy

func _create_behavior(behavior_type: String) -> EnemyBehavior:
    match behavior_type:
        "fast":
            return FastBehavior.new()
        "toxic":
            return ToxicBehavior.new()
        "regen":
            return RegenBehavior.new()
        "tank":
            return TankBehavior.new()
        _:
            return EnemyBehavior.new()  # Base
```

---

## Scaling par Vague

```gdscript
func _apply_wave_scaling(enemy: BaseEnemy, wave_number: int) -> void:
    # Les ennemis deviennent plus forts au fil des vagues
    var hp_multiplier := 1.0 + (wave_number * 0.1)  # +10% HP par vague
    var damage_multiplier := 1.0 + (wave_number * 0.05)  # +5% damage par vague

    enemy.stats.max_hp = int(enemy.stats.max_hp * hp_multiplier)
    enemy.stats.current_hp = enemy.stats.max_hp
    enemy.stats.damage = int(enemy.stats.damage * damage_multiplier)

# Exemple vague 5:
# Fast: 30 HP × 1.5 = 45 HP, 8 DMG × 1.25 = 10 DMG
```

---

## Comparaison des Types

| Type  | HP  | Damage | Speed | Spécial          |
| ----- | --- | ------ | ----- | ---------------- |
| Fast  | 30  | 8      | 120   | Attaque rapide   |
| Toxic | 50  | 10     | 80    | Poison DoT       |
| Regen | 80  | 15     | 70    | Régénération     |
| Tank  | 150 | 20     | 50    | Damage reduction |

---

## Stratégie de Combat

```
Fast (Mercury):
→ Priorité HAUTE - Tue vite avant d'être submergé

Toxic (Venus):
→ Priorité MOYENNE - Évite le poison, heal si touché

Regen (Mars):
→ Priorité HAUTE - Focus pour empêcher la régénération

Tank (Earth):
→ Priorité BASSE - Longue à tuer, gérer les autres d'abord
```

---

## Tests de Validation

1. ✅ 4 types d'ennemis avec stats distinctes
2. ✅ Factory crée l'ennemi correct
3. ✅ Behavior associé au type
4. ✅ Scaling par vague fonctionne
5. ✅ Visuels distincts par type

---

## Dépendances

- **Requiert**: BaseEnemy (COF-201), Behaviors (COF-203-206)
- **Utilisé par**: WaveController, CombatScene
