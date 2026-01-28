# COF-901: Enemy Sprite System

**Epic**: Visual Assets  
**Status**: 🔄 IN PROGRESS  
**Priority**: High  
**Fichier principal**: `scenes/game_combat_scene.gd`  
**Assets**: `assets/sprites/enemies/`

---

## User Story

**En tant que** joueur,  
**Je veux** voir des sprites uniques pour chaque type d'ennemi,  
**Afin de** distinguer visuellement les ennemis par planète et comprendre leur comportement.

---

## Description

Remplacer les `ColorRect` placeholder par de vrais sprites PNG pour les ennemis normaux, mini-boss et vaisseaux d'arrière-plan. Chaque planète a son propre style visuel d'ennemis avec des poses différentes (standing, shooting, hurt).

---

## Assets Requis

### Ennemis par Planète

| Planète | Fichiers | Status |
|---------|----------|--------|
| Mercury | `mercury-sprites-standing.png`, `mercury-sprites-shooting.png`, `mercury-sprites-on-knee.png` | ❌ MANQUANT |
| Venus | `venus-sprites-standing.png`, `venus-sprites-shooting.png`, `venus-sprites-on-knee.png` | ✅ PRÉSENT |
| Mars | `mars-sprites-standing.png`, `mars-sprites-shooting.png`, `mars-sprites-before-shooting.png` | ✅ PRÉSENT |
| Earth | `earth-sprites-standing.png`, `earth-sprites-shooting.png`, `earth-sprites-on-knee.png` | ✅ PRÉSENT |

### Mini-Boss

| Fichier | Usage | Status |
|---------|-------|--------|
| `mini-boss.png` | Pose idle/par défaut | ✅ PRÉSENT |
| `mini-boss-screaming.png` | Pose d'attaque | ✅ PRÉSENT |
| `mini-boss-screaming-2.png` | Pose d'attaque alt | ✅ PRÉSENT |
| `mini-boss-fireball.png` | Attaque spéciale | ✅ PRÉSENT |
| `mini-boss-other-side.png` | Vue alternative | ✅ PRÉSENT |

### Boss Final (Dr. Mortis)

| Fichier | Usage | Status |
|---------|-------|--------|
| `dr-mortis-idle.png` | Pose par défaut | ❌ MANQUANT |
| `dr-mortis-attack.png` | Pose d'attaque | ❌ MANQUANT |
| `dr-mortis-hurt.png` | Pose blessé | ❌ MANQUANT |
| `dr-mortis-death.png` | Animation mort | ❌ MANQUANT |

### Vaisseaux (Background)

| Fichier | Status |
|---------|--------|
| `vaisseau-1.png` à `vaisseau-6.png` | ✅ PRÉSENT (6 variantes) |

---

## Critères d'Acceptation

### Ennemis Normaux
- [x] Configuration `ENEMY_SPRITES` avec chemins par planète
- [x] Fallback `ColorRect` si sprite manquant (Mercury)
- [x] Taille responsive selon viewport
- [x] Stockage des textures additionnelles pour animations futures
- [x] Animation de pose (idle → shooting → hurt) selon état

### Mini-Boss
- [x] Configuration `MINIBOSS_SPRITES` avec toutes les poses
- [x] Affichage sprite au lieu d'emoji
- [x] Fallback emoji si sprite manquant
- [x] Animation de transition entre poses (idle ↔ screaming)

### Boss Final
- [ ] Sprites dédiés pour Dr. Mortis
- [ ] Animation épique d'apparition
- [ ] Effets visuels de mort spéciaux

### Vaisseaux Background (Level Select)
- [x] Container `z_index = -10` (derrière UI)
- [x] Spawn aléatoire toutes les 2 secondes
- [x] Maximum 8 vaisseaux simultanés
- [x] Mouvement fluide avec oscillation
- [x] Opacité réduite (30-60%)
- [x] `mouse_filter = IGNORE` (ne bloque pas les clics)

---

## Implémentation Technique

### Configuration des Sprites (game_combat_scene.gd)

```gdscript
## Enemy Sprite System - sprites par planète
const ENEMY_SPRITES := {
    1: {  # Venus
        "standing": "res://assets/sprites/enemies/venus-sprites-standing.png",
        "shooting": "res://assets/sprites/enemies/venus-sprites-shooting.png",
        "hurt": "res://assets/sprites/enemies/venus-sprites-on-knee.png"
    },
    2: {  # Mars
        "standing": "res://assets/sprites/enemies/mars-sprites-standing.png",
        "shooting": "res://assets/sprites/enemies/mars-sprites-shooting.png",
        "hurt": "res://assets/sprites/enemies/mars-sprites-before-shooting.png"
    },
    3: {  # Earth
        "standing": "res://assets/sprites/enemies/earth-sprites-standing.png",
        "shooting": "res://assets/sprites/enemies/earth-sprites-shooting.png",
        "hurt": "res://assets/sprites/enemies/earth-sprites-on-knee.png"
    }
}

const MINIBOSS_SPRITES := {
    "idle": "res://assets/sprites/enemies/mini-boss.png",
    "screaming": "res://assets/sprites/enemies/mini-boss-screaming.png",
    "screaming2": "res://assets/sprites/enemies/mini-boss-screaming-2.png",
    "fireball": "res://assets/sprites/enemies/mini-boss-fireball.png",
    "other_side": "res://assets/sprites/enemies/mini-boss-other-side.png"
}
```

### Création Visuelle Ennemi

```gdscript
func _create_enemy_visual(enemy: BaseEnemy) -> Control:
    # Vérifier si sprite existe
    var enemy_sprite_data: Dictionary = ENEMY_SPRITES.get(current_planet, {})
    var sprite_path: String = enemy_sprite_data.get("standing", "")
    
    if ResourceLoader.exists(sprite_path):
        # TextureRect avec sprite
        var sprite := TextureRect.new()
        sprite.texture = load(sprite_path)
        sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
        sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        # ... configuration taille et position
    else:
        # Fallback ColorRect
        # ... code existant
```

### Vaisseaux Background (level_select.gd)

```gdscript
const SPACESHIP_SPRITES := [
    "res://assets/sprites/enemies/vaisseau-1.png",
    "res://assets/sprites/enemies/vaisseau-2.png",
    "res://assets/sprites/enemies/vaisseau-3.png",
    "res://assets/sprites/enemies/vaisseau-4.png",
    "res://assets/sprites/enemies/vaisseau-5.png",
    "res://assets/sprites/enemies/vaisseau-6.png"
]

func _spawn_spaceship(random_position: bool) -> void:
    var spaceship := TextureRect.new()
    spaceship.texture = load(sprite_path)
    spaceship.modulate.a = randf_range(0.3, 0.6)
    # Animation de déplacement
```

---

## Tâches Restantes

### Priorité Haute
1. [ ] Créer sprites Mercury (3 poses)
2. [ ] Créer sprites Dr. Mortis (4 poses minimum)
3. [x] ~~Animer les transitions de poses ennemis~~ ✅ FAIT

### Priorité Moyenne
4. [ ] Ajouter effets particules aux ennemis
5. [x] ~~Animation de mort (fade + scale + rotation)~~ ✅ FAIT
6. [ ] Effet de spawn (apparition progressive)

### Priorité Basse
7. [ ] Variations de couleur par ennemi
8. [ ] Ombres sous les sprites
9. [ ] Effet de parallaxe sur vaisseaux

---

## Tests

- [ ] Vérifier affichage sur toutes les planètes
- [ ] Tester fallback ColorRect sur Mercury
- [ ] Valider performance avec 8 vaisseaux + ennemis
- [ ] Tester sur différentes résolutions d'écran
- [ ] Vérifier que les vaisseaux ne bloquent pas les clics

---

## Notes

- Les sprites doivent être en PNG avec transparence
- Taille recommandée : 128x128 ou 256x256 pixels
- Nommage cohérent : `{planète}-sprites-{pose}.png`
- Les vaisseaux sont dans `enemies/` mais pourraient être déplacés vers `ui/` ou `background/`
