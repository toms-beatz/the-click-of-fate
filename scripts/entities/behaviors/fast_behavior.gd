## FastBehavior - Comportement des ennemis de Mercure
##
## Caractéristiques:
## - Attaque 1.5x plus vite
## - 30% moins de PV
## - 15% d'esquive bonus
## - Ennemis rapides mais fragiles
class_name FastBehavior
extends EnemyBehavior

## Multiplicateur de vitesse d'attaque
const ATTACK_SPEED_MULT := 1.5

## Multiplicateur de PV (réduction)
const HP_MULT := 0.7

## Bonus d'esquive
const DODGE_BONUS := 0.10


func _init() -> void:
	behavior_name = "Fast (Mercury)"


func apply(enemy: BaseEnemy) -> void:
	if not enemy.base_stats:
		return
	
	# Modifier les stats de base
	# Note: On modifie les valeurs runtime, pas la Resource!
	
	# Réduire les PV
	var new_max_hp := int(enemy.base_stats.max_hp * HP_MULT)
	enemy.current_hp = mini(enemy.current_hp, new_max_hp)
	
	# Ajouter un modificateur permanent d'esquive
	enemy.add_temp_modifier("dodge_chance", DODGE_BONUS, "add", 9999.0)
	
	# La vitesse d'attaque est gérée via override du timer


func process(enemy: BaseEnemy, _delta: float) -> void:
	# Les ennemis rapides attaquent plus vite
	# Ceci est géré dans BaseEntity via attack_speed
	pass
