@tool
extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)

	for f in range(25):
		await process_frame
		await physics_frame

	var host: BiomeEnvironmentHost = game.biome_environment_host
	var heaven_env: HeavenEnvironment = host.heaven_environment as HeavenEnvironment
	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var cam: FollowCamera = game.follow_camera
	var layer = heaven_env.get_node_or_null("MidPalaceArchitectureLayer") as ParallaxLayer

	var checkpoints = [452.0, 512.0, 540.0, 569.0, 590.0]

	print("================================================================================")
	print("AUDITING COLUMN BASES AND ROAD ELEVATION ACROSS ALL CHECKPOINTS")
	print("================================================================================")

	for dist_m in checkpoints:
		var dist_val: float = float(dist_m)
		var world_x: float = float(game.start_x) + (dist_val * 100.0)

		game.game_manager.update_distance(dist_val)
		host.progression_controller.update_distance(dist_val)
		gen._update_generation(world_x + 4000.0)

		var surf_y: float = gen.get_surface_y_at_world_x(world_x)
		if is_instance_valid(game.vehicle):
			game.vehicle.global_position = Vector2(world_x, surf_y - 40.0)
		cam.global_position = Vector2(world_x + 180.0, surf_y - 50.0)

		for f in range(15):
			await process_frame
			await physics_frame

		var cam_xform: Transform2D = cam.get_canvas_transform()
		var cam_scale_y: float = cam_xform.y.y
		var cam_inv: Transform2D = cam_xform.affine_inverse()

		print("\n--- CHECKPOINT %.0fm (world_x = %.1f) ---" % [dist_m, world_x])
		for col_name in ["Column0", "Column1", "Column2", "Column3"]:
			var col: Sprite2D = layer.get_node_or_null(col_name) as Sprite2D
			if not col:
				continue
			var col_xform: Transform2D = col.get_global_transform_with_canvas()
			var screen_x: float = col_xform.origin.x
			var is_visible_on_screen: bool = (screen_x >= -50.0 and screen_x <= 1330.0)

			var world_pt: Vector2 = cam_inv * Vector2(screen_x, 0.0)
			var r_world_y: float = gen.get_surface_y_at_world_x(world_pt.x)
			var r_screen_y: float = (cam_xform * Vector2(world_pt.x, r_world_y)).y
			var vis_h_screen: float = 936.0 * col.scale.y * cam_scale_y
			var measured_bottom_y: float = col_xform.origin.y + (vis_h_screen * 0.5)
			var overlap: float = measured_bottom_y - r_screen_y

			print("  [%s] screen_x=%7.1f | on_screen=%5s | road_y=%6.2f | base_y=%6.2f | overlap=%5.2f px" % [
				col_name, screen_x, str(is_visible_on_screen), r_screen_y, measured_bottom_y, overlap
			])

	quit(0)
