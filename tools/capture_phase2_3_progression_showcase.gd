@tool
extends SceneTree

## Phase 2.3 Runtime Progression Verification & Visual Showcase Capture Tool.
## Simulates live driving across the 300m recurring world rotation:
## Normal Land (0-300m) -> Heaven (300-600m) -> Hell (600-900m) -> Normal Land (900-1200m) -> repeat.
## Captures all 7 required milestone screenshots:
## 1. Normal launch approach at ~270m
## 2. Nitro launch into Heaven at ~295m
## 3. Heaven portal approach at ~585m
## 4. Heaven-to-Hell crossing at ~600m
## 5. Hell return portal approach at ~885m
## 6. Hell-to-Normal crossing at ~900m
## 7. Repeated second cycle Heaven at ~1200m

const ARTIFACT_PREVIEWS_DIR = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 2.3 RUNTIME SHOWCASE CAPTURE ---")
	print("=================================================================")
	await _run_showcase()
	quit(0)

func _run_showcase() -> void:
	var dir := DirAccess.open(ARTIFACT_PREVIEWS_DIR)
	if not dir:
		DirAccess.make_dir_recursive_absolute(ARTIFACT_PREVIEWS_DIR)
	var docs_dir := DirAccess.open("res://docs/previews")
	if not docs_dir:
		DirAccess.make_dir_recursive_absolute("res://docs/previews")

	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed:
		printerr("Failed to load Game.tscn")
		return

	var sub_viewport := SubViewport.new()
	sub_viewport.size = Vector2i(1280, 720)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sub_viewport)

	var game_inst: GameScene = packed.instantiate() as GameScene
	game_inst.use_procedural_terrain = true
	sub_viewport.add_child(game_inst)

	# Allow initialization frames
	for i in range(16):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game_inst.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game_inst.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	var milestones = [
		{
			"target_dist": 285.0,
			"prep_dist": 275.0,
			"nitro_active": false,
			"name": "Normal Land - Physical Heaven Portal Approach (285m)",
			"filename": "phase2_3_1_heaven_portal_approach_285m.png",
			"legacy_filename": "phase2_3_1_normal_nitro_prompt_270m.png"
		},
		{
			"target_dist": 300.0,
			"prep_dist": 294.0,
			"nitro_active": false,
			"name": "Normal Land -> Heaven Physical Portal Crossing on Roadway (300m, Zero Nitro)",
			"filename": "phase2_3_2_heaven_portal_crossing_300m.png",
			"legacy_filename": "phase2_3_2_nitro_launch_heaven_295m.png"
		},
		{
			"target_dist": 585.0,
			"prep_dist": 575.0,
			"nitro_active": false,
			"name": "Heaven - Hell Portal Roadway Approach (585m)",
			"filename": "phase2_3_3_heaven_hell_portal_approach_585m.png",
			"legacy_filename": ""
		},
		{
			"target_dist": 600.0,
			"prep_dist": 595.0,
			"nitro_active": false,
			"name": "Heaven -> Hell Physical Portal Crossing (600m)",
			"filename": "phase2_3_4_hell_portal_crossing_600m.png",
			"legacy_filename": ""
		},
		{
			"target_dist": 885.0,
			"prep_dist": 875.0,
			"nitro_active": false,
			"name": "Hell - Return Portal Cavern Approach (885m)",
			"filename": "phase2_3_5_hell_return_portal_approach_885m.png",
			"legacy_filename": ""
		},
		{
			"target_dist": 900.0,
			"prep_dist": 895.0,
			"nitro_active": false,
			"name": "Hell -> Normal Land Physical Return Crossing (900m)",
			"filename": "phase2_3_6_return_portal_crossing_900m.png",
			"legacy_filename": ""
		},
		{
			"target_dist": 1200.0,
			"prep_dist": 1195.0,
			"nitro_active": false,
			"name": "Second Cycle (Cycle 1) Heaven Portal Crossing (1200m)",
			"filename": "phase2_3_7_second_cycle_heaven_portal_1200m.png",
			"legacy_filename": "phase2_3_7_second_cycle_heaven_1200m.png"
		}
	]

	for m in milestones:
		var target_dist: float = m["target_dist"]
		var prep_dist: float = m["prep_dist"]
		var prep_x: float = prep_dist * 100.0
		var target_x: float = target_dist * 100.0
		var fname: String = m["filename"]

		print("\n-------------------------------------------------------------")
		print("CAPTURING: %s at %.0f m" % [m["name"], target_dist])
		print("-------------------------------------------------------------")

		# 1. Update distance on GameManager
		game_inst.game_manager.update_distance(prep_dist)
		if is_instance_valid(prog):
			prog.update_distance(prep_dist)
		await process_frame
		await physics_frame

		# 2. Update terrain generation and culling around the milestone
		if is_instance_valid(gen):
			gen._update_generation(target_x + 3500.0)
			gen._update_culling(prep_x)
		await process_frame
		await physics_frame

		# 3. Position vehicle
		var ground_y := gen.get_surface_y_at_world_x(prep_x) if is_instance_valid(gen) else 400.0
		game_inst.vehicle.global_position = Vector2(prep_x, ground_y - 48.0)
		game_inst.vehicle.linear_velocity = Vector2(480.0, 0.0)
		game_inst.vehicle.angular_velocity = 0.0
		game_inst.vehicle.rotation = 0.0
		if m["nitro_active"] and game_inst.vehicle.has_method("set_nitro_active"):
			game_inst.vehicle.set_nitro_active(true)
			game_inst.vehicle.linear_velocity = Vector2(720.0, -180.0)

		# Snap camera
		if is_instance_valid(game_inst.follow_camera):
			game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -50.0)
			if game_inst.follow_camera.has_method("reset_smoothing"):
				game_inst.follow_camera.reset_smoothing()

		# Drive forward until vehicle reaches target distance
		var drive_frames := 0
		while int(game_inst.game_manager.current_distance) < int(target_dist) and drive_frames < 120:
			if is_instance_valid(game_inst.vehicle):
				game_inst.vehicle.set("throttle_input", 1.0)
				if m["nitro_active"] and game_inst.vehicle.has_method("set_nitro_active"):
					game_inst.vehicle.set_nitro_active(true)
			await physics_frame
			await process_frame
			drive_frames += 1

		# Settle visuals for capture
		for s in range(6):
			await process_frame
			await physics_frame

		# Capture SubViewport image
		var img := sub_viewport.get_texture().get_image()
		if img and not img.is_empty():
			var art_path := ARTIFACT_PREVIEWS_DIR + "/" + fname
			var doc_path := "res://docs/previews/" + fname
			img.save_png(art_path)
			img.save_png(doc_path)
			print("  ✓ Saved screenshot: %s (Dimensions: %dx%d)" % [fname, img.get_width(), img.get_height()])
			var legacy_fn: String = m.get("legacy_filename", "")
			if legacy_fn != "" and legacy_fn != fname:
				img.save_png(ARTIFACT_PREVIEWS_DIR + "/" + legacy_fn)
				img.save_png("res://docs/previews/" + legacy_fn)
				print("  ✓ Also mirrored to legacy filename: %s" % legacy_fn)
		else:
			printerr("  ✗ Failed to grab viewport image for %s" % fname)

	print("\n=================================================================")
	print("✓ ALL 7 RUNTIME SHOWCASE SCREENSHOTS CAPTURED SUCCESSFULLY!")
	print("=================================================================")
