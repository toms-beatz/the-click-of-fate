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
var coins_earned_this_run: int = 0  # Coins gagnés pendant cette partie

## Game Over UI
var game_over_panel: PanelContainer
var stats_container: VBoxContainer

## Pause Menu
var pause_panel: Control
var is_paused: bool = false

## Boss System
var is_boss_wave: bool = false
var current_boss: BaseEnemy = null
var boss_visual: Control = null

## Cinematic System
var cinematic_layer: CanvasLayer
var is_showing_cinematic: bool = true
var cinematic_slide_index: int = 0

## Hero Sprite System
var hero_sprite: TextureRect
var hero_textures: Dictionary = {}
enum HeroPose { IDLE, READY, DODGE, ATTACK_1, ATTACK_2, ATTACK_3, SPECIAL }
var current_hero_pose: HeroPose = HeroPose.IDLE

## Enemy Sprite System - sprites par planète
const ENEMY_SPRITES := {
	1: {  # Venus (index 1)
		"standing": "res://assets/sprites/enemies/venus-sprites-standing.png",
		"shooting": "res://assets/sprites/enemies/venus-sprites-shooting.png",
		"hurt": "res://assets/sprites/enemies/venus-sprites-on-knee.png"
	},
	2: {  # Mars (index 2)
		"standing": "res://assets/sprites/enemies/mars-sprites-standing.png",
		"shooting": "res://assets/sprites/enemies/mars-sprites-shooting.png",
		"hurt": "res://assets/sprites/enemies/mars-sprites-before-shooting.png"
	},
	3: {  # Earth (index 3)
		"standing": "res://assets/sprites/enemies/earth-sprites-standing.png",
		"shooting": "res://assets/sprites/enemies/earth-sprites-shooting.png",
		"hurt": "res://assets/sprites/enemies/earth-sprites-on-knee.png"
	}
}

## Mini-boss sprites
const MINIBOSS_SPRITES := {
	"idle": "res://assets/sprites/enemies/mini-boss.png",
	"screaming": "res://assets/sprites/enemies/mini-boss-screaming.png",
	"screaming2": "res://assets/sprites/enemies/mini-boss-screaming-2.png",
	"fireball": "res://assets/sprites/enemies/mini-boss-fireball.png",
	"other_side": "res://assets/sprites/enemies/mini-boss-other-side.png"
}

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

## Scaling de puissance du joueur par planète complétée
## Le héros gagne de la puissance en progressant
const HERO_POWER_PER_PLANET := {
	-1: {"hp_mult": 1.0, "atk_mult": 1.0, "power": 100},     # Aucune planète terminée (débutant)
	0:  {"hp_mult": 1.25, "atk_mult": 1.2, "power": 150},   # Mercury terminée
	1:  {"hp_mult": 1.5, "atk_mult": 1.4, "power": 200},    # Venus terminée  
	2:  {"hp_mult": 1.8, "atk_mult": 1.7, "power": 280},    # Mars terminée
	3:  {"hp_mult": 2.2, "atk_mult": 2.0, "power": 400},    # Earth terminée (max)
}

## Puissance recommandée par planète (pour info joueur)
const PLANET_RECOMMENDED_POWER := {
	0: 100,   # Mercury - niveau débutant
	1: 140,   # Venus - après Mercury
	2: 190,   # Mars - après Venus
	3: 270,   # Earth - après Mars
}

## Boss par planète (après les 5 vagues)
const PLANET_BOSSES := {
	0: {"name": "Mercury Guardian", "hp": 400, "atk": 20, "speed": 1.0, "color": Color(1.0, 0.5, 0.2), "emoji": "🛡️", "special": "shield"},
	1: {"name": "Venus Queen", "hp": 550, "atk": 25, "speed": 0.9, "color": Color(0.8, 0.9, 0.2), "emoji": "👑", "special": "poison"},
	2: {"name": "Mars Warlord", "hp": 700, "atk": 30, "speed": 0.8, "color": Color(0.9, 0.4, 0.3), "emoji": "⚔️", "special": "rage"},
	3: {"name": "DR. MORTIS", "hp": 1500, "atk": 40, "speed": 0.6, "color": Color(0.6, 0.2, 0.8), "emoji": "💀", "special": "final"},  # BOSS FINAL!
}

## Cinématique de fin (après avoir battu Dr. Mortis)
const ENDING_CINEMATIC := [
	{"text": "It's over. Dr. Mortis lies defeated at my feet.", "emoji": "💀"},
	{"text": "But as life fades from his eyes, he laughs...", "emoji": "😈"},
	{"text": "'You fool... I was just ONE of them. The Council... they ordered it all.'", "emoji": "🗣️"},
	{"text": "A Council? More humans responsible for my family's death?", "emoji": "😠"},
	{"text": "'They're everywhere... hiding in the outer colonies... you'll never find them all...'", "emoji": "🌌"},
	{"text": "I WILL find them. Every. Single. One.", "emoji": "🔥"},
	{"text": "My journey is not over. It has only just begun.", "emoji": "🚀"},
	{"text": "TO BE CONTINUED...", "emoji": "⏳"},
]

## Cinématiques par planète
const PLANET_CINEMATICS := {
	0: [  # Mercury
		{"text": "My name is Zyx-7. I had a family once... a beautiful colony on the outer rim.", "emoji": "👽"},
		{"text": "Until HE came. Dr. Mortis. A human scientist who destroyed everything I loved.", "emoji": "💔"},
		{"text": "Now I hunt him across the stars. Mercury is my first stop...", "emoji": "🚀"},
	],
	1: [  # Venus
		{"text": "Mercury's colony knew nothing. But they mentioned Venus...", "emoji": "🔍"},
		{"text": "Dr. Mortis has been building something here. Toxic experiments.", "emoji": "☠️"},
		{"text": "I will tear through his creations until I find him.", "emoji": "😤"},
	],
	2: [  # Mars
		{"text": "Venus was another dead end. But I found records... Mars.", "emoji": "📜"},
		{"text": "His main research facility. Where he perfected his weapons.", "emoji": "🔬"},
		{"text": "The weapons he used on my family. He WILL pay.", "emoji": "🔥"},
	],
	3: [  # Earth
		{"text": "This is it. Earth. His homeworld. His fortress.", "emoji": "🌍"},
		{"text": "Dr. Mortis is here. I can feel it. After all these years...", "emoji": "👁️"},
		{"text": "Today, my family will be avenged. Today, HE DIES.", "emoji": "💀"},
	],
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
		# Marquer le début de la session pour pouvoir restore on retry
		SaveManager.start_session()
		coins_earned_this_run = 0
	
	_setup_background()
	_setup_combat_zone()
	_setup_systems()
	_setup_hero()
	_setup_hud()
	_setup_effects_layer()
	_setup_pause_menu()
	_connect_signals()
	
	# Afficher la cinématique avant le combat
	_show_cinematic()


func _input(event: InputEvent) -> void:
	# Gestion de la touche pause (Escape ou bouton retour Android)
	if event.is_action_pressed("ui_cancel") and not is_game_over and not is_showing_cinematic:
		_toggle_pause()


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
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	# Container pour le héros (côté gauche - 12% de la largeur)
	hero_container = Control.new()
	hero_container.name = "HeroContainer"
	hero_container.position = Vector2(viewport_size.x * 0.12, viewport_size.y * 0.35)
	combat_zone.add_child(hero_container)
	
	# Container pour les ennemis (côté droit - 70% de la largeur)
	enemy_container = Control.new()
	enemy_container.name = "EnemyContainer"
	enemy_container.position = Vector2(viewport_size.x * 0.70, viewport_size.y * 0.31)
	combat_zone.add_child(enemy_container)
	
	# Sol/Platform visuel (couvre toute la largeur)
	var ground := ColorRect.new()
	ground.name = "Ground"
	ground.color = Color(0.1, 0.08, 0.06, 0.8)
	ground.size = Vector2(viewport_size.x, viewport_size.y * 0.12)
	ground.position = Vector2(0, viewport_size.y * 0.55)
	combat_zone.add_child(ground)
	
	# Ligne de séparation combat (au centre)
	var battle_line := ColorRect.new()
	battle_line.name = "BattleLine"
	battle_line.color = PLANET_COLORS.get(current_planet, PLANET_COLORS[0]).accent
	battle_line.color.a = 0.3
	battle_line.size = Vector2(2, viewport_size.y * 0.23)
	battle_line.position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.31)
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
	
	# Calculer la puissance du héros basée sur la progression
	var highest_completed: int = -1
	if SaveManager:
		highest_completed = SaveManager.get_highest_planet_completed()
	
	var power_data: Dictionary = HERO_POWER_PER_PLANET.get(highest_completed, HERO_POWER_PER_PLANET[-1])
	var hp_mult: float = power_data.hp_mult
	var atk_mult: float = power_data.atk_mult
	
	var hero_stats := EntityStats.new()
	hero_stats.display_name = "Alien Hero"
	hero_stats.max_hp = int(HERO_BASE_HP * hp_mult)
	hero_stats.attack = int(HERO_BASE_ATTACK * atk_mult)
	hero_stats.attack_speed = HERO_ATTACK_SPEED
	hero_stats.crit_chance = HERO_CRIT_CHANCE
	hero_stats.dodge_chance = HERO_DODGE_CHANCE
	hero.base_stats = hero_stats
	
	print("[GameCombat] Hero power level: %d (completed planet %d) - HP: %d, ATK: %d" % [power_data.power, highest_completed, hero_stats.max_hp, hero_stats.attack])
	
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
	
	# Sprite principal du héros (taille relative au viewport)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var sprite_width: int = mini(150, int(viewport_size.x * 0.20))  # Max 20% de la largeur
	var sprite_height := sprite_width * 1.2  # Ratio 1.2 pour le héros
	
	hero_sprite = TextureRect.new()
	hero_sprite.name = "HeroSprite"
	hero_sprite.texture = hero_textures.get(HeroPose.IDLE)
	hero_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hero_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hero_sprite.custom_minimum_size = Vector2(sprite_width, sprite_height)
	hero_sprite.size = Vector2(sprite_width, sprite_height)
	hero_sprite.position = Vector2(float(-sprite_width) * 0.5, float(-sprite_height))
	visual.add_child(hero_sprite)
	
	# Barre de vie au-dessus du héros
	var hp_bar_width: int = int(sprite_width * 0.65)
	var hp_bg := ColorRect.new()
	hp_bg.name = "HPBackground"
	hp_bg.color = Color(0.1, 0.1, 0.1, 0.8)
	hp_bg.size = Vector2(hp_bar_width, 12)
	hp_bg.position = Vector2(float(-hp_bar_width) * 0.5, float(-sprite_height) - 15)
	visual.add_child(hp_bg)
	
	var hp_fill := ColorRect.new()
	hp_fill.name = "HPFill"
	hp_fill.color = Color(0.2, 0.9, 0.3)
	hp_fill.size = Vector2(hp_bar_width - 2, 10)
	hp_fill.position = Vector2(float(-hp_bar_width) * 0.5 + 1, float(-sprite_height) - 14)
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
	top_bar.custom_minimum_size.y = 120  # Réduit de 140
	top_bar.add_theme_constant_override("margin_left", 10)
	top_bar.add_theme_constant_override("margin_right", 10)
	top_bar.add_theme_constant_override("margin_top", 25)  # Réduit pour safe area
	parent.add_child(top_bar)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)  # Réduit
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
	
	# Stats du héros sous la barre de vie (utilise les vraies stats calculées)
	var hero_stats_label := Label.new()
	hero_stats_label.name = "HeroStatsLabel"
	var real_atk: int = hero.base_stats.attack if hero and hero.base_stats else HERO_BASE_ATTACK
	hero_stats_label.text = "ATK: %d | SPD: %.1f | CRIT: %d%%" % [real_atk, HERO_ATTACK_SPEED, int(HERO_CRIT_CHANCE * 100)]
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
	
	# Affichage puissance recommandée vs puissance du joueur
	var recommended_power: int = PLANET_RECOMMENDED_POWER.get(current_planet, 100)
	var highest_completed: int = -1
	if SaveManager:
		highest_completed = SaveManager.get_highest_planet_completed()
	var player_power: int = HERO_POWER_PER_PLANET.get(highest_completed, HERO_POWER_PER_PLANET[-1]).power
	
	var power_label := Label.new()
	power_label.name = "PowerLabel"
	var power_color: Color
	if player_power >= recommended_power:
		power_color = Color(0.3, 1.0, 0.5)  # Vert - bon niveau
	elif player_power >= recommended_power * 0.8:
		power_color = Color(1.0, 0.9, 0.3)  # Jaune - faisable
	else:
		power_color = Color(1.0, 0.4, 0.3)  # Rouge - difficile
	power_label.text = "⚡ %d / %d" % [player_power, recommended_power]
	power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	power_label.add_theme_font_size_override("font_size", 12)
	power_label.add_theme_color_override("font_color", power_color)
	center_section.add_child(power_label)
	
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
	
	# Bouton Pause (coin supérieur droit)
	var pause_btn := Button.new()
	pause_btn.name = "PauseButton"
	pause_btn.text = "⏸️"
	pause_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	pause_btn.position = Vector2(-50, 5)
	pause_btn.custom_minimum_size = Vector2(40, 40)
	
	var pause_style := StyleBoxFlat.new()
	pause_style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
	pause_style.border_color = Color(0.5, 0.5, 0.6)
	pause_style.set_border_width_all(2)
	pause_style.set_corner_radius_all(8)
	pause_btn.add_theme_stylebox_override("normal", pause_style)
	pause_btn.add_theme_font_size_override("font_size", 20)
	pause_btn.pressed.connect(_toggle_pause)
	parent.add_child(pause_btn)


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
	bottom_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_container.anchor_top = 0.78  # Commence à 78% de l'écran (adapté à la hauteur)
	bottom_container.add_theme_constant_override("separation", 10)
	parent.add_child(bottom_container)
	
	# Barre de skills
	var skill_bar := _create_skill_bar()
	bottom_container.add_child(skill_bar)
	
	# Spacer flexible
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_container.add_child(spacer)
	
	# Bouton Click Zone tripartite
	var click_margin := MarginContainer.new()
	click_margin.add_theme_constant_override("margin_left", 15)
	click_margin.add_theme_constant_override("margin_right", 15)
	click_margin.add_theme_constant_override("margin_bottom", 20)
	bottom_container.add_child(click_margin)
	
	click_zone_button = ClickZoneButton.new()
	click_zone_button.name = "ClickZoneButton"
	click_zone_button.custom_minimum_size = Vector2(0, 110)  # Hauteur minimale, largeur flexible
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
	btn.custom_minimum_size = Vector2(65, 70)  # Plus compact
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
		var viewport_size: Vector2 = get_viewport().get_visible_rect().size
		_show_floating_text("COOLDOWN!", Vector2(viewport_size.x * 0.5 - 50, viewport_size.y * 0.70), Color(0.7, 0.7, 0.7), 18)
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
	var hero_pos := hero_container.position + Vector2(50, -100)
	_show_floating_text("💚 FULL HEAL! +%d" % healed, hero_pos, Color(0.3, 1.0, 0.5), 32)
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
	var hero_pos := hero_container.position + Vector2(50, -100)
	_show_floating_text("💥 CRIT SURGE! +50%", hero_pos, Color(1.0, 0.7, 0.2), 32)
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
	var hero_pos := hero_container.position + Vector2(50, -100)
	_show_floating_text("🛡️ INVINCIBLE!", hero_pos, Color(0.6, 0.5, 1.0), 32)
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
	
	_show_floating_text("☄️ NOVA BLAST! -%d" % total_damage, enemy_container.position + Vector2(0, -100), Color(1.0, 0.3, 0.2), 36)


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
	if is_boss_wave:
		wave_label.text = "⚠️ BOSS ⚠️"
		wave_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	else:
		wave_label.text = "WAVE %d / %d" % [current_wave, total_waves]
		wave_label.add_theme_color_override("font_color", Color.WHITE)
	
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
	
	# Position relative à l'écran
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var enemy_spacing: float = viewport_size.x * 0.10  # 10% de la largeur entre chaque ennemi
	enemy.position = Vector2(index * enemy_spacing, index * 35 - 35)
	enemy_container.add_child(enemy)
	
	# Créer le visuel de l'ennemi
	var visual := _create_enemy_visual(enemy)
	enemy_visuals[enemy] = visual
	
	# Connecter les signaux
	enemy.died.connect(_on_enemy_died.bind(enemy))
	enemy.hp_changed.connect(_on_enemy_hp_changed.bind(enemy))
	enemy.damaged.connect(_on_enemy_damaged.bind(enemy))
	enemy.attacked.connect(_on_enemy_attacked.bind(enemy))
	
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
	
	# Taille relative au viewport
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var body_width: int = mini(50, int(viewport_size.x * 0.07))
	var body_height: int = int(body_width * 1.4)
	var sprite_size := Vector2(body_width * 2, body_height * 2)
	
	# Vérifier si on a un sprite pour cette planète
	var enemy_sprite_data: Dictionary = ENEMY_SPRITES.get(current_planet, {})
	var sprite_path: String = enemy_sprite_data.get("standing", "")
	
	if ResourceLoader.exists(sprite_path):
		# Utiliser le sprite
		var sprite := TextureRect.new()
		sprite.name = "EnemySprite"
		sprite.texture = load(sprite_path)
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite.custom_minimum_size = sprite_size
		sprite.size = sprite_size
		sprite.position = Vector2(-sprite_size.x / 2, -sprite_size.y)
		visual.add_child(sprite)
		
		# Stocker les autres textures pour les animations
		enemy.set_meta("sprite_standing", sprite_path)
		enemy.set_meta("sprite_shooting", enemy_sprite_data.get("shooting", sprite_path))
		enemy.set_meta("sprite_hurt", enemy_sprite_data.get("hurt", sprite_path))
	else:
		# Fallback: ColorRect (Mercury n'a pas de sprite)
		# Corps
		var body := ColorRect.new()
		body.color = accent.darkened(0.3)
		body.size = Vector2(body_width, body_height)
		body.position = Vector2(-body_width * 0.5, -body_height)
		visual.add_child(body)
		
		# Tête
		var head_size := body_width * 0.8
		var head := ColorRect.new()
		head.color = accent
		head.size = Vector2(head_size, head_size)
		head.position = Vector2(-head_size / 2, -body_height - head_size)
		visual.add_child(head)
		
		# Oeil unique (méchant)
		var eye := ColorRect.new()
		eye.color = Color.BLACK
		eye.size = Vector2(head_size * 0.35, head_size * 0.2)
		eye.position = Vector2(-head_size * 0.18, -body_height - head_size * 0.6)
		visual.add_child(eye)
	
	# Barre de vie (toujours présente)
	var hp_bar_width := body_width * 1.2
	var hp_bg := ColorRect.new()
	hp_bg.name = "HPBackground"
	hp_bg.color = Color(0.1, 0.1, 0.1, 0.8)
	hp_bg.size = Vector2(hp_bar_width, 8)
	hp_bg.position = Vector2(-hp_bar_width / 2, -sprite_size.y - 15)
	visual.add_child(hp_bg)
	
	var hp_fill := ColorRect.new()
	hp_fill.name = "HPFill"
	hp_fill.color = Color(0.9, 0.2, 0.2)
	hp_fill.size = Vector2(hp_bar_width - 2, 6)
	hp_fill.position = Vector2(-hp_bar_width / 2 + 1, -sprite_size.y - 14)
	visual.add_child(hp_fill)
	
	return visual


# ==================== VISUAL EFFECTS ====================

## Positions relatives pour les floating texts
func _get_relative_pos(x_percent: float, y_percent: float) -> Vector2:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	return Vector2(viewport_size.x * x_percent, viewport_size.y * y_percent)

func _show_floating_text(text: String, pos: Vector2, color: Color, size: int = 24) -> void:
	var label := Label.new()
	label.text = text
	# Adapter la taille du texte au viewport
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var adjusted_size: int = int(float(size) * minf(1.0, viewport_size.x / 720.0))
	label.add_theme_font_size_override("font_size", adjusted_size)
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
		var hero_pos := hero_container.position + Vector2(50, -50)
		var enemy_pos := enemy_container.position + Vector2(0, -80)
		match action:
			&"heal":
				_show_floating_text("💚 HEAL", hero_pos, Color(0.3, 0.9, 1.0), 22)
				_flash_entity(hero, Color(0.3, 1.0, 0.5, 0.6))
			&"boost":
				_show_floating_text("🛡️ DODGE!", hero_pos, Color(1.0, 0.8, 0.2), 22)
				_flash_entity(hero, Color(1.0, 0.9, 0.3, 0.6))
			&"attack":
				_show_floating_text("⚔️ ATK", enemy_pos, Color(1.0, 0.4, 0.3), 22)
	else:
		# Action refusée (pression trop haute)
		var hero_pos := hero_container.position + Vector2(50, 0)
		_show_floating_text("❌ BLOCKED", hero_pos, Color(0.7, 0.3, 0.3), 16)


func _on_critical_hit(damage: int) -> void:
	var enemy_pos := enemy_container.position + Vector2(0, -50)
	_show_floating_text("CRIT! %d" % damage, enemy_pos, Color(1.0, 0.8, 0.0), 32)


func _on_dodge_success() -> void:
	var hero_pos := hero_container.position + Vector2(50, -50)
	_show_floating_text("DODGE!", hero_pos, Color(0.5, 0.8, 1.0), 28)
	_flash_entity(hero, Color(0.5, 0.8, 1.0, 0.8))


func _on_hero_healed(amount: int) -> void:
	var hero_pos := hero_container.position + Vector2(50, -80)
	_show_floating_text("+%d" % amount, hero_pos, Color(0.3, 1.0, 0.5), 24)


func _on_hero_damaged(amount: int, is_crit: bool) -> void:
	_flash_entity(hero, Color(1.0, 0.3, 0.3))
	var hero_pos := hero_container.position + Vector2(50, -30)
	var text := "-%d" % amount
	if is_crit:
		text += "!"
	_show_floating_text(text, hero_pos, Color(1.0, 0.3, 0.3), 20)


func _on_enemy_damaged(amount: int, is_crit: bool, enemy: BaseEnemy) -> void:
	if not is_instance_valid(enemy):
		return
	
	_flash_entity(enemy, Color(1.0, 1.0, 1.0))
	
	# Changer en sprite "hurt"
	_set_enemy_sprite_pose(enemy, "hurt")
	# Revenir à standing après un court délai
	await get_tree().create_timer(0.2).timeout
	if is_instance_valid(enemy) and enemy.is_alive:
		_set_enemy_sprite_pose(enemy, "standing")
	
	# Position relative à l'ennemi dans le container
	var pos := enemy_container.position + enemy.position + Vector2(0, -100)
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


## Appelé quand un ennemi attaque - change son sprite en pose "shooting"
func _on_enemy_attacked(_target: BaseEntity, _damage: int, _is_crit: bool, enemy: BaseEnemy) -> void:
	if not is_instance_valid(enemy):
		return
	_set_enemy_sprite_pose(enemy, "shooting")
	# Revenir à la pose standing après un court délai
	await get_tree().create_timer(0.3).timeout
	if is_instance_valid(enemy) and enemy.is_alive:
		_set_enemy_sprite_pose(enemy, "standing")


## Change le sprite d'un ennemi selon sa pose
func _set_enemy_sprite_pose(enemy: BaseEnemy, pose: String) -> void:
	if not is_instance_valid(enemy):
		return
	
	var sprite: TextureRect = enemy.get_node_or_null("EnemyVisual/EnemySprite")
	if not sprite:
		return  # Pas de sprite (Mercury utilise ColorRect)
	
	var sprite_path: String = enemy.get_meta("sprite_" + pose, "")
	if sprite_path.is_empty() or not ResourceLoader.exists(sprite_path):
		return
	
	sprite.texture = load(sprite_path)


func _on_enemy_died(enemy: BaseEnemy) -> void:
	active_enemies.erase(enemy)
	
	# Changer en sprite "hurt" avant la mort
	_set_enemy_sprite_pose(enemy, "hurt")
	
	# Animation de mort améliorée
	var visual: Control = enemy.get_node_or_null("EnemyVisual")
	if visual:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(visual, "modulate:a", 0.0, 0.5)
		tween.tween_property(visual, "scale", Vector2(1.3, 0.3), 0.4)
		tween.tween_property(visual, "rotation", randf_range(-0.3, 0.3), 0.4)
		tween.chain().tween_callback(enemy.queue_free)
	
	# Récompense basée sur la vague
	var reward := ENEMY_KILL_REWARD + (current_wave * 2)
	coins_earned_this_run += reward
	SaveManager.add_currency(reward)
	var reward_pos := enemy_container.position + enemy.position + Vector2(0, -60)
	_show_floating_text("+%d SC" % reward, reward_pos, Color(1.0, 0.85, 0.3), 18)
	
	# Vérifier si vague terminée
	if active_enemies.is_empty():
		_on_wave_cleared()


func _on_wave_cleared() -> void:
	# Bonus de vague
	coins_earned_this_run += WAVE_CLEAR_BONUS
	SaveManager.add_currency(WAVE_CLEAR_BONUS)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var center_pos := Vector2(viewport_size.x * 0.5 - 80, viewport_size.y * 0.30)
	_show_floating_text("WAVE CLEAR! +%d SC" % WAVE_CLEAR_BONUS, center_pos, Color(0.3, 1.0, 0.5), 28)
	
	current_wave += 1
	if current_wave <= total_waves:
		await get_tree().create_timer(1.5).timeout
		_show_floating_text("⚔️ WAVE %d ⚔️" % current_wave, center_pos + Vector2(0, 30), Color.WHITE, 36)
		await get_tree().create_timer(0.8).timeout
		_spawn_wave()
		# Redémarrer le combat pour la nouvelle vague
		state_machine.start_combat()
	else:
		# Toutes les vagues terminées - BOSS TIME!
		print("[GameCombat] All waves cleared! Spawning boss...")
		await get_tree().create_timer(1.5).timeout
		_show_floating_text("⚠️ BOSS INCOMING! ⚠️", center_pos, Color(1.0, 0.3, 0.3), 36)
		await get_tree().create_timer(1.0).timeout
		_spawn_boss()
		state_machine.start_combat()


func _on_hero_hp_changed(_current: int, _max_hp: int) -> void:
	pass  # Géré dans _update_hp_displays


## Signal direct quand le héros meurt - déclenche la défaite
func _on_hero_died_signal() -> void:
	if not is_game_over:
		print("[GameCombat] Hero died! Triggering defeat...")
		_on_defeat()


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
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var center_pos := Vector2(viewport_size.x * 0.5 - 100, viewport_size.y * 0.32)
	_show_floating_text("⚠️ %s OVERLOAD!" % action_name, center_pos, color, 24)
	
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
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var center_pos := Vector2(viewport_size.x * 0.5 - 100, viewport_size.y * 0.25)
	_show_floating_text("🎉 VICTORY! 🎉", center_pos, Color(1.0, 0.85, 0.3), 48)
	
	# Bonus de victoire
	coins_earned_this_run += VICTORY_BONUS
	SaveManager.add_currency(VICTORY_BONUS)
	
	# Sauvegarder la progression - planète complétée!
	# Note: Les coins sont déjà sauvés, pas besoin de restore
	
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
	_add_stat_line("Waves", "%d / %d" % [current_wave if is_victory else current_wave - 1, total_waves])
	_add_stat_line("HP", "%d / %d" % [maxi(0, hero.current_hp), hero.base_stats.max_hp])
	_add_stat_line("Coins this run", "+%d SC" % coins_earned_this_run)
	_add_stat_line("Total StarCoins", "%d SC" % SaveManager.get_currency())
	
	# Message
	var message := Label.new()
	if is_victory:
		if current_planet < 3:
			message.text = "Ready for the next planet!"
		else:
			message.text = "🎉 YOU CONQUERED THE SOLAR SYSTEM! 🎉"
	else:
		message.text = "Coins lost: -%d SC (retry to try again)" % coins_earned_this_run
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 13)
	message.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(message)
	
	# Séparateur
	var sep2 := HSeparator.new()
	vbox.add_child(sep2)
	
	# Boutons selon le résultat
	if is_victory:
		# Bouton NEXT PLANET si pas la dernière planète
		if current_planet < 3:
			var next_btn := Button.new()
			next_btn.text = "NEXT PLANET →"
			next_btn.custom_minimum_size = Vector2(200, 55)
			next_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			next_btn.add_theme_font_size_override("font_size", 20)
			next_btn.pressed.connect(_on_next_planet_pressed)
			vbox.add_child(next_btn)
		
		# Bouton REPLAY pour rejouer cette planète
		var replay_btn := Button.new()
		replay_btn.text = "REPLAY PLANET"
		replay_btn.custom_minimum_size = Vector2(200, 55)
		replay_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		replay_btn.add_theme_font_size_override("font_size", 18)
		replay_btn.pressed.connect(_on_replay_pressed)
		vbox.add_child(replay_btn)
	else:
		# Bouton RETRY (perd les coins de cette run)
		var retry_btn := Button.new()
		retry_btn.text = "RETRY (lose %d SC)" % coins_earned_this_run
		retry_btn.custom_minimum_size = Vector2(250, 55)
		retry_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		retry_btn.add_theme_font_size_override("font_size", 18)
		retry_btn.pressed.connect(_on_retry_pressed)
		vbox.add_child(retry_btn)
	
	# Bouton MENU - Toujours disponible
	var menu_btn := Button.new()
	menu_btn.text = "MAIN MENU"
	menu_btn.custom_minimum_size = Vector2(200, 45)
	menu_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu_btn.add_theme_font_size_override("font_size", 16)
	menu_btn.pressed.connect(_on_menu_pressed)
	vbox.add_child(menu_btn)
	
	print("[GameOver] Screen created, coins earned: %d" % coins_earned_this_run)


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
	# Restaurer les coins qu'on avait AVANT de commencer cette partie
	SaveManager.restore_session_currency()
	get_tree().reload_current_scene()


func _on_replay_pressed() -> void:
	print("[REPLAY] Button pressed!")
	# Rejouer la même planète mais garder les coins (on a gagné!)
	# Juste recharger la scène sans changer de planète
	get_tree().reload_current_scene()


func _on_next_planet_pressed() -> void:
	print("[NEXT] Button pressed!")
	# Garder les coins gagnés (déjà sauvés)
	# Passer à la planète suivante
	if SaveManager:
		SaveManager.advance_planet()
	get_tree().reload_current_scene()


func _on_menu_pressed() -> void:
	print("[MENU] Button pressed!")
	# Retourner au menu principal
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


# ==================== PAUSE MENU ====================

func _setup_pause_menu() -> void:
	pause_panel = Control.new()
	pause_panel.name = "PausePanel"
	pause_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_panel.visible = false
	pause_panel.z_index = 150
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS  # Continue de fonctionner même en pause
	hud_layer.add_child(pause_panel)
	
	# Background semi-transparent
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_panel.add_child(bg)
	
	# Container centré
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_panel.add_child(center)
	
	# Panel principal
	var panel := PanelContainer.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)
	panel_style.border_color = Color(0.4, 0.6, 0.9)
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(15)
	panel_style.content_margin_left = 40
	panel_style.content_margin_right = 40
	panel_style.content_margin_top = 30
	panel_style.content_margin_bottom = 30
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	panel.add_child(vbox)
	
	# Titre
	var title := Label.new()
	title.text = "⏸️ PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	vbox.add_child(title)
	
	# Boutons
	var resume_btn := _create_pause_button("▶️ RESUME", Color(0.3, 0.8, 0.4))
	resume_btn.pressed.connect(_toggle_pause)
	vbox.add_child(resume_btn)
	
	var restart_btn := _create_pause_button("🔄 RESTART", Color(0.9, 0.7, 0.2))
	restart_btn.pressed.connect(_on_pause_restart)
	vbox.add_child(restart_btn)
	
	var menu_btn := _create_pause_button("🏠 MAIN MENU", Color(0.8, 0.4, 0.4))
	menu_btn.pressed.connect(_on_pause_menu)
	vbox.add_child(menu_btn)


func _create_pause_button(text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(200, 50)
	
	var style := StyleBoxFlat.new()
	style.bg_color = color.darkened(0.3)
	style.border_color = color
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", style)
	
	var hover := StyleBoxFlat.new()
	hover.bg_color = color.darkened(0.1)
	hover.border_color = color.lightened(0.2)
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("hover", hover)
	
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = color
	pressed.border_color = Color.WHITE
	pressed.set_border_width_all(2)
	pressed.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("pressed", pressed)
	
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color.WHITE)
	
	return btn


func _toggle_pause() -> void:
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_panel.visible = is_paused
	
	if is_paused:
		click_zone_button.set_active(false)
	else:
		click_zone_button.set_active(true)


func _on_pause_restart() -> void:
	get_tree().paused = false
	SaveManager.restore_session_currency()
	get_tree().reload_current_scene()


func _on_pause_menu() -> void:
	get_tree().paused = false
	SaveManager.restore_session_currency()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


# ==================== CINEMATIC SYSTEM ====================

func _show_cinematic() -> void:
	is_showing_cinematic = true
	cinematic_slide_index = 0
	
	cinematic_layer = CanvasLayer.new()
	cinematic_layer.name = "CinematicLayer"
	cinematic_layer.layer = 200
	add_child(cinematic_layer)
	
	_show_cinematic_slide()


func _show_cinematic_slide() -> void:
	# Nettoyer le slide précédent
	for child in cinematic_layer.get_children():
		child.queue_free()
	
	var slides: Array = PLANET_CINEMATICS.get(current_planet, PLANET_CINEMATICS[0])
	if cinematic_slide_index >= slides.size():
		_end_cinematic()
		return
	
	var slide_data: Dictionary = slides[cinematic_slide_index]
	
	# Background
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.95)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	cinematic_layer.add_child(bg)
	
	# Container centré
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cinematic_layer.add_child(center)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 30)
	center.add_child(vbox)
	
	# Emoji géant
	var emoji := Label.new()
	emoji.text = slide_data.emoji
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", 80)
	vbox.add_child(emoji)
	
	# Texte avec effet machine à écrire
	var text_label := Label.new()
	text_label.name = "CinematicText"
	text_label.text = ""
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.custom_minimum_size.x = mini(400, get_viewport().size.x - 60)  # Adaptatif
	text_label.add_theme_font_size_override("font_size", 18)  # Un peu plus petit
	text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	vbox.add_child(text_label)
	
	# Animation de typewriter
	var full_text: String = slide_data.text
	_typewriter_effect(text_label, full_text)
	
	# Indicateur de planète
	var planet_indicator := Label.new()
	var planet_name: String = PLANET_COLORS.get(current_planet, PLANET_COLORS[0]).name
	planet_indicator.text = "📍 %s" % planet_name
	planet_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	planet_indicator.add_theme_font_size_override("font_size", 14)
	planet_indicator.add_theme_color_override("font_color", PLANET_COLORS.get(current_planet, PLANET_COLORS[0]).accent)
	vbox.add_child(planet_indicator)
	
	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 40
	vbox.add_child(spacer)
	
	# Bouton continuer
	var continue_btn := Button.new()
	continue_btn.text = "TAP TO CONTINUE ▶"
	continue_btn.custom_minimum_size = Vector2(250, 50)
	
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.4, 0.6, 0.8)
	btn_style.border_color = Color(0.4, 0.7, 1.0)
	btn_style.set_border_width_all(2)
	btn_style.set_corner_radius_all(10)
	continue_btn.add_theme_stylebox_override("normal", btn_style)
	continue_btn.add_theme_font_size_override("font_size", 16)
	continue_btn.add_theme_color_override("font_color", Color.WHITE)
	continue_btn.pressed.connect(_on_cinematic_continue)
	vbox.add_child(continue_btn)
	
	# Compteur de slides
	var slide_counter := Label.new()
	slide_counter.text = "%d / %d" % [cinematic_slide_index + 1, slides.size()]
	slide_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slide_counter.add_theme_font_size_override("font_size", 12)
	slide_counter.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(slide_counter)


func _typewriter_effect(label: Label, full_text: String) -> void:
	var current_text := ""
	for i in range(full_text.length()):
		current_text += full_text[i]
		label.text = current_text
		await get_tree().create_timer(0.03).timeout
		if not is_instance_valid(label):
			return


func _on_cinematic_continue() -> void:
	cinematic_slide_index += 1
	_show_cinematic_slide()


func _end_cinematic() -> void:
	is_showing_cinematic = false
	
	if cinematic_layer:
		cinematic_layer.queue_free()
		cinematic_layer = null
	
	# Démarrer le combat
	await get_tree().create_timer(0.5).timeout
	_spawn_wave()
	state_machine.start_combat()


# ==================== BOSS SYSTEM ====================

func _spawn_boss() -> void:
	is_boss_wave = true
	var boss_data: Dictionary = PLANET_BOSSES.get(current_planet, PLANET_BOSSES[0])
	var is_final_boss: bool = current_planet == 3
	
	# Calculer le scaling selon la progression du joueur
	var highest_completed: int = -1
	if SaveManager:
		highest_completed = SaveManager.get_highest_planet_completed()
	
	# Le boss scale aussi un peu avec la progression pour rester challengeant
	var boss_hp_mult: float = 1.0 + (highest_completed + 1) * 0.1
	# Dr. Mortis est BEAUCOUP plus dur
	if is_final_boss:
		boss_hp_mult *= 1.3
	
	# Créer l'entité du boss
	current_boss = BaseEnemy.new()
	current_boss.name = "Boss_" + boss_data.name.replace(" ", "_")
	
	var boss_stats := EntityStats.new()
	boss_stats.display_name = boss_data.name
	boss_stats.max_hp = int(boss_data.hp * boss_hp_mult)
	boss_stats.attack = boss_data.atk
	boss_stats.attack_speed = boss_data.speed
	current_boss.base_stats = boss_stats
	
	# Ajouter au combat
	enemy_container.add_child(current_boss)
	combat_manager.add_enemy(current_boss)
	active_enemies.append(current_boss)
	
	# Visuel du boss (plus grand que les ennemis normaux)
	_create_boss_visual(current_boss, boss_data)
	
	# Connecter les signaux
	current_boss.died.connect(_on_boss_died.bind(current_boss))
	current_boss.hp_changed.connect(_on_boss_hp_changed)  # Signal spécial pour le boss
	current_boss.attacked.connect(_on_boss_attacked.bind(current_boss))
	current_boss.damaged.connect(_on_boss_damaged.bind(current_boss))
	
	# Annonce du boss - ÉPIQUE pour Dr. Mortis
	if is_final_boss:
		_announce_final_boss()
	else:
		_show_floating_text("⚠️ BOSS: %s ⚠️" % boss_data.name, Vector2(200, 350), boss_data.color, 32)
	
	print("[GameCombat] Boss spawned: %s with %d HP" % [boss_data.name, boss_stats.max_hp])


func _create_boss_visual(boss: BaseEnemy, boss_data: Dictionary) -> void:
	var is_final_boss: bool = current_planet == 3
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	var visual := Control.new()
	visual.name = "BossVisual"
	var base_size: int = mini(180, int(viewport_size.x * 0.25))  # Max 25% de la largeur
	var size_mult: float = 1.4 if is_final_boss else 1.0
	visual.custom_minimum_size = Vector2(base_size, base_size * 1.1) * size_mult
	
	# Container pour le boss (centré)
	var boss_container := CenterContainer.new()
	boss_container.custom_minimum_size = Vector2(base_size, base_size * 1.1) * size_mult
	visual.add_child(boss_container)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	boss_container.add_child(vbox)
	
	# Titre spécial pour Dr. Mortis
	if is_final_boss:
		var title := Label.new()
		title.text = "☠️ FINAL BOSS ☠️"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 14)
		title.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		vbox.add_child(title)
		
		# Animation du titre
		var title_tween := create_tween().set_loops()
		title_tween.tween_property(title, "modulate:a", 0.5, 0.5)
		title_tween.tween_property(title, "modulate:a", 1.0, 0.5)
	
	# Sprite du mini-boss OU emoji pour le boss final
	var sprite_path: String = MINIBOSS_SPRITES.get("idle", "")
	if not is_final_boss and ResourceLoader.exists(sprite_path):
		# Utiliser le sprite du mini-boss
		var sprite_container := CenterContainer.new()
		var sprite := TextureRect.new()
		sprite.name = "BossSprite"
		sprite.texture = load(sprite_path)
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var sprite_size := int(base_size * 0.8)
		sprite.custom_minimum_size = Vector2(sprite_size, sprite_size)
		sprite_container.add_child(sprite)
		vbox.add_child(sprite_container)
		
		# Stocker les textures pour animation
		boss.set_meta("sprite_idle", sprite_path)
		boss.set_meta("sprite_screaming", MINIBOSS_SPRITES.get("screaming", sprite_path))
		boss.set_meta("sprite_fireball", MINIBOSS_SPRITES.get("fireball", sprite_path))
	else:
		# Emoji du boss (pour boss final ou fallback)
		var emoji := Label.new()
		emoji.name = "BossEmoji"
		emoji.text = boss_data.emoji
		emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var emoji_size: int = int(base_size * 0.55) if is_final_boss else int(base_size * 0.45)
		emoji.add_theme_font_size_override("font_size", emoji_size)
		vbox.add_child(emoji)
		
		# Animation de pulsation pour le boss final
		if is_final_boss:
			var pulse_tween := create_tween().set_loops()
			pulse_tween.tween_property(emoji, "scale", Vector2(1.1, 1.1), 0.8).set_trans(Tween.TRANS_SINE)
			pulse_tween.tween_property(emoji, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
	
	# Nom du boss
	var name_label := Label.new()
	name_label.text = boss_data.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var name_size: int = 22 if is_final_boss else 16
	name_label.add_theme_font_size_override("font_size", name_size)
	name_label.add_theme_color_override("font_color", boss_data.color)
	vbox.add_child(name_label)
	
	# Sous-titre pour Dr. Mortis
	if is_final_boss:
		var subtitle := Label.new()
		subtitle.text = "\"Your family begged for mercy...\""
		subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle.add_theme_font_size_override("font_size", 10)
		subtitle.add_theme_color_override("font_color", Color(0.7, 0.5, 0.8))
		vbox.add_child(subtitle)
	
	# Barre de vie du boss (taille relative)
	var hp_bar := ProgressBar.new()
	hp_bar.name = "BossHPBar"
	var bar_width: int = int(base_size * 1.0) if is_final_boss else int(base_size * 0.9)
	var bar_height: int = 20 if is_final_boss else 14
	hp_bar.custom_minimum_size = Vector2(bar_width, bar_height)
	hp_bar.max_value = boss.base_stats.max_hp
	hp_bar.value = boss.base_stats.max_hp  # CORRECTION: Utiliser max_hp, pas current_hp
	hp_bar.show_percentage = false
	
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = boss_data.color
	fill_style.set_corner_radius_all(4)
	hp_bar.add_theme_stylebox_override("fill", fill_style)
	
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	bg_style.border_color = boss_data.color
	var border_width: int = 3 if is_final_boss else 2
	bg_style.set_border_width_all(border_width)
	bg_style.set_corner_radius_all(4)
	hp_bar.add_theme_stylebox_override("background", bg_style)
	
	vbox.add_child(hp_bar)
	
	# HP numérique pour le boss final
	if is_final_boss:
		var hp_text := Label.new()
		hp_text.name = "BossHPText"
		hp_text.text = "%d / %d" % [boss.base_stats.max_hp, boss.base_stats.max_hp]
		hp_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp_text.add_theme_font_size_override("font_size", 12)
		hp_text.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		vbox.add_child(hp_text)
	
	# Positionner dans le container des ennemis
	var y_offset: float = -20.0 if is_final_boss else 30.0
	visual.position = Vector2(-20 if is_final_boss else 0, y_offset)
	boss.add_child(visual)
	
	enemy_visuals[boss] = visual
	boss_visual = visual
	
	# Animation d'apparition épique
	visual.modulate.a = 0
	var tween := create_tween()
	if is_final_boss:
		# Apparition plus dramatique pour Dr. Mortis
		tween.tween_property(visual, "modulate:a", 1.0, 1.0)
		tween.parallel().tween_property(visual, "scale", Vector2(1.0, 1.0), 0.8).from(Vector2(2.0, 2.0)).set_trans(Tween.TRANS_BACK)
	else:
		tween.tween_property(visual, "modulate:a", 1.0, 0.5)
		tween.parallel().tween_property(visual, "scale", Vector2(1.0, 1.0), 0.3).from(Vector2(1.5, 1.5))


func _on_boss_died(boss: BaseEnemy) -> void:
	var boss_data: Dictionary = PLANET_BOSSES.get(current_planet, PLANET_BOSSES[0])
	var is_final_boss: bool = current_planet == 3
	
	# Récompense spéciale pour le boss (plus pour le boss final!)
	var boss_reward: int = ENEMY_KILL_REWARD * (10 if is_final_boss else 5)
	coins_earned_this_run += boss_reward
	SaveManager.add_currency(boss_reward)
	
	if is_final_boss:
		_show_floating_text("☠️ DR. MORTIS IS DEAD! +%d SC ☠️" % boss_reward, Vector2(150, 300), Color(0.8, 0.4, 1.0), 32)
	else:
		_show_floating_text("💀 %s DEFEATED! +%d SC" % [boss_data.name, boss_reward], Vector2(200, 300), Color(1.0, 0.8, 0.2), 28)
	
	# Effets visuels de mort du boss
	_create_boss_death_effect(boss)
	
	# Nettoyer
	if boss in active_enemies:
		active_enemies.erase(boss)
	if enemy_visuals.has(boss):
		enemy_visuals[boss].queue_free()
		enemy_visuals.erase(boss)
	boss.queue_free()
	
	is_boss_wave = false
	current_boss = null
	boss_visual = null
	
	# Victoire (ou cinématique de fin pour Dr. Mortis)
	await get_tree().create_timer(2.0 if is_final_boss else 1.5).timeout
	
	if is_final_boss:
		# Cinématique de fin!
		_show_ending_cinematic()
	else:
		_on_victory()


func _create_boss_death_effect(_boss: BaseEnemy) -> void:
	# Grande explosion pour le boss
	var is_final: bool = current_planet == 3
	var particle_count: int = 50 if is_final else 25
	
	for i in range(particle_count):
		var particle := ColorRect.new()
		var size_range: float = 40.0 if is_final else 25.0
		particle.size = Vector2(randf_range(10, size_range), randf_range(10, size_range))
		var boss_color: Color = PLANET_BOSSES.get(current_planet, PLANET_BOSSES[0]).color
		particle.color = boss_color if randf() > 0.3 else Color.WHITE
		
		var start_pos := Vector2(480 + randf_range(-50, 50), 380 + randf_range(-50, 50))
		particle.position = start_pos
		effects_layer.add_child(particle)
		
		var tween := create_tween()
		var spread: float = 300.0 if is_final else 200.0
		var end_pos := start_pos + Vector2(randf_range(-spread, spread), randf_range(-spread, 150))
		tween.tween_property(particle, "position", end_pos, randf_range(0.8, 1.5))
		tween.parallel().tween_property(particle, "modulate:a", 0.0, randf_range(0.8, 1.5))
		tween.parallel().tween_property(particle, "rotation", randf_range(-PI * 2, PI * 2), randf_range(0.8, 1.5))
		tween.tween_callback(particle.queue_free)
	
	# Flash écran (plus intense pour le boss final)
	var flash := ColorRect.new()
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1, 1, 1, 1.0 if is_final else 0.8)
	effects_layer.add_child(flash)
	
	var flash_tween := create_tween()
	flash_tween.tween_property(flash, "color:a", 0.0, 0.8 if is_final else 0.5)
	flash_tween.tween_callback(flash.queue_free)


## Annonce épique pour le boss final
func _announce_final_boss() -> void:
	# Fond rouge qui pulse
	var warning_bg := ColorRect.new()
	warning_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	warning_bg.color = Color(0.5, 0, 0, 0)
	effects_layer.add_child(warning_bg)
	
	var bg_tween := create_tween().set_loops(3)
	bg_tween.tween_property(warning_bg, "color:a", 0.4, 0.3)
	bg_tween.tween_property(warning_bg, "color:a", 0.0, 0.3)
	bg_tween.chain().tween_callback(warning_bg.queue_free)
	
	# Texte d'avertissement
	await get_tree().create_timer(0.2).timeout
	_show_floating_text("⚠️ WARNING ⚠️", Vector2(200, 250), Color(1.0, 0.3, 0.3), 36)
	
	await get_tree().create_timer(0.6).timeout
	_show_floating_text("☠️ FINAL BOSS ☠️", Vector2(180, 320), Color(0.8, 0.2, 0.6), 42)
	
	await get_tree().create_timer(0.6).timeout
	_show_floating_text("💀 DR. MORTIS 💀", Vector2(150, 400), Color(0.6, 0.2, 0.8), 48)
	
	await get_tree().create_timer(0.5).timeout
	_show_floating_text("\"I killed them all... and I'll kill YOU too!\"", Vector2(80, 470), Color(0.7, 0.5, 0.8), 16)


## Mise à jour de la barre de vie du boss
func _on_boss_hp_changed(current_hp: int, max_hp: int) -> void:
	if boss_visual and is_instance_valid(boss_visual):
		var hp_bar := boss_visual.find_child("BossHPBar", true, false) as ProgressBar
		if hp_bar:
			hp_bar.value = current_hp
			
			# Changer la couleur si HP bas
			var fill_style := hp_bar.get_theme_stylebox("fill") as StyleBoxFlat
			if fill_style:
				var hp_percent: float = float(current_hp) / float(max_hp)
				if hp_percent <= 0.25:
					fill_style.bg_color = Color(1.0, 0.2, 0.2)  # Rouge critique
				elif hp_percent <= 0.5:
					fill_style.bg_color = Color(1.0, 0.6, 0.2)  # Orange
		
		# Mettre à jour le texte HP pour le boss final
		var hp_text := boss_visual.find_child("BossHPText", true, false) as Label
		if hp_text:
			hp_text.text = "%d / %d" % [current_hp, max_hp]
	
	# Mettre à jour aussi la barre globale des ennemis
	if current_boss:
		_on_enemy_hp_changed(current_hp, max_hp, current_boss)


## Appelé quand le boss attaque - change son sprite en pose "screaming"
func _on_boss_attacked(_target: BaseEntity, _damage: int, _is_crit: bool, boss: BaseEnemy) -> void:
	if not is_instance_valid(boss):
		return
	_set_boss_sprite_pose(boss, "screaming")
	# Revenir à idle après un court délai
	await get_tree().create_timer(0.4).timeout
	if is_instance_valid(boss) and boss.is_alive:
		_set_boss_sprite_pose(boss, "idle")


## Appelé quand le boss prend des dégâts
func _on_boss_damaged(_amount: int, _is_crit: bool, boss: BaseEnemy) -> void:
	if not is_instance_valid(boss):
		return
	# Flash visuel
	if boss_visual and is_instance_valid(boss_visual):
		var original_modulate := boss_visual.modulate
		boss_visual.modulate = Color(1.0, 0.5, 0.5)
		await get_tree().create_timer(0.15).timeout
		if is_instance_valid(boss_visual):
			boss_visual.modulate = original_modulate


## Change le sprite du boss selon sa pose
func _set_boss_sprite_pose(boss: BaseEnemy, pose: String) -> void:
	if not is_instance_valid(boss) or not boss_visual:
		return
	
	var sprite: TextureRect = boss_visual.find_child("BossSprite", true, false) as TextureRect
	if not sprite:
		return  # Pas de sprite (utilise emoji)
	
	var sprite_path: String = boss.get_meta("sprite_" + pose, "")
	if sprite_path.is_empty() or not ResourceLoader.exists(sprite_path):
		# Essayer depuis la config globale
		sprite_path = MINIBOSS_SPRITES.get(pose, "")
	
	if not sprite_path.is_empty() and ResourceLoader.exists(sprite_path):
		sprite.texture = load(sprite_path)


## Afficher la cinématique de fin après avoir battu Dr. Mortis
func _show_ending_cinematic() -> void:
	is_showing_cinematic = true
	cinematic_slide_index = 0
	
	cinematic_layer = CanvasLayer.new()
	cinematic_layer.name = "EndingCinematicLayer"
	cinematic_layer.layer = 200
	add_child(cinematic_layer)
	
	_show_ending_slide()


func _show_ending_slide() -> void:
	# Nettoyer le slide précédent
	for child in cinematic_layer.get_children():
		child.queue_free()
	
	if cinematic_slide_index >= ENDING_CINEMATIC.size():
		_end_ending_cinematic()
		return
	
	var slide_data: Dictionary = ENDING_CINEMATIC[cinematic_slide_index]
	
	# Background noir
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.98)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	cinematic_layer.add_child(bg)
	
	# Container centré
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cinematic_layer.add_child(center)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 25)
	center.add_child(vbox)
	
	# Emoji géant
	var emoji := Label.new()
	emoji.text = slide_data.emoji
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji.add_theme_font_size_override("font_size", 90)
	vbox.add_child(emoji)
	
	# Texte
	var text_label := Label.new()
	text_label.name = "EndingText"
	text_label.text = ""
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.custom_minimum_size.x = mini(400, get_viewport().size.x - 60)  # Adaptatif
	
	# Style spécial pour "TO BE CONTINUED"
	var is_final_slide: bool = cinematic_slide_index == ENDING_CINEMATIC.size() - 1
	if is_final_slide:
		text_label.add_theme_font_size_override("font_size", 28)  # Un peu plus petit
		text_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
	else:
		text_label.add_theme_font_size_override("font_size", 18)  # Un peu plus petit
		text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	vbox.add_child(text_label)
	
	# Animation de typewriter
	_typewriter_effect(text_label, slide_data.text)
	
	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 50
	vbox.add_child(spacer)
	
	# Bouton continuer
	var continue_btn := Button.new()
	continue_btn.text = "CONTINUE ▶" if not is_final_slide else "🏆 FINISH 🏆"
	continue_btn.custom_minimum_size = Vector2(250, 55)
	
	var btn_color: Color = Color(0.6, 0.4, 0.2) if is_final_slide else Color(0.2, 0.4, 0.6)
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = btn_color.darkened(0.2)
	btn_style.border_color = btn_color.lightened(0.3)
	btn_style.set_border_width_all(2)
	btn_style.set_corner_radius_all(10)
	continue_btn.add_theme_stylebox_override("normal", btn_style)
	continue_btn.add_theme_font_size_override("font_size", 18)
	continue_btn.add_theme_color_override("font_color", Color.WHITE)
	continue_btn.pressed.connect(_on_ending_continue)
	vbox.add_child(continue_btn)
	
	# Compteur de slides
	var slide_counter := Label.new()
	slide_counter.text = "%d / %d" % [cinematic_slide_index + 1, ENDING_CINEMATIC.size()]
	slide_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slide_counter.add_theme_font_size_override("font_size", 12)
	slide_counter.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	vbox.add_child(slide_counter)


func _on_ending_continue() -> void:
	cinematic_slide_index += 1
	_show_ending_slide()


func _end_ending_cinematic() -> void:
	is_showing_cinematic = false
	
	if cinematic_layer:
		cinematic_layer.queue_free()
		cinematic_layer = null
	
	# Afficher l'écran de victoire finale
	_show_game_over_screen(true)
