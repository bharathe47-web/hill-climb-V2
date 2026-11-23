@tool
class_name CaptureStage2Checkpoint
extends SceneTree

const OUT_DIR = "res://docs/heaven_phase2b/checkpoints"

func _init() -> void:
	print("--- CAPTURING STAGE 2 CHECKPOINT (452m) ---")
	await _run_capture()
	quit(0)

func _run_capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed:
		printerr("Failed to load Game.tscn")
		return

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	# Initial warm-up frames
	for f in range(25):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	var target_dist: float = 452.0
	var world_x := game.start_x + (target_dist * 100.0)

	game.game_manager.update_distance(target_dist)
	if is_instance_valid(prog):
		prog.update_distance(target_dist)
	if is_instance_valid(gen):
		gen._update_generation(world_x + 3500.0)

	var surf_y := gen.get_surface_y_at_world_x(world_x) if is_instance_valid(gen) else 380.0
	if is_instance_valid(game.vehicle):
		var v := game.vehicle
		v.global_position = Vector2(world_x, surf_y - 42.0)
		v.rotation = 0.0
		v.linear_velocity = Vector2(0.0, 0.0)
		v.angular_velocity = 0.0

	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
		if game.follow_camera.has_method("reset_smoothing"):
			game.follow_camera.reset_smoothing()

	# Settle frames for terrain, particles and environment
	for f in range(20):
		await process_frame
		await physics_frame

	var img: Image = vp.get_texture().get_image()
	if img and not img.is_empty():
		var out_file = OUT_DIR + "/02_marble_viaduct_452m.png"
		var abs_path = ProjectSettings.globalize_path(out_file)
		img.save_png(abs_path)
		print("Saved checkpoint: %s (%dx%d)" % [out_file, img.get_width(), img.get_height()])
	else:
		printerr("Failed to grab image for checkpoint 02")
