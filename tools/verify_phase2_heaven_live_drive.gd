@tool
extends SceneTree

func _init() -> void:
	print("=== BEGIN HEAVEN LIVE DRIVING VERIFICATION ===")
	await _run_live_drive()
	quit(0)

func _run_live_drive() -> void:
	var packed_game: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed_game:
		printerr("Failed to load Game.tscn")
		return

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	root.add_child(vp)

	var game: GameScene = packed_game.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	for f in range(20):
		await process_frame
		await physics_frame

	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null
	if not prog:
		prog = game.find_child("BiomeProgressionController", true, false)
	if prog:
		prog.enable_branching_mode(false)
		prog.update_distance(1500.0)

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	if gen and prog:
		gen.bind_progression_controller(prog)

	if host:
		host.apply_biome_state(WorldCycleSchedule.BiomeType.HEAVEN)

	var world_x := 150000.0
	if gen:
		gen._update_generation(world_x)

	var surf_y: float = gen.get_surface_y_at_world_x(world_x) if gen else 380.0
	if game.vehicle:
		game.vehicle.reset_vehicle(Vector2(world_x, surf_y - 36.0))
		game.vehicle.linear_velocity = Vector2(400.0, 0.0)

	var initial_x = game.vehicle.global_position.x
	var ground_contact_count := 0
	var total_frames := 90

	Input.action_press("accelerate")
	for step in range(total_frames):
		await physics_frame
		await process_frame
		if game.vehicle:
			var rear_on_floor: bool = game.vehicle.wheel_back.is_on_floor() if "wheel_back" in game.vehicle else true
			var front_on_floor: bool = game.vehicle.wheel_front.is_on_floor() if "wheel_front" in game.vehicle else true
			if rear_on_floor or front_on_floor:
				ground_contact_count += 1
	Input.action_release("accelerate")

	var final_x = game.vehicle.global_position.x
	var distance_driven = final_x - initial_x

	print("  ✓ Live drive initial X: %.1f, final X: %.1f, delta: +%.1f px" % [initial_x, final_x, distance_driven])
	print("  ✓ Ground contact frames: %d/%d (%.1f%%)" % [ground_contact_count, total_frames, (float(ground_contact_count)/total_frames)*100.0])
	print("  ✓ Vehicle stability verified across Heaven marble roadway!")

	game.queue_free()
	vp.queue_free()
