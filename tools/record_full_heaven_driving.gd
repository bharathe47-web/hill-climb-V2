@tool
extends SceneTree

# record_full_heaven_driving.gd
# Records frame-accurate video and the five-section screenshots of continuous driving across Heaven.

func _init() -> void:
	print("=== BEGIN RECORDING FULL HEAVEN DRIVING ===")
	await _record_full_heaven()
	quit(0)

func _record_full_heaven() -> void:
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

	for f in range(25):
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

	if host:
		host.apply_biome_state(WorldCycleSchedule.BiomeType.HEAVEN)

	# Start inside Heaven at 1245m
	var start_dist := 1245.0
	var start_x := start_dist * 100.0

	if prog:
		prog.update_distance(start_dist)
	if game.game_manager:
		game.game_manager.start_run()
		game.game_manager.update_distance(start_dist)
		game.game_manager.coins_collected = 75
		game.game_manager.coins_updated.emit(75)

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

	var total_frames := 660 # ~22 seconds of continuous driving across all 5 sections
	var cap_a := false
	var cap_b := false
	var cap_c := false
	var cap_d := false
	var cap_e := false

	for step in range(total_frames):
		await physics_frame
		await process_frame

		if game.vehicle:
			if game.vehicle.linear_velocity.x < 450.0:
				game.vehicle.apply_central_force(Vector2(35000.0, 0.0))
			if absf(game.vehicle.rotation) > 0.12:
				game.vehicle.angular_velocity = -game.vehicle.rotation * 5.0

		var cur_x: float = game.vehicle.global_position.x if game.vehicle else start_x + step * 16.0
		var cur_dist := cur_x / 100.0

		if prog:
			prog.update_distance(cur_dist)
		if game.game_manager:
			game.game_manager.update_distance(cur_dist)
		if gen:
			gen._update_generation(cur_x)

		# Section A: Gateway Arch & Columns (~1255m)
		if not cap_a and cur_dist >= 1255.0:
			cap_a = true
			var img: Image = vp.get_texture().get_image()
			if img:
				img.save_png(output_dir.path_join("heaven_section_a_gateway.png"))
				img.save_png(brain_dir.path_join("heaven_section_a_gateway.png"))
				print("  ✓ Captured heaven_section_a_gateway.png at %.1fm" % cur_dist)

		# Section B: Rose Window & Colonnade Arch (~1276m)
		if not cap_b and cur_dist >= 1276.0:
			cap_b = true
			var img: Image = vp.get_texture().get_image()
			if img:
				img.save_png(output_dir.path_join("heaven_section_b_rose_window.png"))
				img.save_png(brain_dir.path_join("heaven_section_b_rose_window.png"))
				print("  ✓ Captured heaven_section_b_rose_window.png at %.1fm" % cur_dist)

		# Section C: Ceremonial Pedestal Fountain (~1298m)
		if not cap_c and cur_dist >= 1298.0:
			cap_c = true
			var img: Image = vp.get_texture().get_image()
			if img:
				img.save_png(output_dir.path_join("heaven_section_c_fountain.png"))
				img.save_png(brain_dir.path_join("heaven_section_c_fountain.png"))
				print("  ✓ Captured heaven_section_c_fountain.png at %.1fm" % cur_dist)

		# Section D: Grand Celestial Double Door (~1320m)
		if not cap_d and cur_dist >= 1320.0:
			cap_d = true
			var img: Image = vp.get_texture().get_image()
			if img:
				img.save_png(output_dir.path_join("heaven_section_d_grand_door.png"))
				img.save_png(brain_dir.path_join("heaven_section_d_grand_door.png"))
				print("  ✓ Captured heaven_section_d_grand_door.png at %.1fm" % cur_dist)

		# Section E: Angel Monument Terrace & Causeway (~1337m)
		if not cap_e and cur_dist >= 1337.0:
			cap_e = true
			var img: Image = vp.get_texture().get_image()
			if img:
				img.save_png(output_dir.path_join("heaven_section_e_causeway.png"))
				img.save_png(brain_dir.path_join("heaven_section_e_causeway.png"))
				print("  ✓ Captured heaven_section_e_causeway.png at %.1fm" % cur_dist)

	Input.action_release("accelerate")
	print("✓ Full Heaven driving finished! Reached %.1fm" % (game.vehicle.global_position.x / 100.0))
	game.queue_free()
	vp.queue_free()
