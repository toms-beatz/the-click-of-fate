## LevelSelect - Écran de sélection de niveau (Carrousel)
##
## Affiche les 4 planètes en carrousel horizontal:
## - Défilement gauche/droite par swipe ou boutons
## - Planètes verrouillées grisées avec cadenas
## - Puissance recommandée par planète
## - Style Sci-Fi Néon unifié avec le reste du jeu
##
## Progression LINÉAIRE: Mercure → Vénus → Mars → Terre
extends Control


## Émis quand une planète est sélectionnée
signal planet_selected(planet_index: int)

# =============================================================================
# CONSTANTES DE DESIGN - Style unifié Sci-Fi Néon
# =============================================================================

## Couleurs Sci-Fi Néon (identiques à shop_menu)
const COLOR_BLACK_DEEP := Color("#0A0A0F")
const COLOR_BLUE_NIGHT := Color("#0D1B2A")
const COLOR_NEON_CYAN := Color("#00D4FF")
const COLOR_NEON_PINK := Color("#FF3388")
const COLOR_NEON_GREEN := Color("#33FF88")
const COLOR_NEON_GOLD := Color("#FFD933")
const COLOR_NEON_PURPLE := Color("#AA44FF")
const COLOR_NEON_ORANGE := Color("#FF8833")
const COLOR_WHITE_GLOW := Color("#FFFFFF")
const COLOR_PANEL_BG := Color(0.03, 0.03, 0.12, 0.92)

## Tailles de police
const HEADER_FONT_SIZE := 32
const CURRENCY_FONT_SIZE := 20
const POWER_FONT_SIZE := 20
const BUTTON_FONT_SIZE := 20
const NAV_BUTTON_FONT_SIZE := 18

## Références UI
@onready var currency_label: Label = %CurrencyLabel
@onready var power_label: Label = %PowerLabel
@onready var carousel_container: Control = %CarouselContainer
@onready var planet_name_label: Label = %PlanetNameLabel
@onready var planet_desc_label: Label = %PlanetDescLabel
@onready var recommended_power_label: Label = %RecommendedPowerLabel
@onready var play_button: Button = %PlayButton
@onready var difficulty_label: Label = %DifficultyLabel
@onready var home_button: Button = %HomeButton
@onready var shop_button: Button = %ShopButton
@onready var profile_button: Button = %ProfileButton

## Scènes
const MAIN_MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const COMBAT_SCENE := "res://scenes/game_combat_scene.tscn"
const SHOP_SCENE := "res://scenes/ui/shop_menu.tscn"
const PROFILE_SCENE := "res://scenes/ui/profile_menu.tscn"

## Données des planètes
const PLANETS_INFO := [
	{
		"id": "mercury",
		"name": "Mercury",
		"description": "Fast and aggressive enemies",
		"color": Color(0.9, 0.4, 0.1),
		"bg_color": Color(0.3, 0.15, 0.05),
		"difficulty": 1,
		"recommended_power": 100,
		"sprite": "res://assets/sprites/planets/mercury.png"
	},
	{
		"id": "venus",
		"name": "Venus",
		"description": "Toxic and persistent enemies",
		"color": Color(0.9, 0.75, 0.2),
		"bg_color": Color(0.3, 0.25, 0.05),
		"difficulty": 2,
		"recommended_power": 140,
		"sprite": "res://assets/sprites/planets/venus.png"
	},
	{
		"id": "mars",
		"name": "Mars",
		"description": "Regenerating enemies",
		"color": Color(0.85, 0.25, 0.15),
		"bg_color": Color(0.25, 0.08, 0.05),
		"difficulty": 3,
		"recommended_power": 190,
		"sprite": "res://assets/sprites/planets/mars.png"
	},
	{
		"id": "earth",
		"name": "Earth",
		"description": "Final Battle - Dr. Mortis awaits",
		"color": Color(0.2, 0.6, 0.9),
		"bg_color": Color(0.05, 0.15, 0.25),
		"difficulty": 4,
		"recommended_power": 270,
		"sprite": "res://assets/sprites/planets/earth.png"
	},
	{
		"id": "coming_soon",
		"name": "Coming Soon...",
		"description": "New adventures await!",
		"color": Color(0.15, 0.15, 0.15),
		"bg_color": Color(0.05, 0.05, 0.05),
		"difficulty": 0,
		"recommended_power": 0,
		"sprite": "res://assets/sprites/planets/planet-coming-soon.png",
		"is_coming_soon": true
	}
]

## Index de la planète actuellement affichée au centre
var current_index: int = 0

## Nodes des planètes dans le carrousel
var planet_nodes: Array[Control] = []

## Position X du début du swipe
var swipe_start_x: float = 0.0

## Est-ce qu'on est en train de swiper?
var is_swiping: bool = false

## Seuil de swipe pour changer de planète
const SWIPE_THRESHOLD := 80.0

## Pourcentage de la largeur d'écran pour la planète centrale
const PLANET_SIZE_PERCENT := 0.70  # 70% de la largeur

## Taille de la planète centrale (calculée dynamiquement)
var planet_size_center: float = 160.0

## Taille des planètes sur les côtés (calculée dynamiquement)
var planet_size_side: float = 100.0

## Espacement entre les planètes (calculé dynamiquement)
var planet_spacing: float = 200.0

## Vaisseaux d'arrière-plan
const SPACESHIP_SPRITES := [
	"res://assets/sprites/enemies/vaisseau-1.png",
	"res://assets/sprites/enemies/vaisseau-2.png",
	"res://assets/sprites/enemies/vaisseau-3.png",
	"res://assets/sprites/enemies/vaisseau-4.png",
	"res://assets/sprites/enemies/vaisseau-5.png",
	"res://assets/sprites/enemies/vaisseau-6.png"
]

## Container pour les vaisseaux (arrière-plan)
var spaceships_container: Control
var active_spaceships: Array[TextureRect] = []
const MAX_SPACESHIPS := 8
const SPACESHIP_SPAWN_INTERVAL := 2.0
var spaceship_timer: float = 0.0


func _ready() -> void:
	_connect_signals()
	_style_all_buttons()
	_update_displays()
	_create_background()
	# Attendre que le carousel_container ait sa taille
	await get_tree().process_frame
	_calculate_planet_sizes()
	_create_spaceships_background()
	_create_planet_carousel()
	_animate_entrance()


func _exit_tree() -> void:
	# Nettoyer le CanvasLayer du background
	if background_layer and is_instance_valid(background_layer):
		background_layer.queue_free()


## Calcule les tailles des planètes en fonction de l'écran
func _calculate_planet_sizes() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	planet_size_center = viewport_size.x * PLANET_SIZE_PERCENT
	planet_size_side = planet_size_center * 0.5  # Planètes sur les côtés = 50% de la centrale
	planet_spacing = planet_size_center * 0.8  # Espacement proportionnel


func _connect_signals() -> void:
	play_button.pressed.connect(_on_play_pressed)
	home_button.pressed.connect(_on_home_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	profile_button.pressed.connect(_on_profile_pressed)
	
	if SaveManager:
		SaveManager.currency_changed.connect(_on_currency_changed)


# =============================================================================
# STYLING DES BOUTONS - Style Néon unifié
# =============================================================================

## Applique le style néon à tous les boutons
func _style_all_buttons() -> void:
	# Bouton PLAY principal
	_style_button_neon(play_button, COLOR_NEON_GREEN, true)
	play_button.text = "PLAY"
	
	# Boutons de navigation bas (sans émojis)
	_style_button_neon(home_button, COLOR_NEON_CYAN)
	home_button.text = "HOME"
	
	_style_button_neon(shop_button, COLOR_NEON_GOLD)
	shop_button.text = "SHOP"
	
	_style_button_neon(profile_button, COLOR_NEON_PURPLE)
	profile_button.text = "PROFIL"


## Applique un style néon à un bouton
func _style_button_neon(btn: Button, color: Color, filled: bool = false) -> void:
	var style := StyleBoxFlat.new()
	
	if filled:
		style.bg_color = Color(color.r * 0.3, color.g * 0.3, color.b * 0.3, 0.9)
	else:
		style.bg_color = Color(0.05, 0.05, 0.12, 0.85)
	
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = color
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	
	btn.add_theme_stylebox_override("normal", style)
	
	# Hover
	var hover_style := style.duplicate()
	hover_style.bg_color = Color(color.r * 0.4, color.g * 0.4, color.b * 0.4, 0.95)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	# Pressed
	var pressed_style := style.duplicate()
	pressed_style.bg_color = Color(color.r * 0.5, color.g * 0.5, color.b * 0.5, 1.0)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
	# Disabled
	var disabled_style := style.duplicate()
	disabled_style.bg_color = Color(0.1, 0.1, 0.1, 0.5)
	disabled_style.border_color = Color(0.3, 0.3, 0.3, 0.5)
	btn.add_theme_stylebox_override("disabled", disabled_style)
	
	# Couleurs de texte - toujours blanc
	btn.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
	btn.add_theme_color_override("font_hover_color", COLOR_WHITE_GLOW)
	btn.add_theme_color_override("font_pressed_color", COLOR_WHITE_GLOW)
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5))


## Style les panels de stats (puissance et coins)
func _style_stats_panels() -> void:
	# Style le label de puissance
	if power_label:
		var power_panel = power_label.get_parent()
		if power_panel is PanelContainer:
			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.05, 0.05, 0.15, 0.9)
			style.corner_radius_top_left = 10
			style.corner_radius_top_right = 10
			style.corner_radius_bottom_left = 10
			style.corner_radius_bottom_right = 10
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.border_color = COLOR_NEON_ORANGE
			style.content_margin_left = 12
			style.content_margin_right = 12
			style.content_margin_top = 6
			style.content_margin_bottom = 6
			power_panel.add_theme_stylebox_override("panel", style)
		
		power_label.add_theme_font_size_override("font_size", POWER_FONT_SIZE)
		power_label.add_theme_color_override("font_color", COLOR_NEON_ORANGE)
	
	# Style le label de monnaie
	if currency_label:
		var currency_panel = currency_label.get_parent()
		if currency_panel is PanelContainer:
			var style := StyleBoxFlat.new()
			style.bg_color = Color(0.05, 0.05, 0.15, 0.9)
			style.corner_radius_top_left = 10
			style.corner_radius_top_right = 10
			style.corner_radius_bottom_left = 10
			style.corner_radius_bottom_right = 10
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_width_top = 2
			style.border_width_bottom = 2
			style.border_color = COLOR_NEON_GOLD
			style.content_margin_left = 12
			style.content_margin_right = 12
			style.content_margin_top = 6
			style.content_margin_bottom = 6
			currency_panel.add_theme_stylebox_override("panel", style)
		
		currency_label.add_theme_font_size_override("font_size", CURRENCY_FONT_SIZE)
		currency_label.add_theme_color_override("font_color", COLOR_NEON_GOLD)


## Crée et ajoute le background avec opacité - Layer séparé pour éviter les problèmes d'animation
var background_layer: CanvasLayer
var background_rect: TextureRect

const BACKGROUND_PATH := "res://assets/backgrounds/background-menu-selection.png"

func _create_background() -> void:
	# Utilise le TextureRect existant dans la scène
	var bg_node = get_node_or_null("BackgroundImage")
	if not bg_node:
		push_warning("BackgroundImage node not found in scene!")
		return
	var bg_texture = load(BACKGROUND_PATH)
	if bg_texture:
		bg_node.texture = bg_texture
	else:
		push_warning("Background non trouvé: " + BACKGROUND_PATH)
		return
	bg_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_node.modulate = Color(0.5, 0.5, 0.5, 1)
	bg_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_node.set_anchors_preset(Control.PRESET_FULL_RECT)


func _update_displays() -> void:
	_style_stats_panels()
	_update_currency_display()
	_update_power_display()


func _update_currency_display() -> void:
	if SaveManager and currency_label:
		currency_label.text = "%d SC" % SaveManager.get_currency()


func _update_power_display() -> void:
	if power_label:
		var power := _calculate_player_power()
		power_label.text = "PWR %d" % power


func _on_currency_changed(_new_amount: int) -> void:
	_update_displays()


## Calcule la puissance du joueur basée sur progression + upgrades + équipements
func _calculate_player_power() -> int:
	if not SaveManager:
		return 100  # Valeur de base
	
	var power := 100  # Base de 100
	
	# Bonus de progression par planète complétée
	var highest_completed: int = SaveManager.get_highest_planet_completed()
	var progression_bonus := {
		-1: 0,    # Aucune planète terminée
		0: 50,    # Mercury terminée
		1: 100,   # Venus terminée
		2: 180,   # Mars terminée
		3: 300,   # Earth terminée (max)
	}
	power += progression_bonus.get(highest_completed, 0)
	
	# Bonus des upgrades (même formule que profile_menu)
	var upgrades_config := {
		"max_hp": {"per_level": 15},
		"attack_power": {"per_level": 2},
		"dodge_chance": {"per_level": 2},
		"heal_power": {"per_level": 2}
	}
	for upgrade_id in upgrades_config:
		var level := SaveManager.get_upgrade_level(upgrade_id)
		power += level * int(upgrades_config[upgrade_id]["per_level"] * 0.8)
	
	# Bonus des équipements
	var equipment_data := {
		# Shop equipment
		"sword_basic": {"attack_power": 5},
		"sword_flame": {"attack_power": 12},
		"sword_cosmic": {"attack_power": 25},
		"armor_light": {"dodge_chance": 5},
		"armor_shadow": {"dodge_chance": 10},
		"armor_cosmic": {"dodge_chance": 18},
		"helmet_basic": {"heal_power": 3},
		"helmet_nature": {"heal_power": 8},
		"helmet_cosmic": {"heal_power": 15},
		# Gacha Common weapons
		"sword_iron": {"attack_power": 3},
		"sword_steel": {"attack_power": 4},
		"sword_bronze": {"attack_power": 5},
		# Gacha Rare weapons
		"sword_crystal": {"attack_power": 8},
		"sword_thunder": {"attack_power": 10},
		"sword_frost": {"attack_power": 12},
		# Gacha Legendary weapons
		"sword_dragon": {"attack_power": 18},
		"sword_void": {"attack_power": 22},
		"sword_divine": {"attack_power": 28},
		# Gacha Common armors
		"armor_leather": {"dodge_chance": 3},
		"armor_chainmail": {"dodge_chance": 4},
		"armor_iron": {"dodge_chance": 5},
		# Gacha Rare armors
		"armor_crystal": {"dodge_chance": 8},
		"armor_thunder": {"dodge_chance": 10},
		"armor_frost": {"dodge_chance": 12},
		# Gacha Legendary armors
		"armor_dragon": {"dodge_chance": 16},
		"armor_void": {"dodge_chance": 20},
		"armor_divine": {"dodge_chance": 25},
		# Gacha Common helmets
		"helmet_leather": {"heal_power": 2},
		"helmet_iron": {"heal_power": 3},
		"helmet_steel": {"heal_power": 4},
		# Gacha Rare helmets
		"helmet_crystal": {"heal_power": 6},
		"helmet_thunder": {"heal_power": 8},
		"helmet_frost": {"heal_power": 10},
		# Gacha Legendary helmets
		"helmet_dragon": {"heal_power": 14},
		"helmet_void": {"heal_power": 18},
		"helmet_divine": {"heal_power": 22},
	}
	for slot in ["weapon", "armor", "helmet"]:
		var equipped := SaveManager.get_equipped(slot)
		if equipped != "" and equipment_data.has(equipped):
			for stat in equipment_data[equipped]:
				power += equipment_data[equipped][stat]
	
	return power


func _create_planet_carousel() -> void:
	# Nettoyer les anciens nodes
	for child in carousel_container.get_children():
		child.queue_free()
	planet_nodes.clear()
	
	# Récupérer progression
	var highest_completed: int = -1
	if SaveManager:
		highest_completed = SaveManager.get_highest_planet_completed()
		current_index = clampi(SaveManager.get_current_planet(), 0, PLANETS_INFO.size() - 1)
	
	# Créer les planètes
	for i in range(PLANETS_INFO.size()):
		var planet_node := _create_planet_node(i, highest_completed)
		carousel_container.add_child(planet_node)
		planet_nodes.append(planet_node)
	
	# Positionner les planètes
	_update_carousel_positions(false)
	_update_planet_info_display()


func _create_planet_node(index: int, highest_completed: int) -> Control:
	var info: Dictionary = PLANETS_INFO[index]
	var is_coming_soon: bool = info.get("is_coming_soon", false)
	var is_unlocked: bool = not is_coming_soon and index <= highest_completed + 1
	
	# Container principal
	var container := Control.new()
	container.name = "Planet_%d" % index
	container.custom_minimum_size = Vector2(planet_size_center, planet_size_center)
	container.size = Vector2(planet_size_center, planet_size_center)
	
	# Animation de flottement
	_animate_planet_float(container, randf_range(0.0, 2.0))
	
	# Anneau extérieur (glow) - pas nécessaire avec les vrais sprites
	var ring := Control.new()
	ring.name = "Ring"
	ring.custom_minimum_size = Vector2(planet_size_center + 30, planet_size_center + 30)
	ring.size = Vector2(planet_size_center + 30, planet_size_center + 30)
	ring.position = Vector2(-15, -15)
	ring.visible = false  # Cacher l'anneau quand on a un sprite
	container.add_child(ring)
	
	var ring_bg := ColorRect.new()
	ring_bg.color = info["color"].lightened(0.2) if is_unlocked else Color(0.25, 0.25, 0.25)
	ring_bg.modulate.a = 0.4
	ring_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	ring.add_child(ring_bg)
	
	# Image de la planète (TextureRect) ou ColorRect fallback
	var sprite_path := info.get("sprite", "") as String
	if ResourceLoader.exists(sprite_path):
		var planet_sprite := TextureRect.new()
		planet_sprite.name = "PlanetVisual"
		planet_sprite.texture = load(sprite_path)
		planet_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		planet_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		planet_sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		if not is_unlocked and not is_coming_soon:
			planet_sprite.modulate = Color(0.4, 0.4, 0.4)  # Grisé
		
		container.add_child(planet_sprite)
	else:
		# Fallback: ColorRect si pas de sprite (montrer l'anneau)
		ring.visible = true
		var planet_visual := ColorRect.new()
		planet_visual.name = "PlanetVisual"
		planet_visual.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		if is_unlocked:
			planet_visual.color = info["color"]
		else:
			planet_visual.color = Color(0.35, 0.35, 0.35)
		
		container.add_child(planet_visual)
	
	# Cadenas + planète assombrie si verrouillée (pas pour Coming Soon)
	if not is_unlocked and not is_coming_soon:
		# Ajoute un cadenas centré (icône texte)
		var lock_container := Control.new()
		lock_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		container.add_child(lock_container)
		var lock_label := Label.new()
		lock_label.name = "Lock"
		lock_label.text = "LOCKED"
		lock_label.add_theme_font_size_override("font_size", int(planet_size_center * 0.12))
		lock_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))
		lock_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		lock_label.add_theme_constant_override("outline_size", 3)
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		lock_container.add_child(lock_label)
	
	# Stocker les métadonnées
	container.set_meta("planet_index", index)
	container.set_meta("is_unlocked", is_unlocked)
	container.set_meta("is_coming_soon", is_coming_soon)
	
	return container


func _update_carousel_positions(animate: bool = true) -> void:
	if carousel_container == null or planet_nodes.is_empty():
		return
	
	var center_x := carousel_container.size.x / 2
	var center_y := carousel_container.size.y / 2
	
	for i in range(planet_nodes.size()):
		var node: Control = planet_nodes[i]
		var offset := i - current_index
		
		# Position cible (centré sur la planète)
		var target_x := center_x + (offset * planet_spacing) - planet_size_center / 2
		var target_y := center_y - planet_size_center / 2
		
		# Scale selon la distance du centre
		var distance := absf(offset)
		var target_scale := 1.0 if distance == 0 else maxf(0.4, 1.0 - distance * 0.4)
		
		# Opacité selon la distance
		var target_alpha := 1.0 if distance == 0 else maxf(0.25, 1.0 - distance * 0.4)
		
		# Z-index (centre devant)
		node.z_index = 10 - int(distance)
		
		if animate:
			var tween := create_tween()
			tween.set_parallel(true)
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(node, "position", Vector2(target_x, target_y), 0.3)
			tween.tween_property(node, "scale", Vector2(target_scale, target_scale), 0.3)
			tween.tween_property(node, "modulate:a", target_alpha, 0.3)
		else:
			node.position = Vector2(target_x, target_y)
			node.scale = Vector2(target_scale, target_scale)
			node.modulate.a = target_alpha


func _update_planet_info_display() -> void:
	var info: Dictionary = PLANETS_INFO[current_index]
	var is_coming_soon: bool = info.get("is_coming_soon", false)
	var is_unlocked: bool = not is_coming_soon and current_index <= _get_highest_completed() + 1
	var is_completed: bool = current_index <= _get_highest_completed()
	var player_power := _calculate_player_power()
	var recommended: int = info["recommended_power"]
	
	# Nom et description
	if planet_name_label:
		planet_name_label.text = info["name"]
		if is_coming_soon:
			planet_name_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
			planet_name_label.add_theme_color_override("font_outline_color", Color(0.2, 0.2, 0.2))
		else:
			planet_name_label.add_theme_color_override("font_color", COLOR_WHITE_GLOW)
			planet_name_label.add_theme_color_override("font_outline_color", info["color"])
		planet_name_label.add_theme_constant_override("outline_size", 3)
	
	if planet_desc_label:
		if is_coming_soon:
			planet_desc_label.text = info["description"]
			planet_desc_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		elif is_unlocked:
			planet_desc_label.text = info["description"]
			planet_desc_label.remove_theme_color_override("font_color")
		else:
			planet_desc_label.text = "Locked Planet"
			planet_desc_label.remove_theme_color_override("font_color")
	
	# Difficulté (cacher pour Coming Soon)
	if difficulty_label:
		if is_coming_soon:
			difficulty_label.text = "???"
			difficulty_label.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3))
		else:
			difficulty_label.text = "★".repeat(info["difficulty"]) + "☆".repeat(4 - info["difficulty"])
			difficulty_label.add_theme_color_override("font_color", COLOR_NEON_GOLD)
	
	# Puissance recommandée avec couleur selon notre niveau
	if recommended_power_label:
		if is_coming_soon:
			recommended_power_label.text = "Stay tuned for updates!"
			recommended_power_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
		elif is_unlocked:
			recommended_power_label.text = "Recommended Power: %d" % recommended
			if player_power >= recommended:
				recommended_power_label.add_theme_color_override("font_color", COLOR_NEON_GREEN)
			elif player_power >= recommended * 0.7:
				recommended_power_label.add_theme_color_override("font_color", COLOR_NEON_GOLD)
			else:
				recommended_power_label.add_theme_color_override("font_color", COLOR_NEON_ORANGE)
		else:
			recommended_power_label.text = "Complete %s to unlock" % PLANETS_INFO[maxi(0, current_index - 1)]["name"]
			recommended_power_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	# Bouton jouer - PLAY ou REPLAY selon si complété (cacher pour Coming Soon)
	if play_button:
		play_button.visible = is_unlocked and not is_coming_soon
		play_button.disabled = not is_unlocked or is_coming_soon
		if is_completed:
			play_button.text = "REPLAY"
			_style_button_neon(play_button, COLOR_NEON_CYAN, true)
		else:
			play_button.text = "PLAY"
			_style_button_neon(play_button, COLOR_NEON_GREEN, true)


func _get_highest_completed() -> int:
	if SaveManager:
		return SaveManager.get_highest_planet_completed()
	return -1


func _on_play_pressed() -> void:
	var is_unlocked: bool = current_index <= _get_highest_completed() + 1
	if not is_unlocked:
		return
	
	_animate_button(play_button)
	
	if SaveManager:
		SaveManager.set_current_planet(current_index)
	
	await get_tree().create_timer(0.2).timeout
	planet_selected.emit(current_index)
	
	# Charger la scène de combat
	get_tree().change_scene_to_file(COMBAT_SCENE)


func _on_home_pressed() -> void:
	_animate_button(home_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _on_shop_pressed() -> void:
	_animate_button(shop_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(SHOP_SCENE)


func _on_profile_pressed() -> void:
	_animate_button(profile_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(PROFILE_SCENE)


## Gestion du swipe tactile
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			swipe_start_x = touch_event.position.x
			is_swiping = true
		else:
			if is_swiping:
				var swipe_distance: float = touch_event.position.x - swipe_start_x
				if absf(swipe_distance) > SWIPE_THRESHOLD:
					if swipe_distance > 0 and current_index > 0:
						current_index -= 1
						_update_carousel_positions(true)
						_update_planet_info_display()
					elif swipe_distance < 0 and current_index < PLANETS_INFO.size() - 1:
						current_index += 1
						_update_carousel_positions(true)
						_update_planet_info_display()
			is_swiping = false
	
	# Support souris pour debug PC
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				swipe_start_x = mouse_event.position.x
				is_swiping = true
			else:
				if is_swiping:
					var swipe_distance: float = mouse_event.position.x - swipe_start_x
					if absf(swipe_distance) > SWIPE_THRESHOLD:
						if swipe_distance > 0 and current_index > 0:
							current_index -= 1
							_update_carousel_positions(true)
							_update_planet_info_display()
						elif swipe_distance < 0 and current_index < PLANETS_INFO.size() - 1:
							current_index += 1
							_update_carousel_positions(true)
							_update_planet_info_display()
				is_swiping = false


func _animate_button(button: Button) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.08)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.08)


func _animate_entrance() -> void:
	# Animer seulement les éléments UI, pas le background
	# On anime le carousel et les boutons directement
	if carousel_container:
		carousel_container.modulate.a = 0.0
		var carousel_tween := create_tween()
		carousel_tween.tween_property(carousel_container, "modulate:a", 1.0, 0.3)
	
	# Animer les planètes avec un effet "pop"
	for i in range(planet_nodes.size()):
		var node: Control = planet_nodes[i]
		var original_scale := node.scale
		node.scale = Vector2.ZERO
		
		var pop_tween := create_tween()
		pop_tween.tween_property(node, "scale", original_scale * 1.1, 0.3).set_delay(0.08 * i).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		pop_tween.tween_property(node, "scale", original_scale, 0.12)


# ==================== SPACESHIPS BACKGROUND ====================

func _create_spaceships_background() -> void:
	# Utilise le node existant dans la scène
	spaceships_container = get_node_or_null("SpaceshipsBackground")
	if not spaceships_container:
		push_warning("SpaceshipsBackground node not found in scene!")
		return
	# Spawner quelques vaisseaux initiaux
	for i in range(4):
		_spawn_spaceship(true)


func _process(delta: float) -> void:
	# Spawner des vaisseaux périodiquement
	spaceship_timer += delta
	if spaceship_timer >= SPACESHIP_SPAWN_INTERVAL:
		spaceship_timer = 0.0
		if active_spaceships.size() < MAX_SPACESHIPS:
			_spawn_spaceship(false)
	
	# Nettoyer les vaisseaux hors écran
	_cleanup_spaceships()


func _spawn_spaceship(random_position: bool) -> void:
	# Vérifier qu'on a des sprites
	var valid_sprites: Array[String] = []
	for sprite_path in SPACESHIP_SPRITES:
		if ResourceLoader.exists(sprite_path):
			valid_sprites.append(sprite_path)
	
	if valid_sprites.is_empty():
		return
	
	# Choisir un sprite aléatoire
	var sprite_path: String = valid_sprites[randi() % valid_sprites.size()]
	
	var spaceship := TextureRect.new()
	spaceship.texture = load(sprite_path)
	spaceship.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	spaceship.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	spaceship.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Taille aléatoire (petits vaisseaux)
	var base_size: float = randf_range(30.0, 60.0)
	spaceship.custom_minimum_size = Vector2(base_size, base_size)
	spaceship.size = Vector2(base_size, base_size)
	
	# Opacité réduite pour l'effet de fond
	spaceship.modulate.a = randf_range(0.3, 0.6)
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	# Position de départ
	if random_position:
		# Position aléatoire sur l'écran
		spaceship.position = Vector2(
			randf_range(0, viewport_size.x),
			randf_range(0, viewport_size.y)
		)
	else:
		# Spawn sur le bord gauche ou droit
		var from_left: bool = randf() > 0.5
		spaceship.position = Vector2(
			-base_size if from_left else viewport_size.x + base_size,
			randf_range(50, viewport_size.y - 150)  # Éviter le header et footer
		)
	
	spaceships_container.add_child(spaceship)
	active_spaceships.append(spaceship)
	
	# Animation de déplacement
	var direction: float = 1.0 if spaceship.position.x < viewport_size.x / 2 else -1.0
	var travel_distance: float = viewport_size.x + base_size * 2
	var speed: float = randf_range(30.0, 80.0)
	var duration: float = travel_distance / speed
	
	# Légère oscillation verticale
	var end_y: float = spaceship.position.y + randf_range(-100, 100)
	end_y = clampf(end_y, 50, viewport_size.y - 150)
	
	var target_x: float = spaceship.position.x + (travel_distance * direction)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(spaceship, "position:x", target_x, duration)
	tween.tween_property(spaceship, "position:y", end_y, duration).set_trans(Tween.TRANS_SINE)
	
	# Légère rotation
	var rotation_amount: float = randf_range(-0.1, 0.1)
	tween.tween_property(spaceship, "rotation", rotation_amount, duration / 2)


func _cleanup_spaceships() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var to_remove: Array[TextureRect] = []
	
	for spaceship in active_spaceships:
		if not is_instance_valid(spaceship):
			to_remove.append(spaceship)
			continue
		
		# Vérifier si hors écran
		if spaceship.position.x < -100 or spaceship.position.x > viewport_size.x + 100:
			to_remove.append(spaceship)
	
	for spaceship in to_remove:
		active_spaceships.erase(spaceship)
		if is_instance_valid(spaceship):
			spaceship.queue_free()


# =============================================================================
# ANIMATIONS DES PLANÈTES - EFFET SPATIAL
# =============================================================================

## Animation de flottement pour les planètes
func _animate_planet_float(planet: Control, delay: float) -> void:
	var tween := create_tween()
	tween.set_loops()
	
	# Délai initial pour désynchroniser
	if delay > 0:
		tween.tween_interval(delay)
	
	# Mouvement vertical doux
	var float_distance := randf_range(8.0, 15.0)
	var float_duration := randf_range(3.0, 5.0)
	var original_y := planet.position.y
	
	tween.tween_property(planet, "position:y", original_y + float_distance, float_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(planet, "position:y", original_y, float_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	# Rotation très légère
	var rotate_tween := create_tween()
	rotate_tween.set_loops()
	if delay > 0:
		rotate_tween.tween_interval(delay * 0.6)
	var rotate_angle := randf_range(-2.0, 2.0)
	var rotate_duration := randf_range(6.0, 9.0)
	rotate_tween.tween_property(planet, "rotation_degrees", rotate_angle, rotate_duration).set_ease(Tween.EASE_IN_OUT)
	rotate_tween.tween_property(planet, "rotation_degrees", -rotate_angle, rotate_duration).set_ease(Tween.EASE_IN_OUT)
	rotate_tween.tween_property(planet, "rotation_degrees", 0, rotate_duration).set_ease(Tween.EASE_IN_OUT)
