@tool
extends SceneTree

func _init() -> void:
	print("=== BEGIN CAPTURING ALL 9 REQUIRED HEAVEN SCREENSHOTS ===")
	await _capture_all_heaven_evidence()
	quit(0)

func _capture_all_heaven_evidence() -> void:
	var output_dir := "res://docs/previews"
	var dir := DirAccess.open(output_dir)
	if not dir:
		DirAccess.make_dir_recursive_absolute(output_dir)
		
	var brain_dir := "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"

	var packed_game: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed_game:
		printerr("Failed to load Game.tscn")
		return

	# Setup 1280x720 SubViewport
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var game: GameScene = packed_game.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	# Settle initial scene
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

	var targets := [
		{
			"name": "heaven_1_full_environment",
			"dist": 1600.0,
			"cam_offset": Vector2(160.0, -40.0),
			"hud": true,
			"truck": true,
			"desc": "1. Full Heaven Environment (Panoramic)"
		},
		{
			"name": "heaven_2_main_palace_arch",
			"dist": 1520.0,
			"cam_offset": Vector2(0.0, -80.0),
			"hud": false,
			"truck": true,
			"desc": "2. Main Palace Arch (Symmetrical Gateway)"
		},
		{
			"name": "heaven_3_angel_monument",
			"dist": 1820.0,
			"cam_offset": Vector2(0.0, -90.0),
			"hud": false,
			"truck": true,
			"desc": "3. Angel Monument on Pedestal with Halo"
		},
		{
			"name": "heaven_4_rose_window_colonnade",
			"dist": 1540.0,
			"cam_offset": Vector2(-50.0, -110.0),
			"hud": false,
			"truck": false,
			"desc": "4. Stained-Glass Rose Window and Colonnade"
		},
		{
			"name": "heaven_5_marble_driving_terrain",
			"dist": 1620.0,
			"cam_offset": Vector2(40.0, 50.0),
			"hud": false,
			"truck": true,
			"desc": "5. Polished Ivory Marble Driving Terrain with Gold Inlays"
		},
		{
			"name": "heaven_6_lower_cloud_underside",
			"dist": 1600.0,
			"cam_offset": Vector2(0.0, 150.0),
			"hud": false,
			"truck": false,
			"desc": "6. Billowing Organic Cloud-Island Underside"
		},
		{
			"name": "heaven_7_doves_and_celestial_garden",
			"dist": 1680.0,
			"cam_offset": Vector2(50.0, -40.0),
			"hud": false,
			"truck": true,
			"desc": "7. Doves Soaring in Sky & Roadside Celestial Gardens"
		},
		{
			"name": "heaven_8_full_gameplay_truck_visible",
			"dist": 1600.0,
			"cam_offset": Vector2(160.0, -40.0),
			"hud": true,
			"truck": true,
			"desc": "8. Full Gameplay with Monster Truck and HUD"
		},
		{
			"name": "heaven_9_return_merge_heaven_to_normal",
			"dist": 2260.0,
			"cam_offset": Vector2(160.0, -20.0),
			"hud": true,
			"truck": true,
			"desc": "9. Return Descent Merge from Heaven to Normal Land"
		}
	]

	for item in targets:
		var dist_m: float = item["dist"]
		var world_x: float = dist_m * 100.0

		if prog:
			prog.update_distance(dist_m)
		if game.game_manager:
			game.game_manager.update_distance(dist_m)
			game.game_manager.coins_collected = 75
			game.game_manager.coins_updated.emit(75)

		if gen:
			gen._update_generation(world_x)

		var surf_y: float = gen.get_surface_y_at_world_x(world_x) if gen else 380.0

		if game.vehicle:
			game.vehicle.visible = item["truck"]
			game.vehicle.reset_vehicle(Vector2(world_x, surf_y - 36.0))
			game.vehicle.linear_velocity = Vector2(480.0, 0.0)

		if is_instance_valid(game.follow_camera):
			game.follow_camera.global_position = Vector2(world_x, surf_y) + item["cam_offset"]
			if game.follow_camera.has_method("snap_to_target"):
				game.follow_camera.snap_to_target()

		if game.hud:
			game.hud.visible = item["hud"]
			if game.hud.message_banner:
				game.hud.message_banner.visible = false

		# Let physics, particles, and shaders settle
		for f in range(30):
			await physics_frame
			await process_frame

		var img: Image = vp.get_texture().get_image()
		if img:
			var fname = item["name"] + ".png"
			var path_docs = "res://docs/previews/" + fname
			var path_brain = brain_dir + "/" + fname
			img.save_png(path_docs)
			img.save_png(path_brain)
			print("  ✓ [%s] Saved %s (1280x720)" % [item["desc"], fname])

	# Also re-sync screenshot_heaven.png and current_gameplay_heaven.png with the new baseline
	var img_final: Image = vp.get_texture().get_image()
	img_final.save_png("res://docs/previews/screenshot_heaven.png")
	img_final.save_png("res://docs/previews/current_gameplay_heaven.png")
	img_final.save_png(brain_dir + "/screenshot_heaven.png")
	img_final.save_png(brain_dir + "/current_gameplay_heaven.png")

	game.queue_free()
	vp.queue_free()
	print("✓ Successfully captured and synced all 9 required engine screenshots!")
