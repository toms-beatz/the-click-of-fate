# COF-301: Boss Data Configuration per Planet

**Epic**: Boss System  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd` (lignes 115-121)

---

## User Story

**En tant que** game designer,  
**Je veux** configurer les boss par planète,  
**Afin de** créer des défis uniques et mémorables.

---

## Description

Chaque planète a un boss unique avec ses propres stats, couleur, emoji et pouvoir spécial. Les boss sont significativement plus forts que les ennemis normaux.

---

## Critères d'Acceptation

- [x] Configuration dans constante `PLANET_BOSSES`
- [x] 4 boss configurés :
  - Mercury Guardian
  - Venus Queen
  - Mars Warlord
  - DR. MORTIS (boss final)
- [x] Chaque boss a : name, hp, atk, speed, color, emoji, special

---

## Implémentation

```gdscript
const PLANET_BOSSES := {
    0: {
        "name": "Mercury Guardian",
        "hp": 400,
        "atk": 20,
        "speed": 1.0,
        "color": Color(1.0, 0.5, 0.2),
        "emoji": "🛡️",
        "special": "shield"
    },
    1: {
        "name": "Venus Queen",
        "hp": 550,
        "atk": 25,
        "speed": 0.9,
        "color": Color(0.8, 0.9, 0.2),
        "emoji": "👑",
        "special": "poison"
    },
    2: {
        "name": "Mars Warlord",
        "hp": 700,
        "atk": 30,
        "speed": 0.8,
        "color": Color(0.9, 0.4, 0.3),
        "emoji": "⚔️",
        "special": "rage"
    },
    3: {
        "name": "DR. MORTIS",
        "hp": 1500,
        "atk": 40,
        "speed": 0.6,
        "color": Color(0.6, 0.2, 0.8),
        "emoji": "💀",
        "special": "final"
    },
}
```

---

## Comparaison des Boss

| Boss             | HP   | ATK | Speed | Planète |
| ---------------- | ---- | --- | ----- | ------- |
| Mercury Guardian | 400  | 20  | 1.0   | 0       |
| Venus Queen      | 550  | 25  | 0.9   | 1       |
| Mars Warlord     | 700  | 30  | 0.8   | 2       |
| DR. MORTIS       | 1500 | 40  | 0.6   | 3       |

---

## Scaling des Boss

- **HP** : Augmente de ~40% entre chaque boss
- **ATK** : +5 par niveau de planète
- **Speed** : Diminue (boss plus lents mais plus puissants)

---

## Pouvoirs Spéciaux (Prévu)

| Boss             | Special | Effet (futur)       |
| ---------------- | ------- | ------------------- |
| Mercury Guardian | shield  | Bouclier temporaire |
| Venus Queen      | poison  | Poison renforcé     |
| Mars Warlord     | rage    | Enrage à 50% HP     |
| DR. MORTIS       | final   | Combinaison de tous |

---

## Tests de Validation

1. ✅ `PLANET_BOSSES[0]` retourne Mercury Guardian
2. ✅ DR. MORTIS a 1500 HP (3x+ les autres)
3. ✅ Chaque boss a une couleur unique
4. ✅ Emojis affichés correctement

---

## Dépendances

- **Requiert**: Rien
- **Utilisé par**: `GameCombatScene` pour spawn et affichage boss
