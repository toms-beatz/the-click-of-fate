## ClickZoneButton - Bouton tripartite principal pour les actions du joueur
##
## Divisé en 3 zones: Heal (gauche) | Boost (centre) | Attack (droite)
## Détecte la position X du touch/clic pour déterminer l'action.
## Gère le feedback visuel immédiat.
##
## Layout:
## ┌─────────────┬─────────────┬─────────────┐
## │    HEAL     │    BOOST    │   ATTACK    │
## │   (0-33%)   │  (33-66%)   │  (66-100%)  │
## └─────────────┴─────────────┴─────────────┘
class_name ClickZoneButton
extends Control

## Émis quand une zone est pressée
## [param zone] "heal", "boost", ou "attack"
signal zone_pressed(zone: StringName)

## Émis quand une zone est relâchée
## [param zone] "heal", "boost", ou "attack"
signal zone_released(zone: StringName)


## Les 3 zones d'action
enum Zone { HEAL, BOOST, ATTACK }

## Mapping zone -> StringName pour les signaux
const ZONE_NAMES: Dictionary = {
	Zone.HEAL: &"heal",
	Zone.BOOST: &"boost",
	Zone.ATTACK: &"attack"
}

## Couleurs de base par zone
@export var heal_color: Color = Color(0.2, 0.6, 0.9, 0.8)  # Bleu
@export var boost_color: Color = Color(0.9, 0.7, 0.2, 0.8)  # Jaune/Or
@export var attack_color: Color = Color(0.9, 0.3, 0.2, 0.8)  # Rouge

## Couleur de highlight quand pressé
@export var highlight_intensity: float = 0.3

## Durée du feedback visuel (secondes)
@export var feedback_duration: float = 0.15

## Est-ce que le bouton est actif? (false pendant punishment)
var is_active: bool = true

## Zone actuellement pressée (null si aucune)
var _current_zone: Variant = null

## ColorRects pour chaque zone (créés dynamiquement)
var _zone_rects: Dictionary = {}

## Labels pour chaque zone
var _zone_labels: Dictionary = {}

## Tweens actifs pour le feedback
var _feedback_tweens: Dictionary = {}


func _ready() -> void:
	_setup_visuals()
	
	# S'assurer que le Control reçoit les inputs
	mouse_filter = Control.MOUSE_FILTER_STOP


func _setup_visuals() -> void:
	# Créer un HBoxContainer pour les 3 zones
	var container := HBoxContainer.new()
	container.name = "ZoneContainer"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_theme_constant_override("separation", 4)
	add_child(container)
	
	# Créer les 3 zones
	_create_zone(container, Zone.HEAL, "HEAL", heal_color)
	_create_zone(container, Zone.BOOST, "BOOST", boost_color)
	_create_zone(container, Zone.ATTACK, "ATTACK", attack_color)


func _create_zone(parent: HBoxContainer, zone: Zone, label_text: String, color: Color) -> void:
	# Container pour la zone
	var zone_container := PanelContainer.new()
	zone_container.name = ZONE_NAMES[zone]
	zone_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zone_container.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Le parent gère les inputs
	parent.add_child(zone_container)
	
	# Créer un StyleBoxFlat pour le background
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = color
	stylebox.corner_radius_top_left = 8
	stylebox.corner_radius_top_right = 8
	stylebox.corner_radius_bottom_left = 8
	stylebox.corner_radius_bottom_right = 8
	zone_container.add_theme_stylebox_override("panel", stylebox)
	
	_zone_rects[zone] = zone_container
	
	# Label centré
	var label := Label.new()
	label.name = "Label"
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zone_container.add_child(label)
	
	_zone_labels[zone] = label


func _gui_input(event: InputEvent) -> void:
	# Gérer touch screen
	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	# Gérer souris (pour debug PC)
	elif event is InputEventMouseButton:
		_handle_mouse(event as InputEventMouseButton)


func _handle_touch(event: InputEventScreenTouch) -> void:
	if not is_active:
		return
	
	var local_pos := get_local_mouse_position()
	var zone := _get_zone_from_position(local_pos)
	
	if event.pressed:
		_on_zone_pressed(zone)
	else:
		_on_zone_released(zone)


func _handle_mouse(event: InputEventMouseButton) -> void:
	if not is_active:
		return
	
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	var local_pos := event.position - global_position
	var zone := _get_zone_from_position(local_pos)
	
	if event.pressed:
		_on_zone_pressed(zone)
	else:
		_on_zone_released(zone)


## Détermine la zone en fonction de la position X relative
func _get_zone_from_position(local_pos: Vector2) -> Zone:
	var ratio_x := local_pos.x / size.x
	
	if ratio_x < 0.33:
		return Zone.HEAL
	elif ratio_x < 0.66:
		return Zone.BOOST
	else:
		return Zone.ATTACK


func _on_zone_pressed(zone: Zone) -> void:
	_current_zone = zone
	_show_feedback(zone, true)
	zone_pressed.emit(ZONE_NAMES[zone])


func _on_zone_released(zone: Zone) -> void:
	if _current_zone != null:
		_show_feedback(_current_zone, false)
	_current_zone = null
	zone_released.emit(ZONE_NAMES[zone])


## Affiche le feedback visuel de pression
func _show_feedback(zone: Zone, pressed: bool) -> void:
	var rect: PanelContainer = _zone_rects.get(zone)
	if not rect:
		return
	
	var stylebox: StyleBoxFlat = rect.get_theme_stylebox("panel")
	if not stylebox:
		return
	
	# Annuler le tween précédent si existant
	if _feedback_tweens.has(zone) and _feedback_tweens[zone]:
		_feedback_tweens[zone].kill()
	
	var base_color: Color
	match zone:
		Zone.HEAL:
			base_color = heal_color
		Zone.BOOST:
			base_color = boost_color
		Zone.ATTACK:
			base_color = attack_color
	
	var target_color: Color
	if pressed:
		target_color = base_color.lightened(highlight_intensity)
	else:
		target_color = base_color
	
	# Animation de couleur
	var tween := create_tween()
	tween.tween_property(stylebox, "bg_color", target_color, feedback_duration)
	_feedback_tweens[zone] = tween


## Active ou désactive le bouton (pour punishment)
func set_active(active: bool) -> void:
	is_active = active
	
	# Feedback visuel de désactivation
	modulate.a = 1.0 if active else 0.5


## Retourne le nom de la zone actuellement pressée (ou "" si aucune)
func get_current_zone_name() -> StringName:
	if _current_zone == null:
		return &""
	return ZONE_NAMES[_current_zone]
