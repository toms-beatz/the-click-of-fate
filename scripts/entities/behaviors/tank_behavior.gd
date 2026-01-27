## TankBehavior - Comportement des ennemis de la Terre
##
## Caractéristiques:
## - 50% de défense en plus
## - 30% de PV en plus
## - Aucune faiblesse
## - Les plus résistants du jeu
class_name TankBehavior
extends EnemyBehavior

## Multiplicateur de défense
const DEFENSE_MULT := 1.5

## Multiplicateur de PV
const HP_MULT := 1.3


func _init() -> void:
	behavior_name = "Tank (Earth)"


func apply(enemy: BaseEnemy) -> void:
	if not enemy.base_stats:
		return
	
	# Augmenter les PV (runtime seulement)
	var bonus_hp := int(enemy.base_stats.max_hp * (HP_MULT - 1.0))
	enemy.current_hp += bonus_hp
	
	# Ajouter un modificateur de défense permanent
	var bonus_defense := enemy.base_stats.defense * (DEFENSE_MULT - 1.0)
	enemy.add_temp_modifier("defense", bonus_defense, "add", 9999.0)


func process(enemy: BaseEnemy, _delta: float) -> void:
	# Les tanks n'ont pas d'effet spécial continu
	pass
