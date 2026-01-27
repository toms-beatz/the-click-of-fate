## TestCombatScene - Scène de test pour valider le gameplay complet
##
## Cette scène assemble tous les systèmes pour tester:
## - Click Zone tripartite
## - Jauge de pression
## - Combat auto-battler
## - État du jeu
extends Node2D

## Références aux systèmes (créés dynamiquement)
var pressure_gauge: PressureGauge
var state_machine: CombatStateMachine
var combat_manager: CombatManager
var combat_hud: CombatHUD
var hero: AlienHero
var wave_controller: WaveController


func _ready() -> void:
	_setup_systems()
	_setup_hero()
	_setup_ui()
	_connect_signals()
	_spawn_test_enemy()
	
	# Démarrer le combat
	state_machine.start_combat()


func _setup_systems() -> void:
	# Créer le système de pression
	pressure_gauge = PressureGauge.new()
	pressure_gauge.name = "PressureGauge"
	add_child(pressure_gauge)
	
	# Créer la state machine
	state_machine = CombatStateMachine.new()
	state_machine.name = "CombatStateMachine"
	add_child(state_machine)
	state_machine.connect_pressure_gauge(pressure_gauge)
	
	# Créer le combat manager
	combat_manager = CombatManager.new()
	combat_manager.name = "CombatManager"
	combat_manager.state_machine = state_machine
	combat_manager.pressure_gauge = pressure_gauge
	add_child(combat_manager)
	
	# Créer le wave controller
	wave_controller = WaveController.new()
	wave_controller.name = "WaveController"
	wave_controller.combat_manager = combat_manager
	add_child(wave_controller)


func _setup_hero() -> void:
	# Créer le héros
	hero = AlienHero.new()
	hero.name = "AlienHero"
	hero.position = Vector2(150, 400)
	
	# Charger les stats du héros
	var hero_stats := preload("res://data/entities/alien_hero_stats.tres")
	if hero_stats:
		hero.base_stats = hero_stats
	else:
		# Stats par défaut si pas de fichier
		var default_stats := EntityStats.new()
		default_stats.display_name = "Alien Hero"
		default_stats.max_hp = 100
		default_stats.attack = 5
		default_stats.attack_speed = 1.0
		hero.base_stats = default_stats
	
	add_child(hero)
	
	# Connecter au combat manager
	combat_manager.hero = hero
	
	# Ajouter un visuel simple pour le héros
	var hero_visual := ColorRect.new()
	hero_visual.color = Color(0.2, 0.8, 0.3)
	hero_visual.size = Vector2(60, 80)
	hero_visual.position = Vector2(-30, -40)
	hero.add_child(hero_visual)
	
	var hero_label := Label.new()
	hero_label.text = "HERO"
	hero_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hero_label.position = Vector2(-25, -60)
	hero.add_child(hero_label)


func _setup_ui() -> void:
	# Créer le HUD de combat
	combat_hud = CombatHUD.new()
	combat_hud.name = "CombatHUD"
	add_child(combat_hud)
	
	# Connecter le pressure gauge au HUD
	combat_hud.connect_pressure_gauge(pressure_gauge)
	
	# Connecter le click zone au combat manager
	var click_zone := combat_hud.get_click_zone()
	if click_zone:
		combat_manager.connect_click_zone(click_zone)
	
	# Label de debug pour l'état
	var debug_label := Label.new()
	debug_label.name = "DebugLabel"
	debug_label.position = Vector2(10, 100)
	debug_label.add_theme_font_size_override("font_size", 16)
	add_child(debug_label)


func _connect_signals() -> void:
	# Signaux du combat manager
	combat_manager.player_action.connect(_on_player_action)
	combat_manager.critical_hit.connect(_on_critical_hit)
	combat_manager.dodge_success.connect(_on_dodge_success)
	combat_manager.hero_healed.connect(_on_hero_healed)
	
	# Signaux de la state machine
	state_machine.state_changed.connect(_on_state_changed)
	state_machine.victory.connect(_on_victory)
	state_machine.defeat.connect(_on_defeat)
	
	# Signaux du pressure gauge
	pressure_gauge.punishment_started.connect(_on_punishment_started)
	pressure_gauge.punishment_ended.connect(_on_punishment_ended)
	
	# Signaux du héros
	hero.hp_changed.connect(_on_hero_hp_changed)


func _spawn_test_enemy() -> void:
	# Créer un ennemi de test (type Mercure - rapide)
	var enemy := BaseEnemy.new()
	enemy.name = "TestEnemy"
	enemy.position = Vector2(550, 400)
	enemy.planet_type = BaseEnemy.PlanetType.MERCURY
	
	# Stats de l'ennemi
	var enemy_stats := EntityStats.new()
	enemy_stats.display_name = "Mercury Scout"
	enemy_stats.max_hp = 50
	enemy_stats.attack = 3
	enemy_stats.attack_speed = 1.5
	enemy_stats.dodge_chance = 0.1
	enemy.base_stats = enemy_stats
	
	add_child(enemy)
	
	# Visuel simple pour l'ennemi
	var enemy_visual := ColorRect.new()
	enemy_visual.color = Color(0.9, 0.3, 0.2)
	enemy_visual.size = Vector2(50, 70)
	enemy_visual.position = Vector2(-25, -35)
	enemy.add_child(enemy_visual)
	
	var enemy_label := Label.new()
	enemy_label.text = "ENEMY"
	enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enemy_label.position = Vector2(-30, -55)
	enemy.add_child(enemy_label)
	
	# Connecter les signaux
	enemy.hp_changed.connect(_on_enemy_hp_changed)
	
	# Ajouter au combat
	combat_manager.add_enemy(enemy)


func _process(_delta: float) -> void:
	_update_debug_display()
	_update_hp_bars()


func _update_debug_display() -> void:
	var debug_label: Label = get_node_or_null("DebugLabel")
	if not debug_label:
		return
	
	var debug_text := "=== DEBUG ===\n"
	debug_text += "État: %s\n" % state_machine.get_state_name()
	debug_text += "Pression Heal: %.0f/100\n" % pressure_gauge.get_pressure(&"heal")
	debug_text += "Pression Boost: %.0f/100\n" % pressure_gauge.get_pressure(&"boost")
	debug_text += "Pression Attack: %.0f/100\n" % pressure_gauge.get_pressure(&"attack")
	
	if pressure_gauge.is_punished:
		debug_text += "⚠️ PUNI: %.1fs restantes\n" % pressure_gauge.get_punishment_remaining()
	
	debug_text += "\nHéros HP: %d/%d" % [hero.current_hp, hero.base_stats.max_hp]
	debug_text += "\nEnnemis vivants: %d" % combat_manager.get_alive_enemy_count()
	
	debug_label.text = debug_text


func _update_hp_bars() -> void:
	if hero and hero.base_stats:
		combat_hud.update_hero_hp(hero.current_hp, hero.base_stats.max_hp)
	
	var enemy_hp := combat_manager.get_total_enemy_hp()
	combat_hud.update_enemy_hp(enemy_hp.current, enemy_hp.max)


# ==================== CALLBACKS ====================

func _on_player_action(action: StringName, success: bool) -> void:
	print("[ACTION] %s - %s" % [action, "OK" if success else "BLOQUÉ"])


func _on_critical_hit(damage: int) -> void:
	print("[CRIT!] %d dégâts" % damage)


func _on_dodge_success() -> void:
	print("[DODGE] Esquive réussie!")


func _on_hero_healed(amount: int) -> void:
	print("[HEAL] +%d HP" % amount)


func _on_state_changed(old_state: CombatStateMachine.State, new_state: CombatStateMachine.State) -> void:
	print("[STATE] %s → %s" % [CombatStateMachine.State.keys()[old_state], CombatStateMachine.State.keys()[new_state]])


func _on_victory() -> void:
	print("🎉 VICTOIRE!")


func _on_defeat() -> void:
	print("💀 DÉFAITE - Retry avec ressources conservées")


func _on_punishment_started(duration: float) -> void:
	print("⚠️ PUNITION! Bloqué pendant %.0f secondes" % duration)


func _on_punishment_ended() -> void:
	print("✅ Punition terminée")


func _on_hero_hp_changed(current: int, max_hp: int) -> void:
	pass  # Géré par update_hp_bars


func _on_enemy_hp_changed(current: int, max_hp: int) -> void:
	pass  # Géré par update_hp_bars
