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
	print("--- INSPECTING TRANSFORMS ---")
	print("cam.zoom = ", cam.zoom)
	print("cam.get_canvas_transform() = ", cam.get_canvas_transform())
	print("layer.get_global_transform_with_canvas() = ", layer.get_global_transform_with_canvas())
	print("layer.get_canvas_transform() = ", layer.get_canvas_transform())
	print("layer.position = ", layer.position)
	print("layer.motion_scale = ", layer.motion_scale)
	print("layer.motion_offset = ", layer.motion_offset)

	var col = layer.get_node_or_null("Column1") as Sprite2D
	print("col.texture.get_size() = ", col.texture.get_size() if col.texture else Vector2.ZERO)
	print("col.offset = ", col.offset)
	print("col.centered = ", col.centered)
	print("col.scale = ", col.scale)
	print("col.position = ", col.position)
	print("col.get_transform() = ", col.get_transform())
	print("col.get_global_transform() = ", col.get_global_transform())
	print("col.get_global_transform_with_canvas() = ", col.get_global_transform_with_canvas())

	quit(0)
