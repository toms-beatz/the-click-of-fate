# COF-910: Combat Experience Overhaul - Corrections & Améliorations

**Epic**: Core Combat  
**Priority**: 🔴 HIGH  
**Estimation**: 4-6 heures  
**Fichier principal**: `scenes/game_combat_scene.gd`

---

## 📋 Résumé

Refonte majeure de l'expérience de combat pour la rendre plus plaisante et immersive. Cette story corrige plusieurs bugs et améliore les animations, le spawning des ennemis, l'affichage des dégâts et l'équilibrage.

---

## 🎯 Objectifs

### 1. Sprites du Héros Alien (Simplification)
**Localisation**: `_load_hero_textures()` lignes ~620-635

**Actuellement**:
```gdscript
hero_textures = {
    HeroPose.IDLE: load(base_path + "hero_idle.png"),
    HeroPose.READY: load(base_path + "hero_ready.png"),
    # ... 7 sprites différents
}
```

**Correction**:
- Utiliser UNIQUEMENT les 2 sprites existants dans `assets/sprites/hero/`:
  - `alien-stand.png` → position de base (IDLE, READY, DODGE)
  - `alien-tire.png` → quand il attaque (auto-attack ou bouton ATTACK)

**Code cible**:
```gdscript
func _load_hero_textures() -> void:
    var base_path := "res://assets/sprites/hero/"
    var stand_tex := load(base_path + "alien-stand.png")
    var shoot_tex := load(base_path + "alien-tire.png")
    
    hero_textures = {
        HeroPose.IDLE: stand_tex,
        HeroPose.READY: stand_tex,
        HeroPose.DODGE: stand_tex,
        HeroPose.ATTACK_1: shoot_tex,
        HeroPose.ATTACK_2: shoot_tex,
        HeroPose.ATTACK_3: shoot_tex,
        HeroPose.SPECIAL: shoot_tex,
    }
```

---

### 2. Animation d'Entrée du Héros (Slide-in)
**Localisation**: `_create_hero_visual()` lignes ~578-615

**Actuellement**: Le héros apparaît instantanément à sa position.

**Correction**:
- Au chargement du niveau, le héros commence hors écran à gauche
- Animation de glissement vers sa position finale (durée: 0.8s, easing: EASE_OUT)

**Code à ajouter après création du visuel**:
```gdscript
func _create_hero_visual() -> void:
    # ... code existant ...
    
    # Animation d'entrée: slide depuis la gauche
    var final_position := hero_container.position
    var start_position := Vector2(-200, final_position.y)
    hero_container.position = start_position
    
    var slide_tween := create_tween()
    slide_tween.set_ease(Tween.EASE_OUT)
    slide_tween.set_trans(Tween.TRANS_BACK)
    slide_tween.tween_property(hero_container, "position", final_position, 0.8)
```

---

### 3. Refonte du Système de Vagues
**Localisation**: `_spawn_wave()`, `_spawn_enemy()`, constantes de config

**Actuellement**:
- Nombre d'ennemis variable selon `ENEMIES_PER_WAVE`
- Ennemis spawent avec délai 0.4s chacun
- Pas de configuration claire des vaisseaux par vague

**Nouvelle Configuration**:
```
Wave 1: 1 ennemi au sol, 0 vaisseau
Wave 2: 3 ennemis au sol, 0 vaisseau  
Wave 3: 5 ennemis au sol, 0 vaisseau
Wave 4: 5 ennemis au sol, 1 vaisseau
Wave 5: 5 ennemis au sol, 3 vaisseaux
Boss: Stats x5 (HP et dégâts)
```

**Constantes à modifier**:
```gdscript
## Configuration des vagues (ennemis au sol par vague)
const ENEMIES_PER_WAVE_NEW := [1, 3, 5, 5, 5]

## Configuration des vaisseaux par vague
const SHIPS_PER_WAVE_NEW := [0, 0, 0, 1, 3]

## Multiplicateur de stats ennemis (plus forts individuellement)
const ENEMY_HP_MULT := 3.0      # x3 HP par ennemi
const ENEMY_ATK_MULT := 2.5     # x2.5 ATK par ennemi

## Boss stats multiplier
const BOSS_STATS_MULT := 5.0    # x5 HP et x5 ATK pour le boss
```

**Animation d'entrée des ennemis**:
- Tous les ennemis de la vague spawent EN MÊME TEMPS
- Animation slide-in depuis la droite (hors écran) vers leur position
- Durée: 0.6s avec léger décalage (0.05s) entre chaque ennemi

```gdscript
func _spawn_wave() -> void:
    # ... setup wave label ...
    
    var wave_idx := clampi(current_wave - 1, 0, 4)
    enemies_in_wave = ENEMIES_PER_WAVE_NEW[wave_idx]
    
    # Spawn tous les ennemis d'un coup avec animation slide-in
    for i in range(enemies_in_wave):
        _spawn_enemy_with_slide(i)
    
    # Spawn vaisseaux selon la nouvelle config
    var ships_count: int = SHIPS_PER_WAVE_NEW[wave_idx]
    if ships_count > 0:
        _spawn_enemy_ships(ships_count)

func _spawn_enemy_with_slide(index: int) -> void:
    var enemy := _create_enemy_entity(index)
    var visual := _create_enemy_visual(enemy)
    
    # Position finale
    var final_pos := enemy.position
    # Position de départ (hors écran à droite)
    var viewport_size := get_viewport().get_visible_rect().size
    enemy.position = Vector2(viewport_size.x + 100, final_pos.y)
    
    # Animation slide-in avec délai selon index
    var delay := index * 0.05
    var tween := create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BACK)
    tween.tween_interval(delay)
    tween.tween_property(enemy, "position", final_pos, 0.6)
```

---

### 4. Animations des Boss
**Localisation**: `_on_boss_attacked()`, `BOSS_SPRITES`

**Actuellement**: Le boss utilise 3 sprites (idle, attacking, hurt) mais `attacking` est toujours le même.

**Correction**:
- Renommer les sprites dans `BOSS_SPRITES`:
  - `idle` → sprite de base
  - `attack_1` → premier sprite d'attaque (ancien `attacking`)
  - `attack_2` → second sprite d'attaque (ancien `hurt`)
- À chaque attaque du boss, choisir aléatoirement entre `attack_1` et `attack_2`

**Code**:
```gdscript
const BOSS_SPRITES := {
    0: {  # Mercury
        "idle": "res://assets/sprites/enemies/bosses/mercury/mercury-boss.png",
        "attack_1": "res://assets/sprites/enemies/bosses/mercury/mercury-boss-attaque-1.png",
        "attack_2": "res://assets/sprites/enemies/bosses/mercury/mercury-boss-attaque-2.png"
    },
    # ... idem pour les autres planètes
}

func _on_boss_attacked(target: BaseEntity, damage: int, is_crit: bool, boss: BaseEnemy) -> void:
    if not is_instance_valid(boss):
        return
    
    # Choisir aléatoirement attack_1 ou attack_2
    var attack_sprite: String
    if randf() > 0.5:
        attack_sprite = boss.get_meta("sprite_attack_1", "")
    else:
        attack_sprite = boss.get_meta("sprite_attack_2", "")
    
    _set_boss_sprite(boss, attack_sprite)
    
    # Revenir à idle après 0.3s
    await get_tree().create_timer(0.3).timeout
    if is_instance_valid(boss) and boss.is_alive:
        _set_boss_sprite(boss, boss.get_meta("sprite_idle", ""))
```

---

### 5. Bug des Vaisseaux - Vague Suivante
**Localisation**: `_on_wave_cleared()`, `_on_enemy_died()`

**Bug actuel**: La vague suivante apparaît quand les ennemis au sol sont tués, même si des vaisseaux sont encore en vie.

**Correction**:
- Modifier `_on_wave_cleared()` pour vérifier AUSSI les vaisseaux actifs
- Modifier `_on_ship_died()` pour déclencher `_on_wave_cleared()` si c'était le dernier ennemi

```gdscript
func _on_enemy_died(enemy: BaseEnemy) -> void:
    # ... code existant ...
    
    # Vérifier si vague terminée (ennemis AU SOL + vaisseaux)
    if active_enemies.is_empty() and active_ships.is_empty():
        _on_wave_cleared()

func _on_ship_died(ship: BaseEnemy) -> void:
    # ... code existant ...
    
    active_ships.erase(ship)
    ship_visuals.erase(ship)
    
    # Vérifier si vague terminée
    if active_enemies.is_empty() and active_ships.is_empty():
        _on_wave_cleared()
```

**Modifications visuelles des vaisseaux**:
- Position: Déplacer `ship_container` plus à gauche (x: 0.45 au lieu de 0.60)
- Barre de vie: Rouge (`Color(0.9, 0.2, 0.2)`) au lieu de violet

```gdscript
# Dans _setup_combat_zone():
ship_container.position = Vector2(viewport_size.x * 0.45, viewport_size.y * 0.25)

# Dans _create_ship_visual():
hp_fill.color = Color(0.9, 0.2, 0.2)  # Rouge au lieu de violet
```

---

### 6. Affichage des Annonces de Vagues/Boss
**Localisation**: `_show_wave_title()`

**Actuellement**: Animation complexe avec panel, bordures, sous-titres.

**Correction**:
- Supprimer TOUTES les animations
- Simple Label centré à l'écran
- Apparaît instantanément, disparaît après 1.5 secondes
- Pas de panel, juste le texte avec ombre

```gdscript
func _show_wave_title(text: String, color: Color, _is_boss: bool = false) -> void:
    var viewport_size: Vector2 = get_viewport().get_visible_rect().size
    
    # Simple label centré
    var label := Label.new()
    label.name = "WaveTitle"
    label.text = text
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 48)
    label.add_theme_color_override("font_color", color)
    label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
    label.add_theme_constant_override("shadow_offset_x", 3)
    label.add_theme_constant_override("shadow_offset_y", 3)
    
    # Centrer à l'écran
    label.set_anchors_preset(Control.PRESET_CENTER)
    label.position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
    label.pivot_offset = label.size / 2
    
    effects_layer.add_child(label)
    
    # Attendre 1.5 secondes puis supprimer
    await get_tree().create_timer(1.5).timeout
    if is_instance_valid(label):
        label.queue_free()
```

---

### 7. Optimisation des Hit Points (Floating Damage)
**Localisation**: `_show_floating_text()`, `_on_enemy_damaged()`, `_on_hero_damaged()`

**Problèmes actuels**:
- Dégâts des ennemis affichés en dessous d'eux (devrait être au-dessus)
- Dégâts reçus par le héros affichés devant la barre de vie
- Style visuel "moche"

**Corrections**:

#### Position des dégâts ennemis (au-dessus):
```gdscript
func _on_enemy_damaged(amount: int, is_crit: bool, enemy: BaseEnemy) -> void:
    # ... flash et sprite hurt ...
    
    # Position AU-DESSUS de l'ennemi (y négatif = plus haut)
    var sprite_height := 330  # Hauteur approximative du sprite ennemi
    var pos := enemy_container.position + enemy.position + Vector2(0, -sprite_height - 30)
    
    # Style amélioré
    var text := "-%d" % amount
    var color := Color(1.0, 1.0, 0.0)  # Jaune par défaut
    var size := 22
    if is_crit:
        text = "💥 %d" % amount
        color = Color(1.0, 0.5, 0.0)  # Orange pour crit
        size = 28
    
    _show_damage_text(text, pos, color, size)
```

#### Position des dégâts héros (au-dessus, pas devant HP bar):
```gdscript
func _on_hero_damaged(amount: int, is_crit: bool) -> void:
    _flash_entity(hero, Color(1.0, 0.3, 0.3))
    
    # Position bien AU-DESSUS du héros (éviter la barre de vie)
    var sprite_height := 660  # Hauteur du sprite héros
    var pos := hero_container.position + Vector2(0, -sprite_height - 50)
    
    var text := "-%d" % amount
    var color := Color(1.0, 0.3, 0.3)
    var size := 24
    if is_crit:
        text = "💥 -%d" % amount
        size = 30
    
    _show_damage_text(text, pos, color, size)
```

#### Nouveau style de floating text optimisé:
```gdscript
func _show_damage_text(text: String, pos: Vector2, color: Color, size: int = 24) -> void:
    var label := Label.new()
    label.text = text
    label.add_theme_font_size_override("font_size", size)
    label.add_theme_color_override("font_color", color)
    # Ombre pour lisibilité
    label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
    label.add_theme_constant_override("shadow_offset_x", 2)
    label.add_theme_constant_override("shadow_offset_y", 2)
    label.position = pos
    label.z_index = 100
    effects_layer.add_child(label)
    
    # Animation: monte + grossit légèrement + fade out
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", pos.y - 40, 0.6).set_ease(Tween.EASE_OUT)
    tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.15)
    tween.chain()
    tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
    tween.tween_property(label, "modulate:a", 0.0, 0.4)
    tween.chain().tween_callback(label.queue_free)
```

---

## 📁 Fichiers à Modifier

| Fichier | Modifications |
|---------|---------------|
| `scenes/game_combat_scene.gd` | Toutes les modifications listées ci-dessus |

---

## ✅ Checklist de Test

### Sprites Héros
- [ ] `alien-stand.png` utilisé pour IDLE, READY, DODGE
- [ ] `alien-tire.png` utilisé pour toutes les attaques
- [ ] Transition sprite fluide lors des attaques

### Animation Entrée Héros
- [ ] Héros slide depuis la gauche au début du combat
- [ ] Animation fluide (0.8s, ease out)
- [ ] Pas de glitch visuel

### Système de Vagues
- [ ] Wave 1: 1 ennemi, 0 vaisseau
- [ ] Wave 2: 3 ennemis, 0 vaisseau
- [ ] Wave 3: 5 ennemis, 0 vaisseau
- [ ] Wave 4: 5 ennemis, 1 vaisseau
- [ ] Wave 5: 5 ennemis, 3 vaisseaux
- [ ] Ennemis individuellement plus forts (x3 HP, x2.5 ATK)
- [ ] Animation slide-in depuis la droite pour tous les ennemis

### Boss
- [ ] Boss a x5 HP et x5 ATK
- [ ] Animation d'attaque alterne aléatoirement entre 2 sprites
- [ ] Sprite idle entre les attaques

### Vaisseaux
- [ ] Vague suivante attend que TOUS les ennemis (sol + air) soient morts
- [ ] Vaisseaux positionnés plus à gauche
- [ ] Barre de vie rouge (pas violet)

### Annonces
- [ ] Titre de vague centré à l'écran
- [ ] Pas d'animation, apparition/disparition instantanée
- [ ] Durée affichage: 1.5 secondes

### Hit Points
- [ ] Dégâts ennemis affichés AU-DESSUS d'eux
- [ ] Dégâts héros affichés AU-DESSUS (pas devant HP bar)
- [ ] Style visuel propre avec ombre
- [ ] Animation smooth (monte + scale + fade)

---

## 🔗 Stories Liées

- COF-907: Combat Layout Resize
- COF-908: Apply Upgrades to Combat
- COF-802: Enemy Type Definitions

---

## 📝 Notes d'Implémentation

1. **Ordre d'implémentation recommandé**:
   1. Sprites héros (simple)
   2. Animation entrée héros
   3. Fix vaisseaux (bug critique)
   4. Refonte vagues
   5. Annonces simplifiées
   6. Hit points optimisés
   7. Animations boss

2. **Points d'attention**:
   - Ne pas casser les signaux existants lors des modifications
   - Tester sur mobile (720p) pour vérifier les positions
   - Les animations doivent être fluides à 60 FPS
