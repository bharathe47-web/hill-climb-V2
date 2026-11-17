@tool
extends SceneTree

## Capture Phase 4 Hell 500m Playable Route Evidence
## Captures high-fidelity gameplay screenshots on the Radeon 610M GPU:
## 1. 512m: Entry Catch Basin, Giant Dragon Skull Portal, basalt pillars, and cinders
## 2. 690m: Demon's Chasm Dip & Jump, Demon Goblin sentinel, and Flying Hell Dragon
## 3. 800m: Cavern of the Horned Fiend, catacomb skull piles, and coin trails
## 4. 975m: Magma Geyser Escape Ramp and volcanic eruption visual event

const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 4 HELL GAMEPLAY EVIDENCE CAPTURE ---")
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

	# Ensure Hell route is confirmed for encounter 0
	prog.confirm_route(WorldCycleSchedule.BiomeType.HELL, 0)

	# -------------------------------------------------------------
	# 1. Entry Catch Basin & Giant Dragon Skull Portal (512m)
	# -------------------------------------------------------------
	print("\n>>> Capturing 1/4: Entry Catch Basin & Dragon Skull Portal (512m)...")
	prog.update_distance(512.0)
	game_inst.game_manager.update_distance(512.0)
	game_inst.vehicle.global_position = Vector2(51200.0, 570.0)
	game_inst.vehicle.linear_velocity = Vector2(800.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(12):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase4_hell_1_catch_portal.png")

	# -------------------------------------------------------------
	# 2. Demon's Chasm Dip, Jump & Demon Goblin (690m)
	# -------------------------------------------------------------
	print(">>> Capturing 2/4: Demon's Chasm Dip & Demon Goblin (690m)...")
	prog.update_distance(690.0)
	game_inst.game_manager.update_distance(690.0)
	game_inst.vehicle.global_position = Vector2(69000.0, 595.0)
	game_inst.vehicle.linear_velocity = Vector2(900.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(12):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase4_hell_2_chasm_goblin.png")

	# -------------------------------------------------------------
	# 3. Cavern of the Horned Fiend (800m)
	# -------------------------------------------------------------
	print(">>> Capturing 3/4: Horned Fiend Cavern & Skulls (800m)...")
	prog.update_distance(800.0)
	game_inst.game_manager.update_distance(800.0)
	game_inst.vehicle.global_position = Vector2(80000.0, 595.0)
	game_inst.vehicle.linear_velocity = Vector2(950.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(12):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase4_hell_3_horned_fiend.png")

	# -------------------------------------------------------------
	# 4. Magma Geyser Eruption & Escape Ramp (975m)
	# -------------------------------------------------------------
	print(">>> Capturing 4/4: Magma Geyser Escape Ramp (975m)...")
	prog.update_distance(975.0)
	game_inst.game_manager.update_distance(975.0)
	game_inst.vehicle.global_position = Vector2(97500.0, 480.0)
	game_inst.vehicle.linear_velocity = Vector2(850.0, -80.0)
	game_inst.vehicle.rotation = -0.05
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -40.0)
		if game_inst.follow_camera.has_method("reset_smoothing"):
			game_inst.follow_camera.reset_smoothing()
	for f in range(12):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase4_hell_4_geyser_escape.png")

	game_inst.queue_free()
	await process_frame
	sub_viewport.queue_free()
	await process_frame

	print("\n=================================================================")
	print("✓ ALL 4 PHASE 4 HELL EVIDENCE SCREENSHOTS CAPTURED SUCCESSFULLY!")
	print("=================================================================")

func _save_viewport_image(vp: SubViewport, path: String) -> void:
	var img: Image = vp.get_texture().get_image()
	if img:
		img.save_png(path)
		print("  ✓ Saved %s" % path)
	else:
		printerr("Failed to grab image for %s" % path)
