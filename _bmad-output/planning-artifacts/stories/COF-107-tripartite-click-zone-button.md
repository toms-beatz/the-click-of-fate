# COF-107: Tripartite Click Zone Button

**Epic**: Core Combat System  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/ui/click_zone_button.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** un bouton divisé en 3 zones,  
**Afin d'** effectuer mes actions en touchant la zone appropriée.

---

## Description

Le `ClickZoneButton` est l'interface principale du joueur pendant le combat. Un seul bouton large divisé en 3 zones horizontales : HEAL (gauche), DODGE (centre), ATTACK (droite). La position X du toucher détermine l'action.

---

## Critères d'Acceptation

- [x] Layout horizontal :
  ```
  ┌─────────────┬─────────────┬─────────────┐
  │    HEAL     │    DODGE    │   ATTACK    │
  │   (0-33%)   │  (33-66%)   │  (66-100%)  │
  └─────────────┴─────────────┴─────────────┘
  ```
- [x] Couleurs distinctives :
  - Heal: Bleu (`Color(0.2, 0.6, 0.9, 0.8)`)
  - Dodge: Violet (`Color(0.6, 0.4, 0.9, 0.8)`)
  - Attack: Rouge (`Color(0.9, 0.3, 0.2, 0.8)`)
- [x] Support touch screen ET souris
- [x] Feedback visuel au clic (highlight + animation scale)
- [x] Blocage individuel par zone (quand overload)
- [x] Signaux :
  - `zone_pressed(zone: StringName)`
  - `zone_released(zone: StringName)`

---

## Implémentation

```gdscript
class_name ClickZoneButton
extends Control

signal zone_pressed(zone: StringName)
signal zone_released(zone: StringName)

enum Zone { HEAL, DODGE, ATTACK }

const ZONE_NAMES: Dictionary = {
    Zone.HEAL: &"heal",
    Zone.DODGE: &"dodge",
    Zone.ATTACK: &"attack"
}

var _zone_blocked: Dictionary = {
    Zone.HEAL: false,
    Zone.DODGE: false,
    Zone.ATTACK: false
}

func _get_zone_from_position(local_pos: Vector2) -> Zone:
    var ratio_x := local_pos.x / size.x
    if ratio_x < 0.33:
        return Zone.HEAL
    elif ratio_x < 0.66:
        return Zone.DODGE
    else:
        return Zone.ATTACK
```

---

## Feedback Visuel

### Au Press

- Zone highlight (luminosité +30%)
- Scale animation (0.95 → 1.0)
- Label temporairement en gras

### En Overload

- Zone grisée
- Label affiche "BLOCKED" ou icône 🔒
- Couleur désaturée

---

## Accessibilité Mobile

- Zones suffisamment larges (>100px chacune)
- Espacement de 4px entre zones
- Corner radius pour esthétique
- Position en bas de l'écran (zone de pouce)

---

## Tests de Validation

1. ✅ Touch à 10% largeur → signal `zone_pressed("heal")`
2. ✅ Touch à 50% largeur → signal `zone_pressed("dodge")`
3. ✅ Touch à 80% largeur → signal `zone_pressed("attack")`
4. ✅ Zone HEAL bloquée → touch ignoré, pas de signal
5. ✅ Feedback visuel visible au clic

---

## Dépendances

- **Requiert**: Rien
- **Utilisé par**: `CombatManager` (COF-105), `GameCombatScene`
