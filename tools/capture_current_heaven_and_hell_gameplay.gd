@tool
extends SceneTree

# tools/capture_current_heaven_and_hell_gameplay.gd
# Captures high-fidelity current live gameplay screenshots of Heaven and Hell on AMD Radeon 610M.
# Outputs:
# - res://docs/previews/current_gameplay_heaven.png
# - res://docs/previews/current_gameplay_hell.png

func _init() -> void:
	print("=================================================================")
	print("--- CAPTURING CURRENT LIVE GAMEPLAY: HEAVEN & HELL ---")
	print("=================================================================")
	await _capture_current_gameplay()
	quit(0)

func _capture_current_gameplay() -> void:
	var dir := DirAccess.open("res://docs/previews")
	if not dir:
		DirAccess.make_dir_recursive_absolute("res://docs/previews")

	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed:
		printerr("Failed to load Game.tscn")
		return

	# -------------------------------------------------------------
	# 1. CURRENT GAMEPLAY: HEAVEN BIOME
	# -------------------------------------------------------------
	print("\n>>> Capturing Current Gameplay: HEAVEN BIOME...")
	var sub_viewport := SubViewport.new()
	sub_viewport.size = Vector2i(1280, 720)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sub_viewport)

	var game_inst: GameScene = packed.instantiate() as GameScene
	game_inst.use_procedural_terrain = true
	sub_viewport.add_child(game_inst)

	for i in range(15):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game_inst.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game_inst.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	if not prog:
		prog = game_inst.find_child("BiomeProgressionController", true, false)
	if not prog:
		prog = BiomeProgressionController.new()
		game_inst.add_child(prog)
		if is_instance_valid(game_inst.game_manager):
			prog.connect_to_game_manager(game_inst.game_manager)

	if is_instance_valid(host):
		host.bind_progression_controller(prog)
		if is_instance_valid(game_inst.follow_camera):
			host.follow_camera = game_inst.follow_camera

	if prog:
		prog.enable_branching_mode(true)
	if gen and prog:
		gen.bind_progression_controller(prog)
	if is_instance_valid(game_inst.hud):
		game_inst.hud.bind_progression_controller(prog)

	prog.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	prog.update_distance(750.0)
	game_inst.game_manager.update_distance(750.0)
	game_inst.game_manager.coins_collected = 75
	game_inst.game_manager.coins_updated.emit(75)

	if host:
		host.apply_biome_state(WorldCycleSchedule.BiomeType.HEAVEN)

	if gen:
		gen._update_generation(75000.0)
		for enc in gen.active_encounters:
			if enc.has_method("isolate_route"):
				enc.isolate_route(WorldCycleSchedule.BiomeType.HEAVEN)

	var g_y_heaven: float = gen.get_surface_y_at_world_x(75000.0) if gen else 195.0
	game_inst.vehicle.reset_vehicle(Vector2(75000.0, g_y_heaven - 36.0))
	game_inst.vehicle.linear_velocity = Vector2(980.0, 0.0)
	game_inst.vehicle.set("throttle_input", 1.0)
	if game_inst.game_manager:
		game_inst.game_manager.current_state = GameManager.RunState.PLAYING
	if game_inst.hud and game_inst.hud.message_banner:
		game_inst.hud.message_banner.visible = false
	if game_inst.vehicle.has_method("set_nitro_active"):
		game_inst.vehicle.set_nitro_active(true)

	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -40.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()

	for f in range(30):
		await physics_frame
		await process_frame

	_save_viewport_image(sub_viewport, "res://docs/previews/current_gameplay_heaven.png")

	# Teardown Heaven viewport
	sub_viewport.queue_free()
	await process_frame

	# -------------------------------------------------------------
	# 2. CURRENT GAMEPLAY: HELL BIOME (SEPARATE RUN)
	# -------------------------------------------------------------
	print("\n>>> Capturing Current Gameplay: HELL BIOME...")
	var vp_hell := SubViewport.new()
	vp_hell.size = Vector2i(1280, 720)
	vp_hell.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp_hell)

	var game_hell: GameScene = packed.instantiate() as GameScene
	game_hell.use_procedural_terrain = true
	vp_hell.add_child(game_hell)

	for i in range(15):
		await process_frame
		await physics_frame

	var gen_hell: TerrainGenerator = game_hell.terrain_slot.get_node_or_null("TerrainGenerator")
	var host_hell: BiomeEnvironmentHost = game_hell.biome_environment_host
	var prog_hell: BiomeProgressionController = host_hell.progression_controller if is_instance_valid(host_hell) else null

	if not prog_hell:
		prog_hell = game_hell.find_child("BiomeProgressionController", true, false)
	if not prog_hell:
		prog_hell = BiomeProgressionController.new()
		game_hell.add_child(prog_hell)
		if is_instance_valid(game_hell.game_manager):
			prog_hell.connect_to_game_manager(game_hell.game_manager)

	if is_instance_valid(host_hell):
		host_hell.bind_progression_controller(prog_hell)
		if is_instance_valid(game_hell.follow_camera):
			host_hell.follow_camera = game_hell.follow_camera

	if prog_hell:
		prog_hell.enable_branching_mode(true)
	if gen_hell and prog_hell:
		gen_hell.bind_progression_controller(prog_hell)
	if is_instance_valid(game_hell.hud):
		game_hell.hud.bind_progression_controller(prog_hell)

	prog_hell.confirm_route(WorldCycleSchedule.BiomeType.HELL, 0)
	prog_hell.update_distance(750.0)
	game_hell.game_manager.update_distance(750.0)
	game_hell.game_manager.coins_collected = 120
	game_hell.game_manager.coins_updated.emit(120)

	if host_hell:
		host_hell.apply_biome_state(WorldCycleSchedule.BiomeType.HELL)

	if gen_hell:
		gen_hell._update_generation(75000.0)
		for enc in gen_hell.active_encounters:
			if enc.has_method("isolate_route"):
				enc.isolate_route(WorldCycleSchedule.BiomeType.HELL)

	var g_y_hell: float = gen_hell.get_surface_y_at_world_x(75000.0) if gen_hell else 595.0
	game_hell.vehicle.reset_vehicle(Vector2(75000.0, g_y_hell - 36.0))
	game_hell.vehicle.linear_velocity = Vector2(850.0, 0.0)
	game_hell.vehicle.set("throttle_input", 1.0)
	if game_hell.game_manager:
		game_hell.game_manager.current_state = GameManager.RunState.PLAYING
	if game_hell.hud and game_hell.hud.message_banner:
		game_hell.hud.message_banner.visible = false
	if game_hell.vehicle.has_method("set_nitro_active"):
		game_hell.vehicle.set_nitro_active(false)

	if is_instance_valid(game_hell.follow_camera):
		game_hell.follow_camera.global_position = game_hell.vehicle.global_position + Vector2(160.0, -35.0)
		if game_hell.follow_camera.has_method("snap_to_target"):
			game_hell.follow_camera.snap_to_target()

	for f in range(30):
		await physics_frame
		await process_frame

	_save_viewport_image(vp_hell, "res://docs/previews/current_gameplay_hell.png")

	vp_hell.queue_free()
	await process_frame

	print("\n✓ CURRENT GAMEPLAY SCREENSHOTS OF HEAVEN AND HELL CAPTURED SUCCESSFULLY!")

func _save_viewport_image(viewport: SubViewport, dest_path: String) -> void:
	var img: Image = viewport.get_texture().get_image()
	if not img:
		printerr("Failed to get image from viewport")
		return
	var err := img.save_png(dest_path)
	if err == OK:
		print("  -> Saved screenshot: %s (%dx%d, %d bytes)" % [dest_path, img.get_width(), img.get_height(), img.get_data().size()])
	else:
		printerr("  ✗ Failed to save screenshot: %s (error code %d)" % [dest_path, err])
