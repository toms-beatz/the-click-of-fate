# COF-611: Pressure Gauge Visual Display

**Epic**: User Interface  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scenes/game_combat_scene.gd` (lignes 347-375)

---

## User Story

**En tant que** joueur,  
**Je veux** voir ma jauge de pression,  
**Afin de** savoir quand je peux agir sans pénalité.

---

## Description

La jauge de pression est affichée visuellement pour indiquer au joueur le niveau actuel de pression et quand il approche de l'overload.

---

## Critères d'Acceptation

- [x] Barre circulaire ou horizontale
- [x] Couleur bleu → orange → rouge
- [x] Indicateur d'overload (flash ou blink)
- [x] Decay visible (barre qui diminue)
- [x] Seuil d'overload marqué visuellement

---

## Implémentation

```gdscript
var pressure_bar: ProgressBar
var pressure_label: Label

func _setup_pressure_gauge() -> void:
    var container := HBoxContainer.new()
    container.set_anchors_preset(Control.PRESET_TOP_WIDE)
    container.offset_top = 95  # Sous la HP bar

    pressure_label = Label.new()
    pressure_label.text = "⚡"
    container.add_child(pressure_label)

    pressure_bar = ProgressBar.new()
    pressure_bar.max_value = 100
    pressure_bar.value = 0
    pressure_bar.show_percentage = false
    pressure_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    container.add_child(pressure_bar)

    # Marqueur de seuil d'overload (80%)
    var threshold_marker := ColorRect.new()
    threshold_marker.color = Color.RED
    threshold_marker.size = Vector2(2, 20)
    threshold_marker.position.x = pressure_bar.size.x * 0.8
    pressure_bar.add_child(threshold_marker)

    hud_layer.add_child(container)

func _update_pressure_display() -> void:
    var pressure := pressure_gauge.current_pressure
    pressure_bar.value = pressure

    # Couleur basée sur le niveau
    var color: Color
    if pressure < 50:
        color = Color.CYAN
    elif pressure < 80:
        color = Color.ORANGE
    else:
        color = Color.RED
        _blink_pressure_bar()

    pressure_bar.modulate = color
```

---

## Layout Visuel

```
┌────────────────────────────────────┐
│ HP ▓▓▓▓▓▓▓▓▓▓░░░░░░░░░  67/100    │
├────────────────────────────────────┤
│ ⚡ ░░░░░░░░░░░░░░░░│░░░░  25%     │
│                    ↑               │
│              Seuil 80%             │
└────────────────────────────────────┘
```

### États de la jauge

```
Sûr (Cyan):
⚡ ▓▓▓▓▓▓░░░░░░░░░░│░░░░  30%

Attention (Orange):
⚡ ▓▓▓▓▓▓▓▓▓▓▓▓▓░░│░░░░  65%

Danger (Rouge, blink):
⚡ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│▓▓▓  95%
   ⚠️ OVERLOAD!
```

---

## Animation d'Overload

```gdscript
var is_blinking: bool = false

func _blink_pressure_bar() -> void:
    if is_blinking:
        return

    is_blinking = true
    var tween := create_tween()
    tween.set_loops(0)  # Infini
    tween.tween_property(pressure_bar, "modulate:a", 0.5, 0.2)
    tween.tween_property(pressure_bar, "modulate:a", 1.0, 0.2)

func _stop_blinking() -> void:
    is_blinking = false
    pressure_bar.modulate.a = 1.0
```

---

## Animation d'Action

```gdscript
func _on_action_performed(pressure_cost: float) -> void:
    # La pression augmente immédiatement
    var tween := create_tween()
    tween.tween_property(pressure_bar, "value",
        pressure_gauge.current_pressure, 0.1)

    # Flash blanc
    tween.tween_property(pressure_bar, "modulate", Color.WHITE, 0.05)
    tween.tween_callback(_update_pressure_display)
```

---

## Decay Animation

```gdscript
func _process(delta: float) -> void:
    if pressure_gauge.current_pressure > 0:
        # Smooth decay animation
        pressure_bar.value = lerp(pressure_bar.value,
            pressure_gauge.current_pressure, delta * 10)
        _update_pressure_color()

        if pressure_gauge.current_pressure < 80:
            _stop_blinking()
```

---

## Tests de Validation

1. ✅ Jauge affichée avec valeur 0 au début
2. ✅ Clic → pression augmente visuellement
3. ✅ Pas de clic → pression diminue (decay)
4. ✅ Couleur change selon le niveau
5. ✅ Overload → blink rouge

---

## Dépendances

- **Requiert**: PressureGauge système (COF-106)
- **Utilisé par**: GameCombatScene
