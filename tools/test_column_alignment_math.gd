@tool
extends SceneTree

func _init() -> void:
	print("--- TESTING COLUMN TO ROAD ALIGNMENT TRANSFORMATION ---")
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)

	for f in range(10):
		await process_frame

	var host: BiomeEnvironmentHost = game.biome_environment_host
	var heaven_env: HeavenEnvironment = host.heaven_environment as HeavenEnvironment
	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var cam: FollowCamera = game.follow_camera

	# Fast forward to 452m
	var target_dist: float = 452.0
	var world_x: float = float(game.start_x) + (target_dist * 100.0)
	game.game_manager.update_distance(target_dist)
	host.progression_controller.update_distance(target_dist)
	gen._update_generation(world_x + 4000.0)

	var surf_y: float = gen.get_surface_y_at_world_x(world_x)
	cam.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
	cam.reset_smoothing()

	for f in range(5):
		await process_frame

	var layer = heaven_env.get_node_or_null("MidPalaceArchitectureLayer")
	print("MidPalaceArchitectureLayer: ", layer)
	var col2 = layer.get_node_or_null("Column2") as Sprite2D
	var col3 = layer.get_node_or_null("Column3") as Sprite2D

	for col in [col2, col3]:
		if not col:
			continue
		var col_screen_origin: Vector2 = col.get_global_transform_with_canvas().origin
		var world_pt: Vector2 = cam.get_canvas_transform().affine_inverse() * col_screen_origin
		var r_world_y: float = gen.get_surface_y_at_world_x(world_pt.x)
		var r_screen_pt: Vector2 = cam.get_canvas_transform() * Vector2(world_pt.x, r_world_y)

		print("[%s] at screen x=%.1f, world x=%.1f" % [col.name, col_screen_origin.x, world_pt.x])
		print("  Current col screen Y = %.1f" % col_screen_origin.y)
		print("  Road surface screen Y = %.1f" % r_screen_pt.y)
		print("  Initial Gap = %.1f pixels" % (r_screen_pt.y - col_screen_origin.y))

		# Apply dynamic alignment
		# Configure offset to bottom-center of artwork
		col.offset = Vector2(0.0, -468.0)
		var target_screen_pos := Vector2(col_screen_origin.x, r_screen_pt.y + 1.5)
		var desired_local: Vector2 = layer.get_global_transform_with_canvas().affine_inverse() * target_screen_pos
		col.position.y = desired_local.y

	# Settle one frame
	await process_frame

	print("\n--- AFTER DYNAMIC ALIGNMENT ---")
	for col in [col2, col3]:
		if not col:
			continue
		var col_screen_origin: Vector2 = col.get_global_transform_with_canvas().origin
		var world_pt: Vector2 = cam.get_canvas_transform().affine_inverse() * col_screen_origin
		var r_world_y: float = gen.get_surface_y_at_world_x(world_pt.x)
		var r_screen_pt: Vector2 = cam.get_canvas_transform() * Vector2(world_pt.x, r_world_y)
		var actual_gap: float = r_screen_pt.y - col_screen_origin.y
		print("[%s] New col screen Y = %.2f | Road screen Y = %.2f | Visual Overlap = %.2f px" % [
			col.name, col_screen_origin.y, r_screen_pt.y, -actual_gap
		])

	quit(0)
