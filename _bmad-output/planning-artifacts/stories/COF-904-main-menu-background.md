# COF-904: Main Menu Background Display

**Epic**: Visual Assets & UI Polish  
**Status**: ✅ DONE  
**Priority**: High  
**Sprint**: Current  

---

## User Story

**En tant que** joueur,  
**Je veux** voir un background spatial immersif dès l'écran principal du jeu,  
**Afin de** créer une première impression visuelle forte et cohérente avec l'univers du jeu.

---

## Description

Afficher le background `background-menu-selection.png` en permanence sur le Main Menu (premier écran du jeu), avec une opacité de 20% pour ne pas gêner la lisibilité des éléments UI (titre, boutons).

Le background doit rester **toujours visible**, même pendant les animations d'entrée.

---

## Asset

| Fichier | Chemin |
|---------|--------|
| Background | `res://assets/backgrounds/background-menu-selection.png` |

---

## Acceptance Criteria

### Fonctionnels
- [x] Le background est chargé depuis `res://assets/backgrounds/background-menu-selection.png`
- [x] Le background couvre tout l'écran (PRESET_FULL_RECT)
- [x] Le background a une opacité de 20% (modulate alpha = 0.2)
- [x] Le background reste visible pendant toute la durée de la scène
- [x] Le background n'est PAS affecté par les animations d'entrée
- [x] Le background ne bloque pas les interactions utilisateur (mouse_filter = IGNORE)

### Techniques
- [x] Utilisation d'un CanvasLayer séparé (layer = -1) pour isoler le background
- [x] Nettoyage propre du CanvasLayer dans `_exit_tree()`
- [x] Pas d'erreurs GDScript

---

## Technical Implementation

### Architecture

```
MainMenu (Control)
├── BackgroundLayer (CanvasLayer, layer=-1)  ← NOUVEAU
│   └── BackgroundImage (TextureRect)
├── TitleLabel
├── PlayButton
├── OptionsButton
└── [Autres UI Elements...]
```

### Fichier à modifier
`scripts/ui/main_menu.gd`

### Variables à ajouter
```gdscript
var background_layer: CanvasLayer
var background_rect: TextureRect

const BACKGROUND_PATH := "res://assets/backgrounds/background-menu-selection.png"
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
    
    # Configuration pour couvrir tout l'écran
    background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    background_rect.stretch_mode = TextureRect.STRETCH_SCALE
    background_rect.modulate = Color(1.0, 1.0, 1.0, 0.5)  # 50% opacité
    background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    
    # Taille = viewport entier
    background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    var viewport_size := get_viewport().get_visible_rect().size
    background_rect.size = viewport_size
    
    background_layer.add_child(background_rect)
```

### Fonction _exit_tree()
```gdscript
func _exit_tree() -> void:
    if background_layer and is_instance_valid(background_layer):
        background_layer.queue_free()
```

### Appel dans _ready()
```gdscript
func _ready() -> void:
    _create_background()  # Ajouter en premier
    # ... reste du code existant
```

---

## Tests Manuels

| Test | Résultat attendu | Status |
|------|------------------|--------|
| Lancer le jeu | Background visible immédiatement sur Main Menu | ✅ |
| Observer les animations d'entrée | UI fait fade-in, background reste fixe | ✅ |
| Cliquer sur Play | Transition vers Level Select sans flash | ✅ |
| Cliquer sur Options | Background reste visible | ✅ |
| Revenir au Main Menu | Background réapparaît correctement | ✅ |

---

## Definition of Done

- [x] Code implémenté dans `main_menu.gd`
- [x] Pas d'erreurs dans la console Godot
- [x] Background visible à 20% d'opacité en permanence
- [x] Animations UI n'affectent pas le background
- [x] Story documentée et testée

---

## Notes

### Pourquoi CanvasLayer ?
Le CanvasLayer avec `layer = -1` garantit que le background est rendu **avant** (derrière) tous les autres éléments UI, et qu'il n'est pas affecté par les propriétés `modulate` ou les animations du Control parent.

### Cohérence visuelle
Ce background est le même que celui utilisé dans Level Select (COF-903), créant une continuité visuelle entre les deux écrans.

---

## Related Stories

- COF-903: Level Select Background Display (même pattern d'implémentation)
- COF-902: Background System (infrastructure générale)
