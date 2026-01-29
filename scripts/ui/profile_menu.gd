## ProfileMenu - Écran Profil Style Sci-Fi (comme ShopMenu)
## Layout: Header + Stats 2x2 + Hero Sprite + Équipement 3 cards + Inventaire tabs/grille
## Thème Sci-Fi Espace/Mercure - Pixel Art Moderne
extends Control

# =============================================================================
# CONSTANTES DE DESIGN (identiques au shop)
# =============================================================================

const LEVEL_SELECT_SCENE := "res://scenes/ui/level_select.tscn"
const BACKGROUND_PATH := "res://assets/backgrounds/background-menu-selection.png"
const HERO_SPRITE_PATH := "res://assets/sprites/hero/hero_idle.png"

## Couleurs Sci-Fi Néon
const COLOR_BLACK_DEEP := Color("#0A0A0F")
const COLOR_BLUE_NIGHT := Color("#0D1B2A")
const COLOR_NEON_CYAN := Color("#00D4FF")
const COLOR_NEON_PINK := Color("#FF3388")
const COLOR_NEON_GREEN := Color("#33FF88")
const COLOR_NEON_GOLD := Color("#FFD933")
const COLOR_NEON_PURPLE := Color("#AA44FF")
const COLOR_NEON_ORANGE := Color("#FF6633")
const COLOR_WHITE_GLOW := Color("#FFFFFF")
const COLOR_PANEL_BG := Color(0.03, 0.03, 0.12, 0.92)
const COLOR_TAB_ACTIVE := Color(0.1, 0.1, 0.25, 0.95)
const COLOR_TAB_INACTIVE := Color(0.05, 0.05, 0.15, 0.7)
const COLOR_SUCCESS := Color(0.2, 0.9, 0.4)
const COLOR_ERROR := Color(1.0, 0.3, 0.3)

## Couleurs par type de stat
const STAT_COLORS := {
	"max_hp": Color("#FF3388"),
	"attack_power": Color("#FF6633"),
	"dodge_chance": Color("#00D4FF"),
	"heal_power": Color("#33FF88")
}

## Couleurs par type d'équipement
const EQUIP_COLORS := {
	"weapon": Color("#FF3388"),
	"armor": Color("#00D4FF"),
	"helmet": Color("#33FF88")
}

## Tailles de police responsive
const HEADER_FONT_SIZE := 36
const CURRENCY_FONT_SIZE := 20
const SECTION_TITLE_SIZE := 22
const TAB_FONT_SIZE := 16
const STAT_NAME_SIZE := 14
const STAT_VALUE_SIZE := 12
const ITEM_NAME_SIZE := 12
const ITEM_BONUS_SIZE := 11

## Espacements
const MARGIN_HORIZONTAL := 20
const MARGIN_TOP := 50
const MARGIN_BOTTOM := 25
const SECTION_SPACING := 20
const ITEM_SPACING := 10

## Configuration des upgrades
const UPGRADES_CONFIG := {
	"max_hp": {
		"name": "PV Max",
		"icon_image": "res://assets/emojies/heart-sprites.png",
		"base_value": 100,
		"per_level": 15,
		"base_cost": 50,
		"cost_multiplier": 1.5,
		"max_level": 20,
		"description": "Points de vie"
	},
	"attack_power": {
		"name": "Dégâts",
		"icon_image": "res://assets/emojies/defense-sprites.png",
		"base_value": 10,
		"per_level": 2,
		"base_cost": 75,
		"cost_multiplier": 1.6,
		"max_level": 20,
		"description": "Puissance d'attaque"
	},
	"dodge_chance": {
		"name": "Esquive",
		"icon_image": "res://assets/emojies/esquive-sprites.png",
		"base_value": 5,
		"per_level": 2,
		"base_cost": 100,
		"cost_multiplier": 1.7,
		"max_level": 15,
		"unit": "%",
		"description": "Chance d'esquive"
	},
	"heal_power": {
		"name": "Soin",
		"icon_image": "res://assets/emojies/heal-sprites.png",
		"base_value": 8,
		"per_level": 2,
		"base_cost": 60,
		"cost_multiplier": 1.5,
		"max_level": 20,
		"description": "Puissance de soin"
	}
}

## Données des équipements (avec images)
const EQUIPMENT_DATA := {
	"weapon": {"title": "ARMES", "icon": "⚔️", "items": [
		{"id": "sword_basic", "name": "Pistolet Basique", "bonus": "+5 DMG", "bonus_value": 5, "stat": "attack_power", "image": "res://assets/sprites/ui/équipements/armes/pistolet basique.png"},
		{"id": "sword_flame", "name": "Pistolet Puissant", "bonus": "+12 DMG", "bonus_value": 12, "stat": "attack_power", "image": "res://assets/sprites/ui/équipements/armes/pistolet plus fort.png"},
		{"id": "sword_cosmic", "name": "Pistolet Royal", "bonus": "+25 DMG", "bonus_value": 25, "stat": "attack_power", "image": "res://assets/sprites/ui/équipements/armes/pistolet royal.png"}
	]},
	"armor": {"title": "ARMURES", "icon": "🛡️", "items": [
		{"id": "armor_light", "name": "Armure Basique", "bonus": "+5% ESQ", "bonus_value": 5, "stat": "dodge_chance", "image": "res://assets/sprites/ui/équipements/armures/armure basique.png"},
		{"id": "armor_shadow", "name": "Armure Renforcée", "bonus": "+10% ESQ", "bonus_value": 10, "stat": "dodge_chance", "image": "res://assets/sprites/ui/équipements/armures/armure_plus_fort.png"},
		{"id": "armor_cosmic", "name": "Armure Royale", "bonus": "+18% ESQ", "bonus_value": 18, "stat": "dodge_chance", "image": "res://assets/sprites/ui/équipements/armures/armure royal.png"}
	]},
	"helmet": {"title": "CASQUES", "icon": "⛑️", "items": [
		{"id": "helmet_basic", "name": "Casque Basique", "bonus": "+3 SOIN", "bonus_value": 3, "stat": "heal_power", "image": "res://assets/sprites/ui/équipements/casques/casque basique.png"},
		{"id": "helmet_nature", "name": "Casque Renforcé", "bonus": "+8 SOIN", "bonus_value": 8, "stat": "heal_power", "image": "res://assets/sprites/ui/équipements/casques/casque plus fort.png"},
		{"id": "helmet_cosmic", "name": "Casque Royal", "bonus": "+15 SOIN", "bonus_value": 15, "stat": "heal_power", "image": "res://assets/sprites/ui/équipements/casques/casque royal.png"}
	]}
}

# =============================================================================
# VARIABLES
# =============================================================================

var viewport_size: Vector2
var back_button: Button
var currency_label: Label
var stats_grid: GridContainer
var hero_sprite: TextureRect
var equipped_container: HBoxContainer
var inventory_tabs_container: HBoxContainer
var inventory_grid: GridContainer
var current_inventory_tab: String = "weapon"
var inventory_tab_buttons: Dictionary = {}
var stars_container: Control


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	viewport_size = get_viewport().get_visible_rect().size
	_setup_full_ui()


func _setup_full_ui() -> void:
	# Nettoyer les enfants du .tscn
	for child in get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	# 1. Background
	_create_background()
	
	# 2. Étoiles animées
	_create_stars_background()
	
	# 3. Layout principal
	_create_main_layout()
	
	# 4. Connexions et données
	_connect_signals()
	_update_currency_display()
	_populate_stats_grid()
	_populate_equipped_cards()
	_populate_inventory()
	_animate_entrance()
	_animate_hero()


# =============================================================================
# BACKGROUND & ÉTOILES
# =============================================================================

func _create_background() -> void:
	var bg_color := ColorRect.new()
	bg_color.name = "BackgroundColor"
	bg_color.color = COLOR_BLACK_DEEP
	bg_color.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_color.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_color)
	
	var bg_texture := TextureRect.new()
	bg_texture.name = "BackgroundImage"
	var texture = load(BACKGROUND_PATH)
	if texture:
		bg_texture.texture = texture
	bg_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_texture.modulate.a = 0.5
	add_child(bg_texture)


func _create_stars_background() -> void:
	stars_container = Control.new()
	stars_container.name = "StarsContainer"
	stars_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	stars_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stars_container)
	
	for i in range(25):
		var star := ColorRect.new()
		star.size = Vector2(2, 2) if randf() > 0.3 else Vector2(3, 3)
		star.color = Color(1, 1, 1, randf_range(0.3, 0.8))
		star.position = Vector2(randf() * viewport_size.x, randf() * viewport_size.y)
		star.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stars_container.add_child(star)
		_animate_star(star)


func _animate_star(star: ColorRect) -> void:
	var tween := create_tween()
	tween.set_loops()
	var duration := randf_range(1.5, 3.0)
	var target_alpha := randf_range(0.1, 0.4)
	tween.tween_property(star, "modulate:a", target_alpha, duration)
	tween.tween_property(star, "modulate:a", 1.0, duration)


# =============================================================================
# LAYOUT PRINCIPAL
# =============================================================================

func _create_main_layout() -> void:
	var root_margin := MarginContainer.new()
	root_margin.name = "RootMargin"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", MARGIN_HORIZONTAL)
	root_margin.add_theme_constant_override("margin_right", MARGIN_HORIZONTAL)
	root_margin.add_theme_constant_override("margin_top", MARGIN_TOP)
	root_margin.add_theme_constant_override("margin_bottom", MARGIN_BOTTOM)
	add_child(root_margin)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", SECTION_SPACING)
	root_margin.add_child(main_vbox)
	
	# === HEADER ===
	_create_header(main_vbox)
	
	# === SCROLL CONTAINER ===
	var scroll := ScrollContainer.new()
	scroll.name = "MainScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)
	
	var content_vbox := VBoxContainer.new()
	content_vbox.name = "ContentVBox"
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", SECTION_SPACING)
	scroll.add_child(content_vbox)
	
	# === SECTION STATS (grille 2x2) ===
	_create_stats_section(content_vbox)
	
	# === SECTION HERO + ÉQUIPEMENT ===
	_create_hero_section(content_vbox)
	
	# === SECTION ÉQUIPEMENT ÉQUIPÉ ===
	_create_equipped_section(content_vbox)
	
	# === SECTION INVENTAIRE ===
	_create_inventory_section(content_vbox)


# =============================================================================
# HEADER
# =============================================================================

func _create_header(parent: Control) -> void:
	var header_panel := PanelContainer.new()
	header_panel.name = "HeaderPanel"
	header_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = Color(0.02, 0.02, 0.08, 0.85)
	header_style.corner_radius_top_left = 14
	header_style.corner_radius_top_right = 14
	header_style.corner_radius_bottom_left = 14
	header_style.corner_radius_bottom_right = 14
	header_style.border_width_bottom = 2
	header_style.border_color = COLOR_NEON_CYAN
	header_style.content_margin_left = 14
	header_style.content_margin_right = 14
	header_style.content_margin_top = 10
	header_style.content_margin_bottom = 10
	header_panel.add_theme_stylebox_override("panel", header_style)
	parent.add_child(header_panel)
	
	var header_hbox := HBoxContainer.new()
	header_hbox.name = "HeaderHBox"
	header_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_theme_constant_override("separation", 10)
	header_panel.add_child(header_hbox)
	
	# Bouton retour
	back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = "◀"
	back_button.custom_minimum_size = Vector2(55, 50)
	back_button.add_theme_font_size_override("font_size", 26)
	_style_button_neon(back_button, COLOR_NEON_CYAN)
	header_hbox.add_child(back_button)
	
	# Titre PROFIL
	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "PROFIL"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", HEADER_FONT_SIZE)
	title_label.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	title_label.add_theme_color_override("font_outline_color", COLOR_NEON_CYAN)
	title_label.add_theme_constant_override("outline_size", 3)
	header_hbox.add_child(title_label)
	
	# Monnaie
	var currency_panel := PanelContainer.new()
	currency_panel.name = "CurrencyPanel"
	var currency_style := StyleBoxFlat.new()
	currency_style.bg_color = Color(0.05, 0.05, 0.15, 0.9)
	currency_style.corner_radius_top_left = 10
	currency_style.corner_radius_top_right = 10
	currency_style.corner_radius_bottom_left = 10
	currency_style.corner_radius_bottom_right = 10
	currency_style.border_width_left = 2
	currency_style.border_width_right = 2
	currency_style.border_width_top = 2
	currency_style.border_width_bottom = 2
	currency_style.border_color = COLOR_NEON_GOLD
	currency_style.content_margin_left = 12
	currency_style.content_margin_right = 12
	currency_style.content_margin_top = 6
	currency_style.content_margin_bottom = 6
	currency_panel.add_theme_stylebox_override("panel", currency_style)
	header_hbox.add_child(currency_panel)
	
	currency_label = Label.new()
	currency_label.name = "CurrencyLabel"
	currency_label.text = "0 SC"
	currency_label.add_theme_font_size_override("font_size", CURRENCY_FONT_SIZE)
	currency_label.add_theme_color_override("font_color", COLOR_NEON_GOLD)
	currency_panel.add_child(currency_label)


# =============================================================================
# SECTION STATS (Grille 2x2 style packs)
# =============================================================================

func _create_stats_section(parent: Control) -> void:
	var section := VBoxContainer.new()
	section.name = "StatsSection"
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 12)
	parent.add_child(section)
	
	# Titre
	var title := Label.new()
	title.name = "StatsTitle"
	title.text = "AMÉLIORATIONS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", SECTION_TITLE_SIZE)
	title.add_theme_color_override("font_color", COLOR_NEON_GOLD)
	title.add_theme_color_override("font_outline_color", Color(0.6, 0.4, 0.1, 0.6))
	title.add_theme_constant_override("outline_size", 2)
	section.add_child(title)
	
	# Centrer la grille
	var center_container := CenterContainer.new()
	center_container.name = "StatsCenterContainer"
	center_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_child(center_container)
	
	# Grille 2x2
	stats_grid = GridContainer.new()
	stats_grid.name = "StatsGrid"
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", ITEM_SPACING)
	stats_grid.add_theme_constant_override("v_separation", ITEM_SPACING)
	center_container.add_child(stats_grid)


func _populate_stats_grid() -> void:
	for child in stats_grid.get_children():
		child.queue_free()
	
	var available_width := viewport_size.x - (MARGIN_HORIZONTAL * 2)
	var card_width := (available_width - ITEM_SPACING) / 2.0
	
	for stat_id in UPGRADES_CONFIG:
		var card := _create_stat_card(stat_id, card_width)
		stats_grid.add_child(card)


func _create_stat_card(stat_id: String, card_width: float) -> Control:
	var config: Dictionary = UPGRADES_CONFIG[stat_id]
	var level := 0
	if SaveManager:
		level = SaveManager.get_upgrade_level(stat_id)
	var current_value := _get_stat_value(stat_id, level)
	var next_value := _get_stat_value(stat_id, level + 1)
	var cost := _get_upgrade_cost(stat_id, level)
	var max_level: int = config["max_level"]
	var is_maxed: bool = level >= max_level
	var can_afford: bool = false
	if SaveManager:
		can_afford = SaveManager.can_afford(cost)
	var unit: String = config.get("unit", "")
	var stat_color: Color = STAT_COLORS.get(stat_id, COLOR_NEON_CYAN)
	
	var card := PanelContainer.new()
	card.name = "StatCard_%s" % stat_id
	card.custom_minimum_size = Vector2(card_width, 95)
	
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = COLOR_PANEL_BG
	card_style.corner_radius_top_left = 12
	card_style.corner_radius_top_right = 12
	card_style.corner_radius_bottom_left = 12
	card_style.corner_radius_bottom_right = 12
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.border_color = stat_color
	card_style.content_margin_left = 10
	card_style.content_margin_right = 10
	card_style.content_margin_top = 8
	card_style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", card_style)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	card.add_child(hbox)
	
	# Icône (image au lieu d'emoji)
	var icon_container := CenterContainer.new()
	icon_container.custom_minimum_size = Vector2(36, 36)
	hbox.add_child(icon_container)
	
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(32, 32)
	icon.size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var icon_texture = load(config["icon_image"])
	if icon_texture:
		icon.texture = icon_texture
	icon_container.add_child(icon)
	
	# Info
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)
	
	var name_label := Label.new()
	name_label.text = config["name"]
	name_label.add_theme_font_size_override("font_size", STAT_NAME_SIZE)
	name_label.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	info_vbox.add_child(name_label)
	
	var level_label := Label.new()
	level_label.text = "Niv. %d/%d" % [level, max_level]
	level_label.add_theme_font_size_override("font_size", STAT_VALUE_SIZE)
	level_label.add_theme_color_override("font_color", stat_color)
	info_vbox.add_child(level_label)
	
	var value_label := Label.new()
	if is_maxed:
		value_label.text = "%d%s (MAX)" % [current_value, unit]
		value_label.add_theme_color_override("font_color", COLOR_NEON_GOLD)
	else:
		value_label.text = "%d%s → %d%s" % [current_value, unit, next_value, unit]
		value_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	value_label.add_theme_font_size_override("font_size", STAT_VALUE_SIZE)
	info_vbox.add_child(value_label)
	
	# Bouton upgrade
	var upgrade_btn := Button.new()
	upgrade_btn.name = "UpgradeBtn_%s" % stat_id
	upgrade_btn.custom_minimum_size = Vector2(70, 50)
	
	if is_maxed:
		upgrade_btn.text = "MAX"
		upgrade_btn.disabled = true
		_style_button_neon(upgrade_btn, Color(0.4, 0.4, 0.4))
	else:
		upgrade_btn.text = "+\n%d" % cost
		if can_afford:
			_style_button_neon(upgrade_btn, COLOR_NEON_GREEN)
		else:
			_style_button_neon(upgrade_btn, Color(0.5, 0.3, 0.3))
			upgrade_btn.disabled = true
	
	upgrade_btn.add_theme_font_size_override("font_size", 12)
	upgrade_btn.pressed.connect(_on_upgrade_stat.bind(stat_id))
	hbox.add_child(upgrade_btn)
	
	return card


# =============================================================================
# SECTION HERO
# =============================================================================

func _create_hero_section(parent: Control) -> void:
	var center := CenterContainer.new()
	center.name = "HeroCenterContainer"
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(center)
	
	var hero_panel := PanelContainer.new()
	hero_panel.name = "HeroPanel"
	
	var hero_style := StyleBoxFlat.new()
	hero_style.bg_color = Color(0.02, 0.02, 0.08, 0.7)
	hero_style.corner_radius_top_left = 16
	hero_style.corner_radius_top_right = 16
	hero_style.corner_radius_bottom_left = 16
	hero_style.corner_radius_bottom_right = 16
	hero_style.border_width_left = 2
	hero_style.border_width_right = 2
	hero_style.border_width_top = 2
	hero_style.border_width_bottom = 2
	hero_style.border_color = COLOR_NEON_PURPLE
	hero_style.content_margin_left = 20
	hero_style.content_margin_right = 20
	hero_style.content_margin_top = 15
	hero_style.content_margin_bottom = 15
	hero_panel.add_theme_stylebox_override("panel", hero_style)
	center.add_child(hero_panel)
	
	hero_sprite = TextureRect.new()
	hero_sprite.name = "HeroSprite"
	var hero_size := viewport_size.x * 0.35
	hero_sprite.custom_minimum_size = Vector2(hero_size, hero_size)
	hero_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex = load(HERO_SPRITE_PATH)
	if tex:
		hero_sprite.texture = tex
	hero_panel.add_child(hero_sprite)


func _animate_hero() -> void:
	if not hero_sprite:
		return
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(hero_sprite, "scale", Vector2(1.02, 1.02), 1.5).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(hero_sprite, "scale", Vector2(1.0, 1.0), 1.5).set_ease(Tween.EASE_IN_OUT)


# =============================================================================
# SECTION ÉQUIPEMENT ÉQUIPÉ (3 cards)
# =============================================================================

func _create_equipped_section(parent: Control) -> void:
	var section := VBoxContainer.new()
	section.name = "EquippedSection"
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 10)
	parent.add_child(section)
	
	# Titre
	var title := Label.new()
	title.name = "EquippedTitle"
	title.text = "ÉQUIPEMENT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", SECTION_TITLE_SIZE)
	title.add_theme_color_override("font_color", COLOR_NEON_PURPLE)
	title.add_theme_color_override("font_outline_color", Color(0.4, 0.2, 0.6, 0.6))
	title.add_theme_constant_override("outline_size", 2)
	section.add_child(title)
	
	# Container centré
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_child(center)
	
	equipped_container = HBoxContainer.new()
	equipped_container.name = "EquippedContainer"
	equipped_container.add_theme_constant_override("separation", ITEM_SPACING)
	center.add_child(equipped_container)


func _populate_equipped_cards() -> void:
	for child in equipped_container.get_children():
		child.queue_free()
	
	var available_width := viewport_size.x - (MARGIN_HORIZONTAL * 2)
	var card_width := (available_width - (ITEM_SPACING * 2)) / 3.0
	
	for slot in ["weapon", "armor", "helmet"]:
		var card := _create_equipped_card(slot, card_width)
		equipped_container.add_child(card)


func _create_equipped_card(slot: String, card_width: float) -> Control:
	var slot_data: Dictionary = EQUIPMENT_DATA[slot]
	var equipped_id := ""
	if SaveManager:
		equipped_id = SaveManager.get_equipped(slot)
	
	var item_data: Dictionary = {}
	for item in slot_data["items"]:
		if item["id"] == equipped_id:
			item_data = item
			break
	
	var slot_color: Color = EQUIP_COLORS.get(slot, COLOR_NEON_CYAN)
	
	var card := PanelContainer.new()
	card.name = "EquippedCard_%s" % slot
	card.custom_minimum_size = Vector2(card_width, card_width * 1.2)
	
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = COLOR_PANEL_BG
	card_style.corner_radius_top_left = 12
	card_style.corner_radius_top_right = 12
	card_style.corner_radius_bottom_left = 12
	card_style.corner_radius_bottom_right = 12
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.border_color = slot_color
	card_style.content_margin_left = 6
	card_style.content_margin_right = 6
	card_style.content_margin_top = 8
	card_style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", card_style)
	
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	
	# Type label
	var type_label := Label.new()
	type_label.text = "%s %s" % [slot_data["icon"], slot_data["title"]]
	type_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_label.add_theme_font_size_override("font_size", 12)
	type_label.add_theme_color_override("font_color", slot_color)
	vbox.add_child(type_label)
	
	# Image
	var image_container := CenterContainer.new()
	image_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(image_container)
	
	var image := TextureRect.new()
	var img_size := card_width * 0.6
	image.custom_minimum_size = Vector2(img_size, img_size)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	if not item_data.is_empty():
		var tex = load(item_data["image"])
		if tex:
			image.texture = tex
	else:
		# Placeholder grisé
		image.modulate = Color(0.3, 0.3, 0.3)
	image_container.add_child(image)
	
	# Nom
	var name_label := Label.new()
	if not item_data.is_empty():
		name_label.text = item_data["name"]
		name_label.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	else:
		name_label.text = "Aucun"
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", ITEM_NAME_SIZE)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)
	
	# Bonus
	var bonus_label := Label.new()
	if not item_data.is_empty():
		bonus_label.text = item_data["bonus"]
		bonus_label.add_theme_color_override("font_color", COLOR_NEON_GREEN)
	else:
		bonus_label.text = "-"
		bonus_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus_label.add_theme_font_size_override("font_size", ITEM_BONUS_SIZE)
	vbox.add_child(bonus_label)
	
	return card


# =============================================================================
# SECTION INVENTAIRE (Tabs + Grille)
# =============================================================================

func _create_inventory_section(parent: Control) -> void:
	# Séparateur
	var separator := HSeparator.new()
	separator.add_theme_constant_override("separation", 10)
	separator.modulate = COLOR_NEON_PURPLE
	parent.add_child(separator)
	
	var section := VBoxContainer.new()
	section.name = "InventorySection"
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 12)
	parent.add_child(section)
	
	# Titre
	var title := Label.new()
	title.name = "InventoryTitle"
	title.text = "INVENTAIRE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", SECTION_TITLE_SIZE)
	title.add_theme_color_override("font_color", COLOR_NEON_CYAN)
	title.add_theme_color_override("font_outline_color", Color(0.0, 0.4, 0.6, 0.6))
	title.add_theme_constant_override("outline_size", 2)
	section.add_child(title)
	
	# Onglets centrés
	var tabs_center := CenterContainer.new()
	tabs_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_child(tabs_center)
	
	inventory_tabs_container = HBoxContainer.new()
	inventory_tabs_container.name = "InventoryTabs"
	inventory_tabs_container.add_theme_constant_override("separation", 8)
	tabs_center.add_child(inventory_tabs_container)
	
	for tab_key in EQUIPMENT_DATA.keys():
		var tab_data = EQUIPMENT_DATA[tab_key]
		var tab_btn := Button.new()
		tab_btn.name = "Tab_" + tab_key
		tab_btn.text = tab_data["title"]
		tab_btn.custom_minimum_size = Vector2(90, 40)
		tab_btn.add_theme_font_size_override("font_size", TAB_FONT_SIZE)
		tab_btn.pressed.connect(_on_inventory_tab_pressed.bind(tab_key))
		inventory_tabs_container.add_child(tab_btn)
		inventory_tab_buttons[tab_key] = tab_btn
	
	_update_inventory_tab_styles()
	
	# Grille centrée
	var grid_center := CenterContainer.new()
	grid_center.name = "InventoryGridCenter"
	grid_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section.add_child(grid_center)
	
	inventory_grid = GridContainer.new()
	inventory_grid.name = "InventoryGrid"
	inventory_grid.columns = 3
	inventory_grid.add_theme_constant_override("h_separation", ITEM_SPACING)
	inventory_grid.add_theme_constant_override("v_separation", ITEM_SPACING)
	grid_center.add_child(inventory_grid)


func _populate_inventory() -> void:
	for child in inventory_grid.get_children():
		child.queue_free()
	
	var tab_data = EQUIPMENT_DATA[current_inventory_tab]
	var items = tab_data["items"]
	
	var available_width := viewport_size.x - (MARGIN_HORIZONTAL * 2)
	var card_width := (available_width - (ITEM_SPACING * 2)) / 3.0
	
	for item_data in items:
		var owned := false
		var equipped := false
		if SaveManager:
			owned = SaveManager.owns_equipment(item_data["id"])
			var equipped_id := SaveManager.get_equipped(current_inventory_tab)
			equipped = (item_data["id"] == equipped_id)
		
		var card := _create_inventory_card(item_data, card_width, owned, equipped)
		inventory_grid.add_child(card)


func _create_inventory_card(item_data: Dictionary, card_width: float, owned: bool, equipped: bool) -> Control:
	var slot_color: Color = EQUIP_COLORS.get(current_inventory_tab, COLOR_NEON_CYAN)
	
	var card := PanelContainer.new()
	card.name = "InventoryCard_%s" % item_data["id"]
	card.custom_minimum_size = Vector2(card_width, card_width * 1.2)
	
	var card_style := StyleBoxFlat.new()
	if equipped:
		card_style.bg_color = Color(slot_color.r * 0.2, slot_color.g * 0.2, slot_color.b * 0.2, 0.95)
		card_style.border_color = COLOR_NEON_GREEN
	elif owned:
		card_style.bg_color = COLOR_PANEL_BG
		card_style.border_color = slot_color
	else:
		card_style.bg_color = Color(0.02, 0.02, 0.05, 0.8)
		card_style.border_color = Color(0.3, 0.3, 0.3)
	
	card_style.corner_radius_top_left = 10
	card_style.corner_radius_top_right = 10
	card_style.corner_radius_bottom_left = 10
	card_style.corner_radius_bottom_right = 10
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.content_margin_left = 5
	card_style.content_margin_right = 5
	card_style.content_margin_top = 6
	card_style.content_margin_bottom = 6
	card.add_theme_stylebox_override("panel", card_style)
	
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 3)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	
	# Image
	var image_container := CenterContainer.new()
	image_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(image_container)
	
	var image := TextureRect.new()
	var img_size := card_width * 0.55
	image.custom_minimum_size = Vector2(img_size, img_size)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex = load(item_data["image"])
	if tex:
		image.texture = tex
	if not owned:
		image.modulate = Color(0.3, 0.3, 0.3, 0.6)
	image_container.add_child(image)
	
	# Nom
	var name_label := Label.new()
	name_label.text = item_data["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", ITEM_NAME_SIZE)
	if owned:
		name_label.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	else:
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)
	
	# Bonus
	var bonus_label := Label.new()
	bonus_label.text = item_data["bonus"]
	bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus_label.add_theme_font_size_override("font_size", ITEM_BONUS_SIZE)
	if owned:
		bonus_label.add_theme_color_override("font_color", COLOR_NEON_GREEN)
	else:
		bonus_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	vbox.add_child(bonus_label)
	
	# Statut / Bouton équiper
	if equipped:
		var status := Label.new()
		status.text = "✓ ÉQUIPÉ"
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status.add_theme_font_size_override("font_size", 11)
		status.add_theme_color_override("font_color", COLOR_NEON_GREEN)
		vbox.add_child(status)
	elif owned:
		var equip_btn := Button.new()
		equip_btn.text = "ÉQUIPER"
		equip_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		equip_btn.custom_minimum_size.y = 28
		equip_btn.add_theme_font_size_override("font_size", 11)
		_style_button_neon(equip_btn, slot_color)
		equip_btn.pressed.connect(_on_equip_item.bind(current_inventory_tab, item_data["id"]))
		vbox.add_child(equip_btn)
	else:
		var locked := Label.new()
		locked.text = "🔒 SHOP"
		locked.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		locked.add_theme_font_size_override("font_size", 11)
		locked.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		vbox.add_child(locked)
	
	return card


func _update_inventory_tab_styles() -> void:
	for tab_key in inventory_tab_buttons.keys():
		var btn: Button = inventory_tab_buttons[tab_key]
		var is_active: bool = (tab_key == current_inventory_tab)
		var tab_color: Color = EQUIP_COLORS.get(tab_key, COLOR_NEON_CYAN)
		
		if is_active:
			_style_button_neon(btn, tab_color, true)
		else:
			_style_button_neon(btn, COLOR_TAB_INACTIVE, false)


# =============================================================================
# UTILITAIRES
# =============================================================================

func _get_upgrade_cost(upgrade_id: String, current_level: int) -> int:
	var config: Dictionary = UPGRADES_CONFIG[upgrade_id]
	return int(config["base_cost"] * pow(config["cost_multiplier"], current_level))


func _get_stat_value(upgrade_id: String, level: int) -> int:
	var config: Dictionary = UPGRADES_CONFIG[upgrade_id]
	return config["base_value"] + (level * config["per_level"])


func _style_button_neon(btn: Button, color: Color, filled: bool = false) -> void:
	var style := StyleBoxFlat.new()
	
	if filled:
		style.bg_color = Color(color.r * 0.3, color.g * 0.3, color.b * 0.3, 0.9)
	else:
		style.bg_color = Color(0.05, 0.05, 0.12, 0.85)
	
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = color
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	
	btn.add_theme_stylebox_override("normal", style)
	
	var hover_style := style.duplicate()
	hover_style.bg_color = Color(color.r * 0.4, color.g * 0.4, color.b * 0.4, 0.95)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style := style.duplicate()
	pressed_style.bg_color = Color(color.r * 0.5, color.g * 0.5, color.b * 0.5, 1.0)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
	var disabled_style := style.duplicate()
	disabled_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	disabled_style.border_color = Color(0.3, 0.3, 0.3)
	btn.add_theme_stylebox_override("disabled", disabled_style)
	
	btn.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	btn.add_theme_color_override("font_hover_color", COLOR_WHITE_GLOW)
	btn.add_theme_color_override("font_pressed_color", COLOR_WHITE_GLOW)
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5))


func _show_feedback(message: String, success: bool) -> void:
	var feedback := Label.new()
	feedback.text = message
	feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback.add_theme_font_size_override("font_size", 18)
	feedback.add_theme_color_override("font_color", COLOR_SUCCESS if success else COLOR_ERROR)
	feedback.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	feedback.add_theme_constant_override("outline_size", 3)
	
	feedback.set_anchors_preset(Control.PRESET_CENTER)
	feedback.position.y += viewport_size.y * 0.2
	add_child(feedback)
	
	var tween := create_tween()
	tween.tween_property(feedback, "position:y", feedback.position.y - 40, 0.4)
	tween.parallel().tween_property(feedback, "modulate:a", 0.0, 0.4).set_delay(0.8)
	tween.tween_callback(feedback.queue_free)


# =============================================================================
# SIGNAUX & INTERACTIONS
# =============================================================================

func _connect_signals() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	if SaveManager and SaveManager.has_signal("currency_changed"):
		SaveManager.currency_changed.connect(_on_currency_changed)


func _on_back_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)
	)


func _on_inventory_tab_pressed(tab_key: String) -> void:
	if tab_key == current_inventory_tab:
		return
	
	current_inventory_tab = tab_key
	_update_inventory_tab_styles()
	
	var tween := create_tween()
	tween.tween_property(inventory_grid, "modulate:a", 0.0, 0.1)
	tween.tween_callback(_populate_inventory)
	tween.tween_property(inventory_grid, "modulate:a", 1.0, 0.15)


func _on_upgrade_stat(stat_id: String) -> void:
	if not SaveManager:
		return
	
	var level := SaveManager.get_upgrade_level(stat_id)
	var config: Dictionary = UPGRADES_CONFIG[stat_id]
	var cost := _get_upgrade_cost(stat_id, level)
	
	if level >= config["max_level"]:
		return
	
	if SaveManager.spend_currency(cost):
		SaveManager.increase_upgrade(stat_id)
		_populate_stats_grid()
		_show_feedback("+1 %s!" % config["name"], true)


func _on_equip_item(slot: String, item_id: String) -> void:
	if not SaveManager:
		return
	
	SaveManager.equip_item(slot, item_id)
	_populate_equipped_cards()
	_populate_inventory()
	
	var item_name := ""
	for item in EQUIPMENT_DATA[slot]["items"]:
		if item["id"] == item_id:
			item_name = item["name"]
			break
	
	_show_feedback("%s équipé!" % item_name, true)


func _update_currency_display() -> void:
	if currency_label and SaveManager:
		var coins: int = SaveManager.get_currency()
		currency_label.text = str(coins) + " SC"


func _on_currency_changed(_new_amount: int) -> void:
	_update_currency_display()
	_populate_stats_grid()


# =============================================================================
# ANIMATIONS
# =============================================================================

func _animate_entrance() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
