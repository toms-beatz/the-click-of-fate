# COF-111: Temporary Modifiers (Buff/Debuff System)

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/core/entities/base_entity.gd` (lignes 99-150)

---

## User Story

**En tant que** système de combat,  
**Je veux** un système de buffs/debuffs temporaires,  
**Afin d'** appliquer des effets limités dans le temps.

---

## Description

Les modificateurs temporaires permettent d'augmenter ou réduire les stats d'une entité pendant une durée limitée. C'est essentiel pour les actions DODGE (+esquive) et ATTACK (+crit).

---

## Critères d'Acceptation

- [x] Méthode `add_temp_modifier(stat, value, type, duration)`
- [x] Types supportés :
  - `"add"` - Additif (stat + value)
  - `"mult"` - Multiplicatif (stat × value)
- [x] Decay automatique de la durée chaque frame
- [x] Suppression automatique quand durée ≤ 0
- [x] Application lors du calcul des stats
- [x] Support de plusieurs modificateurs sur la même stat

---

## Implémentation

```gdscript
## Modificateurs temporaires {stat_name: [{value, type, duration}]}
var _temp_modifiers: Dictionary = {}

func add_temp_modifier(stat: String, value: float, type: String, duration: float) -> void:
    if not _temp_modifiers.has(stat):
        _temp_modifiers[stat] = []

    _temp_modifiers[stat].append({
        "value": value,
        "type": type,
        "duration": duration
    })

func _update_modifiers(delta: float) -> void:
    for stat in _temp_modifiers.keys():
        var mods: Array = _temp_modifiers[stat]
        var to_remove: Array[int] = []

        for i in range(mods.size()):
            mods[i]["duration"] -= delta
            if mods[i]["duration"] <= 0:
                to_remove.append(i)

        # Remove expired (reverse order)
        for i in range(to_remove.size() - 1, -1, -1):
            mods.remove_at(to_remove[i])

func _get_stat_modifier(stat: String, base_type: String) -> float:
    var result := 0.0 if base_type == "add" else 1.0

    if _temp_modifiers.has(stat):
        for mod in _temp_modifiers[stat]:
            if mod["type"] == base_type:
                if base_type == "add":
                    result += mod["value"]
                else:
                    result *= mod["value"]

    return result
```

---

## Exemples d'Utilisation

### Action DODGE

```gdscript
# +20% esquive pendant 4 secondes
hero.add_temp_modifier("dodge_chance", 0.20, "add", 4.0)
```

### Action ATTACK

```gdscript
# +10% crit pendant 2 secondes
hero.add_temp_modifier("crit_chance", 0.10, "add", 2.0)
```

### Booster Rage de Guerre

```gdscript
# ×1.5 dégâts pendant toute la partie
hero.add_temp_modifier("attack", 1.5, "mult", 9999.0)
```

---

## Calcul Final des Stats

```
Base dodge: 8%
Additive mods: +20%
Final dodge: 8% + 20% = 28%

Base attack: 12
Multiplicative mods: ×1.5
Final attack: 12 × 1.5 = 18
```

---

## Tests de Validation

1. ✅ Ajouter mod +20% esquive → esquive augmente de 20%
2. ✅ Après 4s → mod expire, esquive revient à la normale
3. ✅ Deux mods additifs sur même stat → cumulent
4. ✅ Mod multiplicatif ×1.5 → dégâts × 1.5
5. ✅ Mods de types différents sur même stat → les deux appliqués

---

## Dépendances

- **Requiert**: Rien
- **Utilisé par**: `CombatManager` pour les actions, `Boosters`
