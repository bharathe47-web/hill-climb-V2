@tool
class_name CaptureProductionMasterShowcase
extends SceneTree

const ARTIFACT_PREVIEWS_DIR = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"
const DOCS_PREVIEWS_DIR = "res://docs/previews"
const FRAME_DIR = "/tmp/master_walkthrough_frames"

func _init() -> void:
	print("=================================================================")
	print("--- MASTER PRODUCTION CANDIDATE: VISUAL & VIDEO CAPTURE ---")
	print("=================================================================")
	await _run_all()
	quit(0)

func _run_all() -> void:
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

	# =============================================================
	# PART 1: 12 HIGH-RES 1280x720 AUDIT SCREENSHOTS
	# =============================================================
	var shots = [
		{"id": 1, "dist": 100.0, "name": "Normal Land Start (100m)", "filename": "prod_01_normal_land_start_100m.png"},
		{"id": 2, "dist": 298.0, "name": "Heaven Portal Approach (298m)", "filename": "prod_02_heaven_portal_crossing_300m.png"},
		{"id": 3, "dist": 360.0, "name": "Heaven Celestial Palace Corridor (360m)", "filename": "prod_03_heaven_palace_corridor_360m.png"},
		{"id": 4, "dist": 480.0, "name": "Heaven Golden Pedestal & Stained Glass (480m)", "filename": "prod_04_heaven_golden_pedestal_480m.png"},
		{"id": 5, "dist": 602.0, "name": "Hell Portal Entry Crossing (602m)", "filename": "prod_05_hell_portal_entry_600m.png"},
		{"id": 6, "dist": 640.0, "name": "Hell Subterranean Magma Glow & Basalt Ledge (640m)", "filename": "prod_06_hell_subterranean_magma_glow_640m.png"},
		{"id": 7, "dist": 700.0, "name": "Hell Blazing Braziers & Basalt Pillars (700m)", "filename": "prod_07_hell_braziers_and_columns_700m.png"},
		{"id": 8, "dist": 740.0, "name": "Hell Animated Skeleton Knight Sentinel (740m)", "filename": "prod_08_hell_skeleton_knight_sentinel_740m.png"},
		{"id": 9, "dist": 800.0, "name": "Hell Animated Demon Goblin & Magma Vents (800m)", "filename": "prod_09_hell_demon_goblin_and_magma_vents_780m.png"},
		{"id": 10, "dist": 860.0, "name": "Hell Horned Fiend & Obsidian Formations (860m)", "filename": "prod_10_hell_horned_fiend_cavern_860m.png"},
		{"id": 11, "dist": 905.0, "name": "Return Portal to Normal Land (905m)", "filename": "prod_11_hell_return_portal_900m.png"},
		{"id": 12, "dist": 1250.0, "name": "Second Cycle Heaven Continuation (1250m)", "filename": "prod_12_cycle2_progression_1200m.png"}
	]

	print("\n--- CAPTURING 12 PRODUCTION AUDIT SCREENSHOTS ---")
	for s in shots:
		var dist: float = s["dist"]
		var s_name: String = s["name"]
		var fname: String = s["filename"]
		_position_and_sync(game, gen, prog, dist)

		# Allow physics and rendering to stabilize and animate
		for f in range(12):
			await process_frame
			await physics_frame

		var img := vp.get_texture().get_image()
		if img and not img.is_empty():
			var art_path := ARTIFACT_PREVIEWS_DIR + "/" + fname
			var doc_path := DOCS_PREVIEWS_DIR + "/" + fname
			img.save_png(art_path)
			img.save_png(doc_path)
			print("  ✓ Captured: %s -> %s" % [fname, s_name])

	# =============================================================
	# PART 2: 450-FRAME WALKTHROUGH VIDEO CAPTURE (15s @ 30fps)
	# =============================================================
	print("\n--- RECORDING MASTER GAMEPLAY WALKTHROUGH VIDEO ---")
	var dir := DirAccess.open("/tmp")
	if not dir.dir_exists("master_walkthrough_frames"):
		dir.make_dir("master_walkthrough_frames")
	else:
		var fdir := DirAccess.open(FRAME_DIR)
		if fdir:
			fdir.list_dir_begin()
			var fn := fdir.get_next()
			while fn != "":
				if fn.ends_with(".jpg"):
					fdir.remove(fn)
				fn = fdir.get_next()
			fdir.list_dir_end()

	var vehicle: VehicleController = game.vehicle as VehicleController

	var video_segments = [
		{"start_dist": 275.0, "frames": 100, "name": "Normal Land -> Heaven Portal Crossing"},
		{"start_dist": 420.0, "frames": 70, "name": "Heaven Celestial Corridor Traversal"},
		{"start_dist": 575.0, "frames": 100, "name": "Heaven -> Hell Portal Crossing"},
		{"start_dist": 720.0, "frames": 110, "name": "Hell Volcanic Fortress & Character Sentinels"},
		{"start_dist": 880.0, "frames": 70, "name": "Hell -> Normal Land Return Crossing"}
	]

	var global_frame := 0
	for seg in video_segments:
		var s_dist: float = seg["start_dist"]
		var s_x := s_dist * 100.0
		var n_frames: int = seg["frames"]
		print("  >>> Video Segment: %s (Starting at %.0fm, %d frames)..." % [seg["name"], s_dist, n_frames])

		_position_and_sync(game, gen, prog, s_dist)
		var surf_y := gen.get_surface_y_at_world_x(s_x) if gen else 380.0
		if vehicle:
			vehicle.reset_vehicle(Vector2(s_x, surf_y - 42.0))
			vehicle.linear_velocity = Vector2(480.0, 0.0)
			vehicle.angular_velocity = 0.0
			vehicle.rotation = 0.0

		for f in range(n_frames):
			var cur_x: float = vehicle.global_position.x if vehicle else s_x
			var cur_dist_m := (cur_x - game.start_x) / 100.0
			game.game_manager.update_distance(cur_dist_m)
			if is_instance_valid(prog):
				prog.update_distance(cur_dist_m)
			if is_instance_valid(gen):
				gen._update_generation(cur_x + 3500.0)
				gen._update_culling(cur_x)

			if vehicle:
				vehicle.set("throttle_input", 1.0)
				if vehicle.linear_velocity.x < 520.0:
					vehicle.apply_central_force(Vector2(30000.0, 0.0))
				if absf(vehicle.rotation) > 0.15:
					vehicle.angular_velocity = -vehicle.rotation * 4.0

			await physics_frame
			await process_frame

			var img: Image = vp.get_texture().get_image()
			if img:
				var fpath := "%s/frame_%04d.jpg" % [FRAME_DIR, global_frame]
				img.save_jpg(fpath, 0.92)
				global_frame += 1

	print("  ✓ Total %d frames recorded." % global_frame)
	vp.queue_free()

func _position_and_sync(game: GameScene, gen: TerrainGenerator, prog: BiomeProgressionController, dist_m: float) -> void:
	var world_x := game.start_x + (dist_m * 100.0)
	game.game_manager.update_distance(dist_m)
	if is_instance_valid(prog):
		prog.update_distance(dist_m)
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
		v.linear_velocity = Vector2(350.0, 0.0)
		v.angular_velocity = 0.0
		if "current_fuel" in v:
			v.current_fuel = 100.0
	game.game_manager.current_fuel = 100.0
	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
		if game.follow_camera.has_method("reset_smoothing"):
			game.follow_camera.reset_smoothing()
