@tool
extends SceneTree

func _init() -> void:
	print("================================================================================")
	print("TESTING PILLAR RUNTIME STABILITY (VERIFYING ZERO VERTICAL MOVEMENT / JITTER)")
	print("================================================================================")
	
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)

	# Initial warm up
	for f in range(25):
		await process_frame
		await physics_frame

	var host: BiomeEnvironmentHost = game.biome_environment_host
	var heaven_env: HeavenEnvironment = host.heaven_environment as HeavenEnvironment
	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var cam: FollowCamera = game.follow_camera
	var layer = heaven_env.get_node_or_null("MidPalaceArchitectureLayer") as ParallaxLayer

	# Test across active driving simulation from 350m to 550m
	var distances = [360.0, 400.0, 452.0, 500.0, 540.0, 580.0]
	var recorded_local_y: Dictionary = {}
	var recorded_screen_y: Dictionary = {}

	for dist_m in distances:
		var dist_val: float = float(dist_m)
		var world_x: float = float(game.start_x) + (dist_val * 100.0)

		game.game_manager.update_distance(dist_val)
		host.progression_controller.update_distance(dist_val)
		gen._update_generation(world_x + 4000.0)

		var surf_y: float = gen.get_surface_y_at_world_x(world_x)
		if is_instance_valid(game.vehicle):
			game.vehicle.global_position = Vector2(world_x, surf_y - 40.0)
		cam.global_position = Vector2(world_x + 180.0, surf_y - 50.0)

		# Simulate 10 frames of driving with physics and process
		var y_samples: Array = []
		for f in range(10):
			await process_frame
			await physics_frame
			var col1 = layer.get_node_or_null("Column1") as Sprite2D
			if col1:
				y_samples.append({
					"frame": f,
					"local_y": col1.position.y,
					"global_screen_y": col1.get_global_transform_with_canvas().origin.y
				})

		# Check stability across frames
		var first_sample = y_samples[0]
		var max_local_diff := 0.0
		var max_screen_diff := 0.0
		for s in y_samples:
			max_local_diff = maxf(max_local_diff, abs(s.local_y - first_sample.local_y))
			max_screen_diff = maxf(max_screen_diff, abs(s.global_screen_y - first_sample.global_screen_y))

		print("Distance %.1fm: Column1 local_y = %.2f (delta across 10 frames: %.6f px) | screen_y = %.2f (delta: %.6f px)" % [
			dist_m, first_sample.local_y, max_local_diff, first_sample.global_screen_y, max_screen_diff
		])

		assert(max_local_diff == 0.0, "Column1 local position.y moved during gameplay!")
		assert(max_screen_diff == 0.0, "Column1 screen_y moved vertically during gameplay!")

	print("\n[✓] PERFECT STABILITY CONFIRMED: Column position is 100% static across all frames and distances!")
	quit(0)
