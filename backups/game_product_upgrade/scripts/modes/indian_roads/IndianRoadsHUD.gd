class_name IndianRoadsHUD
extends CanvasLayer

## IndianRoadsHUD: Specialized HUD for Indian Roads mode.
## Displays route progress, upcoming checkpoints, landmark discovery toasts,
## milestone distance, coins, and mobile driving touch controls.

signal pause_pressed
signal restart_pressed
signal return_to_menu_pressed

@onready var route_title_label: Label = %RouteTitleLabel
@onready var progress_bar: ProgressBar = %RouteProgressBar
@onready var distance_label: Label = %DistanceLabel
@onready var next_wp_label: Label = %NextWaypointLabel
@onready var coins_label: Label = %CoinsLabel
@onready var toast_panel: PanelContainer = %ToastPanel
@onready var toast_label: Label = %ToastLabel
@onready var toast_sub_label: Label = %ToastSubLabel
@onready var pause_button: Button = %PauseButton
@onready var gas_button: TouchScreenButton = get_node_or_null("%GasButton")
@onready var brake_button: TouchScreenButton = get_node_or_null("%BrakeButton")
@onready var nitro_button: TouchScreenButton = get_node_or_null("%NitroButton")

var _toast_tween: Tween = null

func _ready() -> void:
	if is_instance_valid(toast_panel):
		toast_panel.visible = false
	if is_instance_valid(pause_button):
		pause_button.pressed.connect(func(): pause_pressed.emit())

func setup_route_info(state_name: String, start_city: String, dest_city: String) -> void:
	if is_instance_valid(route_title_label):
		route_title_label.text = "%s: %s → %s" % [state_name.to_upper(), start_city.to_upper(), dest_city.to_upper()]

func update_progress(current_m: float, total_m: float, coins: int) -> void:
	if is_instance_valid(progress_bar) and total_m > 0.0:
		progress_bar.max_value = total_m
		progress_bar.value = clampf(current_m, 0.0, total_m)

	if is_instance_valid(distance_label):
		distance_label.text = "DIST: %dm / %dm" % [int(current_m), int(total_m)]

	if is_instance_valid(coins_label):
		coins_label.text = str(coins)

func set_next_waypoint_info(wp_title: String, dist_remaining_m: float) -> void:
	if is_instance_valid(next_wp_label):
		if dist_remaining_m > 0.0:
			next_wp_label.text = "NEXT: %s (%dm)" % [wp_title, int(dist_remaining_m)]
		else:
			next_wp_label.text = "ARRIVED: %s" % wp_title

func show_announcement_toast(main_text: String, sub_text: String = "") -> void:
	if not is_instance_valid(toast_panel):
		return

	if is_instance_valid(_toast_tween):
		_toast_tween.kill()

	if is_instance_valid(toast_label):
		toast_label.text = main_text
	if is_instance_valid(toast_sub_label):
		toast_sub_label.text = sub_text
		toast_sub_label.visible = (sub_text != "")

	toast_panel.visible = true
	toast_panel.modulate.a = 0.0
	toast_panel.position.y = -60.0

	_toast_tween = create_tween()
	# Slide in & fade in
	_toast_tween.parallel().tween_property(toast_panel, "position:y", 20.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_toast_tween.parallel().tween_property(toast_panel, "modulate:a", 1.0, 0.25)
	# Hold for 2.4 seconds
	_toast_tween.tween_interval(2.4)
	# Fade out
	_toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.4)
	_toast_tween.tween_callback(func(): toast_panel.visible = false)
