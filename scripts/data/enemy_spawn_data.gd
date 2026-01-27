## EnemySpawnData - Resource définissant le spawn d'un type d'ennemi
##
## Utilisé par WaveData pour configurer quels ennemis apparaissent.
class_name EnemySpawnData
extends Resource

## Scène de l'ennemi à instancier
@export var enemy_scene: PackedScene

## Stats de l'ennemi (si pas de scène, utiliser ces stats)
@export var enemy_stats: EntityStats

## Nombre d'ennemis de ce type
@export_range(1, 20) var count: int = 1

## Délai entre chaque spawn (secondes)
@export var spawn_interval: float = 0.5

## Délai avant de commencer à spawn ce groupe (secondes)
@export var initial_delay: float = 0.0

## Type de planète (pour le comportement)
@export var planet_type: BaseEnemy.PlanetType = BaseEnemy.PlanetType.MERCURY
