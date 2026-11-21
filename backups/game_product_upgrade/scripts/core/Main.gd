class_name MainController
extends Node

## MainController: Master scene switcher and lifecycle manager.
## Orchestrates clean transitions between MainMenu, Game (Endless Map), and Survival scenes.

@export var default_game_scene: PackedScene = preload("res://scenes/game/Game.tscn")
@export var default_menu_scene: PackedScene = preload("res://scenes/main/MainMenu.tscn")
@export var default_survival_scene: PackedScene = preload("res://scenes/modes/survival/Survival.tscn")
@export var default_indian_roads_scene: PackedScene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
@export var start_with_menu: bool = true

@onready var scene_container: Node = $SceneContainer

var current_scene_node: Node = null

func _ready() -> void:
	if start_with_menu and default_menu_scene != null:
		load_menu()
	else:
		load_game()

func load_menu() -> void:
	_switch_scene(default_menu_scene)
	if is_instance_valid(current_scene_node):
		if current_scene_node.has_signal("start_game_requested") and not current_scene_node.start_game_requested.is_connected(load_game):
			current_scene_node.start_game_requested.connect(load_game)
		if current_scene_node.has_signal("start_survival_requested") and not current_scene_node.start_survival_requested.is_connected(load_survival):
			current_scene_node.start_survival_requested.connect(load_survival)
		if current_scene_node.has_signal("start_indian_roads_requested") and not current_scene_node.start_indian_roads_requested.is_connected(load_indian_roads):
			current_scene_node.start_indian_roads_requested.connect(load_indian_roads)

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

func load_survival() -> void:
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
		if surv_inst.obstacle_scenes.is_empty():
			surv_inst.obstacle_scenes = [
				load("res://scenes/modes/survival/obstacles/ChilliObstacle.tscn"),
				load("res://scenes/modes/survival/obstacles/RiceObstacle.tscn"),
				load("res://scenes/modes/survival/obstacles/SweetsObstacle.tscn"),
				load("res://scenes/modes/survival/obstacles/VadaPavObstacle.tscn"),
				load("res://scenes/modes/survival/obstacles/SamosaObstacle.tscn")
			]
			surv_inst.warning_scene = load("res://scenes/modes/survival/obstacles/WarningIndicator.tscn")
		scene_container.add_child(surv_inst)
		current_scene_node = surv_inst
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

func _switch_scene(new_scene: PackedScene) -> void:
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
