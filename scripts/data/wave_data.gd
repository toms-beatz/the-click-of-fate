## WaveData - Resource définissant une vague d'ennemis
##
## Utilisé par PlanetData pour configurer chaque vague.
class_name WaveData
extends Resource

## Numéro de la vague (pour affichage)
@export var wave_number: int = 1

## Est-ce une vague de boss?
@export var is_boss_wave: bool = false

## Informations de spawn des ennemis
@export var enemy_spawns: Array[EnemySpawnData] = []

## Délai avant le début de la vague (secondes)
@export var start_delay: float = 1.0

## Monnaie gagnée en complétant cette vague
@export var wave_reward: int = 10
