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

## Hearts are only shown in Survival, so they use the wooden Survival HUD heart art.
const HEART_FULL_TEX = preload("res://assets/ui/survival_hud/survival_hud_heart_full.png")
const HEART_EMPTY_TEX = preload("res://assets/ui/survival_hud/survival_hud_heart_empty.png")

# --- Survival wooden HUD skin (applied ONLY in HUDMode.SURVIVAL; Endless uses HUD.tscn + HUDController.gd) ---
const SKIN_DIR := "res://assets/ui/survival_hud/"
const SKIN_FONT: FontFile = preload("res://assets/fonts/Kenney_Future.ttf")
const SKIN_YELLOW := Color(1.0, 0.84, 0.16)
const SKIN_WHITE := Color(1.0, 0.98, 0.93)
const SKIN_OUTLINE := Color(0.17, 0.08, 0.02)
## Speedometer art: hub centre and needle length in source pixels (247x215 dial), arc of the tick marks.
const SKIN_SPEEDO_HUB := Vector2(141.0, 99.0)
const SKIN_SPEEDO_NEEDLE_LEN := 74.0
const SKIN_SPEEDO_ARC_DEG := 130.0
const SKIN_SPEEDO_MAX_KMH := 220.0
## Fuel bar art: empty track rectangle in source pixels (475x143 panel).
const SKIN_FUEL_TRACK := Rect2(54.0, 68.0, 370.0, 28.0)

var _survival_skin_applied: bool = false
var _skin_nodes: Dictionary = {}
var _skin_needle_pivot: Node2D = null

@export var current_mode: HUDMode = HUDMode.ENDLESS

# --- Shared Top & Telemetry References ---
@onready var top_stats_panel: PanelContainer = get_node_or_null("%TopStatsPanel")
@onready var distance_label: Label = get_node_or_null("%DistanceLabel")
@onready var best_distance_label: Label = get_node_or_null("%BestDistanceLabel")
@onready var fuel_section: VBoxContainer = get_node_or_null("%FuelSection")
@onready var fuel_bar: ProgressBar = get_node_or_null("%FuelBar")
@onready var fuel_percentage_label: Label = get_node_or_null("%FuelPercentageLabel")
@onready var low_fuel_indicator: Label = get_node_or_null("%LowFuelIndicator")
@onready var nitro_section: VBoxContainer = get_node_or_null("%NitroSection")
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
	process_mode = Node.PROCESS_MODE_ALWAYS
	_init_fuel_styles()
	_init_toast_panel()
	
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
	_update_survival_skin_needle(delta)

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
			# Compact collectibles HUD: keep only the fuel gauge of the top-left panel and
			# show the coin counter (moved below the MENU button) for Survival collectibles.
			if is_instance_valid(top_stats_panel):
				top_stats_panel.visible = true
				for row in top_stats_panel.get_node("Margin/VBox").get_children():
					row.visible = (row == fuel_section)
				top_stats_panel.offset_bottom = top_stats_panel.offset_top
			if is_instance_valid(coins_panel):
				coins_panel.visible = true
				coins_panel.offset_top = 66.0
				coins_panel.offset_bottom = 118.0
			if is_instance_valid(indian_roads_panel):
				indian_roads_panel.visible = false
			if is_instance_valid(survival_panel):
				survival_panel.visible = true
			if is_instance_valid(nitro_button):
				nitro_button.visible = false
			if is_instance_valid(nitro_section):
				nitro_section.visible = false
			_apply_survival_skin()

# =========================================================================
# SURVIVAL WOODEN HUD SKIN
# Restyles the Survival HUD with the wooden art in assets/ui/survival_hud/.
# Existing nodes (FuelBar, CoinsLabel, HeartContainer, time/dist labels, speed label,
# pedals, pause) are MOVED into the new panels and restyled, so every update path,
# unique-name lookup (%CoinsLabel, %HeartContainer...) and test keeps working.
# =========================================================================

func _skin_tex(file_name: String) -> Texture2D:
	return load(SKIN_DIR + file_name + ".png") as Texture2D

## Anchors a control to (ax, ay) of the HUD and sets its rect relative to that anchor.
func _skin_place(c: Control, ax: float, ay: float, pos: Vector2, sz: Vector2) -> void:
	c.anchor_left = ax
	c.anchor_right = ax
	c.anchor_top = ay
	c.anchor_bottom = ay
	c.offset_left = pos.x
	c.offset_top = pos.y
	c.offset_right = pos.x + sz.x
	c.offset_bottom = pos.y + sz.y

## Places a control at a fixed rect inside a (non-container) parent.
func _skin_rect(c: Control, pos: Vector2, sz: Vector2) -> void:
	c.custom_minimum_size = Vector2.ZERO
	_skin_place(c, 0.0, 0.0, pos, sz)

func _skin_label(lbl: Label, font_size: int, color: Color, outline: int) -> void:
	lbl.add_theme_font_override("font", SKIN_FONT)
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_outline_color", SKIN_OUTLINE)
	lbl.add_theme_constant_override("outline_size", outline)
	lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE

## Turns an existing HUD panel (host) into a wooden panel: its old background and old content are
## hidden, the wooden art is added inside it, and the host is moved/resized to the art's rect.
## The host stays the real, visible panel (SurvivalPanel, CoinsPanel, ...), it just looks wooden now.
func _skin_panel(key: String, tex_name: String, host: Control, ax: float, ay: float, pos: Vector2, sz: Vector2) -> TextureRect:
	if host is PanelContainer:
		host.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	for child in host.get_children():
		if child is CanvasItem:
			child.visible = false
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.custom_minimum_size = Vector2.ZERO
	var tr := TextureRect.new()
	tr.name = key
	tr.texture = _skin_tex(tex_name)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(tr)
	if not (host is Container):
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_skin_nodes[host] = [ax, ay, pos, sz]
	_skin_layout_host(host)
	return tr

func _skin_layout_host(host: Control) -> void:
	var p: Array = _skin_nodes[host]
	_skin_place(host, p[0], p[1], p[2], p[3])
	host.pivot_offset = p[3] * 0.5
	host.visible = true

func _apply_survival_skin() -> void:
	if current_mode != HUDMode.SURVIVAL:
		return
	if not _survival_skin_applied:
		_survival_skin_applied = true
		_skin_buttons()
		_skin_fuel_panel()
		_skin_stats_panel()
		_skin_coin_panel()
		_skin_speedometer()
	# _apply_mode_layout() re-positions the original panels on every pass: restore the wooden layout.
	for host in _skin_nodes.keys():
		if is_instance_valid(host):
			_skin_layout_host(host)

func _skin_buttons() -> void:
	# Pedals keep their 140x140 touch areas and keep-aspect stretch; only the artwork changes.
	if is_instance_valid(brake_pedal):
		brake_pedal.texture_normal = _skin_tex("survival_hud_brake")
		brake_pedal.texture_pressed = _skin_tex("survival_hud_brake_pressed")
		brake_pedal.texture_hover = null
	if is_instance_valid(gas_pedal):
		gas_pedal.texture_normal = _skin_tex("survival_hud_gas")
		gas_pedal.texture_pressed = _skin_tex("survival_hud_gas_pressed")
		gas_pedal.texture_hover = null
	if is_instance_valid(pause_button):
		pause_button.texture_normal = _skin_tex("survival_hud_pause")
		pause_button.texture_pressed = _skin_tex("survival_hud_pause_pressed")
		pause_button.texture_hover = null
		pause_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		_skin_place(pause_button, 1.0, 0.0, Vector2(-80.0, 8.0), Vector2(68.0, 62.0))

func _skin_fuel_panel() -> void:
	if not is_instance_valid(top_stats_panel) or not is_instance_valid(fuel_bar):
		return
	var src_size := Vector2(475.0, 143.0)
	var sz := Vector2(330.0, 330.0 * src_size.y / src_size.x)
	var s := sz.x / src_size.x
	var panel := _skin_panel("SurvivalFuelPanel", "survival_hud_fuel_panel", top_stats_panel, 0.0, 0.0, Vector2(10.0, 8.0), sz)

	# Move the whole FuelSection (header row + bar) onto the wooden panel. The header row sits
	# where the art had "FUEL ... 100%", the bar fills the art's empty track exactly.
	if is_instance_valid(fuel_section):
		fuel_section.reparent(panel, false)
		fuel_section.visible = true
		fuel_section.add_theme_constant_override("separation", maxi(1, int(2.0 * s)))
		var header_h := (SKIN_FUEL_TRACK.position.y - 2.0 - 32.0) * s
		_skin_rect(fuel_section, Vector2(SKIN_FUEL_TRACK.position.x, 32.0) * s,
			Vector2(SKIN_FUEL_TRACK.size.x, SKIN_FUEL_TRACK.end.y - 32.0) * s)
		var header: Control = fuel_section.get_node_or_null("FuelHeader")
		if is_instance_valid(header):
			header.custom_minimum_size = Vector2(0.0, header_h)
			# The wooden art already shows the "FUEL" title.
			for n in ["FuelIconRoot", "FuelTitle"]:
				var c := header.get_node_or_null(n) as CanvasItem
				if c:
					c.visible = false
			# Pack the row from the right: percentage always at the right edge, the LOW FUEL
			# warning appears just left of it, never over the painted "FUEL" title.
			if header is BoxContainer:
				header.alignment = BoxContainer.ALIGNMENT_END
				header.add_theme_constant_override("separation", 8)
		if is_instance_valid(low_fuel_indicator):
			_skin_label(low_fuel_indicator, 14, Color(1.0, 0.3, 0.22), 6)
			low_fuel_indicator.size_flags_horizontal = Control.SIZE_SHRINK_END
	fuel_bar.show_percentage = false
	fuel_bar.add_theme_stylebox_override("background", StyleBoxEmpty.new())
	fuel_bar.custom_minimum_size = Vector2(0.0, SKIN_FUEL_TRACK.size.y * s)
	fuel_bar.size_flags_vertical = Control.SIZE_FILL
	for st in [_fuel_style_healthy, _fuel_style_warning, _fuel_style_critical]:
		if st:
			st.set_corner_radius_all(6)

	if is_instance_valid(fuel_percentage_label):
		_skin_label(fuel_percentage_label, 20, SKIN_WHITE, 8)
		fuel_percentage_label.size_flags_horizontal = Control.SIZE_SHRINK_END
		fuel_percentage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		fuel_percentage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if is_instance_valid(_vehicle_ref) and "current_fuel" in _vehicle_ref and "max_fuel" in _vehicle_ref:
		_on_fuel_updated(_vehicle_ref.current_fuel, _vehicle_ref.max_fuel)

func _skin_stats_panel() -> void:
	if not is_instance_valid(survival_panel) or not is_instance_valid(heart_container):
		return
	var src_size := Vector2(458.0, 146.0)
	var sz := Vector2(380.0, 380.0 * src_size.y / src_size.x)
	var s := sz.x / src_size.x
	var panel := _skin_panel("SurvivalStatsPanel", "survival_hud_stats_panel", survival_panel, 0.5, 0.0, Vector2(-sz.x * 0.5, 6.0), sz)

	heart_container.reparent(panel, false)
	heart_container.alignment = BoxContainer.ALIGNMENT_CENTER
	heart_container.add_theme_constant_override("separation", int(10.0 * s))
	_skin_rect(heart_container, Vector2(40.0, 18.0) * s, Vector2(378.0, 60.0) * s)
	var heart_size := Vector2(60.0, 54.0) * s
	for h in heart_container.get_children():
		if h is TextureRect:
			h.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			h.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			h.custom_minimum_size = heart_size
			h.size = heart_size
			h.pivot_offset = heart_size * 0.5

	var stats_row: Control = survival_time_label.get_parent() as Control if is_instance_valid(survival_time_label) else null
	if is_instance_valid(stats_row):
		stats_row.reparent(panel, false)
		if stats_row is BoxContainer:
			stats_row.alignment = BoxContainer.ALIGNMENT_CENTER
			stats_row.add_theme_constant_override("separation", int(46.0 * s))
		_skin_rect(stats_row, Vector2(40.0, 78.0) * s, Vector2(378.0, 38.0) * s)
		for lbl in [survival_time_label, survival_dist_label]:
			if is_instance_valid(lbl):
				_skin_label(lbl, 20, SKIN_YELLOW, 9)
				lbl.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	if is_instance_valid(_survival_controller_ref):
		if "current_lives" in _survival_controller_ref and "max_lives" in _survival_controller_ref:
			set_survival_lives(_survival_controller_ref.current_lives, _survival_controller_ref.max_lives)
		if "survival_time" in _survival_controller_ref and "survival_distance" in _survival_controller_ref:
			set_survival_stats(_survival_controller_ref.survival_time, _survival_controller_ref.survival_distance)

func _skin_coin_panel() -> void:
	if not is_instance_valid(coins_panel) or not is_instance_valid(coins_label):
		return
	var src_size := Vector2(232.0, 111.0)
	var sz := Vector2(164.0, 164.0 * src_size.y / src_size.x)
	var s := sz.x / src_size.x
	# Under the MENU / pause row in the top-right corner.
	var panel := _skin_panel("SurvivalCoinPanel", "survival_hud_coin_panel", coins_panel, 1.0, 0.0, Vector2(-14.0 - sz.x, 76.0), sz)
	coins_label.reparent(panel, false)
	_skin_label(coins_label, 28, SKIN_YELLOW, 10)
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coins_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_skin_rect(coins_label, Vector2(98.0, 18.0) * s, Vector2(120.0, 72.0) * s)

func _skin_speedometer() -> void:
	var src_size := Vector2(247.0, 215.0)
	var sz := Vector2(150.0, 150.0 * src_size.y / src_size.x)
	var s := sz.x / src_size.x
	var gauge := get_node_or_null("SpeedometerGauge") as Control
	if gauge == null:
		return
	# Bottom-right, just left of the gas pedal (gas occupies right -172..-32).
	var dial := _skin_panel("SurvivalSpeedometer", "survival_hud_speedometer", gauge, 1.0, 1.0, Vector2(-186.0 - sz.x, -18.0 - sz.y), sz)

	# Live needle: tapered red needle with dark outline and a white highlight, pivoting on the hub.
	var pivot := Node2D.new()
	pivot.name = "SurvivalNeedlePivot"
	pivot.position = SKIN_SPEEDO_HUB * s
	dial.add_child(pivot)
	var length := SKIN_SPEEDO_NEEDLE_LEN * s
	var outline := Polygon2D.new()
	outline.color = SKIN_OUTLINE
	outline.polygon = PackedVector2Array([Vector2(-4.6, 4.0), Vector2(4.6, 4.0), Vector2(2.2, -length - 2.0), Vector2(-2.2, -length - 2.0)])
	pivot.add_child(outline)
	var body := Polygon2D.new()
	body.color = Color(0.93, 0.12, 0.08)
	body.polygon = PackedVector2Array([Vector2(-3.2, 2.5), Vector2(3.2, 2.5), Vector2(1.1, -length), Vector2(-1.1, -length)])
	pivot.add_child(body)
	var shine := Line2D.new()
	shine.width = 1.0
	shine.default_color = Color(1.0, 0.95, 0.9, 0.9)
	shine.points = PackedVector2Array([Vector2(-1.2, -4.0), Vector2(-0.5, -length + 3.0)])
	pivot.add_child(shine)
	pivot.rotation = deg_to_rad(-SKIN_SPEEDO_ARC_DEG)
	_skin_needle_pivot = pivot

	var hub := TextureRect.new()
	hub.name = "SurvivalNeedleHub"
	hub.texture = _skin_tex("survival_hud_speedo_hub")
	hub.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hub.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var hub_size := Vector2(29.0, 29.0) * s
	dial.add_child(hub)
	_skin_rect(hub, SKIN_SPEEDO_HUB * s - hub_size * 0.5, hub_size)

	if is_instance_valid(speed_digital_label):
		speed_digital_label.reparent(dial, false)
		_skin_label(speed_digital_label, 19, SKIN_WHITE, 8)
		speed_digital_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		speed_digital_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_skin_rect(speed_digital_label, Vector2(SKIN_SPEEDO_HUB.x - 40.0, 124.0) * s, Vector2(80.0, 36.0) * s)

func _update_survival_skin_needle(delta: float) -> void:
	if not is_instance_valid(_skin_needle_pivot) or not is_instance_valid(_vehicle_ref):
		return
	var speed_kmh: float = 0.0
	if _vehicle_ref.has_method("get_speed_kmh"):
		speed_kmh = maxf(0.0, _vehicle_ref.get_speed_kmh())
	var ratio: float = clampf(speed_kmh / SKIN_SPEEDO_MAX_KMH, 0.0, 1.0)
	var target := deg_to_rad(lerpf(-SKIN_SPEEDO_ARC_DEG, SKIN_SPEEDO_ARC_DEG, ratio))
	_skin_needle_pivot.rotation = lerp_angle(_skin_needle_pivot.rotation, target, clampf(delta * 14.0, 0.0, 1.0))

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

var _previous_survival_lives: int = 3

## Survival: Update remaining lives (heart indicators) with heart-break animation
func set_survival_lives(current_l: int, max_l: int = 3) -> void:
	if not is_instance_valid(heart_container):
		return
	var hearts := heart_container.get_children()
	var is_life_loss: bool = current_l < _previous_survival_lives and _previous_survival_lives <= max_l
	
	for i in range(hearts.size()):
		var heart_rect = hearts[i] as TextureRect
		if not is_instance_valid(heart_rect):
			continue
		
		heart_rect.pivot_offset = heart_rect.size * 0.5
		
		if i < current_l:
			# Fully active heart
			heart_rect.texture = HEART_FULL_TEX
			heart_rect.scale = Vector2.ONE
			heart_rect.rotation = 0.0
			heart_rect.modulate = Color.WHITE
		else:
			# Depleted heart
			if is_life_loss and i >= current_l and i < _previous_survival_lives:
				_animate_heart_break(heart_rect)
			else:
				heart_rect.texture = HEART_EMPTY_TEX
				heart_rect.scale = Vector2.ONE
				heart_rect.rotation = 0.0
				heart_rect.modulate = Color.WHITE

	_previous_survival_lives = current_l

func _animate_heart_break(heart_rect: TextureRect) -> void:
	heart_rect.texture = HEART_EMPTY_TEX
	heart_rect.pivot_offset = heart_rect.size * 0.5
	if not heart_rect.is_inside_tree():
		return
	var tw := heart_rect.create_tween()
	if not tw:
		return
	
	tw.set_parallel(false)
	# 1. Brief shake, scale up, and flash
	tw.tween_property(heart_rect, "scale", Vector2(1.35, 1.35), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(heart_rect, "rotation", 0.15, 0.04)
	tw.parallel().tween_property(heart_rect, "modulate", Color(1.8, 0.4, 0.4, 1.0), 0.06)
	
	# 2. Counter-shake
	tw.tween_property(heart_rect, "rotation", -0.15, 0.06)
	
	# 3. Flash fade & settle back to normal scale
	tw.tween_property(heart_rect, "rotation", 0.0, 0.06)
	tw.parallel().tween_property(heart_rect, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(heart_rect, "modulate", Color.WHITE, 0.12)

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
	if is_instance_valid(_survival_controller_ref) and _survival_controller_ref.has_method("toggle_pause"):
		_survival_controller_ref.toggle_pause()
		return
	if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("toggle_pause"):
		game_manager_ref.toggle_pause()
		return
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
	if controller.has_signal("run_paused") and not controller.run_paused.is_connected(_on_run_paused):
		controller.run_paused.connect(_on_run_paused)
		
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
		if _survival_controller_ref.has_signal("run_paused") and _survival_controller_ref.run_paused.is_connected(_on_run_paused):
			_survival_controller_ref.run_paused.disconnect(_on_run_paused)
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

func _on_pothole_assist_hint(should_hint: bool) -> void:
	_pothole_pulse_active = should_hint
	if not should_hint and nitro_button:
		nitro_button.modulate = Color.WHITE
		nitro_button.scale = Vector2.ONE

## Survival: update the coin counter shown for collected coins.
func set_survival_coins(count: int) -> void:
	_on_coins_updated(count)

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

func hide_message_banner() -> void:
	if message_banner:
		message_banner.visible = false
	if pause_banner:
		pause_banner.visible = false

func _on_vehicle_crashed() -> void:
	# In Survival mode, SurvivalController owns lives, crash handling, and game over presentation
	if current_mode == HUDMode.SURVIVAL:
		return
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
	_previous_survival_lives = 3
	hide_message_banner()
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
