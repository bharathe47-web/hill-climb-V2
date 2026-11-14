class_name VintageCarGarageController
extends Control

## VintageCarGarageController: Controls the dedicated industrial showroom / garage.
## Implements vehicle showcase in spotlight, live stats inspection, dynamic coin balance,
## selection persistence via SaveManager, and top navigation according to vintage_car_garage_specification.md.

const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

signal return_to_main_menu_requested
signal vehicle_selected(vehicle_id: String)

@onready var coin_balance_label: Label = get_node_or_null("%CoinBalance")
@onready var vehicle_display_rect: TextureRect = get_node_or_null("%VehicleDisplayRect")
@onready var vehicle_shadow: Sprite2D = get_node_or_null("%VehicleShadow")
@onready var vehicle_name_label: Label = get_node_or_null("%VehicleNameLabel")
@onready var vehicle_desc_label: Label = get_node_or_null("%VehicleDescLabel")
@onready var select_button: Button = get_node_or_null("%SelectVehicleButton")
@onready var prev_button: Button = get_node_or_null("%PrevButton")
@onready var next_button: Button = get_node_or_null("%NextButton")

# Stat bars / labels
@onready var power_bar: ProgressBar = get_node_or_null("%PowerBar")
@onready var grip_bar: ProgressBar = get_node_or_null("%GripBar")
@onready var suspension_bar: ProgressBar = get_node_or_null("%SuspensionBar")
@onready var fuel_bar: ProgressBar = get_node_or_null("%FuelBar")

# Top Navigation buttons
@onready var trophy_button: TextureButton = get_node_or_null("%TrophyButton")
@onready var crown_button: TextureButton = get_node_or_null("%CrownButton")
@onready var share_button: TextureButton = get_node_or_null("%ShareButton")
@onready var home_button: TextureButton = get_node_or_null("%HomeButton")

# Dialog popups
@onready var info_dialog: PanelContainer = get_node_or_null("%InfoDialog")
@onready var info_title_label: Label = get_node_or_null("%InfoTitleLabel")
@onready var info_body_label: Label = get_node_or_null("%InfoBodyLabel")
@onready var info_close_button: Button = get_node_or_null("%InfoCloseButton")

# Audio players
@onready var ambience_player: AudioStreamPlayer = get_node_or_null("AmbiencePlayer")
@onready var sfx_player: AudioStreamPlayer = get_node_or_null("SFXPlayer")

const _SHADOW_PROFILES: Dictionary = {
	"blue_flame_truck": {
		"scale": Vector2(0.48, 0.32),
		"position": Vector2(0, 122),
		"alpha": 0.65
	},
	"orc_racer": {
		"scale": Vector2(0.72, 0.25),
		"position": Vector2(0, 95),
		"alpha": 0.58
	},
	"trophy_truck": {
		"scale": Vector2(0.76, 0.30),
		"position": Vector2(0, 102),
		"alpha": 0.62
	},
	"dune_buggy": {
		"scale": Vector2(0.68, 0.24),
		"position": Vector2(0, 96),
		"alpha": 0.55
	}
}

const _DEFAULT_SHADOW_PROFILE: Dictionary = {
	"scale": Vector2(0.65, 0.28),
	"position": Vector2(0, 100),
	"alpha": 0.60
}

var _shadow_tween: Tween = null

var _vehicles: Array[Dictionary] = []
var _current_index: int = 0
var _selected_id: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_vehicle_catalog()
	_update_coin_display()
	_connect_signals()
	_display_current_vehicle(true)
	
	if is_instance_valid(ambience_player) and not ambience_player.playing:
		ambience_player.play()

func _init_vehicle_catalog() -> void:
	_vehicles = VehicleRegistry.get_all_vehicles()
	_selected_id = SaveManager.get_selected_vehicle_id()
	
	# Find index of currently selected vehicle
	for i in range(_vehicles.size()):
		if _vehicles[i].get("id", "") == _selected_id:
			_current_index = i
			break

func _update_coin_display() -> void:
	if is_instance_valid(coin_balance_label):
		var total: int = SaveManager.get_total_coins()
		coin_balance_label.text = "%d" % total

func _connect_signals() -> void:
	if is_instance_valid(prev_button) and not prev_button.pressed.is_connected(_on_prev_pressed):
		prev_button.pressed.connect(_on_prev_pressed)
	if is_instance_valid(next_button) and not next_button.pressed.is_connected(_on_next_pressed):
		next_button.pressed.connect(_on_next_pressed)
	if is_instance_valid(select_button) and not select_button.pressed.is_connected(_on_select_pressed):
		select_button.pressed.connect(_on_select_pressed)
		
	# Top bar buttons
	if is_instance_valid(home_button) and not home_button.pressed.is_connected(_on_home_pressed):
		home_button.pressed.connect(_on_home_pressed)
	if is_instance_valid(trophy_button) and not trophy_button.pressed.is_connected(_on_trophy_pressed):
		trophy_button.pressed.connect(_on_trophy_pressed)
	if is_instance_valid(crown_button) and not crown_button.pressed.is_connected(_on_crown_pressed):
		crown_button.pressed.connect(_on_crown_pressed)
	if is_instance_valid(share_button) and not share_button.pressed.is_connected(_on_share_pressed):
		share_button.pressed.connect(_on_share_pressed)
		
	if is_instance_valid(info_close_button) and not info_close_button.pressed.is_connected(_close_info_dialog):
		info_close_button.pressed.connect(_close_info_dialog)

func _display_current_vehicle(immediate: bool = false) -> void:
	if _vehicles.is_empty():
		return
	
	var v_data: Dictionary = _vehicles[_current_index]
	var v_id: String = v_data.get("id", "")
	var v_name: String = v_data.get("display_name", "")
	var v_desc: String = v_data.get("description", "")
	var preview_path: String = v_data.get("preview_path", "")
	var ratings: Dictionary = v_data.get("stat_ratings", {})
	
	if is_instance_valid(vehicle_name_label):
		vehicle_name_label.text = v_name
	if is_instance_valid(vehicle_desc_label):
		vehicle_desc_label.text = v_desc
	
	# Load preview image
	if is_instance_valid(vehicle_display_rect):
		if not preview_path.is_empty() and ResourceLoader.exists(preview_path):
			vehicle_display_rect.texture = load(preview_path)
	
	# Dynamically update vehicle shadow to match current vehicle's stance and footprint
	_update_vehicle_shadow(v_id, immediate)
	
	# Stat ratings (0 to 5)
	if is_instance_valid(power_bar):
		power_bar.value = ratings.get("power", 3)
	if is_instance_valid(grip_bar):
		grip_bar.value = ratings.get("grip", 3)
	if is_instance_valid(suspension_bar):
		suspension_bar.value = ratings.get("suspension", 3)
	if is_instance_valid(fuel_bar):
		fuel_bar.value = ratings.get("fuel", 3)
	
	# Update select button status
	var is_active: bool = (v_id == _selected_id)
	if is_instance_valid(select_button):
		if is_active:
			select_button.text = "★ SELECTED (ACTIVE)"
			select_button.disabled = true
		else:
			select_button.text = "SELECT VEHICLE"
			select_button.disabled = false

func _update_vehicle_shadow(v_id: String, immediate: bool = false) -> void:
	if not is_instance_valid(vehicle_shadow):
		return
		
	var profile: Dictionary = _SHADOW_PROFILES.get(v_id, _DEFAULT_SHADOW_PROFILE)
	var target_scale: Vector2 = profile.get("scale", Vector2(0.65, 0.28))
	var target_pos: Vector2 = profile.get("position", Vector2(0, 100))
	var target_alpha: float = profile.get("alpha", 0.60)
	
	if immediate or not is_inside_tree():
		vehicle_shadow.scale = target_scale
		vehicle_shadow.position = target_pos
		vehicle_shadow.modulate.a = target_alpha
		return
		
	if _shadow_tween and _shadow_tween.is_valid():
		_shadow_tween.kill()
		
	_shadow_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_shadow_tween.tween_property(vehicle_shadow, "scale", target_scale, 0.2)
	_shadow_tween.tween_property(vehicle_shadow, "position", target_pos, 0.2)
	_shadow_tween.tween_property(vehicle_shadow, "modulate:a", target_alpha, 0.2)

func _on_prev_pressed() -> void:
	_play_sfx("res://assets/garage/06_audio/ui/sfx_button_click.wav")
	if _vehicles.is_empty():
		return
	_current_index = (_current_index - 1 + _vehicles.size()) % _vehicles.size()
	_display_current_vehicle()

func _on_next_pressed() -> void:
	_play_sfx("res://assets/garage/06_audio/ui/sfx_button_click.wav")
	if _vehicles.is_empty():
		return
	_current_index = (_current_index + 1) % _vehicles.size()
	_display_current_vehicle()

func _on_select_pressed() -> void:
	if _vehicles.is_empty():
		return
	
	var chosen_id: String = _vehicles[_current_index].get("id", "")
	SaveManager.set_selected_vehicle_id(chosen_id)
	_selected_id = chosen_id
	_play_sfx("res://assets/garage/06_audio/vehicle/sfx_vehicle_selection.wav")
	_display_current_vehicle()
	vehicle_selected.emit(chosen_id)

func _on_home_pressed() -> void:
	_play_sfx("res://assets/garage/06_audio/ui/sfx_button_click.wav")
	return_to_main_menu_requested.emit()

func _on_trophy_pressed() -> void:
	_play_sfx("res://assets/garage/06_audio/ui/sfx_button_click.wav")
	_show_info_dialog("ACHIEVEMENTS", "• First Drive: Start your journey\n• Distance Master: Reach 1000m\n• Coin Collector: Earn 500 Coins\n• Multi-car Owner: Inspect all vehicles")

func _on_crown_pressed() -> void:
	_play_sfx("res://assets/garage/06_audio/ui/sfx_button_click.wav")
	var best_dist: float = SaveManager.get_best_distance()
	_show_info_dialog("LEADERBOARD", "Local Record: %d meters\nGlobal Online Rankings: Coming Soon!" % int(best_dist))

func _on_share_pressed() -> void:
	_play_sfx("res://assets/garage/06_audio/ui/sfx_nav_feedback.wav")
	var v_name: String = _vehicles[_current_index].get("display_name", "Vehicle")
	_show_info_dialog("SHARE GARAGE", "Showcase: %s ready for driving!\nScreenshot and vehicle profile link copied." % v_name)

func _show_info_dialog(title: String, body: String) -> void:
	if is_instance_valid(info_dialog):
		if is_instance_valid(info_title_label):
			info_title_label.text = title
		if is_instance_valid(info_body_label):
			info_body_label.text = body
		info_dialog.visible = true

func _close_info_dialog() -> void:
	_play_sfx("res://assets/garage/06_audio/ui/sfx_button_click.wav")
	if is_instance_valid(info_dialog):
		info_dialog.visible = false

func _play_sfx(path: String) -> void:
	if is_instance_valid(sfx_player) and ResourceLoader.exists(path):
		sfx_player.stream = load(path)
		sfx_player.play()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if is_instance_valid(info_dialog) and info_dialog.visible:
		if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			_close_info_dialog()
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_home_pressed()
	elif event.is_action_pressed("ui_left"):
		get_viewport().set_input_as_handled()
		_on_prev_pressed()
	elif event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		_on_next_pressed()
