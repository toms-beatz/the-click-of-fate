# COF-905: Main Menu Visual Redesign - Sci-Fi Premium

**Epic**: Visual Assets & UI Polish  
**Status**: ✅ DONE  
**Priority**: High  
**Sprint**: Current  
**Référence**: `assets/inspiration/image.png`

---

## User Story

**En tant que** joueur,  
**Je veux** un menu principal avec un design sci-fi premium immersif,  
**Afin de** ressentir l'ambiance spatiale du jeu dès le lancement et avoir une première impression professionnelle.

---

## Description

Refonte complète du Main Menu pour correspondre exactement à l'image d'inspiration :
- Titre "CLICK OF FATE" avec effet néon holographique
- Sous-titre "Master your Fate"
- 3 boutons stylisés avec icônes orbitales
- Background cosmique avec étoiles et nébuleuses
- Compteur de monnaie et version en overlay

---

## Design Specifications

### 📐 Layout Général
| Propriété | Valeur |
|-----------|--------|
| Format | Mobile vertical 9:16 (720x1280) |
| Disposition | Éléments centrés verticalement |
| Espacement | Généreux, aéré |
| Hiérarchie | Titre (haut) → Zone vide → Boutons (centre-bas) |

### 🎯 Titre Principal
| Propriété | Valeur |
|-----------|--------|
| Texte | "CLICK OF FATE" |
| Style | Bold futuriste, effet néon blanc-bleu |
| Effet | Glowing 3D holographique |
| Taille | XXL dominante (~72-96px) |
| Position | Centre-haut (y: ~15% écran) |
| Couleur | Blanc (#FFFFFF) avec glow bleu (#00D4FF) |

### ✨ Sous-titre
| Propriété | Valeur |
|-----------|--------|
| Texte | "Master your Fate" |
| Style | Police élégante fine, luminescent |
| Taille | Moyenne (~24-32px) |
| Position | Juste sous le titre |
| Couleur | Blanc avec légère transparence |

### 🔘 Boutons (x3)
| Bouton | Texte | Icône | Description |
|--------|-------|-------|-------------|
| 1 | PLAY | ▶ (flèche) | Lancer le jeu |
| 2 | OPTIONS | ⚙ (engrenage) | Paramètres |
| 3 | QUIT | ✕ (X stylisé) | Quitter |

**Style des boutons :**
| Propriété | Valeur |
|-----------|--------|
| Forme | Rectangulaire arrondie (border_radius: 12-16px) |
| Largeur | ~70% de l'écran (504px) |
| Hauteur | ~60-70px par bouton |
| Fond | Semi-transparent sombre (Color(0.1, 0.1, 0.2, 0.7)) |
| Bordure | Luminescente bleue subtile (2px, #00D4FF, 50% opacity) |
| Texte | Blanc glowing, bold, ~28px |
| Icône | Bleu néon (#00D4FF), à gauche du texte |
| Espacement | ~20-30px entre chaque bouton |
| Position | Centre-bas (y: ~55-75% écran) |

### 🌌 Background
| Élément | Description |
|---------|-------------|
| Base | Dégradé noir (#0A0A0F) → bleu nuit (#0D1B2A) |
| Étoiles | Particules blanches scintillantes dispersées |
| Nébuleuses | Violettes (#8B5CF6) et roses (#EC4899) diffuses, floues |
| Planètes | Lointaines, rocheuses/gazeuses, profondeur |
| Animation | Particules stellaires traversant l'espace |

### 📊 Éléments Overlay
| Élément | Position | Style |
|---------|----------|-------|
| Monnaie "76815 SC" | Haut-droite | Digital néon, ~18px |
| Version "v1.0" | Bas-droite | Petite police futuriste, ~12px |

### 🎨 Palette de Couleurs
| Couleur | Hex | Usage | % |
|---------|-----|-------|---|
| Noir profond | #0A0A0F | Background principal | 70% |
| Bleu nuit | #0D1B2A | Dégradé background | - |
| Bleu néon | #00D4FF | Accents, icônes, glow | 20% |
| Blanc glowing | #FFFFFF | Textes principaux | 5% |
| Violet nébuleuse | #8B5CF6 | Accents background | 2.5% |
| Rose nébuleuse | #EC4899 | Accents background | 2.5% |

---

## Acceptance Criteria

### Layout & Structure
- [ ] Format 9:16 mobile (720x1280)
- [ ] Titre centré en haut (~15% Y)
- [ ] Sous-titre sous le titre
- [ ] 3 boutons centrés verticalement (55-75% Y)
- [ ] Espacement généreux entre éléments

### Titre "CLICK OF FATE"
- [ ] Police bold futuriste (ou fallback avec effet)
- [ ] Effet glow bleu autour du texte
- [ ] Taille XXL dominante
- [ ] Couleur blanc avec outline bleu néon

### Sous-titre "Master your Fate"
- [ ] Police fine élégante
- [ ] Taille moyenne sous le titre
- [ ] Effet luminescent subtil

### Boutons
- [ ] 3 boutons : PLAY, OPTIONS, QUIT
- [ ] Forme rectangulaire arrondie
- [ ] Fond semi-transparent sombre
- [ ] Bordure bleue luminescente
- [ ] Icônes bleues néon (▶, ⚙, ✕)
- [ ] Texte blanc glowing
- [ ] Effet hover/press visible

### Background
- [ ] Dégradé noir → bleu nuit
- [ ] Étoiles scintillantes (particules ou texture)
- [ ] Nébuleuses violettes/roses (optionnel si image dispo)
- [ ] Profondeur spatiale

### Overlay
- [ ] Compteur SC en haut-droite
- [ ] Version v1.0 en bas-droite

### Effets Visuels
- [ ] Glow sur textes et boutons
- [ ] Animation particules stellaires (bonus)
- [ ] Ombres douces sous UI

---

## Technical Implementation

### Fichiers à modifier
- `scripts/ui/main_menu.gd` - Logique et création dynamique
- `scenes/ui/main_menu.tscn` - Structure de base (si nécessaire)

### Approche recommandée

#### 1. Background avec shader ou texture
```gdscript
# Option A: Texture statique (plus simple)
var bg_texture = load("res://assets/backgrounds/background-menu-selection.png")

# Option B: Shader dégradé + particules (plus avancé)
# Créer un shader pour le dégradé cosmique
```

#### 2. Titre avec effet glow
```gdscript
# Utiliser un Label avec outline et shadow
title_label.add_theme_color_override("font_color", Color.WHITE)
title_label.add_theme_color_override("font_outline_color", Color("#00D4FF"))
title_label.add_theme_constant_override("outline_size", 4)
title_label.add_theme_constant_override("shadow_offset_x", 0)
title_label.add_theme_constant_override("shadow_offset_y", 2)
title_label.add_theme_color_override("font_shadow_color", Color("#00D4FF", 0.5))
```

#### 3. Boutons stylisés
```gdscript
func _create_styled_button(text: String, icon: String) -> Button:
    var button = Button.new()
    button.text = "  " + icon + "  " + text
    button.custom_minimum_size = Vector2(504, 65)
    
    # Style
    var style = StyleBoxFlat.new()
    style.bg_color = Color(0.1, 0.1, 0.2, 0.7)
    style.border_color = Color("#00D4FF", 0.5)
    style.border_width_bottom = 2
    style.border_width_top = 2
    style.border_width_left = 2
    style.border_width_right = 2
    style.corner_radius_top_left = 14
    style.corner_radius_top_right = 14
    style.corner_radius_bottom_left = 14
    style.corner_radius_bottom_right = 14
    button.add_theme_stylebox_override("normal", style)
    
    return button
```

#### 4. Particules stellaires (bonus)
```gdscript
# GPUParticles2D pour les étoiles qui bougent
var particles = GPUParticles2D.new()
particles.amount = 50
particles.lifetime = 4.0
# ... configuration particules
```

---

## Assets Requis

### Existants
| Asset | Chemin | Status |
|-------|--------|--------|
| Background | `res://assets/backgrounds/background-menu-selection.png` | ✅ Existe |

### À créer (optionnel)
| Asset | Description | Priority |
|-------|-------------|----------|
| Font futuriste | Police bold sci-fi | Medium |
| Icônes boutons | ▶ ⚙ ✕ en PNG/SVG | Low (Unicode fallback) |
| Texture étoiles | Pattern répétable | Low |

---

## Mockup Structure

```
┌─────────────────────────────────┐
│  ○○○                    76815 SC│  ← Header
│                                 │
│                                 │
│        ╔═══════════════╗        │
│        ║ CLICK OF FATE ║        │  ← Titre XXL glow
│        ╚═══════════════╝        │
│         Master your Fate        │  ← Sous-titre
│                                 │
│    ┌─────────────────────────┐  │
│    │   ▶   P L A Y           │  │  ← Bouton 1
│    └─────────────────────────┘  │
│    ┌─────────────────────────┐  │
│    │   ⚙   O P T I O N S     │  │  ← Bouton 2
│    └─────────────────────────┘  │
│    ┌─────────────────────────┐  │
│    │   ✕   Q U I T           │  │  ← Bouton 3
│    └─────────────────────────┘  │
│                                 │
│                           v1.0  │  ← Version
└─────────────────────────────────┘
        Background: Espace cosmique
```

---

## Tests Manuels

| Test | Résultat attendu | Status |
|------|------------------|--------|
| Lancer le jeu | Menu sci-fi visible immédiatement | 🔲 |
| Vérifier titre | "CLICK OF FATE" avec glow bleu | 🔲 |
| Vérifier sous-titre | "Master your Fate" visible | 🔲 |
| Vérifier boutons | 3 boutons stylisés avec icônes | 🔲 |
| Cliquer PLAY | Transition vers Level Select | 🔲 |
| Cliquer OPTIONS | Transition vers Options | 🔲 |
| Cliquer QUIT | Ferme l'application | 🔲 |
| Vérifier SC | Compteur affiché en haut-droite | 🔲 |
| Vérifier version | v1.0 en bas-droite | 🔲 |
| Comparer avec inspiration | Ressemblance ~90%+ | 🔲 |

---

## Definition of Done

- [ ] Layout correspond à l'image d'inspiration
- [ ] Titre avec effet glow néon
- [ ] Sous-titre présent
- [ ] 3 boutons stylisés avec icônes
- [ ] Background cosmique
- [ ] Compteur SC visible
- [ ] Version visible
- [ ] Pas d'erreurs GDScript
- [ ] Testé sur format 9:16

---

## Notes

### Priorités d'implémentation
1. **HIGH**: Layout + Boutons stylisés
2. **HIGH**: Titre avec glow
3. **MEDIUM**: Background cosmique
4. **LOW**: Particules animées
5. **LOW**: Font custom futuriste

### Limitations Godot
- Les effets de glow avancés peuvent nécessiter des shaders
- Les fonts custom doivent être importées (.ttf/.otf)
- Les particules 2D ont un coût performance sur mobile

---

## Related Stories

- COF-904: Main Menu Background Display
- COF-903: Level Select Background Display
