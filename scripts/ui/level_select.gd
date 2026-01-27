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
@onready var back_button: Button = %BackButton
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

## Scènes
const MAIN_MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const COMBAT_SCENE := "res://scenes/game_combat_scene.tscn"

## Données des planètes
const PLANETS_INFO := [
	{
		"id": "mercury",
		"name": "Mercury",
		"description": "Fast and aggressive enemies",
		"color": Color(0.9, 0.4, 0.1),
		"bg_color": Color(0.3, 0.15, 0.05),
		"difficulty": 1,
		"recommended_power": 100
	},
	{
		"id": "venus",
		"name": "Venus",
		"description": "Toxic and persistent enemies",
		"color": Color(0.9, 0.75, 0.2),
		"bg_color": Color(0.3, 0.25, 0.05),
		"difficulty": 2,
		"recommended_power": 140
	},
	{
		"id": "mars",
		"name": "Mars",
		"description": "Regenerating enemies",
		"color": Color(0.85, 0.25, 0.15),
		"bg_color": Color(0.25, 0.08, 0.05),
		"difficulty": 3,
		"recommended_power": 190
	},
	{
		"id": "earth",
		"name": "Earth",
		"description": "Final Battle - Dr. Mortis awaits",
		"color": Color(0.2, 0.6, 0.9),
		"bg_color": Color(0.05, 0.15, 0.25),
		"difficulty": 4,
		"recommended_power": 270
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

## Espacement entre les planètes dans le carrousel
const PLANET_SPACING := 200.0

## Taille de la planète centrale
const PLANET_SIZE_CENTER := 160.0

## Taille des planètes sur les côtés
const PLANET_SIZE_SIDE := 100.0


func _ready() -> void:
	_connect_signals()
	_update_displays()
	# Attendre que le carousel_container ait sa taille
	await get_tree().process_frame
	_create_planet_carousel()
	_animate_entrance()


func _connect_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	left_arrow.pressed.connect(_on_left_pressed)
	right_arrow.pressed.connect(_on_right_pressed)
	play_button.pressed.connect(_on_play_pressed)
	
	if SaveManager:
		SaveManager.currency_changed.connect(_on_currency_changed)


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
	container.custom_minimum_size = Vector2(PLANET_SIZE_CENTER, PLANET_SIZE_CENTER)
	container.size = Vector2(PLANET_SIZE_CENTER, PLANET_SIZE_CENTER)
	
	# Anneau extérieur (glow)
	var ring := Control.new()
	ring.name = "Ring"
	ring.custom_minimum_size = Vector2(PLANET_SIZE_CENTER + 30, PLANET_SIZE_CENTER + 30)
	ring.size = Vector2(PLANET_SIZE_CENTER + 30, PLANET_SIZE_CENTER + 30)
	ring.position = Vector2(-15, -15)
	container.add_child(ring)
	
	var ring_bg := ColorRect.new()
	ring_bg.color = info["color"].lightened(0.2) if is_unlocked else Color(0.25, 0.25, 0.25)
	ring_bg.modulate.a = 0.4
	ring_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	ring.add_child(ring_bg)
	
	# Cercle de la planète
	var planet_visual := ColorRect.new()
	planet_visual.name = "PlanetVisual"
	planet_visual.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	if is_unlocked:
		planet_visual.color = info["color"]
	else:
		planet_visual.color = Color(0.35, 0.35, 0.35)  # Grisé
	
	container.add_child(planet_visual)
	
	# Badge de complétion (checkmark vert)
	if is_completed:
		var check_label := Label.new()
		check_label.name = "Check"
		check_label.text = "✓"
		check_label.add_theme_font_size_override("font_size", 32)
		check_label.add_theme_color_override("font_color", Color.GREEN)
		check_label.position = Vector2(PLANET_SIZE_CENTER - 35, 5)
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
		var target_x := center_x + (offset * PLANET_SPACING) - PLANET_SIZE_CENTER / 2
		var target_y := center_y - PLANET_SIZE_CENTER / 2
		
		# Scale selon la distance du centre
		var distance := absf(offset)
		var target_scale := 1.0 if distance == 0 else maxf(0.55, 1.0 - distance * 0.3)
		
		# Opacité selon la distance
		var target_alpha := 1.0 if distance == 0 else maxf(0.35, 1.0 - distance * 0.35)
		
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


func _on_back_pressed() -> void:
	_animate_button(back_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


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
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Animer les planètes avec un effet "pop"
	for i in range(planet_nodes.size()):
		var node: Control = planet_nodes[i]
		var original_scale := node.scale
		node.scale = Vector2.ZERO
		
		var pop_tween := create_tween()
		pop_tween.tween_property(node, "scale", original_scale * 1.1, 0.3).set_delay(0.08 * i).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		pop_tween.tween_property(node, "scale", original_scale, 0.12)
