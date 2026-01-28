# COF-112: Damage and Heal Calculation Formulas

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichiers**: `scripts/core/entities/base_entity.gd`, `scripts/core/stats/entity_stats.gd`

---

## User Story

**En tant que** système de combat,  
**Je veux** des formules de dégâts et soins claires,  
**Afin de** garantir un gameplay équilibré et prévisible.

---

## Description

Les formules de calcul sont le fondement de l'équilibrage. Elles doivent être simples à comprendre mais permettre de la profondeur via les modificateurs.

---

## Critères d'Acceptation

- [x] Formule de dégâts : `ATK - Defense` (minimum 1)
- [x] Formule de crit : `Dégâts × crit_multiplier` (default 1.5x)
- [x] Esquive : cap à 95% maximum
- [x] Heal : montant direct ou pourcentage des max HP
- [x] Minimum 1 dégât toujours infligé

---

## Formules Détaillées

### Dégâts Infligés

```gdscript
func calculate_attack_damage(modifiers: Array = []) -> int:
    var final_attack := float(attack)

    for mod in modifiers:
        if mod.get("stat") == "attack":
            if mod.get("type") == "add":
                final_attack += mod.get("value", 0.0)
            elif mod.get("type") == "mult":
                final_attack *= mod.get("value", 1.0)

    return int(final_attack)
```

### Dégâts Reçus (avec Défense)

```gdscript
func calculate_damage_taken(incoming_damage: int, defense_modifier: int = 0) -> int:
    var total_defense := defense + defense_modifier
    var final_damage := maxi(1, incoming_damage - total_defense)
    return final_damage
```

### Critical Hit

````gdscript
func roll_critical(bonus_crit_chance: float = 0.0) -> bool:
    var total_crit := clampf(crit_chance + bonus_crit_chance, 0.0, 1.0)































































































- **Utilisé par**: Tout le système de combat- **Requiert**: Rien## Dépendances---5. ✅ Heal 13% de 150 HP → +19 HP4. ✅ Esquive 100% → cap à 95%3. ✅ Crit avec mult 1.5 → dégâts × 1.52. ✅ ATK 50 vs DEF 10 → 40 dégâts1. ✅ ATK 10 vs DEF 15 → 1 dégât (minimum)## Tests de Validation---| Heal Percent | 13% | Action HEAL || Default Crit Mult | 1.5x | Multiplicateur critique || Max Dodge | 95% | Cap d'esquive || Min Damage | 1 | Toujours au moins 1 dégât ||-----------|--------|-------------|| Constante | Valeur | Description |## Constantes de Balance---```Total: 28% chance d'esquiverDodge Buff: +20%Base Dodge: 8%```### Esquive avec Buff```After Heal: 99 HPCurrent HP: 80Heal Amount: 150 × 0.13 = 19.5 → 19 HPMax HP: 150```### Heal 13%```Crit Damage: 9 × 1.5 = 13Crit Multiplier: 1.5Base Damage: 9Enemy Defense: 3Hero ATK: 12```### Attaque Critique```Damage: 12 - 3 = 9Enemy Defense: 3Hero ATK: 12```### Attaque Normale## Exemples de Calcul---```    return heal(amount)    var amount := int(base_stats.max_hp * percent)func heal_percent(percent: float) -> int:# Soin en pourcentage    return actual_heal    healed.emit(actual_heal)    current_hp += actual_heal    var actual_heal := mini(amount, base_stats.max_hp - current_hp)        return 0    if not is_alive:func heal(amount: int) -> int:# Soin direct```gdscript### Soins```    return randf() < total_dodge    var total_dodge := clampf(dodge_chance + bonus_dodge_chance, 0.0, 0.95)  # Cap 95%func roll_dodge(bonus_dodge_chance: float = 0.0) -> bool:```gdscript### Esquive```damage = int(damage * crit_multiplier)  # default 1.5x# Si crit:    return randf() < total_crit```
````
