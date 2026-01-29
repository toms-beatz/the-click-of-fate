## ProfileMenu - Écran du profil joueur
##
## Affiche et permet d'améliorer les stats du personnage:
## - Stats de base (vie, dégâts, esquive, soin)
## - Équipement (arme, armure, casque)
## - Statistiques de jeu
extends Control


@onready var back_button: Button = %BackButton
@onready var currency_label: Label = %CurrencyLabel
@onready var power_label: Label = %PowerLabel
@onready var stats_container: VBoxContainer = %StatsContainer
@onready var upgrades_container: VBoxContainer = %UpgradesContainer
@onready var equipment_container: VBoxContainer = %EquipmentContainer

## Scène de sélection de niveau
const LEVEL_SELECT_SCENE := "res://scenes/ui/level_select.tscn"

## Configuration des upgrades
## Formule prix: base_cost * (1.5 ^ level)
const UPGRADES_CONFIG := {
	"max_hp": {
		"name": "PV Max",
		"icon": "❤️",
		"base_value": 100,
		"per_level": 15,
		"base_cost": 50,
		"cost_multiplier": 1.5,
		"max_level": 20,
		"description": "Augmente vos points de vie"
	},
	"attack_power": {
		"name": "Dégâts",
		"icon": "⚔️",
		"base_value": 10,
		"per_level": 2,
		"base_cost": 75,
		"cost_multiplier": 1.6,
		"max_level": 20,
		"description": "Augmente vos dégâts d'attaque"
	},
	"dodge_chance": {
		"name": "Esquive",
		"icon": "💨",
		"base_value": 5,
		"per_level": 2,
		"base_cost": 100,
		"cost_multiplier": 1.7,
		"max_level": 15,
		"unit": "%",
		"description": "Chance d'esquiver les attaques"
	},
	"heal_power": {
		"name": "Soin",
		"icon": "💚",
		"base_value": 8,
		"per_level": 2,
		"base_cost": 60,
		"cost_multiplier": 1.5,
		"max_level": 20,
		"description": "Augmente la puissance de soin"
	}
}

## Configuration des équipements
const EQUIPMENT_DATA := {
	# Armes (bonus dégâts)
	"sword_basic": {"name": "Épée Basique", "type": "weapon", "icon": "🗡️", "bonus": {"attack_power": 5}},
	"sword_flame": {"name": "Lame de Feu", "type": "weapon", "icon": "🔥", "bonus": {"attack_power": 12}},
	"sword_cosmic": {"name": "Épée Cosmique", "type": "weapon", "icon": "⚡", "bonus": {"attack_power": 25}},
	# Armures (bonus esquive)
	"armor_light": {"name": "Armure Légère", "type": "armor", "icon": "🛡️", "bonus": {"dodge_chance": 5}},
	"armor_shadow": {"name": "Armure d'Ombre", "type": "armor", "icon": "🌑", "bonus": {"dodge_chance": 10}},
	"armor_cosmic": {"name": "Armure Cosmique", "type": "armor", "icon": "✨", "bonus": {"dodge_chance": 18}},
	# Casques (bonus soin)
	"helmet_basic": {"name": "Casque Basique", "type": "helmet", "icon": "⛑️", "bonus": {"heal_power": 3}},
	"helmet_nature": {"name": "Casque Nature", "type": "helmet", "icon": "🌿", "bonus": {"heal_power": 8}},
	"helmet_cosmic": {"name": "Casque Cosmique", "type": "helmet", "icon": "👑", "bonus": {"heal_power": 15}},
}


func _ready() -> void:
	_connect_signals()
	_update_displays()
	_populate_upgrades()
	_populate_equipment()
	_populate_stats()
	_animate_entrance()


func _connect_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	
	if SaveManager:
		SaveManager.currency_changed.connect(_on_currency_changed)


func _update_displays() -> void:
	_update_currency_display()
	_update_power_display()


func _update_currency_display() -> void:
	if SaveManager and currency_label:
		currency_label.text = "%d SC" % SaveManager.get_currency()


func _update_power_display() -> void:
	if power_label:
		var power := _calculate_player_power()
		power_label.text = "⚔ %d" % power


func _on_currency_changed(_new_amount: int) -> void:
	_update_displays()
	_refresh_upgrade_buttons()


## Calcule la puissance totale du joueur
func _calculate_player_power() -> int:
	if not SaveManager:
		return 100
	
	var power := 100  # Base de 100
	
	# Bonus de progression par planète complétée
	var highest_completed: int = SaveManager.get_highest_planet_completed()
	var progression_bonus := {
		-1: 0,    # Aucune planète terminée
		0: 50,    # Mercury terminée
		1: 100,   # Venus terminée
		2: 180,   # Mars terminée
		3: 300,   # Earth terminée (max)
	}
	power += progression_bonus.get(highest_completed, 0)
	
	# Bonus des upgrades
	for upgrade_id in UPGRADES_CONFIG:
		var level := SaveManager.get_upgrade_level(upgrade_id)
		var config := UPGRADES_CONFIG[upgrade_id] as Dictionary
		power += level * int(config["per_level"] * 0.8)
	
	# Bonus des équipements
	for slot in ["weapon", "armor", "helmet"]:
		var equipped := SaveManager.get_equipped(slot)
		if equipped != "" and EQUIPMENT_DATA.has(equipped):
			var equip_data: Dictionary = EQUIPMENT_DATA[equipped]
			for stat in equip_data["bonus"]:
				power += equip_data["bonus"][stat]
	
	return power


## Calcule le coût d'un upgrade au niveau donné
func _get_upgrade_cost(upgrade_id: String, current_level: int) -> int:
	var config: Dictionary = UPGRADES_CONFIG[upgrade_id]
	return int(config["base_cost"] * pow(config["cost_multiplier"], current_level))


## Calcule la valeur d'une stat à un niveau donné
func _get_stat_value(upgrade_id: String, level: int) -> int:
	var config: Dictionary = UPGRADES_CONFIG[upgrade_id]
	return config["base_value"] + (level * config["per_level"])


func _refresh_upgrade_buttons() -> void:
	_populate_upgrades()


## Remplit la section des upgrades
func _populate_upgrades() -> void:
	if not upgrades_container or not SaveManager:
		return
	
	# Nettoyer
	for child in upgrades_container.get_children():
		child.queue_free()
	
	for upgrade_id in UPGRADES_CONFIG:
		_create_upgrade_row(upgrade_id)


func _create_upgrade_row(upgrade_id: String) -> void:
	var config: Dictionary = UPGRADES_CONFIG[upgrade_id]
	var level := SaveManager.get_upgrade_level(upgrade_id)
	var current_value := _get_stat_value(upgrade_id, level)
	var next_value := _get_stat_value(upgrade_id, level + 1)
	var cost := _get_upgrade_cost(upgrade_id, level)
	var max_level: int = int(config.get("max_level", 0))
	var is_maxed: bool = level >= max_level
	var can_afford: bool = SaveManager.can_afford(cost)
	var unit := config.get("unit", "") as String
	
	# Container principal
	var panel := PanelContainer.new()
	panel.name = "Upgrade_%s" % upgrade_id
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.8)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	upgrades_container.add_child(panel)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)
	
	# Icône
	var icon := Label.new()
	icon.text = config["icon"]
	icon.add_theme_font_size_override("font_size", 28)
	hbox.add_child(icon)
	
	# Info container
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	# Nom et niveau
	var name_label := Label.new()
	name_label.text = "%s (Niv. %d/%d)" % [config["name"], level, config["max_level"]]
	name_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(name_label)
	
	# Valeur actuelle → prochaine
	var value_label := Label.new()
	if is_maxed:
		value_label.text = "%d%s (MAX)" % [current_value, unit]
		value_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	else:
		value_label.text = "%d%s → %d%s" % [current_value, unit, next_value, unit]
		value_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	value_label.add_theme_font_size_override("font_size", 14)
	info_vbox.add_child(value_label)
	
	# Bouton d'achat
	var buy_btn := Button.new()
	buy_btn.name = "BuyBtn_%s" % upgrade_id
	buy_btn.custom_minimum_size = Vector2(100, 45)
	
	if is_maxed:
		buy_btn.text = "MAX"
		buy_btn.disabled = true
	else:
		buy_btn.text = "%d SC" % cost
		buy_btn.disabled = not can_afford
		if can_afford:
			buy_btn.add_theme_color_override("font_color", Color.GREEN)
		else:
			buy_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	buy_btn.add_theme_font_size_override("font_size", 14)
	buy_btn.pressed.connect(_on_upgrade_pressed.bind(upgrade_id))
	hbox.add_child(buy_btn)


func _on_upgrade_pressed(upgrade_id: String) -> void:
	var level := SaveManager.get_upgrade_level(upgrade_id)
	var config: Dictionary = UPGRADES_CONFIG[upgrade_id]
	var cost := _get_upgrade_cost(upgrade_id, level)
	
	if level >= config["max_level"]:
		return
	
	if SaveManager.spend_currency(cost):
		SaveManager.increase_upgrade(upgrade_id)
		_populate_upgrades()
		_update_power_display()


## Remplit la section équipement
func _populate_equipment() -> void:
	if not equipment_container or not SaveManager:
		return
	
	# Nettoyer
	for child in equipment_container.get_children():
		child.queue_free()
	
	var slots := [
		{"id": "weapon", "name": "Arme", "icon": "⚔️"},
		{"id": "armor", "name": "Armure", "icon": "🛡️"},
		{"id": "helmet", "name": "Casque", "icon": "⛑️"}
	]
	
	for slot in slots:
		_create_equipment_slot(slot)


func _create_equipment_slot(slot: Dictionary) -> void:
	var equipped_id := SaveManager.get_equipped(slot["id"])
	
	# Panel container
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.12, 0.18, 0.8)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	equipment_container.add_child(panel)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)
	
	# Titre du slot
	var title := Label.new()
	title.text = "%s %s" % [slot["icon"], slot["name"]]
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	vbox.add_child(title)
	
	# Équipement actuel
	var current_label := Label.new()
	if equipped_id != "" and EQUIPMENT_DATA.has(equipped_id):
		var equip_data: Dictionary = EQUIPMENT_DATA[equipped_id]
		var bonus_text := ""
		for stat in equip_data["bonus"]:
			var stat_config := UPGRADES_CONFIG.get(stat, {"name": stat}) as Dictionary
			bonus_text += "+%d %s" % [equip_data["bonus"][stat], stat_config.get("name", stat)]
		current_label.text = "%s %s (%s)" % [equip_data["icon"], equip_data["name"], bonus_text]
		current_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		current_label.text = "Aucun équipement"
		current_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	current_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(current_label)
	
	# Liste des équipements possédés pour ce slot
	var slot_items := _get_owned_items_for_slot(slot["id"])
	if slot_items.size() > 0:
		var items_hbox := HBoxContainer.new()
		items_hbox.add_theme_constant_override("separation", 8)
		vbox.add_child(items_hbox)
		
		for item_id in slot_items:
			var item_data: Dictionary = EQUIPMENT_DATA[item_id]
			var equip_btn := Button.new()
			equip_btn.text = item_data["icon"]
			equip_btn.custom_minimum_size = Vector2(50, 50)
			equip_btn.add_theme_font_size_override("font_size", 24)
			equip_btn.tooltip_text = item_data["name"]
			
			if item_id == equipped_id:
				equip_btn.disabled = true
				equip_btn.modulate = Color(0.5, 1.0, 0.5)
			
			equip_btn.pressed.connect(_on_equip_pressed.bind(slot["id"], item_id))
			items_hbox.add_child(equip_btn)


func _get_owned_items_for_slot(slot_type: String) -> Array:
	var items := []
	var owned := SaveManager.get_owned_equipment()
	
	for item_id in owned:
		if EQUIPMENT_DATA.has(item_id):
			var item_data: Dictionary = EQUIPMENT_DATA[item_id]
			if item_data["type"] == slot_type:
				items.append(item_id)
	
	return items


func _on_equip_pressed(slot: String, item_id: String) -> void:
	SaveManager.equip_item(slot, item_id)
	_populate_equipment()
	_update_power_display()


## Remplit la section statistiques
func _populate_stats() -> void:
	if not stats_container or not SaveManager:
		return
	
	# Nettoyer
	for child in stats_container.get_children():
		child.queue_free()
	
	var stats := [
		{"label": "Ennemis vaincus", "value": SaveManager.data["statistics"].get("total_kills", 0)},
		{"label": "Morts", "value": SaveManager.data["statistics"].get("total_deaths", 0)},
		{"label": "Boss vaincus", "value": SaveManager.data["statistics"].get("bosses_defeated", []).size()},
		{"label": "SC gagnés (total)", "value": SaveManager.data["statistics"].get("total_currency_earned", 0)},
		{"label": "Planètes complétées", "value": maxi(0, SaveManager.get_highest_planet_completed() + 1)},
	]
	
	for stat in stats:
		_add_stat_row(stat["label"], str(stat["value"]))


func _add_stat_row(label_text: String, value_text: String) -> void:
	var hbox := HBoxContainer.new()
	stats_container.add_child(hbox)
	
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hbox.add_child(label)
	
	var value := Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.add_theme_font_size_override("font_size", 16)
	value.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(value)


func _animate_entrance() -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)


func _on_back_pressed() -> void:
	var tween := create_tween()
	tween.tween_property(back_button, "scale", Vector2(0.9, 0.9), 0.08)
	tween.tween_property(back_button, "scale", Vector2(1.0, 1.0), 0.08)
	
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file(LEVEL_SELECT_SCENE)
