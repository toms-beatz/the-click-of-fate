## EnemyBehavior - Classe de base pour les comportements d'ennemis
##
## Chaque planète a un comportement unique qui modifie les stats ou ajoute des effets.
## Les comportements sont des objets légers (pas des Nodes) pour la performance.
class_name EnemyBehavior
extends RefCounted

## Nom du comportement (pour debug)
var behavior_name: String = "Base"


## Applique les modifications initiales à l'ennemi
## Appelé une fois à _ready()
func apply(enemy: BaseEnemy) -> void:
	pass  # Override dans les sous-classes


## Traitement chaque frame (effets continus)
## Appelé dans _process()
func process(enemy: BaseEnemy, delta: float) -> void:
	pass  # Override si nécessaire
