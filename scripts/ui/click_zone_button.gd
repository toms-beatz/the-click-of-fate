## ClickZoneButton - Bouton tripartite principal pour les actions du joueur
##
## Divisé en 3 zones: Heal (gauche) | Dodge (centre) | Attack (droite)
## Design Sci-Fi Premium avec effets néon et animations tactiles
##
## Layout:
## ┌─────────────┬─────────────┬─────────────┐
## │    HEAL     │    DODGE    │   ATTACK    │
## │   (vert)    │   (bleu)    │   (rouge)   │
## └─────────────┴─────────────┴─────────────┘
class_name ClickZoneButton
extends Control

## Émis quand une zone est pressée
signal zone_pressed(zone: StringName)

## Émis quand une zone est relâchée
signal zone_released(zone: StringName)


## Les 3 zones d'action
enum Zone { HEAL, DODGE, ATTACK }

## Mapping zone -> StringName pour les signaux
const ZONE_NAMES: Dictionary = {
	Zone.HEAL: &"heal",
	Zone.DODGE: &"dodge",
	Zone.ATTACK: &"attack"
}

# =============================================================================
# COULEURS SCI-FI PREMIUM
# =============================================================================

## Couleurs principales par zone (vives, contrastées)
const COLOR_HEAL := Color("#00FF00")       # Vert glowing
const COLOR_HEAL_DARK := Color("#10B981")  # Vert émeraude
const COLOR_DODGE := Color("#0066FF")      # Bleu dynamique
const COLOR_DODGE_DARK := Color("#3B82F6") # Bleu clair
const COLOR_ATTACK := Color("#FF3333")     # Rouge flamboyant
const COLOR_ATTACK_DARK := Color("#EF4444")# Rouge clair

## Couleurs d'état
const COLOR_DISABLED := Color(0.25, 0.25, 0.25, 0.8)
const COLOR_BORDER_GLOW := Color(1, 1, 1, 0.9)
const COLOR_SHADOW := Color(0, 0, 0, 0.5)

## Icônes par zone (plus grandes et visibles)
const ICON_HEAL := "❤️"
const ICON_DODGE := "🛡️"
const ICON_ATTACK := "⚔️"

# =============================================================================
# DIMENSIONS - OPTIMISÉES POUR TACTILE MOBILE
# =============================================================================

const BUTTON_CORNER_RADIUS := 16
const BUTTON_BORDER_WIDTH := 4
const BUTTON_SPACING := 16
const SHADOW_SIZE := 6
const SHADOW_OFFSET := Vector2(0, 4)
const MIN_BUTTON_HEIGHT := 90  # Hauteur minimum pour zone tactile

# Valeurs par défaut pour taille du texte; seront ajustées dynamiquement
const DEFAULT_FONT_SIZE_LABEL := 24
const DEFAULT_FONT_SIZE_ICON := 36

# Hauteur minimale/optimale utilisée pour le scaling responsive
@export var button_min_height: int = MIN_BUTTON_HEIGHT

# =============================================================================
# VARIABLES
# =============================================================================

## Couleurs de base par zone (exportées pour override)
@export var heal_color: Color = COLOR_HEAL
@export var dodge_color: Color = COLOR_DODGE
@export var attack_color: Color = COLOR_ATTACK

## Couleur de highlight quand pressé
@export var highlight_intensity: float = 0.25

## Durée du feedback visuel (secondes)
@export var feedback_duration: float = 0.1

## Est-ce que le bouton est actif?
var is_active: bool = true

## Zone actuellement pressée (null si aucune)
var _current_zone: Variant = null

## PanelContainers pour chaque zone
var _zone_rects: Dictionary = {}

## Labels pour chaque zone
var _zone_labels: Dictionary = {}

## Labels d'icônes pour chaque zone
var _zone_icons: Dictionary = {}

## Barres de cooldown pour chaque zone
var _zone_cooldown_bars: Dictionary = {}

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

## Styleboxes originaux pour restauration
var _zone_styles: Dictionary = {}


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_setup_visuals()
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	await get_tree().process_frame
	if size.x <= 0:
		push_warning("ClickZoneButton: size.x is 0, inputs won't work correctly")


# =============================================================================
# SETUP VISUEL
# =============================================================================

func _setup_visuals() -> void:
	var container := HBoxContainer.new()
	container.name = "ZoneContainer"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_theme_constant_override("separation", BUTTON_SPACING)
	add_child(container)
	
	_create_zone(container, Zone.HEAL, "HEAL", ICON_HEAL, heal_color, COLOR_HEAL_DARK)
	_create_zone(container, Zone.DODGE, "DODGE", ICON_DODGE, dodge_color, COLOR_DODGE_DARK)
	_create_zone(container, Zone.ATTACK, "ATTACK", ICON_ATTACK, attack_color, COLOR_ATTACK_DARK)


func _create_zone(parent: HBoxContainer, zone: Zone, label_text: String, icon: String, color: Color, _color_dark: Color) -> void:
	var zone_container := PanelContainer.new()
	zone_container.name = ZONE_NAMES[zone]
	zone_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	zone_container.custom_minimum_size.y = button_min_height
	zone_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(zone_container)
	
	# Le fond est maintenant dessiné dans _draw(), inutile de définir bg_color ici
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0,0,0,0) # transparent pour laisser voir le dégradé
	stylebox.border_color = color.lightened(0.3)
	stylebox.border_width_top = BUTTON_BORDER_WIDTH
	stylebox.border_width_bottom = BUTTON_BORDER_WIDTH + 1  # Plus épais en bas pour effet 3D
	stylebox.border_width_left = BUTTON_BORDER_WIDTH
	stylebox.border_width_right = BUTTON_BORDER_WIDTH

	# Coins arrondis friendly tactile
	stylebox.corner_radius_top_left = BUTTON_CORNER_RADIUS
	stylebox.corner_radius_top_right = BUTTON_CORNER_RADIUS
	stylebox.corner_radius_bottom_left = BUTTON_CORNER_RADIUS
	stylebox.corner_radius_bottom_right = BUTTON_CORNER_RADIUS

	# Ombre portée pour effet 3D pressable
	stylebox.shadow_color = COLOR_SHADOW
	stylebox.shadow_size = SHADOW_SIZE
	stylebox.shadow_offset = SHADOW_OFFSET

	# Anti-aliasing pour bordures plus nettes
	stylebox.anti_aliasing = true
	stylebox.anti_aliasing_size = 1.5

	# Ajout d'un "highlight" spéculaire simulé (bande blanche semi-transparente)
	# On utilise le draw de PanelContainer pour dessiner un highlight custom
	zone_container.add_theme_stylebox_override("panel", stylebox)
	_zone_rects[zone] = zone_container
	_zone_styles[zone] = stylebox.duplicate()

	# VBox pour contenu (icône + texte + cooldown)
	var vbox := VBoxContainer.new()
	vbox.name = "Content"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zone_container.add_child(vbox)

	# Icône géante colorée
	var icon_label := Label.new()
	icon_label.name = "Icon"
	icon_label.text = icon
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", DEFAULT_FONT_SIZE_ICON)
	icon_label.add_theme_color_override("font_color", color)
	icon_label.add_theme_color_override("font_shadow_color", color)
	icon_label.add_theme_constant_override("shadow_offset_x", 0)
	icon_label.add_theme_constant_override("shadow_offset_y", 2)
	icon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(icon_label)
	_zone_icons[zone] = icon_label

	# Label texte XXL coloré
	var label := Label.new()
	label.name = "Label"
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", DEFAULT_FONT_SIZE_LABEL)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", color.darkened(0.3))
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(label)
	_zone_labels[zone] = label

	# Barre de cooldown améliorée (invisible par défaut)
	var cooldown_bar := ProgressBar.new()
	cooldown_bar.name = "CooldownBar"
	cooldown_bar.custom_minimum_size = Vector2(0, 8)
	cooldown_bar.max_value = 100
	cooldown_bar.value = 100
	cooldown_bar.show_percentage = false
	cooldown_bar.visible = false
	cooldown_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var bar_style_bg := StyleBoxFlat.new()
	bar_style_bg.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	bar_style_bg.corner_radius_top_left = 4
	bar_style_bg.corner_radius_top_right = 4
	bar_style_bg.corner_radius_bottom_left = 4
	bar_style_bg.corner_radius_bottom_right = 4
	cooldown_bar.add_theme_stylebox_override("background", bar_style_bg)

	var bar_style_fill := StyleBoxFlat.new()
	bar_style_fill.bg_color = Color("#10B981")  # Vert émeraude
	bar_style_fill.corner_radius_top_left = 4
	bar_style_fill.corner_radius_top_right = 4
	bar_style_fill.corner_radius_bottom_left = 4
	bar_style_fill.corner_radius_bottom_right = 4
	cooldown_bar.add_theme_stylebox_override("fill", bar_style_fill)

	vbox.add_child(cooldown_bar)
	_zone_cooldown_bars[zone] = cooldown_bar


func set_button_min_height(h: int) -> void:
	button_min_height = int(h)
	for zone in _zone_rects.keys():
		var rect := _zone_rects[zone] as PanelContainer
		if rect:
			rect.custom_minimum_size.y = button_min_height
	# update fonts proportionally
	var label_size = int(max(12, int(button_min_height * 0.28)))
	var icon_size = int(max(18, int(button_min_height * 0.45)))
	for z in _zone_labels.values():
		var lbl := z as Label
		if lbl:
			lbl.add_theme_font_size_override("font_size", label_size)
	for i in _zone_icons.values():
		var ic := i as Label
		if ic:
			ic.add_theme_font_size_override("font_size", icon_size)


func update_for_viewport(vp_size: Vector2) -> void:
	# Choose button height as a percentage of viewport height (12% typical), clamped
	var target := int(clamp(vp_size.y * 0.12, 60, 140))
	set_button_min_height(target)


# =============================================================================
# INPUT HANDLING
# =============================================================================

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event as InputEventScreenTouch)
	elif event is InputEventMouseButton:
		_handle_mouse(event as InputEventMouseButton)


func _handle_touch(event: InputEventScreenTouch) -> void:
	var local_pos := get_local_mouse_position()
	var zone := _get_zone_from_position(local_pos)

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

	if _zone_blocked.get(zone, false):
		return

	if event.pressed:
		_on_zone_pressed(zone)
	else:
		_on_zone_released(zone)


func _get_zone_from_position(local_pos: Vector2) -> Zone:
	var width := size.x if size.x > 0 else 680.0
	var ratio_x := local_pos.x / width

	if ratio_x < 0.33:
		return Zone.HEAL
	elif ratio_x < 0.66:
		return Zone.DODGE
	else:
		return Zone.ATTACK


# =============================================================================
# ZONE EVENTS
# =============================================================================

func _on_zone_pressed(zone: Zone) -> void:
	print("[ClickZone] Zone pressed: ", ZONE_NAMES[zone], " | is_active: ", is_active)
	_current_zone = zone
	_show_press_feedback(zone, true)
	zone_pressed.emit(ZONE_NAMES[zone])


func _on_zone_released(zone: Zone) -> void:
	if _current_zone != null:
		_show_press_feedback(_current_zone, false)
	_current_zone = null
	zone_released.emit(ZONE_NAMES[zone])


# =============================================================================
# FEEDBACK VISUEL
# =============================================================================

func _show_press_feedback(zone: Zone, pressed: bool) -> void:
	var rect := _zone_rects.get(zone) as PanelContainer
	if not rect:
		return

	# Annuler le tween précédent
	if _feedback_tweens.has(zone) and _feedback_tweens[zone]:
		_feedback_tweens[zone].kill()

	var tween := create_tween()
	_feedback_tweens[zone] = tween
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	if pressed:
		# Effet pressed: scale down 0.95 + shift down 3px + assombrissement
		tween.set_parallel(true)
		tween.tween_property(rect, "scale", Vector2(0.92, 0.92), feedback_duration)
		tween.tween_property(rect, "position:y", rect.position.y + 3, feedback_duration)
		tween.tween_property(rect, "modulate", Color(0.75, 0.75, 0.75, 1.0), feedback_duration)
	else:
		# Restaurer avec légère animation bounce
		tween.set_parallel(true)
		tween.tween_property(rect, "scale", Vector2(1.0, 1.0), feedback_duration * 1.5)
		tween.tween_property(rect, "position:y", rect.position.y - 3, feedback_duration)
		tween.tween_property(rect, "modulate", Color.WHITE, feedback_duration)


# =============================================================================
# ÉTAT DU BOUTON
# =============================================================================

func set_active(active: bool) -> void:
	is_active = active
	modulate.a = 1.0 if active else 0.5


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

	if _zone_blocked[zone] == blocked and not blocked:
		return

	_zone_blocked[zone] = blocked

	var rect := _zone_rects.get(zone) as PanelContainer
	var label := _zone_labels.get(zone) as Label
	var icon := _zone_icons.get(zone) as Label
	var cooldown_bar := _zone_cooldown_bars.get(zone) as ProgressBar

	if not rect:
		return

	var stylebox := rect.get_theme_stylebox("panel") as StyleBoxFlat
	if not stylebox:
		return

	if blocked:
		# Style désactivé
		stylebox.bg_color = COLOR_DISABLED
		stylebox.border_color = Color(0.4, 0.4, 0.4, 0.5)
		stylebox.shadow_size = 1

		if label:
			label.text = "%.1fs" % time_remaining
			label.modulate.a = 0.6
		if icon:
			icon.modulate.a = 0.4
		if cooldown_bar:
			cooldown_bar.visible = true
			cooldown_bar.value = 0
	else:
		# Restaurer le style original
		var original_style := _zone_styles.get(zone) as StyleBoxFlat
		if original_style:
			stylebox.bg_color = original_style.bg_color
			stylebox.border_color = original_style.border_color
			stylebox.shadow_size = original_style.shadow_size

		if label:
			label.text = _zone_original_names[zone]
			label.modulate.a = 1.0
		if icon:
			icon.modulate.a = 1.0
		if cooldown_bar:
			cooldown_bar.visible = false
			cooldown_bar.value = 100


func is_zone_active(_zone_name: StringName) -> bool:
	if not is_active:
		return false
	return true


func get_current_zone_name() -> StringName:
	if _current_zone == null:
		return &""
	return ZONE_NAMES[_current_zone]

# Ajoute le dessin du highlight métallique sur chaque zone dans _draw()
func _draw() -> void:
	for zone in _zone_rects.keys():
		var rect_node = _zone_rects[zone]
		if rect_node and rect_node.is_visible_in_tree():
			var rect = rect_node.get_global_rect()
			# Dégradé radial métal
			var radial_tex := _make_radial_metal_gradient(rect.size)
			draw_texture_rect(radial_tex, rect, false)
			# Highlight spéculaire (conserve l'effet)
			var highlight_height = rect.size.y * 0.22
			var highlight_y = rect.position.y + rect.size.y * 0.13
			var highlight_rect = Rect2(rect.position.x + rect.size.x * 0.12, highlight_y, rect.size.x * 0.76, highlight_height)
			var grad = GradientTexture2D.new()
			grad.gradient = Gradient.new()
			grad.gradient.colors = [Color(1,1,1,0.38), Color(1,1,1,0.12), Color(1,1,1,0.0)]
			grad.gradient.offsets = [0.0, 0.7, 1.0]
			grad.width = int(highlight_rect.size.x)
			grad.height = int(highlight_rect.size.y)
			draw_texture_rect(grad, highlight_rect, false)

# Utilitaire pour générer une texture de dégradé radial métal
func _make_radial_metal_gradient(size: Vector2) -> ImageTexture:
	var img := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	var center := size / 2.0
	var radius := float(min(size.x, size.y)) * 0.5
	for y in range(int(size.y)):
		for x in range(int(size.x)):
			var dist := ((Vector2(x, y) - center).length()) / radius
			dist = clamp(dist, 0.0, 1.0)
			# Métal : centre très clair, bords plus foncés
			var c := Color(0.92, 0.93, 0.96).lerp(Color(0.55, 0.58, 0.62), pow(dist, 1.5))
			img.set_pixel(x, y, c)
	var tex := ImageTexture.create_from_image(img)
	return tex
