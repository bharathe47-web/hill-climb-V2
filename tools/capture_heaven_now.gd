@tool
extends SceneTree

func _init() -> void:
	print("--- BEGIN HEAVEN SCREENSHOT CAPTURE ---")
	await _capture_heaven()
	quit(0)

func _capture_heaven() -> void:
	var output_dir := "res://docs/previews"
	var dir := DirAccess.open(output_dir)
	if not dir:
		DirAccess.make_dir_recursive_absolute(output_dir)

	var packed_game: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed_game:
		printerr("Failed to load Game.tscn")
		return

	# Set up 1280x720 viewport
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var game: GameScene = packed_game.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	# Allow scene tree to settle
	for f in range(20):
		await process_frame
		await physics_frame

	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null
	if not prog:
		prog = game.find_child("BiomeProgressionController", true, false)
	if prog:
		prog.enable_branching_mode(false)

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	if gen and prog:
		gen.bind_progression_controller(prog)

	# 1600m is the prime celestial marble core of Heaven in the 5,150m world schedule
	var dist: float = 1600.0
	var world_x := dist * 100.0

	if host:
		host.apply_biome_state(WorldCycleSchedule.BiomeType.HEAVEN)
	if prog:
		prog.update_distance(dist)
	if game.game_manager:
		game.game_manager.start_run()
		game.game_manager.update_distance(dist)
		game.game_manager.coins_collected = 65
		game.game_manager.coins_updated.emit(65)

	if gen:
		gen._update_generation(world_x)

	var surf_y: float = gen.get_surface_y_at_world_x(world_x) if gen else 380.0
	if game.vehicle:
		game.vehicle.reset_vehicle(Vector2(world_x, surf_y - 36.0))
		game.vehicle.linear_velocity = Vector2(550.0, 0.0)

	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = game.vehicle.global_position + Vector2(160.0, -40.0)
		if game.follow_camera.has_method("snap_to_target"):
			game.follow_camera.snap_to_target()

	if game.hud and game.hud.message_banner:
		game.hud.message_banner.visible = false

	# Let physics and shaders settle
	for f in range(35):
		await physics_frame
		await process_frame

	var img: Image = vp.get_texture().get_image()
	if img:
		var path1 := "res://docs/previews/screenshot_heaven.png"
		var path2 := "res://docs/previews/current_gameplay_heaven.png"
		var brain_path1 := "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews/screenshot_heaven.png"
		var brain_path2 := "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews/current_gameplay_heaven.png"
		
		img.save_png(path1)
		img.save_png(path2)
		img.save_png(brain_path1)
		img.save_png(brain_path2)
		print("  ✓ Saved %s (%dx%d)" % [path1, img.get_width(), img.get_height()])
		print("  ✓ Saved %s (%dx%d)" % [path2, img.get_width(), img.get_height()])
		print("  ✓ Synced to brain previews!")

	game.queue_free()
	vp.queue_free()
	print("✓ Current Heaven screenshot capture completed successfully!")
