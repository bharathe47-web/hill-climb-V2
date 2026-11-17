@tool
extends SceneTree

# tools/capture_all_required_screenshots.gd
# Captures the authoritative set of 9 fresh screenshots:
# 1. Main Menu
# 2. Normal Land (countryside driving)
# 3. Heaven (celestial concourse)
# 4. Hell (volcanic basalt & characters)
# 5. Transition: Normal -> Heaven
# 6. Transition: Normal -> Hell
# 7. Return Merge: Heaven -> Normal
# 8. Return Merge: Hell -> Normal
# 9. Nitro Touch HUD (in-game affordance)

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN CAPTURING ALL 9 REQUIRED SCREENSHOTS ---")
	print("=================================================================\n")
	await _run_all_captures()
	quit(0)

func _run_all_captures() -> void:
	var dir := DirAccess.open("res://docs/previews")
	if not dir:
		DirAccess.make_dir_recursive_absolute("res://docs/previews")

	await _capture_main_menu()
	await _capture_gameplay_scenarios()
	print("\n✓ ALL 9 REQUIRED SCREENSHOTS CAPTURED SUCCESSFULLY!\n")

func _capture_main_menu() -> void:
	print(">>> [1/9] Capturing Main Menu...")
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var menu_scene: PackedScene = load("res://scenes/main/MainMenu.tscn")
	var menu: Control = menu_scene.instantiate() as Control
	vp.add_child(menu)

	for f in range(15):
		await process_frame

	_save_viewport_image(vp, "res://docs/previews/screenshot_main_menu.png")
	vp.queue_free()

func _capture_gameplay_scenarios() -> void:
	var packed_game: PackedScene = load("res://scenes/game/Game.tscn")

	# Scenarios configuration
	var scenarios: Array[Dictionary] = [
		{
			"id": "screenshot_normal_land",
			"title": "[2/9] Normal Land (Countryside Driving)",
			"dist": 350.0,
			"state": WorldCycleSchedule.WorldState.NORMAL_LAND_1,
			"biome": WorldCycleSchedule.BiomeType.NORMAL_LAND,
			"vel": Vector2(650.0, 0.0),
			"nitro": false
		},
		{
			"id": "screenshot_transition_normal_to_heaven",
			"title": "[3/9] Transition Normal -> Heaven (Launch Ramp & Gateway)",
			"dist": 1075.0,
			"state": WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HEAVEN,
			"biome": WorldCycleSchedule.BiomeType.NORMAL_LAND,
			"vel": Vector2(950.0, -180.0),
			"nitro": true
		},
		{
			"id": "screenshot_heaven",
			"title": "[4/9] Heaven (Celestial Concourse & Marble Road)",
			"dist": 1600.0,
			"state": WorldCycleSchedule.WorldState.HEAVEN,
			"biome": WorldCycleSchedule.BiomeType.HEAVEN,
			"vel": Vector2(750.0, 0.0),
			"nitro": false
		},
		{
			"id": "screenshot_return_merge_heaven_to_normal",
			"title": "[5/9] Return Merge: Heaven -> Normal Land (Cloud Slide)",
			"dist": 2280.0,
			"state": WorldCycleSchedule.WorldState.TRANSITION_HEAVEN_TO_NORMAL,
			"biome": WorldCycleSchedule.BiomeType.HEAVEN,
			"vel": Vector2(700.0, 100.0),
			"nitro": false
		},
		{
			"id": "screenshot_transition_normal_to_hell",
			"title": "[6/9] Transition Normal -> Hell (Volcanic Plunge)",
			"dist": 3580.0,
			"state": WorldCycleSchedule.WorldState.TRANSITION_NORMAL_TO_HELL,
			"biome": WorldCycleSchedule.BiomeType.NORMAL_LAND,
			"vel": Vector2(800.0, 150.0),
			"nitro": false
		},
		{
			"id": "screenshot_hell",
			"title": "[7/9] Hell (Basalt Ground, Lava, Skeleton Knight & Demon)",
			"dist": 4200.0,
			"state": WorldCycleSchedule.WorldState.HELL,
			"biome": WorldCycleSchedule.BiomeType.HELL,
			"vel": Vector2(700.0, 0.0),
			"nitro": false
		},
		{
			"id": "screenshot_return_merge_hell_to_normal",
			"title": "[8/9] Return Merge: Hell -> Normal Land (Geyser Ascent)",
			"dist": 5080.0,
			"state": WorldCycleSchedule.WorldState.TRANSITION_HELL_TO_NORMAL,
			"biome": WorldCycleSchedule.BiomeType.HELL,
			"vel": Vector2(750.0, -120.0),
			"nitro": false
		},
		{
			"id": "screenshot_nitro_touch_hud",
			"title": "[9/9] Nitro Touch HUD Affordance",
			"dist": 485.0,
			"state": WorldCycleSchedule.WorldState.NORMAL_LAND_1,
			"biome": WorldCycleSchedule.BiomeType.NORMAL_LAND,
			"vel": Vector2(850.0, 0.0),
			"nitro": true
		}
	]

	for sc in scenarios:
		print(">>> Capturing %s..." % sc["title"])
		var vp := SubViewport.new()
		vp.size = Vector2i(1280, 720)
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)

		var game: GameScene = packed_game.instantiate() as GameScene
		game.use_procedural_terrain = true
		vp.add_child(game)

		for f in range(12):
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

		var dist: float = sc["dist"]
		var world_x := dist * 100.0

		if host:
			host.apply_biome_state(sc["biome"])
		if prog:
			prog.update_distance(dist)
		if game.game_manager:
			game.game_manager.update_distance(dist)
			game.game_manager.coins_collected = 45
			game.game_manager.coins_updated.emit(45)

		if gen:
			gen._update_generation(world_x)

		var surf_y: float = gen.get_surface_y_at_world_x(world_x) if gen else 380.0
		if game.vehicle:
			game.vehicle.reset_vehicle(Vector2(world_x, surf_y - 36.0))
			game.vehicle.linear_velocity = sc["vel"]
			if sc["nitro"] and game.vehicle.has_method("set_nitro_active"):
				game.vehicle.set_nitro_active(true)

		if is_instance_valid(game.follow_camera):
			game.follow_camera.global_position = game.vehicle.global_position + Vector2(160.0, -40.0)
			if game.follow_camera.has_method("snap_to_target"):
				game.follow_camera.snap_to_target()

		if game.hud and game.hud.message_banner:
			game.hud.message_banner.visible = false

		for f in range(25):
			await physics_frame
			await process_frame

		var out_path := "res://docs/previews/%s.png" % sc["id"]
		_save_viewport_image(vp, out_path)
		vp.queue_free()

func _save_viewport_image(viewport: SubViewport, dest_path: String) -> void:
	var img: Image = viewport.get_texture().get_image()
	if not img:
		printerr("  ❌ Failed to get image from viewport: %s" % dest_path)
		return
	var err := img.save_png(dest_path)
	if err == OK:
		print("  ✓ [SAVED] %s (%dx%d)" % [dest_path, img.get_width(), img.get_height()])
	else:
		printerr("  ❌ [ERROR] Failed saving %s (code %d)" % [dest_path, err])
