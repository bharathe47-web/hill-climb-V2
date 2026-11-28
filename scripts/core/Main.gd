class_name MainController
extends Node

## MainController: Master scene switcher and lifecycle manager.
## Orchestrates clean transitions between MainMenu, Game (Endless Map), Survival, and Garage scenes.

@export var default_game_scene: PackedScene = preload("res://scenes/game/Game.tscn")
@export var default_menu_scene: PackedScene = preload("res://scenes/main/MainMenu.tscn")
@export var default_survival_scene: PackedScene = preload("res://scenes/modes/survival/Survival.tscn")
@export var default_garage_scene: PackedScene = preload("res://scenes/modes/garage/VintageCarGarage.tscn")
@export var default_indian_roads_scene: PackedScene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
@export var default_settings_scene: PackedScene = preload("res://scenes/main/SettingsMenu.tscn")
## Alternate garage/vehicle menu from the indian-lag-hill branch (reached via open_garage_requested).
@export var default_garage_menu_scene: PackedScene = preload("res://scenes/ui/GarageMenu.tscn")
@export var start_with_menu: bool = true

const SaveManager = preload("res://scripts/core/SaveManager.gd")

@onready var scene_container: Node = $SceneContainer

var current_scene_node: Node = null
var _settings_instance: Node = null

func _ready() -> void:
	_apply_startup_audio_settings()
	if start_with_menu and default_menu_scene != null:
		load_menu()
	else:
		load_game()

func _apply_startup_audio_settings() -> void:
	var music_vol := SaveManager.get_music_volume()
	var sound_vol := SaveManager.get_sound_volume()
	var music_db: float = linear_to_db(music_vol) if music_vol > 0.0001 else -80.0
	var sound_db: float = linear_to_db(sound_vol) if sound_vol > 0.0001 else -80.0

	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, music_db)
	var amb_bus := AudioServer.get_bus_index("Ambience")
	if amb_bus >= 0:
		AudioServer.set_bus_volume_db(amb_bus, music_db)
	var sfx_bus := AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, sound_db)
	var ui_bus := AudioServer.get_bus_index("UI")
	if ui_bus >= 0:
		AudioServer.set_bus_volume_db(ui_bus, sound_db)

func load_menu() -> void:
	_switch_scene(default_menu_scene)
	if is_instance_valid(current_scene_node):
		if current_scene_node.has_signal("start_game_requested") and not current_scene_node.start_game_requested.is_connected(load_game):
			current_scene_node.start_game_requested.connect(load_game)
		if current_scene_node.has_signal("start_survival_requested") and not current_scene_node.start_survival_requested.is_connected(load_survival):
			current_scene_node.start_survival_requested.connect(load_survival)
		if current_scene_node.has_signal("start_garage_requested") and not current_scene_node.start_garage_requested.is_connected(load_garage):
			current_scene_node.start_garage_requested.connect(load_garage)
		if current_scene_node.has_signal("start_indian_roads_requested") and not current_scene_node.start_indian_roads_requested.is_connected(load_indian_roads):
			current_scene_node.start_indian_roads_requested.connect(load_indian_roads)
		if current_scene_node.has_signal("settings_requested") and not current_scene_node.settings_requested.is_connected(open_settings):
			current_scene_node.settings_requested.connect(open_settings)
		if current_scene_node.has_signal("open_garage_requested") and not current_scene_node.open_garage_requested.is_connected(load_garage_menu):
			current_scene_node.open_garage_requested.connect(load_garage_menu)

func load_game() -> void:
	if not is_instance_valid(scene_container):
		scene_container = get_node_or_null("SceneContainer")
	if not is_instance_valid(scene_container):
		push_error("MainController: SceneContainer is missing!")
		return

	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()
		current_scene_node = null
	
	if default_game_scene:
		var game_inst = default_game_scene.instantiate()
		# Enable procedural terrain BEFORE add_child so _ready() initializes it immediately without frame flicker
		if game_inst.has_method("setup_terrain"):
			game_inst.set("use_procedural_terrain", true)
		scene_container.add_child(game_inst)
		current_scene_node = game_inst
		
		if current_scene_node.has_signal("return_to_main_menu_requested") and not current_scene_node.return_to_main_menu_requested.is_connected(load_menu):
			current_scene_node.return_to_main_menu_requested.connect(load_menu)

func load_survival(difficulty: int = -1) -> void:
	if not is_instance_valid(scene_container):
		scene_container = get_node_or_null("SceneContainer")
	if not is_instance_valid(scene_container):
		push_error("MainController: SceneContainer is missing!")
		return

	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()
		current_scene_node = null
	
	if default_survival_scene:
		var surv_inst = default_survival_scene.instantiate()
		var target_diff: int = difficulty
		if target_diff < 0:
			target_diff = SaveManager.get_survival_difficulty()
		surv_inst.set("selected_difficulty", target_diff)
		# Explicitly enable obstacle spawning and default food hazards for active Survival gameplay
		surv_inst.set("enable_obstacle_spawning", true)
		surv_inst.set("use_default_food_obstacles", true)
		if surv_inst.has_method("load_default_obstacles"):
			surv_inst.load_default_obstacles()
		scene_container.add_child(surv_inst)
		current_scene_node = surv_inst
		
		if current_scene_node.has_signal("return_to_main_menu_requested") and not current_scene_node.return_to_main_menu_requested.is_connected(load_menu):
			current_scene_node.return_to_main_menu_requested.connect(load_menu)

func load_garage() -> void:
	if not is_instance_valid(scene_container):
		scene_container = get_node_or_null("SceneContainer")
	if not is_instance_valid(scene_container):
		push_error("MainController: SceneContainer is missing!")
		return

	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()
		current_scene_node = null
	
	if default_garage_scene:
		var garage_inst = default_garage_scene.instantiate()
		scene_container.add_child(garage_inst)
		current_scene_node = garage_inst
		
		if current_scene_node.has_signal("return_to_main_menu_requested") and not current_scene_node.return_to_main_menu_requested.is_connected(load_menu):
			current_scene_node.return_to_main_menu_requested.connect(load_menu)

func load_indian_roads() -> void:
	if not is_instance_valid(scene_container):
		scene_container = get_node_or_null("SceneContainer")
	if not is_instance_valid(scene_container):
		push_error("MainController: SceneContainer is missing!")
		return

	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()
		current_scene_node = null

	if default_indian_roads_scene:
		var roads_inst = default_indian_roads_scene.instantiate()
		scene_container.add_child(roads_inst)
		current_scene_node = roads_inst

		if current_scene_node.has_signal("return_to_main_menu_requested") and not current_scene_node.return_to_main_menu_requested.is_connected(load_menu):
			current_scene_node.return_to_main_menu_requested.connect(load_menu)

func load_garage_menu() -> void:
	if not is_instance_valid(scene_container):
		scene_container = get_node_or_null("SceneContainer")
	if not is_instance_valid(scene_container):
		push_error("MainController: SceneContainer is missing!")
		return

	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()
		current_scene_node = null

	if default_garage_menu_scene:
		var garage_inst = default_garage_menu_scene.instantiate()
		scene_container.add_child(garage_inst)
		current_scene_node = garage_inst
		if current_scene_node.has_signal("back_pressed") and not current_scene_node.back_pressed.is_connected(load_menu):
			current_scene_node.back_pressed.connect(load_menu)
		if current_scene_node.has_signal("drive_pressed") and not current_scene_node.drive_pressed.is_connected(load_indian_roads):
			current_scene_node.drive_pressed.connect(load_indian_roads)

func _switch_scene(new_scene: PackedScene) -> void:
	close_settings()
	if not is_instance_valid(scene_container):
		scene_container = get_node_or_null("SceneContainer")
	if not is_instance_valid(scene_container):
		push_error("MainController: SceneContainer is missing!")
		return

	if is_instance_valid(current_scene_node):
		current_scene_node.queue_free()
		current_scene_node = null
	
	if new_scene:
		current_scene_node = new_scene.instantiate()
		scene_container.add_child(current_scene_node)

func open_settings() -> void:
	if is_instance_valid(_settings_instance):
		return
	if default_settings_scene:
		_settings_instance = default_settings_scene.instantiate()
		if _settings_instance.has_signal("close_requested"):
			_settings_instance.close_requested.connect(close_settings)
		if is_instance_valid(scene_container):
			scene_container.add_child(_settings_instance)
		else:
			add_child(_settings_instance)

func close_settings() -> void:
	if is_instance_valid(_settings_instance):
		_settings_instance.queue_free()
		_settings_instance = null
