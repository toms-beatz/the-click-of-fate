# COF-305: Dr Mortis Final Boss

**Epic**: Boss System  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** un boss final mémorable (Dr. Mortis),  
**Afin de** conclure l'histoire de vengeance de manière épique.

---

## Description

Dr. Mortis est le boss final du jeu, responsable de la destruction de la famille du héros. Il est significativement plus puissant que les autres boss et déclenche la cinématique de fin une fois vaincu.

---

## Critères d'Acceptation

- [x] 1500 HP (3x+ plus que les autres boss)
- [x] 40 ATK (le plus élevé)
- [x] Couleur violette unique (`Color(0.6, 0.2, 0.8)`)
- [x] Emoji 💀
- [x] Special "final" (préparé pour mécaniques futures)
- [x] Déclenche la cinématique de fin à sa mort

---

## Configuration

```gdscript
const PLANET_BOSSES := {
    # ...autres boss...
    3: {
        "name": "DR. MORTIS",
        "hp": 1500,          # 3x Mercury Guardian
        "atk": 40,           # 2x Mercury Guardian
        "speed": 0.6,        # Plus lent mais dévastateur
        "color": Color(0.6, 0.2, 0.8),  # Violet sinistre
        "emoji": "💀",
        "special": "final"
    },
}
```

---

## Comparaison avec Autres Boss

| Stat  | Mercury | Venus | Mars | **DR. MORTIS** |
| ----- | ------- | ----- | ---- | -------------- |
| HP    | 400     | 550   | 700  | **1500**       |
| ATK   | 20      | 25    | 30   | **40**         |
| Speed | 1.0     | 0.9   | 0.8  | **0.6**        |

**DR. MORTIS a :**

- 3.75x les HP de Mercury Guardian
- 2x les dégâts
- 0.6x la vitesse (plus lent mais plus fort)

---

## Déclenchement de la Cinématique de Fin

```gdscript
func _on_boss_died() -> void:
    if current_planet == 3:  # Earth = Dr. Mortis
        # Victoire finale !
        _show_ending_cinematic()
    else:
        _show_victory_screen()

func _show_ending_cinematic() -> void:
    # Afficher la cinématique de fin (COF-502)
    is_showing_cinematic = true
    cinematic_slide_index = 0
    _create_cinematic_ui(ENDING_CINEMATIC)
```

---

## Lore : Qui est Dr. Mortis ?

> Dr. Mortis était un scientifique humain qui a développé des armes biologiques. Il a ordonné la destruction de la colonie alien du héros, tuant sa famille. Zyx-7 (le héros) traverse le système solaire pour le retrouver et se venger.

---

## Moment de la Révélation

Quand Dr. Mortis est vaincu, il révèle en mourant :

- Il n'était qu'un pion
- Le "Council" a ordonné le massacre
- D'autres cibles existent
- → Setup pour une suite potentielle

---

## Tests de Validation

1. ✅ Dr. Mortis spawn sur planète Earth (index 3)
2. ✅ HP = 1500 (vérifiable via HP bar)
3. ✅ Couleur violette distinctive
4. ✅ Emoji 💀 affiché
5. ✅ Mort déclenche cinématique de fin
6. ✅ Victoire sur Earth = fin du jeu (MVP)

---

## Dépendances

- **Requiert**: Boss System (COF-301 à 304), Ending Cinematic (COF-502)
- **Utilisé par**: `GameCombatScene`
