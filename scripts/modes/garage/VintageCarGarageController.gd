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

## Dedicated Preview Area Constants (Single uniform rule for ALL vehicles)
const PREVIEW_WIDTH: float = 1000.0
const PREVIEW_HEIGHT: float = 420.0
const TARGET_WIDTH_RATIO: float = 0.70
const MIN_MARGIN_RATIO: float = 0.05
const FLOOR_Y: float = 505.0

var _shadow_tween: Tween = null
var _debug_overlay_control: Control = null

var _vehicles: Array[Dictionary] = []
var _current_index: int = 0
var _selected_id: String = ""

## Measures real vehicle bounds from config (body plus wheels)
static func get_vehicle_real_bounds(cfg: Dictionary) -> Dictionary:
	var bw: float = cfg.get("body_size", Vector2(800, 400)).x
	var bh: float = cfg.get("body_size", Vector2(800, 400)).y
	var pivot: Vector2 = cfg.get("body_pivot", Vector2(bw * 0.5, bh * 0.5))
	var r_off: Vector2 = cfg.get("rear_wheel_offset", Vector2.ZERO)
	var f_off: Vector2 = cfg.get("front_wheel_offset", Vector2.ZERO)
	var wr: float = cfg.get("wheel_radius", 100.0)
	var eng_off: Vector2 = cfg.get("engine_offset", Vector2.ZERO)
	
	var min_x = minf(-pivot.x, minf(r_off.x - wr, f_off.x - wr))
	var max_x = maxf(bw - pivot.x, maxf(r_off.x + wr, f_off.x + wr))
	var min_y = minf(-pivot.y, minf(r_off.y - wr, f_off.y - wr))
	var max_y = maxf(bh - pivot.y, maxf(r_off.y + wr, f_off.y + wr))
	
	var real_w = max_x - min_x
	var real_h = max_y - min_y
	
	return {
		"min_x": min_x,
		"max_x": max_x,
		"min_y": min_y,
		"max_y": max_y,
		"real_w": real_w,
		"real_h": real_h,
		"pivot": pivot,
		"rear_offset": r_off,
		"front_offset": f_off,
		"engine_offset": eng_off,
		"wheel_radius": wr
	}

## Computes uniform preview scale to fill ~70% width while guaranteeing >= 5% margins on every side
static func compute_uniform_preview_scale(real_w: float, real_h: float) -> float:
	var target_w: float = PREVIEW_WIDTH * TARGET_WIDTH_RATIO # 700.0
	var max_w: float = PREVIEW_WIDTH * (1.0 - 2.0 * MIN_MARGIN_RATIO) # 900.0
	var max_h: float = PREVIEW_HEIGHT * (1.0 - 2.0 * MIN_MARGIN_RATIO) # 378.0
	
	var s: float = target_w / real_w
	if real_w * s > max_w:
		s = max_w / real_w
	if real_h * s > max_h:
		s = max_h / real_h
	return s

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_vehicle_catalog()
	_update_coin_display()
	_connect_signals()
	_init_debug_overlay()
	_display_current_vehicle(true)
	
	if is_inside_tree() and is_instance_valid(ambience_player) and not ambience_player.playing:
		ambience_player.play()

func _process(_delta: float) -> void:
	if is_instance_valid(_debug_overlay_control):
		_debug_overlay_control.visible = VehicleController.debug_alignment_enabled
		if _debug_overlay_control.visible:
			_debug_overlay_control.queue_redraw()

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
	var v_name: String = v_data.get("display_name", "Vehicle")
	var v_desc: String = v_data.get("description", "")
	var preview_path: String = v_data.get("preview_path", "")
	var ratings: Dictionary = v_data.get("stat_ratings", {})
	
	if is_instance_valid(vehicle_name_label):
		vehicle_name_label.text = v_name
	if is_instance_valid(vehicle_desc_label):
		vehicle_desc_label.text = v_desc
	
	# Load preview image with natural viewing size (avoid unnecessary zooming)
	var cfg: Dictionary = VehicleRegistry.get_vehicle_config(v_id)
	var bounds: Dictionary = get_vehicle_real_bounds(cfg)
	var scale_val: float = compute_uniform_preview_scale(bounds.real_w, bounds.real_h)
	var scaled_w: float = bounds.real_w * scale_val
	var scaled_h: float = bounds.real_h * scale_val
	
	if is_instance_valid(vehicle_display_rect):
		vehicle_display_rect.custom_minimum_size = Vector2(scaled_w, scaled_h)
		vehicle_display_rect.size = Vector2(scaled_w, scaled_h)
		# Centered horizontally at 640.0, wheels touch garage floor (Y = 505.0)
		# Since VehicleDisplay is positioned at (640, 505):
		vehicle_display_rect.position = Vector2(-scaled_w * 0.5, -scaled_h)
		if not preview_path.is_empty():
			var global_p = ProjectSettings.globalize_path(preview_path)
			if FileAccess.file_exists(preview_path) or FileAccess.file_exists(global_p):
				var img = Image.load_from_file(global_p)
				if img and not img.is_empty():
					vehicle_display_rect.texture = ImageTexture.create_from_image(img)
				elif ResourceLoader.exists(preview_path):
					vehicle_display_rect.texture = load(preview_path)
				else:
					vehicle_display_rect.texture = null
			elif ResourceLoader.exists(preview_path):
				vehicle_display_rect.texture = load(preview_path)
			else:
				vehicle_display_rect.texture = null
		else:
			vehicle_display_rect.texture = null
	
	# Dynamically update vehicle shadow to match current vehicle's stance and footprint
	_update_vehicle_shadow(scaled_w, immediate)
	
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

func _update_vehicle_shadow(scaled_w: float, immediate: bool = false) -> void:
	if not is_instance_valid(vehicle_shadow):
		return
		
	var target_scale = Vector2((scaled_w / 700.0) * 0.60, 0.24)
	var target_pos = Vector2(0, 0)
	var target_alpha: float = 0.60
	
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
	if is_inside_tree() and is_instance_valid(sfx_player) and ResourceLoader.exists(path):
		sfx_player.stream = load(path)
		sfx_player.play()

func _init_debug_overlay() -> void:
	if not is_instance_valid(vehicle_display_rect):
		return
	_debug_overlay_control = Control.new()
	_debug_overlay_control.name = "AlignmentDebugOverlay"
	_debug_overlay_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_debug_overlay_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_debug_overlay_control.draw.connect(_on_debug_overlay_draw)
	vehicle_display_rect.add_child(_debug_overlay_control)

func _on_debug_overlay_draw() -> void:
	if not VehicleController.debug_alignment_enabled:
		return
	if _vehicles.is_empty():
		return
	var cur_id: String = _vehicles[_current_index].get("id", "")
	var rect_size: Vector2 = vehicle_display_rect.size
	if rect_size.x <= 0 or rect_size.y <= 0:
		return
	var cfg: Dictionary = VehicleRegistry.get_vehicle_config(cur_id)
	if cfg.is_empty():
		return
		
	var bounds: Dictionary = get_vehicle_real_bounds(cfg)
	var scale_val: float = compute_uniform_preview_scale(bounds.real_w, bounds.real_h)
	
	var rear_pos: Vector2 = Vector2(-bounds.min_x + bounds.rear_offset.x, -bounds.min_y + bounds.rear_offset.y) * scale_val
	var front_pos: Vector2 = Vector2(-bounds.min_x + bounds.front_offset.x, -bounds.min_y + bounds.front_offset.y) * scale_val
	var eng_pos: Vector2 = Vector2(-bounds.min_x + bounds.engine_offset.x, -bounds.min_y + bounds.engine_offset.y) * scale_val
	var wheel_r: float = bounds.wheel_radius * scale_val
	
	# Draw arch / axle centers (red dots)
	_debug_overlay_control.draw_circle(rear_pos, 5.0, Color(1.0, 0.0, 0.0, 0.95))
	_debug_overlay_control.draw_circle(front_pos, 5.0, Color(1.0, 0.0, 0.0, 0.95))
	
	# Draw wheel circles (green circles)
	_debug_overlay_control.draw_arc(rear_pos, wheel_r, 0, TAU, 36, Color(0.0, 1.0, 0.0, 0.95), 2.5)
	_debug_overlay_control.draw_circle(rear_pos, 2.5, Color(0.0, 1.0, 0.0, 0.95))
	_debug_overlay_control.draw_arc(front_pos, wheel_r, 0, TAU, 36, Color(0.0, 1.0, 0.0, 0.95), 2.5)
	_debug_overlay_control.draw_circle(front_pos, 2.5, Color(0.0, 1.0, 0.0, 0.95))
	
	# Draw engine point (orange dot)
	_debug_overlay_control.draw_circle(eng_pos, 5.0, Color(1.0, 0.55, 0.0, 0.95))

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
		VehicleController.debug_alignment_enabled = not VehicleController.debug_alignment_enabled
		print("[DEBUG] Garage alignment overlay toggled: %s" % ("ON" if VehicleController.debug_alignment_enabled else "OFF"))
		if is_instance_valid(_debug_overlay_control):
			_debug_overlay_control.queue_redraw()
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
