## BaseEnemy - Classe de base pour tous les ennemis
##
## Hérite de BaseEntity. Gère:
## - Comportement spécifique par planète
## - Type d'ennemi
## - Valeur de loot
class_name BaseEnemy
extends BaseEntity

## Type de planète d'origine
enum PlanetType { MERCURY, VENUS, MARS, EARTH }

## Planète d'origine de l'ennemi
@export var planet_type: PlanetType = PlanetType.MERCURY

## Valeur de loot (monnaie SC) à la mort
@export var loot_value: int = 5

## Comportement spécifique (assigné selon la planète)
var behavior: EnemyBehavior = null


func _ready() -> void:
	super._ready()
	_apply_planet_behavior()


func _process(delta: float) -> void:
	super._process(delta)
	
	if behavior and is_alive:
		behavior.process(self, delta)


## Applique le comportement selon la planète
func _apply_planet_behavior() -> void:
	match planet_type:
		PlanetType.MERCURY:
			behavior = FastBehavior.new()
		PlanetType.VENUS:
			behavior = ToxicBehavior.new()
		PlanetType.MARS:
			behavior = RegenBehavior.new()
		PlanetType.EARTH:
			behavior = TankBehavior.new()
	
	if behavior:
		behavior.apply(self)


## Override: appelé à la mort
func _die() -> void:
	super._die()
	# Le loot sera géré par le système de progression
