extends CanvasLayer

signal pause_pressed
signal nitro_pressed

@onready var fuel_bar: ProgressBar = $TopLeft/FuelBar
@onready var coin_label: Label = $TopRight/CoinPill/HBox/CoinLabel
@onready var pause_button: TextureButton = $TopRight/PauseButton
@onready var gauge_needle: Sprite2D = $BottomCenter/GaugeDial/GaugeNeedle
@onready var brake_pedal: TouchScreenButton = $BottomLeft/BrakePedal
@onready var gas_pedal: TouchScreenButton = $BottomRight/GasPedal
@onready var nitro_btn: TouchScreenButton = $BottomLeft/NitroButton
@onready var progress_bar: ProgressBar = $TopCenter/StageProgress
@onready var debug_panel: PanelContainer = $DebugOverlay
@onready var debug_label: Label = $DebugOverlay/Margin/DebugLabel

var debug_visible: bool = false
var target_needle_rot: float = 0.85 # Full (rad)

func _ready() -> void:
	debug_panel.visible = false
	pause_button.pressed.connect(_on_pause_pressed)
	
	if GameState:
		GameState.fuel_changed.connect(_on_fuel_changed)
		GameState.coins_changed.connect(_on_coins_changed)
		_on_coins_changed(GameState.coins)
		_on_fuel_changed(GameState.current_fuel, GameState.max_fuel)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_overlay"):
		debug_visible = !debug_visible
		debug_panel.visible = debug_visible
	elif event.is_action_pressed("pause"):
		_on_pause_pressed()

func _process(delta: float) -> void:
	# Smooth needle movement on analog gauge
	gauge_needle.rotation = lerpf(gauge_needle.rotation, target_needle_rot, 8.0 * delta)
	
	# Update stage progress bar
	if StageManager and StageManager.current_stage:
		var total_len: float = StageManager.current_stage.length_meters
		progress_bar.value = clampf((GameState.current_distance / total_len) * 100.0, 0.0, 100.0)
		
	# Update F3 debug overlay
	if debug_visible:
		var fps := Engine.get_frames_per_second()
		var dist := int(GameState.current_distance)
		var fuel := int(GameState.current_fuel)
		var nitro := int(GameState.current_nitro)
		debug_label.text = "FPS: %d\nDistance: %dm\nFuel: %d%%\nNitro: %d%%\nVehicle: %s" % [
			fps, dist, fuel, nitro, GameState.active_vehicle_id.capitalize()
		]

func _on_fuel_changed(current: float, max_val: float) -> void:
	var ratio := clampf(current / maxf(1.0, max_val), 0.0, 1.0)
	fuel_bar.value = ratio * 100.0
	
	# Fuel Bar Color Dynamics: Green -> Orange -> Red
	var style: StyleBoxFlat = fuel_bar.get_theme_stylebox("fill").duplicate()
	if ratio > 0.45:
		style.bg_color = Color(0.2, 0.82, 0.28, 1.0) # Green
	elif ratio > 0.20:
		style.bg_color = Color(0.98, 0.65, 0.12, 1.0) # Warning Orange
	else:
		style.bg_color = Color(0.90, 0.18, 0.18, 1.0) # Critical Red
	fuel_bar.add_theme_stylebox_override("fill", style)
	
	# Analog needle rotation: from -0.85 rad (Empty) to +0.85 rad (Full)
	target_needle_rot = lerpf(-0.85, 0.85, ratio)

func _on_coins_changed(total: int) -> void:
	coin_label.text = str(total)

func _on_pause_pressed() -> void:
	AudioManager.play_sfx("click")
	pause_pressed.emit()
