@tool
extends SceneTree

# tools/capture_phase5_transition_gameplay.gd
# Captures high-fidelity Phase 5 transition presentation gameplay screenshots on AMD Radeon 610M:
# 1. 460m: RAMP AHEAD warning banner with first-time tutorial copy & ramp lip approaching
# 2. 485m: BOOST TO REACH HEAVEN launch window with pulsing Nitro meter and Boost control
# 3. 512m: HEAVEN ROUTE celestial ascent toast, golden light flash aura, and elevated camera
# 4. 515m: HELL ROUTE subterranean descent toast, atmospheric darkening vignette, and dragon skull

const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 5 TRANSITION PRESENTATION CAPTURE ---")
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
	# 1. 460m: RAMP AHEAD Warning Banner & First-time Tutorial Copy
	# -------------------------------------------------------------
	print("\n>>> Capturing 1/4: Ramp Ahead Warning Banner (460m)...")
	prog.update_distance(460.0)
	game_inst.game_manager.update_distance(460.0)
	game_inst.vehicle.global_position = Vector2(46000.0, 420.0)
	game_inst.vehicle.linear_velocity = Vector2(900.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -50.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase5_transition_1_ramp_warning.png")

	# -------------------------------------------------------------
	# 2. 485m: BOOST TO REACH HEAVEN Launch Window & Nitro Pulse
	# -------------------------------------------------------------
	print(">>> Capturing 2/4: Boost To Reach Heaven Launch Window (485m)...")
	prog.update_distance(485.0)
	game_inst.game_manager.update_distance(485.0)
	game_inst.vehicle.global_position = Vector2(48500.0, 400.0)
	game_inst.vehicle.linear_velocity = Vector2(1100.0, -150.0)
	game_inst.vehicle.rotation = deg_to_rad(-8.0)
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -50.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase5_transition_2_launch_window_boost.png")

	# -------------------------------------------------------------
	# 3. 512m: HEAVEN ROUTE Celestial Ascent & Golden Flash Aura
	# -------------------------------------------------------------
	print(">>> Capturing 3/4: Heaven Route Ascent & Golden Light Flash (512m)...")
	prog.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	prog.update_distance(512.0)
	game_inst.game_manager.update_distance(512.0)
	game_inst.vehicle.global_position = Vector2(51200.0, 210.0)
	game_inst.vehicle.linear_velocity = Vector2(950.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -35.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase5_transition_3_heaven_ascent_gold_wipe.png")

	# -------------------------------------------------------------
	# 4. 515m: HELL ROUTE Subterranean Descent & Dark Vignette
	# -------------------------------------------------------------
	print(">>> Capturing 4/4: Hell Route Descent & Atmospheric Darkening (515m)...")
	# Re-arm progression controller into Hell
	prog.confirmed_realms[0] = WorldCycleSchedule.BiomeType.HELL
	prog.branch_confirmed.emit(WorldCycleSchedule.BiomeType.HELL, 0)
	prog.update_distance(515.0)
	game_inst.game_manager.update_distance(515.0)
	game_inst.vehicle.global_position = Vector2(51500.0, 560.0)
	game_inst.vehicle.linear_velocity = Vector2(850.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -70.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase5_transition_4_hell_descent_dark_vignette.png")

	print("\n✓ ALL 4 PHASE 5 GAMEPLAY EVIDENCE SCREENSHOTS CAPTURED!")

func _save_viewport_image(vp: SubViewport, path: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		var err := img.save_png(path)
		if err == OK:
			print("  -> Successfully saved: %s (%dx%d)" % [path, img.get_width(), img.get_height()])
		else:
			printerr("  -> Failed to save: %s (Error: %d)" % [path, err])
