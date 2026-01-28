## MainMenu - Écran du menu principal Sci-Fi Premium
##
## Design inspiré de l'image de référence:
## - Titre "CLICK OF FATE" avec effet glow néon bleu
## - Sous-titre "Master your Fate"
## - 3 boutons stylisés avec icônes et bordures luminescentes
## - Background cosmique
## - Compteur SC et version
##
## Responsive pour mobile (Android/iOS) - Format 9:16
extends Control


# =============================================================================
# CONSTANTES DE DESIGN
# =============================================================================

## Couleurs Sci-Fi
const COLOR_BLACK_DEEP := Color("#0A0A0F")
const COLOR_BLUE_NIGHT := Color("#0D1B2A")
const COLOR_NEON_BLUE := Color("#00D4FF")
const COLOR_NEON_BLUE_DIM := Color("#00D4FF", 0.5)
const COLOR_WHITE_GLOW := Color("#FFFFFF")
const COLOR_BUTTON_BG := Color(0.1, 0.12, 0.2, 0.85)
const COLOR_BUTTON_BORDER := Color("#00D4FF", 0.6)
const COLOR_BUTTON_HOVER := Color(0.15, 0.18, 0.28, 0.9)
const COLOR_SUBTITLE := Color(0.8, 0.85, 0.95, 0.8)
const COLOR_VERSION := Color(0.5, 0.55, 0.65, 0.6)

## Tailles
const TITLE_FONT_SIZE := 52
const SUBTITLE_FONT_SIZE := 22
const BUTTON_FONT_SIZE := 24
const CURRENCY_FONT_SIZE := 20
const VERSION_FONT_SIZE := 14
const BUTTON_HEIGHT := 65
const BUTTON_CORNER_RADIUS := 14
const BUTTON_BORDER_WIDTH := 2
const BUTTON_SPACING := 18

## Scènes
const LEVEL_SELECT_SCENE := "res://scenes/ui/level_select.tscn"
const OPTIONS_SCENE := "res://scenes/ui/options_menu.tscn"
const BACKGROUND_PATH := "res://assets/backgrounds/background-menu-selection.png"


# =============================================================================
# VARIABLES
# =============================================================================

var background_rect: TextureRect
var title_label: Label
var subtitle_label: Label
var play_button: Button
var options_button: Button
var quit_button: Button
var currency_label: Label
var version_label: Label
var stars_container: Control


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_setup_ui()


func _on_ui_ready() -> void:
	_connect_signals()
	_update_currency_display()
	_animate_entrance()


func _connect_signals() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	if SaveManager:
		SaveManager.currency_changed.connect(_on_currency_changed)


# =============================================================================
# UI SETUP
# =============================================================================

func _setup_ui() -> void:
	# Nettoyer les enfants existants du .tscn
	for child in get_children():
		child.queue_free()
	
	# Attendre un frame pour le nettoyage
	await get_tree().process_frame
	
	var viewport_size := get_viewport().get_visible_rect().size
	
	# 1. Background
	_create_background(viewport_size)
	
	# 2. Étoiles animées
	_create_stars_background(viewport_size)
	
	# 3. Container principal
	var main_container := _create_main_container(viewport_size)
	add_child(main_container)
	
	# 4. UI prête, connecter les signaux
	_on_ui_ready()


func _create_background(viewport_size: Vector2) -> void:
	background_rect = TextureRect.new()
	background_rect.name = "BackgroundImage"
	
	var bg_texture = load(BACKGROUND_PATH)
	if bg_texture:
		background_rect.texture = bg_texture
	
	# Adapter l'image à l'écran en couvrant tout (peut rogner)
	background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Ancres pour couvrir tout l'écran
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.anchor_left = 0.0
	background_rect.anchor_top = 0.0
	background_rect.anchor_right = 1.0
	background_rect.anchor_bottom = 1.0
	background_rect.offset_left = 0
	background_rect.offset_top = 0
	background_rect.offset_right = 0
	background_rect.offset_bottom = 0
	
	add_child(background_rect)


func _create_stars_background(viewport_size: Vector2) -> void:
	stars_container = Control.new()
	stars_container.name = "StarsContainer"
	stars_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	stars_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stars_container)
	
	# Créer des étoiles scintillantes
	for i in range(40):
		var star := ColorRect.new()
		star.size = Vector2(2, 2) if randf() > 0.3 else Vector2(3, 3)
		star.color = Color(1, 1, 1, randf_range(0.3, 0.8))
		star.position = Vector2(
			randf() * viewport_size.x,
			randf() * viewport_size.y
		)
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stars_container.add_child(star)
		
		# Animation scintillement
		_animate_star(star)


func _animate_star(star: ColorRect) -> void:
	var tween := create_tween()
	tween.set_loops()
	var duration := randf_range(1.5, 3.0)
	var target_alpha := randf_range(0.1, 0.4)
	tween.tween_property(star, "modulate:a", target_alpha, duration)
	tween.tween_property(star, "modulate:a", 1.0, duration)


func _create_main_container(viewport_size: Vector2) -> Control:
	var container := Control.new()
	container.name = "MainContainer"
	container.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Currency en haut à droite
	currency_label = _create_currency_label(viewport_size)
	container.add_child(currency_label)
	
	# Titre centré en haut
	var title_container := _create_title_section(viewport_size)
	container.add_child(title_container)
	
	# Boutons au centre-bas
	var buttons_container := _create_buttons_section(viewport_size)
	container.add_child(buttons_container)
	
	# Version en bas à droite
	version_label = _create_version_label(viewport_size)
	container.add_child(version_label)
	
	return container


func _create_currency_label(viewport_size: Vector2) -> Label:
	var label := Label.new()
	label.name = "CurrencyLabel"
	label.text = "0 SC"
	
	# Style néon digital
	label.add_theme_font_size_override("font_size", CURRENCY_FONT_SIZE)
	label.add_theme_color_override("font_color", COLOR_NEON_BLUE)
	label.add_theme_color_override("font_outline_color", COLOR_NEON_BLUE_DIM)
	label.add_theme_constant_override("outline_size", 2)
	
	# Position haut-droite
	label.position = Vector2(viewport_size.x - 150, 40)
	label.size = Vector2(130, 30)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	return label


func _create_title_section(viewport_size: Vector2) -> VBoxContainer:
	var container := VBoxContainer.new()
	container.name = "TitleSection"
	container.size = Vector2(viewport_size.x, 200)
	container.position = Vector2(0, viewport_size.y * 0.12)
	
	container.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_theme_constant_override("separation", 8)
	
	# Titre principal "CLICK OF FATE"
	title_label = Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "CLICK OF FATE"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Style glow néon
	title_label.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	title_label.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	title_label.add_theme_color_override("font_outline_color", COLOR_NEON_BLUE)
	title_label.add_theme_constant_override("outline_size", 6)
	title_label.add_theme_color_override("font_shadow_color", COLOR_NEON_BLUE_DIM)
	title_label.add_theme_constant_override("shadow_offset_x", 0)
	title_label.add_theme_constant_override("shadow_offset_y", 4)
	
	container.add_child(title_label)
	
	# Sous-titre "Master your Fate"
	subtitle_label = Label.new()
	subtitle_label.name = "SubtitleLabel"
	subtitle_label.text = "Master your Fate"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	subtitle_label.add_theme_font_size_override("font_size", SUBTITLE_FONT_SIZE)
	subtitle_label.add_theme_color_override("font_color", COLOR_SUBTITLE)
	subtitle_label.add_theme_color_override("font_outline_color", COLOR_NEON_BLUE_DIM)
	subtitle_label.add_theme_constant_override("outline_size", 1)
	
	container.add_child(subtitle_label)
	
	return container


func _create_buttons_section(viewport_size: Vector2) -> VBoxContainer:
	var container := VBoxContainer.new()
	container.name = "ButtonsSection"
	
	var button_width := viewport_size.x * 0.7  # 70% de l'écran
	container.size = Vector2(button_width, 300)
	container.position = Vector2(
		(viewport_size.x - button_width) / 2,
		viewport_size.y * 0.50
	)
	
	container.add_theme_constant_override("separation", BUTTON_SPACING)
	
	# Bouton PLAY
	play_button = _create_styled_button("P L A Y", "▶", true)
	container.add_child(play_button)
	
	# Bouton OPTIONS
	options_button = _create_styled_button("O P T I O N S", "⚙", false)
	container.add_child(options_button)
	
	# Bouton QUIT
	quit_button = _create_styled_button("Q U I T", "✕", false)
	container.add_child(quit_button)
	
	return container


func _create_styled_button(text: String, icon: String, is_primary: bool) -> Button:
	var button := Button.new()
	button.text = "   " + icon + "   " + text
	button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT if is_primary else BUTTON_HEIGHT - 5)
	
	# Style normal
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = COLOR_BUTTON_BG
	style_normal.border_color = COLOR_BUTTON_BORDER
	style_normal.border_width_top = BUTTON_BORDER_WIDTH
	style_normal.border_width_bottom = BUTTON_BORDER_WIDTH
	style_normal.border_width_left = BUTTON_BORDER_WIDTH
	style_normal.border_width_right = BUTTON_BORDER_WIDTH
	style_normal.corner_radius_top_left = BUTTON_CORNER_RADIUS
	style_normal.corner_radius_top_right = BUTTON_CORNER_RADIUS
	style_normal.corner_radius_bottom_left = BUTTON_CORNER_RADIUS
	style_normal.corner_radius_bottom_right = BUTTON_CORNER_RADIUS
	style_normal.shadow_color = COLOR_NEON_BLUE_DIM
	style_normal.shadow_size = 4
	style_normal.shadow_offset = Vector2(0, 2)
	
	# Style hover
	var style_hover := style_normal.duplicate()
	style_hover.bg_color = COLOR_BUTTON_HOVER
	style_hover.border_color = COLOR_NEON_BLUE
	style_hover.shadow_size = 8
	
	# Style pressed
	var style_pressed := style_normal.duplicate()
	style_pressed.bg_color = Color(0.05, 0.08, 0.15, 0.9)
	style_pressed.shadow_size = 2
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_stylebox_override("focus", style_normal)
	
	# Texte
	button.add_theme_font_size_override("font_size", BUTTON_FONT_SIZE if is_primary else BUTTON_FONT_SIZE - 2)
	button.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	button.add_theme_color_override("font_hover_color", COLOR_NEON_BLUE)
	button.add_theme_color_override("font_pressed_color", COLOR_NEON_BLUE_DIM)
	
	# Alignement
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	return button


func _create_version_label(viewport_size: Vector2) -> Label:
	var label := Label.new()
	label.name = "VersionLabel"
	label.text = "v1.0"
	
	label.add_theme_font_size_override("font_size", VERSION_FONT_SIZE)
	label.add_theme_color_override("font_color", COLOR_VERSION)
	
	# Position bas-droite
	label.position = Vector2(viewport_size.x - 80, viewport_size.y - 40)
	label.size = Vector2(60, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	
	return label


# =============================================================================
# UPDATES
# =============================================================================

func _update_currency_display() -> void:
	if SaveManager and currency_label:
		var sc_amount: int = SaveManager.get_currency()
		currency_label.text = "%d SC" % sc_amount


func _on_currency_changed(new_amount: int) -> void:
	if currency_label:
		currency_label.text = "%d SC" % new_amount


# =============================================================================
# ANIMATIONS
# =============================================================================

func _animate_entrance() -> void:
	# Fade in global
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
	
	# Animation du titre (slide + fade)
	if title_label:
		var original_y := title_label.position.y
		title_label.position.y -= 50
		title_label.modulate.a = 0.0
		
		var title_tween := create_tween()
		title_tween.set_parallel(true)
		title_tween.tween_property(title_label, "position:y", original_y, 0.7).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_delay(0.2)
		title_tween.tween_property(title_label, "modulate:a", 1.0, 0.5).set_delay(0.2)
	
	# Animation du sous-titre
	if subtitle_label:
		subtitle_label.modulate.a = 0.0
		var sub_tween := create_tween()
		sub_tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.5).set_delay(0.4)
	
	# Animation des boutons (cascade)
	var buttons := [play_button, options_button, quit_button]
	for i in range(buttons.size()):
		var btn: Button = buttons[i]
		if btn:
			btn.modulate.a = 0.0
			btn.position.x += 100
			var original_x := btn.position.x - 100
			
			var btn_tween := create_tween()
			btn_tween.set_parallel(true)
			btn_tween.tween_property(btn, "position:x", original_x, 0.4).set_ease(Tween.EASE_OUT).set_delay(0.5 + i * 0.1)
			btn_tween.tween_property(btn, "modulate:a", 1.0, 0.3).set_delay(0.5 + i * 0.1)


# =============================================================================
# BUTTON HANDLERS
# =============================================================================

func _on_play_pressed() -> void:
	_animate_button_press(play_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)


func _on_options_pressed() -> void:
	_animate_button_press(options_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(OPTIONS_SCENE)


func _on_quit_pressed() -> void:
	_animate_button_press(quit_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()


func _animate_button_press(button: Button) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.08)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.08)
