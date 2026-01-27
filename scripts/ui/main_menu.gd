## MainMenu - Écran du menu principal
##
## Gère le menu principal du jeu:
## - Bouton Jouer → Sélection de niveau
## - Bouton Options → Écran d'options
## - Bouton Quitter → Ferme l'application
##
## Responsive pour mobile (Android/iOS)
extends Control


## Référence aux boutons
@onready var play_button: Button = %PlayButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton
@onready var title_label: Label = %TitleLabel
@onready var currency_label: Label = %CurrencyLabel

## Scène de sélection de niveau
const LEVEL_SELECT_SCENE := "res://scenes/ui/level_select.tscn"

## Scène des options
const OPTIONS_SCENE := "res://scenes/ui/options_menu.tscn"


func _ready() -> void:
	_connect_signals()
	_update_currency_display()
	_animate_entrance()


func _connect_signals() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Écouter les changements de monnaie
	if SaveManager:
		SaveManager.currency_changed.connect(_on_currency_changed)


func _update_currency_display() -> void:
	if SaveManager and currency_label:
		var sc_amount: int = SaveManager.get_currency()
		currency_label.text = "%d SC" % sc_amount


func _on_currency_changed(new_amount: int) -> void:
	if currency_label:
		currency_label.text = "%d SC" % new_amount


func _animate_entrance() -> void:
	# Animation d'entrée simple
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5).set_ease(Tween.EASE_OUT)
	
	# Animation du titre (slide depuis le haut)
	if title_label:
		var original_pos := title_label.position
		title_label.position.y -= 100
		title_label.modulate.a = 0.0
		var title_tween := create_tween()
		title_tween.set_parallel(true)
		title_tween.tween_property(title_label, "position:y", original_pos.y, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		title_tween.tween_property(title_label, "modulate:a", 1.0, 0.4)


func _on_play_pressed() -> void:
	_animate_button_press(play_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)


func _on_options_pressed() -> void:
	_animate_button_press(options_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(OPTIONS_SCENE)


func _on_quit_pressed() -> void:
	_animate_button_press(quit_button)
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()


## Feedback visuel sur appui bouton
func _animate_button_press(button: Button) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.08)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.08)
