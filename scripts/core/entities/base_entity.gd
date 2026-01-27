## BaseEntity - Classe mère pour toutes les entités de combat (Héros, Ennemis, Boss)
##
## Gère: PV, attaque automatique, dégâts, mort, signaux de combat.
## Héritiers: AlienHero, BaseEnemy, etc.
##
## @tutorial: Attacher ce script ou hériter, puis assigner une EntityStats Resource
class_name BaseEntity
extends Node2D

## Émis quand l'entité subit des dégâts
## [param amount] Dégâts effectivement subis (après défense)
## [param is_crit] True si c'était un coup critique
signal damaged(amount: int, is_crit: bool)

## Émis quand l'entité est soignée
## [param amount] PV restaurés
signal healed(amount: int)

## Émis quand l'entité meurt (PV <= 0)
signal died()

## Émis quand l'entité effectue une attaque
## [param target] La cible attaquée
## [param damage] Dégâts infligés
## [param is_crit] True si coup critique
signal attacked(target: BaseEntity, damage: int, is_crit: bool)

## Émis quand l'entité esquive une attaque
signal dodged()

## Émis quand les PV changent
## [param current] PV actuels
## [param max_hp] PV maximum
signal hp_changed(current: int, max_hp: int)


## Stats de base (Resource - ne pas modifier à runtime!)
@export var base_stats: EntityStats

## Sprite visuel de l'entité
@export var sprite: Sprite2D

## Cible actuelle pour l'auto-attaque (null = pas de cible)
var current_target: BaseEntity = null

## PV actuels
var current_hp: int = 0

## Est vivant?
var is_alive: bool = true

## Modificateurs temporaires de stats {stat_name: [{value, type, duration}]}
var _temp_modifiers: Dictionary = {}

## Timer interne pour l'attaque automatique
var _attack_timer: float = 0.0

## Est-ce que l'entité peut agir? (false pendant punishment, stun, etc.)
var can_act: bool = true


func _ready() -> void:
	_initialize_stats()


func _process(delta: float) -> void:
	if not is_alive or not can_act:
		return
	
	_update_modifiers(delta)
	_process_auto_attack(delta)


## Initialise les PV et stats à partir de base_stats
func _initialize_stats() -> void:
	if base_stats:
		current_hp = base_stats.max_hp
		hp_changed.emit(current_hp, base_stats.max_hp)
	else:
		push_warning("BaseEntity: base_stats non assigné pour " + name)
		current_hp = 100


## Traite l'attaque automatique
func _process_auto_attack(delta: float) -> void:
	if not current_target or not current_target.is_alive:
		return
	
	if not base_stats:
		return
	
	_attack_timer += delta
	var attack_interval := base_stats.get_attack_interval()
	
	if _attack_timer >= attack_interval:
		_attack_timer = 0.0
		perform_attack(current_target)


## Met à jour les modificateurs temporaires (décrémente durée)
func _update_modifiers(delta: float) -> void:
	var to_remove: Array[String] = []
	
	for stat_name in _temp_modifiers:
		var mods: Array = _temp_modifiers[stat_name]
		var expired: Array[int] = []
		
		for i in range(mods.size()):
			mods[i].duration -= delta
			if mods[i].duration <= 0:
				expired.append(i)
		
		# Supprimer les expirés (en ordre inverse pour garder les indices valides)
		expired.reverse()
		for idx in expired:
			mods.remove_at(idx)
		
		if mods.is_empty():
			to_remove.append(stat_name)
	
	for stat_name in to_remove:
		_temp_modifiers.erase(stat_name)


## Effectue une attaque sur la cible
## [param target] L'entité à attaquer
func perform_attack(target: BaseEntity) -> void:
	if not target or not target.is_alive or not base_stats:
		return
	
	# Calcul des dégâts avec modificateurs
	var mods := _get_modifiers_for_stat("attack")
	var damage := base_stats.calculate_attack_damage(mods)
	
	# Roll critique
	var crit_bonus := _get_total_modifier_value("crit_chance")
	var is_crit := base_stats.roll_critical(crit_bonus)
	
	if is_crit:
		damage = int(damage * base_stats.crit_multiplier)
	
	# Appliquer les dégâts à la cible
	target.take_damage(damage, is_crit)
	
	attacked.emit(target, damage, is_crit)


## Subit des dégâts
## [param amount] Dégâts bruts entrants
## [param is_crit] Était-ce un coup critique?
## [returns] Les dégâts effectivement subis
func take_damage(amount: int, is_crit: bool = false) -> int:
	if not is_alive:
		return 0
	
	# Vérifier l'esquive
	var dodge_bonus := _get_total_modifier_value("dodge_chance")
	if base_stats and base_stats.roll_dodge(dodge_bonus):
		dodged.emit()
		return 0
	
	# Calculer les dégâts après défense
	var defense_mod := int(_get_total_modifier_value("defense"))
	var final_damage := amount
	if base_stats:
		final_damage = base_stats.calculate_damage_taken(amount, defense_mod)
	
	current_hp = maxi(0, current_hp - final_damage)
	hp_changed.emit(current_hp, base_stats.max_hp if base_stats else 100)
	damaged.emit(final_damage, is_crit)
	
	if current_hp <= 0:
		_die()
	
	return final_damage


## Soigne l'entité
## [param amount] PV à restaurer
## [returns] Les PV effectivement restaurés
func heal(amount: int) -> int:
	if not is_alive or not base_stats:
		return 0
	
	var old_hp := current_hp
	current_hp = mini(current_hp + amount, base_stats.max_hp)
	var healed_amount := current_hp - old_hp
	
	if healed_amount > 0:
		hp_changed.emit(current_hp, base_stats.max_hp)
		healed.emit(healed_amount)
	
	return healed_amount


## Soigne d'un pourcentage des PV max
## [param percent] Pourcentage (0.0 - 1.0)
func heal_percent(percent: float) -> int:
	if not base_stats:
		return 0
	var amount := int(base_stats.max_hp * percent)
	return heal(amount)


## Gère la mort de l'entité
func _die() -> void:
	if not is_alive:
		return
	
	is_alive = false
	can_act = false
	died.emit()


## Ajoute un modificateur temporaire de stat
## [param stat_name] Nom de la stat ("attack", "crit_chance", "dodge_chance", "defense")
## [param value] Valeur du modificateur
## [param type] "add" (additionnel) ou "mult" (multiplicatif)
## [param duration] Durée en secondes
func add_temp_modifier(stat_name: String, value: float, type: String, duration: float) -> void:
	if not _temp_modifiers.has(stat_name):
		_temp_modifiers[stat_name] = []
	
	_temp_modifiers[stat_name].append({
		"value": value,
		"type": type,
		"duration": duration
	})


## Récupère tous les modificateurs pour une stat sous forme de tableau
func _get_modifiers_for_stat(stat_name: String) -> Array:
	if _temp_modifiers.has(stat_name):
		return _temp_modifiers[stat_name]
	return []


## Calcule la valeur totale des modificateurs additifs pour une stat
func _get_total_modifier_value(stat_name: String) -> float:
	var total := 0.0
	if _temp_modifiers.has(stat_name):
		for mod in _temp_modifiers[stat_name]:
			if mod.type == "add":
				total += mod.value
	return total


## Définit la cible d'attaque
func set_target(target: BaseEntity) -> void:
	current_target = target


## Retire la cible d'attaque
func clear_target() -> void:
	current_target = null


## Retourne le ratio de PV (0.0 - 1.0)
func get_hp_ratio() -> float:
	if not base_stats or base_stats.max_hp == 0:
		return 0.0
	return float(current_hp) / float(base_stats.max_hp)


## Réinitialise l'entité (pour retry niveau)
func reset() -> void:
	if base_stats:
		current_hp = base_stats.max_hp
	is_alive = true
	can_act = true
	_temp_modifiers.clear()
	_attack_timer = 0.0
	current_target = null
	hp_changed.emit(current_hp, base_stats.max_hp if base_stats else 100)
