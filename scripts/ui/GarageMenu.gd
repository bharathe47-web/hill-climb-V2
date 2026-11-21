extends Control
class_name GarageMenu

## GarageMenu: Standalone vehicle showroom and performance upgrade station.
## Connected directly to VehicleRegistry and SaveManager as single source of truth.

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

var vehicles_list: Array[Dictionary] = []
var current_vehicle_index: int = 0

func _ready() -> void:
	vehicles_list = VehicleRegistry.get_all_vehicles()
	
	if is_instance_valid(back_btn):
		back_btn.pressed.connect(_on_back)
	if is_instance_valid(drive_btn):
		drive_btn.pressed.connect(_on_drive)
	if is_instance_valid(prev_veh_btn):
		prev_veh_btn.pressed.connect(_on_prev_vehicle)
	if is_instance_valid(next_veh_btn):
		next_veh_btn.pressed.connect(_on_next_vehicle)
	if is_instance_valid(select_btn):
		select_btn.pressed.connect(_on_select_or_buy)
	
	var active_id := SaveManager.get_selected_vehicle_id()
	for i in range(vehicles_list.size()):
		if vehicles_list[i].get("id", "") == active_id:
			current_vehicle_index = i
			break
			
	_update_view()

func _update_view() -> void:
	if vehicles_list.is_empty():
		return
		
	var coins := SaveManager.get_total_coins()
	if is_instance_valid(coin_label):
		coin_label.text = "%d" % coins
		
	var veh := vehicles_list[current_vehicle_index]
	var v_id: String = veh.get("id", "blue_flame_truck")
	var is_unlocked: bool = SaveManager.is_vehicle_unlocked(v_id)
	var is_active: bool = (SaveManager.get_selected_vehicle_id() == v_id)
	
	if is_instance_valid(vehicle_name_label):
		vehicle_name_label.text = veh.get("display_name", "Vehicle")
	if is_instance_valid(vehicle_desc_label):
		vehicle_desc_label.text = veh.get("description", "")
	if is_instance_valid(vehicle_preview):
		var p_path: String = veh.get("preview_path", "")
		if ResourceLoader.exists(p_path):
			vehicle_preview.texture = load(p_path)
	
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
		var cost: int = int(veh.get("unlock_cost", 0))
		select_btn.text = "UNLOCK (%d Coins)" % cost
		select_btn.disabled = (coins < cost)
		btn_style.bg_color = Color(0.9, 0.55, 0.12, 1)
		
	select_btn.add_theme_stylebox_override("normal", btn_style)
	_populate_upgrades(v_id)

func _populate_upgrades(v_id: String) -> void:
	if not is_instance_valid(upgrades_container):
		return
		
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
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	var lvl: int = SaveManager.get_upgrade_level(v_id, stat_key)
	var name_lbl := Label.new()
	name_lbl.text = stat_name
	name_lbl.add_theme_font_size_override("font_size", 18)
	vbox.add_child(name_lbl)
	
	# Level pip dots
	var pips_str := ""
	for i in range(5):
		pips_str += "★ " if i < lvl else "☆ "
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
	
	if lvl >= 5:
		btn.text = "MAX"
		btn.disabled = true
		b_style.bg_color = Color(0.25, 0.28, 0.32, 1)
	else:
		var cost := VehicleRegistry.get_upgrade_cost(lvl)
		btn.text = "%d Coins" % cost
		btn.disabled = (SaveManager.get_total_coins() < cost)
		b_style.bg_color = Color(0.12, 0.65, 0.32, 1) if SaveManager.get_total_coins() >= cost else Color(0.3, 0.3, 0.35, 1)
		btn.pressed.connect(func(): _on_upgrade_stat(v_id, stat_key))
		
	btn.add_theme_stylebox_override("normal", b_style)
	hbox.add_child(btn)
	
	return panel

func _on_upgrade_stat(v_id: String, stat_key: String) -> void:
	if SaveManager.upgrade_vehicle_stat(v_id, stat_key):
		_update_view()

func _on_prev_vehicle() -> void:
	if vehicles_list.is_empty():
		return
	current_vehicle_index = (current_vehicle_index - 1 + vehicles_list.size()) % vehicles_list.size()
	_update_view()

func _on_next_vehicle() -> void:
	if vehicles_list.is_empty():
		return
	current_vehicle_index = (current_vehicle_index + 1) % vehicles_list.size()
	_update_view()

func _on_select_or_buy() -> void:
	var veh := vehicles_list[current_vehicle_index]
	var v_id: String = veh.get("id", "blue_flame_truck")
	if SaveManager.is_vehicle_unlocked(v_id):
		SaveManager.set_selected_vehicle_id(v_id)
		vehicle_selected.emit(v_id)
		_update_view()
	else:
		var cost: int = int(veh.get("unlock_cost", 0))
		if SaveManager.spend_coins(cost):
			SaveManager.unlock_vehicle(v_id)
			SaveManager.set_selected_vehicle_id(v_id)
			vehicle_selected.emit(v_id)
			_update_view()

func _on_drive() -> void:
	drive_pressed.emit()

func _on_back() -> void:
	back_pressed.emit()
