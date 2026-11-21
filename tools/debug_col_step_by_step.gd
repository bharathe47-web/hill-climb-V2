@tool
extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)

	for f in range(20):
		await process_frame
		await physics_frame

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

	for f in range(20):
		await process_frame
		await physics_frame

	var layer = heaven_env.get_node_or_null("MidPalaceArchitectureLayer") as ParallaxLayer
	var cam_xform: Transform2D = cam.get_canvas_transform()
	var cam_scale_y: float = cam_xform.y.y
	var cam_inv: Transform2D = cam_xform.affine_inverse()

	for col_name in ["Column1", "Column2"]:
		var col: Sprite2D = layer.get_node_or_null(col_name) as Sprite2D
		print("\n=== DEBUGGING %s ===" % col_name)
		print("cam_xform = ", cam_xform)
		print("layer.get_global_transform_with_canvas() = ", layer.get_global_transform_with_canvas())
		var col_xform = col.get_global_transform_with_canvas()
		print("col_xform = ", col_xform)
		print("col.position = ", col.position)
		var screen_x = col_xform.origin.x
		var world_pt = cam_inv * Vector2(screen_x, 0.0)
		var r_world_y = gen.get_surface_y_at_world_x(world_pt.x)
		var r_screen_y = (cam_xform * Vector2(world_pt.x, r_world_y)).y
		var vis_h_screen = 936.0 * col.scale.y * cam_scale_y
		var target_origin_y = (r_screen_y + 1.0) - (vis_h_screen * 0.5)
		var layer_origin_y = layer.get_global_transform_with_canvas().origin.y
		var layer_scale_y = layer.get_global_transform_with_canvas().y.y
		var calculated_local_y = (target_origin_y - layer_origin_y) / layer_scale_y

		print("screen_x: ", screen_x)
		print("world_pt.x: ", world_pt.x)
		print("r_world_y: ", r_world_y)
		print("r_screen_y: ", r_screen_y)
		print("vis_h_screen: ", vis_h_screen)
		print("target_origin_y: ", target_origin_y)
		print("layer_origin_y: ", layer_origin_y)
		print("layer_scale_y: ", layer_scale_y)
		print("calculated_local_y: ", calculated_local_y)
		print("actual col.position.y: ", col.position.y)
		var actual_bottom_screen = col_xform.origin.y + (vis_h_screen * 0.5)
		print("actual_bottom_screen: ", actual_bottom_screen)
		print("overlap: ", actual_bottom_screen - r_screen_y)

	quit(0)
