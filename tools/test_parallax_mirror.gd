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
	var layer = heaven_env.get_node_or_null("MidPalaceArchitectureLayer") as ParallaxLayer

	print("layer.motion_scale = ", layer.motion_scale)
	print("layer.motion_mirroring = ", layer.motion_mirroring)
	print("layer.get_viewport().size = ", layer.get_viewport().size)
	print("layer.get_global_transform_with_canvas() = ", layer.get_global_transform_with_canvas())

	quit(0)
