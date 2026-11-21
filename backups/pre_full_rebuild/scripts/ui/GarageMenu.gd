extends Control
class_name GarageMenu

signal vehicle_selected(vehicle_id: String)
signal drive_pressed
signal back_pressed

@onready var vehicle_preview: TextureRect = $CenterRow/PreviewPanel/VehiclePreview
@onready var vehicle_name_label: Label = $CenterRow/PreviewPanel/VehicleNameLabel
@onready var vehicle_desc_label: Label = $CenterRow/PreviewPanel/VehicleDescLabel
@onready var select_btn: Button = $CenterRow/PreviewPanel/SelectButton
@onready var drive_btn: Button = $Header/DriveButton
@onready var back_btn: Button = $Header/BackButton
@onready var coin_label: Label = $Header/CoinPill/HBox/CoinLabel
@onready var upgrades_container: VBoxContainer = $CenterRow/UpgradesPanel/Margin/VBox/UpgradesList
@onready var prev_veh_btn: Button = $CenterRow/PreviewPanel/PrevButton
@onready var next_veh_btn: Button = $CenterRow/PreviewPanel/NextButton

const VEHICLES: Array[Dictionary] = [
	{
		"id": "red_jeep",
		"name": "Red Trail Jeep",
		"desc": "Classic 4x4 off-roader. Perfectly balanced for coastal hills.",
		"cost": 0,
		"tex": "res://art/vehicles/jeep_body.png"
	},
	{
		"id": "auto_rickshaw",
		"name": "Auto Rickshaw",
		"desc": "Nimble 3-wheeler with high torque and lively suspension.",
		"cost": 400,
		"tex": "res://art/vehicles/rickshaw_body.png"
	},
	{
		"id": "tractor",
		"name": "Heavy Farm Tractor",
		"desc": "Massive rear wheels and immense climb torque on steep grades.",
		"cost": 800,
		"tex": "res://art/vehicles/tractor_body.png"
	},
	{
		"id": "mini_truck",
		"name": "Mini Commercial Truck",
		"desc": "High capacity fuel tank and stable commercial chassis.",
		"cost": 1200,
		"tex": "res://art/vehicles/mini_truck_body.png"
	},
	{
		"id": "rally_jeep",
		"name": "Pro Rally Racer",
		"desc": "High-revving tuned engine and extreme nitro speed.",
		"cost": 2000,
		"tex": "res://art/vehicles/rally_jeep_body.png"
	}
]

var current_vehicle_index: int = 0

func _ready() -> void:
	back_btn.pressed.connect(_on_back)
	drive_btn.pressed.connect(_on_drive)
	prev_veh_btn.pressed.connect(_on_prev_vehicle)
	next_veh_btn.pressed.connect(_on_next_vehicle)
	select_btn.pressed.connect(_on_select_or_buy)
	
	# Find index of currently active vehicle
	for i in range(VEHICLES.size()):
		if VEHICLES[i]["id"] == GameState.active_vehicle_id:
			current_vehicle_index = i
			break
			
	_update_view()

func _update_view() -> void:
	coin_label.text = str(GameState.coins)
	var veh := VEHICLES[current_vehicle_index]
	var v_id: String = veh["id"]
	var is_unlocked: bool = GameState.is_vehicle_unlocked(v_id)
	var is_active: bool = (GameState.active_vehicle_id == v_id)
	
	vehicle_name_label.text = veh["name"]
	vehicle_desc_label.text = veh["desc"]
	vehicle_preview.texture = load(veh["tex"])
	
	# Select / Buy button state
	var btn_style := StyleBoxFlat.new()
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_right = 8
	btn_style.corner_radius_bottom_left = 8
	
	if is_active:
		select_btn.text = "SELECTED (ACTIVE)"
		select_btn.disabled = true
		btn_style.bg_color = Color(0.2, 0.45, 0.75, 1)
	elif is_unlocked:
		select_btn.text = "SELECT VEHICLE"
		select_btn.disabled = false
		btn_style.bg_color = Color(0.12, 0.65, 0.32, 1)
	else:
		var cost: int = veh["cost"]
		select_btn.text = "UNLOCK (%d Coins)" % cost
		select_btn.disabled = (GameState.coins < cost)
		btn_style.bg_color = Color(0.9, 0.55, 0.12, 1)
		
	select_btn.add_theme_stylebox_override("normal", btn_style)
	
	_populate_upgrades(v_id)

func _populate_upgrades(v_id: String) -> void:
	for c in upgrades_container.get_children():
		c.queue_free()
		
	var stats := [
		{"key": "engine", "name": "Engine Torque"},
		{"key": "suspension", "name": "Suspension Shocks"},
		{"key": "tires", "name": "Off-Road Tires"},
		{"key": "fuel_tank", "name": "Fuel Capacity"},
		{"key": "nitro", "name": "Nitro Boost"}
	]
	
	for stat in stats:
		var row := _create_upgrade_row(v_id, stat["key"], stat["name"])
		upgrades_container.add_child(row)

func _create_upgrade_row(v_id: String, stat_key: String, stat_name: String) -> PanelContainer:
	var panel := PanelContainer.new()
	var p_style := StyleBoxFlat.new()
	p_style.bg_color = Color(0.12, 0.14, 0.18, 0.8)
	p_style.corner_radius_top_left = 8
	p_style.corner_radius_top_right = 8
	p_style.corner_radius_bottom_right = 8
	p_style.corner_radius_bottom_left = 8
	panel.add_theme_stylebox_override("panel", p_style)
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	margin.add_child(hbox)
	
	# Name & Level
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	var lvl: int = GameState.get_upgrade_level(v_id, stat_key)
	var name_lbl := Label.new()
	name_lbl.text = stat_name
	name_lbl.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_lbl)
	
	# Level pip dots
	var pips_str := ""
	for i in range(5):
		pips_str += "[X] " if i < lvl else "[ ] "
	var pips_lbl := Label.new()
	pips_lbl.text = "Level %d/5  %s" % [lvl, pips_str]
	pips_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.2, 1))
	pips_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(pips_lbl)
	
	# Upgrade Button
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(130, 42)
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var b_style := StyleBoxFlat.new()
	b_style.corner_radius_top_left = 6
	b_style.corner_radius_top_right = 6
	b_style.corner_radius_bottom_right = 6
	b_style.corner_radius_bottom_left = 6
	
	if lvl >= GameState.MAX_UPGRADE_LEVEL:
		btn.text = "MAX"
		btn.disabled = true
		b_style.bg_color = Color(0.25, 0.28, 0.32, 1)
	else:
		var cost := GameState.get_upgrade_cost(lvl)
		btn.text = "%d Coins" % cost
		btn.disabled = (GameState.coins < cost)
		b_style.bg_color = Color(0.12, 0.65, 0.32, 1) if GameState.coins >= cost else Color(0.3, 0.3, 0.35, 1)
		btn.pressed.connect(func(): _on_upgrade_stat(v_id, stat_key))
		
	btn.add_theme_stylebox_override("normal", b_style)
	hbox.add_child(btn)
	
	return panel

func _on_upgrade_stat(v_id: String, stat_key: String) -> void:
	if GameState.upgrade_vehicle_stat(v_id, stat_key):
		AudioManager.play_sfx("coin", 1.2)
		_update_view()

func _on_prev_vehicle() -> void:
	AudioManager.play_sfx("click")
	current_vehicle_index = (current_vehicle_index - 1 + VEHICLES.size()) % VEHICLES.size()
	_update_view()

func _on_next_vehicle() -> void:
	AudioManager.play_sfx("click")
	current_vehicle_index = (current_vehicle_index + 1) % VEHICLES.size()
	_update_view()

func _on_select_or_buy() -> void:
	var veh := VEHICLES[current_vehicle_index]
	var v_id: String = veh["id"]
	if GameState.is_vehicle_unlocked(v_id):
		GameState.active_vehicle_id = v_id
		AudioManager.play_sfx("click")
		_update_view()
	else:
		var cost: int = veh["cost"]
		if GameState.spend_coins(cost):
			GameState.unlock_vehicle(v_id)
			GameState.active_vehicle_id = v_id
			AudioManager.play_sfx("coin", 1.3)
			_update_view()

func _on_drive() -> void:
	AudioManager.play_sfx("click")
	drive_pressed.emit()

func _on_back() -> void:
	AudioManager.play_sfx("click")
	back_pressed.emit()
