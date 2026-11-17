@tool
extends SceneTree

func _init() -> void:
	print("--- INSPECTING NODES AT 1005m MERGE ---")
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)

	for i in range(15):
		await process_frame
		await physics_frame

	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null
	if not prog:
		prog = game.find_child("BiomeProgressionController", true, false)
	if prog:
		prog.enable_branching_mode(true)

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	if gen and prog:
		gen.bind_progression_controller(prog)

	prog.update_distance(1005.0)
	game.game_manager.update_distance(1005.0)
	if host:
		host.apply_biome_state(WorldCycleSchedule.BiomeType.NORMAL_LAND)

	if gen:
		gen._update_generation(100500.0)

	var g_y: float = gen.get_surface_y_at_world_x(100500.0) if gen else 420.0
	game.vehicle.reset_vehicle(Vector2(100500.0, g_y - 36.0))
	game.follow_camera.global_position = game.vehicle.global_position + Vector2(140.0, -40.0)
	if game.follow_camera.has_method("snap_to_target"):
		game.follow_camera.snap_to_target()

	for f in range(25):
		await physics_frame
		await process_frame

	var cam := game.follow_camera
	var cam_pos := cam.global_position
	print("Camera global position: ", cam_pos)

	# Screen point (843, 317) on a 1280x720 screen
	# The screen center is (640, 360).
	# Relative offset from center:
	var screen_offset := Vector2(843.0 - 640.0, 317.0 - 360.0) # (203, -43)
	var world_target := cam_pos + screen_offset
	print("World target at (843, 317): ", world_target)

	print("\n--- Traversing all CanvasItems in tree ---")
	_check_node(game, world_target, cam_pos)

	quit(0)

func _check_node(node: Node, world_target: Vector2, cam_pos: Vector2) -> void:
	if node is Sprite2D and node.is_visible_in_tree():
		var tex_path: String = node.texture.resource_path if node.texture != null else "NO_TEXTURE"
		var g_pos: Vector2 = node.global_position
		# If inside ParallaxLayer, effective pos depends on motion_scale
		var parent := node.get_parent()
		var motion_scale := Vector2.ONE
		var motion_mirror := Vector2.ZERO
		while parent != null:
			if parent is ParallaxLayer:
				motion_scale = parent.motion_scale
				motion_mirror = parent.motion_mirroring
				break
			parent = parent.get_parent()
		
		print("Sprite: %-30s | Tex: %-50s | Pos: %s | MotionScale: %s" % [node.name, tex_path.get_file(), g_pos, motion_scale])
	elif node is Polygon2D and node.is_visible_in_tree():
		var tex_path: String = node.texture.resource_path if node.texture != null else "NO_TEXTURE"
		print("Polygon2D: %-26s | Tex: %-50s | Pos: %s" % [node.name, tex_path.get_file(), node.global_position])

	for child in node.get_children():
		_check_node(child, world_target, cam_pos)
