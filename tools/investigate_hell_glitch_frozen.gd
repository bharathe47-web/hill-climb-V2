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

	# Freeze all particles to isolate character diffs
	for p in game.find_children("*", "CPUParticles2D", true, false):
		(p as CPUParticles2D).speed_scale = 0.0
	for p in game.find_children("*", "GPUParticles2D", true, false):
		(p as GPUParticles2D).speed_scale = 0.0

	var hell_env: Node = host.hell_environment if host else null
	if not hell_env:
		hell_env = game.find_child("HellEnvironment", true, false)

	# Save frozen baseline
	await process_frame
	_save_vp(vp, "/home/danny/.gemini/antigravity-cli/brain/1729bd5b-8bbd-4078-b9dc-83b6cb99827a/scratch/hell_frozen_baseline.png")

	var targets: Array[String] = [
		"SkeletonKnight",
		"DemonGoblin",
		"HornedFiend",
		"TorchFlameLeft",
		"TorchFlameRight",
		"HeatShimmer"
	]

	for target_name in targets:
		var node := hell_env.find_child(target_name, true, false) as CanvasItem
		if node:
			node.visible = false
			await process_frame
			_save_vp(vp, "/home/danny/.gemini/antigravity-cli/brain/1729bd5b-8bbd-4078-b9dc-83b6cb99827a/scratch/hell_frozen_hide_%s.png" % target_name)
			node.visible = true
			await process_frame

	quit(0)

func _save_vp(vp: SubViewport, path: String) -> void:
	var tex := vp.get_texture()
	if tex:
		var img := tex.get_image()
		if img and not img.is_empty():
			img.save_png(path)
			print("Saved: ", path.get_file())
