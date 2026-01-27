## AlienHero - Le personnage joueur (héros principal)
##
## Hérite de BaseEntity. Gère:
## - Compagnons (MedicalDrone, SupportUnit)
## - Skills actifs
## - Boost modificateurs temporaires
class_name AlienHero
extends BaseEntity

## Émis quand un skill est utilisé
## [param skill_id] Identifiant du skill
signal skill_used(skill_id: String)

## Émis quand un compagnon est ajouté
## [param companion] Le compagnon ajouté
signal companion_added(companion: Node)

## Émis quand un boost est appliqué
## [param boost_type] Type de boost ("dodge", "crit", "attack")
signal boost_applied(boost_type: String)


## Compagnons actifs
var companions: Array[Node] = []

## Skills débloqués (IDs)
var unlocked_skills: Array[String] = []

## Skills en cours de cooldown {skill_id: remaining_time}
var _skill_cooldowns: Dictionary = {}


func _ready() -> void:
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_update_skill_cooldowns(delta)


## Met à jour les cooldowns des skills
func _update_skill_cooldowns(delta: float) -> void:
	var to_remove: Array[String] = []
	
	for skill_id in _skill_cooldowns:
		_skill_cooldowns[skill_id] -= delta
		if _skill_cooldowns[skill_id] <= 0:
			to_remove.append(skill_id)
	
	for skill_id in to_remove:
		_skill_cooldowns.erase(skill_id)


## Ajoute un compagnon au héros
func add_companion(companion: Node) -> void:
	if companion not in companions:
		companions.append(companion)
		add_child(companion)
		companion_added.emit(companion)


## Retire un compagnon
func remove_companion(companion: Node) -> void:
	companions.erase(companion)
	if companion.get_parent() == self:
		remove_child(companion)


## Vérifie si un skill est disponible (pas en cooldown)
func is_skill_ready(skill_id: String) -> bool:
	return not _skill_cooldowns.has(skill_id)


## Active un skill
## [param skill_id] ID du skill à activer
## [param cooldown] Durée du cooldown après activation
func activate_skill(skill_id: String, cooldown: float) -> bool:
	if not is_skill_ready(skill_id):
		return false
	
	if skill_id not in unlocked_skills:
		return false
	
	_skill_cooldowns[skill_id] = cooldown
	skill_used.emit(skill_id)
	return true


## Débloque un skill
func unlock_skill(skill_id: String) -> void:
	if skill_id not in unlocked_skills:
		unlocked_skills.append(skill_id)


## Retourne le temps de cooldown restant pour un skill
func get_skill_cooldown(skill_id: String) -> float:
	return _skill_cooldowns.get(skill_id, 0.0)


## Applique un boost temporaire (appelé par CombatManager)
func apply_boost(boost_type: String, value: float, duration: float) -> void:
	add_temp_modifier(boost_type, value, "add", duration)
	boost_applied.emit(boost_type)


## Override: reset pour retry niveau
func reset() -> void:
	super.reset()
	_skill_cooldowns.clear()
