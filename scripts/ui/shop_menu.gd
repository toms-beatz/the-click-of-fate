## ShopMenu - Boutique Mobile Full Screen Responsive
## Layout 9:16 centré : Header massif + Packs 2x2 + Équipements tabs/grille 3xN
## Thème Sci-Fi Espace/Mercure - Pixel Art Moderne
extends Control

# =============================================================================
# CONSTANTES DE DESIGN
# =============================================================================

const LEVEL_SELECT_SCENE := "res://scenes/ui/level_select.tscn"
const BACKGROUND_PATH := "res://assets/backgrounds/background-menu-selection.png"

## Couleurs Sci-Fi Néon
const COLOR_BLACK_DEEP := Color("#0A0A0F")
const COLOR_BLUE_NIGHT := Color("#0D1B2A")
const COLOR_NEON_CYAN := Color("#00D4FF")
const COLOR_NEON_PINK := Color("#FF3388")
const COLOR_NEON_GREEN := Color("#33FF88")
const COLOR_NEON_GOLD := Color("#FFD933")
const COLOR_NEON_PURPLE := Color("#AA44FF")
const COLOR_WHITE_GLOW := Color("#FFFFFF")
const COLOR_PANEL_BG := Color(0.03, 0.03, 0.12, 0.92)
const COLOR_TAB_ACTIVE := Color(0.1, 0.1, 0.25, 0.95)
const COLOR_TAB_INACTIVE := Color(0.05, 0.05, 0.15, 0.7)
const COLOR_BUTTON_HOVER := Color(0.15, 0.2, 0.35, 0.95)
const COLOR_SUCCESS := Color(0.2, 0.9, 0.4)
const COLOR_ERROR := Color(1.0, 0.3, 0.3)

## Tailles de police responsive
const HEADER_FONT_SIZE := 42
const CURRENCY_FONT_SIZE := 22
const SECTION_TITLE_SIZE := 26
const TAB_FONT_SIZE := 18
const ITEM_NAME_SIZE := 14
const ITEM_PRICE_SIZE := 16
const PACK_NAME_SIZE := 16
const PACK_PRICE_SIZE := 18

## Espacements
const MARGIN_HORIZONTAL := 24
const MARGIN_TOP := 60
const MARGIN_BOTTOM := 30
const SECTION_SPACING := 28
const ITEM_SPACING := 12

## Données des Packs (grille 2x2)
const COIN_PACKS := [
	{"id": "pack_basic", "name": "Pack Basique", "coins": 500, "price": "0.99€", "image": "res://assets/sprites/ui/coffres/coffre-basique.png", "color": Color(0.6, 0.7, 0.8)},
	{"id": "pack_plus", "name": "Pack Plus", "coins": 1200, "price": "1.99€", "image": "res://assets/sprites/ui/coffres/coffre-plus.png", "color": Color(0.3, 0.8, 0.5)},
	{"id": "pack_luxe", "name": "Pack Luxueux", "coins": 3000, "price": "4.99€", "image": "res://assets/sprites/ui/coffres/coffre-luxueux.png", "color": Color(0.8, 0.5, 1.0)},
	{"id": "pack_royal", "name": "Pack Royal", "coins": 8000, "price": "9.99€", "image": "res://assets/sprites/ui/coffres/coffre-royal.png", "color": Color(1.0, 0.85, 0.3)}
]

## Données des équipements (onglets + grille 3xN)
const EQUIPMENT_DATA := {
	"weapon": {"title": "ARMES", "items": [
		{"id": "pistol_basic", "name": "Pistolet Basique", "cost": 200, "bonus": "+5 DMG", "image": "res://assets/sprites/ui/équipements/armes/pistolet basique.png"},
		{"id": "pistol_strong", "name": "Pistolet Puissant", "cost": 800, "bonus": "+12 DMG", "image": "res://assets/sprites/ui/équipements/armes/pistolet plus fort.png"},
		{"id": "pistol_royal", "name": "Pistolet Royal", "cost": 2500, "bonus": "+25 DMG", "image": "res://assets/sprites/ui/équipements/armes/pistolet royal.png"}
	]},
	"armor": {"title": "ARMURES", "items": [
		{"id": "armor_basic", "name": "Armure Basique", "cost": 250, "bonus": "+5% ESQ", "image": "res://assets/sprites/ui/équipements/armures/armure basique.png"},
		{"id": "armor_strong", "name": "Armure Renforcée", "cost": 900, "bonus": "+10% ESQ", "image": "res://assets/sprites/ui/équipements/armures/armure_plus_fort.png"},
		{"id": "armor_royal", "name": "Armure Royale", "cost": 3000, "bonus": "+18% ESQ", "image": "res://assets/sprites/ui/équipements/armures/armure royal.png"}
	]},
	"helmet": {"title": "CASQUES", "items": [
		{"id": "helmet_basic", "name": "Casque Basique", "cost": 180, "bonus": "+3 SOIN", "image": "res://assets/sprites/ui/équipements/casques/casque basique.png"},
		{"id": "helmet_strong", "name": "Casque Renforcé", "cost": 700, "bonus": "+8 SOIN", "image": "res://assets/sprites/ui/équipements/casques/casque plus fort.png"},
		{"id": "helmet_royal", "name": "Casque Royal", "cost": 2200, "bonus": "+15 SOIN", "image": "res://assets/sprites/ui/équipements/casques/casque royal.png"}
	]}
}

## Mapping IDs internes
const EQUIPMENT_ID_MAP := {
	"pistol_basic": "sword_basic", "pistol_strong": "sword_flame", "pistol_royal": "sword_cosmic",
	"armor_basic": "armor_light", "armor_strong": "armor_shadow", "armor_royal": "armor_cosmic",
	"helmet_basic": "helmet_basic", "helmet_strong": "helmet_nature", "helmet_royal": "helmet_cosmic"
}

## Données des Gachas
const GACHA_TYPES := {
	"common": {
		"name": "Gacha Commun",
		"price": 500,
		"color": Color("#33FF88"),
		"capsule": "res://assets/sprites/gacha/capsule-common.png",
		"pool": [
			"sword_iron", "sword_steel", "sword_bronze",
			"armor_leather", "armor_chainmail", "armor_iron",
			"helmet_leather", "helmet_iron", "helmet_steel"
		]
	},
	"rare": {
		"name": "Gacha Rare",
		"price": 1500,
		"color": Color("#00D4FF"),
		"capsule": "res://assets/sprites/gacha/capsule-rare.png",
		"pool": [
			"sword_crystal", "sword_thunder", "sword_frost",
			"armor_crystal", "armor_thunder", "armor_frost",
			"helmet_crystal", "helmet_thunder", "helmet_frost"
		]
	},
	"legendary": {
		"name": "Gacha Légendaire",
		"price": 3500,
		"color": Color("#AA44FF"),
		"capsule": "res://assets/sprites/gacha/capsule-legendary.png",
		"pool": [
			"sword_dragon", "sword_void", "sword_divine",
			"armor_dragon", "armor_void", "armor_divine",
			"helmet_dragon", "helmet_void", "helmet_divine"
		]
	}
}

## Données des équipements gacha (27 nouveaux items)
const GACHA_EQUIPMENT_DATA := {
	# === ARMES COMMUNES ===
	"sword_iron": {"name": "Iron Blade", "slot": "weapon", "bonus": "+3 DMG", "bonus_value": 3, "stat": "attack_power", "rarity": "common", "image": "res://assets/sprites/equipment/weapons/common/sword_iron.png"},
	"sword_steel": {"name": "Steel Sword", "slot": "weapon", "bonus": "+4 DMG", "bonus_value": 4, "stat": "attack_power", "rarity": "common", "image": "res://assets/sprites/equipment/weapons/common/sword_steel.png"},
	"sword_bronze": {"name": "Bronze Cutter", "slot": "weapon", "bonus": "+5 DMG", "bonus_value": 5, "stat": "attack_power", "rarity": "common", "image": "res://assets/sprites/equipment/weapons/common/sword_bronze.png"},
	# === ARMES RARES ===
	"sword_crystal": {"name": "Crystal Edge", "slot": "weapon", "bonus": "+8 DMG", "bonus_value": 8, "stat": "attack_power", "rarity": "rare", "image": "res://assets/sprites/equipment/weapons/rare/sword_crystal.png"},
	"sword_thunder": {"name": "Thunder Blade", "slot": "weapon", "bonus": "+10 DMG", "bonus_value": 10, "stat": "attack_power", "rarity": "rare", "image": "res://assets/sprites/equipment/weapons/rare/sword_thunder.png"},
	"sword_frost": {"name": "Frost Fang", "slot": "weapon", "bonus": "+12 DMG", "bonus_value": 12, "stat": "attack_power", "rarity": "rare", "image": "res://assets/sprites/equipment/weapons/rare/sword_frost.png"},
	# === ARMES LÉGENDAIRES ===
	"sword_dragon": {"name": "Dragon Slayer", "slot": "weapon", "bonus": "+18 DMG", "bonus_value": 18, "stat": "attack_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/weapons/legendary/sword_dragon.png"},
	"sword_void": {"name": "Void Reaper", "slot": "weapon", "bonus": "+22 DMG", "bonus_value": 22, "stat": "attack_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/weapons/legendary/sword_void.png"},
	"sword_divine": {"name": "Divine Excalibur", "slot": "weapon", "bonus": "+28 DMG", "bonus_value": 28, "stat": "attack_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/weapons/legendary/sword_divine.png"},
	# === ARMURES COMMUNES ===
	"armor_leather": {"name": "Leather Vest", "slot": "armor", "bonus": "+3% ESQ", "bonus_value": 3, "stat": "dodge_chance", "rarity": "common", "image": "res://assets/sprites/equipment/armors/common/armor_leather.png"},
	"armor_chainmail": {"name": "Chainmail", "slot": "armor", "bonus": "+4% ESQ", "bonus_value": 4, "stat": "dodge_chance", "rarity": "common", "image": "res://assets/sprites/equipment/armors/common/armor_chainmail.png"},
	"armor_iron": {"name": "Iron Plate", "slot": "armor", "bonus": "+5% ESQ", "bonus_value": 5, "stat": "dodge_chance", "rarity": "common", "image": "res://assets/sprites/equipment/armors/common/armor_iron.png"},
	# === ARMURES RARES ===
	"armor_crystal": {"name": "Crystal Guard", "slot": "armor", "bonus": "+8% ESQ", "bonus_value": 8, "stat": "dodge_chance", "rarity": "rare", "image": "res://assets/sprites/equipment/armors/rare/armor_crystal.png"},
	"armor_thunder": {"name": "Storm Armor", "slot": "armor", "bonus": "+10% ESQ", "bonus_value": 10, "stat": "dodge_chance", "rarity": "rare", "image": "res://assets/sprites/equipment/armors/rare/armor_thunder.png"},
	"armor_frost": {"name": "Frost Mail", "slot": "armor", "bonus": "+12% ESQ", "bonus_value": 12, "stat": "dodge_chance", "rarity": "rare", "image": "res://assets/sprites/equipment/armors/rare/armor_frost.png"},
	# === ARMURES LÉGENDAIRES ===
	"armor_dragon": {"name": "Dragon Scale", "slot": "armor", "bonus": "+16% ESQ", "bonus_value": 16, "stat": "dodge_chance", "rarity": "legendary", "image": "res://assets/sprites/equipment/armors/legendary/armor_dragon.png"},
	"armor_void": {"name": "Void Shroud", "slot": "armor", "bonus": "+20% ESQ", "bonus_value": 20, "stat": "dodge_chance", "rarity": "legendary", "image": "res://assets/sprites/equipment/armors/legendary/armor_void.png"},
	"armor_divine": {"name": "Divine Aegis", "slot": "armor", "bonus": "+25% ESQ", "bonus_value": 25, "stat": "dodge_chance", "rarity": "legendary", "image": "res://assets/sprites/equipment/armors/legendary/armor_divine.png"},
	# === CASQUES COMMUNS ===
	"helmet_leather": {"name": "Leather Cap", "slot": "helmet", "bonus": "+2 SOIN", "bonus_value": 2, "stat": "heal_power", "rarity": "common", "image": "res://assets/sprites/equipment/helmets/common/helmet_leather.png"},
	"helmet_iron": {"name": "Iron Helm", "slot": "helmet", "bonus": "+3 SOIN", "bonus_value": 3, "stat": "heal_power", "rarity": "common", "image": "res://assets/sprites/equipment/helmets/common/helmet_iron.png"},
	"helmet_steel": {"name": "Steel Visor", "slot": "helmet", "bonus": "+4 SOIN", "bonus_value": 4, "stat": "heal_power", "rarity": "common", "image": "res://assets/sprites/equipment/helmets/common/helmet_steel.png"},
	# === CASQUES RARES ===
	"helmet_crystal": {"name": "Crystal Crown", "slot": "helmet", "bonus": "+6 SOIN", "bonus_value": 6, "stat": "heal_power", "rarity": "rare", "image": "res://assets/sprites/equipment/helmets/rare/helmet_crystal.png"},
	"helmet_thunder": {"name": "Storm Hood", "slot": "helmet", "bonus": "+8 SOIN", "bonus_value": 8, "stat": "heal_power", "rarity": "rare", "image": "res://assets/sprites/equipment/helmets/rare/helmet_thunder.png"},
	"helmet_frost": {"name": "Frost Helm", "slot": "helmet", "bonus": "+10 SOIN", "bonus_value": 10, "stat": "heal_power", "rarity": "rare", "image": "res://assets/sprites/equipment/helmets/rare/helmet_frost.png"},
	# === CASQUES LÉGENDAIRES ===
	"helmet_dragon": {"name": "Dragon Horns", "slot": "helmet", "bonus": "+14 SOIN", "bonus_value": 14, "stat": "heal_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/helmets/legendary/helmet_dragon.png"},
	"helmet_void": {"name": "Void Mask", "slot": "helmet", "bonus": "+18 SOIN", "bonus_value": 18, "stat": "heal_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/helmets/legendary/helmet_void.png"},
	"helmet_divine": {"name": "Divine Halo", "slot": "helmet", "bonus": "+22 SOIN", "bonus_value": 22, "stat": "heal_power", "rarity": "legendary", "image": "res://assets/sprites/equipment/helmets/legendary/helmet_divine.png"}
}

# =============================================================================
# VARIABLES
# =============================================================================

var viewport_size: Vector2
var back_button: Button
var currency_label: Label
var packs_grid: GridContainer
var gacha_container: HBoxContainer
var equipment_container: Control
var stars_container: Control
var gacha_overlay: Control  # Pour l'animation gacha


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
	_populate_packs()
	_populate_equipment()
	_animate_entrance()


# =============================================================================
# BACKGROUND & ÉTOILES
# =============================================================================

func _create_background() -> void:
	# Couleur de fond sombre
	var bg_color := ColorRect.new()
	bg_color.name = "BackgroundColor"
	bg_color.color = COLOR_BLACK_DEEP
	bg_color.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_color.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_color)
	
	# Image de fond
	var bg_texture := TextureRect.new()
	bg_texture.name = "BackgroundImage"
	var texture = load(BACKGROUND_PATH)
	if texture:
		bg_texture.texture = texture
	bg_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_texture.modulate.a = 0.6
	add_child(bg_texture)


func _create_stars_background() -> void:
	stars_container = Control.new()
	stars_container.name = "StarsContainer"
	stars_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	stars_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stars_container)
	
	for i in range(30):
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
# LAYOUT PRINCIPAL - STRUCTURE COMPLÈTE
# =============================================================================

func _create_main_layout() -> void:
	# Container racine avec marges safe area
	var root_margin := MarginContainer.new()
	root_margin.name = "RootMargin"
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", MARGIN_HORIZONTAL)
	root_margin.add_theme_constant_override("margin_right", MARGIN_HORIZONTAL)
	root_margin.add_theme_constant_override("margin_top", MARGIN_TOP)
	root_margin.add_theme_constant_override("margin_bottom", MARGIN_BOTTOM)
	add_child(root_margin)
	
	# VBox principal
	var main_vbox := VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_theme_constant_override("separation", SECTION_SPACING)
	root_margin.add_child(main_vbox)
	
	# === HEADER MASSIF ===
	_create_header(main_vbox)
	
	# === SCROLL CONTAINER pour le contenu ===
	var scroll := ScrollContainer.new()
	scroll.name = "MainScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)
	
	# Content VBox dans le scroll
	var content_vbox := VBoxContainer.new()
	content_vbox.name = "ContentVBox"
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", SECTION_SPACING)
	scroll.add_child(content_vbox)
	
	# === SECTION PACKS (milieu-haut) ===
	_create_packs_section(content_vbox)
	
	# === SECTION GACHA ===
	_create_gacha_section(content_vbox)
	
	# === SECTION ÉQUIPEMENTS (bas) ===
	_create_equipment_section(content_vbox)


# =============================================================================
# HEADER - Titre + Retour + Monnaie
# =============================================================================

func _create_header(parent: Control) -> void:
	# Panel header avec fond semi-transparent
	var header_panel := PanelContainer.new()
	header_panel.name = "HeaderPanel"
	header_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = Color(0.02, 0.02, 0.08, 0.85)
	header_style.corner_radius_top_left = 16
	header_style.corner_radius_top_right = 16
	header_style.corner_radius_bottom_left = 16
	header_style.corner_radius_bottom_right = 16
	header_style.border_width_bottom = 2
	header_style.border_color = COLOR_NEON_CYAN
	header_style.content_margin_left = 16
	header_style.content_margin_right = 16
	header_style.content_margin_top = 12
	header_style.content_margin_bottom = 12
	header_panel.add_theme_stylebox_override("panel", header_style)
	parent.add_child(header_panel)
	
	# HBox pour le header
	var header_hbox := HBoxContainer.new()
	header_hbox.name = "HeaderHBox"
	header_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_theme_constant_override("separation", 12)
	header_panel.add_child(header_hbox)
	
	# Bouton retour
	back_button = Button.new()
	back_button.name = "BackButton"
	back_button.text = "◀"
	back_button.custom_minimum_size = Vector2(60, 55)
	back_button.add_theme_font_size_override("font_size", 28)
	_style_button_neon(back_button, COLOR_NEON_CYAN)
	header_hbox.add_child(back_button)
	
	# Titre BOUTIQUE centré
	var title_label := Label.new()
	title_label.name = "TitleLabel"
	title_label.text = "BOUTIQUE"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", HEADER_FONT_SIZE)
	title_label.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	title_label.add_theme_color_override("font_outline_color", COLOR_NEON_CYAN)
	title_label.add_theme_constant_override("outline_size", 4)
	header_hbox.add_child(title_label)
	
	# Monnaie à droite (gros et visible)
	var currency_panel := PanelContainer.new()
	currency_panel.name = "CurrencyPanel"
	var currency_style := StyleBoxFlat.new()
	currency_style.bg_color = Color(0.05, 0.05, 0.15, 0.9)
	currency_style.corner_radius_top_left = 12
	currency_style.corner_radius_top_right = 12
	currency_style.corner_radius_bottom_left = 12
	currency_style.corner_radius_bottom_right = 12
	currency_style.border_width_left = 2
	currency_style.border_width_right = 2
	currency_style.border_width_top = 2
	currency_style.border_width_bottom = 2
	currency_style.border_color = COLOR_NEON_GOLD
	currency_style.content_margin_left = 14
	currency_style.content_margin_right = 14
	currency_style.content_margin_top = 8
	currency_style.content_margin_bottom = 8
	currency_panel.add_theme_stylebox_override("panel", currency_style)
	header_hbox.add_child(currency_panel)
	
	currency_label = Label.new()
	currency_label.name = "CurrencyLabel"
	currency_label.text = "0 SC"
	currency_label.add_theme_font_size_override("font_size", CURRENCY_FONT_SIZE)
	currency_label.add_theme_color_override("font_color", COLOR_NEON_GOLD)
	currency_label.add_theme_color_override("font_outline_color", Color(0.8, 0.6, 0.1, 0.5))
	currency_label.add_theme_constant_override("outline_size", 2)
	currency_panel.add_child(currency_label)


# =============================================================================
# SECTION PACKS - Grille 2x2 centrée
# =============================================================================

func _create_packs_section(parent: Control) -> void:
	# Container section
	var section := VBoxContainer.new()
	section.name = "PacksSection"
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 16)
	parent.add_child(section)
	
	# Titre section
	var title := Label.new()
	title.name = "PacksTitle"
	title.text = "PACKS DE COINS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", SECTION_TITLE_SIZE)
	title.add_theme_color_override("font_color", COLOR_NEON_GOLD)
	title.add_theme_color_override("font_outline_color", Color(0.6, 0.4, 0.1, 0.6))
	title.add_theme_constant_override("outline_size", 2)
	section.add_child(title)
	
	# Centrer la grille
	var center_container := CenterContainer.new()
	center_container.name = "PacksCenterContainer"
	center_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_child(center_container)
	
	# Grille 2x2
	packs_grid = GridContainer.new()
	packs_grid.name = "PacksGrid"
	packs_grid.columns = 2
	packs_grid.add_theme_constant_override("h_separation", ITEM_SPACING)
	packs_grid.add_theme_constant_override("v_separation", ITEM_SPACING)
	center_container.add_child(packs_grid)


# =============================================================================
# SECTION GACHA - 3 capsules horizontales
# =============================================================================

func _create_gacha_section(parent: Control) -> void:
	# Container section
	var section := VBoxContainer.new()
	section.name = "GachaSection"
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 16)
	parent.add_child(section)
	
	# Titre section
	var title := Label.new()
	title.name = "GachaTitle"
	title.text = "🎰 GACHA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", SECTION_TITLE_SIZE)
	title.add_theme_color_override("font_color", COLOR_NEON_PINK)
	title.add_theme_color_override("font_outline_color", Color(0.6, 0.2, 0.4, 0.6))
	title.add_theme_constant_override("outline_size", 2)
	section.add_child(title)
	
	# Container horizontal pour les 3 gachas
	var center_container := CenterContainer.new()
	center_container.name = "GachaCenterContainer"
	center_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_child(center_container)
	
	gacha_container = HBoxContainer.new()
	gacha_container.name = "GachaContainer"
	gacha_container.add_theme_constant_override("separation", ITEM_SPACING)
	center_container.add_child(gacha_container)
	
	_populate_gacha()


func _populate_gacha() -> void:
	# Nettoyer
	for child in gacha_container.get_children():
		child.queue_free()
	
	# Calculer taille des cartes - largeur disponible divisée par 3
	var available_width := viewport_size.x - (MARGIN_HORIZONTAL * 2)
	var card_width := (available_width - (ITEM_SPACING * 2)) / 3.0
	var card_height := card_width * 1.4
	
	# Créer les 3 cartes gacha
	for gacha_type in ["common", "rare", "legendary"]:
		var card := _create_gacha_card(gacha_type, card_width, card_height)
		gacha_container.add_child(card)


func _create_gacha_card(gacha_type: String, card_width: float, card_height: float) -> Control:
	var gacha_data: Dictionary = GACHA_TYPES[gacha_type]
	var color: Color = gacha_data["color"]
	
	# Panel carte
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(card_width, card_height)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(color.r * 0.15, color.g * 0.15, color.b * 0.15, 0.92)
	card_style.corner_radius_top_left = 14
	card_style.corner_radius_top_right = 14
	card_style.corner_radius_bottom_left = 14
	card_style.corner_radius_bottom_right = 14
	card_style.border_width_left = 3
	card_style.border_width_right = 3
	card_style.border_width_top = 3
	card_style.border_width_bottom = 3
	card_style.border_color = color
	card_style.content_margin_left = 8
	card_style.content_margin_right = 8
	card_style.content_margin_top = 10
	card_style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", card_style)
	
	# VBox contenu
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	
	# Nom du gacha
	var name_label := Label.new()
	name_label.text = gacha_data["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", color)
	name_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	name_label.add_theme_constant_override("outline_size", 2)
	vbox.add_child(name_label)
	
	# Image de la capsule
	var image_container := CenterContainer.new()
	image_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(image_container)
	
	var image := TextureRect.new()
	var img_size := card_width * 0.7
	image.custom_minimum_size = Vector2(img_size, img_size)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	# Essayer de charger l'image, sinon placeholder
	var tex = load(gacha_data["capsule"]) if ResourceLoader.exists(gacha_data["capsule"]) else null
	if tex:
		image.texture = tex
	else:
		# Placeholder: un ColorRect stylisé
		var placeholder := ColorRect.new()
		placeholder.custom_minimum_size = Vector2(img_size, img_size)
		placeholder.color = color.darkened(0.5)
		image_container.add_child(placeholder)
		
		var placeholder_label := Label.new()
		placeholder_label.text = "?"
		placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		placeholder_label.add_theme_font_size_override("font_size", int(img_size * 0.5))
		placeholder_label.add_theme_color_override("font_color", color)
		placeholder_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		placeholder.add_child(placeholder_label)
	
	if tex:
		image_container.add_child(image)
	
	# Étoiles de rareté
	var stars_label := Label.new()
	match gacha_type:
		"common":
			stars_label.text = "★"
		"rare":
			stars_label.text = "★★"
		"legendary":
			stars_label.text = "★★★"
	stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars_label.add_theme_font_size_override("font_size", 16)
	stars_label.add_theme_color_override("font_color", color)
	vbox.add_child(stars_label)
	
	# Bouton de tirage avec prix
	var pull_btn := Button.new()
	pull_btn.text = str(gacha_data["price"]) + " SC"
	pull_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pull_btn.custom_minimum_size.y = 38
	pull_btn.add_theme_font_size_override("font_size", 16)
	_style_button_neon(pull_btn, color, true)
	pull_btn.pressed.connect(_on_gacha_pull.bind(gacha_type))
	vbox.add_child(pull_btn)
	
	# Animation de pulse subtile sur la carte
	_animate_gacha_pulse(card, color)
	
	return card


func _animate_gacha_pulse(card: Control, _color: Color) -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(card, "modulate", Color(1.1, 1.1, 1.1, 1.0), 1.0).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(card, "modulate", Color.WHITE, 1.0).set_ease(Tween.EASE_IN_OUT)


func _on_gacha_pull(gacha_type: String) -> void:
	var gacha_data: Dictionary = GACHA_TYPES[gacha_type]
	var price: int = gacha_data["price"]
	
	# Vérifier les coins
	if not SaveManager:
		_show_feedback("Erreur SaveManager", false)
		return
	
	var current_coins: int = SaveManager.get_currency()
	if current_coins < price:
		_show_feedback("Pas assez de SC!", false)
		return
	
	# Dépenser les coins
	SaveManager.spend_currency(price)
	_update_currency_display()
	
	# Tirer un item aléatoire du pool
	var pool: Array = gacha_data["pool"]
	var won_item_id: String = pool[randi() % pool.size()]
	
	# Ajouter à l'inventaire
	SaveManager.add_equipment(won_item_id)
	
	# Lancer l'animation
	_play_gacha_animation(gacha_type, won_item_id)


# =============================================================================
# ANIMATION GACHA - Overlay avec capsule et révélation
# =============================================================================

func _play_gacha_animation(gacha_type: String, won_item_id: String) -> void:
	var gacha_data: Dictionary = GACHA_TYPES[gacha_type]
	var item_data: Dictionary = GACHA_EQUIPMENT_DATA[won_item_id]
	var rarity_color: Color = gacha_data["color"]
	
	# Créer l'overlay noir
	gacha_overlay = Control.new()
	gacha_overlay.name = "GachaOverlay"
	gacha_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	gacha_overlay.z_index = 200
	add_child(gacha_overlay)
	
	# Fond noir semi-transparent
	var bg := ColorRect.new()
	bg.name = "Background"
	bg.color = Color(0, 0, 0, 0.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP  # Bloquer les clics en dessous
	gacha_overlay.add_child(bg)
	
	# Container central pour la capsule/item
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	gacha_overlay.add_child(center)
	
	var content := Control.new()
	content.custom_minimum_size = Vector2(250, 350)
	center.add_child(content)
	
	# Capsule au centre
	var capsule := TextureRect.new()
	capsule.name = "Capsule"
	capsule.custom_minimum_size = Vector2(180, 180)
	capsule.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	capsule.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	capsule.set_anchors_preset(Control.PRESET_CENTER)
	capsule.pivot_offset = Vector2(90, 90)
	capsule.position = Vector2(-90, -120)
	capsule.scale = Vector2.ZERO
	
	var capsule_tex = load(gacha_data["capsule"]) if ResourceLoader.exists(gacha_data["capsule"]) else null
	if capsule_tex:
		capsule.texture = capsule_tex
	else:
		# Placeholder coloré
		capsule.modulate = rarity_color
	content.add_child(capsule)
	
	# Item (caché au début)
	var item_container := VBoxContainer.new()
	item_container.name = "ItemContainer"
	item_container.set_anchors_preset(Control.PRESET_CENTER)
	item_container.position = Vector2(-100, -150)
	item_container.custom_minimum_size = Vector2(200, 300)
	item_container.alignment = BoxContainer.ALIGNMENT_CENTER
	item_container.add_theme_constant_override("separation", 12)
	item_container.modulate.a = 0.0
	item_container.scale = Vector2.ZERO
	content.add_child(item_container)
	
	# Image de l'item
	var item_image := TextureRect.new()
	item_image.custom_minimum_size = Vector2(120, 120)
	item_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var item_tex = load(item_data["image"]) if ResourceLoader.exists(item_data["image"]) else null
	if item_tex:
		item_image.texture = item_tex
	item_container.add_child(item_image)
	
	# Nom de l'item
	var item_name := Label.new()
	item_name.text = item_data["name"]
	item_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_name.add_theme_font_size_override("font_size", 24)
	item_name.add_theme_color_override("font_color", rarity_color)
	item_name.add_theme_color_override("font_outline_color", Color.WHITE)
	item_name.add_theme_constant_override("outline_size", 4)
	item_container.add_child(item_name)
	
	# Bonus de l'item
	var item_bonus := Label.new()
	item_bonus.text = item_data["bonus"]
	item_bonus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item_bonus.add_theme_font_size_override("font_size", 18)
	item_bonus.add_theme_color_override("font_color", COLOR_NEON_GREEN)
	item_container.add_child(item_bonus)
	
	# Rareté
	var rarity_label := Label.new()
	rarity_label.text = item_data["rarity"].to_upper()
	rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_label.add_theme_font_size_override("font_size", 16)
	rarity_label.add_theme_color_override("font_color", rarity_color)
	item_container.add_child(rarity_label)
	
	# Flash blanc
	var flash := ColorRect.new()
	flash.name = "Flash"
	flash.color = Color(1, 1, 1, 0)
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gacha_overlay.add_child(flash)
	
	# === SÉQUENCE D'ANIMATION ===
	var tween := create_tween()
	
	# 1. Fade in du fond noir (0.2s)
	tween.tween_property(bg, "color:a", 0.7, 0.2)
	
	# 2. Apparition de la capsule avec bounce (0.3s)
	tween.tween_property(capsule, "scale", Vector2(1.2, 1.2), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(capsule, "scale", Vector2(1.0, 1.0), 0.1)
	
	# 3. Secousse de la capsule (0.8s) - rotations rapides
	for i in range(8):
		var angle := 5.0 if i % 2 == 0 else -5.0
		var intensity := 1.0 + (i * 0.15)  # Intensité croissante
		tween.tween_property(capsule, "rotation_degrees", angle * intensity, 0.08).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(capsule, "rotation_degrees", 0.0, 0.05)
	
	# 4. Flash blanc + disparition capsule (0.3s)
	tween.tween_property(flash, "color:a", 0.9, 0.1)
	tween.parallel().tween_property(capsule, "scale", Vector2.ZERO, 0.15).set_ease(Tween.EASE_IN)
	tween.tween_property(flash, "color:a", 0.0, 0.2)
	
	# 5. Révélation de l'item (0.4s)
	tween.tween_property(item_container, "modulate:a", 1.0, 0.1)
	tween.parallel().tween_property(item_container, "scale", Vector2(1.3, 1.3), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(item_container, "scale", Vector2(1.0, 1.0), 0.15)
	
	# 6. Attendre 2 secondes puis fermer automatiquement (ou tap)
	tween.tween_interval(2.0)
	tween.tween_callback(_close_gacha_animation)
	
	# Permettre de fermer en tapant
	bg.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			_close_gacha_animation()
	)


func _close_gacha_animation() -> void:
	if not gacha_overlay or not is_instance_valid(gacha_overlay):
		return
	
	var tween := create_tween()
	tween.tween_property(gacha_overlay, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		if gacha_overlay and is_instance_valid(gacha_overlay):
			gacha_overlay.queue_free()
			gacha_overlay = null
		_show_feedback("Item ajouté à l'inventaire!", true)
	)


func _populate_packs() -> void:
	# Nettoyer
	for child in packs_grid.get_children():
		child.queue_free()
	
	# Calculer taille des cartes - largeur disponible divisée par 2 (grille 2x2)
	var available_width := viewport_size.x - (MARGIN_HORIZONTAL * 2)
	var card_width := (available_width - ITEM_SPACING) / 2.0
	# Limiter la hauteur à un pourcentage de l'écran pour garder les proportions
	var max_height := viewport_size.y * 0.25
	
	for pack_data in COIN_PACKS:
		var card := _create_pack_card(pack_data, card_width, max_height)
		packs_grid.add_child(card)


func _create_pack_card(pack_data: Dictionary, card_width: float, max_height: float) -> Control:
	# Panel de la carte avec largeur fixe et hauteur limitée
	var card := PanelContainer.new()
	var card_height := minf(card_width * 1.2, max_height)  # Ratio 1:1.2 mais limité
	card.custom_minimum_size = Vector2(card_width, card_height)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = COLOR_PANEL_BG
	card_style.corner_radius_top_left = 14
	card_style.corner_radius_top_right = 14
	card_style.corner_radius_bottom_left = 14
	card_style.corner_radius_bottom_right = 14
	card_style.border_width_left = 2
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.border_color = pack_data.get("color", COLOR_NEON_CYAN)
	card_style.content_margin_left = 10
	card_style.content_margin_right = 10
	card_style.content_margin_top = 10
	card_style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", card_style)
	
	# VBox contenu
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	
	# Image du coffre
	var image_container := CenterContainer.new()
	image_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(image_container)
	
	var image := TextureRect.new()
	image.custom_minimum_size = Vector2(card_width * 0.6, card_width * 0.5)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var tex = load(pack_data["image"])
	if tex:
		image.texture = tex
	image_container.add_child(image)
	
	# Nom du pack
	var name_label := Label.new()
	name_label.text = pack_data["name"]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", PACK_NAME_SIZE)
	name_label.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	vbox.add_child(name_label)
	
	# Coins
	var coins_label := Label.new()
	coins_label.text = str(pack_data["coins"]) + " SC"
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coins_label.add_theme_font_size_override("font_size", PACK_PRICE_SIZE)
	coins_label.add_theme_color_override("font_color", COLOR_NEON_GOLD)
	vbox.add_child(coins_label)
	
	# Bouton d'achat
	var buy_btn := Button.new()
	buy_btn.text = pack_data["price"]
	buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_btn.custom_minimum_size.y = 36
	_style_button_neon(buy_btn, COLOR_NEON_GREEN)
	buy_btn.pressed.connect(_on_pack_purchase.bind(pack_data))
	vbox.add_child(buy_btn)
	
	return card


# =============================================================================
# SECTION ÉQUIPEMENTS - Liste verticale avec toutes les catégories
# =============================================================================

func _create_equipment_section(parent: Control) -> void:
	# Container section
	var section := VBoxContainer.new()
	section.name = "EquipmentSection"
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 12)
	parent.add_child(section)
	
	# Titre section principal
	var title := Label.new()
	title.name = "EquipmentTitle"
	title.text = "ÉQUIPEMENTS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", SECTION_TITLE_SIZE)
	title.add_theme_color_override("font_color", COLOR_NEON_CYAN)
	title.add_theme_color_override("font_outline_color", Color(0.0, 0.4, 0.6, 0.6))
	title.add_theme_constant_override("outline_size", 2)
	section.add_child(title)
	
	# VBox principal pour toutes les catégories
	equipment_container = VBoxContainer.new()
	equipment_container.name = "EquipmentList"
	equipment_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equipment_container.add_theme_constant_override("separation", SECTION_SPACING)
	section.add_child(equipment_container)


func _populate_equipment() -> void:
	# Nettoyer
	for child in equipment_container.get_children():
		child.queue_free()
	
	# Calculer taille des cartes - largeur disponible divisée par 3 (grille 3xN)
	var available_width := viewport_size.x - (MARGIN_HORIZONTAL * 2)
	var card_width := (available_width - (ITEM_SPACING * 2)) / 3.0
	# Limiter la hauteur à un pourcentage de l'écran
	var max_height := viewport_size.y * 0.22
	
	# Parcourir toutes les catégories et afficher chaque section
	for category_key in ["weapon", "armor", "helmet"]:
		var category_data = EQUIPMENT_DATA[category_key]
		
		# Titre de la catégorie
		var category_title := Label.new()
		category_title.text = category_data["title"]
		category_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		category_title.add_theme_font_size_override("font_size", 22)
		category_title.add_theme_color_override("font_color", COLOR_NEON_PURPLE)
		category_title.add_theme_color_override("font_outline_color", Color(0.4, 0.2, 0.5, 0.6))
		category_title.add_theme_constant_override("outline_size", 2)
		equipment_container.add_child(category_title)
		
		# Grille 3xN pour cette catégorie
		var category_grid := GridContainer.new()
		category_grid.columns = 3
		category_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		category_grid.add_theme_constant_override("h_separation", ITEM_SPACING)
		category_grid.add_theme_constant_override("v_separation", ITEM_SPACING)
		equipment_container.add_child(category_grid)
		
		# Ajouter les items de cette catégorie
		for item_data in category_data["items"]:
			var card := _create_equipment_card(item_data, card_width, max_height)
			category_grid.add_child(card)


func _create_equipment_card(item_data: Dictionary, card_width: float, max_height: float) -> Control:
	# Panel carte avec largeur fixe et hauteur limitée
	var card := PanelContainer.new()
	var card_height := minf(card_width * 1.3, max_height)  # Ratio 1:1.3 mais limité
	card.custom_minimum_size = Vector2(card_width, card_height)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
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
	card_style.border_color = COLOR_NEON_PURPLE
	card_style.content_margin_left = 6
	card_style.content_margin_right = 6
	card_style.content_margin_top = 8
	card_style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", card_style)
	
	# VBox contenu
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	
	# Image équipement (carrée, upscalée)
	var image_container := CenterContainer.new()
	image_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(image_container)
	
	var image := TextureRect.new()
	var img_size := card_width * 0.7
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
	bonus_label.add_theme_font_size_override("font_size", 12)
	bonus_label.add_theme_color_override("font_color", COLOR_NEON_GREEN)
	vbox.add_child(bonus_label)
	
	# Prix + Bouton
	var price_btn := Button.new()
	price_btn.text = str(item_data["cost"]) + " SC"
	price_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	price_btn.custom_minimum_size.y = 32
	price_btn.add_theme_font_size_override("font_size", ITEM_PRICE_SIZE)
	_style_button_neon(price_btn, COLOR_NEON_GOLD)
	price_btn.pressed.connect(_on_equipment_purchase.bind(item_data))
	vbox.add_child(price_btn)
	
	return card


# =============================================================================
# UTILITAIRES DE STYLE
# =============================================================================

func _style_button_neon(btn: Button, color: Color, filled: bool = false) -> void:
	var style := StyleBoxFlat.new()
	
	if filled:
		style.bg_color = Color(color.r * 0.3, color.g * 0.3, color.b * 0.3, 0.9)
	else:
		style.bg_color = Color(0.05, 0.05, 0.12, 0.85)
	
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = color
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	
	btn.add_theme_stylebox_override("normal", style)
	
	# Hover
	var hover_style := style.duplicate()
	hover_style.bg_color = Color(color.r * 0.4, color.g * 0.4, color.b * 0.4, 0.95)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	# Pressed
	var pressed_style := style.duplicate()
	pressed_style.bg_color = Color(color.r * 0.5, color.g * 0.5, color.b * 0.5, 1.0)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
	btn.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	btn.add_theme_color_override("font_hover_color", COLOR_WHITE_GLOW)
	btn.add_theme_color_override("font_pressed_color", COLOR_WHITE_GLOW)


# =============================================================================
# SIGNAUX & INTERACTIONS
# =============================================================================

func _connect_signals() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	if SaveManager:
		if SaveManager.has_signal("currency_changed"):
			SaveManager.currency_changed.connect(_on_currency_changed)


func _on_back_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)
	)


func _on_pack_purchase(pack_data: Dictionary) -> void:
	print("[ShopMenu] Achat pack: ", pack_data["id"], " - ", pack_data["price"])
	# Simuler l'achat de coins (pas de vrai paiement pour l'instant)
	if SaveManager:
		var coins_to_add: int = pack_data["coins"]
		SaveManager.add_currency(coins_to_add)
		_update_currency_display()
		_show_feedback("+" + str(coins_to_add) + " SC!", true)
	else:
		_show_feedback("Achat non disponible", false)


func _on_equipment_purchase(item_data: Dictionary) -> void:
	var cost: int = item_data["cost"]
	var internal_id: String = EQUIPMENT_ID_MAP.get(item_data["id"], item_data["id"])
	
	if SaveManager:
		# Vérifier si déjà possédé
		if SaveManager.owns_equipment(internal_id):
			_show_feedback("Deja possede!", false)
			return
		
		var current_coins: int = SaveManager.get_currency()
		if current_coins >= cost:
			SaveManager.spend_currency(cost)
			SaveManager.add_equipment(internal_id)
			_show_feedback(item_data["name"] + " achete!", true)
			_update_currency_display()
		else:
			_show_feedback("Pas assez de SC!", false)
	else:
		print("[ShopMenu] SaveManager non disponible")


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


func _update_currency_display() -> void:
	if currency_label and SaveManager:
		var coins: int = SaveManager.get_currency()
		currency_label.text = str(coins) + " SC"


func _on_currency_changed(_new_amount: int) -> void:
	_update_currency_display()


# =============================================================================
# ANIMATIONS
# =============================================================================

func _animate_entrance() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
