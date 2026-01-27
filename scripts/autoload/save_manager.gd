## SaveManager - Singleton de gestion de la sauvegarde
##
## Gère la persistance des données joueur:
## - Monnaie (SC - Solar Credits)
## - Progression (planète/vague actuelle)
## - Skills débloqués
## - Upgrades achetés
## - Statistiques
##
## IMPORTANT: Le joueur garde TOUT à la mort (progression linéaire, pas de roguelite)
##
## Usage: Ajouter comme Autoload dans project.godot
## Note: Pas de class_name car c'est un autoload (accessible via SaveManager directement)
extends Node

## Émis après une sauvegarde réussie
signal save_completed()

## Émis après un chargement réussi
signal load_completed()

## Émis en cas d'erreur
signal save_error(message: String)

## Émis quand la monnaie change
signal currency_changed(new_amount: int)

## Émis quand la progression change
signal progression_changed()


## Chemin du fichier de sauvegarde principal
const SAVE_PATH := "user://save_data.json"

## Chemin du backup
const BACKUP_PATH := "user://save_data.backup.json"

## Version du format de sauvegarde (pour migrations futures)
const SAVE_VERSION := 1


## Données de sauvegarde actuelles
var data: Dictionary = {}

## Est-ce que les données ont été chargées?
var is_loaded: bool = false


func _ready() -> void:
	_initialize_default_data()
	load_game()


func _notification(what: int) -> void:
	# Sauvegarder à la fermeture de l'app
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save_game()


## Initialise les données par défaut
func _initialize_default_data() -> void:
	data = {
		"version": SAVE_VERSION,
		"currency_sc": 0,
		"current_planet": 0,  # 0 = Mercury, 1 = Venus, 2 = Mars, 3 = Earth
		"current_wave": 0,    # 0-4 = vagues normales, 5 = boss
		"highest_planet_completed": -1,  # -1 = aucune planète terminée
		"unlocked_skills": [],
		"unlocked_companions": [],
		"upgrades": {
			"heal_power": 0,    # Niveau actuel
			"max_hp": 0,
			"dodge_chance": 0,
			"attack_power": 0
		},
		"statistics": {
			"total_kills": 0,
			"total_deaths": 0,
			"bosses_defeated": [],
			"play_time_seconds": 0,
			"total_currency_earned": 0
		},
		"settings": {
			"music_volume": 0.8,
			"sfx_volume": 1.0,
			"vibration_enabled": true
		}
	}


## Sauvegarde les données dans un fichier JSON
func save_game() -> void:
	# Créer un backup d'abord
	if FileAccess.file_exists(SAVE_PATH):
		var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
		if backup:
			var original := FileAccess.open(SAVE_PATH, FileAccess.READ)
			if original:
				backup.store_string(original.get_as_text())
				original.close()
			backup.close()
	
	# Sauvegarder les nouvelles données
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		save_error.emit("Impossible d'ouvrir le fichier de sauvegarde")
		return
	
	var json_string := JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	
	save_completed.emit()


## Charge les données depuis le fichier JSON
func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		# Pas de sauvegarde existante, utiliser les données par défaut
		is_loaded = true
		load_completed.emit()
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		save_error.emit("Impossible de lire le fichier de sauvegarde")
		return
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	
	if parse_result != OK:
		# Essayer le backup
		if FileAccess.file_exists(BACKUP_PATH):
			_load_from_backup()
		else:
			save_error.emit("Fichier de sauvegarde corrompu")
		return
	
	var loaded_data: Variant = json.data
	if loaded_data is Dictionary:
		_merge_save_data(loaded_data)
	
	is_loaded = true
	load_completed.emit()


## Charge depuis le backup
func _load_from_backup() -> void:
	var file := FileAccess.open(BACKUP_PATH, FileAccess.READ)
	if not file:
		save_error.emit("Backup également corrompu")
		return
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	if json.parse(json_string) == OK and json.data is Dictionary:
		_merge_save_data(json.data)
		save_game()  # Restaurer la sauvegarde principale


## Fusionne les données chargées avec les valeurs par défaut
## Garantit que toutes les clés existent
func _merge_save_data(loaded: Dictionary) -> void:
	for key in data:
		if loaded.has(key):
			if data[key] is Dictionary and loaded[key] is Dictionary:
				# Fusion récursive pour les dictionnaires
				for sub_key in data[key]:
					if loaded[key].has(sub_key):
						data[key][sub_key] = loaded[key][sub_key]
			else:
				data[key] = loaded[key]


## Réinitialise toutes les données (nouvelle partie)
func reset_save() -> void:
	_initialize_default_data()
	save_game()


## Vérifie si un fichier de sauvegarde existe
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


# ==================== ACCESSEURS MONNAIE ====================

## Retourne la monnaie actuelle
func get_currency() -> int:
	return data.get("currency_sc", 0)


## Ajoute de la monnaie
func add_currency(amount: int) -> void:
	data["currency_sc"] = get_currency() + amount
	data["statistics"]["total_currency_earned"] += amount
	currency_changed.emit(get_currency())
	save_game()


## Réinitialise la monnaie à 0 (pour retry)
func reset_currency() -> void:
	data["currency_sc"] = 0
	currency_changed.emit(0)
	save_game()


## Dépense de la monnaie (retourne false si pas assez)
func spend_currency(amount: int) -> bool:
	if get_currency() < amount:
		return false
	
	data["currency_sc"] = get_currency() - amount
	currency_changed.emit(get_currency())
	save_game()
	return true


## Vérifie si le joueur peut se permettre un achat
func can_afford(amount: int) -> bool:
	return get_currency() >= amount


# ==================== ACCESSEURS PROGRESSION ====================

## Retourne l'index de la planète actuelle (0-3)
func get_current_planet() -> int:
	return data.get("current_planet", 0)


## Retourne le numéro de vague actuel (0-5)
func get_current_wave() -> int:
	return data.get("current_wave", 0)


## Avance à la vague suivante
func advance_wave() -> void:
	data["current_wave"] = get_current_wave() + 1
	progression_changed.emit()
	save_game()


## Passe à la planète suivante
func advance_planet() -> void:
	var current := get_current_planet()
	data["highest_planet_completed"] = maxi(data["highest_planet_completed"], current)
	data["current_planet"] = mini(current + 1, 3)  # Max 4 planètes (0-3)
	data["current_wave"] = 0
	progression_changed.emit()
	save_game()


## Retry le niveau actuel (après mort - GARDE TOUT)
func retry_level() -> void:
	data["current_wave"] = 0  # Recommence la planète
	data["statistics"]["total_deaths"] += 1
	progression_changed.emit()
	save_game()


# ==================== ACCESSEURS SKILLS ====================

## Retourne la liste des skills débloqués
func get_unlocked_skills() -> Array:
	return data.get("unlocked_skills", [])


## Vérifie si un skill est débloqué
func is_skill_unlocked(skill_id: String) -> bool:
	return skill_id in get_unlocked_skills()


## Débloque un skill
func unlock_skill(skill_id: String) -> void:
	if not is_skill_unlocked(skill_id):
		data["unlocked_skills"].append(skill_id)
		save_game()


# ==================== ACCESSEURS UPGRADES ====================

## Retourne le niveau d'un upgrade
func get_upgrade_level(upgrade_id: String) -> int:
	return data["upgrades"].get(upgrade_id, 0)


## Augmente le niveau d'un upgrade
func increase_upgrade(upgrade_id: String) -> void:
	if data["upgrades"].has(upgrade_id):
		data["upgrades"][upgrade_id] += 1
		save_game()


# ==================== ACCESSEURS STATISTIQUES ====================

## Ajoute des kills
func add_kills(count: int) -> void:
	data["statistics"]["total_kills"] += count


## Enregistre un boss vaincu
func record_boss_defeated(boss_id: String) -> void:
	if boss_id not in data["statistics"]["bosses_defeated"]:
		data["statistics"]["bosses_defeated"].append(boss_id)
	save_game()


## Ajoute du temps de jeu
func add_play_time(seconds: int) -> void:
	data["statistics"]["play_time_seconds"] += seconds


# ==================== ACCESSEURS SETTINGS ====================

## Retourne le volume de la musique
func get_music_volume() -> float:
	return data["settings"].get("music_volume", 0.8)


## Définit le volume de la musique
func set_music_volume(volume: float) -> void:
	data["settings"]["music_volume"] = clampf(volume, 0.0, 1.0)
	save_game()


## Retourne le volume des SFX
func get_sfx_volume() -> float:
	return data["settings"].get("sfx_volume", 1.0)


## Définit le volume des SFX
func set_sfx_volume(volume: float) -> void:
	data["settings"]["sfx_volume"] = clampf(volume, 0.0, 1.0)
	save_game()


## Retourne si les vibrations sont activées
func is_vibration_enabled() -> bool:
	return data["settings"].get("vibration_enabled", true)


## Active/désactive les vibrations
func set_vibration_enabled(enabled: bool) -> void:
	data["settings"]["vibration_enabled"] = enabled
	save_game()


## Retourne tous les settings
func get_settings() -> Dictionary:
	return data.get("settings", {})


## Définit une valeur de setting générique
func set_setting(key: String, value: Variant) -> void:
	if data["settings"].has(key):
		data["settings"][key] = value
	save_game()


## Retourne le plus haut niveau de planète complétée (-1 si aucune)
func get_highest_planet_completed() -> int:
	return data.get("highest_planet_completed", -1)


## Définit la planète actuelle (pour la sélection de niveau)
func set_current_planet(planet_index: int) -> void:
	data["current_planet"] = clampi(planet_index, 0, 3)
	data["current_wave"] = 0  # Reset à la première vague
	progression_changed.emit()
	save_game()
