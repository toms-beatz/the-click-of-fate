# Backgrounds - Fonds d'écran

Ce dossier contient tous les fonds d'écran pour les différentes scènes du jeu.

## Structure recommandée

### Menus Généraux
```
bg_main_menu.png          # Fond principal du menu (titre/début)
bg_space_nebula.png       # Nébuleuse spatiale générique
bg_stars.png              # Ciel étoilé animé
```

### Sélection de Niveau
```
bg_level_select.png       # Fond du carrousel de planètes
bg_space_static.png       # Espace statique avec étoiles
```

### Combat par Planète
```
bg_mercury_combat.png     # Mercure (soleil proche, roche brûlante)
bg_venus_combat.png       # Vénus (atmosphère jaune toxique)
bg_mars_combat.png        # Mars (roche rouge, poussière)
bg_earth_combat.png       # Terre (bleu océan, atmosphère)
```

### UI Complémentaires
```
bg_profile_menu.png       # Profil du joueur
bg_shop_menu.png          # Boutique
bg_victory.png            # Victoire
bg_defeat.png             # Défaite
```

### Particules/Effets
```
particle_stars.png        # Étoiles pour parallaxe
particle_nebula.png       # Nébuleuse animée
```

## Spécifications Techniques

- **Format** : PNG avec transparence (optionnel)
- **Résolution** : 720x1280 (résolution cible du jeu)
- **Alternative** : 1440x2560 (2x) ou 360x640 (0.5x) pour scalabilité
- **Compression** : Optimisée pour mobile

## Utilisation dans le Jeu

### Main Menu
```gdscript
var bg_texture = load("res://assets/sprites/background/bg_main_menu.png")
```

### Level Select
```gdscript
var bg_texture = load("res://assets/sprites/background/bg_level_select.png")
```

### Combat (dynamique par planète)
```gdscript
var bg_texture = load("res://assets/sprites/background/bg_%s_combat.png" % planet_name.to_lower())
```

### Menus
```gdscript
var bg_texture = load("res://assets/sprites/background/bg_%s_menu.png" % menu_name.to_lower())
```

## Options d'Intégration

### Option 1 : Background statique (simple)
Ajouter directement un TextureRect en arrière-plan de chaque scène.

### Option 2 : Parallaxe (avancé)
Utiliser un parallaxe avec plusieurs couches d'étoiles/nébuleuses qui bougent à différentes vitesses.

### Option 3 : Animation (cinématique)
Utiliser des animations subtiles (rotation légère, oscillation de couleur) sur le fond.
