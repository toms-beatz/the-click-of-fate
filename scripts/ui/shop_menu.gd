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

# =============================================================================
# VARIABLES
# =============================================================================

var viewport_size: Vector2
var back_button: Button
var currency_label: Label
var packs_grid: GridContainer
var equipment_tabs_container: HBoxContainer
var equipment_grid: GridContainer
var current_tab: String = "weapon"
var tab_buttons: Dictionary = {}
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
# SECTION ÉQUIPEMENTS - Tabs + Grille 3xN
# =============================================================================

func _create_equipment_section(parent: Control) -> void:
	# Container section
	var section := VBoxContainer.new()
	section.name = "EquipmentSection"
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 12)
	parent.add_child(section)
	
	# Titre section
	var title := Label.new()
	title.name = "EquipmentTitle"
	title.text = "ÉQUIPEMENTS"
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
	
	equipment_tabs_container = HBoxContainer.new()
	equipment_tabs_container.name = "EquipmentTabs"
	equipment_tabs_container.add_theme_constant_override("separation", 8)
	tabs_center.add_child(equipment_tabs_container)
	
	# Créer les onglets
	for tab_key in EQUIPMENT_DATA.keys():
		var tab_data = EQUIPMENT_DATA[tab_key]
		var tab_btn := Button.new()
		tab_btn.name = "Tab_" + tab_key
		tab_btn.text = tab_data["title"]
		tab_btn.custom_minimum_size = Vector2(100, 45)
		tab_btn.add_theme_font_size_override("font_size", TAB_FONT_SIZE)
		tab_btn.pressed.connect(_on_tab_pressed.bind(tab_key))
		equipment_tabs_container.add_child(tab_btn)
		tab_buttons[tab_key] = tab_btn
	
	_update_tab_styles()
	
	# Container centré pour la grille
	var grid_center := CenterContainer.new()
	grid_center.name = "EquipmentGridCenter"
	grid_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	section.add_child(grid_center)
	
	# Grille 3 colonnes
	equipment_grid = GridContainer.new()
	equipment_grid.name = "EquipmentGrid"
	equipment_grid.columns = 3
	equipment_grid.add_theme_constant_override("h_separation", ITEM_SPACING)
	equipment_grid.add_theme_constant_override("v_separation", ITEM_SPACING)
	grid_center.add_child(equipment_grid)


func _populate_equipment() -> void:
	# Nettoyer
	for child in equipment_grid.get_children():
		child.queue_free()
	
	var tab_data = EQUIPMENT_DATA[current_tab]
	var items = tab_data["items"]
	
	# Calculer taille des cartes - largeur disponible divisée par 3 (grille 3xN)
	var available_width := viewport_size.x - (MARGIN_HORIZONTAL * 2)
	var card_width := (available_width - (ITEM_SPACING * 2)) / 3.0
	# Limiter la hauteur à un pourcentage de l'écran
	var max_height := viewport_size.y * 0.22
	
	for item_data in items:
		var card := _create_equipment_card(item_data, card_width, max_height)
		equipment_grid.add_child(card)


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


func _update_tab_styles() -> void:
	for tab_key in tab_buttons.keys():
		var btn: Button = tab_buttons[tab_key]
		var is_active: bool = (tab_key == current_tab)
		
		if is_active:
			_style_button_neon(btn, COLOR_NEON_CYAN, true)
		else:
			_style_button_neon(btn, COLOR_TAB_INACTIVE, false)


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


func _on_tab_pressed(tab_key: String) -> void:
	if tab_key == current_tab:
		return
	
	current_tab = tab_key
	_update_tab_styles()
	
	# Animation de transition
	var tween := create_tween()
	tween.tween_property(equipment_grid, "modulate:a", 0.0, 0.1)
	tween.tween_callback(_populate_equipment)
	tween.tween_property(equipment_grid, "modulate:a", 1.0, 0.15)


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
	# Créer un label de feedback temporaire
	var feedback := Label.new()
	feedback.text = message
	feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback.add_theme_font_size_override("font_size", 20)
	feedback.add_theme_color_override("font_color", COLOR_SUCCESS if success else COLOR_ERROR)
	feedback.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	feedback.add_theme_constant_override("outline_size", 3)
	
	feedback.set_anchors_preset(Control.PRESET_CENTER)
	feedback.position.y += viewport_size.y * 0.3
	add_child(feedback)
	
	# Animation
	var tween := create_tween()
	tween.tween_property(feedback, "position:y", feedback.position.y - 50, 0.5)
	tween.parallel().tween_property(feedback, "modulate:a", 0.0, 0.5).set_delay(1.0)
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
