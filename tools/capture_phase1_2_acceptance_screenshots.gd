@tool
extends SceneTree

func _init() -> void:
	print("--- BEGIN PHASE 1.2 ACCEPTANCE SCREENSHOT CAPTURE ---")
	await _run_captures()
	quit(0)

func _run_captures() -> void:
	var output_dir := "res://docs/previews"
	var dir := DirAccess.open(output_dir)
	if not dir:
		DirAccess.make_dir_recursive_absolute(output_dir)

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

	# Initialize and settle physics
	for f in range(25):
		await process_frame
		await physics_frame

	if is_instance_valid(game.game_manager):
		game.game_manager.start_run()

	var terrain_gen: TerrainGenerator = null
	if is_instance_valid(game.terrain_slot):
		terrain_gen = game.terrain_slot.get_node_or_null("TerrainGenerator")

	# Define capture targets
	# 1. Uphill terrain
	# 2. Hill crest
	# 3. Downhill terrain
	# 4. Deep terrain layers
	# 5. Terrain segment boundaries
	# Plus primary screenshot_normal_land.png

	# Let's find terrain coordinates for each target
	# We can inspect active segments or sample points along the generated terrain
	var segments: Array[Node] = []
	if is_instance_valid(terrain_gen):
		for c in terrain_gen.get_children():
			if c is TerrainSegment:
				segments.append(c)

	print("Found %d active terrain segments in generator" % segments.size())

	# We'll capture each required scene:
	var captures := [
		{
			"id": "uphill_terrain",
			"filename": "res://docs/previews/uphill_terrain.png",
			"cam_offset_x": 450.0,
			"cam_offset_y": -80.0,
			"zoom": Vector2(1.0, 1.0),
			"car_x": 380.0,
			"throttle": 0.85
		},
		{
			"id": "hill_crest",
			"filename": "res://docs/previews/hill_crest.png",
			"cam_offset_x": 680.0,
			"cam_offset_y": -100.0,
			"zoom": Vector2(1.0, 1.0),
			"car_x": 620.0,
			"throttle": 0.7
		},
		{
			"id": "downhill_terrain",
			"filename": "res://docs/previews/downhill_terrain.png",
			"cam_offset_x": 920.0,
			"cam_offset_y": -70.0,
			"zoom": Vector2(1.0, 1.0),
			"car_x": 860.0,
			"throttle": 0.5
		},
		{
			"id": "deep_terrain_layers",
			"filename": "res://docs/previews/deep_terrain_layers.png",
			"cam_offset_x": 550.0,
			"cam_offset_y": 140.0, # Camera shifted down to show deep geological strata
			"zoom": Vector2(1.0, 1.0),
			"car_x": 550.0,
			"throttle": 0.0
		},
		{
			"id": "terrain_segment_boundaries",
			"filename": "res://docs/previews/terrain_segment_boundaries.png",
			"cam_offset_x": 1200.0, # Exact seam between Segment 0 (0..1200) and Segment 1 (1200..2400)
			"cam_offset_y": -20.0,
			"zoom": Vector2(1.15, 1.15), # Slight zoom on the seam
			"car_x": 1140.0,
			"throttle": 0.4
		},
		{
			"id": "screenshot_normal_land",
			"filename": "res://docs/previews/screenshot_normal_land.png",
			"cam_offset_x": 480.0,
			"cam_offset_y": -70.0,
			"zoom": Vector2(1.0, 1.0),
			"car_x": 420.0,
			"throttle": 0.75
		}
	]

	for cap in captures:
		var car_x: float = cap["car_x"]
		var surf_y: float = 400.0
		if is_instance_valid(terrain_gen):
			surf_y = terrain_gen.get_surface_y_at_world_x(car_x)

		if is_instance_valid(game.vehicle):
			game.vehicle.global_position = Vector2(car_x, surf_y - 28.0)
			game.vehicle.linear_velocity = Vector2(350.0 * cap["throttle"], 0.0)
			game.vehicle.set("throttle_input", cap["throttle"])

		if is_instance_valid(game.follow_camera):
			var cam_x: float = cap["cam_offset_x"]
			var cam_surf_y: float = surf_y
			if is_instance_valid(terrain_gen):
				cam_surf_y = terrain_gen.get_surface_y_at_world_x(cam_x)
			game.follow_camera.global_position = Vector2(cam_x, cam_surf_y + cap["cam_offset_y"])
			game.follow_camera.zoom = cap["zoom"]

		# Advance frames so physics, suspensions and rendering settle
		for f in range(20):
			await physics_frame
			await process_frame

		var img: Image = vp.get_texture().get_image()
		if img:
			img.save_png(cap["filename"])
			# Also copy to brain artifact previews directory
			var brain_path: String = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews/" + cap["filename"].get_file()
			img.save_png(brain_path)
			print("  ✓ Saved %s (%dx%d)" % [cap["filename"], img.get_width(), img.get_height()])

	game.queue_free()
	vp.queue_free()
	print("✓ All Phase 1.2 acceptance screenshots captured successfully!")
