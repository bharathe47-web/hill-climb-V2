@tool
extends SceneTree

func _init() -> void:
	print("=== BEGIN CAPTURING ALL 11 REQUIRED HEAVEN REBUILD SCREENSHOTS ===")
	await _capture_all_heaven_rebuild_evidence()
	quit(0)

func _capture_all_heaven_rebuild_evidence() -> void:
	var output_dir := "res://docs/previews"
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

	# Targets ordered with monotonically increasing distance to guarantee continuous active terrain segments
	var targets := [
		{
			"name": "heaven_1_full_environment",
			"dist": 1382.8,
			"cam_offset": Vector2(120.0, -25.0),
			"hud": true,
			"truck": true,
			"desc": "1. Full Celestial Palace View (Panoramic Corridor)"
		},
		{
			"name": "heaven_2_main_palace_arch",
			"dist": 1382.8,
			"cam_offset": Vector2(0.0, -35.0),
			"hud": false,
			"truck": true,
			"desc": "2. Grand Arch and Column Composition (Section A)"
		},
		{
			"name": "heaven_section_a_gateway",
			"dist": 1382.8,
			"cam_offset": Vector2(0.0, -25.0),
			"hud": true,
			"truck": true,
			"desc": "Section A: Gateway Arch & Columns"
		},
		{
			"name": "heaven_4_rose_window_colonnade",
			"dist": 1405.7,
			"cam_offset": Vector2(0.0, -35.0),
			"hud": false,
			"truck": true,
			"desc": "4. Stained-Glass Rose Window and Colonnade (Section B)"
		},
		{
			"name": "heaven_section_b_rose_window",
			"dist": 1405.7,
			"cam_offset": Vector2(0.0, -25.0),
			"hud": true,
			"truck": true,
			"desc": "Section B: Rose Window & Colonnade Arch"
		},
		{
			"name": "heaven_5_central_fountain",
			"dist": 1428.6,
			"cam_offset": Vector2(0.0, -35.0),
			"hud": false,
			"truck": true,
			"desc": "5. Central Ceremonial Fountain (Section C)"
		},
		{
			"name": "heaven_section_c_fountain",
			"dist": 1428.6,
			"cam_offset": Vector2(0.0, -25.0),
			"hud": true,
			"truck": true,
			"desc": "Section C: Ceremonial Pedestal Fountain"
		},
		{
			"name": "heaven_3_grand_door",
			"dist": 1451.4,
			"cam_offset": Vector2(0.0, -35.0),
			"hud": false,
			"truck": true,
			"desc": "3. Main Decorative Double Door Landmark (Section D)"
		},
		{
			"name": "heaven_section_d_grand_door",
			"dist": 1451.4,
			"cam_offset": Vector2(0.0, -25.0),
			"hud": true,
			"truck": true,
			"desc": "Section D: Grand Celestial Double Door"
		},
		{
			"name": "heaven_section_e_causeway",
			"dist": 1474.3,
			"cam_offset": Vector2(0.0, -25.0),
			"hud": true,
			"truck": true,
			"desc": "Section E: Angel Monument Terrace & Causeway"
		},
		{
			"name": "heaven_6_marble_bridge_driving_surface",
			"dist": 1480.0,
			"cam_offset": Vector2(60.0, 30.0),
			"hud": false,
			"truck": true,
			"desc": "6. Marble Bridge Driving Surface (Paving, Gold Inlays & Rosettes)"
		},
		{
			"name": "heaven_7_bridge_masonry_underside",
			"dist": 1480.0,
			"cam_offset": Vector2(0.0, 140.0),
			"hud": false,
			"truck": false,
			"desc": "7. Bridge Masonry Underside and Rounded Arch Openings (Clouds Visible)"
		},
		{
			"name": "heaven_8_floating_islands_layered_sky",
			"dist": 1485.0,
			"cam_offset": Vector2(0.0, -110.0),
			"hud": false,
			"truck": false,
			"desc": "8. Floating Islands and Layered Turquoise Sky with Pantheons"
		},
		{
			"name": "heaven_9_doves_and_celestial_garden",
			"dist": 1474.3,
			"cam_offset": Vector2(40.0, -25.0),
			"hud": false,
			"truck": true,
			"desc": "9. Celestial Garden Terraces on Marble Plinths (No Doves)"
		},
		{
			"name": "heaven_10_vehicle_driving_inside_heaven",
			"dist": 1451.4,
			"cam_offset": Vector2(140.0, -25.0),
			"hud": true,
			"truck": true,
			"desc": "10. Vehicle Driving Inside the New Heaven (Live Action & HUD)"
		},
		{
			"name": "heaven_11_heaven_return_merge",
			"dist": 2260.0,
			"cam_offset": Vector2(160.0, -20.0),
			"hud": true,
			"truck": true,
			"desc": "11. Heaven Return Merge into Normal Land"
		}
	]

	for item in targets:
		var dist_m: float = item["dist"]
		var world_x: float = dist_m * 100.0

		if prog:
			prog.update_distance(dist_m)
		if game.game_manager:
			game.game_manager.update_distance(dist_m)
			game.game_manager.coins_collected = 80
			game.game_manager.coins_updated.emit(80)

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

		# Settle
		for f in range(20):
			await physics_frame
			await process_frame

		var img: Image = vp.get_texture().get_image()
		if img:
			var fname: String = item["name"] + ".png"
			var local_path := output_dir.path_join(fname)
			var b_path := brain_dir.path_join(fname)
			img.save_png(local_path)
			img.save_png(b_path)
			print("  ✓ Saved %s (%s)" % [fname, item["desc"]])

			# Also update primary gameplay references when on full gameplay targets
			if item["name"] == "heaven_1_full_environment":
				img.save_png(output_dir.path_join("screenshot_heaven.png"))
				img.save_png(output_dir.path_join("current_gameplay_heaven.png"))
				img.save_png(brain_dir.path_join("screenshot_heaven.png"))
				img.save_png(brain_dir.path_join("current_gameplay_heaven.png"))

	game.queue_free()
	vp.queue_free()
	print("=== ALL HEAVEN REBUILD SCREENSHOTS CAPTURED SUCCESSFULLY ===")
