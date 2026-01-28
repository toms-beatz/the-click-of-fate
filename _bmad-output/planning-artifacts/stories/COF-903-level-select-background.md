# COF-903: Level Select Background Display

**Epic**: Visual Assets & UI Polish  
**Status**: ✅ DONE  
**Priority**: High  
**Sprint**: Current  

---

## User Story

**En tant que** joueur,  
**Je veux** voir un background spatial immersif sur l'écran de sélection de niveau,  
**Afin de** renforcer l'ambiance du jeu et avoir une expérience visuelle cohérente.

---

## Description

Afficher le background `background-menu-selection.png` en permanence sur l'écran de sélection de niveau (Level Select), avec une opacité de 50% pour ne pas gêner la lisibilité des éléments UI.

Le background doit rester **toujours visible**, même pendant les animations d'entrée de la scène.

---

## Acceptance Criteria

### Fonctionnels
- [x] Le background est chargé depuis `res://assets/sprites/background/background-menu-selection.png`
- [x] Le background couvre tout l'écran (PRESET_FULL_RECT)
- [x] Le background a une opacité de 50% (modulate alpha = 0.5)
- [x] Le background reste visible pendant toute la durée de la scène
- [x] Le background n'est PAS affecté par les animations d'entrée (fade-in du carousel)
- [x] Le background ne bloque pas les interactions utilisateur (mouse_filter = IGNORE)

### Techniques
- [x] Utilisation d'un CanvasLayer séparé (layer = -1) pour isoler le background
- [x] Nettoyage propre du CanvasLayer dans `_exit_tree()`
- [x] Pas d'erreurs GDScript

---

## Technical Implementation

### Architecture

```
LevelSelect (Control)
├── BackgroundLayer (CanvasLayer, layer=-1)  ← NOUVEAU
│   └── BackgroundImage (TextureRect)
├── SpaceshipsBackground (Control, z_index=-10)
│   └── [Spaceship sprites...]
├── CarouselContainer
│   └── [Planet nodes...]
└── [UI Elements...]
```

### Fichier modifié
`scripts/ui/level_select.gd`

### Variables ajoutées
```gdscript
var background_layer: CanvasLayer
var background_rect: TextureRect
const BACKGROUND_PATH := "res://assets/sprites/background/background-menu-selection.png"
```

### Fonction _create_background()
```gdscript
func _create_background() -> void:
    # Créer un CanvasLayer séparé (layer -1 = derrière tout)
    background_layer = CanvasLayer.new()
    background_layer.name = "BackgroundLayer"
    background_layer.layer = -1
    add_child(background_layer)
    
    # Créer le TextureRect
    background_rect = TextureRect.new()
    background_rect.name = "BackgroundImage"
    
    var bg_texture = load(BACKGROUND_PATH)
    if bg_texture:
        background_rect.texture = bg_texture
    else:
        push_warning("Background non trouvé: " + BACKGROUND_PATH)
        return
    
    # Configuration
    background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background_rect.stretch_mode = TextureRect.STRETCH_SCALE
    background_rect.modulate = Color(1.0, 1.0, 1.0, 0.5)  # 50% opacité
    background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    background_rect.size = get_viewport().get_visible_rect().size
    
    background_layer.add_child(background_rect)
```

### Fonction _exit_tree()
```gdscript
func _exit_tree() -> void:
    if background_layer and is_instance_valid(background_layer):
        background_layer.queue_free()
```

---

## Problème Résolu

### Symptôme initial
Le background disparaissait après quelques millisecondes lors de l'entrée dans la scène.

### Cause racine
L'animation `_animate_entrance()` faisait un fade-in (`modulate.a = 0.0 → 1.0`) sur le Control parent, ce qui affectait **tous les enfants**, y compris le background.

### Solution
Utiliser un **CanvasLayer** avec `layer = -1` pour isoler le background de la hiérarchie de rendu principale. Les CanvasLayers sont des couches de rendu indépendantes qui ne sont pas affectées par les propriétés `modulate` de leurs parents.

---

## Assets Utilisés

| Asset | Chemin | Taille |
|-------|--------|--------|
| Background Menu Selection | `res://assets/sprites/background/background-menu-selection.png` | 2 MB |

---

## Tests Manuels

| Test | Résultat attendu | Status |
|------|------------------|--------|
| Lancer Level Select depuis Main Menu | Background visible immédiatement | ✅ |
| Observer l'animation d'entrée | Planètes font "pop", background reste fixe | ✅ |
| Swiper entre les planètes | Background reste en place | ✅ |
| Cliquer sur Play | Transition vers combat, background ne "flash" pas | ✅ |
| Revenir au Level Select | Background réapparaît correctement | ✅ |

---

## Definition of Done

- [x] Code implémenté et testé
- [x] Pas d'erreurs dans la console Godot
- [x] Background visible à 50% d'opacité en permanence
- [x] Animations UI n'affectent pas le background
- [x] Story documentée

---

## Notes Techniques

### Pourquoi CanvasLayer et pas z_index ?

| Approche | Problème |
|----------|----------|
| `z_index = -20` | Affecté par `modulate.a` du parent Control |
| `move_child(bg, 0)` | Toujours dans la même hiérarchie de rendu |
| **CanvasLayer** | Couche de rendu **totalement indépendante** ✅ |

### Performance
- La texture est chargée une seule fois avec `load()`
- Le CanvasLayer n'ajoute pas de surcharge significative
- Le background est nettoyé dans `_exit_tree()` pour éviter les fuites mémoire

---

## Related Stories

- COF-902: Background System (infrastructure générale)
- COF-808: Fullscreen Background Images (backgrounds de combat)
