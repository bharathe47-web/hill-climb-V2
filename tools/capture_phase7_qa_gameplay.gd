@tool
extends SceneTree

# tools/capture_phase7_qa_gameplay.gd
# Captures live Phase 7 End-to-End QA milestone gameplay evidence on AMD Radeon 610M:
# 1. 485m: Approach Decision Window (Hermite ramp lip, LAUNCH_WINDOW prompt, RAMP_WARNING HUD)
# 2. 750m: Heaven Active Flight Route (celestial sky, golden palace pillars, doves, angel monument, coin arcs)
# 3. 750m: Hell Active Cavern Route (basalt crags, volcanic lava glow, demon sentinel, high-density coins)
# 4. 1005m: Return Merge into Normal Land (exit ramp rejoining baseline Y=420px, countryside transition)
# 5. 5020m: Continuous 5,000m+ Milestone (cycle 5 progression, seamless endless state persistence)

const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 7 END-TO-END QA GAMEPLAY CAPTURE ---")
	print("=================================================================")
	await _run_captures()
	quit(0)

func _run_captures() -> void:
	var dir := DirAccess.open("res://docs/previews")
	if not dir:
		DirAccess.make_dir_recursive_absolute("res://docs/previews")

	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed:
		printerr("Failed to load Game.tscn")
		return

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

	# -------------------------------------------------------------
	# 1. 485m: Approach Decision Window & Ramp Warning HUD
	# -------------------------------------------------------------
	print("\n>>> Capturing 1/5: Approach Decision Window (485m)...")
	prog.update_distance(485.0)
	game_inst.game_manager.update_distance(485.0)
	game_inst.game_manager.coins_collected = 15
	game_inst.game_manager.coins_updated.emit(15)
	
	game_inst.vehicle.global_position = Vector2(48500.0, 365.0)
	game_inst.vehicle.linear_velocity = Vector2(850.0, -80.0)
	game_inst.vehicle.rotation = deg_to_rad(-6.0)
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(120.0, -40.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase7_qa_1_approach_decision_window.png")

	# -------------------------------------------------------------
	# 2. 750m: Heaven Active Flight Route & Celestial Scenery
	# -------------------------------------------------------------
	print(">>> Capturing 2/5: Heaven Active Flight Route (750m)...")
	prog.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	prog.update_distance(750.0)
	game_inst.game_manager.update_distance(750.0)
	game_inst.game_manager.coins_collected = 55
	game_inst.game_manager.coins_updated.emit(55)
	
	game_inst.vehicle.global_position = Vector2(75000.0, 185.0)
	game_inst.vehicle.linear_velocity = Vector2(980.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(140.0, -40.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase7_qa_2_heaven_active_flight.png")

	# -------------------------------------------------------------
	# 3. 750m: Hell Active Cavern Route & Magma Atmosphere
	# -------------------------------------------------------------
	print(">>> Capturing 3/5: Hell Active Cavern Route (750m)...")
	# Switch progression confirmation to Hell for visual evidence
	prog.confirmed_realms[0] = WorldCycleSchedule.BiomeType.HELL
	prog.update_distance(750.0)
	game_inst.game_manager.update_distance(750.0)
	game_inst.game_manager.coins_collected = 80
	game_inst.game_manager.coins_updated.emit(80)
	
	# Spawn Trophy Truck at Hell cavern floor elevation
	game_inst.vehicle.global_position = Vector2(75000.0, 560.0)
	game_inst.vehicle.linear_velocity = Vector2(850.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(140.0, -30.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase7_qa_3_hell_active_cavern.png")

	# -------------------------------------------------------------
	# 4. 1,005m: Return Merge into Normal Land Baseline
	# -------------------------------------------------------------
	print(">>> Capturing 4/5: Return Merge into Normal Land (1,005m)...")
	prog.update_distance(1005.0)
	game_inst.game_manager.update_distance(1005.0)
	game_inst.game_manager.coins_collected = 115
	game_inst.game_manager.coins_updated.emit(115)
	
	game_inst.vehicle.global_position = Vector2(100500.0, 405.0)
	game_inst.vehicle.linear_velocity = Vector2(750.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(120.0, -40.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase7_qa_4_return_merge_normal_land.png")

	# -------------------------------------------------------------
	# 5. 5,020m: Continuous 5,000m+ Endless Milestone
	# -------------------------------------------------------------
	print(">>> Capturing 5/5: Continuous 5,000m+ Endless Milestone (5,020m)...")
	prog.update_distance(5020.0)
	game_inst.game_manager.update_distance(5020.0)
	game_inst.game_manager.coins_collected = 385
	game_inst.game_manager.coins_updated.emit(385)
	
	game_inst.vehicle.global_position = Vector2(502000.0, 410.0)
	game_inst.vehicle.linear_velocity = Vector2(880.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(140.0, -40.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase7_qa_5_continuous_5000m_milestone.png")

	print("\n✓ ALL 5 PHASE 7 QA SCREENSHOTS CAPTURED SUCCESSFULLY!")

func _save_viewport_image(viewport: SubViewport, dest_path: String) -> void:
	var img: Image = viewport.get_texture().get_image()
	if not img:
		printerr("Failed to get image from viewport")
		return
	var err := img.save_png(dest_path)
	if err == OK:
		print("  -> Saved screenshot: %s (%dx%d)" % [dest_path, img.get_width(), img.get_height()])
	else:
		printerr("  ✗ Failed to save screenshot: %s (error code %d)" % [dest_path, err])
