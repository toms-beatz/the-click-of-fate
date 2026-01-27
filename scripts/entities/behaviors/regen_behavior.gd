## RegenBehavior - Comportement des ennemis de Mars
##
## Caractéristiques:
## - Régénère 1% de ses PV max par seconde
## - Plus résistant dans le temps
## - Force le joueur à maintenir la pression
class_name RegenBehavior
extends EnemyBehavior

## Pourcentage de PV régénérés par seconde
const REGEN_PERCENT_PER_SEC := 0.01

## Accumulateur pour la régénération
var _regen_accumulator: float = 0.0


func _init() -> void:
	behavior_name = "Regen (Mars)"


func apply(enemy: BaseEnemy) -> void:
	# Les ennemis régénérants ont des stats normales au départ
	pass


func process(enemy: BaseEnemy, delta: float) -> void:
	if not enemy.is_alive or not enemy.base_stats:
		return
	
	# Accumuler le temps pour éviter de heal chaque frame
	_regen_accumulator += delta
	
	if _regen_accumulator >= 1.0:
		_regen_accumulator -= 1.0
		
		# Régénérer 1% des PV max
		var regen_amount := int(enemy.base_stats.max_hp * REGEN_PERCENT_PER_SEC)
		if regen_amount > 0:
			enemy.heal(regen_amount)
