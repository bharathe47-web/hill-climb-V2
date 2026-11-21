class_name GameHUD
extends Control

## GameHUD: Unified Reusable Shared HUD for Hill Climb 2D.
## Supports Endless Map, Reach Your Destiny (Indian Roads), and Survival modes.
## Provides responsive mobile controls (Gas, Brake, Nitro, Pause), real-time gauges
## (Speedometer, RPM, Fuel, Nitro), stunt toasts, and mode-specific display panels.

enum HUDMode {
	ENDLESS,
	INDIAN_ROADS,
	SURVIVAL
}

const HEART_FULL_TEX = preload("res://assets/ui/hud/hearts/hud_heart_full.png")
const HEART_EMPTY_TEX = preload("res://assets/ui/hud/hearts/hud_heart_empty.png")

@export var current_mode: HUDMode = HUDMode.ENDLESS

# --- Shared Top & Telemetry References ---
@onready var top_stats_panel: PanelContainer = get_node_or_null("%TopStatsPanel")
@onready var distance_label: Label = get_node_or_null("%DistanceLabel")
@onready var best_distance_label: Label = get_node_or_null("%BestDistanceLabel")
@onready var fuel_section: Control = get_node_or_null("%FuelSection")
@onready var fuel_bar: ProgressBar = get_node_or_null("%FuelBar")
@onready var fuel_percentage_label: Label = get_node_or_null("%FuelPercentageLabel")
@onready var low_fuel_indicator: Label = get_node_or_null("%LowFuelIndicator")
@onready var nitro_section: Control = get_node_or_null("%NitroSection")
@onready var nitro_bar: ProgressBar = get_node_or_null("%NitroBar")
@onready var nitro_percentage_label: Label = get_node_or_null("%NitroPercentageLabel")

@onready var coins_panel: PanelContainer = get_node_or_null("%CoinsPanel")
@onready var coins_label: Label = get_node_or_null("%CoinsLabel")

@onready var _rpm_needle: Sprite2D = get_node_or_null("%RPMNeedle")
@onready var speed_needle: Sprite2D = get_node_or_null("%SpeedNeedle")
@onready var speed_digital_label: Label = get_node_or_null("%SpeedDigitalLabel")
@onready var gas_pedal: TextureButton = get_node_or_null("%GasPedal")
@onready var brake_pedal: TextureButton = get_node_or_null("%BrakePedal")
@onready var nitro_button: TextureButton = get_node_or_null("%NitroButton")
@onready var nitro_button_label: Label = get_node_or_null("%NitroButtonLabel")
@onready var pause_button: TextureButton = get_node_or_null("%PauseButton")

@onready var message_banner: PanelContainer = get_node_or_null("%MessageBanner")
@onready var message_title_label: Label = get_node_or_null("%MessageTitleLabel")
@onready var message_label: Label = get_node_or_null("%MessageLabel")
@onready var retry_hint_label: Label = get_node_or_null("%RetryHintLabel")
@onready var pause_banner: PanelContainer = get_node_or_null("%PauseBanner")

# --- Mode-Specific Display References ---
# Indian Roads
@onready var indian_roads_panel: PanelContainer = get_node_or_null("%IndianRoadsPanel")
@onready var destination_label: Label = get_node_or_null("%DestinationLabel")
@onready var checkpoint_label: Label = get_node_or_null("%CheckpointLabel")
@onready var checkpoint_bar: ProgressBar = get_node_or_null("%CheckpointBar")
@onready var checkpoint_pct_label: Label = get_node_or_null("%CheckpointPctLabel")

# Survival
@onready var survival_panel: PanelContainer = get_node_or_null("%SurvivalPanel")
@onready var heart_container: HBoxContainer = get_node_or_null("%HeartContainer")
@onready var survival_time_label: Label = get_node_or_null("%SurvivalTimeLabel")
@onready var survival_dist_label: Label = get_node_or_null("%SurvivalDistLabel")

# --- Bindings & Internal State ---
var game_manager_ref: Node = null
var _vehicle_ref: Node = null
var _survival_controller_ref: Node = null
var _route_controller_ref: Node = null

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

func _ready() -> void:
	_init_fuel_styles()
	_init_toast_panel()
	_setup_nitro_ticks()
	
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

	_apply_mode_layout()
	call_deferred("_auto_discover_bindings")

func _exit_tree() -> void:
	unbind_game_manager()
	unbind_vehicle()
	unbind_survival_controller()
	unbind_route_controller()

func _auto_discover_bindings() -> void:
	if not is_instance_valid(game_manager_ref):
		var tree_root := get_tree().root
		if tree_root:
			var gm = tree_root.find_child("GameManager", true, false)
			if is_instance_valid(gm):
				bind_game_manager(gm)
			var veh = tree_root.find_child("Vehicle", true, false)
			if is_instance_valid(veh) and veh.has_method("refuel"):
				bind_vehicle(veh)
			var surv = tree_root.find_child("Survival", true, false)
			if is_instance_valid(surv) and surv.has_signal("lives_changed"):
				bind_survival_controller(surv)

func _init_fuel_styles() -> void:
	_fuel_style_healthy = StyleBoxFlat.new()
	_fuel_style_healthy.bg_color = Color(1.0, 0.60, 0.10, 1.0) # Garage warm orange
	_fuel_style_healthy.border_width_top = 1
	_fuel_style_healthy.border_color = Color(1.0, 0.80, 0.30, 0.8)
	_fuel_style_healthy.set_corner_radius_all(3)
	
	_fuel_style_warning = StyleBoxFlat.new()
	_fuel_style_warning.bg_color = Color(0.98, 0.72, 0.16, 1.0)
	_fuel_style_warning.border_width_top = 1
	_fuel_style_warning.border_color = Color(1.0, 0.88, 0.45, 0.8)
	_fuel_style_warning.set_corner_radius_all(3)
	
	_fuel_style_critical = StyleBoxFlat.new()
	_fuel_style_critical.bg_color = Color(0.95, 0.22, 0.18, 1.0)
	_fuel_style_critical.border_width_top = 1
	_fuel_style_critical.border_color = Color(1.0, 0.55, 0.5, 0.8)
	_fuel_style_critical.set_corner_radius_all(3)

func _setup_nitro_ticks() -> void:
	if not is_instance_valid(nitro_bar):
		return
	var existing = nitro_bar.get_node_or_null("NitroTickOverlay")
	if not existing:
		var overlay := Control.new()
		overlay.name = "NitroTickOverlay"
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		nitro_bar.add_child(overlay)
		overlay.draw.connect(func():
			var w: float = overlay.size.x
			var h: float = overlay.size.y
			var tick_dark := Color(0.0, 0.0, 0.0, 0.85)
			var tick_light := Color(1.0, 1.0, 1.0, 0.70)
			for fraction in [0.25, 0.50, 0.75]:
				var x: float = roundf(w * fraction)
				overlay.draw_line(Vector2(x - 0.5, 0.0), Vector2(x - 0.5, h), tick_dark, 1.5)
				overlay.draw_line(Vector2(x + 0.5, 0.0), Vector2(x + 0.5, h), tick_light, 1.0)
		)
		if not nitro_bar.resized.is_connected(overlay.queue_redraw):
			nitro_bar.resized.connect(overlay.queue_redraw)

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

# =========================================================================
# MODE SWITCHING & CONFIGURATION
# =========================================================================

func set_hud_mode(mode: HUDMode) -> void:
	current_mode = mode
	_apply_mode_layout()

func set_mode_by_name(mode_name: String) -> void:
	match mode_name.to_lower():
		"endless", "endless_map":
			set_hud_mode(HUDMode.ENDLESS)
		"indian_roads", "reach_your_destiny", "roads":
			set_hud_mode(HUDMode.INDIAN_ROADS)
		"survival":
			set_hud_mode(HUDMode.SURVIVAL)
		_:
			set_hud_mode(HUDMode.ENDLESS)

func _apply_mode_layout() -> void:
	match current_mode:
		HUDMode.ENDLESS:
			if is_instance_valid(top_stats_panel):
				top_stats_panel.visible = true
			if is_instance_valid(fuel_section):
				fuel_section.visible = true
			if is_instance_valid(coins_panel):
				coins_panel.visible = true
			if is_instance_valid(indian_roads_panel):
				indian_roads_panel.visible = false
			if is_instance_valid(survival_panel):
				survival_panel.visible = false
				
		HUDMode.INDIAN_ROADS:
			if is_instance_valid(top_stats_panel):
				top_stats_panel.visible = true
			if is_instance_valid(fuel_section):
				fuel_section.visible = true
			if is_instance_valid(coins_panel):
				coins_panel.visible = true
			if is_instance_valid(indian_roads_panel):
				indian_roads_panel.visible = true
			if is_instance_valid(survival_panel):
				survival_panel.visible = false
				
		HUDMode.SURVIVAL:
			if is_instance_valid(top_stats_panel):
				top_stats_panel.visible = false
			if is_instance_valid(coins_panel):
				coins_panel.visible = false
			if is_instance_valid(indian_roads_panel):
				indian_roads_panel.visible = false
			if is_instance_valid(survival_panel):
				survival_panel.visible = true

# =========================================================================
# MODE-SPECIFIC PUBLIC APIS
# =========================================================================

## Indian Roads: Update checkpoint and destination information
func set_indian_roads_progress(current_checkpoint: int, total_checkpoints: int, destination_name: String = "") -> void:
	if is_instance_valid(checkpoint_label):
		checkpoint_label.text = "CHECKPOINT %d / %d" % [current_checkpoint, total_checkpoints]
	if is_instance_valid(checkpoint_bar):
		checkpoint_bar.max_value = float(maxi(1, total_checkpoints))
		checkpoint_bar.value = float(current_checkpoint)
	if is_instance_valid(checkpoint_pct_label):
		var pct: float = (float(current_checkpoint) / float(maxi(1, total_checkpoints))) * 100.0
		checkpoint_pct_label.text = "%d%%" % int(pct)
	if is_instance_valid(destination_label) and destination_name != "":
		destination_label.text = "DESTINATION: %s" % destination_name.to_upper()

## Survival: Update remaining lives (heart indicators)
func set_survival_lives(current_l: int, max_l: int = 3) -> void:
	if not is_instance_valid(heart_container):
		return
	var hearts := heart_container.get_children()
	for i in range(hearts.size()):
		var heart_rect = hearts[i] as TextureRect
		if is_instance_valid(heart_rect):
			if i < current_l:
				heart_rect.texture = HEART_FULL_TEX
			else:
				heart_rect.texture = HEART_EMPTY_TEX

## Survival: Update run metrics (time & distance)
func set_survival_stats(time_val: float, distance_val: float) -> void:
	if is_instance_valid(survival_time_label):
		survival_time_label.text = "TIME: %.1fs" % time_val
	if is_instance_valid(survival_dist_label):
		survival_dist_label.text = "DIST: %dm" % int(distance_val)

# =========================================================================
# MOBILE TOUCH CONTROLS
# =========================================================================

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

# =========================================================================
# SAFE BINDING & UNBINDING LIFECYCLE
# =========================================================================

## Binds to GameManager signals
func bind_game_manager(gm: Node) -> void:
	if is_instance_valid(game_manager_ref) and game_manager_ref != gm:
		unbind_game_manager()
	
	game_manager_ref = gm
	if not is_instance_valid(gm):
		return
	
	if gm.has_signal("distance_updated") and not gm.distance_updated.is_connected(_on_distance_updated):
		gm.distance_updated.connect(_on_distance_updated)
	if gm.has_signal("fuel_updated") and not gm.fuel_updated.is_connected(_on_fuel_updated):
		gm.fuel_updated.connect(_on_fuel_updated)
	if gm.has_signal("run_finished") and not gm.run_finished.is_connected(_on_run_finished):
		gm.run_finished.connect(_on_run_finished)
	if gm.has_signal("run_started") and not gm.run_started.is_connected(_on_run_started):
		gm.run_started.connect(_on_run_started)
	if gm.has_signal("coins_updated") and not gm.coins_updated.is_connected(_on_coins_updated):
		gm.coins_updated.connect(_on_coins_updated)
	if gm.has_signal("run_paused") and not gm.run_paused.is_connected(_on_run_paused):
		gm.run_paused.connect(_on_run_paused)
		
	_update_best_distance()
	if "coins_collected" in gm:
		_on_coins_updated(gm.coins_collected)
	if "current_distance" in gm:
		_on_distance_updated(gm.current_distance)

## Unbinds from GameManager
func unbind_game_manager() -> void:
	if is_instance_valid(game_manager_ref):
		if game_manager_ref.has_signal("distance_updated") and game_manager_ref.distance_updated.is_connected(_on_distance_updated):
			game_manager_ref.distance_updated.disconnect(_on_distance_updated)
		if game_manager_ref.has_signal("fuel_updated") and game_manager_ref.fuel_updated.is_connected(_on_fuel_updated):
			game_manager_ref.fuel_updated.disconnect(_on_fuel_updated)
		if game_manager_ref.has_signal("run_finished") and game_manager_ref.run_finished.is_connected(_on_run_finished):
			game_manager_ref.run_finished.disconnect(_on_run_finished)
		if game_manager_ref.has_signal("run_started") and game_manager_ref.run_started.is_connected(_on_run_started):
			game_manager_ref.run_started.disconnect(_on_run_started)
		if game_manager_ref.has_signal("coins_updated") and game_manager_ref.coins_updated.is_connected(_on_coins_updated):
			game_manager_ref.coins_updated.disconnect(_on_coins_updated)
		if game_manager_ref.has_signal("run_paused") and game_manager_ref.run_paused.is_connected(_on_run_paused):
			game_manager_ref.run_paused.disconnect(_on_run_paused)
	game_manager_ref = null

## Binds to VehicleController signals
func bind_vehicle(vehicle: Node) -> void:
	if is_instance_valid(_vehicle_ref) and _vehicle_ref != vehicle:
		unbind_vehicle()

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
	if vehicle.has_signal("monster_surge_state_changed") and not vehicle.monster_surge_state_changed.is_connected(_on_monster_surge_state_changed):
		vehicle.monster_surge_state_changed.connect(_on_monster_surge_state_changed)
	_ensure_monster_surge_tag()
	
	if "current_nitro" in vehicle and "max_nitro" in vehicle:
		_on_nitro_updated(vehicle.current_nitro, vehicle.max_nitro)
	if "current_fuel" in vehicle and "max_fuel" in vehicle:
		_on_fuel_updated(vehicle.current_fuel, vehicle.max_fuel)

## Unbinds from VehicleController
func unbind_vehicle() -> void:
	if is_instance_valid(_vehicle_ref):
		if _vehicle_ref.has_signal("fuel_changed") and _vehicle_ref.fuel_changed.is_connected(_on_fuel_updated):
			_vehicle_ref.fuel_changed.disconnect(_on_fuel_updated)
		if _vehicle_ref.has_signal("crashed") and _vehicle_ref.crashed.is_connected(_on_vehicle_crashed):
			_vehicle_ref.crashed.disconnect(_on_vehicle_crashed)
		if _vehicle_ref.has_signal("trick_performed") and _vehicle_ref.trick_performed.is_connected(_on_trick_performed):
			_vehicle_ref.trick_performed.disconnect(_on_trick_performed)
		if _vehicle_ref.has_signal("airtime_landed") and _vehicle_ref.airtime_landed.is_connected(_on_airtime_landed):
			_vehicle_ref.airtime_landed.disconnect(_on_airtime_landed)
		if _vehicle_ref.has_signal("clean_landed") and _vehicle_ref.clean_landed.is_connected(_on_clean_landed):
			_vehicle_ref.clean_landed.disconnect(_on_clean_landed)
		if _vehicle_ref.has_signal("nitro_changed") and _vehicle_ref.nitro_changed.is_connected(_on_nitro_updated):
			_vehicle_ref.nitro_changed.disconnect(_on_nitro_updated)
		if _vehicle_ref.has_signal("nitro_state_changed") and _vehicle_ref.nitro_state_changed.is_connected(_on_nitro_state_changed):
			_vehicle_ref.nitro_state_changed.disconnect(_on_nitro_state_changed)
		if _vehicle_ref.has_signal("monster_surge_state_changed") and _vehicle_ref.monster_surge_state_changed.is_connected(_on_monster_surge_state_changed):
			_vehicle_ref.monster_surge_state_changed.disconnect(_on_monster_surge_state_changed)
		if _vehicle_ref.has_signal("pothole_assist_hint") and _vehicle_ref.pothole_assist_hint.is_connected(_on_pothole_assist_hint):
			_vehicle_ref.pothole_assist_hint.disconnect(_on_pothole_assist_hint)
	_vehicle_ref = null

## Binds to SurvivalController
func bind_survival_controller(controller: Node) -> void:
	if is_instance_valid(_survival_controller_ref) and _survival_controller_ref != controller:
		unbind_survival_controller()

	if not is_instance_valid(controller):
		return
	_survival_controller_ref = controller
	set_hud_mode(HUDMode.SURVIVAL)
	
	if controller.has_signal("lives_changed") and not controller.lives_changed.is_connected(_on_survival_lives_changed):
		controller.lives_changed.connect(_on_survival_lives_changed)
	if controller.has_signal("run_started") and not controller.run_started.is_connected(_on_survival_run_started):
		controller.run_started.connect(_on_survival_run_started)
	if controller.has_signal("run_finished") and not controller.run_finished.is_connected(_on_survival_run_finished):
		controller.run_finished.connect(_on_survival_run_finished)
		
	if "current_lives" in controller and "max_lives" in controller:
		set_survival_lives(controller.current_lives, controller.max_lives)
	if "survival_time" in controller and "survival_distance" in controller:
		set_survival_stats(controller.survival_time, controller.survival_distance)

## Unbinds from SurvivalController
func unbind_survival_controller() -> void:
	if is_instance_valid(_survival_controller_ref):
		if _survival_controller_ref.has_signal("lives_changed") and _survival_controller_ref.lives_changed.is_connected(_on_survival_lives_changed):
			_survival_controller_ref.lives_changed.disconnect(_on_survival_lives_changed)
		if _survival_controller_ref.has_signal("run_started") and _survival_controller_ref.run_started.is_connected(_on_survival_run_started):
			_survival_controller_ref.run_started.disconnect(_on_survival_run_started)
		if _survival_controller_ref.has_signal("run_finished") and _survival_controller_ref.run_finished.is_connected(_on_survival_run_finished):
			_survival_controller_ref.run_finished.disconnect(_on_survival_run_finished)
	_survival_controller_ref = null

## Binds to Joel's RouteController (Indian Roads)
func bind_route_controller(controller: Node) -> void:
	if is_instance_valid(_route_controller_ref) and _route_controller_ref != controller:
		unbind_route_controller()

	if not is_instance_valid(controller):
		return
	_route_controller_ref = controller
	set_hud_mode(HUDMode.INDIAN_ROADS)
	
	if controller.has_signal("checkpoint_reached") and not controller.checkpoint_reached.is_connected(_on_checkpoint_reached):
		controller.checkpoint_reached.connect(_on_checkpoint_reached)
	if controller.has_signal("destination_reached") and not controller.destination_reached.is_connected(_on_destination_reached):
		controller.destination_reached.connect(_on_destination_reached)

## Unbinds from RouteController
func unbind_route_controller() -> void:
	if is_instance_valid(_route_controller_ref):
		if _route_controller_ref.has_signal("checkpoint_reached") and _route_controller_ref.checkpoint_reached.is_connected(_on_checkpoint_reached):
			_route_controller_ref.checkpoint_reached.disconnect(_on_checkpoint_reached)
		if _route_controller_ref.has_signal("destination_reached") and _route_controller_ref.destination_reached.is_connected(_on_destination_reached):
			_route_controller_ref.destination_reached.disconnect(_on_destination_reached)
	_route_controller_ref = null

# =========================================================================
# SIGNAL CALLBACKS & STATS UPDATES
# =========================================================================

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

var monster_surge_tag: Label = null

func _ensure_monster_surge_tag() -> void:
	if is_instance_valid(monster_surge_tag):
		return
	monster_surge_tag = get_node_or_null("%MonsterSurgeTag")
	if not monster_surge_tag:
		var tag := Label.new()
		tag.name = "MonsterSurgeTag"
		tag.unique_name_in_owner = true
		tag.text = "MONSTER SURGE"
		tag.visible = false
		tag.add_theme_font_size_override("font_size", 10)
		tag.add_theme_color_override("font_color", Color(1.0, 0.65, 0.1))
		tag.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.0, 0.9))
		tag.add_theme_constant_override("outline_size", 3)
		var nitro_sec = get_node_or_null("%NitroSection")
		if not nitro_sec:
			nitro_sec = get_node_or_null("TopStatsPanel/Margin/VBox/NitroSection")
		if nitro_sec:
			var hdr = nitro_sec.get_node_or_null("NitroHeader")
			if hdr:
				hdr.add_child(tag)
			else:
				nitro_sec.add_child(tag)
		else:
			add_child(tag)
		monster_surge_tag = tag

func _on_monster_surge_state_changed(is_surging: bool) -> void:
	_ensure_monster_surge_tag()
	if is_instance_valid(monster_surge_tag):
		monster_surge_tag.visible = is_surging

func _on_pothole_assist_hint(should_hint: bool) -> void:
	_pothole_pulse_active = should_hint
	if not should_hint and nitro_button:
		nitro_button.modulate = Color.WHITE
		nitro_button.scale = Vector2.ONE

func _on_coins_updated(count: int) -> void:
	if coins_label:
		coins_label.text = str(count)
		# Pop animation on coin count increase
		if count > _last_coins_count and is_instance_valid(coins_panel):
			var tw := create_tween()
			tw.tween_property(coins_panel, "scale", Vector2(1.1, 1.1), 0.1)
			tw.tween_property(coins_panel, "scale", Vector2.ONE, 0.15)
	_last_coins_count = count

func _on_run_paused(is_paused: bool) -> void:
	if pause_banner:
		pause_banner.visible = is_paused
	if is_paused:
		Input.action_release("accelerate")
		Input.action_release("brake_reverse")
		Input.action_release("nitro")
		Input.action_release("tilt_left")
		Input.action_release("tilt_right")
		if is_instance_valid(_vehicle_ref) and _vehicle_ref.has_method("set_nitro_active"):
			_vehicle_ref.set_nitro_active(false)

func _on_run_started() -> void:
	_is_low_fuel = false
	_pothole_pulse_active = false
	if nitro_button:
		nitro_button.scale = Vector2.ONE
		nitro_button.modulate = Color.WHITE
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

# Survival Controller Signal Callbacks
func _on_survival_lives_changed(curr_l: int, max_l: int) -> void:
	set_survival_lives(curr_l, max_l)

func _on_survival_run_started() -> void:
	set_survival_lives(3, 3)
	set_survival_stats(0.0, 0.0)

func _on_survival_run_finished(time_val: float, dist_val: float, reason: String) -> void:
	set_survival_stats(time_val, dist_val)
	show_toast("SURVIVAL ENDED", "%s (%.1fs)" % [reason, time_val], Color(0.95, 0.35, 0.35))

# Route Controller Signal Callbacks (Indian Roads)
func _on_checkpoint_reached(cp_index: int, total_cps: int) -> void:
	set_indian_roads_progress(cp_index, total_cps)
	show_toast("🏁 CHECKPOINT %d PASSED!" % cp_index, "Keep Going!", Color(0.2, 0.85, 1.0))

func _on_destination_reached(dest_name: String) -> void:
	show_toast("🏆 DESTINATION REACHED!", dest_name.to_upper(), Color(1.0, 0.85, 0.2))

# =========================================================================
# TOAST NOTIFICATIONS (STUNTS & MILESTONES)
# =========================================================================

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
