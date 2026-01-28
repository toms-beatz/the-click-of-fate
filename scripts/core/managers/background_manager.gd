## BackgroundManager - Gestion centralisée des fonds d'écran
##
## Permet de charger et appliquer des backgrounds facilement sur toute les scènes.
## Utilise un cache pour optimiser les performances.
##
## Usage:
##   BackgroundManager.set_background(get_node("TextureRect"), "main_menu")
##   BackgroundManager.set_background_by_planet(get_node("TextureRect"), 2)  # Mars

class_name BackgroundManager
extends Node

## Cache des textures chargées (pour éviter de recharger)
var _texture_cache: Dictionary = {}

## Chemins des backgrounds
const BG_PATHS := {
	# Menus
	"main_menu": "res://assets/sprites/background/bg_main_menu.png",
	"level_select": "res://assets/sprites/background/bg_level_select.png",
	"profile_menu": "res://assets/sprites/background/bg_profile_menu.png",
	"shop_menu": "res://assets/sprites/background/bg_shop_menu.png",
	"options_menu": "res://assets/sprites/background/bg_options_menu.png",
	"pause_menu": "res://assets/sprites/background/bg_pause_menu.png",
	"victory_screen": "res://assets/sprites/background/bg_victory.png",
	"defeat_screen": "res://assets/sprites/background/bg_defeat.png",
	
	# Combats par planète
	"combat_mercury": "res://assets/sprites/background/bg_mercury_combat.png",
	"combat_venus": "res://assets/sprites/background/bg_venus_combat.png",
	"combat_mars": "res://assets/sprites/background/bg_mars_combat.png",
	"combat_earth": "res://assets/sprites/background/bg_earth_combat.png",
	
	# Génériques
	"space_static": "res://assets/sprites/background/bg_space_static.png",
	"space_nebula": "res://assets/sprites/background/bg_space_nebula.png",
}

## Planet IDs
const PLANET_NAMES := ["mercury", "venus", "mars", "earth"]


## Charge une texture en cache
func _get_texture(key: String) -> Texture2D:
	if key in _texture_cache:
		return _texture_cache[key]
	
	var path = BG_PATHS.get(key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		push_warning("BackgroundManager: Background '%s' non trouvé (chemin: %s)" % [key, path])
		return null
	
	var texture = load(path) as Texture2D
	if texture:
		_texture_cache[key] = texture
	return texture


## Applique un background sur un TextureRect
func set_background(rect: TextureRect, background_key: String) -> void:
	if not rect:
		push_error("BackgroundManager: TextureRect invalide")
		return
	
	var texture = _get_texture(background_key)
	if texture:
		rect.texture = texture
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


## Applique un background selon la planète (pour les combats)
func set_background_by_planet(rect: TextureRect, planet_index: int) -> void:
	if planet_index < 0 or planet_index >= PLANET_NAMES.size():
		push_error("BackgroundManager: Index planète invalide: %d" % planet_index)
		return
	
	var planet_name = PLANET_NAMES[planet_index]
	var background_key = "combat_%s" % planet_name
	set_background(rect, background_key)


## Applique un background selon le nom de la scène
func set_background_by_scene(rect: TextureRect, scene_name: String) -> void:
	# Mapper les noms de scènes aux clés de background
	var scene_map := {
		"main_menu": "main_menu",
		"level_select": "level_select",
		"profile_menu": "profile_menu",
		"shop_menu": "shop_menu",
		"options_menu": "options_menu",
		"pause_menu": "pause_menu",
		"victory": "victory_screen",
		"defeat": "defeat_screen",
	}
	
	var background_key = scene_map.get(scene_name, "space_static")
	set_background(rect, background_key)


## Précharge tous les backgrounds (optionnel, pour éviter les ralentissements)
func preload_all_backgrounds() -> void:
	for key in BG_PATHS.keys():
		_get_texture(key)


## Libère le cache (optionnel, pour économiser la mémoire)
func clear_cache() -> void:
	_texture_cache.clear()


## Retourne le chemin d'un background
func get_background_path(background_key: String) -> String:
	return BG_PATHS.get(background_key, "")
