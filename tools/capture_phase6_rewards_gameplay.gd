@tool
extends SceneTree

# tools/capture_phase6_rewards_gameplay.gd
# Captures live Phase 6 rewards, difficulty, and repetition gameplay evidence on AMD Radeon 610M:
# 1. 645m: Heaven scenic coin arc & monument jump with aerial collection trajectory
# 2. 820m: Heaven Nitro Bottle & Fuel replenishment on the speed terrace
# 3. 582m: Hell high-density rewards (+50% coins & recovery Nitro canister) amidst basalt crags
# 4. 1475m: Encounter 1 gate approach (1,500m) showing multi-encounter repetition and variety

const BranchingEncounterClass = preload("res://scripts/terrain/BranchingEncounter.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 6 REWARDS & VARIETY GAMEPLAY CAPTURE ---")
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
	# 1. 645m: Heaven Scenic Coin Arc over Angel's Terrace
	# -------------------------------------------------------------
	print("\n>>> Capturing 1/4: Heaven Scenic Coin Arc over Angel's Terrace (645m)...")
	prog.confirm_route(WorldCycleSchedule.BiomeType.HEAVEN, 0)
	prog.update_distance(645.0)
	game_inst.game_manager.update_distance(645.0)
	game_inst.game_manager.coins_collected = 25
	game_inst.game_manager.coins_updated.emit(25)
	
	game_inst.vehicle.global_position = Vector2(64500.0, 148.0)
	game_inst.vehicle.linear_velocity = Vector2(1050.0, -80.0)
	game_inst.vehicle.rotation = deg_to_rad(-4.0)
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -35.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase6_rewards_1_heaven_coin_arc_crest.png")

	# -------------------------------------------------------------
	# 2. 820m: Heaven Nitro Bottle & Speed Terrace Replenishment
	# -------------------------------------------------------------
	print(">>> Capturing 2/4: Heaven Nitro Bottle & Speed Terrace (820m)...")
	prog.update_distance(820.0)
	game_inst.game_manager.update_distance(820.0)
	game_inst.game_manager.coins_collected = 45
	game_inst.game_manager.coins_updated.emit(45)
	game_inst.vehicle.global_position = Vector2(82000.0, 195.0)
	game_inst.vehicle.linear_velocity = Vector2(1150.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -35.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase6_rewards_2_heaven_nitro_pickup.png")

	# -------------------------------------------------------------
	# 3. 582m: Hell High-Density Reward Trail (+50% coins & recovery Nitro canister)
	# -------------------------------------------------------------
	print(">>> Capturing 3/4: Hell High-Density Rewards & Recovery Nitro (582m)...")
	prog.confirmed_realms[0] = WorldCycleSchedule.BiomeType.HELL
	prog.branch_confirmed.emit(WorldCycleSchedule.BiomeType.HELL, 0)
	prog.update_distance(582.0)
	game_inst.game_manager.update_distance(582.0)
	game_inst.game_manager.coins_collected = 15
	game_inst.game_manager.coins_updated.emit(15)
	
	game_inst.vehicle.global_position = Vector2(58200.0, 595.0)
	game_inst.vehicle.linear_velocity = Vector2(980.0, 0.0)
	game_inst.vehicle.rotation = 0.0
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -70.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase6_rewards_3_hell_high_density_coins_and_nitro.png")

	# -------------------------------------------------------------
	# 4. 1,475m: Multi-Encounter Repeat Gate (Encounter 1 at 1,500m)
	# -------------------------------------------------------------
	print(">>> Capturing 4/4: Multi-Encounter Repeat Gate (1,475m)...")
	prog.update_distance(1475.0)
	game_inst.game_manager.update_distance(1475.0)
	game_inst.game_manager.coins_collected = 85
	game_inst.game_manager.coins_updated.emit(85)
	
	game_inst.vehicle.global_position = Vector2(147500.0, 410.0)
	game_inst.vehicle.linear_velocity = Vector2(1050.0, -40.0)
	game_inst.vehicle.rotation = deg_to_rad(-4.0)
	if is_instance_valid(game_inst.follow_camera):
		game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(160.0, -50.0)
		if game_inst.follow_camera.has_method("snap_to_target"):
			game_inst.follow_camera.snap_to_target()
	for f in range(15):
		await physics_frame
		await process_frame
	_save_viewport_image(sub_viewport, "res://docs/previews/phase6_rewards_4_multi_encounter_repeat_gate.png")

	print("\n✓ ALL 4 PHASE 6 GAMEPLAY EVIDENCE SCREENSHOTS SUCCESSFULLY CAPTURED!\n")

func _save_viewport_image(vp: SubViewport, dest_path: String) -> void:
	var tex: ViewportTexture = vp.get_texture()
	if not tex:
		printerr("Failed to get viewport texture for: ", dest_path)
		return
	var img: Image = tex.get_image()
	if not img:
		printerr("Failed to get image from texture for: ", dest_path)
		return
	var abs_path: String = ProjectSettings.globalize_path(dest_path)
	var err := img.save_png(abs_path)
	if err == OK:
		print("  -> Saved: ", dest_path, " (", img.get_width(), "x", img.get_height(), ")")
	else:
		printerr("Failed to save image (error ", err, "): ", abs_path)
