@tool
extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)

	for f in range(15):
		await process_frame

	var host: BiomeEnvironmentHost = game.biome_environment_host
	var heaven_env: HeavenEnvironment = host.heaven_environment as HeavenEnvironment
	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var cam: FollowCamera = game.follow_camera

	var target_dist: float = 452.0
	var world_x: float = float(game.start_x) + (target_dist * 100.0)
	game.game_manager.update_distance(target_dist)
	host.progression_controller.update_distance(target_dist)
	gen._update_generation(world_x + 4000.0)

	var surf_y: float = gen.get_surface_y_at_world_x(world_x)
	cam.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
	cam.reset_smoothing()

	for f in range(15):
		await process_frame

	var layer = heaven_env.get_node_or_null("MidPalaceArchitectureLayer") as ParallaxLayer
	var cam_xform: Transform2D = cam.get_canvas_transform()
	var cam_scale_y: float = cam_xform.y.y
	var cam_inv: Transform2D = cam_xform.affine_inverse()

	print("--- VERIFYING EXACT COLUMN BOTTOM TO ROAD ALIGNMENT ---")
	for col_name in ["Column0", "Column1", "Column2", "Column3"]:
		var col: Sprite2D = layer.get_node_or_null(col_name) as Sprite2D
		if not col:
			continue
		var col_xform: Transform2D = col.get_global_transform_with_canvas()
		var screen_x: float = col_xform.origin.x
		var world_pt: Vector2 = cam_inv * Vector2(screen_x, 0.0)
		var r_world_y: float = gen.get_surface_y_at_world_x(world_pt.x)
		var r_screen_pt: Vector2 = cam_xform * Vector2(world_pt.x, r_world_y)
		var r_screen_y: float = r_screen_pt.y

		# Calculate visible height on screen
		var vis_h_screen: float = 936.0 * col.scale.y * cam_scale_y
		var target_origin_y: float = (r_screen_y + 1.0) - (vis_h_screen * 0.5)
		
		# Layer canvas transform origin.y
		var layer_origin_y: float = layer.get_global_transform_with_canvas().origin.y
		var layer_scale_y: float = layer.get_global_transform_with_canvas().y.y
		
		# Set local position.y
		col.position.y = (target_origin_y - layer_origin_y) / layer_scale_y

	# Settle one frame
	await process_frame

	print("\n--- MEASURED RESULTS AFTER FORMULA ---")
	for col_name in ["Column0", "Column1", "Column2", "Column3"]:
		var col: Sprite2D = layer.get_node_or_null(col_name) as Sprite2D
		if not col:
			continue
		var col_xform: Transform2D = col.get_global_transform_with_canvas()
		var screen_x: float = col_xform.origin.x
		var world_pt: Vector2 = cam_inv * Vector2(screen_x, 0.0)
		var r_world_y: float = gen.get_surface_y_at_world_x(world_pt.x)
		var r_screen_y: float = (cam_xform * Vector2(world_pt.x, r_world_y)).y
		var vis_h_screen: float = 936.0 * col.scale.y * cam_scale_y
		var measured_bottom_y: float = col_xform.origin.y + (vis_h_screen * 0.5)
		var error: float = measured_bottom_y - r_screen_y
		print("[%s] screen_x=%.1f | Road screen Y=%.2f | Column base Y=%.2f | Overlap=%.2f px | Error=%.4f px" % [
			col.name, screen_x, r_screen_y, measured_bottom_y, error, error - 1.0
		])

	quit(0)
