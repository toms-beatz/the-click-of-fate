# COF-906: Combat Buttons Visual Redesign

**Epic**: Visual Assets & UI Polish  
**Status**: ✅ DONE  
**Priority**: High  
**Sprint**: Current  

---

## User Story

**En tant que** joueur,  
**Je veux** des boutons d'action visuellement attractifs et tactiles dans le combat,  
**Afin de** avoir un feedback clair sur mes actions et une expérience de jeu premium sur mobile.

---

## Description

Refonte complète des boutons de combat :
- **Boutons secondaires** : HEAL, CRIT, SHIELD, NOVA (petits, carrés, colorés)
- **Boutons principaux** : HEAL, DODGE, ATTACK (grands, rectangulaires, glossy)

Avec effets visuels néon, animations tactiles, et feedback visuel de cooldown.

---

## Design Specifications

### 🔲 Boutons Secondaires (HEAL, CRIT, SHIELD, NOVA)

| Propriété | Valeur |
|-----------|--------|
| **Taille** | 15-20% largeur écran, ~64x64 pixels |
| **Forme** | Carré avec coins légèrement arrondis (4-6px) |
| **Bordure** | Fine blanche glowing (1-2px) |

#### Couleurs par bouton :
| Bouton | Fond | Icône | Hex |
|--------|------|-------|-----|
| HEAL | Vert émeraude | ❤️ Cœur | #10B981 |
| CRIT | Orange vif | ⚡ Éclair | #F59E0B |
| SHIELD | Cyan clair | 🛡️ Bouclier | #06B6D4 |
| NOVA | Magenta | ⭐ Étoile | #EC4899 |

#### Style :
```
┌─────────┐
│  ❤️     │  ← Icône centrée
│  HEAL   │  ← Texte petit bold
├─────────┤
│▓▓▓▓░░░░░│  ← Barre cooldown
└─────────┘
```

#### Effets :
- Bordure néon pulsant subtile (animation loop)
- Ombre portée légère en bas (2-4px, noir 30%)
- Pressed : enfoncé 2px + assombrissement 20%
- Cooldown : barre horizontale verte sous l'icône

#### Position :
- Centrés horizontalement en rangée
- Espacement : 8-12 pixels entre chaque
- Au-dessus des boutons principaux

---

### 🔳 Boutons Principaux (HEAL, DODGE, ATTACK)

| Propriété | Valeur |
|-----------|--------|
| **Taille** | 25-30% largeur écran, hauteur 80-100px |
| **Forme** | Rectangulaire arrondi (8-12px radius) |
| **Zone tactile** | Min 48x48 points effectifs |

#### Couleurs par bouton :
| Bouton | Fond dégradé | Icône | Hex Principal |
|--------|--------------|-------|---------------|
| HEAL | Vert glowing | ❤️ Cœur massif | #00FF00 → #10B981 |
| DODGE | Bleu dynamique | ↪️ Flèche courbe | #0066FF → #3B82F6 |
| ATTACK | Rouge flamboyant | ⚔️ Épée/Lame | #FF0000 → #EF4444 |

#### Style :
```
┌───────────────────────┐
│        ATTACK         │  ← Texte XXL bold luminescent
│          ⚔️           │  ← Icône géante pixel art
│                       │
└───────────────────────┘
   ↑ Bevel haut clair
   ↓ Bevel bas sombre (effet 3D)
```

#### Structure visuelle :
- Fond : Dégradé glossy (couleur → couleur sombre)
- Texte : XXL bold blanc/luminescent centré
- Bordure : Néon épaisse (3-4px) même couleur + blanc
- Bevel : Haut clair / Bas sombre pour effet 3D pressable

#### Effets :
| État | Effet |
|------|-------|
| Normal | Glow subtil autour |
| Hover | Scale 1.05 + glow intensifié + outline blanche |
| Pressed | Scale 0.95 + shift down 2px + ombre interne |
| Disabled | Gris 50% transparence |

#### Position :
- Rangée centrée sous les boutons secondaires
- Légèrement remontés (éviter bords écran)
- Espacement : 16 pixels latéraux

---

## Acceptance Criteria

### Boutons Secondaires
- [ ] 4 boutons carrés (HEAL, CRIT, SHIELD, NOVA)
- [ ] Taille ~64x64 pixels (15-20% largeur)
- [ ] Couleurs vives distinctes par action
- [ ] Icône pixel art centrée
- [ ] Texte petit bold en dessous
- [ ] Bordure blanche glowing
- [ ] Animation pulsation néon subtile
- [ ] Ombre portée légère
- [ ] État pressed visible (enfoncé + sombre)
- [ ] Barre de cooldown horizontale

### Boutons Principaux
- [ ] 3 boutons rectangulaires (HEAL, DODGE, ATTACK)
- [ ] Taille 25-30% largeur, hauteur 80-100px
- [ ] Fond dégradé glossy coloré
- [ ] Texte XXL bold luminescent
- [ ] Icône géante pixel art
- [ ] Bordure néon épaisse
- [ ] Effet 3D bevel (haut clair/bas sombre)
- [ ] Hover : scale 1.05 + glow
- [ ] Pressed : scale 0.95 + shift down
- [ ] Disabled : gris 50%

### Technique
- [ ] Responsive (iOS/Android)
- [ ] Zone tactile min 48x48
- [ ] Contraste >4.5:1 pour accessibilité
- [ ] Animations easing fluides
- [ ] Performance OK sur mobile

---

## Technical Implementation

### Fichiers à modifier
- `scenes/game_combat_scene.gd` - Création des boutons
- `scripts/ui/click_zone_button.gd` - Si existant, style

### Constantes de couleurs
```gdscript
# Boutons secondaires
const COLOR_HEAL_SECONDARY := Color("#10B981")  # Vert émeraude
const COLOR_CRIT := Color("#F59E0B")            # Orange vif
const COLOR_SHIELD := Color("#06B6D4")          # Cyan clair
const COLOR_NOVA := Color("#EC4899")            # Magenta

# Boutons principaux
const COLOR_HEAL_PRIMARY := Color("#00FF00")    # Vert glowing
const COLOR_DODGE := Color("#0066FF")           # Bleu dynamique
const COLOR_ATTACK := Color("#FF0000")          # Rouge flamboyant

# États
const COLOR_DISABLED := Color(0.5, 0.5, 0.5, 0.5)
const COLOR_GLOW_WHITE := Color(1, 1, 1, 0.6)
```

### Fonction de création de bouton stylisé
```gdscript
func _create_action_button(text: String, icon: String, color: Color, is_primary: bool) -> Button:
    var button := Button.new()
    var viewport_size := get_viewport().get_visible_rect().size
    
    if is_primary:
        # Bouton principal (25-30% largeur, 80-100px hauteur)
        var btn_width := int(viewport_size.x * 0.28)
        var btn_height := 90
        button.custom_minimum_size = Vector2(btn_width, btn_height)
        button.text = text
        
        # Style avec dégradé
        var style := StyleBoxFlat.new()
        style.bg_color = color
        style.border_color = color.lightened(0.3)
        style.border_width_top = 3
        style.border_width_bottom = 3
        style.border_width_left = 3
        style.border_width_right = 3
        style.corner_radius_top_left = 12
        style.corner_radius_top_right = 12
        style.corner_radius_bottom_left = 12
        style.corner_radius_bottom_right = 12
        style.shadow_color = Color(0, 0, 0, 0.4)
        style.shadow_size = 4
        style.shadow_offset = Vector2(0, 3)
        
        button.add_theme_stylebox_override("normal", style)
        button.add_theme_font_size_override("font_size", 24)
        button.add_theme_color_override("font_color", Color.WHITE)
    else:
        # Bouton secondaire (64x64)
        button.custom_minimum_size = Vector2(64, 64)
        button.text = icon + "\n" + text
        
        var style := StyleBoxFlat.new()
        style.bg_color = color
        style.border_color = Color.WHITE
        style.border_width_top = 2
        style.border_width_bottom = 2
        style.border_width_left = 2
        style.border_width_right = 2
        style.corner_radius_top_left = 6
        style.corner_radius_top_right = 6
        style.corner_radius_bottom_left = 6
        style.corner_radius_bottom_right = 6
        style.shadow_color = Color(0, 0, 0, 0.3)
        style.shadow_size = 2
        style.shadow_offset = Vector2(0, 2)
        
        button.add_theme_stylebox_override("normal", style)
        button.add_theme_font_size_override("font_size", 12)
        button.add_theme_color_override("font_color", Color.WHITE)
    
    return button
```

### Animation hover/pressed
```gdscript
func _animate_button_hover(button: Button) -> void:
    var tween := create_tween()
    tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.1).set_ease(Tween.EASE_OUT)

func _animate_button_press(button: Button) -> void:
    var tween := create_tween()
    tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
    tween.tween_property(button, "position:y", button.position.y + 2, 0.05)
    tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
    tween.tween_property(button, "position:y", button.position.y, 0.1)

func _animate_button_disabled(button: Button) -> void:
    button.modulate = COLOR_DISABLED
```

### Barre de cooldown
```gdscript
func _create_cooldown_bar(parent: Control, width: int) -> ProgressBar:
    var bar := ProgressBar.new()
    bar.custom_minimum_size = Vector2(width, 6)
    bar.max_value = 100
    bar.value = 100
    bar.show_percentage = false
    
    var style_bg := StyleBoxFlat.new()
    style_bg.bg_color = Color(0.2, 0.2, 0.2, 0.8)
    bar.add_theme_stylebox_override("background", style_bg)
    
    var style_fill := StyleBoxFlat.new()
    style_fill.bg_color = Color("#10B981")  # Vert
    bar.add_theme_stylebox_override("fill", style_fill)
    
    parent.add_child(bar)
    return bar
```

---

## Layout Mockup

```
┌─────────────────────────────────────────────┐
│                                             │
│              [Combat Zone]                  │
│                                             │
├─────────────────────────────────────────────┤
│                                             │
│   ┌────┐  ┌────┐  ┌────┐  ┌────┐           │
│   │ ❤️ │  │ ⚡ │  │ 🛡️ │  │ ⭐ │           │  ← Secondaires
│   │HEAL│  │CRIT│  │SHLD│  │NOVA│           │
│   │▓▓░░│  │▓▓▓░│  │░░░░│  │▓▓▓▓│           │  ← Cooldowns
│   └────┘  └────┘  └────┘  └────┘           │
│                                             │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐    │
│  │   HEAL   │ │  DODGE   │ │  ATTACK  │    │  ← Principaux
│  │    ❤️    │ │    ↪️    │ │    ⚔️    │    │
│  └──────────┘ └──────────┘ └──────────┘    │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Palette Complète

| Élément | Couleur | Hex | Usage |
|---------|---------|-----|-------|
| Heal Secondary | Vert émeraude | #10B981 | Bouton secondaire |
| Crit | Orange vif | #F59E0B | Bouton secondaire |
| Shield | Cyan clair | #06B6D4 | Bouton secondaire |
| Nova | Magenta | #EC4899 | Bouton secondaire |
| Heal Primary | Vert glowing | #00FF00 | Bouton principal |
| Dodge | Bleu dynamique | #0066FF | Bouton principal |
| Attack | Rouge flamboyant | #FF0000 | Bouton principal |
| Disabled | Gris | #808080 50% | État inactif |
| Glow | Blanc | #FFFFFF 60% | Effet lumineux |
| Shadow | Noir | #000000 30-40% | Ombre portée |

---

## Tests Manuels

| Test | Résultat attendu | Status |
|------|------------------|--------|
| Affichage boutons secondaires | 4 boutons carrés colorés visibles | 🔲 |
| Affichage boutons principaux | 3 boutons rectangulaires glossy | 🔲 |
| Tap sur bouton principal | Scale 0.95 + shift down + action | 🔲 |
| Cooldown visible | Barre verte se vide progressivement | 🔲 |
| Bouton disabled | Grisé 50%, non cliquable | 🔲 |
| Responsive mobile | Taille adaptée à l'écran | 🔲 |
| Contraste accessible | Texte lisible sur tous les fonds | 🔲 |

---

## Definition of Done

- [ ] Boutons secondaires stylisés (4)
- [ ] Boutons principaux stylisés (3)
- [ ] Animations hover/pressed
- [ ] Barres de cooldown
- [ ] États disabled
- [ ] Responsive mobile
- [ ] Pas d'erreurs GDScript
- [ ] Performance OK

---

## Notes Techniques

### Pixel Art Tips
- Anti-aliasing minimal pour netteté
- Dithering pour dégradés subtils
- Outline 1px sombre pour pop-out sur gameplay chaotique

### Accessibilité
- Ratio contraste >4.5:1 (WCAG AA)
- Zone tactile min 48x48 points
- Feedback visuel clair sur tous les états

### Performance
- Éviter trop d'animations simultanées
- Recycler les tweens si possible
- Textures optimisées pour mobile

---

## Related Stories

- COF-905: Main Menu Visual Redesign
- COF-903: Level Select Background Display
