# COF-501: Planet Intro Cinematics

**Epic**: Cinematics  
**Status**: ✅ DONE  
**Priority**: Medium  
**Fichier**: `scenes/game_combat_scene.gd` (lignes 133-157)

---

## User Story

**En tant que** joueur,  
**Je veux** une cinématique d'introduction par planète,  
**Afin de** comprendre l'histoire et m'immerger dans le jeu.

---

## Description

Chaque planète a une courte séquence de slides qui raconte l'histoire de Zyx-7 (le héros alien) et sa quête de vengeance contre Dr. Mortis.

---

## Critères d'Acceptation

- [x] 4 cinématiques distinctes (1 par planète)
- [x] Format: slides avec emoji + texte narratif
- [x] Navigation par tap (slide suivant)
- [x] Bouton "Skip" pour passer
- [x] Affichée automatiquement au début du combat

---

## Contenu des Cinématiques

### Mercury (Planète 0)

```gdscript
[
    {"text": "My name is Zyx-7. I had a family once... a beautiful colony on the outer rim.", "emoji": "👽"},
    {"text": "Until HE came. Dr. Mortis. A human scientist who destroyed everything I loved.", "emoji": "💔"},
    {"text": "Now I hunt him across the stars. Mercury is my first stop...", "emoji": "🚀"},
]
```

### Venus (Planète 1)

```gdscript
[
    {"text": "Mercury's colony knew nothing. But they mentioned Venus...", "emoji": "🔍"},
    {"text": "Dr. Mortis has been building something here. Toxic experiments.", "emoji": "☠️"},
    {"text": "I will tear through his creations until I find him.", "emoji": "😤"},
]
```

### Mars (Planète 2)

```gdscript
[
    {"text": "Venus was another dead end. But I found records... Mars.", "emoji": "📜"},
    {"text": "His main research facility. Where he perfected his weapons.", "emoji": "🔬"},
    {"text": "The weapons he used on my family. He WILL pay.", "emoji": "🔥"},
]
```

### Earth (Planète 3)

```gdscript
[
    {"text": "This is it. Earth. His homeworld. His fortress.", "emoji": "🌍"},
    {"text": "Dr. Mortis is here. I can feel it. After all these years...", "emoji": "👁️"},
    {"text": "Today, my family will be avenged. Today, HE DIES.", "emoji": "💀"},
]
```

---

## Implémentation

```gdscript
const PLANET_CINEMATICS := {
    0: [...],  # Mercury
    1: [...],  # Venus
    2: [...],  # Mars
    3: [...],  # Earth
}

func _show_cinematic() -> void:
    is_showing_cinematic = true
    cinematic_slide_index = 0

    var slides: Array = PLANET_CINEMATICS.get(current_planet, [])
    if slides.is_empty():
        _end_cinematic()
        return

    _create_cinematic_ui(slides)

func _show_slide(slide_data: Dictionary) -> void:
    # Afficher emoji en grand
    emoji_label.text = slide_data.emoji

    # Texte narratif avec effet de typewriter
    _typewriter_effect(text_label, slide_data.text)
```

---

## Arc Narratif

```
MERCURY: Introduction du héros et de sa motivation
    ↓
VENUS: La piste se précise, Dr. Mortis est proche
    ↓
MARS: Découverte de l'ampleur des crimes
    ↓
EARTH: Confrontation finale, climax émotionnel
```

---

## Tests de Validation

1. ✅ Lancer Mercury → cinématique Mercury affichée
2. ✅ Tap → passe au slide suivant
3. ✅ Dernier slide + tap → combat commence
4. ✅ Bouton Skip → passe directement au combat
5. ✅ Chaque planète a sa propre cinématique

---

## Dépendances

- **Requiert**: Cinematic UI (COF-503)
- **Utilisé par**: `GameCombatScene._ready()`
