class_name MainMenuController
extends Control

## MainMenuController: Home screen. A countryside environment with the player's selected
## Garage vehicle in the centre, four wooden signboards (Indian Roads, Survival, My Cars,
## Endless), and a Quit button in the sky with a Yes/No confirmation dialog.
## Scene switching stays in Main.gd via the signals below.

const SaveManager = preload("res://scripts/core/SaveManager.gd")

signal start_game_requested
signal start_survival_requested(difficulty: int)
signal start_garage_requested
signal start_indian_roads_requested
signal quit_requested
signal settings_requested

## Design resolution of the home-screen art; the Stage node is scaled to fit the viewport width.
const DESIGN_SIZE := Vector2(1920.0, 1080.0)
## Quit button placement in design space (matches the asset composite's sky position).
const QUIT_SIZE := 100.0
const QUIT_MARGIN_RIGHT := 86.0
const QUIT_MARGIN_TOP := 56.0

@onready var stage: Control = %Stage
@onready var vehicle_showcase: HomeVehicleShowcase = %VehicleShowcase
@onready var indian_roads_sign: HomeSignboard = %IndianRoadsSign
@onready var survival_sign: HomeSignboard = %SurvivalSign
@onready var garage_sign: HomeSignboard = %GarageSign
@onready var endless_sign: HomeSignboard = %EndlessSign
@onready var quit_button: TextureButton = %QuitButton
@onready var settings_button: TextureButton = %SettingsButton
@onready var quit_dialog: Control = %QuitDialog
@onready var quit_yes_button: Button = %QuitYesButton
@onready var quit_no_button: Button = %QuitNoButton
@onready var difficulty_layer: Control = %DifficultyLayer
@onready var difficulty_menu: Control = %SurvivalDifficultyMenu

# Idle parallax drift on the home screen's sky layers, so the scene feels alive while the
# player reads the signboards rather than sitting perfectly static.
var _parallax_time: float = 0.0
var _clouds: Control = null
var _distant_mountains: Control = null
var _hills_forest: Control = null

func _ready() -> void:
	_connect_signals()
	resized.connect(_layout)
	_layout()
	refresh_vehicle()
	if is_instance_valid(stage):
		_clouds = stage.get_node_or_null("Clouds")
		_distant_mountains = stage.get_node_or_null("DistantMountains")
		_hills_forest = stage.get_node_or_null("MidgroundHillsForest")
	_parallax_time = randf() * TAU

func _process(delta: float) -> void:
	_parallax_time += delta
	if is_instance_valid(_clouds):
		_clouds.position.x = sin(_parallax_time * 0.12) * 16.0
	if is_instance_valid(_distant_mountains):
		_distant_mountains.position.x = sin(_parallax_time * 0.08 + 1.4) * 6.0
	if is_instance_valid(_hills_forest):
		_hills_forest.position.x = sin(_parallax_time * 0.18 + 2.6) * 3.0

## Shows the vehicle currently selected in the Garage (single source: SaveManager).
func refresh_vehicle() -> void:
	vehicle_showcase.show_vehicle(SaveManager.get_selected_vehicle_id())

func _connect_signals() -> void:
	endless_sign.pressed.connect(_on_endless_pressed)
	survival_sign.pressed.connect(_on_survival_pressed)
	garage_sign.pressed.connect(_on_garage_pressed)
	indian_roads_sign.pressed.connect(_on_indian_roads_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	quit_yes_button.pressed.connect(_on_quit_confirmed)
	quit_no_button.pressed.connect(_close_quit_dialog)
	if is_instance_valid(settings_button):
		settings_button.pressed.connect(_on_settings_pressed)
	if not difficulty_menu.start_survival_pressed.is_connected(_on_difficulty_start_survival_pressed):
		difficulty_menu.start_survival_pressed.connect(_on_difficulty_start_survival_pressed)
	if not difficulty_menu.back_pressed.is_connected(_close_difficulty_selection):
		difficulty_menu.back_pressed.connect(_close_difficulty_selection)

## Scales the 1920x1080 stage to the viewport width, anchored to the bottom so the ground and
## signboards always stay visible; the quit button is pinned to the top-right of the screen.
func _layout() -> void:
	if not is_instance_valid(stage):
		return
	var s := size.x / DESIGN_SIZE.x
	stage.scale = Vector2(s, s)
	stage.position = Vector2(0.0, size.y - DESIGN_SIZE.y * s)
	var q := QUIT_SIZE * s
	quit_button.size = Vector2(q, q)
	quit_button.position = Vector2(size.x - QUIT_MARGIN_RIGHT * s - q, maxf(QUIT_MARGIN_TOP * s, 8.0))
	quit_button.pivot_offset = quit_button.size * 0.5
	if is_instance_valid(settings_button):
		settings_button.size = Vector2(q, q)
		settings_button.position = Vector2(quit_button.position.x - q - 16.0 * s, quit_button.position.y)
		settings_button.pivot_offset = settings_button.size * 0.5

func _on_endless_pressed() -> void:
	start_game_requested.emit()

func _on_garage_pressed() -> void:
	start_garage_requested.emit()

func _on_survival_pressed() -> void:
	_open_difficulty_selection()

func _on_indian_roads_pressed() -> void:
	start_indian_roads_requested.emit()

func _open_difficulty_selection() -> void:
	difficulty_layer.visible = true
	var saved_diff := SaveManager.get_survival_difficulty()
	if difficulty_menu.has_method("select_difficulty"):
		difficulty_menu.select_difficulty(saved_diff)

func _close_difficulty_selection() -> void:
	difficulty_layer.visible = false
	survival_sign.grab_focus()

func _on_difficulty_start_survival_pressed(difficulty: int) -> void:
	SaveManager.set_survival_difficulty(difficulty)
	start_survival_requested.emit(difficulty)

func _on_quit_pressed() -> void:
	quit_dialog.visible = true
	quit_no_button.grab_focus()

func _on_settings_pressed() -> void:
	settings_requested.emit()

func _close_quit_dialog() -> void:
	quit_dialog.visible = false
	quit_button.grab_focus()

func _on_quit_confirmed() -> void:
	quit_requested.emit()
	get_tree().quit()

func _notification(what: int) -> void:
	# Android back button: ask before leaving the game instead of closing immediately.
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_inside_tree():
		if quit_dialog.visible:
			_close_quit_dialog()
		elif difficulty_layer.visible:
			_close_difficulty_selection()
		else:
			_on_quit_pressed()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel"):
		if quit_dialog.visible:
			get_viewport().set_input_as_handled()
			_close_quit_dialog()
		elif difficulty_layer.visible:
			get_viewport().set_input_as_handled()
			_close_difficulty_selection()
