# STORY: Système de Gacha dans le Shop

## 📋 Résumé
Ajouter un système de gacha (loot boxes) dans le shop permettant aux joueurs d'obtenir des équipements aléatoires en échange de coins. Trois niveaux de rareté avec des prix et récompenses différents.

---

## 🎯 Objectifs
1. Créer une nouvelle section "GACHA" dans le shop, juste en dessous des packs de coins
2. Implémenter 3 types de gacha avec des prix différents
3. Ajouter une animation d'ouverture immersive
4. Intégrer 27 nouveaux équipements (9 par rareté)
5. Connecter au système d'inventaire existant

---

## 💎 Types de Gacha

### 🟢 Gacha Commun - 500 SC
- **Couleur**: Vert (`#33FF88`)
- **Contenu possible**: 3 armes + 3 armures + 3 casques communs
- **Taux de drop**: Équiprobable (11.11% chaque)

### 🔵 Gacha Rare - 1500 SC
- **Couleur**: Bleu/Cyan (`#00D4FF`)
- **Contenu possible**: 3 armes + 3 armures + 3 casques rares
- **Taux de drop**: Équiprobable (11.11% chaque)

### 🟣 Gacha Légendaire - 3500 SC
- **Couleur**: Violet/Or (`#AA44FF` / `#FFD933`)
- **Contenu possible**: 3 armes + 3 armures + 3 casques légendaires
- **Taux de drop**: Équiprobable (11.11% chaque)

---

## 🎨 Design UI

### Section Gacha dans le Shop
```
┌─────────────────────────────────────────┐
│            💰 COIN PACKS                │
│  [Pack 1]  [Pack 2]  [Pack 3]  [Pack 4] │
├─────────────────────────────────────────┤
│            🎰 GACHA                     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │ COMMUN  │ │  RARE   │ │LEGENDAIRE│   │
│  │  ⬜⬜⬜  │ │  🔷🔷🔷  │ │  ⭐⭐⭐  │   │
│  │ 500 SC  │ │ 1500 SC │ │ 3500 SC │   │
│  │ [TIRER] │ │ [TIRER] │ │ [TIRER] │   │
│  └─────────┘ └─────────┘ └─────────┘   │
├─────────────────────────────────────────┤
│            ⚔️ WEAPONS                   │
│            🛡️ ARMOR                     │
│            ⛑️ HELMETS                   │
└─────────────────────────────────────────┘
```

### Carte Gacha (Style Néon Sci-Fi)
- Bordure néon de la couleur de rareté
- Image du coffre/capsule gacha au centre
- Nom de la rareté en haut
- Prix en bas avec icône coin
- Bouton "TIRER" / "PULL"
- Effet de brillance/pulse subtil

---

## 🎬 Animation d'Ouverture

### Séquence d'Animation (2-3 secondes)
1. **Fond noir** (0.2s)
   - Overlay noir à 50% d'opacité
   - Fade in rapide

2. **Apparition capsule** (0.3s)
   - Image de la capsule gacha au centre
   - Scale de 0 → 1.2 → 1.0 (bounce)

3. **Secousse** (0.8s)
   - Rotation gauche/droite rapide (±5°)
   - Intensité croissante
   - Particules/étoiles autour

4. **Ouverture** (0.3s)
   - Flash blanc
   - Capsule disparaît (scale → 0)

5. **Révélation récompense** (0.5s)
   - Image de l'équipement obtenu
   - Scale de 0 → 1.3 → 1.0
   - Bordure néon de la rareté
   - Nom de l'item en dessous

6. **Fermeture** (tap ou 2s auto)
   - Fade out
   - Retour au shop
   - Feedback "Item ajouté à l'inventaire!"

---

## 📦 Nouveaux Équipements

### Armes (slot: "weapon")

#### Communes (Gacha 500 SC)
| ID | Nom | Bonus |
|---|---|---|
| `sword_iron` | Iron Blade | attack_power: +3 |
| `sword_steel` | Steel Sword | attack_power: +4 |
| `sword_bronze` | Bronze Cutter | attack_power: +5 |

#### Rares (Gacha 1500 SC)
| ID | Nom | Bonus |
|---|---|---|
| `sword_crystal` | Crystal Edge | attack_power: +8 |
| `sword_thunder` | Thunder Blade | attack_power: +10 |
| `sword_frost` | Frost Fang | attack_power: +12 |

#### Légendaires (Gacha 3500 SC)
| ID | Nom | Bonus |
|---|---|---|
| `sword_dragon` | Dragon Slayer | attack_power: +18 |
| `sword_void` | Void Reaper | attack_power: +22 |
| `sword_divine` | Divine Excalibur | attack_power: +28 |

---

### Armures (slot: "armor")

#### Communes (Gacha 500 SC)
| ID | Nom | Bonus |
|---|---|---|
| `armor_leather` | Leather Vest | dodge_chance: +3 |
| `armor_chainmail` | Chainmail | dodge_chance: +4 |
| `armor_iron` | Iron Plate | dodge_chance: +5 |

#### Rares (Gacha 1500 SC)
| ID | Nom | Bonus |
|---|---|---|
| `armor_crystal` | Crystal Guard | dodge_chance: +8 |
| `armor_thunder` | Storm Armor | dodge_chance: +10 |
| `armor_frost` | Frost Mail | dodge_chance: +12 |

#### Légendaires (Gacha 3500 SC)
| ID | Nom | Bonus |
|---|---|---|
| `armor_dragon` | Dragon Scale | dodge_chance: +16 |
| `armor_void` | Void Shroud | dodge_chance: +20 |
| `armor_divine` | Divine Aegis | dodge_chance: +25 |

---

### Casques (slot: "helmet")

#### Communs (Gacha 500 SC)
| ID | Nom | Bonus |
|---|---|---|
| `helmet_leather` | Leather Cap | heal_power: +2 |
| `helmet_iron` | Iron Helm | heal_power: +3 |
| `helmet_steel` | Steel Visor | heal_power: +4 |

#### Rares (Gacha 1500 SC)
| ID | Nom | Bonus |
|---|---|---|
| `helmet_crystal` | Crystal Crown | heal_power: +6 |
| `helmet_thunder` | Storm Hood | heal_power: +8 |
| `helmet_frost` | Frost Helm | heal_power: +10 |

#### Légendaires (Gacha 3500 SC)
| ID | Nom | Bonus |
|---|---|---|
| `helmet_dragon` | Dragon Horns | heal_power: +14 |
| `helmet_void` | Void Mask | heal_power: +18 |
| `helmet_divine` | Divine Halo | heal_power: +22 |

---

## 📁 Structure des Fichiers

### Assets Requis (à fournir)
```
assets/
├── sprites/
│   ├── gacha/
│   │   ├── capsule-common.png      # Capsule verte
│   │   ├── capsule-rare.png        # Capsule bleue
│   │   └── capsule-legendary.png   # Capsule violette/dorée
│   │
│   └── equipment/
│       ├── weapons/
│       │   ├── common/
│       │   │   ├── sword_iron.png
│       │   │   ├── sword_steel.png
│       │   │   └── sword_bronze.png
│       │   ├── rare/
│       │   │   ├── sword_crystal.png
│       │   │   ├── sword_thunder.png
│       │   │   └── sword_frost.png
│       │   └── legendary/
│       │       ├── sword_dragon.png
│       │       ├── sword_void.png
│       │       └── sword_divine.png
│       │
│       ├── armors/
│       │   ├── common/
│       │   ├── rare/
│       │   └── legendary/
│       │
│       └── helmets/
│           ├── common/
│           ├── rare/
│           └── legendary/
```

### Code à Modifier
```
scripts/
├── ui/
│   └── shop_menu.gd          # Ajouter section gacha + animation
│
├── data/
│   └── equipment_data.gd     # Ajouter les 27 nouveaux items
│
└── autoload/
    └── save_manager.gd       # Vérifier compatibilité inventaire
```

---

## 🔧 Implémentation Technique

### 1. Données Gacha (dans shop_menu.gd ou séparé)
```gdscript
const GACHA_TYPES := {
    "common": {
        "name": "Common Gacha",
        "price": 500,
        "color": Color("#33FF88"),
        "capsule": "res://assets/sprites/gacha/capsule-common.png",
        "pool": ["sword_iron", "sword_steel", "sword_bronze", 
                 "armor_leather", "armor_chainmail", "armor_iron",
                 "helmet_leather", "helmet_iron", "helmet_steel"]
    },
    "rare": {
        "name": "Rare Gacha",
        "price": 1500,
        "color": Color("#00D4FF"),
        "capsule": "res://assets/sprites/gacha/capsule-rare.png",
        "pool": ["sword_crystal", "sword_thunder", "sword_frost",
                 "armor_crystal", "armor_thunder", "armor_frost",
                 "helmet_crystal", "helmet_thunder", "helmet_frost"]
    },
    "legendary": {
        "name": "Legendary Gacha",
        "price": 3500,
        "color": Color("#AA44FF"),
        "capsule": "res://assets/sprites/gacha/capsule-legendary.png",
        "pool": ["sword_dragon", "sword_void", "sword_divine",
                 "armor_dragon", "armor_void", "armor_divine",
                 "helmet_dragon", "helmet_void", "helmet_divine"]
    }
}
```

### 2. Fonction de Tirage
```gdscript
func _pull_gacha(gacha_type: String) -> void:
    var gacha := GACHA_TYPES[gacha_type]
    
    # Vérifier les coins
    if not SaveManager.spend_currency(gacha["price"]):
        _show_feedback("Pas assez de SC!", false)
        return
    
    # Tirer un item aléatoire
    var pool: Array = gacha["pool"]
    var won_item: String = pool[randi() % pool.size()]
    
    # Ajouter à l'inventaire
    SaveManager.add_equipment(won_item)
    
    # Lancer l'animation
    _play_gacha_animation(gacha_type, won_item)
```

### 3. Animation d'Ouverture
```gdscript
func _play_gacha_animation(gacha_type: String, won_item: String) -> void:
    var gacha := GACHA_TYPES[gacha_type]
    var item_data := EQUIPMENT_DATA[won_item]
    
    # Créer overlay
    var overlay := ColorRect.new()
    overlay.color = Color(0, 0, 0, 0.5)
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    overlay.z_index = 200
    add_child(overlay)
    
    # Capsule au centre
    var capsule := TextureRect.new()
    capsule.texture = load(gacha["capsule"])
    # ... positionnement centré
    
    # Séquence d'animation avec Tween
    var tween := create_tween()
    # 1. Apparition capsule (bounce)
    # 2. Secousse (rotation)
    # 3. Flash + disparition
    # 4. Apparition item
    # 5. Attendre tap ou timeout
    # 6. Cleanup
```

---

## ✅ Critères d'Acceptation

### Fonctionnels
- [x] Section Gacha visible dans le shop sous les coins
- [x] 3 cartes gacha avec prix corrects (500/1500/3500)
- [x] Achat déduit les coins correctement
- [x] Message "Pas assez de SC!" si insuffisant
- [x] Item aléatoire tiré du bon pool
- [x] Item ajouté à l'inventaire SaveManager
- [x] Animation complète jouée à chaque tirage
- [x] Possibilité de fermer l'animation (tap ou auto 2s)
- [x] Items visibles dans le profil après obtention
- [x] Items équipables depuis le profil

### Visuels
- [x] Style Sci-Fi Néon cohérent avec le shop
- [x] Couleurs distinctes par rareté (vert/bleu/violet)
- [x] Animation fluide (secousse + flash + révélation)
- [x] Effet de secousse convaincant
- [x] Flash et transitions smooth

### Données
- [x] 27 nouveaux équipements dans EQUIPMENT_DATA (profile_menu.gd)
- [x] 27 nouveaux équipements dans GACHA_EQUIPMENT_DATA (shop_menu.gd)
- [x] Calcul de puissance mis à jour (level_select.gd)
- [ ] Sprites placeholder en attendant images réelles

---

## 📝 Notes pour l'Implémentation

1. **Images à fournir par l'utilisateur**:
   - 3 capsules gacha (common, rare, legendary)
   - 27 sprites d'équipements (ou utiliser placeholders)

2. **Spécificités des armes à confirmer**:
   - Les bonus indiqués sont des suggestions
   - L'utilisateur fournira les valeurs finales

3. **Gestion des doublons**:
   - Si le joueur obtient un item déjà possédé, il l'a quand même (pas de compensation pour l'instant)
   - Option future: convertir en coins ou fragments

4. **Équilibrage**:
   - Prix à ajuster selon l'économie du jeu
   - Taux de drop uniformes (pas de pity system pour l'instant)

---

## 🚀 Prochaines Étapes

1. Recevoir les images des capsules gacha
2. Recevoir les sprites des 27 équipements
3. Recevoir les spécificités exactes des bonus
4. Implémenter la section gacha dans shop_menu.gd
5. Ajouter les équipements dans EQUIPMENT_DATA
6. Créer l'animation d'ouverture
7. Tester l'intégration avec le profil
8. Ajuster l'équilibrage si nécessaire
