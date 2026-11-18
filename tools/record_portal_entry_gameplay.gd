@tool
extends SceneTree

# record_portal_entry_gameplay.gd
# Records frame-accurate video and screenshots of the Normal Land -> Heaven portal traversal.

func _init() -> void:
	print("=== BEGIN RECORDING PORTAL ENTRY GAMEPLAY ===")
	await _record_portal_entry()
	quit(0)

func _record_portal_entry() -> void:
	var output_dir := "res://docs/previews"
	var brain_dir := "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"

	var packed_game: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed_game:
		printerr("Failed to load Game.tscn")
		return

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var game: GameScene = packed_game.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	# Initial settle
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

	# Start on Normal Land at 980m (approaching the ramp at 988m and gateway at 995m)
	var start_dist := 980.0
	var start_x := start_dist * 100.0

	if prog:
		prog.update_distance(start_dist)
	if game.game_manager:
		game.game_manager.start_run()
		game.game_manager.update_distance(start_dist)
		game.game_manager.coins_collected = 45
		game.game_manager.coins_updated.emit(45)

	if gen:
		gen._update_generation(start_x)

	var surf_y: float = gen.get_surface_y_at_world_x(start_x) if gen else 380.0
	if game.vehicle:
		game.vehicle.reset_vehicle(Vector2(start_x, surf_y - 36.0))
		game.vehicle.linear_velocity = Vector2(450.0, 0.0)

	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = Vector2(start_x, surf_y - 40.0)
		if game.follow_camera.has_method("snap_to_target"):
			game.follow_camera.snap_to_target()

	Input.action_press("accelerate")

	var total_frames := 270 # 9 seconds at 30 FPS
	var approach_captured := false
	var crossing_captured := false

	for step in range(total_frames):
		await physics_frame
		await process_frame

		var cur_x: float = game.vehicle.global_position.x if game.vehicle else start_x + step * 15.0
		var cur_dist := cur_x / 100.0

		if prog:
			prog.update_distance(cur_dist)
		if game.game_manager:
			game.game_manager.update_distance(cur_dist)
		if gen:
			gen._update_generation(cur_x)

		# Capture Screenshot 1: Approach to Golden Gateway (around 990m)
		if not approach_captured and cur_dist >= 988.0:
			approach_captured = true
			var img: Image = vp.get_texture().get_image()
			if img:
				img.save_png(output_dir.path_join("portal_entry_approach.png"))
				img.save_png(brain_dir.path_join("portal_entry_approach.png"))
				print("  ✓ Captured portal_entry_approach.png at %.1fm" % cur_dist)

		# Capture Screenshot 2: Traversing through Golden Gateway Archway (around 995m)
		if not crossing_captured and cur_dist >= 994.0:
			crossing_captured = true
			var img: Image = vp.get_texture().get_image()
			if img:
				img.save_png(output_dir.path_join("portal_entry_crossing.png"))
				img.save_png(brain_dir.path_join("portal_entry_crossing.png"))
				print("  ✓ Captured portal_entry_crossing.png at %.1fm" % cur_dist)

	Input.action_release("accelerate")
	print("✓ Portal entry sequence finished! Traversed to %.1fm" % (game.vehicle.global_position.x / 100.0))
	game.queue_free()
	vp.queue_free()
