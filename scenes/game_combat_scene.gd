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

## COF-907: Vaisseaux ennemis actifs
var active_ships: Array = []
var ship_visuals: Dictionary = {}
var ship_container: Control

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
var wave_bonus_multiplier: float = 1.0  # BMAD Mode: Boost cumulatif par vague complétée

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
	0: {  # Mercury (index 0)
		"standing": "res://assets/sprites/enemies/mercury-sprites-standing.png",
		"shooting": "res://assets/sprites/enemies/mercury-sprites-shooting.png",
		"hurt": "res://assets/sprites/enemies/mercury-sprites-on-knee.png"
	},
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

## COF-907: Vaisseaux ennemis - sprites aériens
const ENEMY_SHIPS := [
	"res://assets/sprites/enemies/vaisseau-1.png",
	"res://assets/sprites/enemies/vaisseau-2.png",
	"res://assets/sprites/enemies/vaisseau-3.png",
	"res://assets/sprites/enemies/vaisseau-4.png",
	"res://assets/sprites/enemies/vaisseau-5.png",
	"res://assets/sprites/enemies/vaisseau-6.png"
]

## COF-907: Configuration vaisseaux par wave (Array indexé par wave-1)
const SHIPS_PER_WAVE := [1, 1, 2, 2, 3]  # Wave 1-5: nombre de vaisseaux

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

## Boss par planète (après les 5 vagues) - Plus durs que la vague 5!
const PLANET_BOSSES := {
	0: {"name": "Mercury Guardian", "hp": 600, "atk": 28, "speed": 0.9, "color": Color(1.0, 0.5, 0.2), "emoji": "🛡️", "special": "shield"},
	1: {"name": "Venus Queen", "hp": 800, "atk": 35, "speed": 0.85, "color": Color(0.8, 0.9, 0.2), "emoji": "👑", "special": "poison"},
	2: {"name": "Mars Warlord", "hp": 1000, "atk": 42, "speed": 0.75, "color": Color(0.9, 0.4, 0.3), "emoji": "⚔️", "special": "rage"},
	3: {"name": "DR. MORTIS", "hp": 2200, "atk": 55, "speed": 0.6, "color": Color(0.6, 0.2, 0.8), "emoji": "💀", "special": "final"},  # BOSS FINAL!
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

## COF-908: Configuration des équipements (bonus par item)
const EQUIPMENT_BONUSES := {
	# Armes (bonus attack_power)
	"sword_basic": {"attack_power": 5},
	"sword_flame": {"attack_power": 12},
	"sword_cosmic": {"attack_power": 25},
	# Armures (bonus dodge_chance en %)
	"armor_light": {"dodge_chance": 5},
	"armor_shadow": {"dodge_chance": 10},
	"armor_cosmic": {"dodge_chance": 18},
	# Casques (bonus heal_power)
	"helmet_basic": {"heal_power": 3},
	"helmet_nature": {"heal_power": 8},
	"helmet_cosmic": {"heal_power": 15},
}

## COF-908: Bonus de heal des upgrades/équipements (passé au combat_manager)
var _heal_power_bonus: int = 0

## Cinématiques par planète
const PLANET_CINEMATICS := {
	0: [  # Mercury
		{"text": "My name is Zyx-7. I had a family once... a beautiful colony on the outer rim.", "emoji": "👽", "character": "zyx"},
		{"text": "Until HE came. Dr. Mortis. A human scientist who destroyed everything I loved.", "emoji": "💔", "character": "mortis"},
		{"text": "Now I hunt him across the stars. Mercury is my first stop...", "emoji": "🚀", "character": "zyx"},
	],
	1: [  # Venus
		{"text": "Mercury's colony knew nothing. But they mentioned Venus...", "emoji": "🔍", "character": "zyx"},
		{"text": "Dr. Mortis has been building something here. Toxic experiments.", "emoji": "☠️", "character": "mortis"},
		{"text": "I will tear through his creations until I find him.", "emoji": "😤", "character": "zyx"},
	],
	2: [  # Mars
		{"text": "Venus was another dead end. But I found records... Mars.", "emoji": "📜", "character": "zyx"},
		{"text": "His main research facility. Where he perfected his weapons.", "emoji": "🔬", "character": "mortis"},
		{"text": "The weapons he used on my family. He WILL pay.", "emoji": "🔥", "character": "zyx"},
	],
	3: [  # Earth
		{"text": "This is it. Earth. His homeworld. His fortress.", "emoji": "🌍", "character": "zyx"},
		{"text": "Dr. Mortis is here. I can feel it. After all these years...", "emoji": "👁️", "character": "mortis"},
		{"text": "Today, my family will be avenged. Today, HE DIES.", "emoji": "💀", "character": "zyx"},
	],
}

## Scaling par vague
const WAVE_HP_SCALING := 1.15  # +15% HP par vague
const WAVE_ATK_SCALING := 1.1  # +10% ATK par vague
## Nombre d'ennemis par vague - par planète [Mercury, Venus, Mars, Earth]
const ENEMIES_PER_WAVE := {
	0: [6, 8, 8, 10, 8],       # Mercury (Wave 5: 10→8) - BMAD Mode: -25% Wave 5
	1: [8, 10, 10, 12, 10],    # Venus (Wave 5: 12→10) - BMAD Mode: -25% Wave 5
	2: [8, 10, 12, 12, 12],    # Mars (Wave 5: 14→12) - BMAD Mode: -25% Wave 5
	3: [10, 12, 12, 14, 12],   # Earth (Wave 5: 16→12) - BMAD Mode: -25% Wave 5 (4 fewer mobs!)
}

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
	
	# BMAD Mode: Réinitialiser le multiplicateur de vague pour chaque nouvelle planète
	wave_bonus_multiplier = 1.0
	
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
	
	# COF-808: Try to load fullscreen planet background image
	var bg_image_path: String = _get_background_image_path(current_planet)
	
	if ResourceLoader.exists(bg_image_path):
		# Load the background image
		var bg_texture: Texture2D = load(bg_image_path)
		
		# Create TextureRect for fullscreen background
		var bg_rect := TextureRect.new()
		bg_rect.name = "BackgroundImage"
		bg_rect.texture = bg_texture
		bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED  # Fullscreen without gaps
		bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg_rect.modulate.a = 0.95  # Slight transparency for UI readability
		background.add_child(bg_rect)
		
		print("[GameCombat] Loaded background image: %s" % bg_image_path)
	else:
		# Fallback: Use colored gradient if image not found
		print("[GameCombat] Background image not found at %s, using gradient fallback" % bg_image_path)
		_setup_background_gradient_fallback()


func _get_background_image_path(planet_id: int) -> String:
	# COF-808: Map planet IDs to background image paths
	var bg_paths := {
		0: "res://assets/backgrounds/mercury_bg.png",
		1: "res://assets/backgrounds/venus_bg.png",
		2: "res://assets/backgrounds/mars_bg.png",
		3: "res://assets/backgrounds/earth_bg.png"
	}
	return bg_paths.get(planet_id, bg_paths[0])


func _setup_background_gradient_fallback() -> void:
	# COF-808: Fallback to colored gradient if images not found (COF-807 colors)
	var planet_colors := PLANET_COLORS.get(current_planet, PLANET_COLORS[0]) as Dictionary
	
	# Base color background
	var bg_rect := ColorRect.new()
	bg_rect.name = "BackgroundGradientFallback"
	bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_rect.color = planet_colors.bg_bottom
	background.add_child(bg_rect)
	
	# Particules d'ambiance (étoiles/poussière)
	_add_ambient_particles(planet_colors.accent)


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
	
	# Container pour le héros (côté gauche - BMAD MODE)
	hero_container = Control.new()
	hero_container.name = "HeroContainer"
	hero_container.position = Vector2(viewport_size.x * 0.28, viewport_size.y * 0.55)  # Position originale
	combat_zone.add_child(hero_container)
	
	# Container pour les ennemis (côté droit - BMAD MODE)
	enemy_container = Control.new()
	enemy_container.name = "EnemyContainer"
	enemy_container.position = Vector2(viewport_size.x * 0.68, viewport_size.y * 0.55)  # Position originale
	combat_zone.add_child(enemy_container)
	
	# COF-907: Container pour les vaisseaux ennemis (au-dessus des troupes)
	ship_container = Control.new()
	ship_container.name = "ShipContainer"
	ship_container.position = Vector2(viewport_size.x * 0.60, viewport_size.y * 0.25)  # Haut à droite
	ship_container.z_index = 5  # Au-dessus du background, sous le HUD
	combat_zone.add_child(ship_container)
	
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
	
	# ===== COF-908: Récupérer les bonus des upgrades =====
	var hp_upgrade_bonus := 0
	var atk_upgrade_bonus := 0
	var dodge_upgrade_bonus := 0.0
	var heal_upgrade_bonus := 0
	
	if SaveManager:
		hp_upgrade_bonus = SaveManager.get_upgrade_level("max_hp") * 15
		atk_upgrade_bonus = SaveManager.get_upgrade_level("attack_power") * 2
		dodge_upgrade_bonus = SaveManager.get_upgrade_level("dodge_chance") * 0.02
		heal_upgrade_bonus = SaveManager.get_upgrade_level("heal_power") * 2
	
	# ===== COF-908: Récupérer les bonus des équipements =====
	var equip_atk_bonus := _get_equipment_bonus("attack_power")
	var equip_dodge_bonus := _get_equipment_bonus("dodge_chance") * 0.01  # % converti en décimal
	var equip_heal_bonus := _get_equipment_bonus("heal_power")
	
	# Appliquer toutes les stats avec upgrades + équipements
	var hero_stats := EntityStats.new()
	hero_stats.display_name = "Alien Hero"
	hero_stats.max_hp = int(HERO_BASE_HP * hp_mult) + hp_upgrade_bonus
	hero_stats.attack = int(HERO_BASE_ATTACK * atk_mult) + atk_upgrade_bonus + equip_atk_bonus
	hero_stats.attack_speed = HERO_ATTACK_SPEED
	hero_stats.crit_chance = HERO_CRIT_CHANCE
	hero_stats.dodge_chance = HERO_DODGE_CHANCE + dodge_upgrade_bonus + equip_dodge_bonus
	hero.base_stats = hero_stats
	
	# COF-908: Stocker le heal bonus pour le combat manager
	_heal_power_bonus = heal_upgrade_bonus + equip_heal_bonus
	
	print("[GameCombat] Hero stats with upgrades - HP: %d (+%d), ATK: %d (+%d+%d), Dodge: %.1f%% (+%.1f%%+%.1f%%), Heal bonus: +%d" % [
		hero_stats.max_hp, hp_upgrade_bonus,
		hero_stats.attack, atk_upgrade_bonus, equip_atk_bonus,
		hero_stats.dodge_chance * 100, dodge_upgrade_bonus * 100, equip_dodge_bonus * 100,
		_heal_power_bonus
	])
	
	hero_container.add_child(hero)
	combat_manager.hero = hero
	
	# COF-908: Passer le bonus de heal au combat manager
	combat_manager.heal_power_bonus = _heal_power_bonus
	
	# Reconnecter les signaux du héros dans le combat manager
	# (nécessaire car le hero est assigné après _ready du combat_manager)
	combat_manager._connect_hero_signals()
	
	# Visuel du héros
	_create_hero_visual()


## COF-908: Calcule le bonus d'équipement pour une stat donnée
func _get_equipment_bonus(stat: String) -> int:
	if not SaveManager:
		return 0
	
	var total_bonus := 0
	
	for slot in ["weapon", "armor", "helmet"]:
		var equipped := SaveManager.get_equipped(slot)
		if equipped != "" and EQUIPMENT_BONUSES.has(equipped):
			total_bonus += EQUIPMENT_BONUSES[equipped].get(stat, 0)
	
	return total_bonus


func _create_hero_visual() -> void:
	# Charger toutes les textures du héros
	_load_hero_textures()
	
	var visual := Control.new()
	visual.name = "HeroVisual"
	hero.add_child(visual)
	
	# COF-907: Sprite principal du héros agrandi (taille relative au viewport)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var sprite_width: int = mini(350, int(viewport_size.x * 0.48))  # COF-907: Max 48% de la largeur - HÉROS XXL
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
	
	# var hero_header := HBoxContainer.new()
	# hero_section.add_child(hero_header)
	
	# var hero_title := Label.new()
	# hero_title.text = "👽 ALIEN HERO"
	# hero_title.add_theme_font_size_override("font_size", 13)
	# hero_title.add_theme_color_override("font_color", Color(0.7, 1.0, 0.7))
	# hero_header.add_child(hero_title)
	
	# Stats du héros sous la barre de vie (utilise les vraies stats calculées)
	# var hero_stats_label := Label.new()
	# hero_stats_label.name = "HeroStatsLabel"
	# var real_atk: int = hero.base_stats.attack if hero and hero.base_stats else HERO_BASE_ATTACK
	# hero_stats_label.text = "ATK: %d | SPD: %.1f | CRIT: %d%%" % [real_atk, HERO_ATTACK_SPEED, int(HERO_CRIT_CHANCE * 100)]
	# hero_stats_label.add_theme_font_size_override("font_size", 10)
	# hero_stats_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	# hero_section.add_child(hero_stats_label)
	
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
	# var recommended_power: int = PLANET_RECOMMENDED_POWER.get(current_planet, 100)
	# var highest_completed: int = -1
	# if SaveManager:
	# 	highest_completed = SaveManager.get_highest_planet_completed()
	# var player_power: int = HERO_POWER_PER_PLANET.get(highest_completed, HERO_POWER_PER_PLANET[-1]).power
	
	# var power_label := Label.new()
	# power_label.name = "PowerLabel"
	# var power_color: Color
	# if player_power >= recommended_power:
	# 	power_color = Color(0.3, 1.0, 0.5)  # Vert - bon niveau
	# elif player_power >= recommended_power * 0.8:
	# 	power_color = Color(1.0, 0.9, 0.3)  # Jaune - faisable
	# else:
	# 	power_color = Color(1.0, 0.4, 0.3)  # Rouge - difficile
	# power_label.text = "⚡ %d / %d" % [player_power, recommended_power]
	# power_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# power_label.add_theme_font_size_override("font_size", 12)
	# power_label.add_theme_color_override("font_color", power_color)
	# center_section.add_child(power_label)
	
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
	
	# var enemy_title := Label.new()
	# enemy_title.text = "ENEMIES 👾"
	# enemy_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	# enemy_title.add_theme_font_size_override("font_size", 13)
	# enemy_title.add_theme_color_override("font_color", Color(1.0, 0.7, 0.7))
	# enemy_section.add_child(enemy_title)
	
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
	bottom_container.anchor_top = 0.75  # 22% de l'écran pour les boutons (remis comme avant)
	bottom_container.add_theme_constant_override("separation", 8)
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
	click_margin.add_theme_constant_override("margin_left", 10)
	click_margin.add_theme_constant_override("margin_right", 10)
	click_margin.add_theme_constant_override("margin_bottom", 30)
	bottom_container.add_child(click_margin)
	
	click_zone_button = ClickZoneButton.new()
	click_zone_button.name = "ClickZoneButton"
	click_zone_button.custom_minimum_size = Vector2(0, 180)  # COF-907: Hauteur agrandie (110 → 180)
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
	
	# Skills débloqués par planète:
	# - Mercury (0): HEAL
	# - Venus (1): CRIT  
	# - Mars (2): SHIELD
	# - Earth (3): NOVA
	var highest_planet: int = 0
	if SaveManager:
		highest_planet = SaveManager.get_highest_planet_completed() + 1  # +1 car on débloque la planète actuelle
	highest_planet = maxi(highest_planet, current_planet)  # Au moins la planète en cours
	
	var skills := [
		{"id": "heal_burst", "name": "HEAL", "color": Color(0.2, 0.8, 0.5), "icon": "💚", "cooldown": 12.0, "desc": "Full Heal", "unlock_planet": 0},
		{"id": "crit_surge", "name": "CRIT", "color": Color(0.9, 0.5, 0.1), "icon": "💥", "cooldown": 15.0, "desc": "+50% Crit", "unlock_planet": 1},
		{"id": "dodge_field", "name": "SHIELD", "color": Color(0.5, 0.4, 0.9), "icon": "🛡️", "cooldown": 10.0, "desc": "Invincible", "unlock_planet": 2},
		{"id": "nova_blast", "name": "NOVA", "color": Color(0.9, 0.2, 0.3), "icon": "☄️", "cooldown": 20.0, "desc": "AOE Dmg", "unlock_planet": 3},
	]
	
	for skill in skills:
		var is_unlocked: bool = highest_planet >= skill.unlock_planet
		var skill_btn := _create_skill_button(skill, is_unlocked)
		skill_bar.add_child(skill_btn)
		skill_buttons[skill.id] = skill_btn
	
	return skill_bar


func _create_skill_button(skill_data: Dictionary, is_unlocked: bool = true) -> Button:
	var btn := Button.new()
	btn.name = skill_data.id
	btn.custom_minimum_size = Vector2(85, 100)  # COF-907: Boutons agrandis (65x70 → 85x100)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Si verrouillé, afficher un cadenas
	if is_unlocked:
		btn.text = skill_data.icon + "\n" + skill_data.name
	else:
		btn.text = "🔒\n" + skill_data.name
		btn.disabled = true
	
	# --- PIXEL ART STYLE ---
	var style := StyleBoxFlat.new()
	if is_unlocked:
		style.bg_color = skill_data.color.lightened(0.1)
	else:
		style.bg_color = Color(0.15, 0.15, 0.15, 0.8)  # Gris foncé pour verrouillé
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1,1,1) if is_unlocked else Color(0.4, 0.4, 0.4)
	style.corner_radius_top_left = 0
	style.corner_radius_top_right = 0
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	btn.add_theme_stylebox_override("normal", style)

	var hover_style := style.duplicate()
	hover_style.bg_color = skill_data.color if is_unlocked else Color(0.2, 0.2, 0.2, 0.8)
	btn.add_theme_stylebox_override("hover", hover_style)

	var pressed_style := style.duplicate()
	pressed_style.bg_color = skill_data.color.darkened(0.2) if is_unlocked else Color(0.1, 0.1, 0.1, 0.8)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	var disabled_style := style.duplicate()
	disabled_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	disabled_style.border_color = Color(0.4, 0.4, 0.4)
	btn.add_theme_stylebox_override("disabled", disabled_style)

	# Police pixel art si dispo
	var pixel_font_path := "res://assets/fonts/pixel_font.tres"
	if ResourceLoader.exists(pixel_font_path):
		var pixel_font = load(pixel_font_path)
		btn.add_theme_font_override("font", pixel_font)
		btn.add_theme_font_size_override("font_size", 16)
	else:
		btn.add_theme_font_size_override("font_size", 16)

	btn.add_theme_color_override("font_color", Color(1,1,1) if is_unlocked else Color(0.5, 0.5, 0.5))
	
	# Connecter le bouton seulement si débloqué
	if is_unlocked:
		btn.pressed.connect(_on_skill_pressed.bind(skill_data))
	
	# Stocker les données du skill dans metadata
	btn.set_meta("skill_data", skill_data)
	btn.set_meta("cooldown_label", null)
	btn.set_meta("is_unlocked", is_unlocked)
	
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
	punishment_overlay.color = Color(0.2, 0.0, 0.0, 0.0)  # Invisible by default (alpha=0)
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
	
	# Déterminer le nombre d'ennemis pour cette vague (selon la planète)
	var wave_idx := clampi(current_wave - 1, 0, 4)  # Max 5 waves
	var planet_enemies = ENEMIES_PER_WAVE.get(current_planet, ENEMIES_PER_WAVE[0])
	enemies_in_wave = planet_enemies[wave_idx]
	
	for i in range(enemies_in_wave):
		await get_tree().create_timer(0.4).timeout
		_spawn_enemy(i)
	
	# COF-907: Spawn vaisseaux ennemis aériens
	var ship_idx: int = clampi(current_wave - 1, 0, SHIPS_PER_WAVE.size() - 1)
	var ships_count: int = SHIPS_PER_WAVE[ship_idx]
	_spawn_enemy_ships(ships_count)


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
	
	# Position relative à l'écran - BMAD MODE: ennemis rapprochés comme une armée
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	# Formation matricielle: 4 rangées, colonnes dynamiques
	var enemy_spacing_x: float = viewport_size.x * 0.045  # 4.5% (était 10%) - armée compacte
	var enemy_spacing_y: float = 35.0  # Vertical spacing entre rangées
	var rows: int = 4
	var cols: int = int((enemies_in_wave + rows - 1) / rows)
	var row: int = int(index % rows)
	var col: int = int(index / rows)
	# Centrer la formation autour de (0, 0) du container
	var offset_x: float = -(cols - 1) * enemy_spacing_x * 0.5
	var offset_y: float = -60.0
	enemy.position = Vector2(col * enemy_spacing_x + offset_x, row * enemy_spacing_y + offset_y)
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
	
	# COF-907: Taille relative au viewport - Ennemis agrandis
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var body_width: int = mini(100, int(viewport_size.x * 0.14))  # COF-907: ENNEMIS XXL (0.11 → 0.14)
	var body_height: int = int(body_width * 1.4)
	var sprite_size := Vector2(body_width * 2.2, body_height * 2.2)  # COF-907: +10% scaling sprite
	
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


# ==================== COF-907: ENEMY SHIPS SYSTEM ====================

func _spawn_enemy_ships(count: int) -> void:
	# Nettoyer les vaisseaux précédents
	for ship in active_ships:
		if is_instance_valid(ship):
			ship.queue_free()
	active_ships.clear()
	ship_visuals.clear()
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var ship_spacing: float = viewport_size.x * 0.10
	var start_x: float = -ship_spacing * (count - 1) / 2.0
	
	for i in range(count):
		var ship := BaseEnemy.new()
		ship.name = "EnemyShip_%d" % i
		
		# Stats du vaisseau (ennemi aérien)
		var ship_stats := EntityStats.new()
		ship_stats.display_name = "Fighter Ship"
		ship_stats.max_hp = 30 + (current_wave * 10)
		ship_stats.attack = 5 + (current_wave * 2)
		ship_stats.attack_speed = 0.8
		ship.base_stats = ship_stats
		
		# Position en formation diagonale
		var ship_pos := Vector2(start_x + i * ship_spacing, i * 30)
		ship.position = ship_pos
		
		ship_container.add_child(ship)
		active_ships.append(ship)
		
		# Visual du vaisseau
		var visual := _create_ship_visual(ship)
		ship_visuals[ship] = visual
		
		# Connecter signaux
		ship.died.connect(_on_ship_died.bind(ship))
		ship.hp_changed.connect(_on_ship_hp_changed.bind(ship))
		
		# Ajouter au combat manager comme cible
		combat_manager.add_enemy(ship)


func _create_ship_visual(ship: BaseEnemy) -> Control:
	var visual := Control.new()
	visual.name = "ShipVisual"
	ship.add_child(visual)
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var ship_size := Vector2(
		mini(100, int(viewport_size.x * 0.14)),
		mini(70, int(viewport_size.x * 0.10))
	)
	
	# Sprite du vaisseau (choix aléatoire)
	var sprite := TextureRect.new()
	sprite.name = "ShipSprite"
	var random_ship: String = ENEMY_SHIPS[randi() % ENEMY_SHIPS.size()]
	if ResourceLoader.exists(random_ship):
		sprite.texture = load(random_ship)
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.custom_minimum_size = ship_size
	sprite.size = ship_size
	sprite.position = Vector2(-ship_size.x / 2, -ship_size.y)
	# Flip horizontal pour pointer vers le héros
	sprite.flip_h = true
	visual.add_child(sprite)
	
	# Barre de vie du vaisseau
	var hp_bar_width := ship_size.x * 0.8
	var hp_bg := ColorRect.new()
	hp_bg.name = "HPBackground"
	hp_bg.color = Color(0.1, 0.1, 0.1, 0.8)
	hp_bg.size = Vector2(hp_bar_width, 5)
	hp_bg.position = Vector2(-hp_bar_width / 2, -ship_size.y - 10)
	visual.add_child(hp_bg)
	
	var hp_fill := ColorRect.new()
	hp_fill.name = "HPFill"
	hp_fill.color = Color(0.5, 0.2, 0.8)  # Violet pour différencier
	hp_fill.size = Vector2(hp_bar_width - 2, 3)
	hp_fill.position = Vector2(-hp_bar_width / 2 + 1, -ship_size.y - 9)
	visual.add_child(hp_fill)
	
	# Animation d'apparition
	visual.modulate.a = 0.0
	var appear_tween := create_tween()
	appear_tween.tween_property(visual, "modulate:a", 1.0, 0.4)
	
	# Animation de flottement
	_animate_ship_hover(sprite)
	
	return visual


func _animate_ship_hover(sprite: TextureRect) -> void:
	var original_y := sprite.position.y
	var tween := create_tween().set_loops()
	tween.tween_property(sprite, "position:y", original_y - 8, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:y", original_y + 8, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _on_ship_died(ship: BaseEnemy) -> void:
	var ship_pos := ship.global_position
	
	# Animation de destruction du vaisseau (comme les troupes au sol)
	var visual: Control = ship.get_node_or_null("ShipVisual")
	if visual:
		# Arrêter l'animation de flottement
		var sprite: TextureRect = visual.get_node_or_null("ShipSprite")
		
		# Animation de mort : explosion + rotation + disparition
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(visual, "modulate", Color(1.5, 0.8, 0.3, 1.0), 0.15)  # Flash orange
		tween.chain().set_parallel(true)
		tween.tween_property(visual, "modulate:a", 0.0, 0.4)
		tween.tween_property(visual, "scale", Vector2(1.5, 0.2), 0.35)  # Écrasement
		tween.tween_property(visual, "rotation", randf_range(-0.5, 0.5), 0.35)  # Rotation
		tween.tween_property(visual, "position:y", visual.position.y + 30, 0.35)  # Tombe
		tween.chain().tween_callback(ship.queue_free)
	
	_show_floating_text("💥", ship_pos + Vector2(0, -50), Color.ORANGE, 28)
	
	# COF-907: Reward pour vaisseau (15 SC)
	var ship_reward: int = 15
	coins_earned_this_run += ship_reward
	SaveManager.add_currency(ship_reward)
	_show_floating_text("+%d SC" % ship_reward, ship_pos + Vector2(20, -30), Color(1.0, 0.9, 0.3), 18)
	_update_currency_display()
	
	if ship in active_ships:
		active_ships.erase(ship)
	if ship in ship_visuals:
		ship_visuals.erase(ship)


func _on_ship_hp_changed(current_hp: int, max_hp: int, ship: BaseEnemy) -> void:
	if ship in ship_visuals:
		var visual: Control = ship_visuals[ship]
		var hp_fill: ColorRect = visual.get_node_or_null("HPFill")
		var hp_bg: ColorRect = visual.get_node_or_null("HPBackground")
		if hp_fill and hp_bg:
			var ratio := float(current_hp) / float(max_hp)
			hp_fill.size.x = (hp_bg.size.x - 2) * ratio


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
		var hp_ratio := float(hero.current_hp) / float(hero.base_stats.max_hp)
		
			# Update hero HP bar above sprite
		var hp_fill: ColorRect = hero.get_node_or_null("HeroVisual/HPFill")
		if hp_fill:
			var hp_bg: ColorRect = hero.get_node_or_null("HeroVisual/HPBackground")
			var max_width: float = hp_bg.size.x - 2 if hp_bg else 128.0
			hp_fill.size.x = max_width * hp_ratio
			# Même logique de couleur
			if hp_ratio <= 0.25:
				hp_fill.color = Color(0.9, 0.2, 0.2)
			elif hp_ratio <= 0.5:
				hp_fill.color = Color(0.9, 0.6, 0.2)
			else:
				hp_fill.color = Color(0.2, 0.9, 0.3)
	



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
	# Si la référence est invalide, nettoyer la liste et sortir
	if not is_instance_valid(enemy):
		active_enemies = active_enemies.filter(func(e): is_instance_valid(e))
		return

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
		# BMAD Mode: Appliquer le boost de vague AVANT la prochaine vague (mais pas au boss)
		_apply_wave_bonus_to_hero()
		await get_tree().create_timer(1.0).timeout
		# Afficher le titre de vague pendant 3 secondes
		await _show_wave_title("⚔️ WAVE %d ⚔️" % current_wave, Color.WHITE)
		_spawn_wave()
		# Redémarrer le combat pour la nouvelle vague
		state_machine.start_combat()
	else:
		# Toutes les vagues terminées - BOSS TIME!
		print("[GameCombat] All waves cleared! Spawning boss...")
		await get_tree().create_timer(1.0).timeout
		# Afficher le titre du boss pendant 3 secondes
		var boss_data: Dictionary = PLANET_BOSSES.get(current_planet, PLANET_BOSSES[0])
		await _show_wave_title("⚠️ %s ⚠️" % boss_data.name.to_upper(), Color(1.0, 0.3, 0.3), true)
		_spawn_boss()
		state_machine.start_combat()


## Affiche un titre de vague/boss centré en haut pendant 3 secondes
func _show_wave_title(text: String, color: Color, is_boss: bool = false) -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	# Créer un panneau de fond
	var panel := PanelContainer.new()
	panel.name = "WaveTitle"
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.0, 0.0, 0.0, 0.85)
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 40
	style.content_margin_right = 40
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	
	# Label du titre
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var font_size: int = 48 if is_boss else 42
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	panel.add_child(label)
	
	# Sous-titre pour le boss
	if is_boss:
		var vbox := VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		label.reparent(vbox)
		
		var sub_label := Label.new()
		sub_label.text = "PREPARE FOR BATTLE!"
		sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub_label.add_theme_font_size_override("font_size", 24)
		sub_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.3))
		vbox.add_child(sub_label)
		
		panel.add_child(vbox)
	
	# Positionner au centre-haut
	panel.position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.15)
	panel.pivot_offset = panel.size * 0.5
	effects_layer.add_child(panel)
	
	# Attendre que le panel soit dimensionné puis centrer
	await get_tree().process_frame
	panel.position = Vector2((viewport_size.x - panel.size.x) * 0.5, viewport_size.y * 0.12)
	
	# Animation d'apparition
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.5, 0.5)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Pulsation pendant l'affichage
	await tween.finished
	var pulse_tween := create_tween().set_loops(3)
	pulse_tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.5).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.5).set_ease(Tween.EASE_IN_OUT)
	
	# Attendre selon le type - 1.5s pour les vagues, 3s pour les boss
	var display_time: float = 3.0 if is_boss else 1.5
	await get_tree().create_timer(display_time).timeout
	
	# Animation de disparition
	pulse_tween.kill()
	var fade_tween := create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(panel, "modulate:a", 0.0, 0.4)
	fade_tween.tween_property(panel, "scale", Vector2(1.2, 0.8), 0.4)
	fade_tween.tween_property(panel, "position:y", panel.position.y - 30, 0.4)
	await fade_tween.finished
	panel.queue_free()


func _apply_wave_bonus_to_hero() -> void:
	# BMAD Mode: Boost de +10% ATK et +10% HP pour chaque vague complétée
	wave_bonus_multiplier += 0.10  # Accumule: Wave1=1.10x, Wave2=1.20x, etc.
	
	var hero_visual: Control = hero_container.get_node_or_null("HeroVisual")
	if not hero_visual:
		push_error("[GameCombat] Hero visual not found for wave bonus!")
		return
	
	# Appliquer le boost aux stats du héros
	if hero:
		hero.base_stats.attack = int(hero.base_stats.attack * 1.10)
		hero.base_stats.max_hp = int(hero.base_stats.max_hp * 1.10)
		# Remplir la HP au maximum pour équité
		hero.base_stats.current_hp = hero.base_stats.max_hp
	
	# Affichage du boost avec une animation
	var boost_text_pos := hero_container.position + Vector2(-50, -120)
	_show_floating_text("⚡ POWER UP x%.2f ⚡" % wave_bonus_multiplier, boost_text_pos, Color(1.0, 0.85, 0.3), 24)
	
	# Animation de scintillement du héros
	if hero_visual:
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(hero_visual, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.2)
		tween.tween_property(hero_visual, "scale", Vector2(1.15, 1.15), 0.2)
		tween.chain()
		tween.tween_property(hero_visual, "modulate", Color.WHITE, 0.2)
		tween.tween_property(hero_visual, "scale", Vector2(1.0, 1.0), 0.2)
	
	print("[GameCombat] Wave bonus applied! Multiplier now: %.2f (ATK: %.2fx, HP: %.2fx)" % [wave_bonus_multiplier, wave_bonus_multiplier, wave_bonus_multiplier])


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
	
	# Fond stylisé (dégradé ou image DA)
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.10, 0.18, 0.98)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	cinematic_layer.add_child(bg)

	# Panneau pixel art responsive (anchors full rect, marges internes via MarginContainer)
	var viewport_size: Vector2 = get_viewport().size
	var margin_x: float = clamp(viewport_size.x * 0.05, 12, 40)
	var margin_y: float = clamp(viewport_size.y * 0.08, 12, 40)

	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.15, 0.22, 0.96)
	style.border_color = Color(0.4, 0.7, 1.0)
	style.set_border_width_all(4)
	style.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 0
	panel.offset_right = 0
	panel.offset_top = 0
	panel.offset_bottom = 0
	cinematic_layer.add_child(panel)

	# Marges internes pour le contenu
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", int(margin_x))
	margin.add_theme_constant_override("margin_right", int(margin_x))
	margin.add_theme_constant_override("margin_top", int(margin_y))
	margin.add_theme_constant_override("margin_bottom", int(margin_y))
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(margin)

	# Contenu centré dans le panneau
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_child(center)

	# Largeur max du contenu (évite d'étirer sur desktop)
	var content_box := VBoxContainer.new()
	content_box.add_theme_constant_override("separation", 18)
	content_box.custom_minimum_size.x = min(540, viewport_size.x - margin_x * 2)
	center.add_child(content_box)

	# Largeur de référence pour le contenu
	var content_w: float = content_box.custom_minimum_size.x

	# Emoji toujours affiché en haut (petit)
	var emoji := Label.new()
	emoji.text = slide_data.emoji
	emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var emoji_size: int = int(clamp(content_w * 0.10, 28, 48))
	emoji.add_theme_font_size_override("font_size", emoji_size)
	content_box.add_child(emoji)

	var character_name: String = slide_data.get("character", "")
	var panel_h: float = panel.size.y if panel.size.y > 0 else viewport_size.y
	# Increase max_h to allow larger portraits on small viewports; previously capped at 64 (too small)
	var max_h: float = min(panel_h * 0.30, 220)
	var max_w: float = content_w * 0.4
	if character_name == "mortis":
		var portrait := TextureRect.new()
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# Portrait Mortis: taille raisonnable (légèrement plus petit que le contenu)
		portrait.custom_minimum_size = Vector2(max_w * 0.9, max_h * 0.9)
		portrait.expand = true
		portrait.size_flags_horizontal = Control.SIZE_FILL
		portrait.size_flags_vertical = Control.SIZE_FILL
		var portrait_path := "res://assets/sprites/enemies/mini-boss.png"
		if ResourceLoader.exists(portrait_path):
			var tex = ResourceLoader.load(portrait_path)
			if tex and (tex is Texture or tex is Texture2D):
				portrait.texture = tex
				portrait.visible = true
				content_box.add_child(portrait)
				var portrait_spacer := Control.new()
				portrait_spacer.custom_minimum_size.y = 8
				content_box.add_child(portrait_spacer)
			else:
				push_warning("Portrait Mortis introuvable ou invalide: %s" % portrait_path)
				# Fallback emoji si la texture est corrompue/invalide
				var mortis_emoji := Label.new()
				mortis_emoji.text = "🧟‍♂️"
				mortis_emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				var mortis_size: int = int(clamp(content_w * 0.22, 48, 96))
				mortis_emoji.add_theme_font_size_override("font_size", mortis_size)
				content_box.add_child(mortis_emoji)
				var mortis_spacer := Control.new()
				mortis_spacer.custom_minimum_size.y = 8
				content_box.add_child(mortis_spacer)
		else:
			push_warning("Portrait Mortis introuvable: %s" % portrait_path)
			var mortis_emoji := Label.new()
			mortis_emoji.text = "🧟‍♂️"
			mortis_emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			var mortis_size2: int = int(clamp(content_w * 0.22, 48, 96))
			mortis_emoji.add_theme_font_size_override("font_size", mortis_size2)
			content_box.add_child(mortis_emoji)
			var mortis_spacer2 := Control.new()
			mortis_spacer2.custom_minimum_size.y = 8
			content_box.add_child(mortis_spacer2)
	else:
		var portrait := TextureRect.new()
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# Agrandir significativement le portrait du héros (alien)
		var hero_scale: float = 2.0
		portrait.custom_minimum_size = Vector2(max_w * hero_scale, max_h * hero_scale)
		portrait.expand = true
		portrait.size_flags_horizontal = Control.SIZE_FILL
		portrait.size_flags_vertical = Control.SIZE_FILL
		var portrait_path := "res://assets/sprites/hero/hero_ready.png"
		if ResourceLoader.exists(portrait_path):
			var tex_h = ResourceLoader.load(portrait_path)
			if tex_h and (tex_h is Texture or tex_h is Texture2D):
				portrait.texture = tex_h
				portrait.visible = true
				content_box.add_child(portrait)
				var portrait_spacer := Control.new()
				portrait_spacer.custom_minimum_size.y = 8
				content_box.add_child(portrait_spacer)
			else:
				# Fallback emoji si la texture du héros est invalide
				var zyx_emoji := Label.new()
				zyx_emoji.text = "👽"
				zyx_emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				var zyx_size: int = int(clamp(content_w * 0.30, 64, 140))
				zyx_emoji.add_theme_font_size_override("font_size", zyx_size)
				content_box.add_child(zyx_emoji)
				var zyx_spacer := Control.new()
				zyx_spacer.custom_minimum_size.y = 8
				content_box.add_child(zyx_spacer)
				push_warning("Portrait Zyx-7 invalide: %s" % portrait_path)
		else:
			# Fallback emoji si le sprite du héros n'existe pas
			var zyx_emoji := Label.new()
			zyx_emoji.text = "👽"
			zyx_emoji.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			var zyx_size: int = int(clamp(content_w * 0.30, 64, 140))
			zyx_emoji.add_theme_font_size_override("font_size", zyx_size)
			content_box.add_child(zyx_emoji)
			var zyx_spacer2 := Control.new()
			zyx_spacer2.custom_minimum_size.y = 8
			content_box.add_child(zyx_spacer2)
			push_warning("Portrait Zyx-7 introuvable: %s" % portrait_path)
	
	# Texte avec effet machine à écrire (toujours visible)
	var text_label := Label.new()
	text_label.name = "CinematicText"
	text_label.text = ""
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.custom_minimum_size.x = content_w * 0.9
	var font_size: int = int(clamp(content_w * 0.045, 14, 26))
	text_label.add_theme_font_size_override("font_size", font_size)
	text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	content_box.add_child(text_label)
	var full_text: String = slide_data.text
	_typewriter_effect(text_label, full_text)
	
	# Indicateur de planète
	var planet_indicator := Label.new()
	var planet_name: String = PLANET_COLORS.get(current_planet, PLANET_COLORS[0]).name
	planet_indicator.text = "📍 %s" % planet_name
	planet_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	planet_indicator.add_theme_font_size_override("font_size", 14)
	planet_indicator.add_theme_color_override("font_color", PLANET_COLORS.get(current_planet, PLANET_COLORS[0]).accent)
	content_box.add_child(planet_indicator)
	
	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 40
	content_box.add_child(spacer)
	
	# Bouton continuer
	var continue_btn := Button.new()
	continue_btn.text = "TAP TO CONTINUE ▶"
	continue_btn.custom_minimum_size = Vector2(clamp(content_w * 0.5, 120, 320), 44)

	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.2, 0.4, 0.6, 0.8)
	btn_style.border_color = Color(0.4, 0.7, 1.0)
	btn_style.set_border_width_all(2)
	btn_style.set_corner_radius_all(10)
	continue_btn.add_theme_stylebox_override("normal", btn_style)
	continue_btn.add_theme_font_size_override("font_size", int(clamp(content_w * 0.045, 14, 22)))
	continue_btn.add_theme_color_override("font_color", Color.WHITE)
	continue_btn.pressed.connect(_on_cinematic_continue)
	content_box.add_child(continue_btn)
	
	# Compteur de slides
	var slide_counter := Label.new()
	slide_counter.text = "%d / %d" % [cinematic_slide_index + 1, slides.size()]
	slide_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slide_counter.add_theme_font_size_override("font_size", 12)
	slide_counter.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	content_box.add_child(slide_counter)


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
	
	# Démarrer le combat avec titre de vague 1
	await get_tree().create_timer(0.5).timeout
	await _show_wave_title("⚔️ WAVE 1 ⚔️", Color.WHITE)
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
	# BMAD Mode: Boss prend 60% de l'espace (était 25%)
	var base_size: int = mini(432, int(viewport_size.x * 0.60))  # 60% de la largeur!
	var size_mult: float = 1.25 if is_final_boss else 1.0  # Dr. Mortis: 75% total (432 * 1.25 = 540px)
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
	
	# Positionner le boss à y = 0.55 du viewport (aligné avec héros/ennemis)
	visual.position = Vector2(
		(viewport_size.x * 0.5) - (visual.size.x * 0.5),
		(viewport_size.y * 0.55) - (visual.size.y * 0.5)
	)
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
