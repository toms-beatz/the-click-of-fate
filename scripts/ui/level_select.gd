## LevelSelect - Écran de sélection de niveau (Carrousel)
##
## Affiche les 4 planètes en carrousel horizontal:
## - Défilement gauche/droite par swipe ou boutons
## - Planètes verrouillées grisées avec cadenas
## - Puissance recommandée par planète
##
## Progression LINÉAIRE: Mercure → Vénus → Mars → Terre
extends Control


## Émis quand une planète est sélectionnée
signal planet_selected(planet_index: int)

## Références UI
@onready var currency_label: Label = %CurrencyLabel
@onready var power_label: Label = %PowerLabel
@onready var carousel_container: Control = %CarouselContainer
@onready var left_arrow: Button = %LeftArrow
@onready var right_arrow: Button = %RightArrow
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
	_update_displays()
	_create_background()
	# Attendre que le carousel_container ait sa taille
	await get_tree().process_frame
	_calculate_planet_sizes()
	_create_spaceships_background()
	_create_planet_carousel()
	_animate_entrance()


## Calcule les tailles des planètes en fonction de l'écran
func _calculate_planet_sizes() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	planet_size_center = viewport_size.x * PLANET_SIZE_PERCENT
	planet_size_side = planet_size_center * 0.5  # Planètes sur les côtés = 50% de la centrale
	planet_spacing = planet_size_center * 0.8  # Espacement proportionnel


func _connect_signals() -> void:
	left_arrow.pressed.connect(_on_left_pressed)
	right_arrow.pressed.connect(_on_right_pressed)
	play_button.pressed.connect(_on_play_pressed)
	home_button.pressed.connect(_on_home_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	profile_button.pressed.connect(_on_profile_pressed)
	
	if SaveManager:
		SaveManager.currency_changed.connect(_on_currency_changed)


## Crée et ajoute le background avec opacité
var background_rect: TextureRect  # Référence pour l'animation

func _create_background() -> void:
	var bg_texture = load("res://assets/sprites/background/background-menu-selection.png")
	if bg_texture:
		background_rect = TextureRect.new()
		background_rect.name = "BackgroundImage"
		background_rect.texture = bg_texture
		background_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		background_rect.stretch_mode = TextureRect.STRETCH_SCALE
		background_rect.modulate = Color(1.0, 1.0, 1.0, 0.5)  # 50% d'opacité
		background_rect.z_index = -20  # Encore plus derrière que les vaisseaux (-10)
		background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(background_rect)
		move_child(background_rect, 0)  # Déplace en premier enfant (fond)


func _update_displays() -> void:
	_update_currency_display()
	_update_power_display()


func _update_currency_display() -> void:
	if SaveManager and currency_label:
		currency_label.text = "%d SC" % SaveManager.get_currency()


func _update_power_display() -> void:
	if power_label:
		var power := _calculate_player_power()
		power_label.text = "⚔ %d" % power


func _on_currency_changed(_new_amount: int) -> void:
	_update_displays()


## Calcule la puissance du joueur basée sur la progression (comme dans le combat)
func _calculate_player_power() -> int:
	if not SaveManager:
		return 100  # Valeur de base
	
	# Utiliser le même système que le combat
	var highest_completed: int = SaveManager.get_highest_planet_completed()
	
	# Puissance par planète complétée (aligné avec HERO_POWER_PER_PLANET dans game_combat_scene)
	var power_table := {
		-1: 100,   # Aucune planète terminée
		0: 150,    # Mercury terminée
		1: 200,    # Venus terminée
		2: 280,    # Mars terminée
		3: 400,    # Earth terminée (max)
	}
	
	return power_table.get(highest_completed, 100)


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
	var is_unlocked: bool = index <= highest_completed + 1
	var is_completed: bool = index <= highest_completed
	
	# Container principal
	var container := Control.new()
	container.name = "Planet_%d" % index
	container.custom_minimum_size = Vector2(planet_size_center, planet_size_center)
	container.size = Vector2(planet_size_center, planet_size_center)
	
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
	var sprite_path: String = info.get("sprite", "")
	if ResourceLoader.exists(sprite_path):
		var planet_sprite := TextureRect.new()
		planet_sprite.name = "PlanetVisual"
		planet_sprite.texture = load(sprite_path)
		planet_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		planet_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		planet_sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		if not is_unlocked:
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
	
	# Badge de complétion (checkmark vert)
	if is_completed:
		var check_label := Label.new()
		check_label.name = "Check"
		check_label.text = "✓"
		var check_size: int = int(planet_size_center * 0.15)
		check_label.add_theme_font_size_override("font_size", check_size)
		check_label.add_theme_color_override("font_color", Color.GREEN)
		check_label.position = Vector2(planet_size_center - check_size - 10, 5)
		container.add_child(check_label)
	
	# Cadenas si verrouillé
	if not is_unlocked:
		var lock_container := Control.new()
		lock_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		container.add_child(lock_container)
		
		var lock_label := Label.new()
		lock_label.name = "Lock"
		lock_label.text = "🔒"
		lock_label.add_theme_font_size_override("font_size", 52)
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lock_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		lock_container.add_child(lock_label)
	
	# Stocker les métadonnées
	container.set_meta("planet_index", index)
	container.set_meta("is_unlocked", is_unlocked)
	
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
	var is_unlocked: bool = current_index <= _get_highest_completed() + 1
	var is_completed: bool = current_index <= _get_highest_completed()
	var player_power := _calculate_player_power()
	var recommended: int = info["recommended_power"]
	
	# Nom et description
	if planet_name_label:
		planet_name_label.text = info["name"]
	
	if planet_desc_label:
		planet_desc_label.text = info["description"] if is_unlocked else "🔒 Locked Planet"
	
	# Difficulté
	if difficulty_label:
		difficulty_label.text = "★".repeat(info["difficulty"]) + "☆".repeat(4 - info["difficulty"])
	
	# Puissance recommandée avec couleur selon notre niveau
	if recommended_power_label:
		if is_unlocked:
			recommended_power_label.text = "Recommended Power: %d" % recommended
			if player_power >= recommended:
				recommended_power_label.add_theme_color_override("font_color", Color.GREEN)
			elif player_power >= recommended * 0.7:
				recommended_power_label.add_theme_color_override("font_color", Color.YELLOW)
			else:
				recommended_power_label.add_theme_color_override("font_color", Color.ORANGE_RED)
		else:
			recommended_power_label.text = "Complete %s to unlock" % PLANETS_INFO[maxi(0, current_index - 1)]["name"]
			recommended_power_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	# Bouton jouer - PLAY ou REPLAY selon si complété
	if play_button:
		play_button.visible = is_unlocked
		play_button.disabled = not is_unlocked
		if is_completed:
			play_button.text = "🔄 REPLAY"
		else:
			play_button.text = "▶ PLAY"
	
	# Flèches de navigation
	if left_arrow:
		left_arrow.disabled = current_index <= 0
		left_arrow.modulate.a = 1.0 if current_index > 0 else 0.3
	
	if right_arrow:
		right_arrow.disabled = current_index >= PLANETS_INFO.size() - 1
		right_arrow.modulate.a = 1.0 if current_index < PLANETS_INFO.size() - 1 else 0.3


func _get_highest_completed() -> int:
	if SaveManager:
		return SaveManager.get_highest_planet_completed()
	return -1


func _on_left_pressed() -> void:
	if current_index > 0:
		current_index -= 1
		_update_carousel_positions(true)
		_update_planet_info_display()
		_animate_button(left_arrow)


func _on_right_pressed() -> void:
	if current_index < PLANETS_INFO.size() - 1:
		current_index += 1
		_update_carousel_positions(true)
		_update_planet_info_display()
		_animate_button(right_arrow)


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
	# Créer le container en arrière-plan (z_index négatif)
	spaceships_container = Control.new()
	spaceships_container.name = "SpaceshipsBackground"
	spaceships_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	spaceships_container.z_index = -10  # Derrière le contenu, devant le background
	spaceships_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(spaceships_container)
	move_child(spaceships_container, 1)  # Après le background (index 0)
	
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
