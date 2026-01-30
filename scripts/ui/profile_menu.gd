## ProfileMenu - Écran Profil Style Sci-Fi (comme ShopMenu)
## Layout: Header + Stats 2x2 + Hero Sprite + Équipement 3 cards + Inventaire tabs/grille
## Thème Sci-Fi Espace/Mercure - Pixel Art Moderne
extends Control

# =============================================================================
# CONSTANTES DE DESIGN (identiques au shop)
# =============================================================================

const LEVEL_SELECT_SCENE := "res://scenes/ui/level_select.tscn"
const BACKGROUND_PATH := "res://assets/backgrounds/background-menu-selection.png"
const HERO_SPRITE_PATH := "res://assets/sprites/hero/alien-stand.png"

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

## Données des équipements (avec images) - incluant tous les gacha
const EQUIPMENT_DATA := {
	"weapon": {"title": "ARMES", "icon": "⚔️", "items": [
		# Shop items
		{"id": "sword_basic", "name": "Pistolet Basique", "bonus": "+5 DMG", "bonus_value": 5, "stat": "attack_power", "image": "res://assets/sprites/ui/équipements/armes/pistolet basique.png"},
		{"id": "sword_flame", "name": "Pistolet Puissant", "bonus": "+12 DMG", "bonus_value": 12, "stat": "attack_power", "image": "res://assets/sprites/ui/équipements/armes/pistolet plus fort.png"},
		{"id": "sword_cosmic", "name": "Pistolet Royal", "bonus": "+25 DMG", "bonus_value": 25, "stat": "attack_power", "image": "res://assets/sprites/ui/équipements/armes/pistolet royal.png"},
		# Gacha Common
		{"id": "sword_simple", "name": "Épée Simple", "bonus": "+3 ATT", "bonus_value": 3, "stat": "attack_power", "rarity": "common", "image": "res://assets/sprites/equipment/épée-simple.png"},
		{"id": "sword_angelique", "name": "Épée Angélique", "bonus": "+4 ATT", "bonus_value": 4, "stat": "attack_power", "rarity": "common", "image": "res://assets/sprites/equipment/épées-angelique.png"},
		{"id": "sword_corne", "name": "Épée Corne", "bonus": "+5 ATT", "bonus_value": 5, "stat": "attack_power", "rarity": "common", "image": "res://assets/sprites/equipment/épées-corne.png"},
		# Gacha Rare
		{"id": "sword_emeraude", "name": "Épée Émeraude", "bonus": "+8 ATT", "bonus_value": 8, "stat": "attack_power", "rarity": "rare", "image": "res://assets/sprites/equipment/épées-emeraude.png"},
		{"id": "sword_flamme", "name": "Épée Flamme", "bonus": "+10 ATT", "bonus_value": 10, "stat": "attack_power", "rarity": "rare", "image": "res://assets/sprites/equipment/épées-flamme.png"},
		{"id": "sword_glace", "name": "Épée Glace", "bonus": "+12 ATT", "bonus_value": 12, "stat": "attack_power", "rarity": "rare", "image": "res://assets/sprites/equipment/épées-glace.png"},
		# Gacha Legendary
		{"id": "sword_onyx", "name": "Épée Onyx", "bonus": "+18 ATT", "bonus_value": 18, "stat": "attack_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/épées-onyx.png"},
		{"id": "sword_turboglace", "name": "Épée TurboGlace", "bonus": "+22 ATT", "bonus_value": 22, "stat": "attack_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/épées-turboglace.png"},
		{"id": "sword_turbolegendaire", "name": "Épée TurboLégendaire", "bonus": "+28 ATT", "bonus_value": 28, "stat": "attack_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/épées-turbolegendaire.png"},
		{"id": "sword_turboonyx", "name": "Épée TurboOnyx", "bonus": "+32 ATT", "bonus_value": 32, "stat": "attack_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/épées-turboonyx.png"}
	]},
	"armor": {"title": "ARMURES", "icon": "🛡️", "items": [
		# Shop items
		{"id": "armor_light", "name": "Armure Basique", "bonus": "+5% ESQ", "bonus_value": 5, "stat": "dodge_chance", "image": "res://assets/sprites/ui/équipements/armures/armure basique.png"},
		{"id": "armor_shadow", "name": "Armure Renforcée", "bonus": "+10% ESQ", "bonus_value": 10, "stat": "dodge_chance", "image": "res://assets/sprites/ui/équipements/armures/armure_plus_fort.png"},
		{"id": "armor_cosmic", "name": "Armure Royale", "bonus": "+18% ESQ", "bonus_value": 18, "stat": "dodge_chance", "image": "res://assets/sprites/ui/équipements/armures/armure royal.png"},
		# Gacha Common
		{"id": "armor_fer", "name": "Armure Fer", "bonus": "+3 DEF", "bonus_value": 3, "stat": "defense", "rarity": "common", "image": "res://assets/sprites/equipment/armures-fer.png"},
		{"id": "armor_cool", "name": "Armure Cool", "bonus": "+4 DEF", "bonus_value": 4, "stat": "defense", "rarity": "common", "image": "res://assets/sprites/equipment/armures-cool.png"},
		{"id": "armor_nul", "name": "Armure Nul", "bonus": "+5 DEF", "bonus_value": 5, "stat": "defense", "rarity": "common", "image": "res://assets/sprites/equipment/armures-nul.png"},
		# Gacha Rare
		{"id": "armor_ninja", "name": "Armure Ninja", "bonus": "+8 DEF", "bonus_value": 8, "stat": "defense", "rarity": "rare", "image": "res://assets/sprites/equipment/armures-ninja.png"},
		{"id": "armor_rouge", "name": "Armure Rouge", "bonus": "+10 DEF", "bonus_value": 10, "stat": "defense", "rarity": "rare", "image": "res://assets/sprites/equipment/armures-rouge.png"},
		{"id": "armor_pasdingue", "name": "Armure PasDingue", "bonus": "+12 DEF", "bonus_value": 12, "stat": "defense", "rarity": "rare", "image": "res://assets/sprites/equipment/armures-pasdingue.png"},
		# Gacha Legendary
		{"id": "armor_onyx", "name": "Armure Onyx", "bonus": "+16 DEF", "bonus_value": 16, "stat": "defense", "rarity": "legendary", "image": "res://assets/sprites/equipment/armures-onyx.png"},
		{"id": "armor_gold", "name": "Armure Gold", "bonus": "+20 DEF", "bonus_value": 20, "stat": "defense", "rarity": "legendary", "image": "res://assets/sprites/equipment/armures-gold.png"},
		{"id": "armor_arcenciel", "name": "Armure Arcenciel", "bonus": "+25 DEF", "bonus_value": 25, "stat": "defense", "rarity": "legendary", "image": "res://assets/sprites/equipment/armures-arcenciel.png"},
		{"id": "armor_spatial", "name": "Armure Spatiale", "bonus": "+30 DEF", "bonus_value": 30, "stat": "defense", "rarity": "legendary", "image": "res://assets/sprites/equipment/armures-spatial.png"}
	]},
	"helmet": {"title": "CASQUES", "icon": "⛑️", "items": [
		# Shop items
		{"id": "helmet_basic", "name": "Casque Basique", "bonus": "+3 SOIN", "bonus_value": 3, "stat": "heal_power", "image": "res://assets/sprites/ui/équipements/casques/casque basique.png"},
		{"id": "helmet_nature", "name": "Casque Renforcé", "bonus": "+8 SOIN", "bonus_value": 8, "stat": "heal_power", "image": "res://assets/sprites/ui/équipements/casques/casque plus fort.png"},
		{"id": "helmet_cosmic", "name": "Casque Royal", "bonus": "+15 SOIN", "bonus_value": 15, "stat": "heal_power", "image": "res://assets/sprites/ui/équipements/casques/casque royal.png"},
		# Gacha Common
		{"id": "helmet_basique", "name": "Casque Basique", "bonus": "+2 SOIN", "bonus_value": 2, "stat": "heal_power", "rarity": "common", "image": "res://assets/sprites/equipment/casques-basique.png"},
		{"id": "helmet_fer", "name": "Casque Fer", "bonus": "+3 SOIN", "bonus_value": 3, "stat": "heal_power", "rarity": "common", "image": "res://assets/sprites/equipment/casques-fer.png"},
		{"id": "helmet_nul", "name": "Casque Nul", "bonus": "+4 SOIN", "bonus_value": 4, "stat": "heal_power", "rarity": "common", "image": "res://assets/sprites/equipment/casques-nul.png"},
		# Gacha Rare
		{"id": "helmet_flamme", "name": "Casque Flamme", "bonus": "+6 SOIN", "bonus_value": 6, "stat": "heal_power", "rarity": "rare", "image": "res://assets/sprites/equipment/casques-flamme.png"},
		{"id": "helmet_futur", "name": "Casque Futur", "bonus": "+8 SOIN", "bonus_value": 8, "stat": "heal_power", "rarity": "rare", "image": "res://assets/sprites/equipment/casques-futur.png"},
		{"id": "helmet_verre", "name": "Casque Verre", "bonus": "+10 SOIN", "bonus_value": 10, "stat": "heal_power", "rarity": "rare", "image": "res://assets/sprites/equipment/casques-verre.png"},
		# Gacha Legendary
		{"id": "helmet_halo", "name": "Casque Halo", "bonus": "+14 SOIN", "bonus_value": 14, "stat": "heal_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/casques-halo.png"}
	]}
}

# =============================================================================
# VARIABLES
# =============================================================================

var viewport_size: Vector2
var back_button: Button
var currency_label: Label
var power_label: Label
var stats_grid: GridContainer
var hero_sprite: TextureRect
var equipped_container: HBoxContainer
var inventory_container: Control
var stars_container: Control

## Références aux ScrollContainers d'inventaire par catégorie
var inventory_scroll_containers := {}
## Items possédés par catégorie (cache)
var owned_items_cache := {"weapon": [], "armor": [], "helmet": []}


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
	_update_power_display()
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
	
	# Panel Power (à gauche de currency)
	var power_panel := PanelContainer.new()
	power_panel.name = "PowerPanel"
	var power_style := StyleBoxFlat.new()
	power_style.bg_color = Color(0.05, 0.05, 0.15, 0.9)
	power_style.corner_radius_top_left = 10
	power_style.corner_radius_top_right = 10
	power_style.corner_radius_bottom_left = 10
	power_style.corner_radius_bottom_right = 10
	power_style.border_width_left = 2
	power_style.border_width_right = 2
	power_style.border_width_top = 2
	power_style.border_width_bottom = 2
	power_style.border_color = COLOR_NEON_ORANGE
	power_style.content_margin_left = 12
	power_style.content_margin_right = 12
	power_style.content_margin_top = 6
	power_style.content_margin_bottom = 6
	power_panel.add_theme_stylebox_override("panel", power_style)
	# Insérer avant currency_panel (à gauche)
	header_hbox.add_child(power_panel)
	header_hbox.move_child(power_panel, header_hbox.get_child_count() - 2)
	
	power_label = Label.new()
	power_label.name = "PowerLabel"
	power_label.text = "PWR 0"
	power_label.add_theme_font_size_override("font_size", CURRENCY_FONT_SIZE)
	power_label.add_theme_color_override("font_color", COLOR_NEON_ORANGE)
	power_panel.add_child(power_label)


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
	section.add_theme_constant_override("separation", 20)
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
	
	# Container principal pour les catégories
	inventory_container = VBoxContainer.new()
	inventory_container.name = "InventoryContainer"
	inventory_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inventory_container.add_theme_constant_override("separation", 18)
	section.add_child(inventory_container)


func _populate_inventory() -> void:
	# Nettoyer
	for child in inventory_container.get_children():
		child.queue_free()
	inventory_scroll_containers.clear()
	
	var available_width := viewport_size.x - (MARGIN_HORIZONTAL * 2)
	var card_width := (available_width - (ITEM_SPACING * 2)) / 3.0
	
	# Parcourir chaque catégorie (weapon, armor, helmet)
	for category_key in ["weapon", "armor", "helmet"]:
		var category_data = EQUIPMENT_DATA[category_key]
		var category_color: Color = EQUIP_COLORS.get(category_key, COLOR_NEON_CYAN)
		
		# Titre de la catégorie
		var category_title := Label.new()
		category_title.text = category_data["title"]
		category_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		category_title.add_theme_font_size_override("font_size", 18)
		category_title.add_theme_color_override("font_color", category_color)
		category_title.add_theme_color_override("font_outline_color", Color(category_color.r * 0.5, category_color.g * 0.5, category_color.b * 0.5, 0.6))
		category_title.add_theme_constant_override("outline_size", 2)
		inventory_container.add_child(category_title)
		
		# Récupérer les items possédés pour cette catégorie
		var owned_items: Array = []
		for item_data in category_data["items"]:
			if SaveManager and SaveManager.owns_equipment(item_data["id"]):
				owned_items.append(item_data)
		
		# Mettre en cache
		owned_items_cache[category_key] = owned_items
		
		# Si aucun item possédé, afficher "No weapon/armor/helmet"
		if owned_items.is_empty():
			var no_item_label := Label.new()
			var category_name := ""
			match category_key:
				"weapon": category_name = "weapon"
				"armor": category_name = "armor"
				"helmet": category_name = "helmet"
			no_item_label.text = "No %s" % category_name
			no_item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			no_item_label.add_theme_font_size_override("font_size", 14)
			no_item_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
			inventory_container.add_child(no_item_label)
		else:
			# Container vertical pour scroll + barre
			var scroll_section := VBoxContainer.new()
			scroll_section.add_theme_constant_override("separation", 4)
			inventory_container.add_child(scroll_section)
			
			# ScrollContainer horizontal avec scrollbar cachée
			var scroll_container := ScrollContainer.new()
			scroll_container.name = "ScrollContainer_%s" % category_key
			scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
			scroll_container.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
			scroll_container.custom_minimum_size = Vector2(available_width, card_width * 1.3)
			scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			scroll_container.follow_focus = false  # Évite le scroll automatique
			scroll_section.add_child(scroll_container)
			
			# HBoxContainer pour les items
			var items_hbox := HBoxContainer.new()
			items_hbox.name = "ItemsContainer_%s" % category_key
			items_hbox.add_theme_constant_override("separation", ITEM_SPACING)
			scroll_container.add_child(items_hbox)
			
			# Créer tous les items
			for item_data in owned_items:
				var equipped := false
				if SaveManager:
					var equipped_id := SaveManager.get_equipped(category_key)
					equipped = (item_data["id"] == equipped_id)
				
				var card := _create_inventory_card_horizontal(item_data, card_width, equipped, category_key, category_color)
				items_hbox.add_child(card)
			
			# Barre de scroll personnalisée (visible si plus de 3 items)
			if owned_items.size() > 3:
				var scrollbar_container := _create_custom_scrollbar(scroll_container, category_color, available_width)
				scroll_section.add_child(scrollbar_container)
			
			# Stocker la référence
			inventory_scroll_containers[category_key] = scroll_container


func _create_custom_scrollbar(scroll_container: ScrollContainer, color: Color, available_width: float) -> Control:
	# Container pour la barre de scroll
	var bar_bg := PanelContainer.new()
	bar_bg.custom_minimum_size = Vector2(available_width, 8)
	
	# Style fond de la barre
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.2, 0.6)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	bar_bg.add_theme_stylebox_override("panel", bg_style)
	
	# Thumb (indicateur de position)
	var thumb := Panel.new()
	thumb.name = "ScrollThumb"
	bar_bg.add_child(thumb)
	
	# Style du thumb
	var thumb_style := StyleBoxFlat.new()
	thumb_style.bg_color = color
	thumb_style.corner_radius_top_left = 4
	thumb_style.corner_radius_top_right = 4
	thumb_style.corner_radius_bottom_left = 4
	thumb_style.corner_radius_bottom_right = 4
	thumb.add_theme_stylebox_override("panel", thumb_style)
	
	# Mettre à jour la position du thumb quand on scroll
	scroll_container.get_h_scroll_bar().value_changed.connect(
		func(_value: float) -> void:
			_update_scrollbar_thumb(scroll_container, thumb, available_width)
	)
	
	# Initialiser la taille du thumb
	scroll_container.ready.connect(
		func() -> void:
			await get_tree().process_frame
			_update_scrollbar_thumb(scroll_container, thumb, available_width)
	)
	
	return bar_bg


func _update_scrollbar_thumb(scroll_container: ScrollContainer, thumb: Panel, bar_width: float) -> void:
	if not is_instance_valid(thumb) or not is_instance_valid(scroll_container):
		return
	
	var h_scroll := scroll_container.get_h_scroll_bar()
	var max_scroll := h_scroll.max_value - h_scroll.page
	
	# Calculer la taille du thumb proportionnellement
	var content_width := 0.0
	for child in scroll_container.get_children():
		content_width = child.size.x
		break
	
	if content_width <= 0:
		content_width = bar_width
	
	var visible_ratio := minf(1.0, scroll_container.size.x / content_width)
	var thumb_width := maxf(40.0, bar_width * visible_ratio)  # Minimum 40px
	
	# Calculer la position du thumb
	var scroll_ratio := 0.0
	if max_scroll > 0:
		scroll_ratio = h_scroll.value / max_scroll
	
	var max_thumb_pos := bar_width - thumb_width
	var thumb_pos := scroll_ratio * max_thumb_pos
	
	# Appliquer
	thumb.position = Vector2(thumb_pos, 0)
	thumb.size = Vector2(thumb_width, 8)


func _create_inventory_card_horizontal(item_data: Dictionary, card_width: float, equipped: bool, _slot: String, slot_color: Color) -> Control:
	var card := PanelContainer.new()
	card.name = "InventoryCard_%s" % item_data["id"]
	card.custom_minimum_size = Vector2(card_width, card_width * 1.2)
	
	var card_style := StyleBoxFlat.new()
	if equipped:
		card_style.bg_color = Color(slot_color.r * 0.2, slot_color.g * 0.2, slot_color.b * 0.2, 0.95)
		card_style.border_color = COLOR_NEON_GREEN
	else:
		card_style.bg_color = COLOR_PANEL_BG
		card_style.border_color = slot_color
	
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
	image_container.add_child(image)
	
	# Nom
	var name_label := Label.new()
	name_label.text = item_data["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", ITEM_NAME_SIZE)
	name_label.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_label)
	
	# Bonus
	var bonus_label := Label.new()
	bonus_label.text = item_data["bonus"]
	bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bonus_label.add_theme_font_size_override("font_size", ITEM_BONUS_SIZE)
	bonus_label.add_theme_color_override("font_color", COLOR_NEON_GREEN)
	vbox.add_child(bonus_label)
	
	# Statut / Bouton équiper
	if equipped:
		var status := Label.new()
		status.text = "✓ ÉQUIPÉ"
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status.add_theme_font_size_override("font_size", 11)
		status.add_theme_color_override("font_color", COLOR_NEON_GREEN)
		vbox.add_child(status)
	else:
		var equip_btn := Button.new()
		equip_btn.text = "ÉQUIPER"
		equip_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		equip_btn.custom_minimum_size.y = 28
		equip_btn.add_theme_font_size_override("font_size", 11)
		_style_button_neon(equip_btn, slot_color)
		equip_btn.pressed.connect(_on_equip_item.bind(_slot, item_data["id"]))
		vbox.add_child(equip_btn)
	
	return card


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
	# Créer un label de feedback temporaire au centre de l'écran
	var feedback := Label.new()
	feedback.text = message
	feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback.add_theme_font_size_override("font_size", 28)
	
	# Couleur verte si succès, rouge si erreur
	var text_color := Color("#33FF88") if success else Color("#FF4444")
	feedback.add_theme_color_override("font_color", text_color)
	
	# Contour blanc épais pour la lisibilité
	feedback.add_theme_color_override("font_outline_color", Color.WHITE)
	feedback.add_theme_constant_override("outline_size", 6)
	
	# Ombre noire en plus pour encore plus de contraste
	feedback.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	feedback.add_theme_constant_override("shadow_offset_x", 2)
	feedback.add_theme_constant_override("shadow_offset_y", 2)
	
	# Centrer parfaitement à l'écran
	feedback.anchors_preset = Control.PRESET_CENTER
	feedback.grow_horizontal = Control.GROW_DIRECTION_BOTH
	feedback.grow_vertical = Control.GROW_DIRECTION_BOTH
	feedback.z_index = 100  # Au-dessus de tout
	add_child(feedback)
	
	# Centrer horizontalement, positionner à 25% du haut (75% vers le haut)
	await get_tree().process_frame
	var screen_size := get_viewport().get_visible_rect().size
	feedback.position.x = (screen_size.x - feedback.size.x) / 2
	feedback.position.y = screen_size.y * 0.25 - feedback.size.y / 2
	
	# Animation: apparition puis fondu après 1 seconde
	feedback.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(feedback, "modulate:a", 1.0, 0.15)  # Apparition rapide
	tween.tween_interval(1.0)  # Reste visible 1 seconde
	tween.tween_property(feedback, "modulate:a", 0.0, 0.3)  # Fondu de sortie
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
		_update_power_display()
		_show_feedback("+1 %s!" % config["name"], true)


func _on_equip_item(slot: String, item_id: String) -> void:
	if not SaveManager:
		return
	
	SaveManager.equip_item(slot, item_id)
	_populate_equipped_cards()
	_populate_inventory()
	_update_power_display()
	
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


func _update_power_display() -> void:
	if power_label and SaveManager:
		var power := _calculate_player_power()
		power_label.text = "PWR %d" % power


func _calculate_player_power() -> int:
	if not SaveManager:
		return 100  # Valeur de base
	
	var power := 100  # Base de 100
	
	# Bonus des upgrades
	for upgrade_id in UPGRADES_CONFIG:
		var level := SaveManager.get_upgrade_level(upgrade_id)
		var per_level: int = UPGRADES_CONFIG[upgrade_id]["per_level"]
		power += level * per_level
	
	# Bonus des équipements équipés
	for slot in ["weapon", "armor", "helmet"]:
		var equipped := SaveManager.get_equipped(slot)
		if equipped != "":
			# Trouver l'équipement dans EQUIPMENT_DATA
			var slot_data = EQUIPMENT_DATA.get(slot, {})
			var items = slot_data.get("items", [])
			for item in items:
				if item["id"] == equipped:
					power += item["bonus_value"]
					break
	
	return power


func _on_currency_changed(_new_amount: int) -> void:
	_update_currency_display()
	_update_power_display()
	_populate_stats_grid()


# =============================================================================
# ANIMATIONS
# =============================================================================

func _animate_entrance() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
