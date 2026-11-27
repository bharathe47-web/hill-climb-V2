class_name HUDController
extends Control

## HUDController: Displays real-time run telemetry, fuel status, rewards, and notifications.
## Binds cleanly to GameManager and Vehicle signals with zero hard-coded coupling.
## Responsive across mobile and desktop display aspect ratios.

@onready var distance_label: Label = %DistanceLabel
@onready var best_distance_label: Label = %BestDistanceLabel
@onready var fuel_bar: ProgressBar = %FuelBar
@onready var fuel_percentage_label: Label = get_node_or_null("%FuelPercentageLabel")
@onready var low_fuel_indicator: Label = get_node_or_null("%LowFuelIndicator")
@onready var nitro_bar: ProgressBar = get_node_or_null("%NitroBar")
@onready var nitro_percentage_label: Label = get_node_or_null("%NitroPercentageLabel")
@onready var coins_label: Label = get_node_or_null("%CoinsLabel")
@onready var coins_panel: PanelContainer = get_node_or_null("CoinsPanel")

@onready var _rpm_needle: Sprite2D = get_node_or_null("%RPMNeedle")
@onready var speed_needle: Sprite2D = get_node_or_null("%SpeedNeedle")
@onready var speed_digital_label: Label = get_node_or_null("%SpeedDigitalLabel")
@onready var gas_pedal: TextureButton = get_node_or_null("%GasPedal")
@onready var brake_pedal: TextureButton = get_node_or_null("%BrakePedal")
@onready var nitro_button: TextureButton = get_node_or_null("%NitroButton")
@onready var nitro_button_label: Label = get_node_or_null("%NitroButtonLabel")
@onready var pause_button: TextureButton = get_node_or_null("%PauseButton")

@onready var message_banner: PanelContainer = %MessageBanner
@onready var message_title_label: Label = get_node_or_null("%MessageTitleLabel")
@onready var message_label: Label = %MessageLabel
@onready var retry_hint_label: Label = get_node_or_null("%RetryHintLabel")
@onready var pause_banner: PanelContainer = get_node_or_null("%PauseBanner")

var game_manager_ref: Node
var _vehicle_ref: Node = null
var _flash_timer: float = 0.0
var _is_low_fuel: bool = false
var _target_fuel: float = 100.0
var _target_nitro: float = 100.0
var _pothole_pulse_active: bool = false
var _pothole_pulse_timer: float = 0.0
var _last_coins_count: int = 0

# Style boxes for dynamic fuel bar feedback
var _fuel_style_healthy: StyleBoxFlat
var _fuel_style_warning: StyleBoxFlat
var _fuel_style_critical: StyleBoxFlat

# Stunt and distance milestone toast feedback
var _toast_panel: PanelContainer
var _toast_title_label: Label
var _toast_subtitle_label: Label
var _toast_tween: Tween
var _milestones_reached: Array[int] = []

# Branching Encounter & Ramp Prompt HUD (Phase 5)
var progression_controller_ref: BiomeProgressionController = null
var _ramp_prompt_panel: PanelContainer
var _ramp_title_label: Label
var _ramp_subtitle_label: Label
var _ramp_prompt_tween: Tween
var _has_seen_first_ramp_tutorial: bool = false
var _is_launch_window_active: bool = false
var _launch_pulse_timer: float = 0.0
var _ramp_stylebox: StyleBoxFlat

func _ready() -> void:
	_init_fuel_styles()
	_init_toast_panel()
	_init_ramp_prompt_panel()
	
	if message_banner:
		message_banner.visible = false
	if pause_banner:
		pause_banner.visible = false
	if low_fuel_indicator:
		low_fuel_indicator.visible = false
		
	if gas_pedal and not gas_pedal.button_down.is_connected(_on_gas_down):
		gas_pedal.button_down.connect(_on_gas_down)
		gas_pedal.button_up.connect(_on_gas_up)
	if brake_pedal and not brake_pedal.button_down.is_connected(_on_brake_down):
		brake_pedal.button_down.connect(_on_brake_down)
		brake_pedal.button_up.connect(_on_brake_up)
	if nitro_button and not nitro_button.button_down.is_connected(_on_nitro_button_down):
		nitro_button.button_down.connect(_on_nitro_button_down)
		nitro_button.button_up.connect(_on_nitro_button_up)
	if pause_button and not pause_button.pressed.is_connected(_on_pause_button_pressed):
		pause_button.pressed.connect(_on_pause_button_pressed)

	# Fallback auto-discovery if running in standalone scene
	call_deferred("_auto_discover_bindings")

func _auto_discover_bindings() -> void:
	var tree_root := get_tree().root
	if tree_root:
		if not is_instance_valid(game_manager_ref):
			var gm = tree_root.find_child("GameManager", true, false)
			if is_instance_valid(gm):
				bind_game_manager(gm)
		if not is_instance_valid(_vehicle_ref):
			var veh = tree_root.find_child("Vehicle", true, false)
			if is_instance_valid(veh) and veh.has_method("refuel"):
				bind_vehicle(veh)
		if not is_instance_valid(progression_controller_ref):
			var pc = tree_root.find_child("BiomeProgressionController", true, false)
			if is_instance_valid(pc) and pc is BiomeProgressionController:
				bind_progression_controller(pc)

func _init_fuel_styles() -> void:
	_fuel_style_healthy = StyleBoxFlat.new()
	_fuel_style_healthy.bg_color = Color(0.22, 0.82, 0.36, 1.0)
	_fuel_style_healthy.border_width_top = 1
	_fuel_style_healthy.border_color = Color(0.5, 0.95, 0.6, 0.8)
	_fuel_style_healthy.set_corner_radius_all(5)
	
	_fuel_style_warning = StyleBoxFlat.new()
	_fuel_style_warning.bg_color = Color(0.98, 0.72, 0.16, 1.0)
	_fuel_style_warning.border_width_top = 1
	_fuel_style_warning.border_color = Color(1.0, 0.88, 0.45, 0.8)
	_fuel_style_warning.set_corner_radius_all(5)
	
	_fuel_style_critical = StyleBoxFlat.new()
	_fuel_style_critical.bg_color = Color(0.95, 0.22, 0.18, 1.0)
	_fuel_style_critical.border_width_top = 1
	_fuel_style_critical.border_color = Color(1.0, 0.55, 0.5, 0.8)
	_fuel_style_critical.set_corner_radius_all(5)

func _process(delta: float) -> void:
	# Smoothly animate fuel bar towards target level during driving
	if fuel_bar and absf(fuel_bar.value - _target_fuel) > 0.1:
		fuel_bar.value = lerpf(fuel_bar.value, _target_fuel, delta * 12.0)

	# Smoothly animate nitro bar towards target level
	if nitro_bar and absf(nitro_bar.value - _target_nitro) > 0.1:
		nitro_bar.value = lerpf(nitro_bar.value, _target_nitro, delta * 14.0)

	# Pulse nitro button when struggling in pothole
	if _pothole_pulse_active and nitro_button:
		_pothole_pulse_timer += delta * 8.0
		var pulse := (sin(_pothole_pulse_timer) * 0.5) + 0.5
		nitro_button.modulate = Color(0.2, 0.8, 1.0).lerp(Color(1.0, 1.0, 0.3), pulse)
		var s := 1.0 + sin(_pothole_pulse_timer) * 0.08
		nitro_button.scale = Vector2(s, s)
		nitro_button.pivot_offset = nitro_button.size * 0.5
	elif _is_launch_window_active:
		# Vibrant pulse on Nitro Button and Nitro Bar during Launch Window (Phase 5)
		_launch_pulse_timer += delta * 11.0
		var pulse := (sin(_launch_pulse_timer) * 0.5) + 0.5
		var s := 1.0 + sin(_launch_pulse_timer) * 0.12
		if nitro_button:
			nitro_button.scale = Vector2(s, s)
			nitro_button.pivot_offset = nitro_button.size * 0.5
			nitro_button.modulate = Color(0.25, 0.9, 1.0).lerp(Color(1.0, 0.95, 0.25), pulse)
		if nitro_bar:
			nitro_bar.modulate = Color(0.25, 0.9, 1.0).lerp(Color(1.0, 0.95, 0.25), pulse)
	
	# Animate RPM needle based on vehicle wheel angular velocity
	if is_instance_valid(_rpm_needle) and is_instance_valid(_vehicle_ref):
		var ang_vel: float = 0.0
		var rw = _vehicle_ref.get_node_or_null("RearWheel")
		if is_instance_valid(rw) and "angular_velocity" in rw:
			ang_vel = absf(rw.angular_velocity)
		var rpm_ratio: float = clampf(ang_vel / 80.0, 0.0, 1.0)
		var target_rot: float = deg_to_rad(lerpf(-120.0, 120.0, rpm_ratio))
		_rpm_needle.rotation = lerp_angle(_rpm_needle.rotation, target_rot, delta * 12.0)

	# Animate Speedometer needle and digital readout based on vehicle.get_speed_kmh()
	if is_instance_valid(speed_needle) and is_instance_valid(_vehicle_ref):
		var speed_kmh: float = 0.0
		if _vehicle_ref.has_method("get_speed_kmh"):
			speed_kmh = maxf(0.0, _vehicle_ref.get_speed_kmh())
		var speed_ratio: float = clampf(speed_kmh / 220.0, 0.0, 1.0)
		var target_speed_rot: float = deg_to_rad(lerpf(-135.0, 135.0, speed_ratio))
		speed_needle.rotation = lerp_angle(speed_needle.rotation, target_speed_rot, delta * 14.0)
		if is_instance_valid(speed_digital_label):
			speed_digital_label.text = str(int(round(speed_kmh)))
	_update_wooden_needle(delta)

	# Pulse low fuel beacon when critical
	if _is_low_fuel:
		_flash_timer += delta * 7.0
		var alpha := (sin(_flash_timer) * 0.5) + 0.5
		if low_fuel_indicator:
			low_fuel_indicator.visible = true
			low_fuel_indicator.modulate.a = alpha
			var s := 1.0 + (sin(_flash_timer) * 0.08)
			low_fuel_indicator.scale = Vector2(s, s)
	else:
		if low_fuel_indicator and low_fuel_indicator.visible:
			low_fuel_indicator.visible = false
			low_fuel_indicator.scale = Vector2.ONE

func _on_gas_down() -> void:
	Input.action_press("accelerate")

func _on_gas_up() -> void:
	Input.action_release("accelerate")

func _on_brake_down() -> void:
	Input.action_press("brake_reverse")

func _on_brake_up() -> void:
	Input.action_release("brake_reverse")

func _on_nitro_button_down() -> void:
	Input.action_press("nitro")
	if is_instance_valid(_vehicle_ref) and _vehicle_ref.has_method("set_nitro_active"):
		_vehicle_ref.set_nitro_active(true)

func _on_nitro_button_up() -> void:
	Input.action_release("nitro")
	if is_instance_valid(_vehicle_ref) and _vehicle_ref.has_method("set_nitro_active"):
		_vehicle_ref.set_nitro_active(false)

func _on_pause_button_pressed() -> void:
	var ev := InputEventAction.new()
	ev.action = "pause"
	ev.pressed = true
	Input.parse_input_event(ev)
	# Release the synthetic press shortly after, otherwise "pause" stays held forever and
	# is_action_just_pressed("pause") never fires again (pause button only worked once).
	# process_always=true so the timer still runs while the tree is paused.
	get_tree().create_timer(0.1, true).timeout.connect(_release_pause_action)

func _release_pause_action() -> void:
	var ev := InputEventAction.new()
	ev.action = "pause"
	ev.pressed = false
	Input.parse_input_event(ev)

## Binds to GameManager signals
func bind_game_manager(gm: Node) -> void:
	game_manager_ref = gm
	if not is_instance_valid(gm):
		return
	
	if not gm.distance_updated.is_connected(_on_distance_updated):
		gm.distance_updated.connect(_on_distance_updated)
	if not gm.fuel_updated.is_connected(_on_fuel_updated):
		gm.fuel_updated.connect(_on_fuel_updated)
	if not gm.run_finished.is_connected(_on_run_finished):
		gm.run_finished.connect(_on_run_finished)
	if not gm.run_started.is_connected(_on_run_started):
		gm.run_started.connect(_on_run_started)
	
	if gm.has_signal("coins_updated") and not gm.coins_updated.is_connected(_on_coins_updated):
		gm.coins_updated.connect(_on_coins_updated)
	
	if gm.has_signal("run_paused") and not gm.run_paused.is_connected(_on_run_paused):
		gm.run_paused.connect(_on_run_paused)
		
	_update_best_distance()
	if "coins_collected" in gm:
		_on_coins_updated(gm.coins_collected)

## Binds to VehicleController signals
func bind_vehicle(vehicle: Node) -> void:
	if not is_instance_valid(vehicle):
		return
	_vehicle_ref = vehicle
	if vehicle.has_signal("fuel_changed") and not vehicle.fuel_changed.is_connected(_on_fuel_updated):
		vehicle.fuel_changed.connect(_on_fuel_updated)
	if vehicle.has_signal("crashed") and not vehicle.crashed.is_connected(_on_vehicle_crashed):
		vehicle.crashed.connect(_on_vehicle_crashed)
	if vehicle.has_signal("trick_performed") and not vehicle.trick_performed.is_connected(_on_trick_performed):
		vehicle.trick_performed.connect(_on_trick_performed)
	if vehicle.has_signal("airtime_landed") and not vehicle.airtime_landed.is_connected(_on_airtime_landed):
		vehicle.airtime_landed.connect(_on_airtime_landed)
	if vehicle.has_signal("clean_landed") and not vehicle.clean_landed.is_connected(_on_clean_landed):
		vehicle.clean_landed.connect(_on_clean_landed)
	if vehicle.has_signal("nitro_changed") and not vehicle.nitro_changed.is_connected(_on_nitro_updated):
		vehicle.nitro_changed.connect(_on_nitro_updated)
	if vehicle.has_signal("nitro_state_changed") and not vehicle.nitro_state_changed.is_connected(_on_nitro_state_changed):
		vehicle.nitro_state_changed.connect(_on_nitro_state_changed)
	if vehicle.has_signal("pothole_assist_hint") and not vehicle.pothole_assist_hint.is_connected(_on_pothole_assist_hint):
		vehicle.pothole_assist_hint.connect(_on_pothole_assist_hint)
	
	var c_nit = vehicle.get("current_nitro")
	if c_nit != null:
		_target_nitro = float(c_nit)
		var m_nit = vehicle.get("max_nitro")
		var m_val: float = float(m_nit) if m_nit != null else 100.0
		_on_nitro_updated(float(c_nit), m_val)

func _update_best_distance() -> void:
	if best_distance_label and is_instance_valid(game_manager_ref) and "best_distance" in game_manager_ref:
		best_distance_label.text = "Best: %d m" % int(game_manager_ref.best_distance)

func _on_distance_updated(new_distance: float) -> void:
	if distance_label:
		distance_label.text = "%d m" % int(new_distance)
	
	# Check distance milestones (100m, 250m, 500m, 1000m, 1500m, 2000m, 3000m, 5000m)
	var current_int: int = int(new_distance)
	for m in [100, 250, 500, 1000, 1500, 2000, 3000, 5000]:
		if current_int >= m and not (m in _milestones_reached):
			_milestones_reached.append(m)
			show_toast("🏁 %d METERS REACHED! 🏁" % m, "Keep Climbing!", Color(0.25, 0.9, 0.55))

func _on_trick_performed(trick_name: String, reward_coins: int) -> void:
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("add_coins"):
		game_manager_ref.add_coins(reward_coins)
	show_toast("★ %s! ★" % trick_name.to_upper(), "+%d Coins" % reward_coins, Color(1.0, 0.85, 0.2))

func _on_airtime_landed(duration: float, reward_coins: int) -> void:
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("add_coins"):
		game_manager_ref.add_coins(reward_coins)
	show_toast("★ BIG AIR! (%.1fs) ★" % duration, "+%d Coins" % reward_coins, Color(0.35, 0.85, 1.0))

func _on_clean_landed(bonus_coins: int) -> void:
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("add_coins"):
		game_manager_ref.add_coins(bonus_coins)
	show_toast("CLEAN LANDING!", "+%d Coins" % bonus_coins, Color(0.35, 0.95, 0.45))

func _on_fuel_updated(current: float, max_val: float) -> void:
	_target_fuel = current
	if fuel_bar:
		fuel_bar.max_value = max_val
		fuel_bar.value = current # Immediate sync for assertion safety
	
	var pct: float = (current / max_val) * 100.0 if max_val > 0.0 else 0.0
	if fuel_percentage_label:
		fuel_percentage_label.text = "%d%%" % int(pct)
	
	# Dynamic color and low-fuel warning state
	if pct <= 20.0:
		_is_low_fuel = true
		if fuel_bar and _fuel_style_critical:
			fuel_bar.add_theme_stylebox_override("fill", _fuel_style_critical)
	elif pct <= 45.0:
		_is_low_fuel = false
		if fuel_bar and _fuel_style_warning:
			fuel_bar.add_theme_stylebox_override("fill", _fuel_style_warning)
	else:
		_is_low_fuel = false
		if fuel_bar and _fuel_style_healthy:
			fuel_bar.add_theme_stylebox_override("fill", _fuel_style_healthy)

func _on_nitro_updated(current: float, max_val: float) -> void:
	_target_nitro = current
	if nitro_bar:
		nitro_bar.max_value = max_val
		nitro_bar.value = current
	var pct: float = (current / max_val) * 100.0 if max_val > 0.0 else 0.0
	if nitro_percentage_label:
		nitro_percentage_label.text = "%d%%" % int(pct)
	
	if nitro_button:
		if current <= 0.0:
			nitro_button.modulate = Color(0.5, 0.5, 0.5, 0.6)
		elif not _pothole_pulse_active:
			nitro_button.modulate = Color.WHITE

func _on_nitro_state_changed(is_boosting: bool) -> void:
	if nitro_button:
		if is_boosting:
			nitro_button.modulate = Color(1.3, 1.3, 1.5, 1.0)
		elif not _pothole_pulse_active:
			nitro_button.modulate = Color.WHITE
	if nitro_bar:
		if is_boosting:
			nitro_bar.modulate = Color(1.3, 1.3, 1.5, 1.0)
		else:
			nitro_bar.modulate = Color.WHITE

func _on_pothole_assist_hint(should_hint: bool) -> void:
	_pothole_pulse_active = should_hint
	if not should_hint and nitro_button:
		nitro_button.modulate = Color.WHITE
		nitro_button.scale = Vector2.ONE

func _on_coins_updated(count: int) -> void:
	if coins_label:
		coins_label.text = str(count)
		# Subtle pop animation on coin count increase
		if count > _last_coins_count and is_instance_valid(coins_panel):
			var tw := create_tween()
			tw.tween_property(coins_panel, "scale", Vector2(1.1, 1.1), 0.1)
			tw.tween_property(coins_panel, "scale", Vector2.ONE, 0.15)
	_last_coins_count = count

func _on_run_paused(is_paused: bool) -> void:
	if pause_banner:
		pause_banner.visible = is_paused

func _on_run_started() -> void:
	_is_low_fuel = false
	_pothole_pulse_active = false
	_is_launch_window_active = false
	_hide_ramp_prompt()
	if nitro_button:
		nitro_button.scale = Vector2.ONE
		nitro_button.modulate = Color.WHITE
	if nitro_bar:
		nitro_bar.scale = Vector2.ONE
		nitro_bar.modulate = Color.WHITE
	_milestones_reached.clear()
	if is_instance_valid(_toast_panel):
		_toast_panel.visible = false
	if message_banner:
		message_banner.visible = false
	if pause_banner:
		pause_banner.visible = false
	if low_fuel_indicator:
		low_fuel_indicator.visible = false
	
	_update_best_distance()
	if distance_label:
		distance_label.text = "0 m"
	if coins_label and is_instance_valid(game_manager_ref) and "coins_collected" in game_manager_ref:
		coins_label.text = str(game_manager_ref.coins_collected)
		_last_coins_count = game_manager_ref.coins_collected

func _on_vehicle_crashed() -> void:
	if is_instance_valid(_toast_panel):
		_toast_panel.visible = false
	if message_banner:
		message_banner.visible = true
	if message_title_label:
		message_title_label.text = "DRIVER CRASHED!"
		message_title_label.modulate = Color(0.98, 0.28, 0.24)
	if message_label:
		var current_dist: int = int(game_manager_ref.current_distance) if is_instance_valid(game_manager_ref) and "current_distance" in game_manager_ref else 0
		var best_dist: int = int(game_manager_ref.best_distance) if is_instance_valid(game_manager_ref) and "best_distance" in game_manager_ref else 0
		message_label.text = "Distance: %d m\nBest: %d m" % [current_dist, best_dist]
	if retry_hint_label:
		retry_hint_label.text = "Press [R] to Retry"

func _on_run_finished(final_distance: float, coins: int = 0, reason: String = "") -> void:
	if is_instance_valid(_toast_panel):
		_toast_panel.visible = false
	if message_banner:
		message_banner.visible = true
	if message_title_label:
		match reason:
			"crashed":
				message_title_label.text = "DRIVER CRASHED!"
				message_title_label.modulate = Color(0.98, 0.28, 0.24)
			"out_of_fuel":
				message_title_label.text = "OUT OF FUEL!"
				message_title_label.modulate = Color(0.98, 0.65, 0.15)
			_:
				message_title_label.text = "RUN FINISHED!"
				message_title_label.modulate = Color(0.35, 0.85, 0.45)
	if message_label:
		var best_dist: int = int(game_manager_ref.best_distance) if is_instance_valid(game_manager_ref) and "best_distance" in game_manager_ref else int(final_distance)
		message_label.text = "Distance: %d m\nCoins: %d\nBest: %d m" % [int(final_distance), coins, best_dist]
	if retry_hint_label:
		retry_hint_label.text = "Press [R] to Retry"
	_update_best_distance()

# --- TOAST NOTIFICATIONS (STUNTS & MILESTONES) ---

func _init_toast_panel() -> void:
	_toast_panel = PanelContainer.new()
	_toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_panel.anchors_preset = Control.PRESET_CENTER_TOP
	_toast_panel.anchor_left = 0.5
	_toast_panel.anchor_right = 0.5
	_toast_panel.anchor_top = 0.0
	_toast_panel.offset_left = -170.0
	_toast_panel.offset_top = 22.0
	_toast_panel.offset_right = 170.0
	_toast_panel.offset_bottom = 84.0
	_toast_panel.visible = false
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.09, 0.16, 0.94)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.92, 0.82, 0.25, 0.9)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 10
	_toast_panel.add_theme_stylebox_override("panel", style)
	
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 8)
	
	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	
	_toast_title_label = Label.new()
	_toast_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_title_label.add_theme_font_size_override("font_size", 16)
	_toast_title_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.25))
	vbox.add_child(_toast_title_label)
	
	_toast_subtitle_label = Label.new()
	_toast_subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_subtitle_label.add_theme_font_size_override("font_size", 13)
	_toast_subtitle_label.add_theme_color_override("font_color", Color(0.85, 0.94, 0.98))
	vbox.add_child(_toast_subtitle_label)
	
	margin.add_child(vbox)
	_toast_panel.add_child(margin)
	add_child(_toast_panel)

func show_toast(title: String, subtitle: String = "", highlight_color: Color = Color(1.0, 0.85, 0.2)) -> void:
	if not is_instance_valid(_toast_panel):
		_init_toast_panel()
	
	_toast_title_label.text = title
	_toast_title_label.add_theme_color_override("font_color", highlight_color)
	_toast_subtitle_label.text = subtitle
	_toast_subtitle_label.visible = subtitle != ""
	
	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	
	_toast_panel.visible = true
	_toast_panel.modulate.a = 0.0
	_toast_panel.scale = Vector2(0.85, 0.85)
	_toast_panel.pivot_offset = Vector2(170.0, 31.0)
	
	_toast_tween = create_tween()
	_toast_tween.set_parallel(true)
	_toast_tween.tween_property(_toast_panel, "modulate:a", 1.0, 0.16)
	_toast_tween.tween_property(_toast_panel, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	_toast_tween.chain().tween_interval(1.5)
	
	_toast_tween.chain().tween_property(_toast_panel, "modulate:a", 0.0, 0.25)
	_toast_tween.tween_callback(func(): _toast_panel.visible = false)

# --- BRANCHING ENCOUNTER & RAMP PROMPT SYSTEM (PHASE 5) ---

func _init_ramp_prompt_panel() -> void:
	if is_instance_valid(_ramp_prompt_panel):
		return
	
	_ramp_prompt_panel = PanelContainer.new()
	_ramp_prompt_panel.name = "RampPromptPanel"
	_ramp_prompt_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ramp_prompt_panel.anchors_preset = Control.PRESET_CENTER_TOP
	_ramp_prompt_panel.anchor_left = 0.5
	_ramp_prompt_panel.anchor_right = 0.5
	_ramp_prompt_panel.anchor_top = 0.0
	_ramp_prompt_panel.offset_left = -220.0
	_ramp_prompt_panel.offset_top = 92.0
	_ramp_prompt_panel.offset_right = 220.0
	_ramp_prompt_panel.offset_bottom = 162.0
	_ramp_prompt_panel.visible = false
	
	_ramp_stylebox = StyleBoxFlat.new()
	_ramp_stylebox.bg_color = Color(0.04, 0.07, 0.13, 0.94)
	_ramp_stylebox.border_width_left = 2
	_ramp_stylebox.border_width_top = 2
	_ramp_stylebox.border_width_right = 2
	_ramp_stylebox.border_width_bottom = 2
	_ramp_stylebox.border_color = Color(1.0, 0.85, 0.25, 0.95)
	_ramp_stylebox.set_corner_radius_all(10)
	_ramp_stylebox.shadow_color = Color(0, 0, 0, 0.55)
	_ramp_stylebox.shadow_size = 12
	_ramp_prompt_panel.add_theme_stylebox_override("panel", _ramp_stylebox)
	
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 10)
	
	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	
	_ramp_title_label = Label.new()
	_ramp_title_label.name = "RampTitleLabel"
	_ramp_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ramp_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ramp_title_label.add_theme_font_size_override("font_size", 16)
	_ramp_title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	vbox.add_child(_ramp_title_label)
	
	_ramp_subtitle_label = Label.new()
	_ramp_subtitle_label.name = "RampSubtitleLabel"
	_ramp_subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ramp_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ramp_subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ramp_subtitle_label.add_theme_font_size_override("font_size", 12)
	_ramp_subtitle_label.add_theme_color_override("font_color", Color(0.88, 0.94, 0.98))
	vbox.add_child(_ramp_subtitle_label)
	
	margin.add_child(vbox)
	_ramp_prompt_panel.add_child(margin)
	add_child(_ramp_prompt_panel)

func _show_ramp_prompt(title: String, subtitle: String, border_color: Color, title_color: Color) -> void:
	if not is_instance_valid(_ramp_prompt_panel):
		_init_ramp_prompt_panel()
	
	_ramp_title_label.text = title
	_ramp_title_label.add_theme_color_override("font_color", title_color)
	_ramp_subtitle_label.text = subtitle
	if _ramp_stylebox:
		_ramp_stylebox.border_color = border_color
	
	if _ramp_prompt_tween and _ramp_prompt_tween.is_valid():
		_ramp_prompt_tween.kill()
	
	_ramp_prompt_panel.visible = true
	_ramp_prompt_panel.modulate.a = 0.0
	_ramp_prompt_panel.scale = Vector2(0.9, 0.9)
	_ramp_prompt_panel.pivot_offset = Vector2(220.0, 35.0)
	
	_ramp_prompt_tween = create_tween()
	_ramp_prompt_tween.set_parallel(true)
	_ramp_prompt_tween.tween_property(_ramp_prompt_panel, "modulate:a", 1.0, 0.18)
	_ramp_prompt_tween.tween_property(_ramp_prompt_panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_ramp_prompt_tween.chain().tween_interval(2.8)
	_ramp_prompt_tween.chain().tween_property(_ramp_prompt_panel, "modulate:a", 0.0, 0.25)
	_ramp_prompt_tween.tween_callback(func():
		if is_instance_valid(_ramp_prompt_panel):
			_ramp_prompt_panel.visible = false
	)

func _hide_ramp_prompt() -> void:
	if not is_instance_valid(_ramp_prompt_panel) or not _ramp_prompt_panel.visible:
		return
	if _ramp_prompt_tween and _ramp_prompt_tween.is_valid():
		_ramp_prompt_tween.kill()
	
	_ramp_prompt_tween = create_tween()
	_ramp_prompt_tween.tween_property(_ramp_prompt_panel, "modulate:a", 0.0, 0.2)
	_ramp_prompt_tween.tween_callback(func():
		if is_instance_valid(_ramp_prompt_panel):
			_ramp_prompt_panel.visible = false
	)

## Binds to BiomeProgressionController for branching encounter cues
func bind_progression_controller(pc: BiomeProgressionController) -> void:
	if not is_instance_valid(pc):
		return
	progression_controller_ref = pc
	if not pc.state_changed.is_connected(_on_progression_state_changed):
		pc.state_changed.connect(_on_progression_state_changed)
	if not pc.ramp_warning_triggered.is_connected(_on_ramp_warning_triggered):
		pc.ramp_warning_triggered.connect(_on_ramp_warning_triggered)
	if not pc.launch_window_entered.is_connected(_on_launch_window_entered):
		pc.launch_window_entered.connect(_on_launch_window_entered)
	if not pc.branch_confirmed.is_connected(_on_branch_confirmed):
		pc.branch_confirmed.connect(_on_branch_confirmed)
	if not pc.route_merge_completed.is_connected(_on_route_merge_completed):
		pc.route_merge_completed.connect(_on_route_merge_completed)
	if not pc.nitro_prompt_triggered.is_connected(_on_nitro_prompt_triggered):
		pc.nitro_prompt_triggered.connect(_on_nitro_prompt_triggered)
	if not pc.launch_zone_entered.is_connected(_on_launch_zone_entered_900m):
		pc.launch_zone_entered.connect(_on_launch_zone_entered_900m)
	if not pc.heaven_portal_entered.is_connected(_on_heaven_portal_entered_900m):
		pc.heaven_portal_entered.connect(_on_heaven_portal_entered_900m)
	if not pc.hell_portal_entered.is_connected(_on_hell_portal_entered_900m):
		pc.hell_portal_entered.connect(_on_hell_portal_entered_900m)
	if not pc.return_portal_entered.is_connected(_on_return_portal_entered_900m):
		pc.return_portal_entered.connect(_on_return_portal_entered_900m)
	if not pc.biome_changed.is_connected(_on_biome_changed_900m):
		pc.biome_changed.connect(_on_biome_changed_900m)
	if not pc.progression_reset.is_connected(_on_progression_reset):
		pc.progression_reset.connect(_on_progression_reset)

func _on_progression_state_changed(_old_state: int, new_state: int, _state_info: Dictionary) -> void:
	if _state_info.get("state_name", "").contains("Launch") or (new_state == WorldCycleSchedule.WorldState.LAUNCH_WINDOW and _is_launch_window_active):
		return
	match new_state:
		WorldCycleSchedule.WorldState.NORMAL_APPROACH:
			_hide_ramp_prompt()
			_is_launch_window_active = false
		WorldCycleSchedule.WorldState.HEAVEN_ENTRY, WorldCycleSchedule.WorldState.HEAVEN_ACTIVE:
			_hide_ramp_prompt()
			_is_launch_window_active = false
		WorldCycleSchedule.WorldState.HELL_ENTRY, WorldCycleSchedule.WorldState.HELL_ACTIVE:
			_hide_ramp_prompt()
			_is_launch_window_active = false
		WorldCycleSchedule.WorldState.NORMAL_MERGE:
			_hide_ramp_prompt()
			_is_launch_window_active = false

func _on_ramp_warning_triggered(_gate_dist_m: float, enc_idx: int) -> void:
	var title: String = "⚠ RAMP AHEAD!"
	var subtitle: String = ""
	if enc_idx == 0 and not _has_seen_first_ramp_tutorial:
		_has_seen_first_ramp_tutorial = true
		subtitle = "USE BOOST AT THE RAMP TO REACH HEAVEN. MISS THE LAUNCH AND YOU'LL DROP INTO HELL."
	else:
		title = "⚠ RAMP AHEAD"
		subtitle = "Prepare for Launch"
	
	_show_ramp_prompt(title, subtitle, Color(1.0, 0.85, 0.25, 0.95), Color(1.0, 0.9, 0.3))

func _on_launch_window_entered(_gate_dist_m: float, _enc_idx: int) -> void:
	var has_nitro: bool = false
	if is_instance_valid(_vehicle_ref) and _vehicle_ref.get("current_nitro") != null:
		has_nitro = float(_vehicle_ref.get("current_nitro")) > 5.0
	elif _target_nitro > 5.0 and not is_instance_valid(_vehicle_ref):
		has_nitro = true
	else:
		has_nitro = _target_nitro > 5.0

	if has_nitro:
		var title := "⚡ BOOST TO REACH HEAVEN! ⚡"
		var subtitle := "Press BOOST / SHIFT now!"
		_is_launch_window_active = true
		_show_ramp_prompt(title, subtitle, Color(0.25, 0.9, 1.0, 0.95), Color(0.4, 0.95, 1.0))
	else:
		var title := "⚠ NITRO EMPTY — LOWER ROUTE"
		var subtitle := "Brace for Hell descent"
		_is_launch_window_active = false
		_show_ramp_prompt(title, subtitle, Color(0.95, 0.45, 0.2, 0.95), Color(1.0, 0.55, 0.25))

func _on_branch_confirmed(realm: int, _enc_idx: int) -> void:
	_hide_ramp_prompt()
	_is_launch_window_active = false
	if nitro_button:
		nitro_button.scale = Vector2.ONE
	if nitro_bar:
		nitro_bar.scale = Vector2.ONE
	
	if realm == WorldCycleSchedule.BiomeType.HEAVEN:
		show_toast("✦ HEAVEN ROUTE ✦", "Celestial Ascent Confirmed", Color(1.0, 0.9, 0.25))
	elif realm == WorldCycleSchedule.BiomeType.HELL:
		show_toast("▼ HELL ROUTE ▼", "Subterranean Descent Confirmed", Color(1.0, 0.4, 0.15))

func _on_route_merge_completed(_enc_idx: int) -> void:
	show_toast("NORMAL LAND", "Endless Journey Continues", Color(0.35, 0.95, 0.45))

func _on_nitro_prompt_triggered(_target_dist_m: float, _cycle_idx: int) -> void:
	var title := "⚡ NITRO TO REACH HEAVEN! ⚡"
	var subtitle := "Activate Nitro at the Ramp to Launch"
	_show_ramp_prompt(title, subtitle, Color(0.25, 0.9, 1.0, 0.95), Color(0.4, 0.95, 1.0))

func _on_heaven_portal_entered_900m(_target_dist_m: float, _cycle_idx: int) -> void:
	var title := "✦ HEAVEN PORTAL AHEAD ✦"
	var subtitle := "Cross the Gateway to Enter the Celestial Realm"
	_show_ramp_prompt(title, subtitle, Color(1.0, 0.9, 0.25, 0.95), Color(1.0, 0.95, 0.4))

func _on_hell_portal_entered_900m(_target_dist_m: float, _cycle_idx: int) -> void:
	var title := "▼ HELL PORTAL AHEAD ▼"
	var subtitle := "Gateway to the Underworld Ahead"
	_show_ramp_prompt(title, subtitle, Color(1.0, 0.45, 0.2, 0.95), Color(1.0, 0.55, 0.25))

func _on_return_portal_entered_900m(_target_dist_m: float, _cycle_idx: int) -> void:
	var title := "✦ RETURN PORTAL AHEAD ✦"
	var subtitle := "Return to the Overworld Ahead"
	_show_ramp_prompt(title, subtitle, Color(0.35, 0.95, 0.45, 0.95), Color(0.5, 1.0, 0.5))

func _on_launch_zone_entered_900m(_target_dist_m: float, _cycle_idx: int) -> void:
	var has_nitro: bool = false
	if is_instance_valid(_vehicle_ref) and _vehicle_ref.get("current_nitro") != null:
		has_nitro = float(_vehicle_ref.get("current_nitro")) > 2.0
	elif _target_nitro > 2.0:
		has_nitro = true

	if has_nitro:
		var title := "⚡ NITRO TO REACH HEAVEN! ⚡"
		var subtitle := "PRESS NITRO / SHIFT NOW!"
		_is_launch_window_active = true
		_show_ramp_prompt(title, subtitle, Color(1.0, 0.9, 0.25, 1.0), Color(1.0, 0.95, 0.3))
	else:
		var title := "⚠ NITRO EMPTY — RECOVERY BOOST"
		var subtitle := "Launch Assist Active!"
		_is_launch_window_active = false
		_show_ramp_prompt(title, subtitle, Color(0.95, 0.6, 0.2, 1.0), Color(1.0, 0.7, 0.3))

func _on_biome_changed_900m(_old_biome: int, new_biome: int, _cycle_idx: int) -> void:
	_hide_ramp_prompt()
	_is_launch_window_active = false
	match new_biome:
		WorldCycleSchedule.BiomeType.NORMAL_LAND:
			show_toast("✦ NORMAL LAND ✦", "Endless Journey Continues", Color(0.35, 0.95, 0.45))
		WorldCycleSchedule.BiomeType.HEAVEN:
			show_toast("✦ HEAVEN ✦", "Celestial Palace", Color(1.0, 0.9, 0.25))
		WorldCycleSchedule.BiomeType.HELL:
			show_toast("▼ HELL ▼", "Underworld Caverns", Color(1.0, 0.4, 0.15))

func _on_progression_reset() -> void:
	_hide_ramp_prompt()
	_is_launch_window_active = false
	if nitro_button:
		nitro_button.scale = Vector2.ONE
		nitro_button.modulate = Color.WHITE
	if nitro_bar:
		nitro_bar.scale = Vector2.ONE
		nitro_bar.modulate = Color.WHITE

# =========================================================================
# ENDLESS WOODEN HUD SKIN
# Opt-in restyle with the Wooden Arcade HUD kit (assets/ui/endless_hud/). Only Game.gd (Endless)
# calls apply_wooden_skin(); a bare HUD.tscn instance (tests, other scenes) keeps its original look.
# Survival is unaffected: its HUD (game_hud.tscn) runs game_hud.gd, not this script.
# Existing nodes are MOVED onto the wooden art and restyled, so every update path and
# unique-name lookup (%DistanceLabel, %FuelBar, %CoinsLabel, ...) keeps working.
# =========================================================================

const WOOD_DIR := "res://assets/ui/endless_hud/"
const WOOD_FONT: FontFile = preload("res://assets/fonts/Kenney_Future.ttf")
const WOOD_WHITE := Color(1.0, 0.98, 0.93)
const WOOD_YELLOW := Color(1.0, 0.84, 0.16)
const WOOD_OUTLINE := Color(0.13, 0.06, 0.02)
## Source-pixel geometry of the kit art.
const WOOD_STATS_SIZE := Vector2(745.0, 321.0)
const WOOD_DIST_RECT := Rect2(288.0, 36.0, 110.0, 54.0)
const WOOD_BEST_RECT := Rect2(404.0, 38.0, 282.0, 50.0)
const WOOD_FUEL_TRACK := Rect2(290.0, 136.0, 291.0, 39.0)
const WOOD_NITRO_TRACK := Rect2(290.0, 225.0, 291.0, 38.0)
const WOOD_FUEL_PILL := Rect2(590.0, 124.0, 92.0, 54.0)
const WOOD_NITRO_PILL := Rect2(588.0, 213.0, 94.0, 55.0)
const WOOD_COIN_SIZE := Vector2(397.0, 177.0)
const WOOD_SPEEDO_SIZE := Vector2(388.0, 385.0)
const WOOD_SPEEDO_HUB := Vector2(195.0, 187.0)
const WOOD_SPEEDO_NEEDLE_LEN := 128.0
const WOOD_SPEEDO_ARC_DEG := 125.0
const WOOD_SPEEDO_MAX_KMH := 220.0

var wooden_skin_applied: bool = false
var _wood_needle_pivot: Node2D = null

func _wood_tex(file_name: String) -> Texture2D:
	return load(WOOD_DIR + file_name + ".png") as Texture2D

func _wood_place(c: Control, ax: float, ay: float, pos: Vector2, sz: Vector2) -> void:
	c.anchor_left = ax
	c.anchor_right = ax
	c.anchor_top = ay
	c.anchor_bottom = ay
	c.offset_left = pos.x
	c.offset_top = pos.y
	c.offset_right = pos.x + sz.x
	c.offset_bottom = pos.y + sz.y

## Moves a node onto a wooden panel at a rect given in the art's source pixels.
func _wood_attach(c: Control, panel: Control, src_rect: Rect2, s: float) -> void:
	c.reparent(panel, false)
	c.visible = true
	c.custom_minimum_size = Vector2.ZERO
	c.size_flags_horizontal = Control.SIZE_FILL
	c.size_flags_vertical = Control.SIZE_FILL
	_wood_place(c, 0.0, 0.0, src_rect.position * s, src_rect.size * s)

func _wood_label(lbl: Label, font_size: int, color: Color, outline: int) -> void:
	lbl.add_theme_font_override("font", WOOD_FONT)
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", WOOD_OUTLINE)
	lbl.add_theme_constant_override("outline_size", outline)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Turns an existing panel into a wooden one: old background/content hidden, art added inside.
func _wood_host(host: Control, tex_name: String, ax: float, ay: float, pos: Vector2, sz: Vector2) -> TextureRect:
	if host is PanelContainer:
		host.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	for child in host.get_children():
		if child is CanvasItem:
			child.visible = false
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.custom_minimum_size = Vector2.ZERO
	_wood_place(host, ax, ay, pos, sz)
	host.pivot_offset = sz * 0.5
	var tr := TextureRect.new()
	tr.name = "Wood" + host.name
	tr.texture = _wood_tex(tex_name)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(tr)
	if not (host is Container):
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return tr

## Public entry point used by the Endless game scene (Game.gd).
func apply_wooden_skin() -> void:
	if wooden_skin_applied:
		return
	wooden_skin_applied = true
	_wood_buttons()
	_wood_stats_panel()
	_wood_coin_panel()
	_wood_speedometer()

func _wood_button(btn: TextureButton, tex_name: String) -> void:
	btn.texture_normal = _wood_tex(tex_name)
	btn.texture_pressed = _wood_tex(tex_name + "_pressed")
	btn.texture_hover = null
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

func _wood_buttons() -> void:
	# Pedals keep a large touch area (taller rect to fit the kit's pedal-with-stem shape).
	if is_instance_valid(brake_pedal):
		_wood_button(brake_pedal, "endless_hud_brake")
		_wood_place(brake_pedal, 0.0, 1.0, Vector2(28.0, -196.0), Vector2(126.0, 176.0))
	if is_instance_valid(gas_pedal):
		_wood_button(gas_pedal, "endless_hud_gas")
		_wood_place(gas_pedal, 1.0, 1.0, Vector2(-154.0, -196.0), Vector2(126.0, 176.0))
	if is_instance_valid(nitro_button):
		_wood_button(nitro_button, "endless_hud_nitro")
		# The kit's nitro button already contains the bottle artwork.
		var icon := nitro_button.get_node_or_null("NitroButtonIcon") as CanvasItem
		if icon:
			icon.visible = false
		_wood_place(nitro_button, 0.0, 1.0, Vector2(172.0, -156.0), Vector2(128.0, 128.0))
	if is_instance_valid(pause_button):
		_wood_button(pause_button, "endless_hud_pause")
		_wood_place(pause_button, 1.0, 0.0, Vector2(-82.0, 8.0), Vector2(70.0, 70.0))

func _wood_stats_panel() -> void:
	var panel_host := get_node_or_null("TopStatsPanel") as Control
	if not is_instance_valid(panel_host):
		return
	var sz := Vector2(372.0, 372.0 * WOOD_STATS_SIZE.y / WOOD_STATS_SIZE.x)
	var s := sz.x / WOOD_STATS_SIZE.x
	var panel := _wood_host(panel_host, "endless_hud_stats_panel", 0.0, 0.0, Vector2(10.0, 8.0), sz)

	if is_instance_valid(distance_label):
		_wood_attach(distance_label, panel, WOOD_DIST_RECT, s)
		_wood_label(distance_label, 17, WOOD_YELLOW, 8)
	if is_instance_valid(best_distance_label):
		_wood_attach(best_distance_label, panel, WOOD_BEST_RECT, s)
		_wood_label(best_distance_label, 16, WOOD_WHITE, 8)

	for pair in [[fuel_bar, WOOD_FUEL_TRACK], [nitro_bar, WOOD_NITRO_TRACK]]:
		var bar: ProgressBar = pair[0]
		if is_instance_valid(bar):
			var track: Rect2 = pair[1]
			_wood_attach(bar, panel, Rect2(track.position + Vector2(2, 2), track.size - Vector2(4, 4)), s)
			bar.show_percentage = false
			bar.add_theme_stylebox_override("background", StyleBoxEmpty.new())
	for st in [_fuel_style_healthy, _fuel_style_warning, _fuel_style_critical]:
		if st:
			st.set_corner_radius_all(6)
	if is_instance_valid(nitro_bar):
		var nitro_fill := StyleBoxFlat.new()
		nitro_fill.bg_color = Color(0.0, 0.85, 1.0)
		nitro_fill.border_width_top = 1
		nitro_fill.border_color = Color(0.6, 0.97, 1.0, 0.8)
		nitro_fill.set_corner_radius_all(6)
		nitro_bar.add_theme_stylebox_override("fill", nitro_fill)

	if is_instance_valid(fuel_percentage_label):
		_wood_attach(fuel_percentage_label, panel, WOOD_FUEL_PILL, s)
		_wood_label(fuel_percentage_label, 16, WOOD_WHITE, 7)
	if is_instance_valid(nitro_percentage_label):
		_wood_attach(nitro_percentage_label, panel, WOOD_NITRO_PILL, s)
		_wood_label(nitro_percentage_label, 16, WOOD_WHITE, 7)
	# LOW FUEL warning flashes centred on the fuel bar (the kit has no separate slot for it).
	if is_instance_valid(low_fuel_indicator):
		_wood_attach(low_fuel_indicator, panel, WOOD_FUEL_TRACK, s)
		_wood_label(low_fuel_indicator, 14, Color(1.0, 0.3, 0.22), 7)
		low_fuel_indicator.visible = _is_low_fuel
		low_fuel_indicator.pivot_offset = low_fuel_indicator.size * 0.5

func _wood_coin_panel() -> void:
	if not is_instance_valid(coins_panel) or not is_instance_valid(coins_label):
		return
	var sz := Vector2(176.0, 176.0 * WOOD_COIN_SIZE.y / WOOD_COIN_SIZE.x)
	var s := sz.x / WOOD_COIN_SIZE.x
	# Left of the pause button in the top-right corner.
	var panel := _wood_host(coins_panel, "endless_hud_coin_panel", 1.0, 0.0, Vector2(-90.0 - sz.x, 4.0 + (70.0 - sz.y) * 0.5), sz)
	_wood_attach(coins_label, panel, Rect2(178.0, 30.0, 190.0, 110.0), s)
	_wood_label(coins_label, 26, WOOD_YELLOW, 9)

func _wood_speedometer() -> void:
	var gauge := get_node_or_null("SpeedometerGauge") as Control
	if not is_instance_valid(gauge):
		return
	var sz := Vector2(156.0, 156.0 * WOOD_SPEEDO_SIZE.y / WOOD_SPEEDO_SIZE.x)
	var s := sz.x / WOOD_SPEEDO_SIZE.x
	# Bottom-right, just left of the gas pedal (gas occupies right -154..-28).
	var dial := _wood_host(gauge, "endless_hud_speedometer", 1.0, 1.0, Vector2(-166.0 - sz.x, -16.0 - sz.y), sz)

	var pivot := Node2D.new()
	pivot.name = "WoodNeedlePivot"
	pivot.position = WOOD_SPEEDO_HUB * s
	dial.add_child(pivot)
	var length := WOOD_SPEEDO_NEEDLE_LEN * s
	var outline := Polygon2D.new()
	outline.color = WOOD_OUTLINE
	outline.polygon = PackedVector2Array([Vector2(-4.4, 4.0), Vector2(4.4, 4.0), Vector2(2.0, -length - 2.0), Vector2(-2.0, -length - 2.0)])
	pivot.add_child(outline)
	var body := Polygon2D.new()
	body.color = Color(0.93, 0.12, 0.08)
	body.polygon = PackedVector2Array([Vector2(-3.0, 2.5), Vector2(3.0, 2.5), Vector2(1.0, -length), Vector2(-1.0, -length)])
	pivot.add_child(body)
	var shine := Line2D.new()
	shine.width = 1.0
	shine.default_color = Color(1.0, 0.95, 0.9, 0.9)
	shine.points = PackedVector2Array([Vector2(-1.1, -4.0), Vector2(-0.5, -length + 3.0)])
	pivot.add_child(shine)
	pivot.rotation = deg_to_rad(-WOOD_SPEEDO_ARC_DEG)
	_wood_needle_pivot = pivot

	var hub := TextureRect.new()
	hub.name = "WoodNeedleHub"
	hub.texture = _wood_tex("endless_hud_speedo_hub")
	hub.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dial.add_child(hub)
	var hub_size := Vector2(51.0, 51.0) * s
	_wood_place(hub, 0.0, 0.0, WOOD_SPEEDO_HUB * s - hub_size * 0.5, hub_size)

	if is_instance_valid(speed_digital_label):
		_wood_attach(speed_digital_label, dial, Rect2(WOOD_SPEEDO_HUB.x - 60.0, 228.0, 120.0, 56.0), s)
		_wood_label(speed_digital_label, 19, WOOD_WHITE, 8)

func _update_wooden_needle(delta: float) -> void:
	if not is_instance_valid(_wood_needle_pivot) or not is_instance_valid(_vehicle_ref):
		return
	var speed_kmh: float = 0.0
	if _vehicle_ref.has_method("get_speed_kmh"):
		speed_kmh = maxf(0.0, _vehicle_ref.get_speed_kmh())
	var ratio: float = clampf(speed_kmh / WOOD_SPEEDO_MAX_KMH, 0.0, 1.0)
	var target := deg_to_rad(lerpf(-WOOD_SPEEDO_ARC_DEG, WOOD_SPEEDO_ARC_DEG, ratio))
	_wood_needle_pivot.rotation = lerp_angle(_wood_needle_pivot.rotation, target, clampf(delta * 14.0, 0.0, 1.0))
