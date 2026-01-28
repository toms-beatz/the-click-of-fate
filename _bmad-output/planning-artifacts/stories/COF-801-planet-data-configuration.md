# COF-801: Planet Data Configuration

**Epic**: Data Structures  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/data/planet_data.gd` (concept)

---

## User Story

**En tant que** développeur,  
**Je veux** une structure de données claire pour les planètes,  
**Afin de** faciliter l'ajout de nouvelles planètes.

---

## Description

Les données des planètes sont centralisées dans une structure de données qui contient toutes les informations nécessaires : nom, difficulté, ennemis, boss, etc.

---

## Critères d'Acceptation

- [x] 4 planètes configurées (Mercury, Venus, Mars, Earth)
- [x] Pour chaque planète:
  - Nom et emoji
  - Power recommandé
  - Types d'ennemis
  - Configuration du boss
  - Nombre de vagues
- [x] Facile à étendre

---

## Structure de Données

```gdscript
const PLANET_DATA := {
    0: {
        "name": "Mercury",
        "emoji": "🌕",
        "color": Color(0.8, 0.6, 0.2),  # Orange/marron
        "power_required": 100,
        "waves": 5,
        "enemies_per_wave": [3, 4, 4, 5, 5],
        "enemy_types": ["fast"],
        "boss": {
            "name": "Mercury Guardian",
            "hp": 400,
            "damage": 12,
            "attack_speed": 2.0,
            "color": Color.ORANGE,
        },
        "background": "res://assets/backgrounds/mercury.png",
        "music": "res://assets/music/mercury_theme.ogg",
    },

    1: {
        "name": "Venus",
        "emoji": "🌒",
        "color": Color(0.5, 0.1, 0.5),  # Violet
        "power_required": 150,
        "waves": 5,
        "enemies_per_wave": [4, 5, 5, 6, 6],
        "enemy_types": ["toxic"],
        "boss": {
            "name": "Venus Queen",
            "hp": 550,
            "damage": 15,
            "attack_speed": 1.8,
            "special": "poison_aura",
            "color": Color.PURPLE,
        },
        "background": "res://assets/backgrounds/venus.png",
        "music": "res://assets/music/venus_theme.ogg",
    },

    2: {
        "name": "Mars",
        "emoji": "🔴",
        "color": Color(0.8, 0.2, 0.1),  # Rouge
        "power_required": 200,
        "waves": 5,
        "enemies_per_wave": [4, 5, 6, 6, 7],
        "enemy_types": ["regen"],
        "boss": {
            "name": "Mars Warlord",
            "hp": 700,
            "damage": 20,
            "attack_speed": 1.5,
            "special": "regeneration",
            "color": Color.RED,
        },
        "background": "res://assets/backgrounds/mars.png",
        "music": "res://assets/music/mars_theme.ogg",
    },

    3: {
        "name": "Earth",
        "emoji": "🌍",
        "color": Color(0.2, 0.4, 0.8),  # Bleu
        "power_required": 280,
        "waves": 5,
        "enemies_per_wave": [5, 6, 6, 7, 8],
        "enemy_types": ["tank"],
        "boss": {
            "name": "DR. MORTIS",
            "hp": 1500,
            "damage": 25,
            "attack_speed": 1.2,
            "special": "phases",
            "color": Color.DARK_GREEN,
            "is_final_boss": true,
        },
        "background": "res://assets/backgrounds/earth.png",
        "music": "res://assets/music/final_boss_theme.ogg",
    },
}
```

---

## Utilisation

```gdscript
# Obtenir les données d'une planète
func _get_planet_data(planet_index: int) -> Dictionary:
    return PLANET_DATA.get(planet_index, {})

# Exemple dans WaveController
func _setup_for_planet(planet_index: int) -> void:
    var planet := _get_planet_data(planet_index)

    total_waves = planet["waves"]
    enemy_types = planet["enemy_types"]
    enemies_per_wave = planet["enemies_per_wave"]

    # Charger le background
    if planet.has("background"):
        background.texture = load(planet["background"])

    # Jouer la musique
    if planet.has("music"):
        MusicManager.play(load(planet["music"]))

# Boss spawn
func _spawn_boss() -> void:
    var planet := _get_planet_data(current_planet)
    var boss_data := planet["boss"]

    var boss := BossEnemy.new()
    boss.boss_name = boss_data["name"]
    boss.stats.max_hp = boss_data["hp"]
    boss.stats.damage = boss_data["damage"]
    boss.attack_cooldown = 1.0 / boss_data["attack_speed"]
```

---

## Extensibilité

```gdscript
# Pour ajouter une nouvelle planète (DLC/Update):
PLANET_DATA[4] = {
    "name": "Jupiter",
    "emoji": "🪐",
    "power_required": 400,
    "waves": 6,  # Plus de vagues!
    "enemy_types": ["electric"],  # Nouveau type
    "boss": {
        "name": "Storm King",
        "hp": 2000,
        # ...
    }
}
```

---

## Tests de Validation

1. ✅ 4 planètes configurées avec toutes les données
2. ✅ Données accessibles par index
3. ✅ Boss configuré par planète
4. ✅ Nombre d'ennemis par vague défini
5. ✅ Structure facile à étendre

---

## Dépendances

- **Requiert**: Rien
- **Utilisé par**: LevelSelect, WaveController, CombatScene
