# Guide d'Intégration des Backgrounds

## 📁 Structure créée

```
assets/sprites/background/
├── README.md                    # Documentation des backgrounds
├── bg_main_menu.png            # (À ajouter)
├── bg_level_select.png         # (À ajouter)
├── bg_mercury_combat.png       # (À ajouter)
├── bg_venus_combat.png         # (À ajouter)
├── bg_mars_combat.png          # (À ajouter)
├── bg_earth_combat.png         # (À ajouter)
├── bg_profile_menu.png         # (À ajouter)
├── bg_shop_menu.png            # (À ajouter)
├── bg_victory.png              # (À ajouter)
├── bg_defeat.png               # (À ajouter)
└── ...
```

## 🔧 BackgroundManager

Un script utilitaire (`scripts/core/managers/background_manager.gd`) centralise la gestion des backgrounds.

### Utilisation

#### 1. **Pour un menu spécifique** :
```gdscript
# Dans main_menu.gd
func _ready() -> void:
    var bg_rect = TextureRect.new()
    bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg_rect, true)  # Avant le reste de la UI
    
    # Charger le background
    BackgroundManager.set_background(bg_rect, "main_menu")
```

#### 2. **Pour un menu par nom de scène** :
```gdscript
func _ready() -> void:
    var bg_rect = TextureRect.new()
    bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg_rect, true)
    
    # Auto-détecte le background selon le nom de la scène
    var scene_name = get_tree().current_scene.name
    BackgroundManager.set_background_by_scene(bg_rect, scene_name)
```

#### 3. **Pour le combat** (dynamique par planète) :
```gdscript
# Dans game_combat_scene.gd
func _ready() -> void:
    var bg_rect = TextureRect.new()
    bg_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg_rect, true)
    
    # Charger le background selon la planète actuelle
    BackgroundManager.set_background_by_planet(bg_rect, current_planet)
```

## 📋 Checklist d'intégration

### Étape 1 : Ajouter les fichiers PNG
- [ ] Placer les backgrounds PNG dans `assets/sprites/background/`
- [ ] Nommer les fichiers selon le pattern : `bg_[scene/planet]_[type].png`

### Étape 2 : Enregistrer comme Autoload (optionnel)
Pour utiliser `BackgroundManager` sans l'importer, ajouter dans `project.godot` :
```ini
[autoload]
BackgroundManager="res://scripts/core/managers/background_manager.gd"
```

### Étape 3 : Intégrer dans les scènes

#### Main Menu
```gdscript
# main_menu.gd _ready()
var bg = TextureRect.new()
bg.set_anchors_preset(Control.PRESET_FULL_RECT)
add_child(bg, true)
BackgroundManager.set_background(bg, "main_menu")
```

#### Level Select
```gdscript
# level_select.gd _ready()
var bg = TextureRect.new()
bg.set_anchors_preset(Control.PRESET_FULL_RECT)
add_child(bg, true)
BackgroundManager.set_background(bg, "level_select")
```

#### Combat
```gdscript
# game_combat_scene.gd _ready()
var bg = TextureRect.new()
bg.set_anchors_preset(Control.PRESET_FULL_RECT)
add_child(bg, true)
BackgroundManager.set_background_by_planet(bg, current_planet)
```

#### Profil/Shop
```gdscript
# profile_menu.gd ou shop_menu.gd _ready()
var bg = TextureRect.new()
bg.set_anchors_preset(Control.PRESET_FULL_RECT)
add_child(bg, true)
BackgroundManager.set_background(bg, "profile_menu")  # ou "shop_menu"
```

## 🎨 Options d'intégration

### Option 1 : Background statique simple (FACILE)
Le background est juste une texture statique en arrière-plan.
- Pas d'animation
- Pas d'effet parallaxe
- ✅ Performance excellente

### Option 2 : Background avec parallaxe (MOYEN)
Plusieurs couches d'étoiles/nébuleuses qui bougent à différentes vitesses.
```gdscript
# Pseudo-code
var layer1 = TextureRect.new()  # Étoiles (lent)
var layer2 = TextureRect.new()  # Nébuleuse (normal)
var layer3 = TextureRect.new()  # Particules (rapide)

func _process(delta: float) -> void:
    layer1.position.x += delta * 10
    layer2.position.x += delta * 20
    layer3.position.x += delta * 30
```

### Option 3 : Background animé (AVANCÉ)
Utiliser des animations subtiles (rotation, oscillation, pulsation).
```gdscript
# Pseudo-code
var tween = create_tween().set_loops()
tween.tween_property(bg, "modulate:a", 0.8, 3.0)
tween.tween_property(bg, "modulate:a", 1.0, 3.0)
```

## 📊 Noms de fichiers recommandés

| Scène | Fichier | Utilisé dans |
|-------|---------|--------------|
| Menu Principal | `bg_main_menu.png` | MainMenu.tscn |
| Sélection Niveau | `bg_level_select.png` | level_select.gd |
| Profil | `bg_profile_menu.png` | profile_menu.gd |
| Shop | `bg_shop_menu.png` | shop_menu.gd |
| Options | `bg_options_menu.png` | options_menu.gd |
| Pause | `bg_pause_menu.png` | Pause menu |
| Combat Mercure | `bg_mercury_combat.png` | Combat (planète 0) |
| Combat Vénus | `bg_venus_combat.png` | Combat (planète 1) |
| Combat Mars | `bg_mars_combat.png` | Combat (planète 2) |
| Combat Terre | `bg_earth_combat.png` | Combat (planète 3) |
| Victoire | `bg_victory.png` | Game Over (victoire) |
| Défaite | `bg_defeat.png` | Game Over (défaite) |

## 🚀 Prochaines étapes

1. **Créer les assets** : Dessiner ou générer les 10+ backgrounds PNG
2. **Intégrer dans les scènes** : Ajouter le code dans chaque menu/combat
3. **Optimiser** : Compiler les images pour mobile, ajuster la compression
4. **Tester** : Vérifier que les backgrounds s'affichent correctement sur différentes résolutions

## 💡 Conseils de performance

- **Compression** : Utiliser PNG avec 8 bits si possible (plutôt que 32 bits)
- **Résolution** : 720x1280 est optimal pour le jeu (évite l'upscaling)
- **Cache** : Les backgrounds sont cachés après le premier chargement
- **Parallaxe** : Limiter à 2-3 couches maximum pour ne pas surcharger
