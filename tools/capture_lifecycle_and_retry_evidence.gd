@tool
class_name CaptureLifecycleAndRetryEvidence
extends SceneTree

const ARTIFACT_PREVIEWS_DIR = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"
const DOCS_PREVIEWS_DIR = "res://docs/previews"

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN 12-SHOT LIFECYCLE & RETRY EVIDENCE CAPTURE ---")
	print("=================================================================")
	await _capture_all()
	quit(0)

func _capture_all() -> void:
	DirAccess.make_dir_recursive_absolute(ARTIFACT_PREVIEWS_DIR)
	DirAccess.make_dir_recursive_absolute(DOCS_PREVIEWS_DIR)

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
	for f in range(24):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")

	var shots = [
		{"id": 1, "name": "Normal Land immediately before 300m (295m)", "filename": "lifecycle_01_normal_before_300m.png"},
		{"id": 2, "name": "Exact Heaven portal crossing (300m)", "filename": "lifecycle_02_heaven_portal_crossing_300m.png"},
		{"id": 3, "name": "First frame after entering Heaven (302m)", "filename": "lifecycle_03_heaven_entry_first_frame.png"},
		{"id": 4, "name": "100m inside Heaven with zero Normal assets (400m)", "filename": "lifecycle_04_heaven_100m_no_normal_assets.png"},
		{"id": 5, "name": "Heaven immediately before 600m (595m)", "filename": "lifecycle_05_heaven_before_600m.png"},
		{"id": 6, "name": "Hell immediately after 600m (605m)", "filename": "lifecycle_06_hell_crossing_605m.png"},
		{"id": 7, "name": "Normal Land immediately after 900m (905m)", "filename": "lifecycle_07_normal_return_crossing_905m.png"},
		{"id": 8, "name": "Crash inside Heaven (450m)", "filename": "lifecycle_08_heaven_crash_450m.png"},
		{"id": 9, "name": "Retry loading frame (0m restart transaction)", "filename": "lifecycle_09_retry_transaction_frame.png"},
		{"id": 10, "name": "Fresh Normal Land at 0m after Heaven retry", "filename": "lifecycle_10_fresh_normal_land_after_retry_0m.png"},
		{"id": 11, "name": "Normal Land at 100m after Heaven retry", "filename": "lifecycle_11_normal_land_after_retry_100m.png"},
		{"id": 12, "name": "Fresh Normal Land at 0m after Hell retry", "filename": "lifecycle_12_fresh_normal_land_after_hell_retry_0m.png"}
	]

	for s in shots:
		var s_id: int = s["id"]
		var s_name: String = s["name"]
		var fname: String = s["filename"]
		print("\n>>> Setting up Shot %d: %s..." % [s_id, s_name])
		await _setup_shot(s_id, game, gen)
		for f in range(6):
			await process_frame
			await physics_frame

		var img := vp.get_texture().get_image()
		if img and not img.is_empty():
			var art_path := ARTIFACT_PREVIEWS_DIR + "/" + fname
			var doc_path := DOCS_PREVIEWS_DIR + "/" + fname
			img.save_png(art_path)
			img.save_png(doc_path)
			print("  ✓ Saved: %s (Dimensions: %dx%d)" % [fname, img.get_width(), img.get_height()])
		else:
			printerr("  ✗ Failed to capture shot %d" % s_id)

	print("\n=================================================================")
	print("✓ ALL 12 LIFECYCLE & RETRY EVIDENCE SCREENSHOTS CAPTURED!")
	print("=================================================================")
	vp.queue_free()

func _setup_shot(shot_id: int, game: GameScene, gen: TerrainGenerator) -> void:
	match shot_id:
		1:
			game.execute_restart_transaction()
			await process_frame
			_position_vehicle(game, gen, 295.0)
		2:
			_position_vehicle(game, gen, 300.0)
		3:
			_position_vehicle(game, gen, 302.0)
		4:
			_position_vehicle(game, gen, 400.0)
		5:
			_position_vehicle(game, gen, 595.0)
		6:
			_position_vehicle(game, gen, 605.0)
		7:
			_position_vehicle(game, gen, 905.0)
		8:
			_position_vehicle(game, gen, 450.0)
			game.game_manager.finish_run("crashed")
			if is_instance_valid(game.results_screen):
				game.results_screen.visible = true
		9:
			game.game_manager.restart_run()
			await process_frame
		10:
			_position_vehicle(game, gen, 0.0)
		11:
			_position_vehicle(game, gen, 100.0)
		12:
			_position_vehicle(game, gen, 750.0)
			await process_frame
			game.game_manager.finish_run("crashed")
			await process_frame
			game.game_manager.restart_run()
			await process_frame
			_position_vehicle(game, gen, 0.0)

func _position_vehicle(game: GameScene, gen: TerrainGenerator, dist_m: float) -> void:
	var world_x := game.start_x + (dist_m * 100.0)
	game.game_manager.update_distance(dist_m)
	var host: BiomeEnvironmentHost = game.biome_environment_host
	if is_instance_valid(host) and is_instance_valid(host.progression_controller):
		host.progression_controller.update_distance(dist_m)
	if is_instance_valid(gen):
		gen._update_generation(world_x + 3500.0)
		gen._update_culling(world_x)

	var surf_y := gen.get_surface_y_at_world_x(world_x) if is_instance_valid(gen) else 380.0
	if is_instance_valid(game.vehicle):
		var v := game.vehicle
		v.global_position = Vector2(world_x, surf_y - 42.0)
		v.rotation = 0.0
		v.linear_velocity = Vector2(300.0, 0.0)
		v.angular_velocity = 0.0
		if "current_fuel" in v:
			v.current_fuel = 100.0
	game.game_manager.current_fuel = 100.0
	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
		if game.follow_camera.has_method("reset_smoothing"):
			game.follow_camera.reset_smoothing()
