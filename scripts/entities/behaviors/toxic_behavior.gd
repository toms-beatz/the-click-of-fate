## ToxicBehavior - Comportement des ennemis de Vénus
##
## Caractéristiques:
## - Inflige du poison sur hit (2 DPS pendant 5s)
## - Stats normales
## - Atmosphère toxique
class_name ToxicBehavior
extends EnemyBehavior

## Dégâts de poison par seconde
const POISON_DPS := 2

## Durée du poison en secondes
const POISON_DURATION := 5.0


func _init() -> void:
	behavior_name = "Toxic (Venus)"


func apply(enemy: BaseEnemy) -> void:
	# Les ennemis toxiques ont des stats normales
	# L'effet poison est appliqué lors des attaques
	pass


func process(enemy: BaseEnemy, _delta: float) -> void:
	# Le poison est géré via un effet sur la cible après attaque
	# Ceci nécessite une extension du système de combat
	pass


## Applique l'effet poison à une cible (appelé après une attaque réussie)
static func apply_poison_to(target: BaseEntity) -> void:
	if not target or not target.is_alive:
		return
	
	# Créer un timer pour le poison
	var poison_timer := Timer.new()
	poison_timer.wait_time = 1.0
	poison_timer.one_shot = false
	target.add_child(poison_timer)
	
	var ticks_remaining := int(POISON_DURATION)
	
	poison_timer.timeout.connect(func():
		if target.is_alive:
			target.take_damage(POISON_DPS, false)
		ticks_remaining -= 1
		if ticks_remaining <= 0:
			poison_timer.stop()
			poison_timer.queue_free()
	)
	
	poison_timer.start()
