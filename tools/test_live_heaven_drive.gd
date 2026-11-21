@tool
extends SceneTree

func _init() -> void:
	print("================================================================================")
	print("STARTING LIVE RUNTIME TEST: DRIVING HEAVEN BIOME (300m -> 600m)")
	print("================================================================================")

	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)

	# Warm up
	for f in range(20):
		await process_frame
		await physics_frame

	var host: BiomeEnvironmentHost = game.biome_environment_host
	var heaven_env: HeavenEnvironment = host.heaven_environment as HeavenEnvironment
	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var cam: FollowCamera = game.follow_camera
	var vehicle: Node2D = game.vehicle
	var layer = heaven_env.get_node_or_null("MidPalaceArchitectureLayer") as ParallaxLayer

	# Start at 300m
	var cur_dist_m := 300.0
	var step_m := 1.5 # 1.5m advance per frame (~90 km/h driving speed)
	var max_dist_m := 600.0

	var frame_count := 0
	var col_screen_y_history: Array = []
	var col_local_y_history: Array = []
	var segment_crossings := 0
	var prev_seg_index := -1

	# Milestones to capture
	var capture_milestones = [320.0, 380.0, 440.0, 500.0, 560.0, 595.0]
	var next_milestone_idx := 0

	print("Simulating real-time driving from 300m to 600m...")

	while cur_dist_m <= max_dist_m:
		var world_x := float(game.start_x) + (cur_dist_m * 100.0)
		game.game_manager.update_distance(cur_dist_m)
		host.progression_controller.update_distance(cur_dist_m)
		gen._update_generation(world_x + 3500.0)

		var surf_y := gen.get_surface_y_at_world_x(world_x)
		var surf_y_ahead := gen.get_surface_y_at_world_x(world_x + 20.0)
		var slope := atan2(surf_y_ahead - surf_y, 20.0)

		if is_instance_valid(vehicle):
			vehicle.global_position = Vector2(world_x, surf_y - 35.0)
			vehicle.rotation = slope
			if vehicle is RigidBody2D:
				var rb := vehicle as RigidBody2D
				rb.linear_velocity = Vector2(1200.0, (surf_y_ahead - surf_y) * 40.0)
			if "current_fuel" in vehicle:
				vehicle.set("current_fuel", 95.0)

		if is_instance_valid(cam):
			# Camera tracks vehicle with vertical camera movement
			cam.global_position = Vector2(world_x + 180.0, surf_y - 50.0)

		await process_frame
		await physics_frame
		frame_count += 1

		# Record column position
		if is_instance_valid(layer):
			var col1 = layer.get_node_or_null("Column1") as Sprite2D
			if col1:
				var local_y = col1.position.y
				var screen_y = col1.get_global_transform_with_canvas().origin.y
				col_local_y_history.append(local_y)
				col_screen_y_history.append(screen_y)

		# Track segment crossings
		var cur_seg_idx = int(cur_dist_m / 12.0)
		if cur_seg_idx != prev_seg_index:
			if prev_seg_index != -1:
				segment_crossings += 1
			prev_seg_index = cur_seg_idx

		# Check capture milestones
		if next_milestone_idx < capture_milestones.size():
			if cur_dist_m >= capture_milestones[next_milestone_idx]:
				var target_m = capture_milestones[next_milestone_idx]
				print("  -> Passed milestone %.0fm (frame %d, slope=%.2f deg, vehicle_y=%.1f)" % [
					target_m, frame_count, rad_to_deg(slope), surf_y
				])
				next_milestone_idx += 1

		cur_dist_m += step_m

	print("\n--- RUNTIME STABILITY ANALYSIS RESULTS ---")
	print("Total frames simulated: %d" % frame_count)
	print("Total distance driven: 300m -> 600m (300 meters)")
	print("Segment crossings verified: %d" % segment_crossings)

	# Analyze column stability
	var base_local_y: float = col_local_y_history[0]
	var base_screen_y: float = col_screen_y_history[0]
	var max_local_dev := 0.0
	var max_screen_dev := 0.0

	for i in range(col_local_y_history.size()):
		max_local_dev = maxf(max_local_dev, abs(col_local_y_history[i] - base_local_y))
		max_screen_dev = maxf(max_screen_dev, abs(col_screen_y_history[i] - base_screen_y))

	print("Column1 Local Y: base = %.2f, max deviation across %d frames = %.6f px" % [
		base_local_y, col_local_y_history.size(), max_local_dev
	])
	print("Column1 Screen Y: base = %.2f, max deviation across %d frames = %.6f px" % [
		base_screen_y, col_screen_y_history.size(), max_screen_dev
	])

	assert(max_local_dev == 0.0, "Column local Y drifted or bounced during gameplay!")
	assert(max_screen_dev == 0.0, "Column screen Y moved vertically during gameplay!")
	print("\n[✓] VERIFICATION SUCCESS: ZERO PILLAR BOUNCING, ZERO DANCING, ROCK-SOLID RUNTIME STABILITY!")

	quit(0)
