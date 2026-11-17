@tool
extends SceneTree

func _init() -> void:
	print("--- FINDING OFFENDING NODE AT x=[870, 1080], y=[415, 460] ---")
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

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

	prog.confirm_route(WorldCycleSchedule.BiomeType.HELL, 0)
	prog.update_distance(750.0)
	game.game_manager.update_distance(750.0)
	if host:
		host.apply_biome_state(WorldCycleSchedule.BiomeType.HELL)

	if gen:
		gen._update_generation(75000.0)
		for enc in gen.active_encounters:
			if enc.has_method("isolate_route"):
				enc.isolate_route(WorldCycleSchedule.BiomeType.HELL)

	var g_y: float = gen.get_surface_y_at_world_x(75000.0) if gen else 595.0
	game.vehicle.reset_vehicle(Vector2(75000.0, g_y - 36.0))
	game.vehicle.linear_velocity = Vector2(850.0, 0.0)
	game.follow_camera.global_position = game.vehicle.global_position + Vector2(160.0, -35.0)
	if game.follow_camera.has_method("snap_to_target"):
		game.follow_camera.snap_to_target()

	for f in range(25):
		await physics_frame
		await process_frame

	var cam := game.follow_camera
	var cam_pos := cam.global_position

	print("\n--- Checking all nodes in Game Scene ---")
	_find_node_at_screen_box(game, Rect2(870, 415, 210, 45), cam_pos)

	quit(0)

func _find_node_at_screen_box(node: Node, screen_box: Rect2, cam_pos: Vector2) -> void:
	if node is CanvasItem and node.is_visible_in_tree():
		var parent := node.get_parent()
		var motion_scale := Vector2.ONE
		var motion_mirror := Vector2.ZERO
		var in_parallax := false
		while parent != null:
			if parent is ParallaxLayer:
				motion_scale = parent.motion_scale
				motion_mirror = parent.motion_mirroring
				in_parallax = true
				break
			parent = parent.get_parent()

		var screen_pos: Vector2
		if in_parallax:
			var scrolled_pos: Vector2 = node.global_position - (cam_pos * motion_scale)
			screen_pos = scrolled_pos + Vector2(640, 360)
			if motion_mirror.x > 0:
				while screen_pos.x < 0:
					screen_pos.x += motion_mirror.x
				while screen_pos.x > motion_mirror.x:
					screen_pos.x -= motion_mirror.x
		else:
			screen_pos = (node.global_position - cam_pos) + Vector2(640, 360)

		# Check if screen_pos is on screen (0..1280, 0..720)
		if screen_pos.x >= 0 and screen_pos.x <= 1280 and screen_pos.y >= 0 and screen_pos.y <= 720:
			var tex_name: String = ""
			if "texture" in node and node.texture != null:
				tex_name = node.texture.resource_path
			elif node is AnimatedSprite2D and node.sprite_frames != null:
				var fr: Texture2D = node.sprite_frames.get_frame_texture(node.animation, node.frame)
				if fr:
					tex_name = fr.resource_path
			print("VISIBLE: %-25s | Path: %-55s | Screen: %s | Z: %d | Mod: %s | Scale: %s | Tex: %s" % [
				node.name, node.get_path(), screen_pos, node.z_index, node.modulate, node.scale, tex_name.get_file()
			])

	for child in node.get_children():
		_find_node_at_screen_box(child, screen_box, cam_pos)

	for child in node.get_children():
		_find_node_at_screen_box(child, screen_box, cam_pos)
