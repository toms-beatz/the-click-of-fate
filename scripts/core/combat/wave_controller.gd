## WaveController - Gère le spawning des vagues d'ennemis
##
## Responsabilités:
## - Charger les données de vague
## - Spawner les ennemis selon le timing défini
## - Notifier quand une vague est terminée
class_name WaveController
extends Node

## Émis quand une vague commence
## [param wave_number] Numéro de la vague (1-indexed pour affichage)
signal wave_started(wave_number: int)

## Émis quand tous les ennemis de la vague sont morts
signal wave_cleared()

## Émis quand un ennemi est spawné
## [param enemy] L'ennemi spawné
signal enemy_spawned(enemy: BaseEnemy)

## Émis quand la phase de boss commence
signal boss_phase_started()


## Container pour les ennemis spawnés
@export var enemy_container: Node

## Scène par défaut pour les ennemis (si pas de scène spécifique)
@export var default_enemy_scene: PackedScene

## Position de spawn des ennemis (côté droit)
@export var spawn_position: Vector2 = Vector2(500, 300)


## Données de la planète actuelle
var current_planet_data: PlanetData = null

## Index de la vague actuelle (0-based)
var current_wave_index: int = 0

## Ennemis actuellement en vie
var active_enemies: Array[BaseEnemy] = []

## Est-ce que le spawning est en cours?
var is_spawning: bool = false

## Référence au CombatManager pour connecter les ennemis
var combat_manager: CombatManager = null


## Configure le contrôleur avec les données d'une planète
func setup(planet_data: PlanetData, manager: CombatManager) -> void:
	current_planet_data = planet_data
	combat_manager = manager
	current_wave_index = 0
	active_enemies.clear()


## Démarre la vague actuelle
func start_wave() -> void:
	if not current_planet_data or current_planet_data.waves.is_empty():
		push_warning("WaveController: Pas de données de planète ou de vagues")
		return
	
	if current_wave_index >= current_planet_data.waves.size():
		# Toutes les vagues normales terminées, passer au boss
		_start_boss_wave()
		return
	
	var wave_data: WaveData = current_planet_data.waves[current_wave_index]
	wave_started.emit(wave_data.wave_number)
	
	# Attendre le délai initial puis spawner
	if wave_data.start_delay > 0:
		await get_tree().create_timer(wave_data.start_delay).timeout
	
	_spawn_wave(wave_data)


## Spawne une vague complète
func _spawn_wave(wave_data: WaveData) -> void:
	is_spawning = true
	
	for spawn_data in wave_data.enemy_spawns:
		# Attendre le délai initial de ce groupe
		if spawn_data.initial_delay > 0:
			await get_tree().create_timer(spawn_data.initial_delay).timeout
		
		# Spawner les ennemis de ce groupe
		for i in range(spawn_data.count):
			_spawn_enemy(spawn_data)
			
			# Attendre entre chaque spawn
			if spawn_data.spawn_interval > 0 and i < spawn_data.count - 1:
				await get_tree().create_timer(spawn_data.spawn_interval).timeout
	
	is_spawning = false


## Spawne un ennemi individuel
func _spawn_enemy(spawn_data: EnemySpawnData) -> void:
	var enemy: BaseEnemy = null
	
	# Utiliser la scène spécifique ou la scène par défaut
	if spawn_data.enemy_scene:
		enemy = spawn_data.enemy_scene.instantiate() as BaseEnemy
	elif default_enemy_scene:
		enemy = default_enemy_scene.instantiate() as BaseEnemy
	else:
		# Créer un ennemi basique si aucune scène
		enemy = BaseEnemy.new()
	
	if not enemy:
		push_warning("WaveController: Impossible de créer l'ennemi")
		return
	
	# Configurer l'ennemi
	if spawn_data.enemy_stats:
		enemy.base_stats = spawn_data.enemy_stats
	enemy.planet_type = spawn_data.planet_type
	
	# Positionner l'ennemi
	enemy.position = spawn_position + Vector2(randf_range(-20, 20), randf_range(-50, 50))
	
	# Ajouter au container
	if enemy_container:
		enemy_container.add_child(enemy)
	else:
		add_child(enemy)
	
	# Connecter les signaux
	enemy.died.connect(_on_enemy_died.bind(enemy))
	
	# Enregistrer l'ennemi
	active_enemies.append(enemy)
	
	# Notifier le CombatManager
	if combat_manager:
		combat_manager.add_enemy(enemy)
	
	enemy_spawned.emit(enemy)


## Démarre la vague de boss
func _start_boss_wave() -> void:
	if not current_planet_data or not current_planet_data.boss_wave:
		push_warning("WaveController: Pas de données de boss")
		return
	
	boss_phase_started.emit()
	_spawn_wave(current_planet_data.boss_wave)


## Callback quand un ennemi meurt
func _on_enemy_died(enemy: BaseEnemy) -> void:
	# Si référence invalide, nettoyer la liste et sortir
	if not is_instance_valid(enemy):
		active_enemies = active_enemies.filter(func(e): is_instance_valid(e))
		if active_enemies.is_empty() and not is_spawning:
			wave_cleared.emit()
		return

	active_enemies.erase(enemy)
    
	# Vérifier si la vague est terminée
	if active_enemies.is_empty() and not is_spawning:
		wave_cleared.emit()


## Passe à la vague suivante
func advance_to_next_wave() -> void:
	current_wave_index += 1


## Vérifie si c'est la dernière vague (boss)
func is_boss_wave() -> bool:
	if not current_planet_data:
		return false
	return current_wave_index >= current_planet_data.waves.size()


## Retourne le numéro de vague pour affichage (1-indexed)
func get_display_wave_number() -> int:
	return current_wave_index + 1


## Retourne le nombre total de vagues (sans le boss)
func get_total_waves() -> int:
	if not current_planet_data:
		return 0
	return current_planet_data.waves.size()


## Réinitialise le contrôleur (pour retry)
func reset() -> void:
	# Supprimer tous les ennemis actifs
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	active_enemies.clear()
	current_wave_index = 0
	is_spawning = false


## Retourne le nombre d'ennemis vivants
func get_alive_enemy_count() -> int:
	var count := 0
	for enemy in active_enemies:
		if is_instance_valid(enemy) and enemy.is_alive:
			count += 1
	return count
