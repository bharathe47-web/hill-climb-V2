@tool
class_name CaptureP0HeavenDefectRepairs
extends SceneTree

const ARTIFACT_PREVIEWS_DIR = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"
const DOCS_PREVIEWS_DIR = "res://docs/previews"

func _init() -> void:
	print("=================================================================")
	print("--- CAPTURING P0 HEAVEN DEFECT REPAIR EVIDENCE SCREENSHOTS ---")
	print("=================================================================")
	await _run_captures()
	quit(0)

func _run_captures() -> void:
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
	for f in range(25):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	var shots = [
		{"id": 1, "dist": 300.0, "name": "Heaven Portal Crossing (300m)", "filename": "defect_repair_01_heaven_portal_300m.png"},
		{"id": 2, "dist": 314.0, "name": "Heaven Driving Roadway & Bridge (314m - Authoritative Target)", "filename": "defect_repair_02_heaven_roadway_314m.png"},
		{"id": 3, "dist": 360.0, "name": "Heaven Colonnade & Rose Window (360m)", "filename": "defect_repair_03_heaven_palace_corridor_360m.png"},
		{"id": 4, "dist": 420.0, "name": "Heaven Ceremonial Fountain Plaza (420m)", "filename": "defect_repair_04_heaven_fountain_plaza_420m.png"},
		{"id": 5, "dist": 480.0, "name": "Heaven Grand Palace Entrance Door (480m - Bay 3, No White Box)", "filename": "defect_repair_05_heaven_grand_door_480m.png"},
		{"id": 6, "dist": 540.0, "name": "Heaven Angel Monument Niche (540m - Bay 4, No Black Artifact)", "filename": "defect_repair_06_heaven_angel_monument_540m.png"},
		{"id": 7, "dist": 600.0, "name": "Hell Portal Approach (600m)", "filename": "defect_repair_07_heaven_hell_portal_600m.png"}
	]

	for s in shots:
		var target_dist: float = s["dist"]
		var world_x := game.start_x + (target_dist * 100.0)

		game.game_manager.update_distance(target_dist)
		if is_instance_valid(prog):
			prog.update_distance(target_dist)
		if is_instance_valid(gen):
			gen._update_generation(world_x + 3500.0)
			gen._update_culling(world_x)

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

		for f in range(12):
			await process_frame
			await physics_frame

		var img := vp.get_texture().get_image()
		if img and not img.is_empty():
			var out_artifact := "%s/%s" % [ARTIFACT_PREVIEWS_DIR, s["filename"]]
			var out_docs := "%s/%s" % [DOCS_PREVIEWS_DIR, s["filename"]]
			img.save_png(out_artifact)
			img.save_png(out_docs)
			print("  [✓] Captured %s -> %s" % [s["name"], s["filename"]])
		else:
			printerr("  [✗] Failed to capture image for %s" % s["name"])

	# Part 2: Capture Crash in Heaven & Retry back in Normal Land
	print("\n--- PART 2: TESTING CRASH & RETRY LIFECYCLE ---")
	if is_instance_valid(game.game_manager):
		# Simulate crash while in Heaven at 400m
		game.game_manager.finish_run("Test crash in Heaven")
		for f in range(10):
			await process_frame
			await physics_frame

		# Trigger Retry
		if game.has_method("restart_game"):
			game.restart_game()
		else:
			game.game_manager.restart_run()
		for f in range(30):
			await process_frame
			await physics_frame

		var retry_img := vp.get_texture().get_image()
		if retry_img and not retry_img.is_empty():
			var out_artifact := "%s/defect_repair_08_heaven_crash_retry_normal.png" % ARTIFACT_PREVIEWS_DIR
			var out_docs := "%s/defect_repair_08_heaven_crash_retry_normal.png" % DOCS_PREVIEWS_DIR
			retry_img.save_png(out_artifact)
			retry_img.save_png(out_docs)
			print("  [✓] Captured Heaven Crash & Retry -> defect_repair_08_heaven_crash_retry_normal.png")

	vp.queue_free()
	print("\n=================================================================")
	print("--- P0 EVIDENCE CAPTURE COMPLETED SUCCESSFULLY ---")
	print("=================================================================")
