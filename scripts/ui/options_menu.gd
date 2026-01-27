## OptionsMenu - Écran des options
##
## Gère les paramètres du jeu:
## - Volume Musique
## - Volume Effets sonores
## - Vibrations (on/off)
##
## Sauvegarde automatique via SaveManager
extends Control


@onready var back_button: Button = %BackButton
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var vibration_toggle: CheckButton = %VibrationToggle
@onready var music_value_label: Label = %MusicValueLabel
@onready var sfx_value_label: Label = %SFXValueLabel

## Scène du menu principal
const MAIN_MENU_SCENE := "res://scenes/ui/main_menu.tscn"


func _ready() -> void:
	_connect_signals()
	_load_settings()
	_animate_entrance()


func _connect_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	vibration_toggle.toggled.connect(_on_vibration_toggled)


func _load_settings() -> void:
	if not SaveManager:
		return
	
	var settings: Dictionary = SaveManager.get_settings()
	
	# Appliquer les valeurs sauvegardées
	music_slider.value = settings.get("music_volume", 0.8)
	sfx_slider.value = settings.get("sfx_volume", 1.0)
	vibration_toggle.button_pressed = settings.get("vibration_enabled", true)
	
	# Mettre à jour les labels
	_update_music_label(music_slider.value)
	_update_sfx_label(sfx_slider.value)


func _update_music_label(value: float) -> void:
	if music_value_label:
		music_value_label.text = "%d%%" % int(value * 100)


func _update_sfx_label(value: float) -> void:
	if sfx_value_label:
		sfx_value_label.text = "%d%%" % int(value * 100)


func _on_music_changed(value: float) -> void:
	_update_music_label(value)
	if SaveManager:
		SaveManager.set_setting("music_volume", value)
	# TODO: Appliquer au bus audio "Music"
	# AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))


func _on_sfx_changed(value: float) -> void:
	_update_sfx_label(value)
	if SaveManager:
		SaveManager.set_setting("sfx_volume", value)
	# TODO: Appliquer au bus audio "SFX"
	# AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))


func _on_vibration_toggled(enabled: bool) -> void:
	if SaveManager:
		SaveManager.set_setting("vibration_enabled", enabled)


func _animate_entrance() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)


func _on_back_pressed() -> void:
	# Sauvegarder avant de quitter
	if SaveManager:
		SaveManager.save_game()
	
	var tween := create_tween()
	tween.tween_property(back_button, "scale", Vector2(0.95, 0.95), 0.08)
	tween.tween_property(back_button, "scale", Vector2(1.0, 1.0), 0.08)
	
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
