# COF-502: Ending Cinematic After Dr Mortis

**Epic**: Cinematics  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd` (lignes 124-133)

---

## User Story

**En tant que** joueur ayant battu Dr. Mortis,  
**Je veux** une cinématique de fin,  
**Afin de** conclure l'histoire (avec un cliffhanger pour la suite).

---

## Description

Après avoir vaincu le boss final (Dr. Mortis), une cinématique spéciale révèle un twist : Dr. Mortis n'était qu'un pion, et un mystérieux "Council" tire les ficelles.

---

## Critères d'Acceptation

- [x] 8 slides de dialogue
- [x] Révélation du "Council" (setup pour suite)
- [x] "TO BE CONTINUED..." à la fin
- [x] Déclenché automatiquement après victoire sur Earth
- [x] Transition vers écran de victoire finale

---

## Contenu de la Cinématique

```gdscript
const ENDING_CINEMATIC := [
    {"text": "It's over. Dr. Mortis lies defeated at my feet.", "emoji": "💀"},
    {"text": "But as life fades from his eyes, he laughs...", "emoji": "😈"},
    {"text": "'You fool... I was just ONE of them. The Council... they ordered it all.'", "emoji": "🗣️"},
    {"text": "A Council? More humans responsible for my family's death?", "emoji": "😠"},
    {"text": "'They're everywhere... hiding in the outer colonies... you'll never find them all...'", "emoji": "🌌"},
    {"text": "I WILL find them. Every. Single. One.", "emoji": "🔥"},
    {"text": "My journey is not over. It has only just begun.", "emoji": "🚀"},
    {"text": "TO BE CONTINUED...", "emoji": "⏳"},
]
```

---

## Implémentation

```gdscript
func _on_boss_died() -> void:
    if current_planet == 3:  # Earth = Dr. Mortis
        _show_ending_cinematic()
    else:
        _show_victory_screen()

func _show_ending_cinematic() -> void:
    is_showing_cinematic = true
    cinematic_slide_index = 0
    _create_cinematic_ui(ENDING_CINEMATIC)

func _on_ending_cinematic_finished() -> void:
    # Enregistrer que le jeu est terminé
    SaveManager.record_boss_defeated("dr_mortis")
    SaveManager.advance_planet()  # highest_completed = 3

    # Afficher écran de victoire finale
    _show_final_victory_screen()
```

---

## Structure Narrative

```
SLIDE 1: Victoire - Dr. Mortis est vaincu
SLIDE 2-3: Twist - Il rit et révèle un secret
SLIDE 4-5: Révélation - Le Council existe
SLIDE 6-7: Résolution - Le héros jure de continuer
SLIDE 8: Cliffhanger - TO BE CONTINUED
```

---

## Implications pour la Suite

Le "Council" est un setup pour :

- 🎮 Sequel potentiel
- 🌌 Nouvelles planètes (colonies extérieures)
- 👥 Nouveaux boss (membres du Council)
- 📖 Extension de l'histoire

---

## Écran de Victoire Finale

Après la cinématique :

- "CONGRATULATIONS!" en grand
- Statistiques de la partie complète
- Crédits (optionnel)
- Bouton "New Game+" ou "Return to Menu"

---

## Tests de Validation

1. ✅ Battre Dr. Mortis → cinématique de fin jouée
2. ✅ 8 slides affichés séquentiellement
3. ✅ Dernier slide = "TO BE CONTINUED..."
4. ✅ Fin cinématique → écran victoire finale
5. ✅ `highest_planet_completed` = 3 sauvegardé

---

## Dépendances

- **Requiert**: Dr. Mortis Boss (COF-305), Cinematic UI (COF-503)
- **Utilisé par**: `GameCombatScene._on_boss_died()`
