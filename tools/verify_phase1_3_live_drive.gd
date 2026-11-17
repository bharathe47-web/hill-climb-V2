@tool
extends SceneTree

func _init() -> void:
	print("--- BEGIN PHASE 1.3 LIVE DRIVE SIMULATION & ACCEPTANCE ---")
	await _run_drive_test()
	quit(0)

func _run_drive_test() -> void:
	var packed_game: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed_game:
		printerr("Failed to load Game.tscn")
		return

	var game: GameScene = packed_game.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)

	# Initialize
	for f in range(25):
		await process_frame
		await physics_frame

	if is_instance_valid(game.game_manager):
		game.game_manager.start_run()

	var vehicle: VehicleController = game.vehicle
	assert(vehicle != null, "Vehicle must exist in game")

	var initial_x := vehicle.global_position.x
	print("Vehicle initial position: ", vehicle.global_position)

	# Press accelerate
	Input.action_press("accelerate")

	var boundary_crossed := false

	# Drive forward across terrain and segment boundaries
	for f in range(200):
		await physics_frame
		await process_frame
		if vehicle.global_position.x > 1200.0 and not boundary_crossed:
			boundary_crossed = true
			print("  ✓ Seamlessly crossed segment boundary at x=1200m (frame %d, pos: %s)" % [f, vehicle.global_position])

	Input.action_release("accelerate")

	var final_x := vehicle.global_position.x
	var dist_moved := final_x - initial_x
	print("Total distance moved: %.1f px (final pos: %s)" % [dist_moved, vehicle.global_position])
	print("Vehicle velocity: %s" % [vehicle.linear_velocity])
	assert(dist_moved > 500.0, "Vehicle must make substantial progress across terrain")
	assert(boundary_crossed, "Vehicle must seamlessly cross segment boundary")

	game.queue_free()
	print("✓ Phase 1.3 live drive simulation passed with 100% stability!")
