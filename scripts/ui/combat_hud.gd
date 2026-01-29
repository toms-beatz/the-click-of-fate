## CombatHUD - Interface de combat responsive pour mobile
##
## Layout:
## ┌──────────────────────────────────────────┐
## │ [HP Bar Hero]          [HP Bar Enemies] │  ← Top
## │                                          │
## │  [Pressure Gauges - 3 barres fines]     │
## │                                          │
## │        [Zone de Combat]                  │  ← Centre
## │                                          │
## │ [Skill 1] [Skill 2] [Skill 3] [Skill 4] │  ← Skills
## │                                          │
## │ ┌─────────┬─────────┬─────────┐         │
## │ │  HEAL   │  BOOST  │ ATTACK  │         │  ← Click Zone (bas)
## │ └─────────┴─────────┴─────────┘         │
## └──────────────────────────────────────────┘
class_name CombatHUD
extends CanvasLayer

## Référence au système de pression (à connecter)
@export var pressure_gauge: PressureGauge

## Hauteur du bouton click zone (en pixels)
@export var click_zone_height: float = 120.0

## Marge pour safe area (encoches, barres système)
@export var safe_margin: float = 24.0
@export var side_margin: float = 20.0

## Référence pour layout responsive
@export var base_resolution: Vector2 = Vector2(1080, 1920)
@export var min_ui_scale: float = 0.7
@export var max_ui_scale: float = 1.4


## Composants UI
var _root_container: MarginContainer
var _main_vbox: VBoxContainer
var _top_bar: HBoxContainer
var _hero_hp_bar: ProgressBar
var _enemy_hp_bar: ProgressBar
var _pressure_container: HBoxContainer
var _pressure_bars: Dictionary = {}  # {StringName: ProgressBar}
var _skill_bar: HBoxContainer
var _click_zone: ClickZoneButton
var _punishment_overlay: ColorRect
var _punishment_label: Label


func _ready() -> void:
	_setup_layout()
	_connect_signals()
	# Ensure HUD renders above other layers (helps on devices where system bars overlap)
	layer = 100

	# Ensure layout is updated after viewport is ready
	call_deferred("_on_viewport_resized")
	var vp := get_viewport()
	if vp:
		var c := Callable(self, "_on_viewport_resized")
		if not vp.size_changed.is_connected(c):
			vp.size_changed.connect(c)


func _setup_layout() -> void:
	# Root container avec marges pour safe area
	_root_container = MarginContainer.new()
	_root_container.name = "RootContainer"
	_root_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root_container.add_theme_constant_override("margin_left", int(side_margin))
	_root_container.add_theme_constant_override("margin_right", int(side_margin))
	_root_container.add_theme_constant_override("margin_top", int(side_margin))
	_root_container.add_theme_constant_override("margin_bottom", int(safe_margin))
	add_child(_root_container)
	
	# VBox principal
	_main_vbox = VBoxContainer.new()
	_main_vbox.name = "MainVBox"
	_main_vbox.add_theme_constant_override("separation", 10)
	_root_container.add_child(_main_vbox)
	
	_setup_top_bar()
	_setup_pressure_display()
	_setup_combat_zone()
	_setup_skill_bar()
	_setup_click_zone()
	_add_bottom_safe_spacer()
	_setup_punishment_overlay()


func _setup_top_bar() -> void:
	_top_bar = HBoxContainer.new()
	_top_bar.name = "TopBar"
	_top_bar.add_theme_constant_override("separation", 20)
	_main_vbox.add_child(_top_bar)
	
	# HP Bar du héros (gauche)
	var hero_container := VBoxContainer.new()
	hero_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_top_bar.add_child(hero_container)
	
	var hero_label := Label.new()
	hero_label.text = "HERO"
	hero_label.add_theme_font_size_override("font_size", 14)
	hero_container.add_child(hero_label)
	
	_hero_hp_bar = ProgressBar.new()
	_hero_hp_bar.name = "HeroHPBar"
	_hero_hp_bar.min_value = 0
	_hero_hp_bar.max_value = 100
	_hero_hp_bar.value = 100
	_hero_hp_bar.show_percentage = false
	_hero_hp_bar.custom_minimum_size.y = 20
	_setup_hp_bar_style(_hero_hp_bar, Color(0.2, 0.8, 0.3))
	hero_container.add_child(_hero_hp_bar)
	
	# Spacer central
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_top_bar.add_child(spacer)
	
	# HP Bar des ennemis (droite)
	var enemy_container := VBoxContainer.new()
	enemy_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_top_bar.add_child(enemy_container)
	
	var enemy_label := Label.new()
	enemy_label.text = "ENEMIES"
	enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy_label.add_theme_font_size_override("font_size", 14)
	enemy_container.add_child(enemy_label)
	
	_enemy_hp_bar = ProgressBar.new()
	_enemy_hp_bar.name = "EnemyHPBar"
	_enemy_hp_bar.min_value = 0
	_enemy_hp_bar.max_value = 100
	_enemy_hp_bar.value = 100
	_enemy_hp_bar.show_percentage = false
	_enemy_hp_bar.custom_minimum_size.y = 20
	_enemy_hp_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	_setup_hp_bar_style(_enemy_hp_bar, Color(0.9, 0.2, 0.2))
	enemy_container.add_child(_enemy_hp_bar)


func _setup_hp_bar_style(bar: ProgressBar, color: Color) -> void:
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = color
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	bar.add_theme_stylebox_override("fill", fill_style)


func _setup_pressure_display() -> void:
	_pressure_container = HBoxContainer.new()
	_pressure_container.name = "PressureContainer"
	_pressure_container.add_theme_constant_override("separation", 10)
	_pressure_container.custom_minimum_size.y = 15
	_main_vbox.add_child(_pressure_container)
	
	# Créer les 3 jauges de pression
	_create_pressure_bar(&"heal", "H", Color(0.2, 0.6, 0.9))
	_create_pressure_bar(&"boost", "B", Color(0.9, 0.7, 0.2))
	_create_pressure_bar(&"attack", "A", Color(0.9, 0.3, 0.2))


func _create_pressure_bar(action: StringName, label_text: String, color: Color) -> void:
	var container := HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_pressure_container.add_child(container)
	
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", color)
	container.add_child(label)
	
	var bar := ProgressBar.new()
	bar.name = str(action) + "_pressure"
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 0
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size.y = 10
	_setup_pressure_bar_style(bar, color)
	container.add_child(bar)
	
	_pressure_bars[action] = bar


func _setup_pressure_bar_style(bar: ProgressBar, color: Color) -> void:
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.15, 0.9)
	bg_style.corner_radius_top_left = 2
	bg_style.corner_radius_top_right = 2
	bg_style.corner_radius_bottom_left = 2
	bg_style.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = color
	fill_style.corner_radius_top_left = 2
	fill_style.corner_radius_top_right = 2
	fill_style.corner_radius_bottom_left = 2
	fill_style.corner_radius_bottom_right = 2
	bar.add_theme_stylebox_override("fill", fill_style)


func _setup_combat_zone() -> void:
	# Zone centrale extensible pour le combat
	var combat_zone := Control.new()
	combat_zone.name = "CombatZone"
	combat_zone.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_main_vbox.add_child(combat_zone)


func _setup_skill_bar() -> void:
	_skill_bar = HBoxContainer.new()
	_skill_bar.name = "SkillBar"
	_skill_bar.add_theme_constant_override("separation", 15)
	_skill_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_skill_bar.custom_minimum_size.y = 60
	_main_vbox.add_child(_skill_bar)
	
	# Créer 4 slots de skills (vides pour l'instant)
	for i in range(4):
		var skill_slot := _create_skill_slot(i)
		_skill_bar.add_child(skill_slot)


func _create_skill_slot(index: int) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.name = "SkillSlot_%d" % index
	slot.custom_minimum_size = Vector2(50, 50)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.25, 0.9)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.5, 0.8)
	slot.add_theme_stylebox_override("panel", style)
	
	var label := Label.new()
	label.text = str(index + 1)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	slot.add_child(label)
	
	return slot


func _setup_click_zone() -> void:
	_click_zone = ClickZoneButton.new()
	_click_zone.name = "ClickZoneButton"
	_click_zone.custom_minimum_size.y = click_zone_height
	# Add click zone into the main vbox so spacer keeps it above the bottom safe area
	_click_zone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_click_zone.h_size_flags = Control.SIZE_EXPAND_FILL
	_main_vbox.add_child(_click_zone)


func _add_bottom_safe_spacer() -> void:
	# Spacer flexible qui pousse le bouton vers le bas mais ne le sort jamais de l'écran
	var flex_spacer := Control.new()
	flex_spacer.name = "BottomFlexibleSpacer"
	flex_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_main_vbox.add_child(flex_spacer)
	# Spacer fixe minimal pour la safe area
	var safe_spacer := Control.new()
	safe_spacer.name = "BottomSafeSpacer"
	safe_spacer.custom_minimum_size.y = int(safe_margin)
	safe_spacer.size_flags_vertical = 0
	_main_vbox.add_child(safe_spacer)


func _on_viewport_resized() -> void:
	# Called when viewport changes size; reflow HUD
	_apply_responsive_layout()
	_update_click_zone_layout()


func _apply_responsive_layout() -> void:
	if not _root_container:
		return
	var vp_size := get_viewport().get_visible_rect().size
	if vp_size.x <= 0 or vp_size.y <= 0:
		return
	var scale := min(vp_size.x / base_resolution.x, vp_size.y / base_resolution.y)
	scale = clamp(scale, min_ui_scale, max_ui_scale)
	_root_container.rect_scale = Vector2(scale, scale)


func _update_click_zone_layout() -> void:
	if not _click_zone:
		return
	# Limite la hauteur max du bouton à 18% de l'écran (pour ne jamais dépasser)
	var vp_size := get_viewport().get_visible_rect().size
	var max_btn_height := int(vp_size.y * 0.18)
	var btn_height := min(click_zone_height, max_btn_height)
	_click_zone.custom_minimum_size.y = btn_height
	# Ask click zone to adapt to viewport (adjusts button height + font sizes)
	if vp_size.x > 0 and vp_size.y > 0:
		if _click_zone.has_method("update_for_viewport"):
			_click_zone.update_for_viewport(vp_size)


func _setup_punishment_overlay() -> void:
	# Overlay sombre pendant la punition
	_punishment_overlay = ColorRect.new()
	_punishment_overlay.name = "PunishmentOverlay"
	_punishment_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_punishment_overlay.color = Color(0.1, 0.0, 0.0, 0.7)
	_punishment_overlay.visible = false
	_punishment_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_punishment_overlay)
	
	# Label de punition centré
	_punishment_label = Label.new()
	_punishment_label.name = "PunishmentLabel"
	_punishment_label.text = "PUNISHED!"
	_punishment_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_punishment_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_punishment_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_punishment_label.add_theme_font_size_override("font_size", 48)
	_punishment_label.add_theme_color_override("font_color", Color.RED)
	_punishment_label.visible = false
	add_child(_punishment_label)


func _connect_signals() -> void:
	if pressure_gauge:
		pressure_gauge.pressure_changed.connect(_on_pressure_changed)
		pressure_gauge.punishment_started.connect(_on_punishment_started)
		pressure_gauge.punishment_ended.connect(_on_punishment_ended)


## Met à jour l'affichage d'une jauge de pression
func _on_pressure_changed(action_type: StringName, value: float) -> void:
	if _pressure_bars.has(action_type):
		_pressure_bars[action_type].value = value


## Affiche l'overlay de punition
func _on_punishment_started(duration: float) -> void:
	_punishment_overlay.visible = true
	_punishment_label.visible = true
	_click_zone.set_active(false)
	
	# Timer pour masquer
	var tween := create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(_on_punishment_ended)


## Cache l'overlay de punition
func _on_punishment_ended() -> void:
	_punishment_overlay.visible = false
	_punishment_label.visible = false
	_click_zone.set_active(true)


## Met à jour la barre de vie du héros
func update_hero_hp(current: int, max_hp: int) -> void:
	_hero_hp_bar.max_value = max_hp
	_hero_hp_bar.value = current


## Met à jour la barre de vie des ennemis (total)
func update_enemy_hp(current: int, max_hp: int) -> void:
	_enemy_hp_bar.max_value = max_hp
	_enemy_hp_bar.value = current


## Retourne la référence au ClickZoneButton
func get_click_zone() -> ClickZoneButton:
	return _click_zone


## Connecte le PressureGauge après création
func connect_pressure_gauge(gauge: PressureGauge) -> void:
	pressure_gauge = gauge
	_connect_signals()
