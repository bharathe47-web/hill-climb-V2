@tool
extends SceneTree

## Capture Phase 2 Branching Graybox Outcomes
## Produces sequential screenshot evidence for both:
## Outcome 1: Successful Nitro launch -> Heaven landing -> Heaven driving -> Normal merge
## Outcome 2: Missed launch -> Safe Hell catch -> Hell driving -> Normal merge

const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 2 BRANCHING EVIDENCE CAPTURE ---")
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

	if prog:
		prog.enable_branching_mode(true)
	if gen and prog:
		gen.bind_progression_controller(prog)

	# -------------------------------------------------------------
	# OUTCOME 1: NITRO LAUNCH -> HEAVEN ROUTE -> MERGE
	# -------------------------------------------------------------
	print("\n>>> CAPTURING OUTCOME 1: NITRO LAUNCH -> HEAVEN ROUTE")

	# 1.1 Nitro Launch off the lip (501m)
	print("Capturing 1.1: Heaven Launch...")
	prog.update_distance(495.0)
	game_inst.game_manager.update_distance(495.0)
	game_inst.vehicle.global_position = Vector2(50150.0, 290.0)
	game_inst.vehicle.linear_velocity = Vector2(1650.0, -420.0)
	game_inst.vehicle.rotation = -0.22
	game_inst.vehicle.set_nitro_active(true)
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(6):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase2_outcome_heaven_1_launch.png")

	# 1.2 Heaven Landing (508m)
	print("Capturing 1.2: Heaven Landing Apron...")
	prog.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	prog.update_distance(508.0)
	game_inst.game_manager.update_distance(508.0)
	game_inst.vehicle.global_position = Vector2(50800.0, 200.0)
	game_inst.vehicle.linear_velocity = Vector2(1100.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(6):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase2_outcome_heaven_2_landing.png")

	# 1.3 Heaven Active Mid-Route Driving (750m)
	print("Capturing 1.3: Heaven Active Mid-Route...")
	prog.update_distance(750.0)
	game_inst.game_manager.update_distance(750.0)
	game_inst.vehicle.global_position = Vector2(75000.0, 195.0)
	game_inst.vehicle.linear_velocity = Vector2(1200.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(6):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase2_outcome_heaven_3_active.png")

	# 1.4 Heaven Exit Ramp Merge back to Normal Land (1,000m)
	print("Capturing 1.4: Heaven Exit Merge...")
	prog.update_distance(1000.0)
	game_inst.game_manager.update_distance(1000.0)
	game_inst.vehicle.global_position = Vector2(100000.0, 420.0)
	game_inst.vehicle.linear_velocity = Vector2(1050.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(6):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase2_outcome_heaven_4_merge.png")

	# -------------------------------------------------------------
	# OUTCOME 2: MISSED LAUNCH -> HELL CATCH BASIN -> MERGE
	# -------------------------------------------------------------
	print("\n>>> CAPTURING OUTCOME 2: MISSED LAUNCH -> HELL ROUTE")
	prog.reset_progression()

	# 2.1 Missed launch dropping past lip (501m)
	print("Capturing 2.1: Missed Launch Descent...")
	prog.update_distance(501.0)
	game_inst.game_manager.update_distance(501.0)
	game_inst.vehicle.global_position = Vector2(50250.0, 410.0)
	game_inst.vehicle.linear_velocity = Vector2(750.0, 320.0)
	game_inst.vehicle.rotation = 0.25
	game_inst.vehicle.set_nitro_active(false)
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(6):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase2_outcome_hell_1_miss.png")

	# 2.2 Hell Catch Basin Landing (512m)
	print("Capturing 2.2: Hell Catch Basin Landing...")
	prog.confirm_route(WorldCycleSchedule.BiomeType.HELL, 0)
	prog.update_distance(512.0)
	game_inst.game_manager.update_distance(512.0)
	game_inst.vehicle.global_position = Vector2(51200.0, 580.0)
	game_inst.vehicle.linear_velocity = Vector2(950.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(6):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase2_outcome_hell_2_catch.png")

	# 2.3 Hell Active Mid-Route Driving (750m)
	print("Capturing 2.3: Hell Active Mid-Route...")
	prog.update_distance(750.0)
	game_inst.game_manager.update_distance(750.0)
	game_inst.vehicle.global_position = Vector2(75000.0, 600.0)
	game_inst.vehicle.linear_velocity = Vector2(1100.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(6):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase2_outcome_hell_3_active.png")

	# 2.4 Hell Geyser Exit Ramp Merge back to Normal Land (1,000m)
	print("Capturing 2.4: Hell Exit Merge...")
	prog.update_distance(1000.0)
	game_inst.game_manager.update_distance(1000.0)
	game_inst.vehicle.global_position = Vector2(100000.0, 420.0)
	game_inst.vehicle.linear_velocity = Vector2(1050.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(6):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase2_outcome_hell_4_merge.png")

	game_inst.queue_free()
	await process_frame
	sub_viewport.queue_free()
	await process_frame

	print("\n=================================================================")
	print("✓ ALL 8 SEQUENTIAL SCREENSHOTS CAPTURED SUCCESSFULLY!")
	print("=================================================================")

func _save_viewport_image(vp: SubViewport, path: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		img.save_png(path)
		print("  ✓ Saved %s" % path)
	else:
		printerr("Failed to grab image for %s" % path)
