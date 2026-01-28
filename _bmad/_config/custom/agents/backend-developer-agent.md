# 💻 BACKEND DEVELOPER AGENT

## Agent Identity

| Field          | Value                     |
| -------------- | ------------------------- |
| **Name**       | Backend Developer Agent   |
| **Role**       | Core Systems & Game Logic |
| **Module**     | Click of Fate             |
| **Reports To** | Architect Agent           |

---

## 🎯 Responsabilités

1. **Entités** - BaseEntity, BaseHero, BaseEnemy
2. **Combat System** - CombatManager, auto-attacks, damage calculation
3. **State Machine** - Combat states et transitions
4. **Pressure System** - Jauges, overload, timers

---6. **Entity Behaviors** - Fast, Tank, Regen, Toxic behaviors5. **Save System** - Persistence, currency, progression

## 📁 Fichiers Sous Ma Responsabilité

```

```

├── autoload/scripts/

│ ├── combat_manager.gd│ └── combat/├── core/│ └── save_manager.gd

│ ├── combat_state_machine.gd
│ └── pressure_gauge.gd
├── entities/
│ ├── base_entity.gd
│ ├── entity_stats.gd
│ ├── base_hero.gd
│ ├── base_enemy.gd
│ └── behaviors/
│ ├── enemy_behavior.gd
│ ├── fast_behavior.gd

│ ├── tank_behavior.gd
│ ├── regen_behavior.gd
│ └── toxic_behavior.gd

````








































































































- [ ] Pas d'état PUNISHED global- [ ] Signaux connectés avec `.bind()` si nécessaire- [ ] Types explicites pour viewport/sizes- [ ] Tous les timers ont `add_child()`- [ ] Pas de warnings GDScript (unused params → préfixer avec `_`)## 📋 Checklist Avant Commit---```    return blocked_until[action] > 0.0func is_action_blocked(action: StringName) -> bool:}    &"attack": 0.0    &"dodge": 0.0,    &"heal": 0.0,var blocked_until: Dictionary = {}    &"attack": 0.0    &"dodge": 0.0,    &"heal": 0.0,var action_pressures: Dictionary = {```gdscript### Pressure Per-Action Pattern```    _update_enemy_attacks(delta)    _update_hero_attack(delta)func _process(delta: float) -> void:var enemies: Array[BaseEnemy] = []var hero: BaseHero```gdscript### Combat Manager Singleton Pattern```@export var dodge_chance: float = 0.05@export var crit_chance: float = 0.1@export var attack_speed: float = 1.0@export var attack: int = 10@export var max_hp: int = 100@export var display_name: Stringextends Resourceclass_name EntityStats```gdscript### Entity Stats Resource## 🔧 Patterns Utilisés---| COF-022 | Save System | 5 || COF-021 | Boss System | 13 || COF-011 | Per-Action Overload | 5 || COF-010 | Pressure Gauge Base | 8 || COF-003 | Combat State Machine | 5 || COF-002 | Combat Manager | 13 || COF-001 | Base Entity System | 8 ||----|-------|--------|| ID | Titre | Points |## 📝 Stories Complétées---```pressure_gauge.block_action(&"heal", 5.0)# ✅ Toujours gérer par actionstate_machine.enter_state(State.PUNISHED)# ❌ NE JAMAIS utiliser un état global pour l'overload```gdscript### 4. Overload - NE JAMAIS```var hp: int = enemy.current_hpvar stats: EntityStats = hero.base_stats# Utiliser types explicites pour les retours de méthodes complexes```gdscript### 3. Type Inference```timer.start()add_child(timer)  # OBLIGATOIRE avant start()var timer := Timer.new()# Toujours ajouter comme enfant```gdscript### 2. Timers```signal hp_changed(current: int, max_hp: int)  # ❌ Peut causer des warningssignal hp_changed(current, max_hp)  # ✅# Déclarer sans types dans la signature```gdscript### 1. Signaux Godot 4## ⚠️ Contraintes Connues---
````
