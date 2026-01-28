# COF-907: Combat Layout Resize - Zone Boutons 55% & Sprites Agrandis

**Epic**: Visual Assets & UI Polish  
**Status**: 📋 READY FOR IMPLEMENTATION  
**Priority**: High  
**Sprint**: Current  
**Fichier principal**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur mobile,  
**Je veux** une zone de boutons plus grande (55% de l'écran) avec des boutons et sprites agrandis,  
**Afin de** avoir une meilleure expérience tactile et un visuel plus épique avec les vaisseaux ennemis.

---

## Description

Refonte majeure du layout de combat pour améliorer l'ergonomie mobile :

1. **Zone de boutons étendue** : Occupe 55% de l'écran (vs 22% actuellement)
2. **Boutons agrandis** : Skills et actions principales plus larges
3. **Héros agrandi** : L'alien est plus imposant visuellement
4. **Ennemis agrandis** : Troupes au sol plus visibles
5. **Vaisseaux ennemis** : Nouveaux ennemis aériens au-dessus des troupes

---

## Spécifications Techniques

### 1. Zone de Boutons (Bottom HUD)

**Avant** (dans `_create_bottom_hud`):
```gdscript
bottom_container.anchor_top = 0.78  # 22% de l'écran pour les boutons
```

**Après**:
```gdscript
bottom_container.anchor_top = 0.45  # 55% de l'écran pour les boutons
```

**Localisation**: `scenes/game_combat_scene.gd`, fonction `_create_bottom_hud()`, ligne ~701

---

### 2. Boutons Skills Agrandis

**Avant** (dans `_create_skill_button`):
```gdscript
btn.custom_minimum_size = Vector2(65, 70)  # Compact
```

**Après**:
```gdscript
btn.custom_minimum_size = Vector2(85, 100)  # Plus gros pour touch
```

**Localisation**: `scenes/game_combat_scene.gd`, fonction `_create_skill_button()`, ligne ~769

---

### 3. Bouton Click Zone Agrandi

**Avant** (dans `_create_bottom_hud`):
```gdscript
click_zone_button.custom_minimum_size = Vector2(0, 110)  # Hauteur 110
```

**Après**:
```gdscript
click_zone_button.custom_minimum_size = Vector2(0, 180)  # Hauteur 180
```

**Localisation**: `scenes/game_combat_scene.gd`, ligne ~723

---

### 4. Héros (Alien) Agrandi

**Avant** (dans `_create_hero_visual`):
```gdscript
var sprite_width: int = mini(280, int(viewport_size.x * 0.38))  # Max 38%
var sprite_height := sprite_width * 1.2
```

**Après**:
```gdscript
var sprite_width: int = mini(350, int(viewport_size.x * 0.48))  # Max 48% - HÉROS XXL
var sprite_height := sprite_width * 1.2
```

**Localisation**: `scenes/game_combat_scene.gd`, fonction `_create_hero_visual()`, lignes ~436-437

---

### 5. Ennemis au Sol Agrandis

**Avant** (dans `_create_enemy_visual`):
```gdscript
var body_width: int = mini(80, int(viewport_size.x * 0.11))  # 11%
var body_height: int = int(body_width * 1.4)
var sprite_size := Vector2(body_width * 2, body_height * 2)
```

**Après**:
```gdscript
var body_width: int = mini(100, int(viewport_size.x * 0.14))  # 14% - ENNEMIS XXL
var body_height: int = int(body_width * 1.4)
var sprite_size := Vector2(body_width * 2.2, body_height * 2.2)  # +10% scaling sprite
```

**Localisation**: `scenes/game_combat_scene.gd`, fonction `_create_enemy_visual()`, lignes ~1188-1190

---

### 6. Nouveau Système : Vaisseaux Ennemis Aériens

#### 6.1 Configuration des Vaisseaux

Ajouter après `MINIBOSS_SPRITES`:
```gdscript
## Vaisseaux ennemis - sprites aériens
const ENEMY_SHIPS := [
    "res://assets/sprites/enemies/vaisseau-1.png",
    "res://assets/sprites/enemies/vaisseau-2.png",
    "res://assets/sprites/enemies/vaisseau-3.png",
    "res://assets/sprites/enemies/vaisseau-4.png",
    "res://assets/sprites/enemies/vaisseau-5.png",
    "res://assets/sprites/enemies/vaisseau-6.png"
]

## Configuration vaisseaux par wave
const SHIPS_PER_WAVE := {
    1: 1,   # Wave 1: 1 vaisseau
    2: 1,   # Wave 2: 1 vaisseau
    3: 2,   # Wave 3: 2 vaisseaux
    4: 2,   # Wave 4: 2 vaisseaux
    5: 3,   # Wave 5 (boss): 3 vaisseaux
}
```

#### 6.2 Variables pour les Vaisseaux

Ajouter après `enemy_visuals: Dictionary`:
```gdscript
## Vaisseaux ennemis actifs
var active_ships: Array = []
var ship_visuals: Dictionary = {}
var ship_container: Control
```

#### 6.3 Container pour Vaisseaux

Dans `_setup_combat_zone()`, après création de `enemy_container`:
```gdscript
# Container pour les vaisseaux ennemis (au-dessus des troupes)
ship_container = Control.new()
ship_container.name = "ShipContainer"
ship_container.position = Vector2(viewport_size.x * 0.60, viewport_size.y * 0.20)  # Haut à droite
ship_container.z_index = 5  # Au-dessus du background, sous le HUD
combat_zone.add_child(ship_container)
```

#### 6.4 Fonction de Spawn des Vaisseaux

Nouvelle fonction à ajouter:
```gdscript
func _spawn_enemy_ships(count: int) -> void:
    # Nettoyer les vaisseaux précédents
    for ship in active_ships:
        if is_instance_valid(ship):
            ship.queue_free()
    active_ships.clear()
    ship_visuals.clear()
    
    var viewport_size: Vector2 = get_viewport().get_visible_rect().size
    var ship_spacing: float = viewport_size.x * 0.08
    var start_x: float = -ship_spacing * (count - 1) / 2.0
    
    for i in range(count):
        var ship := BaseEnemy.new()
        ship.name = "EnemyShip_%d" % i
        
        # Stats du vaisseau (ennemi aérien faible)
        var ship_stats := EntityStats.new()
        ship_stats.display_name = "Fighter Ship"
        ship_stats.max_hp = 30 + (current_wave * 10)
        ship_stats.attack = 5 + (current_wave * 2)
        ship_stats.attack_speed = 0.8
        ship.base_stats = ship_stats
        
        # Position en formation
        var ship_pos := Vector2(start_x + i * ship_spacing, i * 25)  # Décalage diagonal
        ship.position = ship_pos
        
        ship_container.add_child(ship)
        active_ships.append(ship)
        
        # Visual du vaisseau
        var visual := _create_ship_visual(ship)
        ship_visuals[ship] = visual
        
        # Connecter signaux
        ship.died.connect(_on_ship_died.bind(ship))
        ship.hp_changed.connect(_on_ship_hp_changed.bind(ship))


func _create_ship_visual(ship: BaseEnemy) -> Control:
    var visual := Control.new()
    visual.name = "ShipVisual"
    ship.add_child(visual)
    
    var viewport_size: Vector2 = get_viewport().get_visible_rect().size
    var ship_size := Vector2(
        mini(90, int(viewport_size.x * 0.12)),
        mini(60, int(viewport_size.x * 0.08))
    )
    
    # Sprite du vaisseau (choix aléatoire)
    var sprite := TextureRect.new()
    sprite.name = "ShipSprite"
    var random_ship := ENEMY_SHIPS[randi() % ENEMY_SHIPS.size()]
    if ResourceLoader.exists(random_ship):
        sprite.texture = load(random_ship)
    sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    sprite.custom_minimum_size = ship_size
    sprite.size = ship_size
    sprite.position = Vector2(-ship_size.x / 2, -ship_size.y)
    # Flip horizontal pour pointer vers le héros
    sprite.flip_h = true
    visual.add_child(sprite)
    
    # Barre de vie du vaisseau
    var hp_bar_width := ship_size.x * 0.8
    var hp_bg := ColorRect.new()
    hp_bg.name = "HPBackground"
    hp_bg.color = Color(0.1, 0.1, 0.1, 0.8)
    hp_bg.size = Vector2(hp_bar_width, 5)
    hp_bg.position = Vector2(-hp_bar_width / 2, -ship_size.y - 10)
    visual.add_child(hp_bg)
    
    var hp_fill := ColorRect.new()
    hp_fill.name = "HPFill"
    hp_fill.color = Color(0.5, 0.2, 0.8)  # Violet pour différencier
    hp_fill.size = Vector2(hp_bar_width - 2, 3)
    hp_fill.position = Vector2(-hp_bar_width / 2 + 1, -ship_size.y - 9)
    visual.add_child(hp_fill)
    
    # Animation de flottement
    _animate_ship_hover(sprite)
    
    return visual


func _animate_ship_hover(sprite: TextureRect) -> void:
    var tween := create_tween().set_loops()
    tween.tween_property(sprite, "position:y", sprite.position.y - 5, 0.8).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(sprite, "position:y", sprite.position.y + 5, 0.8).set_ease(Tween.EASE_IN_OUT)


func _on_ship_died(ship: BaseEnemy) -> void:
    _show_floating_text("💥", ship.global_position + Vector2(0, -50), Color.ORANGE, 28)
    _award_kill_currency(15)  # Reward pour vaisseau
    
    if ship in active_ships:
        active_ships.erase(ship)
    if ship in ship_visuals:
        ship_visuals.erase(ship)
    
    ship.queue_free()


func _on_ship_hp_changed(current: int, max_hp: int, ship: BaseEnemy) -> void:
    if ship in ship_visuals:
        var visual: Control = ship_visuals[ship]
        var hp_fill: ColorRect = visual.get_node_or_null("HPFill")
        if hp_fill:
            var ratio := float(current) / float(max_hp)
            hp_fill.size.x = (hp_fill.get_parent().size.x - 2) * ratio
```

#### 6.5 Intégration dans le Spawn de Wave

Modifier `_spawn_wave()` pour appeler le spawn de vaisseaux:
```gdscript
func _spawn_wave() -> void:
    # ... code existant pour spawn ennemis au sol ...
    
    # Spawn vaisseaux ennemis aériens
    var ships_count: int = SHIPS_PER_WAVE.get(current_wave, 1)
    _spawn_enemy_ships(ships_count)
```

#### 6.6 Intégration dans l'Auto-Attack

Les vaisseaux sont des cibles valides pour l'auto-attack du héros. Dans le système d'attaque, ajouter les `active_ships` comme cibles potentielles après les `active_enemies`.

---

## Repositionnement Containers (Zone Combat Réduite)

Comme la zone de boutons passe de 22% à 55%, la zone de combat doit être ajustée :

**Avant**:
```gdscript
hero_container.position = Vector2(viewport_size.x * 0.28, viewport_size.y * 0.55)
enemy_container.position = Vector2(viewport_size.x * 0.68, viewport_size.y * 0.55)
```

**Après**:
```gdscript
hero_container.position = Vector2(viewport_size.x * 0.22, viewport_size.y * 0.32)  # Plus haut, plus à gauche
enemy_container.position = Vector2(viewport_size.x * 0.70, viewport_size.y * 0.32)  # Plus haut, plus à droite
```

**Localisation**: `scenes/game_combat_scene.gd`, fonction `_setup_combat_zone()`, lignes ~351-358

---

## Layout Mockup

```
┌─────────────────────────────────────────────┐
│  [HUD: Wave, Planet, Currency]              │  5%
├─────────────────────────────────────────────┤
│                                             │
│   🛸 🛸 🛸          ← Vaisseaux ennemis     │  15%
│                                             │
│   👽           ⚔️⚔️⚔️                        │
│  ALIEN        TROOPS                        │  25%
│  (BIG)        (BIG)                         │
│                                             │
├═════════════════════════════════════════════┤
│                                             │
│   ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐│
│   │  💚    │ │  💥    │ │  🛡️    │ │  ☄️    ││  15%
│   │ HEAL   │ │ CRIT   │ │ SHIELD │ │ NOVA   ││
│   │▓▓▓░░░░░│ │▓▓▓▓▓░░░│ │░░░░░░░░│ │▓▓▓▓▓▓▓▓││  (Skills)
│   └────────┘ └────────┘ └────────┘ └────────┘│
│                                             │
│   ┌─────────────────────────────────────────┐│
│   │                                         ││
│   │      HEAL    |   DODGE   |   ATTACK     ││  40%
│   │       ❤️     |    ↪️     |     ⚔️       ││  (Actions)
│   │                                         ││
│   └─────────────────────────────────────────┘│
│                                             │
└─────────────────────────────────────────────┘
        ↑
   55% de l'écran pour les boutons
```

---

## Critères d'Acceptation

### Zone de Boutons
- [ ] La zone de boutons occupe 55% de l'écran (anchor_top = 0.45)
- [ ] Les boutons skills sont agrandis (85x100 pixels)
- [ ] Le click zone button est agrandi (180px de haut)
- [ ] L'espacement entre les éléments est harmonieux

### Sprites Agrandis
- [ ] L'alien héros est 26% plus grand (0.38 → 0.48)
- [ ] Les ennemis au sol sont 27% plus grands (0.11 → 0.14)
- [ ] Les sprites gardent leur ratio d'aspect

### Vaisseaux Ennemis
- [ ] 1-3 vaisseaux apparaissent selon la wave
- [ ] Les vaisseaux utilisent les sprites `vaisseau-1.png` à `vaisseau-6.png`
- [ ] Les vaisseaux flottent avec une animation subtile
- [ ] Les vaisseaux ont une barre de vie violette
- [ ] Les vaisseaux sont des cibles valides pour l'auto-attack
- [ ] Les vaisseaux donnent 15 coins à leur mort

### Layout Global
- [ ] La zone de combat est repositionnée plus haut (0.32)
- [ ] Pas de chevauchement entre les zones
- [ ] L'affichage reste correct sur différentes tailles d'écran

---

## Tests Manuels

| Test | Résultat Attendu | Status |
|------|------------------|--------|
| Zone boutons 55% | Les boutons occupent plus de la moitié de l'écran | 🔲 |
| Boutons skills agrandis | Skills visiblement plus gros | 🔲 |
| Click zone agrandi | Zone tactile plus haute (180px) | 🔲 |
| Alien agrandi | Héros imposant visuellement | 🔲 |
| Ennemis agrandis | Troupes plus visibles | 🔲 |
| Vaisseaux Wave 1 | 1 vaisseau au-dessus des troupes | 🔲 |
| Vaisseaux Wave 3 | 2 vaisseaux en formation | 🔲 |
| Vaisseaux Wave 5 | 3 vaisseaux pour le boss | 🔲 |
| Animation flottement | Vaisseaux oscillent doucement | 🔲 |
| Kill vaisseau | +15 coins, effet explosion | 🔲 |
| Layout mobile | Pas de clipping, tout visible | 🔲 |

---

## Definition of Done

- [ ] Zone de boutons = 55% de l'écran
- [ ] Boutons skills agrandis
- [ ] Click zone agrandi
- [ ] Héros agrandi
- [ ] Ennemis agrandis
- [ ] Vaisseaux ennemis fonctionnels
- [ ] Layout repositionné
- [ ] Pas d'erreurs GDScript
- [ ] Test sur différentes résolutions OK

---

## Related Stories

- COF-906: Combat Buttons Visual Redesign (Style des boutons)
- COF-804: BMAD Mode - Army Formation (Formation ennemis)
- COF-901: Enemy Sprite System (Système de sprites)

---

## Notes Techniques

### Performance
- Max 3 vaisseaux pour éviter surcharge
- Animation de flottement légère (pas d'effets lourds)
- Recycler les tweens pour les animations

### Mobile Ergonomie
- Zone tactile élargie = meilleure précision
- Boutons plus gros = moins de misclicks
- Zone de combat réduite mais sprites agrandis = même lisibilité

### Assets Utilisés
Les vaisseaux utilisent les sprites existants :
- `res://assets/sprites/enemies/vaisseau-1.png`
- `res://assets/sprites/enemies/vaisseau-2.png`
- `res://assets/sprites/enemies/vaisseau-3.png`
- `res://assets/sprites/enemies/vaisseau-4.png`
- `res://assets/sprites/enemies/vaisseau-5.png`
- `res://assets/sprites/enemies/vaisseau-6.png`
