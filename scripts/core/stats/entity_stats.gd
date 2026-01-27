## EntityStats - Resource contenant les stats de base d'une entité
## 
## Cette Resource définit l'ADN statistique de chaque entité (héros, ennemis, boss).
## Ne JAMAIS modifier cette Resource à runtime - copier les valeurs dans l'entité.
##
## @tutorial: Créer un .tres dans l'Inspector pour chaque type d'entité
class_name EntityStats
extends Resource

## Nom d'affichage de l'entité
@export var display_name: String = "Entity"

## Points de vie maximum
@export_range(1, 10000, 1) var max_hp: int = 100

## Dégâts de base par attaque
@export_range(1, 1000, 1) var attack: int = 10

## Vitesse d'attaque (attaques par seconde)
@export_range(0.1, 10.0, 0.1) var attack_speed: float = 1.0

## Réduction de dégâts (soustrait des dégâts reçus)
@export_range(0, 500, 1) var defense: int = 0

## Chance de critique (0.0 = 0%, 1.0 = 100%)
@export_range(0.0, 1.0, 0.01) var crit_chance: float = 0.05

## Multiplicateur de dégâts critiques
@export_range(1.0, 5.0, 0.1) var crit_multiplier: float = 1.5

## Chance d'esquive (0.0 = 0%, 1.0 = 100%)
@export_range(0.0, 1.0, 0.01) var dodge_chance: float = 0.05

## Vitesse de déplacement (pixels par seconde, pour les ennemis mobiles)
@export_range(0.0, 500.0, 1.0) var move_speed: float = 100.0


## Calcule les dégâts d'une attaque avec modificateurs
## [param modifiers] Array de dictionnaires {stat: String, value: float, type: "add"|"mult"}
func calculate_attack_damage(modifiers: Array = []) -> int:
	var final_attack := float(attack)
	
	for mod in modifiers:
		if mod.get("stat") == "attack":
			if mod.get("type") == "add":
				final_attack += mod.get("value", 0.0)
			elif mod.get("type") == "mult":
				final_attack *= mod.get("value", 1.0)
	
	return int(final_attack)


## Vérifie si une attaque est critique selon les modificateurs
## [param bonus_crit_chance] Bonus de chance de crit (ex: +0.1 = +10%)
func roll_critical(bonus_crit_chance: float = 0.0) -> bool:
	var total_crit := clampf(crit_chance + bonus_crit_chance, 0.0, 1.0)
	return randf() < total_crit


## Vérifie si une esquive réussit selon les modificateurs
## [param bonus_dodge_chance] Bonus de chance d'esquive (ex: +0.05 = +5%)
func roll_dodge(bonus_dodge_chance: float = 0.0) -> bool:
	var total_dodge := clampf(dodge_chance + bonus_dodge_chance, 0.0, 0.95)  # Cap à 95% max
	return randf() < total_dodge


## Retourne le temps entre deux attaques (en secondes)
func get_attack_interval() -> float:
	if attack_speed <= 0.0:
		return 999.0  # Pas d'attaque
	return 1.0 / attack_speed


## Calcule les dégâts reçus après application de la défense
## [param incoming_damage] Dégâts bruts entrants
## [param defense_modifier] Modificateur additionnel de défense
func calculate_damage_taken(incoming_damage: int, defense_modifier: int = 0) -> int:
	var total_defense := defense + defense_modifier
	var final_damage := maxi(1, incoming_damage - total_defense)  # Minimum 1 dégât
	return final_damage


## Crée une copie des stats pour modification runtime
func duplicate_for_runtime() -> EntityStats:
	return self.duplicate(true) as EntityStats
