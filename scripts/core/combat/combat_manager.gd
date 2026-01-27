## CombatManager - Orchestre le combat auto-battler
##
## Gère:
## - Les actions du joueur (Heal/Boost/Attack via clics)
## - L'auto-attaque des entités
## - La coordination entre PressureGauge, StateMachine et entités
## - Les effets des clics sur les probabilités
class_name CombatManager
extends Node

## Émis quand le joueur effectue une action via clic
## [param action] "heal", "boost", ou "attack"
## [param success] true si l'action a été effectuée
signal player_action(action: StringName, success: bool)

## Émis quand un critique est déclenché
signal critical_hit(damage: int)

## Émis quand une esquive réussit
signal dodge_success()

## Émis quand le héros est soigné
## [param amount] Montant soigné
signal hero_healed(amount: int)


## Valeurs de base des actions du joueur (planète 1 sans upgrades)
const BASE_HEAL_PERCENT := 0.03  # 3% des PV max
const BASE_BOOST_DODGE := 0.05   # +5% esquive temporaire
const BASE_ATTACK_DAMAGE := 5    # 5 dégâts

## Durée du boost temporaire (secondes)
const BOOST_DURATION := 3.0

## Bonus de crit quand le joueur clique Attack
const ATTACK_CLICK_CRIT_BONUS := 0.10  # +10% de crit pendant 1 attaque


## Références aux systèmes
@export var state_machine: CombatStateMachine
@export var pressure_gauge: PressureGauge
@export var hero: BaseEntity

## Ennemis actifs dans le combat
var active_enemies: Array[BaseEntity] = []

## Bonus de crit temporaire du prochain clic Attack
var _pending_crit_bonus: float = 0.0

## Bonus d'esquive actif
var _active_dodge_bonus: float = 0.0


func _ready() -> void:
	_connect_systems()


func _connect_systems() -> void:
	if state_machine:
		state_machine.state_changed.connect(_on_state_changed)
	
	if hero:
		hero.attacked.connect(_on_hero_attacked)
		hero.damaged.connect(_on_hero_damaged)
		hero.died.connect(_on_hero_died)
		hero.dodged.connect(_on_hero_dodged)


## Connecte le ClickZoneButton pour recevoir les inputs
func connect_click_zone(click_zone: ClickZoneButton) -> void:
	click_zone.zone_pressed.connect(_on_zone_pressed)


## Traite un clic sur une zone
func _on_zone_pressed(zone: StringName) -> void:
	if not state_machine or not state_machine.can_player_act():
		return
	
	if not pressure_gauge:
		_execute_action(zone)
		return
	
	# Enregistrer dans la jauge de pression
	var accepted := pressure_gauge.register_click(zone)
	
	if accepted:
		_execute_action(zone)
		player_action.emit(zone, true)
	else:
		player_action.emit(zone, false)


## Exécute l'action correspondante à la zone
func _execute_action(zone: StringName) -> void:
	match zone:
		&"heal":
			_do_heal()
		&"boost":
			_do_boost()
		&"attack":
			_do_attack()


## Action HEAL: Soigne le héros
func _do_heal() -> void:
	if not hero or not hero.is_alive:
		return
	
	var healed := hero.heal_percent(BASE_HEAL_PERCENT)
	if healed > 0:
		hero_healed.emit(healed)


## Action BOOST: Augmente temporairement l'esquive
func _do_boost() -> void:
	if not hero or not hero.is_alive:
		return
	
	# Ajouter un modificateur temporaire d'esquive
	hero.add_temp_modifier("dodge_chance", BASE_BOOST_DODGE, "add", BOOST_DURATION)
	_active_dodge_bonus = BASE_BOOST_DODGE


## Action ATTACK: Prépare un bonus de crit pour la prochaine attaque
func _do_attack() -> void:
	if not hero or not hero.is_alive:
		return
	
	# Le clic Attack augmente la chance de crit de la prochaine attaque
	hero.add_temp_modifier("crit_chance", ATTACK_CLICK_CRIT_BONUS, "add", 2.0)
	_pending_crit_bonus = ATTACK_CLICK_CRIT_BONUS
	
	# Optionnel: infliger des dégâts directs à l'ennemi le plus proche
	if not active_enemies.is_empty():
		var target := _get_first_alive_enemy()
		if target:
			target.take_damage(BASE_ATTACK_DAMAGE, false)


## Retourne le premier ennemi vivant
func _get_first_alive_enemy() -> BaseEntity:
	for enemy in active_enemies:
		if enemy and enemy.is_alive:
			return enemy
	return null


## Ajoute un ennemi au combat
func add_enemy(enemy: BaseEntity) -> void:
	if enemy not in active_enemies:
		active_enemies.append(enemy)
		enemy.died.connect(_on_enemy_died.bind(enemy))
		
		# L'ennemi cible le héros
		enemy.set_target(hero)
		
		# Le héros cible le premier ennemi s'il n'a pas de cible
		if hero and not hero.current_target:
			hero.set_target(enemy)


## Retire un ennemi du combat
func remove_enemy(enemy: BaseEntity) -> void:
	active_enemies.erase(enemy)
	
	# Mettre à jour la cible du héros si nécessaire
	if hero and hero.current_target == enemy:
		hero.set_target(_get_first_alive_enemy())


## Callback quand un ennemi meurt
func _on_enemy_died(enemy: BaseEntity) -> void:
	remove_enemy(enemy)
	
	# Vérifier si tous les ennemis sont morts
	if _are_all_enemies_dead() and state_machine:
		state_machine.on_wave_cleared()


## Vérifie si tous les ennemis sont morts
func _are_all_enemies_dead() -> bool:
	for enemy in active_enemies:
		if enemy and enemy.is_alive:
			return false
	return true


## Callback quand le héros attaque
func _on_hero_attacked(target: BaseEntity, damage: int, is_crit: bool) -> void:
	if is_crit:
		critical_hit.emit(damage)
	
	# Reset le bonus de crit après utilisation
	_pending_crit_bonus = 0.0


## Callback quand le héros subit des dégâts
func _on_hero_damaged(amount: int, _is_crit: bool) -> void:
	pass  # Peut être utilisé pour des effets visuels


## Callback quand le héros esquive
func _on_hero_dodged() -> void:
	dodge_success.emit()


## Callback quand le héros meurt
func _on_hero_died() -> void:
	if state_machine:
		state_machine.on_hero_died()


## Callback quand l'état du combat change
func _on_state_changed(_old_state: CombatStateMachine.State, new_state: CombatStateMachine.State) -> void:
	match new_state:
		CombatStateMachine.State.PUNISHED:
			# Désactiver les actions du héros pendant la punition
			if hero:
				hero.can_act = false
		CombatStateMachine.State.COMBAT, CombatStateMachine.State.BOSS_PHASE:
			# Réactiver les actions
			if hero:
				hero.can_act = true
		CombatStateMachine.State.VICTORY, CombatStateMachine.State.DEFEAT:
			# Arrêter le combat
			_clear_all_targets()


## Efface toutes les cibles (fin de combat)
func _clear_all_targets() -> void:
	if hero:
		hero.clear_target()
	for enemy in active_enemies:
		if enemy:
			enemy.clear_target()


## Réinitialise le combat (nouveau niveau)
func reset_combat() -> void:
	active_enemies.clear()
	_pending_crit_bonus = 0.0
	_active_dodge_bonus = 0.0
	
	if hero:
		hero.reset()


## Retourne le nombre d'ennemis vivants
func get_alive_enemy_count() -> int:
	var count := 0
	for enemy in active_enemies:
		if enemy and enemy.is_alive:
			count += 1
	return count


## Retourne les PV totaux des ennemis (pour la barre de vie)
func get_total_enemy_hp() -> Dictionary:
	var current := 0
	var max_hp := 0
	for enemy in active_enemies:
		if enemy and enemy.is_alive and enemy.base_stats:
			current += enemy.current_hp
			max_hp += enemy.base_stats.max_hp
	return {"current": current, "max": max_hp}
