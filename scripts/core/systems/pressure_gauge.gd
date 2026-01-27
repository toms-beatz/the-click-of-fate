## PressureGauge - Système de jauge de pression anti-spam
##
## Chaque action (Heal/Dodge/Attack) a sa propre jauge qui s'incrémente au clic.
## Si une jauge atteint 100, le joueur est PUNI (durée variable selon l'action).
## Decay automatique de 5 points/seconde par jauge.
##
## C'est le CŒUR du gameplay - force le joueur à varier ses actions.
class_name PressureGauge
extends Node

## Émis quand une jauge change de valeur
## [param action_type] "heal", "dodge", ou "attack"
## [param current_value] Valeur actuelle (0-100)
signal pressure_changed(action_type: StringName, current_value: float)

## Émis quand la punition commence
## [param duration] Durée de la punition en secondes
signal punishment_started(duration: float)

## Émis quand la punition se termine
signal punishment_ended()

## Émis quand une action est bloquée (pendant punishment)
signal action_blocked(action_type: StringName)


## Configuration des incréments par action
const PRESSURE_INCREMENT := {
	&"heal": 25.0,   # Heal spamé = dangereux (mais moins qu'avant)
	&"dodge": 20.0,  # Dodge abusé = moyen
	&"attack": 8.0   # Attack spam = léger
}

## Durées de punition VARIABLES par type d'overload
const PUNISHMENT_DURATION := {
	&"heal": 5.0,   # Heal overload = 5s (soigner trop = dangereux)
	&"dodge": 4.0,  # Dodge overload = 4s  
	&"attack": 3.0  # Attack overload = 3s (le plus court)
}

## Seuil de déclenchement de la punition
const PRESSURE_THRESHOLD := 100.0

## Taux de decay par seconde (pour chaque jauge) - PLUS RAPIDE
const DECAY_RATE := 5.0


## Valeurs actuelles des jauges {action_type: float}
var _pressures: Dictionary = {
	&"heal": 0.0,
	&"dodge": 0.0,
	&"attack": 0.0
}

## Est-ce que le joueur est actuellement puni?
var is_punished: bool = false

## Actions actuellement bloquées (par type)
var _blocked_actions: Dictionary = {
	&"heal": false,
	&"dodge": false,
	&"attack": false
}

## Timer de punition restant par action
var _punishment_timers: Dictionary = {
	&"heal": 0.0,
	&"dodge": 0.0,
	&"attack": 0.0
}

## Timer de punition restant (legacy pour affichage)
var _punishment_timer: float = 0.0

## Durée totale de la punition actuelle (pour le ratio)
var _current_punishment_duration: float = 0.0

## Type d'action qui a déclenché l'overload
var _overload_type: StringName = &""


func _ready() -> void:
	# Initialiser les jauges à 0
	reset_all()


func _process(delta: float) -> void:
	_process_punishment_timers(delta)
	_process_decay(delta)


## Traite les timers de punition par action
func _process_punishment_timers(delta: float) -> void:
	var any_blocked := false
	for action_type in _blocked_actions:
		if _blocked_actions[action_type]:
			_punishment_timers[action_type] -= delta
			if _punishment_timers[action_type] <= 0.0:
				_blocked_actions[action_type] = false
				_punishment_timers[action_type] = 0.0
			else:
				any_blocked = true
	
	# Mettre à jour l'état global pour compatibilité
	if is_punished and not any_blocked:
		is_punished = false
		_punishment_timer = 0.0
		punishment_ended.emit()
	elif any_blocked:
		# Mettre à jour le timer global avec le max des timers
		_punishment_timer = 0.0
		for action_type in _punishment_timers:
			_punishment_timer = maxf(_punishment_timer, _punishment_timers[action_type])


## Traite le decay naturel de toutes les jauges
func _process_decay(delta: float) -> void:
	for action_type in _pressures:
		# Ne pas decay les actions bloquées
		if _blocked_actions.get(action_type, false):
			continue
		
		if _pressures[action_type] > 0.0:
			var old_value: float = _pressures[action_type]
			_pressures[action_type] = maxf(0.0, _pressures[action_type] - DECAY_RATE * delta)
			
			# Émettre seulement si changement significatif (évite spam de signaux)
			if absf(old_value - _pressures[action_type]) > 0.1:
				pressure_changed.emit(action_type, _pressures[action_type])


## Enregistre un clic sur une action
## [param action_type] "heal", "dodge", ou "attack"
## [returns] true si l'action a été acceptée, false si bloquée
func register_click(action_type: StringName) -> bool:
	# Convertir "boost" en "dodge" pour compatibilité
	var actual_type := action_type
	if action_type == &"boost":
		actual_type = &"dodge"
	
	# Vérifier si CETTE action est bloquée
	if _blocked_actions.get(actual_type, false):
		action_blocked.emit(actual_type)
		return false
	
	# Vérifier que l'action existe
	if not _pressures.has(actual_type):
		push_warning("PressureGauge: action_type inconnu: " + str(actual_type))
		return false
	
	# Incrémenter la jauge
	var increment: float = PRESSURE_INCREMENT.get(actual_type, 0.0)
	_pressures[actual_type] += increment
	
	pressure_changed.emit(actual_type, _pressures[actual_type])
	
	# Vérifier si seuil atteint
	if _pressures[actual_type] >= PRESSURE_THRESHOLD:
		_start_punishment(actual_type)
		return false  # L'action qui déclenche la punition n'est PAS exécutée
	
	return true


## Démarre la punition UNIQUEMENT pour l'action qui a overload
func _start_punishment(overload_type: StringName) -> void:
	is_punished = true
	_overload_type = overload_type
	
	# Bloquer SEULEMENT cette action
	var duration: float = PUNISHMENT_DURATION.get(overload_type, 4.0)
	_blocked_actions[overload_type] = true
	_punishment_timers[overload_type] = duration
	_current_punishment_duration = duration
	_punishment_timer = duration
	
	# Reset SEULEMENT la jauge de l'action bloquée
	_pressures[overload_type] = 0.0
	pressure_changed.emit(overload_type, 0.0)
	
	punishment_started.emit(duration)


## Retourne si une action spécifique est bloquée
func is_action_blocked(action_type: StringName) -> bool:
	var actual_type := action_type
	if action_type == &"boost":
		actual_type = &"dodge"
	return _blocked_actions.get(actual_type, false)


## Retourne le temps de blocage restant pour une action
func get_action_block_remaining(action_type: StringName) -> float:
	var actual_type := action_type
	if action_type == &"boost":
		actual_type = &"dodge"
	return _punishment_timers.get(actual_type, 0.0)


## Retourne la valeur actuelle d'une jauge
## [param action_type] "heal", "dodge", ou "attack"
func get_pressure(action_type: StringName) -> float:
	return _pressures.get(action_type, 0.0)


## Retourne le ratio d'une jauge (0.0 - 1.0)
## [param action_type] "heal", "dodge", ou "attack"
func get_pressure_ratio(action_type: StringName) -> float:
	return _pressures.get(action_type, 0.0) / PRESSURE_THRESHOLD


## Retourne le temps de punition restant
func get_punishment_remaining() -> float:
	return _punishment_timer


## Retourne le ratio de punition restant (1.0 = plein, 0.0 = fini)
func get_punishment_ratio() -> float:
	if not is_punished or _current_punishment_duration <= 0:
		return 0.0
	return _punishment_timer / _current_punishment_duration


## Retourne le type d'overload qui a causé la punition
func get_overload_type() -> StringName:
	return _overload_type


## Réinitialise toutes les jauges (pour nouveau niveau)
func reset_all() -> void:
	for action_type in _pressures:
		_pressures[action_type] = 0.0
		pressure_changed.emit(action_type, 0.0)
	
	# Reset aussi les blocages
	for action_type in _blocked_actions:
		_blocked_actions[action_type] = false
		_punishment_timers[action_type] = 0.0
	
	is_punished = false
	_punishment_timer = 0.0


## Vérifie si une action peut être effectuée (pas puni)
func can_perform_action() -> bool:
	return not is_punished


## Retourne toutes les valeurs de pression sous forme de dictionnaire
func get_all_pressures() -> Dictionary:
	return _pressures.duplicate()
