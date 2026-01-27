## GameCombatScene - Scène de combat principale (version réaliste)
##
## Layout proche du jeu final avec:
## - Background planétaire
## - Zone de combat avec héros à gauche, ennemis à droite
## - HUD complet avec feedbacks visuels
## - Effets visuels pour les actions
extends Node2D

## Configuration de la planète actuelle
@export var current_planet: int = 0  # 0 = Mercury

## Couleurs par planète
const PLANET_COLORS := {
	0: {  # Mercury
		"bg_top": Color(0.15, 0.05, 0.02),
		"bg_bottom": Color(0.4, 0.15, 0.05),
		"accent": Color(1.0, 0.5, 0.2),
		"name": "MERCURY"
	},
	1: {  # Venus
		"bg_top": Color(0.1, 0.12, 0.02),
		"bg_bottom": Color(0.3, 0.35, 0.1),
		"accent": Color(0.8, 0.9, 0.2),
		"name": "VENUS"
	},
	2: {  # Mars
		"bg_top": Color(0.12, 0.03, 0.02),
		"bg_bottom": Color(0.35, 0.1, 0.08),
		"accent": Color(0.9, 0.4, 0.3),
		"name": "MARS"
	},
	3: {  # Earth
		"bg_top": Color(0.02, 0.05, 0.12),
		"bg_bottom": Color(0.1, 0.15, 0.3),
		"accent": Color(0.3, 0.6, 0.9),
		"name": "EARTH"
	}
}

## Références aux systèmes
var pressure_gauge: PressureGauge
var state_machine: CombatStateMachine
var combat_manager: CombatManager
var hero: AlienHero

## UI Elements
var background: CanvasLayer
var combat_zone: Control
var hud_layer: CanvasLayer
var effects_layer: CanvasLayer

## UI Components
var hero_container: Control
var enemy_container: Control
var click_zone_button: ClickZoneButton
var hero_hp_bar: ProgressBar
var enemy_hp_bar: ProgressBar
var pressure_bars: Dictionary = {}
var wave_label: Label
var planet_label: Label
var currency_label: Label
var punishment_overlay: ColorRect
var punishment_timer_label: Label

## Ennemis actifs
var active_enemies: Array = []
var enemy_visuals: Dictionary = {}

## État du jeu
var current_wave: int = 1
var total_waves: int = 5
var enemies_in_wave: int = 3
var is_game_over: bool = false

## Game Over UI
var game_over_panel: PanelContainer
var stats_container: VBoxContainer

## Hero Sprite System
var hero_sprite: TextureRect
var hero_textures: Dictionary = {}
enum HeroPose { IDLE, READY, DODGE, ATTACK_1, ATTACK_2, ATTACK_3, SPECIAL }
var current_hero_pose: HeroPose = HeroPose.IDLE

## ========== BALANCE CONFIG ==========
## Héros
const HERO_BASE_HP := 150
const HERO_BASE_ATTACK := 12
const HERO_ATTACK_SPEED := 1.5
const HERO_CRIT_CHANCE := 0.15
const HERO_DODGE_CHANCE := 0.08

## Heal action
const HEAL_BASE_AMOUNT := 20
const HEAL_BOOST_MULTIPLIER := 1.5  # x1.5 si boost actif

## Ennemis par planète (multiplicateurs)
const PLANET_ENEMY_MULTIPLIERS := {
	0: {"hp": 1.0, "atk": 1.0, "speed": 1.3, "name": "Scout"},  # Mercury - rapide
	1: {"hp": 0.9, "atk": 1.2, "speed": 1.0, "name": "Toxin"},  # Venus - toxic DPS
	2: {"hp": 1.2, "atk": 0.9, "speed": 0.9, "name": "Regen"},  # Mars - tanky
	3: {"hp": 1.5, "atk": 1.3, "speed": 0.7, "name": "Titan"},  # Earth - boss-like
}

## Scaling par vague
const WAVE_HP_SCALING := 1.15  # +15% HP par vague
const WAVE_ATK_SCALING := 1.1  # +10% ATK par vague
const ENEMIES_PER_WAVE := [2, 3, 3, 4, 5]  # Nombre d'ennemis par vague

## Récompenses
const ENEMY_KILL_REWARD := 8
const WAVE_CLEAR_BONUS := 25
const VICTORY_BONUS := 100


func _ready() -> void:
	# Charger la planète sélectionnée depuis le SaveManager
	if SaveManager:
		current_planet = SaveManager.get_current_planet()
	
	_setup_background()
	_setup_combat_zone()
	_setup_systems()
	_setup_hero()
	_setup_hud()
	_setup_effects_layer()
	_connect_signals()
	
	# Démarrer le combat
	await get_tree().create_timer(0.5).timeout
	_spawn_wave()
	state_machine.start_combat()


# ==================== SETUP BACKGROUND ====================

func _setup_background() -> void:
	background = CanvasLayer.new()
	background.name = "Background"
	background.layer = -10
	add_child(background)
	
	var planet_colors: Dictionary = PLANET_COLORS.get(current_planet, PLANET_COLORS[0])
	
	# Gradient background
	var bg_rect := ColorRect.new()
	bg_rect.name = "BackgroundGradient"
	bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_rect.color = planet_colors.bg_bottom
	background.add_child(bg_rect)
	
	# Top gradient overlay
	var gradient_top := ColorRect.new()
	gradient_top.name = "GradientTop"
	gradient_top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	gradient_top.custom_minimum_size.y = 400
	gradient_top.color = planet_colors.bg_top
	background.add_child(gradient_top)
	
	# Particules d'ambiance (étoiles/poussière)
	_add_ambient_particles(planet_colors.accent)
	
	# Ligne d'horizon
	var horizon := ColorRect.new()
	horizon.name = "Horizon"
	horizon.color = planet_colors.accent.darkened(0.5)
	horizon.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	horizon.custom_minimum_size.y = 2
	horizon.position.y = -350
	background.add_child(horizon)


func _add_ambient_particles(accent_color: Color) -> void:
	# Créer des "étoiles" statiques en arrière-plan
	var stars_container := Control.new()
	stars_container.name = "Stars"
	stars_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.add_child(stars_container)
	
	for i in range(30):
		var star := ColorRect.new()
		star.size = Vector2(2, 2) if randf() > 0.7 else Vector2(1, 1)
		star.color = accent_color.lightened(0.5)
		star.color.a = randf_range(0.3, 0.8)
		star.position = Vector2(randf_range(0, 720), randf_range(0, 600))
		stars_container.add_child(star)


# ==================== SETUP COMBAT ZONE ====================

func _setup_combat_zone() -> void:
	combat_zone = Control.new()
	combat_zone.name = "CombatZone"
	combat_zone.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(combat_zone)
	
	# Container pour le héros (côté gauche)
	hero_container = Control.new()
	hero_container.name = "HeroContainer"
	hero_container.position = Vector2(80, 450)
	combat_zone.add_child(hero_container)
	
	# Container pour les ennemis (côté droit)
	enemy_container = Control.new()
	enemy_container.name = "EnemyContainer"
	enemy_container.position = Vector2(500, 400)
	combat_zone.add_child(enemy_container)
	
	# Sol/Platform visuel
	var ground := ColorRect.new()
	ground.name = "Ground"
	ground.color = Color(0.1, 0.08, 0.06, 0.8)
	ground.size = Vector2(720, 150)
	ground.position = Vector2(0, 700)
	combat_zone.add_child(ground)
	
	# Ligne de séparation combat
	var battle_line := ColorRect.new()
	battle_line.name = "BattleLine"
	battle_line.color = PLANET_COLORS.get(current_planet, PLANET_COLORS[0]).accent
	battle_line.color.a = 0.3
	battle_line.size = Vector2(2, 300)
	battle_line.position = Vector2(359, 400)
	combat_zone.add_child(battle_line)


# ==================== SETUP SYSTEMS ====================

func _setup_systems() -> void:
	pressure_gauge = PressureGauge.new()
	pressure_gauge.name = "PressureGauge"
	add_child(pressure_gauge)
	
	state_machine = CombatStateMachine.new()
	state_machine.name = "CombatStateMachine"
	add_child(state_machine)
	state_machine.connect_pressure_gauge(pressure_gauge)
	
	combat_manager = CombatManager.new()
	combat_manager.name = "CombatManager"
	combat_manager.state_machine = state_machine
	combat_manager.pressure_gauge = pressure_gauge
	add_child(combat_manager)


# ==================== SETUP HERO ====================

func _setup_hero() -> void:
	hero = AlienHero.new()
	hero.name = "AlienHero"
	
	var hero_stats := EntityStats.new()
	hero_stats.display_name = "Alien Hero"
	hero_stats.max_hp = HERO_BASE_HP
	hero_stats.attack = HERO_BASE_ATTACK
	hero_stats.attack_speed = HERO_ATTACK_SPEED
	hero_stats.crit_chance = HERO_CRIT_CHANCE
	hero_stats.dodge_chance = HERO_DODGE_CHANCE
	hero.base_stats = hero_stats
	
	hero_container.add_child(hero)
	combat_manager.hero = hero
	
	# Reconnecter les signaux du héros dans le combat manager
	# (nécessaire car le hero est assigné après _ready du combat_manager)
	combat_manager._connect_hero_signals()
	
	# Visuel du héros
	_create_hero_visual()


func _create_hero_visual() -> void:
	# Charger toutes les textures du héros
	_load_hero_textures()
	
	var visual := Control.new()
	visual.name = "HeroVisual"
	hero.add_child(visual)
	
	# Sprite principal du héros
	hero_sprite = TextureRect.new()
	hero_sprite.name = "HeroSprite"
	hero_sprite.texture = hero_textures.get(HeroPose.IDLE)
	hero_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_sprite.custom_minimum_size = Vector2(150, 180)
	hero_sprite.size = Vector2(150, 180)
	hero_sprite.position = Vector2(-75, -180)
	visual.add_child(hero_sprite)
	
	# Barre de vie au-dessus du héros
	var hp_bg := ColorRect.new()
	hp_bg.name = "HPBackground"
	hp_bg.color = Color(0.1, 0.1, 0.1, 0.8)
	hp_bg.size = Vector2(100, 12)
	hp_bg.position = Vector2(-50, -195)
	visual.add_child(hp_bg)
	
	var hp_fill := ColorRect.new()
	hp_fill.name = "HPFill"
	hp_fill.color = Color(0.2, 0.9, 0.3)
	hp_fill.size = Vector2(98, 10)
	hp_fill.position = Vector2(-49, -194)
	visual.add_child(hp_fill)


func _load_hero_textures() -> void:
	## Charge toutes les textures du héros
	var base_path := "res://assets/sprites/hero/"
	hero_textures = {
		HeroPose.IDLE: load(base_path + "hero_idle.png"),
		HeroPose.READY: load(base_path + "hero_ready.png"),
		HeroPose.DODGE: load(base_path + "hero_dodge.png"),
		HeroPose.ATTACK_1: load(base_path + "hero_attack_1.png"),
		HeroPose.ATTACK_2: load(base_path + "hero_attack_2.png"),
		HeroPose.ATTACK_3: load(base_path + "hero_attack_3.png"),
		HeroPose.SPECIAL: load(base_path + "hero_special.png"),
	}


func set_hero_pose(pose: HeroPose, duration: float = 0.0) -> void:
	## Change la pose du héros avec animation optionnelle
	if not hero_sprite:
		return
	
	current_hero_pose = pose
	hero_sprite.texture = hero_textures.get(pose, hero_textures[HeroPose.IDLE])
	
	# Animation de scaling au changement
	var tween := create_tween()
	tween.tween_property(hero_sprite, "scale", Vector2(1.1, 1.1), 0.05)
	tween.tween_property(hero_sprite, "scale", Vector2(1.0, 1.0), 0.05)
	
	# Si durée spécifiée, revenir à idle après
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout
		if current_hero_pose == pose:  # Seulement si pas changé entre-temps
			set_hero_pose(HeroPose.IDLE)


# ==================== SETUP HUD ====================

func _setup_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.name = "HUDLayer"
	hud_layer.layer = 10
	add_child(hud_layer)
	
	var hud_root := Control.new()
	hud_root.name = "HUDRoot"
	hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_layer.add_child(hud_root)
	
	_create_top_hud(hud_root)
	_create_pressure_display(hud_root)
	_create_bottom_hud(hud_root)
	_create_punishment_overlay(hud_root)


func _create_top_hud(parent: Control) -> void:
	var top_bar := MarginContainer.new()
	top_bar.name = "TopBar"
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.custom_minimum_size.y = 140
	top_bar.add_theme_constant_override("margin_left", 15)
	top_bar.add_theme_constant_override("margin_right", 15)
	top_bar.add_theme_constant_override("margin_top", 35)
	parent.add_child(top_bar)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	top_bar.add_child(hbox)
	
	# Section Héros (gauche) - avec stats détaillées
	var hero_section := VBoxContainer.new()
	hero_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_section.add_theme_constant_override("separation", 3)
	hbox.add_child(hero_section)
	
	var hero_header := HBoxContainer.new()
	hero_section.add_child(hero_header)
	
	var hero_title := Label.new()
	hero_title.text = "👽 ALIEN HERO"
	hero_title.add_theme_font_size_override("font_size", 13)
	hero_title.add_theme_color_override("font_color", Color(0.7, 1.0, 0.7))
	hero_header.add_child(hero_title)
	
	hero_hp_bar = _create_styled_progress_bar(Color(0.2, 0.9, 0.3), 180, 22)
	hero_hp_bar.name = "HeroHPBar"
	hero_section.add_child(hero_hp_bar)
	
	# Stats du héros sous la barre de vie
	var hero_stats_label := Label.new()
	hero_stats_label.name = "HeroStatsLabel"
	hero_stats_label.text = "ATK: %d | SPD: %.1f | CRIT: %d%%" % [HERO_BASE_ATTACK, HERO_ATTACK_SPEED, int(HERO_CRIT_CHANCE * 100)]
	hero_stats_label.add_theme_font_size_override("font_size", 10)
	hero_stats_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	hero_section.add_child(hero_stats_label)
	
	# Section centrale (Wave info + Planet)
	var center_section := VBoxContainer.new()
	center_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_section.alignment = BoxContainer.ALIGNMENT_CENTER
	center_section.add_theme_constant_override("separation", 2)
	hbox.add_child(center_section)
	
	planet_label = Label.new()
	planet_label.text = "🪐 " + PLANET_COLORS.get(current_planet, PLANET_COLORS[0]).name
	planet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	planet_label.add_theme_font_size_override("font_size", 16)
	planet_label.add_theme_color_override("font_color", PLANET_COLORS.get(current_planet, PLANET_COLORS[0]).accent)
	center_section.add_child(planet_label)
	
	wave_label = Label.new()
	wave_label.text = "⚔️ WAVE %d / %d" % [current_wave, total_waves]
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_label.add_theme_font_size_override("font_size", 20)
	wave_label.add_theme_color_override("font_color", Color.WHITE)
	center_section.add_child(wave_label)
	
	# Indicateur d'ennemis restants
	var enemies_remaining_label := Label.new()
	enemies_remaining_label.name = "EnemiesRemainingLabel"
	enemies_remaining_label.text = "Enemies: 0"
	enemies_remaining_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemies_remaining_label.add_theme_font_size_override("font_size", 11)
	enemies_remaining_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	center_section.add_child(enemies_remaining_label)
	
	# Section Ennemis (droite) - avec stats
	var enemy_section := VBoxContainer.new()
	enemy_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_section.alignment = BoxContainer.ALIGNMENT_END
	enemy_section.add_theme_constant_override("separation", 3)
	hbox.add_child(enemy_section)
	
	var enemy_title := Label.new()
	enemy_title.text = "ENEMIES 👾"
	enemy_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy_title.add_theme_font_size_override("font_size", 13)
	enemy_title.add_theme_color_override("font_color", Color(1.0, 0.7, 0.7))
	enemy_section.add_child(enemy_title)
	
	enemy_hp_bar = _create_styled_progress_bar(Color(0.9, 0.2, 0.2), 200, 25)
	enemy_hp_bar.name = "EnemyHPBar"
	enemy_hp_bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN
	enemy_section.add_child(enemy_hp_bar)
	
	# Monnaie (coin supérieur droit)
	currency_label = Label.new()
	currency_label.name = "CurrencyLabel"
	currency_label.text = "💰 0 SC"
	currency_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	currency_label.position = Vector2(-100, 10)
	currency_label.add_theme_font_size_override("font_size", 16)
	currency_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	parent.add_child(currency_label)


func _create_pressure_display(parent: Control) -> void:
	var pressure_container := HBoxContainer.new()
	pressure_container.name = "PressureContainer"
	pressure_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	pressure_container.position.y = 130
	pressure_container.add_theme_constant_override("separation", 30)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 50)
	margin.add_theme_constant_override("margin_right", 50)
	margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	margin.position.y = 130
	margin.custom_minimum_size.y = 40
	parent.add_child(margin)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)
	margin.add_child(hbox)
	
	# Créer les 3 jauges de pression avec icônes
	_create_pressure_bar_with_icon(hbox, &"heal", "❤️", Color(0.2, 0.7, 0.9))
	_create_pressure_bar_with_icon(hbox, &"dodge", "🛡️", Color(0.6, 0.4, 0.9))
	_create_pressure_bar_with_icon(hbox, &"attack", "⚔️", Color(0.9, 0.3, 0.2))


func _create_pressure_bar_with_icon(parent: HBoxContainer, action: StringName, icon: String, color: Color) -> void:
	var container := HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_theme_constant_override("separation", 5)
	parent.add_child(container)
	
	var icon_label := Label.new()
	icon_label.text = icon
	icon_label.add_theme_font_size_override("font_size", 16)
	container.add_child(icon_label)
	
	var bar := _create_styled_progress_bar(color, 0, 12)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.max_value = 100
	bar.value = 0
	container.add_child(bar)
	
	pressure_bars[action] = bar


func _create_bottom_hud(parent: Control) -> void:
	var bottom_container := VBoxContainer.new()
	bottom_container.name = "BottomContainer"
	bottom_container.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_container.position.y = -250
	bottom_container.add_theme_constant_override("separation", 15)
	parent.add_child(bottom_container)
	
	# Barre de skills
	var skill_bar := _create_skill_bar()
	bottom_container.add_child(skill_bar)
	
	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 10
	bottom_container.add_child(spacer)
	
	# Bouton Click Zone tripartite
	var click_margin := MarginContainer.new()
	click_margin.add_theme_constant_override("margin_left", 20)
	click_margin.add_theme_constant_override("margin_right", 20)
	click_margin.add_theme_constant_override("margin_bottom", 30)
	bottom_container.add_child(click_margin)
	
	click_zone_button = ClickZoneButton.new()
	click_zone_button.name = "ClickZoneButton"
	click_zone_button.custom_minimum_size = Vector2(680, 130)
	click_zone_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	click_zone_button.heal_color = Color(0.15, 0.5, 0.8, 0.9)
	click_zone_button.dodge_color = Color(0.6, 0.35, 0.9, 0.9)  # Violet pour Dodge
	click_zone_button.attack_color = Color(0.8, 0.2, 0.15, 0.9)
	click_margin.add_child(click_zone_button)
	
	# Connecter au combat manager
	combat_manager.connect_click_zone(click_zone_button)


## Skill cooldowns
var skill_cooldowns: Dictionary = {
	"heal_burst": 0.0,
	"crit_surge": 0.0,
	"dodge_field": 0.0,
	"nova_blast": 0.0
}

## Skill buttons for reference
var skill_buttons: Dictionary = {}


func _create_skill_bar() -> HBoxContainer:
	var skill_bar := HBoxContainer.new()
	skill_bar.name = "SkillBar"
	skill_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	skill_bar.add_theme_constant_override("separation", 15)
	
	var skills := [
		{"id": "heal_burst", "name": "HEAL", "color": Color(0.2, 0.8, 0.5), "icon": "💚", "cooldown": 12.0, "desc": "Full Heal"},
		{"id": "crit_surge", "name": "CRIT", "color": Color(0.9, 0.5, 0.1), "icon": "💥", "cooldown": 15.0, "desc": "+50% Crit"},
		{"id": "dodge_field", "name": "SHIELD", "color": Color(0.5, 0.4, 0.9), "icon": "🛡️", "cooldown": 10.0, "desc": "Invincible"},
		{"id": "nova_blast", "name": "NOVA", "color": Color(0.9, 0.2, 0.3), "icon": "☄️", "cooldown": 20.0, "desc": "AOE Dmg"},
	]
	
	for skill in skills:
		var skill_btn := _create_skill_button(skill)
		skill_bar.add_child(skill_btn)
		skill_buttons[skill.id] = skill_btn
	
	return skill_bar


func _create_skill_button(skill_data: Dictionary) -> Button:
	var btn := Button.new()
	btn.name = skill_data.id
	btn.custom_minimum_size = Vector2(75, 80)
	btn.text = skill_data.icon + "\n" + skill_data.name
	
	var style := StyleBoxFlat.new()
	style.bg_color = skill_data.color.darkened(0.6)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = skill_data.color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	btn.add_theme_stylebox_override("normal", style)
	
	var hover_style := style.duplicate()
	hover_style.bg_color = skill_data.color.darkened(0.3)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style := style.duplicate()
	pressed_style.bg_color = skill_data.color
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
	var disabled_style := style.duplicate()
	disabled_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	disabled_style.border_color = Color(0.4, 0.4, 0.4)
	btn.add_theme_stylebox_override("disabled", disabled_style)
	
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)
	
	# Connecter le bouton
	btn.pressed.connect(_on_skill_pressed.bind(skill_data))
	
	# Stocker les données du skill dans metadata
	btn.set_meta("skill_data", skill_data)
	btn.set_meta("cooldown_label", null)
	
	return btn


func _on_skill_pressed(skill_data: Dictionary) -> void:
	var skill_id: String = skill_data.id
	
	# Vérifier le cooldown
	if skill_cooldowns[skill_id] > 0:
		_show_floating_text("COOLDOWN!", Vector2(360, 500), Color(0.7, 0.7, 0.7), 18)
		return
	
	# Vérifier si le combat est actif
	if not state_machine or not state_machine.can_player_act():
		return
	
	# Exécuter le skill
	match skill_id:
		"heal_burst":
			_activate_heal_burst()
		"crit_surge":
			_activate_crit_surge()
		"dodge_field":
			_activate_dodge_field()
		"nova_blast":
			_activate_nova_blast()
	
	# Mettre en cooldown
	skill_cooldowns[skill_id] = skill_data.cooldown
	if skill_buttons.has(skill_id):
		skill_buttons[skill_id].disabled = true


## SKILL 1: Heal Burst - Soigne 100% des PV
func _activate_heal_burst() -> void:
	if not hero or not hero.is_alive:
		return
	
	# Pose spéciale (dual wield)
	set_hero_pose(HeroPose.SPECIAL, 0.8)
	
	# Effet visuel: Flash vert + particules
	_create_screen_flash(Color(0.2, 1.0, 0.4, 0.4))
	_create_skill_particles(hero.global_position + Vector2(80, 400), Color(0.3, 1.0, 0.5), 20)
	
	# Full heal
	var healed := hero.heal(hero.base_stats.max_hp)
	_show_floating_text("💚 FULL HEAL! +%d" % healed, Vector2(150, 350), Color(0.3, 1.0, 0.5), 32)
	_flash_entity(hero, Color(0.3, 1.0, 0.5, 0.8))


## SKILL 2: Crit Surge - +50% crit pendant 8s
func _activate_crit_surge() -> void:
	if not hero or not hero.is_alive:
		return
	
	# Pose prête au combat
	set_hero_pose(HeroPose.READY, 0.6)
	
	# Effet visuel: Flash orange + texte
	_create_screen_flash(Color(1.0, 0.6, 0.1, 0.3))
	_create_skill_particles(hero.global_position + Vector2(80, 400), Color(1.0, 0.7, 0.2), 15)
	
	hero.add_temp_modifier("crit_chance", 0.50, "add", 8.0)
	_show_floating_text("💥 CRIT SURGE! +50%", Vector2(150, 350), Color(1.0, 0.7, 0.2), 32)
	_flash_entity(hero, Color(1.0, 0.7, 0.2, 0.8))


## SKILL 3: Dodge Field - Invincible pendant 3s
func _activate_dodge_field() -> void:
	if not hero or not hero.is_alive:
		return
	
	# Pose défensive (crouch)
	set_hero_pose(HeroPose.DODGE, 1.0)
	
	# Effet visuel: Flash violet + shield
	_create_screen_flash(Color(0.6, 0.4, 1.0, 0.3))
	_create_shield_effect()
	
	# 100% dodge pendant 3s
	hero.add_temp_modifier("dodge_chance", 1.0, "add", 3.0)
	_show_floating_text("🛡️ INVINCIBLE!", Vector2(150, 350), Color(0.6, 0.5, 1.0), 32)
	_flash_entity(hero, Color(0.6, 0.4, 1.0, 0.8))


## SKILL 4: Nova Blast - Dégâts massifs à tous les ennemis
func _activate_nova_blast() -> void:
	if not hero or not hero.is_alive:
		return
	
	# Pose d'attaque puissante (tir droit)
	set_hero_pose(HeroPose.ATTACK_2, 0.8)
	
	# Effet visuel: Flash rouge + explosion
	_create_screen_flash(Color(1.0, 0.2, 0.1, 0.5))
	_create_explosion_effect()
	
	# Infliger 50 dégâts à tous les ennemis
	var total_damage := 0
	for enemy in active_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			enemy.take_damage(50, false)
			total_damage += 50
			_flash_entity(enemy, Color(1.0, 0.3, 0.1))
	
	_show_floating_text("☄️ NOVA BLAST! -%d" % total_damage, Vector2(350, 350), Color(1.0, 0.3, 0.2), 36)


## Crée un flash d'écran coloré
func _create_screen_flash(color: Color) -> void:
	var flash := ColorRect.new()
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.color = color
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	effects_layer.add_child(flash)
	
	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.0, 0.4)
	tween.tween_callback(flash.queue_free)


## Crée des particules de skill
func _create_skill_particles(pos: Vector2, color: Color, count: int) -> void:
	for i in range(count):
		var particle := ColorRect.new()
		particle.size = Vector2(8, 8)
		particle.color = color
		particle.position = pos + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		effects_layer.add_child(particle)
		
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position:y", particle.position.y - 100, 0.6)
		tween.tween_property(particle, "modulate:a", 0.0, 0.6)
		tween.tween_property(particle, "scale", Vector2(0.1, 0.1), 0.6)
		tween.chain().tween_callback(particle.queue_free)


## Crée un effet de bouclier autour du héros
func _create_shield_effect() -> void:
	var shield := ColorRect.new()
	shield.size = Vector2(120, 180)
	shield.color = Color(0.5, 0.4, 1.0, 0.4)
	shield.position = Vector2(20, 280)
	effects_layer.add_child(shield)
	
	var tween := create_tween()
	tween.tween_property(shield, "modulate:a", 0.0, 3.0)
	tween.tween_callback(shield.queue_free)


## Crée un effet d'explosion
func _create_explosion_effect() -> void:
	var explosion := ColorRect.new()
	explosion.size = Vector2(50, 50)
	explosion.color = Color(1.0, 0.3, 0.1, 0.9)
	explosion.position = Vector2(480, 380)
	effects_layer.add_child(explosion)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(explosion, "size", Vector2(300, 300), 0.3)
	tween.tween_property(explosion, "position", Vector2(330, 230), 0.3)
	tween.tween_property(explosion, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(explosion.queue_free)


func _create_punishment_overlay(parent: Control) -> void:
	punishment_overlay = ColorRect.new()
	punishment_overlay.name = "PunishmentOverlay"
	punishment_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	punishment_overlay.color = Color(0.2, 0.0, 0.0, 0.0)
	punishment_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(punishment_overlay)
	
	var punishment_container := VBoxContainer.new()
	punishment_container.name = "PunishmentContainer"
	punishment_container.set_anchors_preset(Control.PRESET_CENTER)
	punishment_container.alignment = BoxContainer.ALIGNMENT_CENTER
	punishment_container.visible = false
	parent.add_child(punishment_container)
	
	var punishment_title := Label.new()
	punishment_title.name = "PunishmentTitle"
	punishment_title.text = "⚠️ OVERLOADED ⚠️"
	punishment_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	punishment_title.add_theme_font_size_override("font_size", 36)
	punishment_title.add_theme_color_override("font_color", Color.RED)
	punishment_container.add_child(punishment_title)
	
	punishment_timer_label = Label.new()
	punishment_timer_label.name = "PunishmentTimer"
	punishment_timer_label.text = "10.0s"
	punishment_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	punishment_timer_label.add_theme_font_size_override("font_size", 48)
	punishment_timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	punishment_container.add_child(punishment_timer_label)


func _create_styled_progress_bar(color: Color, width: int, height: int) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.min_value = 0
	bar.max_value = 100
	bar.value = 100
	if width > 0:
		bar.custom_minimum_size.x = width
	bar.custom_minimum_size.y = height
	
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
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
	
	return bar


# ==================== SETUP EFFECTS ====================

func _setup_effects_layer() -> void:
	effects_layer = CanvasLayer.new()
	effects_layer.name = "EffectsLayer"
	effects_layer.layer = 5
	add_child(effects_layer)


# ==================== CONNECT SIGNALS ====================

func _connect_signals() -> void:
	combat_manager.player_action.connect(_on_player_action)
	combat_manager.critical_hit.connect(_on_critical_hit)
	combat_manager.dodge_success.connect(_on_dodge_success)
	combat_manager.hero_healed.connect(_on_hero_healed)
	combat_manager.hero_pose_changed.connect(_on_hero_pose_changed)
	
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.victory.connect(_on_victory)
	state_machine.defeat.connect(_on_defeat)
	
	pressure_gauge.pressure_changed.connect(_on_pressure_changed)
	pressure_gauge.punishment_started.connect(_on_punishment_started)
	pressure_gauge.punishment_ended.connect(_on_punishment_ended)
	
	hero.hp_changed.connect(_on_hero_hp_changed)
	hero.damaged.connect(_on_hero_damaged)
	hero.died.connect(_on_hero_died_signal)


func _on_hero_pose_changed(pose_name: StringName, duration: float) -> void:
	## Change la pose du héros selon le signal du CombatManager
	var pose: HeroPose = HeroPose.IDLE
	match pose_name:
		&"idle":
			pose = HeroPose.IDLE
		&"ready":
			pose = HeroPose.READY
		&"dodge":
			pose = HeroPose.DODGE
		&"attack_1":
			pose = HeroPose.ATTACK_1
		&"attack_2":
			pose = HeroPose.ATTACK_2
		&"attack_3":
			pose = HeroPose.ATTACK_3
		&"special":
			pose = HeroPose.SPECIAL
	
	set_hero_pose(pose, duration)


# ==================== ENEMY SPAWNING ====================

func _spawn_wave() -> void:
	wave_label.text = "WAVE %d / %d" % [current_wave, total_waves]
	
	# Déterminer le nombre d'ennemis pour cette vague
	var wave_idx := clampi(current_wave - 1, 0, ENEMIES_PER_WAVE.size() - 1)
	enemies_in_wave = ENEMIES_PER_WAVE[wave_idx]
	
	for i in range(enemies_in_wave):
		await get_tree().create_timer(0.4).timeout
		_spawn_enemy(i)


func _spawn_enemy(index: int) -> void:
	var enemy := BaseEnemy.new()
	enemy.name = "Enemy_%d" % index
	enemy.planet_type = current_planet as BaseEnemy.PlanetType
	
	# Récupérer les multiplicateurs de la planète
	var planet_mult: Dictionary = PLANET_ENEMY_MULTIPLIERS.get(current_planet, PLANET_ENEMY_MULTIPLIERS[0])
	
	# Calculer le scaling par vague
	var wave_hp_mult := pow(WAVE_HP_SCALING, current_wave - 1)
	var wave_atk_mult := pow(WAVE_ATK_SCALING, current_wave - 1)
	
	var enemy_stats := EntityStats.new()
	enemy_stats.display_name = planet_mult.name
	enemy_stats.max_hp = int(45 * planet_mult.hp * wave_hp_mult)
	enemy_stats.attack = int(8 * planet_mult.atk * wave_atk_mult)
	enemy_stats.attack_speed = 0.8 * planet_mult.speed
	enemy_stats.crit_chance = 0.05 + (current_wave * 0.01)  # +1% crit par vague
	enemy.base_stats = enemy_stats
	
	enemy.position = Vector2(index * 80, index * 40 - 40)
	enemy_container.add_child(enemy)
	
	# Créer le visuel de l'ennemi
	var visual := _create_enemy_visual(enemy)
	enemy_visuals[enemy] = visual
	
	# Connecter les signaux
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy.hp_changed.connect(_on_enemy_hp_changed.bind(enemy))
	enemy.damaged.connect(_on_enemy_damaged.bind(enemy))
	
	active_enemies.append(enemy)
	combat_manager.add_enemy(enemy)
	
	# Animation d'apparition
	visual.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(visual, "modulate:a", 1.0, 0.3)


func _create_enemy_visual(enemy: BaseEnemy) -> Control:
	var visual := Control.new()
	visual.name = "EnemyVisual"
	enemy.add_child(visual)
	
	var planet_data: Dictionary = PLANET_COLORS.get(current_planet, PLANET_COLORS[0])
	var accent: Color = planet_data.accent
	
	# Corps
	var body := ColorRect.new()
	body.color = accent.darkened(0.3)
	body.size = Vector2(50, 70)
	body.position = Vector2(-25, -70)
	visual.add_child(body)
	
	# Tête
	var head := ColorRect.new()
	head.color = accent
	head.size = Vector2(40, 40)
	head.position = Vector2(-20, -110)
	visual.add_child(head)
	
	# Oeil unique (méchant)
	var eye := ColorRect.new()
	eye.color = Color.BLACK
	eye.size = Vector2(15, 8)
	eye.position = Vector2(-7, -95)
	visual.add_child(eye)
	
	# Barre de vie
	var hp_bg := ColorRect.new()
	hp_bg.name = "HPBackground"
	hp_bg.color = Color(0.1, 0.1, 0.1, 0.8)
	hp_bg.size = Vector2(60, 8)
	hp_bg.position = Vector2(-30, -125)
	visual.add_child(hp_bg)
	
	var hp_fill := ColorRect.new()
	hp_fill.name = "HPFill"
	hp_fill.color = Color(0.9, 0.2, 0.2)
	hp_fill.size = Vector2(58, 6)
	hp_fill.position = Vector2(-29, -124)
	visual.add_child(hp_fill)
	
	return visual


# ==================== VISUAL EFFECTS ====================

func _show_floating_text(text: String, pos: Vector2, color: Color, size: int = 24) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.position = pos
	label.z_index = 100
	effects_layer.add_child(label)
	
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", pos.y - 60, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.chain().tween_callback(label.queue_free)


func _flash_entity(entity: Node2D, color: Color) -> void:
	var visual: Control = entity.get_node_or_null("HeroVisual")
	if not visual:
		visual = entity.get_node_or_null("EnemyVisual")
	if not visual:
		return
	
	var original_modulate := visual.modulate
	visual.modulate = color
	
	var tween := create_tween()
	tween.tween_property(visual, "modulate", original_modulate, 0.15)


# ==================== PROCESS ====================

func _process(delta: float) -> void:
	if is_game_over:
		return
	_update_hp_displays()
	_update_punishment_display()
	_update_currency_display()
	_update_enemy_count()
	_update_skill_cooldowns(delta)
	_update_blocked_zones()


## Met à jour l'affichage des zones bloquées par overload (comme les skills)
func _update_blocked_zones() -> void:
	if not pressure_gauge or not click_zone_button:
		return
	
	# Vérifier chaque action et passer le temps restant
	var actions: Array[StringName] = [&"heal", &"dodge", &"attack"]
	for action in actions:
		var is_blocked := pressure_gauge.is_action_blocked(action)
		var time_remaining := pressure_gauge.get_action_block_remaining(action)
		click_zone_button.set_zone_blocked(action, is_blocked, time_remaining)


func _update_skill_cooldowns(delta: float) -> void:
	for skill_id in skill_cooldowns.keys():
		if skill_cooldowns[skill_id] > 0:
			skill_cooldowns[skill_id] -= delta
			
			# Mettre à jour l'affichage du bouton
			if skill_buttons.has(skill_id):
				var btn: Button = skill_buttons[skill_id]
				if skill_cooldowns[skill_id] <= 0:
					skill_cooldowns[skill_id] = 0
					btn.disabled = false
					btn.text = btn.get_meta("skill_data").icon + "\n" + btn.get_meta("skill_data").name
				else:
					btn.text = btn.get_meta("skill_data").icon + "\n%.1fs" % skill_cooldowns[skill_id]


func _update_hp_displays() -> void:
	# Hero HP
	if hero and hero.base_stats:
		hero_hp_bar.max_value = hero.base_stats.max_hp
		hero_hp_bar.value = hero.current_hp
		
		# Changer la couleur de la barre selon le pourcentage
		var hp_ratio := float(hero.current_hp) / float(hero.base_stats.max_hp)
		var fill_style: StyleBoxFlat = hero_hp_bar.get_theme_stylebox("fill")
		if fill_style:
			if hp_ratio <= 0.25:
				fill_style.bg_color = Color(0.9, 0.2, 0.2)  # Rouge critique
			elif hp_ratio <= 0.5:
				fill_style.bg_color = Color(0.9, 0.6, 0.2)  # Orange warning
			else:
				fill_style.bg_color = Color(0.2, 0.9, 0.3)  # Vert normal
		
		# Update hero HP bar above sprite
		var hp_fill: ColorRect = hero.get_node_or_null("HeroVisual/HPFill")
		if hp_fill:
			hp_fill.size.x = 78 * hp_ratio
			# Même logique de couleur
			if hp_ratio <= 0.25:
				hp_fill.color = Color(0.9, 0.2, 0.2)
			elif hp_ratio <= 0.5:
				hp_fill.color = Color(0.9, 0.6, 0.2)
			else:
				hp_fill.color = Color(0.2, 0.9, 0.3)
	
	# Enemy HP total
	var total_hp := 0
	var total_max := 0
	for enemy in active_enemies:
		if is_instance_valid(enemy) and enemy.is_alive and enemy.base_stats:
			total_hp += enemy.current_hp
			total_max += enemy.base_stats.max_hp
	
	enemy_hp_bar.max_value = maxi(total_max, 1)
	enemy_hp_bar.value = total_hp


func _update_punishment_display() -> void:
	if pressure_gauge.is_punished:
		punishment_timer_label.text = "%.1fs" % pressure_gauge.get_punishment_remaining()
	else:
		punishment_timer_label.text = ""
	
	# Mettre à jour manuellement les barres de pression (au cas où le signal rate)
	for action_type in [&"heal", &"dodge", &"attack"]:
		var value: float = pressure_gauge.get_pressure(action_type)
		if pressure_bars.has(action_type):
			pressure_bars[action_type].value = value


func _update_currency_display() -> void:
	if SaveManager:
		currency_label.text = "💰 %d SC" % SaveManager.get_currency()


func _update_enemy_count() -> void:
	var enemies_label: Label = hud_layer.get_node_or_null("HUDRoot/TopBar/HBoxContainer/VBoxContainer2/EnemiesRemainingLabel")
	if not enemies_label:
		# Chercher par nom alternatif
		for child in hud_layer.get_node("HUDRoot/TopBar").get_child(0).get_children():
			if child is VBoxContainer:
				var label: Label = child.get_node_or_null("EnemiesRemainingLabel")
				if label:
					enemies_label = label
					break
	
	if enemies_label:
		var alive_count := 0
		for enemy in active_enemies:
			if is_instance_valid(enemy) and enemy.is_alive:
				alive_count += 1
		enemies_label.text = "👾 x%d remaining" % alive_count


# ==================== CALLBACKS ====================

func _on_player_action(action: StringName, success: bool) -> void:
	if success:
		var pos := Vector2(360, 600)
		match action:
			&"heal":
				_show_floating_text("💚 HEAL", pos, Color(0.3, 0.9, 1.0), 22)
				_flash_entity(hero, Color(0.3, 1.0, 0.5, 0.6))
			&"boost":
				_show_floating_text("⚡ BOOST!", pos, Color(1.0, 0.8, 0.2), 22)
				_flash_entity(hero, Color(1.0, 0.9, 0.3, 0.6))
			&"attack":
				_show_floating_text("⚔️ ATK", pos, Color(1.0, 0.4, 0.3), 22)
	else:
		# Action refusée (pression trop haute)
		_show_floating_text("❌ BLOCKED", Vector2(360, 620), Color(0.7, 0.3, 0.3), 16)


func _on_critical_hit(damage: int) -> void:
	_show_floating_text("CRIT! %d" % damage, Vector2(500, 350), Color(1.0, 0.8, 0.0), 32)


func _on_dodge_success() -> void:
	_show_floating_text("DODGE!", Vector2(150, 350), Color(0.5, 0.8, 1.0), 28)
	_flash_entity(hero, Color(0.5, 0.8, 1.0, 0.8))


func _on_hero_healed(amount: int) -> void:
	_show_floating_text("+%d" % amount, Vector2(120, 380), Color(0.3, 1.0, 0.5), 24)


func _on_hero_damaged(amount: int, is_crit: bool) -> void:
	_flash_entity(hero, Color(1.0, 0.3, 0.3))
	var text := "-%d" % amount
	if is_crit:
		text += "!"
	_show_floating_text(text, Vector2(120, 400), Color(1.0, 0.3, 0.3), 20)


func _on_enemy_damaged(amount: int, is_crit: bool, enemy: BaseEnemy) -> void:
	if not is_instance_valid(enemy):
		return
	
	_flash_entity(enemy, Color(1.0, 1.0, 1.0))
	
	var pos := enemy.global_position + Vector2(480, 280)
	var text := "-%d" % amount
	var color := Color(1.0, 1.0, 1.0)
	if is_crit:
		text = "CRIT -%d" % amount
		color = Color(1.0, 0.8, 0.0)
	_show_floating_text(text, pos, color, 18)
	
	# Update enemy HP bar
	var hp_fill: ColorRect = enemy.get_node_or_null("EnemyVisual/HPFill")
	if hp_fill and enemy.base_stats:
		var ratio := float(enemy.current_hp) / float(enemy.base_stats.max_hp)
		hp_fill.size.x = 58 * ratio


func _on_enemy_hp_changed(_current: int, _max_hp: int, enemy: BaseEnemy) -> void:
	if not is_instance_valid(enemy):
		return
	var hp_fill: ColorRect = enemy.get_node_or_null("EnemyVisual/HPFill")
	if hp_fill and enemy.base_stats:
		var ratio := float(enemy.current_hp) / float(enemy.base_stats.max_hp)
		hp_fill.size.x = 58 * ratio


func _on_enemy_died(enemy: BaseEnemy) -> void:
	active_enemies.erase(enemy)
	
	# Animation de mort
	var visual: Control = enemy.get_node_or_null("EnemyVisual")
	if visual:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(visual, "modulate:a", 0.0, 0.4)
		tween.tween_property(visual, "scale", Vector2(1.3, 0.3), 0.4)
		tween.chain().tween_callback(enemy.queue_free)
	
	# Récompense basée sur la vague
	var reward := ENEMY_KILL_REWARD + (current_wave * 2)
	SaveManager.add_currency(reward)
	_show_floating_text("+%d SC" % reward, enemy.global_position + Vector2(480, 300), Color(1.0, 0.85, 0.3), 18)
	
	# Vérifier si vague terminée
	if active_enemies.is_empty():
		_on_wave_cleared()


func _on_wave_cleared() -> void:
	# Bonus de vague
	SaveManager.add_currency(WAVE_CLEAR_BONUS)
	_show_floating_text("WAVE CLEAR! +%d SC" % WAVE_CLEAR_BONUS, Vector2(200, 350), Color(0.3, 1.0, 0.5), 28)
	
	current_wave += 1
	if current_wave <= total_waves:
		await get_tree().create_timer(1.5).timeout
		_show_floating_text("⚔️ WAVE %d ⚔️" % current_wave, Vector2(250, 400), Color.WHITE, 36)
		await get_tree().create_timer(0.8).timeout
		_spawn_wave()
		# Redémarrer le combat pour la nouvelle vague
		state_machine.start_combat()
	else:
		# Toutes les vagues terminées - VICTOIRE!
		state_machine.on_wave_cleared()


func _on_hero_hp_changed(_current: int, _max_hp: int) -> void:
	pass  # Géré dans _update_hp_displays


## Signal direct quand le héros meurt - déclenche la défaite
func _on_hero_died_signal() -> void:
	if not is_game_over:
		state_machine.on_hero_died()


func _on_state_changed(_old_state: CombatStateMachine.State, new_state: CombatStateMachine.State) -> void:
	# Note: On n'utilise plus l'état PUNISHED car l'overload est maintenant par action
	match new_state:
		CombatStateMachine.State.COMBAT, CombatStateMachine.State.BOSS_PHASE:
			click_zone_button.set_active(true)


func _on_pressure_changed(action_type: StringName, value: float) -> void:
	if pressure_bars.has(action_type):
		pressure_bars[action_type].value = value
		
		# Changer la couleur selon le niveau de pression
		var fill_style: StyleBoxFlat = pressure_bars[action_type].get_theme_stylebox("fill")
		if fill_style:
			if value >= 80:
				fill_style.bg_color = Color(1.0, 0.2, 0.2)  # Rouge danger
			elif value >= 60:
				fill_style.bg_color = Color(1.0, 0.6, 0.2)  # Orange warning
			elif value >= 40:
				fill_style.bg_color = Color(1.0, 0.9, 0.3)  # Jaune
			else:
				# Couleur normale selon l'action
				match action_type:
					&"heal":
						fill_style.bg_color = Color(0.3, 0.8, 0.5)
					&"dodge":
						fill_style.bg_color = Color(0.6, 0.4, 0.9)
					&"attack":
						fill_style.bg_color = Color(0.9, 0.4, 0.3)


func _on_punishment_started(_duration: float) -> void:
	# Récupérer le type d'action bloquée
	var overload_type := pressure_gauge.get_overload_type()
	var action_name := str(overload_type).to_upper()
	
	# Afficher un message indiquant quelle action est bloquée
	var color := Color(0.9, 0.3, 0.3)
	match overload_type:
		&"heal":
			color = Color(0.2, 0.8, 0.5)
		&"dodge":
			color = Color(0.6, 0.4, 0.9)
		&"attack":
			color = Color(0.9, 0.3, 0.3)
	
	_show_floating_text("⚠️ %s OVERLOAD!" % action_name, Vector2(200, 400), color, 24)
	
	# Animation légère de l'overlay (moins punitive visuellement)
	var tween := create_tween()
	tween.tween_property(punishment_overlay, "color:a", 0.3, 0.2)
	tween.tween_property(punishment_overlay, "color:a", 0.0, 0.5)


func _on_punishment_ended() -> void:
	# Les actions individuelles se débloquent automatiquement
	# Réactiver la zone de clic si tout est débloqué
	if not pressure_gauge.is_punished:
		click_zone_button.set_active(true)


func _on_victory() -> void:
	is_game_over = true
	_show_floating_text("🎉 VICTORY! 🎉", Vector2(200, 300), Color(1.0, 0.85, 0.3), 48)
	SaveManager.add_currency(VICTORY_BONUS)
	
	# Afficher l'écran de victoire
	await get_tree().create_timer(1.0).timeout
	_show_game_over_screen(true)


func _on_defeat() -> void:
	is_game_over = true
	_show_floating_text("💀 DEFEAT", Vector2(250, 300), Color(0.8, 0.2, 0.2), 48)
	
	# Afficher l'écran de game over après un délai
	await get_tree().create_timer(1.5).timeout
	_show_game_over_screen(false)


# ==================== GAME OVER / VICTORY SCREEN ====================

func _show_game_over_screen(is_victory: bool) -> void:
	# Créer un CenterContainer pour bien centrer le panel
	var center := CenterContainer.new()
	center.name = "GameOverCenter"
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_STOP
	center.z_index = 100  # Assurer qu'il est au-dessus de tout
	hud_layer.add_child(center)
	
	# Déplacer tout en haut de la hiérarchie du hud_layer
	hud_layer.move_child(center, -1)
	
	# Background semi-transparent
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	center.add_child(bg)
	bg.z_index = -1
	
	game_over_panel = PanelContainer.new()
	game_over_panel.name = "GameOverPanel"
	game_over_panel.custom_minimum_size = Vector2(380, 420)
	
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.1, 0.98)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color(1.0, 0.85, 0.3) if is_victory else Color(0.8, 0.2, 0.2)
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.corner_radius_bottom_right = 20
	game_over_panel.add_theme_stylebox_override("panel", panel_style)
	
	center.add_child(game_over_panel)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 25)
	margin.add_theme_constant_override("margin_right", 25)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	game_over_panel.add_child(margin)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	
	# Titre
	var title := Label.new()
	title.text = "VICTORY!" if is_victory else "DEFEAT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3) if is_victory else Color(0.9, 0.3, 0.3))
	vbox.add_child(title)
	
	# Séparateur
	var sep1 := HSeparator.new()
	vbox.add_child(sep1)
	
	# Stats du combat
	stats_container = VBoxContainer.new()
	stats_container.add_theme_constant_override("separation", 6)
	vbox.add_child(stats_container)
	
	_add_stat_line("Planet", PLANET_COLORS.get(current_planet, PLANET_COLORS[0]).name)
	_add_stat_line("Waves", "%d / %d" % [current_wave - 1 if not is_victory else total_waves, total_waves])
	_add_stat_line("HP", "%d / %d" % [maxi(0, hero.current_hp), hero.base_stats.max_hp])
	_add_stat_line("StarCoins", "%d" % SaveManager.get_currency())
	
	# Message
	var message := Label.new()
	message.text = "Ready for the next planet!" if is_victory else "You keep your StarCoins!"
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 13)
	message.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(message)
	
	# Séparateur
	var sep2 := HSeparator.new()
	vbox.add_child(sep2)
	
	# Bouton RETRY - Simple Button
	var retry_btn := Button.new()
	retry_btn.text = "RETRY"
	retry_btn.custom_minimum_size = Vector2(200, 55)
	retry_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	retry_btn.add_theme_font_size_override("font_size", 20)
	retry_btn.pressed.connect(_on_retry_pressed)
	vbox.add_child(retry_btn)
	
	# Bouton NEXT si victoire
	if is_victory and current_planet < 3:
		var next_btn := Button.new()
		next_btn.text = "NEXT PLANET"
		next_btn.custom_minimum_size = Vector2(200, 55)
		next_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		next_btn.add_theme_font_size_override("font_size", 20)
		next_btn.pressed.connect(_on_next_planet_pressed)
		vbox.add_child(next_btn)
	
	# Bouton MENU - Retour au menu principal
	var menu_btn := Button.new()
	menu_btn.text = "MENU"
	menu_btn.custom_minimum_size = Vector2(200, 55)
	menu_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu_btn.add_theme_font_size_override("font_size", 20)
	menu_btn.pressed.connect(_on_menu_pressed)
	vbox.add_child(menu_btn)
	
	print("[GameOver] Screen created, buttons should be clickable")


func _add_stat_line(label_text: String, value_text: String) -> void:
	var hbox := HBoxContainer.new()
	stats_container.add_child(hbox)
	
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	hbox.add_child(label)
	
	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.add_theme_font_size_override("font_size", 16)
	value.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(value)


func _create_styled_button(text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(130, 50)
	
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = color.darkened(0.3)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = color
	normal_style.corner_radius_top_left = 10
	normal_style.corner_radius_top_right = 10
	normal_style.corner_radius_bottom_left = 10
	normal_style.corner_radius_bottom_right = 10
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = color.darkened(0.1)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style := normal_style.duplicate()
	pressed_style.bg_color = color
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)
	
	return btn


func _on_retry_pressed() -> void:
	print("[RETRY] Button pressed!")
	# Perdre tous les starcoins gagnés lors de cette partie
	SaveManager.reset_currency()
	get_tree().reload_current_scene()


func _on_next_planet_pressed() -> void:
	print("[NEXT] Button pressed!")
	current_planet = mini(current_planet + 1, 3)
	if SaveManager:
		SaveManager.advance_planet()
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	print("[MENU] Button pressed!")
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
