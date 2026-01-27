## CombatStateMachine - Gère les états du combat
##
## États:
## - IDLE: Attente (avant/après combat)
## - COMBAT: Boucle principale active
## - BOSS_PHASE: Combat de boss avec patterns spéciaux
## - PUNISHED: Joueur puni (10s), aucune commande
## - VICTORY: Vague terminée
## - DEFEAT: PV à 0 (garde ressources, retry niveau)
class_name CombatStateMachine
extends Node

## Émis quand l'état change
## [param old_state] État précédent
## [param new_state] Nouvel état
signal state_changed(old_state: State, new_state: State)

## Émis quand le combat commence
signal combat_started()

## Émis quand une vague est terminée
## [param wave_number] Numéro de la vague terminée
signal wave_completed(wave_number: int)

## Émis quand le boss est vaincu
signal boss_defeated()

## Émis quand le joueur gagne (toutes vagues + boss)
signal victory()

## Émis quand le joueur perd (PV héros = 0)
signal defeat()


## États possibles du combat
enum State {
	IDLE,        ## Attente avant/après combat
	COMBAT,      ## Combat actif contre vague normale
	BOSS_PHASE,  ## Combat contre le boss
	PUNISHED,    ## Joueur puni (jauge de pression)
	VICTORY,     ## Victoire de la vague/niveau
	DEFEAT       ## Défaite (retry avec ressources)
}

## État actuel
var current_state: State = State.IDLE

## État avant la punition (pour y retourner après)
var _state_before_punishment: State = State.IDLE

## Numéro de la vague actuelle (0-4 pour normales, 5 pour boss)
var current_wave: int = 0

## Nombre total de vagues (sans le boss)
const WAVES_PER_PLANET: int = 5

## Référence au PressureGauge (pour détecter les punitions)
var pressure_gauge: PressureGauge


func _ready() -> void:
	_enter_state(State.IDLE)


## Connecte le PressureGauge pour gérer les transitions de punition
## NOTE: On ne change plus l'état global car l'overload est maintenant par action
func connect_pressure_gauge(gauge: PressureGauge) -> void:
	pressure_gauge = gauge
	# Ne plus écouter les signaux de punition globale
	# Le blocage est maintenant géré par action dans le ClickZoneButton
	# pressure_gauge.punishment_started.connect(_on_punishment_started)
	# pressure_gauge.punishment_ended.connect(_on_punishment_ended)


## Démarre le combat (appelé pour lancer une vague)
func start_combat() -> void:
	if current_state != State.IDLE and current_state != State.VICTORY:
		push_warning("CombatStateMachine: Impossible de démarrer le combat depuis l'état " + State.keys()[current_state])
		return
	
	_change_state(State.COMBAT)
	combat_started.emit()


## Démarre la phase de boss
func start_boss_phase() -> void:
	if current_state != State.VICTORY:
		push_warning("CombatStateMachine: Boss phase uniquement après victoire de vague")
		return
	
	_change_state(State.BOSS_PHASE)


## Appelé quand tous les ennemis de la vague sont morts
func on_wave_cleared() -> void:
	if current_state == State.COMBAT:
		current_wave += 1
		wave_completed.emit(current_wave)
		
		if current_wave >= WAVES_PER_PLANET:
			# Toutes les vagues normales terminées → Victoire!
			_change_state(State.VICTORY)
			victory.emit()
		else:
			# Entre les vagues - rester en IDLE pour la transition
			# Le jeu appellera start_combat() pour la prochaine vague
			_change_state(State.IDLE)
	elif current_state == State.BOSS_PHASE:
		boss_defeated.emit()
		_change_state(State.VICTORY)
		victory.emit()


## Appelé quand le héros meurt
func on_hero_died() -> void:
	if current_state == State.COMBAT or current_state == State.BOSS_PHASE:
		_change_state(State.DEFEAT)
		defeat.emit()


## Réinitialise pour retry le niveau (après défaite)
## IMPORTANT: Le joueur garde ses ressources!
func retry_level() -> void:
	current_wave = 0
	_change_state(State.IDLE)


## Réinitialise complètement pour nouvelle planète
func reset_for_new_planet() -> void:
	current_wave = 0
	_change_state(State.IDLE)


## Callback quand la punition commence
func _on_punishment_started(_duration: float) -> void:
	if current_state == State.COMBAT or current_state == State.BOSS_PHASE:
		_state_before_punishment = current_state
		_change_state(State.PUNISHED)


## Callback quand la punition se termine
func _on_punishment_ended() -> void:
	if current_state == State.PUNISHED:
		_change_state(_state_before_punishment)


## Change l'état avec notification
func _change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	var old_state := current_state
	_exit_state(old_state)
	current_state = new_state
	_enter_state(new_state)
	
	state_changed.emit(old_state, new_state)


## Actions à l'entrée d'un état
func _enter_state(state: State) -> void:
	match state:
		State.IDLE:
			pass  # Attente
		State.COMBAT:
			pass  # Combat actif
		State.BOSS_PHASE:
			pass  # Boss fight
		State.PUNISHED:
			pass  # Bloqué
		State.VICTORY:
			pass  # Afficher victoire
		State.DEFEAT:
			pass  # Afficher défaite


## Actions à la sortie d'un état
func _exit_state(state: State) -> void:
	match state:
		State.PUNISHED:
			pass  # Déblocage


## Vérifie si le joueur peut effectuer des actions
func can_player_act() -> bool:
	return current_state == State.COMBAT or current_state == State.BOSS_PHASE


## Vérifie si le combat est actif
func is_combat_active() -> bool:
	return current_state == State.COMBAT or current_state == State.BOSS_PHASE or current_state == State.PUNISHED


## Retourne le nom de l'état actuel (pour debug/UI)
func get_state_name() -> String:
	return State.keys()[current_state]


## Vérifie si c'est le moment du boss
func is_boss_time() -> bool:
	return current_wave >= WAVES_PER_PLANET


## Retourne le numéro de vague pour affichage (1-indexed)
func get_display_wave_number() -> int:
	return current_wave + 1
