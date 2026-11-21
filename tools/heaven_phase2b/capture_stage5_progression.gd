@tool
class_name CaptureStage5Progression
extends SceneTree

const OUT_DIR = "res://docs/heaven_phase2b/qa_screenshots"

func _init() -> void:
	print("--- CAPTURING STAGE 5 FULL PROGRESSION (9 SCREENSHOTS) ---")
	await _run_captures()
	quit(0)

func _run_captures() -> void:
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

	var shots = [
		{"dist": 299.0, "file": "qa_01_299m_normal_land_portal.png", "label": "Normal Land (299m)"},
		{"dist": 314.0, "file": "qa_02_314m_heaven_entry.png", "label": "Heaven Entry (314m)"},
		{"dist": 360.0, "file": "qa_03_360m_heaven_colonnade.png", "label": "Heaven Colonnade (360m)"},
		{"dist": 420.0, "file": "qa_04_420m_heaven_fountain_plaza.png", "label": "Heaven Garden/Plaza (420m)"},
		{"dist": 452.0, "file": "qa_05_452m_heaven_reference_match.png", "label": "Heaven Reference Match (452m)"},
		{"dist": 480.0, "file": "qa_06_480m_heaven_grand_door.png", "label": "Heaven Colonnade Arch (480m)"},
		{"dist": 540.0, "file": "qa_07_540m_heaven_angel_monument.png", "label": "Heaven Angel Monument (540m)"},
		{"dist": 590.0, "file": "qa_08_590m_heaven_exit_approach.png", "label": "Heaven Exit Approach (590m)"},
		{"dist": 600.0, "file": "qa_09_600m_hell_portal_entry.png", "label": "Hell Portal Entry (600m)"}
	]

	var fps_samples: Array[float] = []

	for s in shots:
		var target_dist: float = s["dist"]
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
			v.linear_velocity = Vector2.ZERO
			v.angular_velocity = 0.0

		if is_instance_valid(game.follow_camera):
			game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
			if game.follow_camera.has_method("reset_smoothing"):
				game.follow_camera.reset_smoothing()

		# Settle frames for terrain, particles and environment
		for f in range(25):
			await process_frame
			await physics_frame

		var current_fps := Engine.get_frames_per_second()
		fps_samples.append(current_fps)

		var img: Image = vp.get_texture().get_image()
		if img and not img.is_empty():
			var out_file = OUT_DIR + "/" + s["file"]
			var abs_path = ProjectSettings.globalize_path(out_file)
			img.save_png(abs_path)
			print("Saved: %s (%s, %dx%d, FPS: %d)" % [s["file"], s["label"], img.get_width(), img.get_height(), current_fps])
		else:
			printerr("Failed to grab image for: " + s["file"])

	print("Stage 5 captures completed. Total screenshots: %d" % shots.size())
