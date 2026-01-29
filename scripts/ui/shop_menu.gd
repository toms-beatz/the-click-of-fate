## ShopMenu - Écran de la boutique
##
## 3 catégories:
## 1. Boosters temporaires (pour la prochaine partie)
## 2. Acheter des SC (argent réel - simulation)
## 3. Équipements (armes, armures, casques)
extends Control


@onready var back_button: Button = %BackButton
@onready var currency_label: Label = %CurrencyLabel
@onready var boosters_container: VBoxContainer = %BoostersContainer
@onready var coins_container: VBoxContainer = %CoinsContainer
@onready var equipment_container: VBoxContainer = %EquipmentContainer

## Scène de sélection de niveau
const LEVEL_SELECT_SCENE := "res://scenes/ui/level_select.tscn"
## Configuration des packs de coins (argent réel simulé)
const COIN_PACKS := {
	"pack_small": {
		"name": "Petit Pack",
		"icon": "💰",
		"coins": 500,
		"price": "0.99€",
		"bonus": ""
	},
	"pack_medium": {
		"name": "Pack Moyen",
		"icon": "💰💰",
		"coins": 1200,
		"price": "1.99€",
		"bonus": "+20%"
	},
	"pack_large": {
		"name": "Grand Pack",
		"icon": "💰💰💰",
		"coins": 3000,
		"price": "4.99€",
		"bonus": "+50%"
	},
	"pack_mega": {
		"name": "Méga Pack",
		"icon": "👑",
		"coins": 8000,
		"price": "9.99€",
		"bonus": "+100%"
	}
}

## Configuration des boosters
const BOOSTERS := {
	"boost_attack": {
		"name": "Rage de Guerre",
		"icon": "⚔️",
		"description": "+50% Dégâts (1 partie)",
		"cost": 100,
		"effect": {"attack_power": 1.5}
	},
	"boost_hp": {
		"name": "Vitalité",
		"icon": "❤️",
		"description": "+30% PV Max (1 partie)",
		"cost": 80,
		"effect": {"max_hp": 1.3}
	},
	"boost_dodge": {
		"name": "Agilité",
		"icon": "💨",
		"description": "+20% Esquive (1 partie)",
		"cost": 120,
		"effect": {"dodge_chance": 1.2}
	},
	"boost_heal": {
		"name": "Régénération",
		"icon": "💚",
		"description": "+40% Soin (1 partie)",
		"cost": 90,
		"effect": {"heal_power": 1.4}
	},
	"boost_all": {
		"name": "Puissance Totale",
		"icon": "⭐",
		"description": "+15% Toutes stats (1 partie)",
		"cost": 200,
		"effect": {"all": 1.15}
	}
}

## Configuration des équipements à vendre
const EQUIPMENT_SHOP := {
	# Armes
	"sword_basic": {"name": "Épée Basique", "type": "weapon", "icon": "🗡️", "cost": 200, "bonus": "+5 Dégâts"},
	"sword_flame": {"name": "Lame de Feu", "type": "weapon", "icon": "🔥", "cost": 800, "bonus": "+12 Dégâts"},
	"sword_cosmic": {"name": "Épée Cosmique", "type": "weapon", "icon": "⚡", "cost": 2500, "bonus": "+25 Dégâts"},
	# Armures
	"armor_light": {"name": "Armure Légère", "type": "armor", "icon": "🛡️", "cost": 250, "bonus": "+5% Esquive"},
	"armor_shadow": {"name": "Armure d'Ombre", "type": "armor", "icon": "🌑", "cost": 900, "bonus": "+10% Esquive"},
	"armor_cosmic": {"name": "Armure Cosmique", "type": "armor", "icon": "✨", "cost": 3000, "bonus": "+18% Esquive"},
	# Casques
	"helmet_basic": {"name": "Casque Basique", "type": "helmet", "icon": "⛑️", "cost": 180, "bonus": "+3 Soin"},
	"helmet_nature": {"name": "Casque Nature", "type": "helmet", "icon": "🌿", "cost": 700, "bonus": "+8 Soin"},
	"helmet_cosmic": {"name": "Casque Cosmique", "type": "helmet", "icon": "👑", "cost": 2200, "bonus": "+15 Soin"},
}


func _ready() -> void:
	_connect_signals()
	_update_currency_display()
	_populate_boosters()
	_populate_coins()
	_populate_equipment()
	_animate_entrance()


func _connect_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	
	if SaveManager:
		SaveManager.currency_changed.connect(_on_currency_changed)


func _update_currency_display() -> void:
	if SaveManager and currency_label:
		currency_label.text = "%d SC" % SaveManager.get_currency()


func _on_currency_changed(_new_amount: int) -> void:
	_update_currency_display()
	_refresh_shop()


func _refresh_shop() -> void:
	_populate_boosters()
	_populate_equipment()


## ==================== BOOSTERS ====================
func _populate_boosters() -> void:
	if not boosters_container:
		return
	
	for child in boosters_container.get_children():
		child.queue_free()
	
	for booster_id in BOOSTERS:
		_create_booster_item(booster_id)


func _create_booster_item(booster_id: String) -> void:
	var config: Dictionary = BOOSTERS[booster_id]
	var can_afford := SaveManager.can_afford(config["cost"]) if SaveManager else false
	var is_active := SaveManager.has_booster(booster_id) if SaveManager else false
	
	var panel := _create_item_panel()
	boosters_container.add_child(panel)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)
	
	# Icône
	var icon := Label.new()
	icon.text = config["icon"]
	icon.add_theme_font_size_override("font_size", 28)
	hbox.add_child(icon)
	
	# Info
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	var name_label := Label.new()
	name_label.text = config["name"]
	name_label.add_theme_font_size_override("font_size", 16)
	info_vbox.add_child(name_label)
	
	var desc_label := Label.new()
	desc_label.text = config["description"]
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	info_vbox.add_child(desc_label)
	
	# Bouton achat
	var buy_btn := Button.new()
	buy_btn.custom_minimum_size = Vector2(90, 40)
	buy_btn.add_theme_font_size_override("font_size", 14)
	
	if is_active:
		buy_btn.text = "ACTIF"
		buy_btn.disabled = true
		buy_btn.add_theme_color_override("font_color", Color.GREEN)
	else:
		buy_btn.text = "%d SC" % config["cost"]
		buy_btn.disabled = not can_afford
		if can_afford:
			buy_btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			buy_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	buy_btn.pressed.connect(_on_buy_booster.bind(booster_id))
	hbox.add_child(buy_btn)


func _on_buy_booster(booster_id: String) -> void:
	var config: Dictionary = BOOSTERS[booster_id]
	if SaveManager and SaveManager.spend_currency(config["cost"]):
		SaveManager.add_booster(booster_id)
		_populate_boosters()


## ==================== COINS (Argent réel simulé) ====================
func _populate_coins() -> void:
	if not coins_container:
		return
	
	for child in coins_container.get_children():
		child.queue_free()
	
	for pack_id in COIN_PACKS:
		_create_coin_pack(pack_id)


func _create_coin_pack(pack_id: String) -> void:
	var config: Dictionary = COIN_PACKS[pack_id]
	
	var panel := _create_item_panel()
	panel.get_theme_stylebox("panel").bg_color = Color(0.15, 0.1, 0.05, 0.9)
	coins_container.add_child(panel)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)
	
	# Icône
	var icon := Label.new()
	icon.text = config["icon"]
	icon.add_theme_font_size_override("font_size", 24)
	hbox.add_child(icon)
	
	# Info
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	var name_label := Label.new()
	var bonus_text := " %s" % config["bonus"] if config["bonus"] != "" else ""
	name_label.text = "%s%s" % [config["name"], bonus_text]
	name_label.add_theme_font_size_override("font_size", 16)
	if config["bonus"] != "":
		name_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	info_vbox.add_child(name_label)
	
	var coins_label := Label.new()
	coins_label.text = "%d SC" % config["coins"]
	coins_label.add_theme_font_size_override("font_size", 14)
	coins_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	info_vbox.add_child(coins_label)
	
	# Bouton achat (argent réel)
	var buy_btn := Button.new()
	buy_btn.text = config["price"]
	buy_btn.custom_minimum_size = Vector2(80, 40)
	buy_btn.add_theme_font_size_override("font_size", 14)
	buy_btn.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))
	buy_btn.pressed.connect(_on_buy_coins.bind(pack_id))
	hbox.add_child(buy_btn)


func _on_buy_coins(pack_id: String) -> void:
	var config: Dictionary = COIN_PACKS[pack_id]
	# Simulation d'achat réel - ajoute directement les coins
	print("[SHOP] Achat simulé: %s pour %s" % [config["name"], config["price"]])
	if SaveManager:
		SaveManager.add_currency(config["coins"])
	_show_purchase_popup(config["coins"])


func _show_purchase_popup(coins: int) -> void:
	# Feedback visuel simple
	var popup := Label.new()
	popup.text = "+%d SC !" % coins
	popup.add_theme_font_size_override("font_size", 32)
	popup.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.set_anchors_preset(Control.PRESET_CENTER)
	add_child(popup)
	
	var tween := create_tween()
	tween.tween_property(popup, "position:y", popup.position.y - 50, 1.0)
	tween.parallel().tween_property(popup, "modulate:a", 0.0, 1.0)
	tween.tween_callback(popup.queue_free)


## ==================== ÉQUIPEMENT ====================
func _populate_equipment() -> void:
	if not equipment_container:
		return
	
	for child in equipment_container.get_children():
		child.queue_free()
	
	# Grouper par type
	var types := {"weapon": "⚔️ Armes", "armor": "🛡️ Armures", "helmet": "⛑️ Casques"}
	
	for type_id in types:
		var type_label := Label.new()
		type_label.text = types[type_id]
		type_label.add_theme_font_size_override("font_size", 16)
		type_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		equipment_container.add_child(type_label)
		
		for equip_id in EQUIPMENT_SHOP:
			var config: Dictionary = EQUIPMENT_SHOP[equip_id]
			if config["type"] == type_id:
				_create_equipment_item(equip_id)


func _create_equipment_item(equip_id: String) -> void:
	var config: Dictionary = EQUIPMENT_SHOP[equip_id]
	var owned := SaveManager.owns_equipment(equip_id) if SaveManager else false
	var can_afford := SaveManager.can_afford(config["cost"]) if SaveManager else false
	
	var panel := _create_item_panel()
	equipment_container.add_child(panel)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	panel.add_child(hbox)
	
	# Icône
	var icon := Label.new()
	icon.text = config["icon"]
	icon.add_theme_font_size_override("font_size", 26)
	hbox.add_child(icon)
	
	# Info
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)
	
	var name_label := Label.new()
	name_label.text = config["name"]
	name_label.add_theme_font_size_override("font_size", 15)
	info_vbox.add_child(name_label)
	
	var bonus_label := Label.new()
	bonus_label.text = config["bonus"]
	bonus_label.add_theme_font_size_override("font_size", 12)
	bonus_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	info_vbox.add_child(bonus_label)
	
	# Bouton
	var buy_btn := Button.new()
	buy_btn.custom_minimum_size = Vector2(90, 40)
	buy_btn.add_theme_font_size_override("font_size", 14)
	
	if owned:
		buy_btn.text = "POSSÉDÉ"
		buy_btn.disabled = true
		buy_btn.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))
	else:
		buy_btn.text = "%d SC" % config["cost"]
		buy_btn.disabled = not can_afford
		if can_afford:
			buy_btn.add_theme_color_override("font_color", Color.WHITE)
		else:
			buy_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	buy_btn.pressed.connect(_on_buy_equipment.bind(equip_id))
	hbox.add_child(buy_btn)


func _on_buy_equipment(equip_id: String) -> void:
	var config: Dictionary = EQUIPMENT_SHOP[equip_id]
	if SaveManager and SaveManager.spend_currency(config["cost"]):
		SaveManager.add_equipment(equip_id)
		_populate_equipment()


## ==================== UTILS ====================
func _create_item_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	return panel


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
