## PressureGauge - Système de jauge de pression anti-spam
##
## Chaque action (Heal/Boost/Attack) a sa propre jauge qui s'incrémente au clic.
## Si une jauge atteint 100, le joueur est PUNI pendant 10 secondes.
## Decay automatique de 3 points/seconde par jauge.
##
## C'est le CŒUR du gameplay - force le joueur à varier ses actions.
class_name PressureGauge
extends Node

## Émis quand une jauge change de valeur
## [param action_type] "heal", "boost", ou "attack"
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
	&"heal": 30.0,
	&"boost": 20.0,
	&"attack": 5.0
}

## Seuil de déclenchement de la punition
const PRESSURE_THRESHOLD := 100.0

## Taux de decay par seconde (pour chaque jauge)
const DECAY_RATE := 3.0

## Durée de la punition en secondes
const PUNISHMENT_DURATION := 10.0


## Valeurs actuelles des jauges {action_type: float}
var _pressures: Dictionary = {
	&"heal": 0.0,
	&"boost": 0.0,
	&"attack": 0.0
}

## Est-ce que le joueur est actuellement puni?
var is_punished: bool = false

## Timer de punition restant
var _punishment_timer: float = 0.0


func _ready() -> void:
	# Initialiser les jauges à 0
	reset_all()


func _process(delta: float) -> void:
	if is_punished:
		_process_punishment(delta)
	else:
		_process_decay(delta)


## Traite le decay naturel de toutes les jauges
func _process_decay(delta: float) -> void:
	for action_type in _pressures:
		if _pressures[action_type] > 0.0:
			var old_value: float = _pressures[action_type]
			_pressures[action_type] = maxf(0.0, _pressures[action_type] - DECAY_RATE * delta)
			
			# Émettre seulement si changement significatif (évite spam de signaux)
			if absf(old_value - _pressures[action_type]) > 0.1:
				pressure_changed.emit(action_type, _pressures[action_type])


## Traite le timer de punition
func _process_punishment(delta: float) -> void:
	_punishment_timer -= delta
	
	if _punishment_timer <= 0.0:
		_end_punishment()


## Enregistre un clic sur une action
## [param action_type] "heal", "boost", ou "attack"
## [returns] true si l'action a été acceptée, false si bloquée
func register_click(action_type: StringName) -> bool:
	# Vérifier si puni
	if is_punished:
		action_blocked.emit(action_type)
		return false
	
	# Vérifier que l'action existe
	if not _pressures.has(action_type):
		push_warning("PressureGauge: action_type inconnu: " + str(action_type))
		return false
	
	# Incrémenter la jauge
	var increment: float = PRESSURE_INCREMENT.get(action_type, 0.0)
	_pressures[action_type] += increment
	
	pressure_changed.emit(action_type, _pressures[action_type])
	
	# Vérifier si seuil atteint
	if _pressures[action_type] >= PRESSURE_THRESHOLD:
		_start_punishment()
		return false  # L'action qui déclenche la punition n'est PAS exécutée
	
	return true


## Démarre la punition
func _start_punishment() -> void:
	is_punished = true
	_punishment_timer = PUNISHMENT_DURATION
	
	# Reset toutes les jauges pendant la punition
	for action_type in _pressures:
		_pressures[action_type] = 0.0
		pressure_changed.emit(action_type, 0.0)
	
	punishment_started.emit(PUNISHMENT_DURATION)


## Termine la punition
func _end_punishment() -> void:
	is_punished = false
	_punishment_timer = 0.0
	punishment_ended.emit()


## Retourne la valeur actuelle d'une jauge
## [param action_type] "heal", "boost", ou "attack"
func get_pressure(action_type: StringName) -> float:
	return _pressures.get(action_type, 0.0)


## Retourne le ratio d'une jauge (0.0 - 1.0)
## [param action_type] "heal", "boost", ou "attack"
func get_pressure_ratio(action_type: StringName) -> float:
	return _pressures.get(action_type, 0.0) / PRESSURE_THRESHOLD


## Retourne le temps de punition restant
func get_punishment_remaining() -> float:
	return _punishment_timer


## Retourne le ratio de punition restant (1.0 = plein, 0.0 = fini)
func get_punishment_ratio() -> float:
	if not is_punished:
		return 0.0
	return _punishment_timer / PUNISHMENT_DURATION


## Réinitialise toutes les jauges (pour nouveau niveau)
func reset_all() -> void:
	for action_type in _pressures:
		_pressures[action_type] = 0.0
		pressure_changed.emit(action_type, 0.0)
	
	is_punished = false
	_punishment_timer = 0.0


## Vérifie si une action peut être effectuée (pas puni)
func can_perform_action() -> bool:
	return not is_punished


## Retourne toutes les valeurs de pression sous forme de dictionnaire
func get_all_pressures() -> Dictionary:
	return _pressures.duplicate()
