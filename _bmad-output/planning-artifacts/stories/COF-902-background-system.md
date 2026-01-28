# COF-902: Background System

**Epic**: Visual Assets  
**Status**: 🔄 IN PROGRESS  
**Priority**: Medium  
**Fichiers**: 
- `assets/sprites/background/` (dossier)
- `scripts/core/managers/background_manager.gd`
- `BACKGROUNDS_SETUP.md`

---

## User Story

**En tant que** game designer,  
**Je veux** pouvoir ajouter différents fonds d'écran pour chaque scène,  
**Afin de** créer une ambiance visuelle unique pour le menu, la sélection de niveau, le combat et les menus secondaires.

---

## Description

Système centralisé de gestion des backgrounds avec :
- Dossier organisé `assets/sprites/background/`
- Script `BackgroundManager` pour charger facilement les textures
- Support dynamique des backgrounds par scène et par planète
- Cache pour optimiser les performances

---

## Assets Requis

### Menus
| Fichier | Utilisation | Status |
|---------|------------|--------|
| `bg_main_menu.png` | Menu principal | ❌ À créer |
| `bg_level_select.png` | Sélection de niveau | ❌ À créer |
| `bg_profile_menu.png` | Profil du joueur | ❌ À créer |
| `bg_shop_menu.png` | Boutique | ❌ À créer |
| `bg_options_menu.png` | Options | ❌ À créer |
| `bg_pause_menu.png` | Menu pause | ❌ À créer |

### Combat par Planète
| Fichier | Planète | Status |
|---------|---------|--------|
| `bg_mercury_combat.png` | Mercure | ❌ À créer |
| `bg_venus_combat.png` | Vénus | ❌ À créer |
| `bg_mars_combat.png` | Mars | ❌ À créer |
| `bg_earth_combat.png` | Terre | ❌ À créer |

### Game Over
| Fichier | Utilisation | Status |
|---------|------------|--------|
| `bg_victory.png` | Écran victoire | ❌ À créer |
| `bg_defeat.png` | Écran défaite | ❌ À créer |

---

## Critères d'Acceptation

### Système BackgroundManager
- [x] Classe `BackgroundManager` avec cache de textures
- [x] Méthode `set_background(rect, key)` pour charger un background
- [x] Méthode `set_background_by_planet(rect, planet_index)` pour les combats
- [x] Méthode `set_background_by_scene(rect, scene_name)` pour auto-détection
- [x] Support du préchargement et du cache clearing
- [x] Gestion des erreurs si background manquant

### Dossier et Documentation
- [x] Dossier `assets/sprites/background/` créé
- [x] `README.md` avec structure recommandée
- [x] `BACKGROUNDS_SETUP.md` avec guide d'intégration
- [x] Config `BG_PATHS` avec tous les chemins de fichiers

### Intégration dans les Scènes
- [ ] Main Menu intégré
- [ ] Level Select intégré
- [ ] Combat intégré (dynamique par planète)
- [ ] Profile Menu intégré
- [ ] Shop Menu intégré
- [ ] Pause Menu intégré
- [ ] Victory/Defeat Screens intégrés

---

## Implémentation

### BackgroundManager

```gdscript
class_name BackgroundManager
extends Node

var _texture_cache: Dictionary = {}

const BG_PATHS := {
    "main_menu": "res://assets/sprites/background/bg_main_menu.png",
    "level_select": "res://assets/sprites/background/bg_level_select.png",
    "combat_mercury": "res://assets/sprites/background/bg_mercury_combat.png",
    # ... tous les autres backgrounds
}

func set_background(rect: TextureRect, background_key: String) -> void:
    var texture = _get_texture(background_key)
    if texture:
        rect.texture = texture
        rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func set_background_by_planet(rect: TextureRect, planet_index: int) -> void:
    var planet_name = ["mercury", "venus", "mars", "earth"][planet_index]
    set_background(rect, "combat_%s" % planet_name)
```

### Utilisation dans une scène

```gdscript
# Dans level_select.gd _ready()
var bg = TextureRect.new()
bg.set_anchors_preset(Control.PRESET_FULL_RECT)
add_child(bg, true)
BackgroundManager.set_background(bg, "level_select")
```

---

## Tâches Restantes

### Priorité Haute
1. [ ] Créer les 4 backgrounds de combat (Mercury, Venus, Mars, Earth)
2. [ ] Créer les 6 backgrounds de menus (Main, Level Select, Profile, Shop, Options, Pause)
3. [ ] Créer les 2 backgrounds de game over (Victory, Defeat)

### Priorité Moyenne
4. [ ] Intégrer BackgroundManager dans `project.godot` comme Autoload
5. [ ] Ajouter les backgrounds à main_menu.gd
6. [ ] Ajouter les backgrounds à level_select.gd
7. [ ] Ajouter les backgrounds à game_combat_scene.gd

### Priorité Basse
8. [ ] Ajouter parallaxe optionnel aux backgrounds
9. [ ] Animer légèrement les backgrounds (pulsation, oscillation)
10. [ ] Créer des variantes animées (étoiles scintillantes, nébuleuses)

---

## Spécifications Techniques

**Format** : PNG avec transparence  
**Résolution** : 720x1280 (ou multiples : 360x640, 1440x2560)  
**Compression** : 8 bits si possible (pour mobile)  
**Couleur** : sRGB  

---

## Notes

- Les backgrounds seront cachés en mémoire après leur premier chargement
- Le système supporte le changement dynamique de background en runtime
- Chaque planète de combat a son propre background pour l'immersion
- Les menus utilisent un background global (pas dynamique par menu)
