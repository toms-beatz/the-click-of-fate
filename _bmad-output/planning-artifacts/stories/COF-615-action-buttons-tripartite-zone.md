# COF-615: Action Buttons Tripartite Zone

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/ui/click_zone_button.gd`

---

## User Story

**En tant que** joueur mobile,  
**Je veux** 3 gros boutons d'action tactiles,  
**Afin de** jouer confortablement sur téléphone.

---

## Description

La zone de clic tripartite divise le bas de l'écran en 3 boutons égaux : Heal, Dodge, Attack. Optimisé pour le jeu mobile à une main.

---

## Critères d'Acceptation

- [x] 3 boutons couvrant toute la largeur
- [x] Taille minimale pour touch (≥100px hauteur)
- [x] Couleurs distinctives:
  - Heal: Vert 💚
  - Dodge: Bleu 💨
  - Attack: Rouge ⚔️
- [x] Feedback visuel au tap
- [x] Émission de signaux par action

---

## Implémentation

```gdscript
# click_zone_button.gd
class_name ClickZoneButton
extends Button

signal action_triggered(action_type: String)

@export var action_type: String = ""  # "heal", "dodge", "attack"
@export var action_color: Color = Color.WHITE
@export var action_emoji: String = ""

func _ready() -> void:
    _setup_style()
    pressed.connect(_on_pressed)

func _setup_style() -> void:
    # Style normal
    var normal_style := StyleBoxFlat.new()
    normal_style.bg_color = action_color
    normal_style.set_corner_radius_all(10)
    add_theme_stylebox_override("normal", normal_style)

    # Style pressed
    var pressed_style := StyleBoxFlat.new()
    pressed_style.bg_color = action_color.lightened(0.3)
    pressed_style.set_corner_radius_all(10)
    add_theme_stylebox_override("pressed", pressed_style)

    # Texte
    text = action_emoji
    add_theme_font_size_override("font_size", 32)

func _on_pressed() -> void:
    action_triggered.emit(action_type)
    _play_feedback()

func _play_feedback() -> void:
    # Vibration
    if SaveManager.is_vibration_enabled():
        Input.vibrate_handheld(30)

    # Animation scale
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.05)
    tween.tween_property(self, "scale", Vector2.ONE, 0.05)
```

---

## Setup des 3 Boutons

```gdscript
# Dans GameCombatScene
func _setup_click_zones() -> void:
    var click_container := HBoxContainer.new()
    click_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    click_container.custom_minimum_size.y = 120
    click_container.offset_top = -120

    # Heal (gauche)
    var heal_btn := ClickZoneButton.new()
    heal_btn.action_type = "heal"
    heal_btn.action_color = Color(0.2, 0.6, 0.2)  # Vert
    heal_btn.action_emoji = "💚 HEAL"
    heal_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    heal_btn.action_triggered.connect(_on_action_triggered)
    click_container.add_child(heal_btn)

    # Dodge (centre)
    var dodge_btn := ClickZoneButton.new()
    dodge_btn.action_type = "dodge"
    dodge_btn.action_color = Color(0.2, 0.4, 0.8)  # Bleu
    dodge_btn.action_emoji = "💨 DODGE"
    dodge_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    dodge_btn.action_triggered.connect(_on_action_triggered)
    click_container.add_child(dodge_btn)

    # Attack (droite)
    var attack_btn := ClickZoneButton.new()
    attack_btn.action_type = "attack"
    attack_btn.action_color = Color(0.7, 0.2, 0.2)  # Rouge
    attack_btn.action_emoji = "⚔️ ATTACK"
    attack_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    attack_btn.action_triggered.connect(_on_action_triggered)
    click_container.add_child(attack_btn)

    ui_layer.add_child(click_container)
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│                                    │
│         (Zone de combat)           │
│                                    │
│                                    │
│                                    │
├────────────┬──────────┬────────────┤
│            │          │            │
│  💚 HEAL   │💨 DODGE  │ ⚔️ ATTACK │
│            │          │            │
│   Vert     │   Bleu   │   Rouge    │
│            │          │            │
└────────────┴──────────┴────────────┘
```

---

## Dimensions Touch-Friendly

```gdscript
# Dimensions minimales recommandées pour mobile
const BUTTON_MIN_HEIGHT := 100  # Minimum pour touch confortable
const BUTTON_PADDING := 5       # Espacement entre boutons

# Sur écran 720×1280:
# Hauteur zone: ~120px
# Largeur chaque bouton: ~235px
```

---

## Handling des Actions

```gdscript
func _on_action_triggered(action_type: String) -> void:
    match action_type:
        "heal":
            _perform_heal_action()
        "dodge":
            _perform_dodge_action()
        "attack":
            _perform_attack_action()

func _perform_heal_action() -> void:
    var pressure_cost := pressure_gauge.get_action_cost("heal")
    if pressure_gauge.can_perform_action(pressure_cost):
        pressure_gauge.add_pressure(pressure_cost)
        hero.heal(hero.stats.get_heal_amount())
        # Feedback visuel

func _perform_dodge_action() -> void:
    var pressure_cost := pressure_gauge.get_action_cost("dodge")
    if pressure_gauge.can_perform_action(pressure_cost):
        pressure_gauge.add_pressure(pressure_cost)
        hero.start_dodge()
        # Feedback visuel

func _perform_attack_action() -> void:
    var pressure_cost := pressure_gauge.get_action_cost("attack")
    if pressure_gauge.can_perform_action(pressure_cost):
        pressure_gauge.add_pressure(pressure_cost)
        hero.attack()
        # Feedback visuel
```

---

## États des Boutons

```gdscript
func _update_button_states() -> void:
    # Désactiver si en overload
    var is_overload := pressure_gauge.is_overload()
    heal_btn.disabled = is_overload
    dodge_btn.disabled = is_overload
    attack_btn.disabled = is_overload

    # Feedback visuel overload
    if is_overload:
        for btn in [heal_btn, dodge_btn, attack_btn]:
            btn.modulate = Color(0.5, 0.5, 0.5)
    else:
        for btn in [heal_btn, dodge_btn, attack_btn]:
            btn.modulate = Color.WHITE
```

---

## Tests de Validation

1. ✅ 3 boutons occupent toute la largeur
2. ✅ Couleurs distinctives correctes
3. ✅ Tap → action émise + feedback
4. ✅ Vibration sur tap (si activée)
5. ✅ Boutons désactivés en overload

---

## Dépendances

- **Requiert**: PressureGauge (COF-106)
- **Utilisé par**: GameCombatScene pour les inputs joueur
