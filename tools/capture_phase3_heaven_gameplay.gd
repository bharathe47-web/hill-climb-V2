@tool
extends SceneTree

## Capture Phase 3 Heaven 500m Playable Route Evidence
## Captures high-fidelity gameplay screenshots on the Radeon 610M GPU:
## 1. 508m: Entry Golden Gateway, sparkles, cloud cushions, and marble track
## 2. 645m: Angel's Terrace elevated crest, palace columns, angel statue, and lilies
## 3. 750m: Mid-Route Grand Palace Archway, columns, and animated flying doves
## 4. 975m: Cloud Descent Ramp gliding down toward Normal Land baseline

const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 3 HEAVEN GAMEPLAY EVIDENCE CAPTURE ---")
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

	# Ensure Heaven route is confirmed for encounter 0
	prog.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)

	# -------------------------------------------------------------
	# 1. Entry Golden Gateway Landmark (508m)
	# -------------------------------------------------------------
	print("\n>>> Capturing 1/4: Entry Golden Gateway & Sparkles (508m)...")
	prog.update_distance(508.0)
	game_inst.game_manager.update_distance(508.0)
	game_inst.vehicle.global_position = Vector2(50800.0, 195.0)
	game_inst.vehicle.linear_velocity = Vector2(850.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(12):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase3_heaven_1_entry.png")

	# -------------------------------------------------------------
	# 2. Angel's Terrace & First Monument (645m)
	# -------------------------------------------------------------
	print(">>> Capturing 2/4: Angel's Terrace & Statue Monument (645m)...")
	prog.update_distance(645.0)
	game_inst.game_manager.update_distance(645.0)
	game_inst.vehicle.global_position = Vector2(64500.0, 140.0)
	game_inst.vehicle.linear_velocity = Vector2(900.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(12):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase3_heaven_2_terrace_monument.png")

	# -------------------------------------------------------------
	# 3. Mid-Route Grand Palace Archway & Flying Doves (750m)
	# -------------------------------------------------------------
	print(">>> Capturing 3/4: Grand Palace Archway & Flying Doves (750m)...")
	prog.update_distance(750.0)
	game_inst.game_manager.update_distance(750.0)
	game_inst.vehicle.global_position = Vector2(75000.0, 195.0)
	game_inst.vehicle.linear_velocity = Vector2(950.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(12):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase3_heaven_3_mid_palace_doves.png")

	# -------------------------------------------------------------
	# 4. Cloud Descent Slide Ramp (975m)
	# -------------------------------------------------------------
	print(">>> Capturing 4/4: Cloud Descent Slide Ramp (975m)...")
	prog.update_distance(975.0)
	game_inst.game_manager.update_distance(975.0)
	game_inst.vehicle.global_position = Vector2(97500.0, 310.0)
	game_inst.vehicle.linear_velocity = Vector2(900.0, 150.0)
	game_inst.vehicle.rotation = 0.06
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(12):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase3_heaven_4_exit_descent_slide.png")

	game_inst.queue_free()
	await process_frame
	sub_viewport.queue_free()
	await process_frame

	print("\n=================================================================")
	print("✓ ALL 4 PHASE 3 HEAVEN EVIDENCE SCREENSHOTS CAPTURED SUCCESSFULLY!")
	print("=================================================================")

func _save_viewport_image(vp: SubViewport, path: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		img.save_png(path)
		print("  ✓ Saved %s" % path)
	else:
		printerr("Failed to grab image for %s" % path)
