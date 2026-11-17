@tool
extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	for i in range(15):
		await process_frame
		await physics_frame

	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null
	if not prog:
		prog = game.find_child("BiomeProgressionController", true, false)
	if prog:
		prog.enable_branching_mode(true)

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	if gen and prog:
		gen.bind_progression_controller(prog)

	prog.confirm_route(WorldCycleSchedule.BiomeType.HELL, 0)
	prog.update_distance(750.0)
	game.game_manager.update_distance(750.0)
	if host:
		host.apply_biome_state(WorldCycleSchedule.BiomeType.HELL)

	if gen:
		gen._update_generation(75000.0)
		for enc in gen.active_encounters:
			if enc.has_method("isolate_route"):
				enc.isolate_route(WorldCycleSchedule.BiomeType.HELL)

	var g_y: float = gen.get_surface_y_at_world_x(75000.0) if gen else 595.0
	game.vehicle.reset_vehicle(Vector2(75000.0, g_y - 36.0))
	game.vehicle.linear_velocity = Vector2(850.0, 0.0)
	game.follow_camera.global_position = game.vehicle.global_position + Vector2(160.0, -35.0)
	if game.follow_camera.has_method("snap_to_target"):
		game.follow_camera.snap_to_target()

	for f in range(25):
		await physics_frame
		await process_frame

	var hell_env: Node = host.hell_environment if host else null
	var skull1: CanvasItem = hell_env.find_child("SkullDecal1", true, false)
	var skull2: CanvasItem = hell_env.find_child("SkullDecal2", true, false)
	var torch_l: CanvasItem = hell_env.find_child("TorchFlameLeft", true, false)
	var torch_r: CanvasItem = hell_env.find_child("TorchFlameRight", true, false)

	if skull1:
		skull1.visible = false
	if skull2:
		skull2.visible = false
	if torch_l:
		torch_l.visible = false
	if torch_r:
		torch_r.visible = false

	await process_frame
	await physics_frame

	var tex := vp.get_texture()
	var img := tex.get_image()
	img.save_png("/home/danny/.gemini/antigravity-cli/brain/1729bd5b-8bbd-4078-b9dc-83b6cb99827a/scratch/hell_no_glitch_test.png")
	print("Saved hell_no_glitch_test.png")

	quit(0)
