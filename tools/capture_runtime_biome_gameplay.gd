@tool
extends SceneTree

## Comprehensive runtime biome visual verification and capture tool
## Measures live telemetry, HUD distance, active biomes, and saves 4 gameplay screenshots.

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN BIOME RUNTIME VISUAL VERIFICATION & CAPTURE ---")
	print("=================================================================")
	await _run_capture()
	quit(0)

func _run_capture() -> void:
	var dir := DirAccess.open("res://docs/previews")
	if not dir:
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
	for i in range(12):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game_inst.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game_inst.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	var milestones = [
		{
			"target_dist": 500.0,
			"prep_dist": 496.0,
			"expected_biome": WorldCycleSchedule.BiomeType.NORMAL_LAND,
			"name": "Normal Land (Countryside Start)",
			"file_main": "res://docs/previews/gameplay_500m_normal_land.png",
			"file_compat": "res://docs/previews/gameplay_normal_land_driving.png"
		},
		{
			"target_dist": 1500.0,
			"prep_dist": 1496.0,
			"expected_biome": WorldCycleSchedule.BiomeType.HEAVEN,
			"name": "Heaven (Celestial Palace)",
			"file_main": "res://docs/previews/gameplay_1500m_heaven.png",
			"file_compat": "res://docs/previews/gameplay_heaven_driving.png"
		},
		{
			"target_dist": 2800.0,
			"prep_dist": 2796.0,
			"expected_biome": WorldCycleSchedule.BiomeType.NORMAL_LAND,
			"name": "Normal Land (Expert Undulations)",
			"file_main": "res://docs/previews/gameplay_2800m_normal_land_expert.png",
			"file_compat": "res://docs/previews/gameplay_hills_scenery.png"
		},
		{
			"target_dist": 4200.0,
			"prep_dist": 4196.0,
			"expected_biome": WorldCycleSchedule.BiomeType.HELL,
			"name": "Hell (Basalt Caverns & Magma)",
			"file_main": "res://docs/previews/gameplay_4200m_hell.png",
			"file_compat": "res://docs/previews/gameplay_hell_driving.png"
		}
	]

	var verification_results: Array[Dictionary] = []

	for m in milestones:
		var target_dist: float = m["target_dist"]
		var prep_dist: float = m["prep_dist"]
		var prep_x: float = prep_dist * 100.0
		var target_x: float = target_dist * 100.0

		print("\n-------------------------------------------------------------")
		print("MILESTONE: %s at %.0f m" % [m["name"], target_dist])
		print("-------------------------------------------------------------")

		# 1. Update distance on GameManager to trigger authoritative progression
		game_inst.game_manager.update_distance(prep_dist)
		await process_frame
		await physics_frame

		# 2. Generate terrain segments ahead with active biome profile
		gen._update_generation(prep_x + 3500.0)
		gen._update_culling(prep_x)
		await process_frame
		await physics_frame

		# 3. Position vehicle cleanly onto terrain surface
		var ground_y := gen.get_surface_y_at_world_x(prep_x)
		game_inst.vehicle.global_position = Vector2(prep_x, ground_y - 48.0)
		game_inst.vehicle.linear_velocity = Vector2(350.0, 0.0)
		game_inst.vehicle.angular_velocity = 0.0
		game_inst.vehicle.rotation = 0.0

		# Snap camera to vehicle
		if is_instance_valid(game_inst.follow_camera):
			game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(180.0, -50.0)
			if game_inst.follow_camera.has_method("reset_smoothing"):
				game_inst.follow_camera.reset_smoothing()

		# 4. Drive under live physics until vehicle reaches target distance
		var drive_frames := 0
		while int(game_inst.game_manager.current_distance) < int(target_dist) and drive_frames < 300:
			if is_instance_valid(game_inst.vehicle):
				game_inst.vehicle.set("throttle_input", 1.0)
			await physics_frame
			await process_frame
			drive_frames += 1

		# Give 3 frames for render settle
		for f in range(3):
			if is_instance_valid(game_inst.vehicle):
				game_inst.vehicle.set("throttle_input", 0.5)
			await physics_frame
			await process_frame

		# 5. Extract verification telemetry
		var current_dist: float = game_inst.game_manager.current_distance
		var hud_text: String = ""
		if is_instance_valid(game_inst.hud) and "distance_label" in game_inst.hud and is_instance_valid(game_inst.hud.distance_label):
			hud_text = game_inst.hud.distance_label.text

		var active_biome_id: int = host.current_biome if is_instance_valid(host) else -1
		var active_biome_name: String = ""
		match active_biome_id:
			0: active_biome_name = "NORMAL_LAND"
			1: active_biome_name = "HEAVEN"
			2: active_biome_name = "HELL"
			_: active_biome_name = "UNKNOWN"

		var active_profile: String = gen.active_terrain_profile.get("profile_name") if (gen and gen.active_terrain_profile) else "None"
		var normal_vis: bool = host.normal_environment.visible if (host and host.normal_environment) else false
		var heaven_vis: bool = host.heaven_environment.visible if (host and host.heaven_environment) else false
		var hell_vis: bool = host.hell_environment.visible if (host and host.hell_environment) else false

		var pass_dist: bool = (int(current_dist) == int(target_dist)) or (absf(current_dist - target_dist) <= 1.5)
		var pass_biome: bool = (active_biome_id == int(m["expected_biome"]))

		var record := {
			"milestone": m["name"],
			"target_meters": target_dist,
			"displayed_hud_distance": hud_text,
			"actual_sim_distance_m": current_dist,
			"vehicle_position": game_inst.vehicle.global_position,
			"active_biome_id": active_biome_id,
			"active_biome_name": active_biome_name,
			"active_terrain_profile": active_profile,
			"normal_env_visible": normal_vis,
			"heaven_env_visible": heaven_vis,
			"hell_env_visible": hell_vis,
			"distance_verified": pass_dist,
			"biome_verified": pass_biome
		}
		verification_results.append(record)

		print("  -> Target: %.0f m | Sim: %.2f m | HUD: '%s'" % [target_dist, current_dist, hud_text])
		print("  -> Vehicle X: %.1f px | Surface Y: %.1f px" % [game_inst.vehicle.global_position.x, game_inst.vehicle.global_position.y])
		print("  -> Active Biome: %s (%d) | Profile: %s" % [active_biome_name, active_biome_id, active_profile])
		print("  -> Environment Visibility: Normal=%s, Heaven=%s, Hell=%s" % [str(normal_vis), str(heaven_vis), str(hell_vis)])
		print("  -> Distance Check: %s | Biome Check: %s" % ["PASS" if pass_dist else "FAIL", "PASS" if pass_biome else "FAIL"])

		# 6. Capture gameplay snapshot from SubViewport
		var img: Image = sub_viewport.get_texture().get_image()
		if img:
			img.save_png(m["file_main"])
			img.save_png(m["file_compat"])
			print("  ✓ Saved %s" % m["file_main"])
			print("  ✓ Saved %s" % m["file_compat"])

	# Save telemetry report to JSON
	var file := FileAccess.open("res://docs/previews/biome_runtime_verification_telemetry.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(verification_results, "\t"))
		file.close()
		print("\n✓ Saved res://docs/previews/biome_runtime_verification_telemetry.json")

	game_inst.queue_free()
	await process_frame
	sub_viewport.queue_free()
	await process_frame

	print("\n=================================================================")
	print("--- BIOME RUNTIME VISUAL CAPTURE COMPLETED SUCCESSFULLY ---")
	print("=================================================================")
