# 📋 STORY: Refonte Complète du Menu Profil (Style Shop Sci-Fi)

## 📌 Informations Générales

| Champ | Valeur |
|-------|--------|
| **ID** | STORY-PROFILE-REDESIGN-001 |
| **Titre** | Refonte du ProfileMenu dans le style visuel du ShopMenu |
| **Epic** | UI/UX Amélioration |
| **Priorité** | Haute |
| **Estimation** | 8-12h |
| **Fichiers concernés** | `scripts/ui/profile_menu.gd`, `scenes/ui/profile_menu.tscn` |

---

## 🎯 Objectif

Refondre complètement le menu Profil (`profile_menu.gd`) pour adopter le même style visuel Sci-Fi Néon que le Shop (`shop_menu.gd`), avec une nouvelle disposition centrée sur le héros et son équipement.

---

## 📐 Nouvelle Architecture Visuelle

### Layout Global (de haut en bas)

```
┌─────────────────────────────────────────────────────────────┐
│  ◀ RETOUR        PROFIL                    💰 1234 SC       │  ← HEADER (style shop)
├─────────────────────────────────────────────────────────────┤
│                                                             │
│     ┌─────────────────────────────────────────────┐         │
│     │  STATISTIQUES AMÉLIORABLES (style packs)    │         │  ← SECTION STATS
│     │  ❤️ PV +   ⚔️ ATK +   💨 ESQ +   💚 SOIN + │         │     (4 cards en grille 2x2)
│     └─────────────────────────────────────────────┘         │
│                                                             │
│                    ┌──────────────┐                         │
│                    │              │                         │
│                    │  🧑‍🚀 HERO   │                         │  ← SPRITE HERO (centré)
│                    │   SPRITE     │                         │
│                    │              │                         │
│                    └──────────────┘                         │
│                                                             │
│     ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│     │  ⚔️     │    │  🛡️     │    │  ⛑️     │              │  ← ÉQUIPEMENT ÉQUIPÉ
│     │  ARME   │    │ ARMURE  │    │ CASQUE  │              │     (3 cards)
│     │ Équipé  │    │ Équipée │    │ Équipé  │              │
│     └─────────┘    └─────────┘    └─────────┘              │
│                                                             │
│  ═══════════════════════════════════════════════════════   │  ← SÉPARATEUR
│                                                             │
│     INVENTAIRE - Équipements Possédés                       │  ← SECTION INVENTAIRE
│     [Tab ARMES] [Tab ARMURES] [Tab CASQUES]                │     (onglets style shop)
│                                                             │
│     ┌─────┐ ┌─────┐ ┌─────┐                                │     (grille 3xN)
│     │item1│ │item2│ │item3│  ← Clic = équiper             │
│     └─────┘ └─────┘ └─────┘                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Détails Techniques

### 1. Constantes de Design (reprises du shop_menu.gd)

```gdscript
## Couleurs Sci-Fi Néon
const COLOR_BLACK_DEEP := Color("#0A0A0F")
const COLOR_BLUE_NIGHT := Color("#0D1B2A")
const COLOR_NEON_CYAN := Color("#00D4FF")
const COLOR_NEON_PINK := Color("#FF3388")
const COLOR_NEON_GREEN := Color("#33FF88")
const COLOR_NEON_GOLD := Color("#FFD933")
const COLOR_NEON_PURPLE := Color("#AA44FF")
const COLOR_WHITE_GLOW := Color("#FFFFFF")
const COLOR_PANEL_BG := Color(0.03, 0.03, 0.12, 0.92)
const COLOR_TAB_ACTIVE := Color(0.1, 0.1, 0.25, 0.95)
const COLOR_TAB_INACTIVE := Color(0.05, 0.05, 0.15, 0.7)
const COLOR_SUCCESS := Color(0.2, 0.9, 0.4)
const COLOR_ERROR := Color(1.0, 0.3, 0.3)
```

### 2. Assets Nécessaires

| Asset | Chemin | Utilisation |
|-------|--------|-------------|
| Hero Sprite | `res://assets/sprites/hero/hero_idle.png` | Sprite central du héros |
| Background | `res://assets/backgrounds/background-menu-selection.png` | Fond du menu |
| Armes | `res://assets/sprites/ui/équipements/armes/*.png` | Images équipements |
| Armures | `res://assets/sprites/ui/équipements/armures/*.png` | Images équipements |
| Casques | `res://assets/sprites/ui/équipements/casques/*.png` | Images équipements |

---

## 📋 Critères d'Acceptation

### ✅ Header
- [x] Bouton retour `◀` avec style néon cyan
- [x] Titre "PROFIL" centré avec police 36px, outline cyan
- [x] Affichage monnaie avec bordure or (style identique au shop)

### ✅ Section Stats Améliorables (Style Packs 2x2)
- [x] Grille 2x2 avec 4 cards de stats
- [x] Chaque card contient:
  - Icône de la stat (❤️, ⚔️, 💨, 💚)
  - Nom de la stat
  - Valeur actuelle → Valeur suivante
  - Bouton `+` pour améliorer (avec coût en SC)
  - Niveau actuel / Niveau max
- [x] Bordure colorée selon le type (rouge PV, orange ATK, bleu ESQ, vert SOIN)
- [x] Bouton désactivé si max atteint ou pas assez de SC
- [x] Animation glow au clic

### ✅ Sprite du Héros
- [x] Image `hero_idle.png` centrée
- [x] Taille responsive (environ 35% de la largeur écran)
- [x] Légère animation de respiration (scale pulse)
- [x] Encadré par un panel avec bordure néon violet

### ✅ Équipement Équipé (3 Cards)
- [x] 3 cards alignées horizontalement
- [x] Chaque card affiche:
  - Type (ARME / ARMURE / CASQUE)
  - Image de l'équipement équipé (ou placeholder si aucun)
  - Nom de l'équipement
  - Bonus apporté (+X DMG, +X% ESQ, +X SOIN)
- [x] Bordure couleur selon type:
  - Arme: Rose/Rouge
  - Armure: Cyan
  - Casque: Vert
- [x] Si aucun équipement: afficher "Aucun" avec style grisé

### ✅ Section Inventaire
- [x] Titre "INVENTAIRE" avec style néon
- [x] 3 onglets cliquables: ARMES | ARMURES | CASQUES
- [x] Style onglets identique au shop (actif = rempli, inactif = outline)
- [x] Grille 3 colonnes sous les onglets
- [x] Chaque item affiche:
  - Image de l'équipement
  - Nom
  - Bonus
  - Indicateur si équipé (✓ vert)
- [x] Clic sur item non-équipé → l'équipe
- [x] Animation de transition entre onglets
- [x] Items non possédés affichés grisés avec "🔒 SHOP"

### ✅ Animations & Effets
- [x] Étoiles animées en background (comme le shop)
- [x] Fade in à l'entrée du menu
- [x] Hover/Pressed states sur tous les boutons
- [x] Feedback visuel à l'amélioration ("+1 stat!" message)

---

## 🔄 Flux Utilisateur

### Améliorer une Stat
1. Utilisateur clique sur le bouton `+` d'une stat
2. Vérification: niveau < max ET assez de SC
3. Si OK: déduire SC, augmenter niveau, refresh UI
4. Feedback: flash vert + animation de la valeur

### Équiper un Item
1. Utilisateur clique sur un item dans l'inventaire
2. Item s'équipe automatiquement dans le slot correspondant
3. Card équipement haut se met à jour
4. Ancien item retourne dans l'inventaire
5. Feedback: animation swap + son

---

## 📁 Structure du Code

### Méthodes Principales à Implémenter

```gdscript
# LIFECYCLE
func _ready() -> void
func _setup_full_ui() -> void

# BACKGROUND
func _create_background() -> void
func _create_stars_background() -> void
func _animate_star(star: ColorRect) -> void

# LAYOUT
func _create_main_layout() -> void
func _create_header(parent: Control) -> void
func _create_stats_section(parent: Control) -> void
func _create_hero_section(parent: Control) -> void
func _create_equipped_section(parent: Control) -> void
func _create_inventory_section(parent: Control) -> void

# STATS CARDS
func _create_stat_card(stat_id: String, card_width: float) -> Control
func _populate_stats_grid() -> void

# EQUIPMENT
func _create_equipped_card(slot: String, card_width: float) -> Control
func _create_inventory_card(item_data: Dictionary, card_width: float) -> Control
func _populate_inventory() -> void

# TABS
func _on_inventory_tab_pressed(tab_key: String) -> void
func _update_inventory_tab_styles() -> void

# INTERACTIONS
func _on_upgrade_stat(stat_id: String) -> void
func _on_equip_item(slot: String, item_id: String) -> void

# STYLES
func _style_button_neon(btn: Button, color: Color, filled: bool = false) -> void
func _show_feedback(message: String, success: bool) -> void

# ANIMATIONS
func _animate_entrance() -> void
func _animate_hero() -> void
```

---

## 🎨 Mockup Couleurs par Section

| Section | Couleur Principale | Couleur Bordure |
|---------|-------------------|-----------------|
| Header | `#0D1B2A` | `#00D4FF` (cyan) |
| Stats PV | `#1a0a0a` | `#FF3388` (rose/rouge) |
| Stats ATK | `#1a100a` | `#FF6633` (orange) |
| Stats ESQ | `#0a0a1a` | `#00D4FF` (cyan) |
| Stats SOIN | `#0a1a0a` | `#33FF88` (vert) |
| Hero Frame | `#0D1B2A` | `#AA44FF` (violet) |
| Équip Arme | `#1a0a0a` | `#FF3388` |
| Équip Armure | `#0a0a1a` | `#00D4FF` |
| Équip Casque | `#0a1a0a` | `#33FF88` |
| Inventaire | `#0a0a0f` | `#AA44FF` |

---

## 📊 Données à Utiliser

### Stats (déjà dans profile_menu.gd)
```gdscript
const UPGRADES_CONFIG := {
    "max_hp": {"name": "PV Max", "icon": "❤️", ...},
    "attack_power": {"name": "Dégâts", "icon": "⚔️", ...},
    "dodge_chance": {"name": "Esquive", "icon": "💨", ...},
    "heal_power": {"name": "Soin", "icon": "💚", ...}
}
```

### Équipements (utiliser ceux du shop_menu.gd)
```gdscript
const EQUIPMENT_DATA := {
    "weapon": {"title": "ARMES", "items": [...]},
    "armor": {"title": "ARMURES", "items": [...]},
    "helmet": {"title": "CASQUES", "items": [...]}
}
```

---

## 🧪 Tests à Effectuer

1. **Responsive**: Vérifier sur différentes résolutions (9:16, 16:9, tablette)
2. **SaveManager**: Stats et équipements sauvegardés correctement
3. **Transitions**: Animations fluides entre onglets
4. **Edge cases**:
   - Aucun équipement possédé
   - Stats au niveau max
   - 0 SC
   - Tous les équipements possédés

---

## 📝 Notes Additionnelles

- Réutiliser un maximum de code du `shop_menu.gd` (styles, animations, constantes)
- Le `.tscn` sera minimal comme pour le shop (UI générée en code)
- Penser à connecter les signaux de `SaveManager` pour refresh auto
- La puissance totale (`power_label`) doit se recalculer après chaque modification

---

## 🏷️ Tags

`#UI` `#Profile` `#Refactoring` `#Sci-Fi` `#GDScript` `#Godot4`
