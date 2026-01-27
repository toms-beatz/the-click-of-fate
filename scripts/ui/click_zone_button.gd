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
enum Zone { HEAL, DODGE, ATTACK }

## Mapping zone -> StringName pour les signaux
const ZONE_NAMES: Dictionary = {
	Zone.HEAL: &"heal",
	Zone.DODGE: &"dodge",
	Zone.ATTACK: &"attack"
}

## Couleurs de base par zone
@export var heal_color: Color = Color(0.2, 0.6, 0.9, 0.8)  # Bleu
@export var dodge_color: Color = Color(0.6, 0.4, 0.9, 0.8)  # Violet
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

## Labels des noms originaux
var _zone_original_names: Dictionary = {
	Zone.HEAL: "HEAL",
	Zone.DODGE: "DODGE",
	Zone.ATTACK: "ATTACK"
}

## État de blocage par zone
var _zone_blocked: Dictionary = {
	Zone.HEAL: false,
	Zone.DODGE: false,
	Zone.ATTACK: false
}

## Tweens actifs pour le feedback
var _feedback_tweens: Dictionary = {}


func _ready() -> void:
	_setup_visuals()
	
	# S'assurer que le Control reçoit les inputs
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Attendre un frame pour que la taille soit définie
	await get_tree().process_frame
	if size.x <= 0:
		push_warning("ClickZoneButton: size.x is 0, inputs won't work correctly")


func _setup_visuals() -> void:
	# Créer un HBoxContainer pour les 3 zones
	var container := HBoxContainer.new()
	container.name = "ZoneContainer"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_theme_constant_override("separation", 4)
	add_child(container)
	
	# Créer les 3 zones
	_create_zone(container, Zone.HEAL, "HEAL", heal_color)
	_create_zone(container, Zone.DODGE, "DODGE", dodge_color)
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
	var local_pos := get_local_mouse_position()
	var zone := _get_zone_from_position(local_pos)
	
	# Vérifier si CETTE zone est bloquée (pas tout le bouton)
	if _zone_blocked.get(zone, false):
		return
	
	if event.pressed:
		_on_zone_pressed(zone)
	else:
		_on_zone_released(zone)


func _handle_mouse(event: InputEventMouseButton) -> void:
	if event.button_index != MOUSE_BUTTON_LEFT:
		return
	
	var local_pos := event.position - global_position
	var zone := _get_zone_from_position(local_pos)
	
	# Vérifier si CETTE zone est bloquée (pas tout le bouton)
	if _zone_blocked.get(zone, false):
		return
	
	if event.pressed:
		_on_zone_pressed(zone)
	else:
		_on_zone_released(zone)


## Détermine la zone en fonction de la position X relative
func _get_zone_from_position(local_pos: Vector2) -> Zone:
	# Fallback si la taille n'est pas encore définie
	var width := size.x if size.x > 0 else 680.0
	var ratio_x := local_pos.x / width
	
	if ratio_x < 0.33:
		return Zone.HEAL
	elif ratio_x < 0.66:
		return Zone.DODGE
	else:
		return Zone.ATTACK


func _on_zone_pressed(zone: Zone) -> void:
	print("[ClickZone] Zone pressed: ", ZONE_NAMES[zone], " | is_active: ", is_active)
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
		Zone.DODGE:
			base_color = dodge_color
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


## Active ou désactive le bouton entier (legacy)
func set_active(active: bool) -> void:
	is_active = active
	
	# Feedback visuel de désactivation
	modulate.a = 1.0 if active else 0.5


## Bloque une zone spécifique avec timer comme les skills
func set_zone_blocked(zone_name: StringName, blocked: bool, time_remaining: float = 0.0) -> void:
	var zone: Zone
	match zone_name:
		&"heal":
			zone = Zone.HEAL
		&"dodge", &"boost":
			zone = Zone.DODGE
		&"attack":
			zone = Zone.ATTACK
		_:
			return
	
	# Éviter de mettre à jour si l'état n'a pas changé (sauf pour le timer)
	if _zone_blocked[zone] == blocked and not blocked:
		return
	
	_zone_blocked[zone] = blocked
	
	var rect: PanelContainer = _zone_rects.get(zone)
	if not rect:
		return
	
	var stylebox: StyleBoxFlat = rect.get_theme_stylebox("panel")
	if not stylebox:
		return
	
	var label: Label = _zone_labels.get(zone)
	
	if blocked:
		# Style désactivé comme les skills
		stylebox.bg_color = Color(0.2, 0.2, 0.2, 0.7)
		stylebox.border_width_left = 2
		stylebox.border_width_top = 2
		stylebox.border_width_right = 2
		stylebox.border_width_bottom = 2
		stylebox.border_color = Color(0.5, 0.5, 0.5, 0.5)
		
		if label:
			# Afficher le timer comme les skills
			label.text = "%.1fs" % time_remaining
			label.modulate.a = 0.6
	else:
		# Restaurer la couleur et le style original
		var original_color: Color
		var original_name: String = _zone_original_names[zone]
		match zone:
			Zone.HEAL:
				original_color = heal_color
			Zone.DODGE:
				original_color = dodge_color
			Zone.ATTACK:
				original_color = attack_color
		
		stylebox.bg_color = original_color
		stylebox.border_width_left = 0
		stylebox.border_width_top = 0
		stylebox.border_width_right = 0
		stylebox.border_width_bottom = 0
		
		if label:
			label.text = original_name
			label.modulate.a = 1.0


## Vérifie si une zone spécifique est cliquable
func is_zone_active(_zone_name: StringName) -> bool:
	if not is_active:
		return false
	# Ici on pourrait ajouter une vérification des zones bloquées
	return true


## Retourne le nom de la zone actuellement pressée (ou "" si aucune)
func get_current_zone_name() -> StringName:
	if _current_zone == null:
		return &""
	return ZONE_NAMES[_current_zone]
