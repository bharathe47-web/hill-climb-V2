@tool
extends SceneTree

# tools/investigate_hell_glitch.gd
# Investigates the Hell character glitch by toggling candidate nodes one by one

func _init() -> void:
	print("--- INVESTIGATING HELL CHARACTER GLITCH AT 750m ---")
	await _run()
	quit(0)

func _run() -> void:
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

	var hell_env: Node = host.hell_environment if host else null
	if not hell_env:
		hell_env = game.find_child("HellEnvironment", true, false)

	print("HellEnvironment found: ", hell_env != null)

	# Save baseline screenshot
	_save_vp(vp, "/home/danny/.gemini/antigravity-cli/brain/1729bd5b-8bbd-4078-b9dc-83b6cb99827a/scratch/hell_glitch_0_baseline.png")

	var test_nodes: Array[String] = [
		"SkeletonKnight",
		"DemonGoblin",
		"HornedFiend",
		"TorchFlameLeft",
		"TorchFlameRight",
		"HeatShimmer"
	]

	for target_name in test_nodes:
		var target_node := hell_env.find_child(target_name, true, false) as CanvasItem
		if target_node:
			print("\n--- Testing node: %s ---" % target_name)
			print("  Type: ", target_node.get_class())
			print("  Global Position: ", target_node.global_position)
			print("  Local Position: ", target_node.position)
			print("  Scale: ", target_node.scale)
			print("  Modulate: ", target_node.modulate)
			print("  Z-Index: ", target_node.z_index)
			if target_node is AnimatedSprite2D:
				var frames: SpriteFrames = target_node.sprite_frames
				if frames:
					print("  Animation: ", target_node.animation, " | Frame count: ", frames.get_frame_count(target_node.animation))
					var cur_tex: Texture2D = frames.get_frame_texture(target_node.animation, target_node.frame)
					if cur_tex:
						print("  Current frame texture: ", cur_tex.resource_path)

			# Toggle off
			target_node.visible = false
			await process_frame
			await physics_frame
			var path := "/home/danny/.gemini/antigravity-cli/brain/1729bd5b-8bbd-4078-b9dc-83b6cb99827a/scratch/hell_glitch_hide_%s.png" % target_name
			_save_vp(vp, path)
			# Toggle back on
			target_node.visible = true
			await process_frame
		else:
			print("Node NOT found in HellEnvironment: ", target_name)

func _save_vp(vp: SubViewport, path: String) -> void:
	var tex := vp.get_texture()
	if tex:
		var img := tex.get_image()
		if img and not img.is_empty():
			img.save_png(path)
			print("  [SAVED] ", path)
