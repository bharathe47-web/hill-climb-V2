@tool
extends SceneTree

func _init() -> void:
	print("--- BEGIN NORMAL LAND REDESIGN SHOWCASE CAPTURE ---")
	await _run_captures()
	quit(0)

func _run_captures() -> void:
	var dir := DirAccess.open("res://docs/previews")
	if not dir:
		DirAccess.make_dir_recursive_absolute("res://docs/previews")

	var packed_game: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed_game:
		printerr("Failed to load Game.tscn")
		return

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var targets: Array[Dictionary] = [
		{
			"filename": "res://docs/previews/normal_land_redesign_200m.png",
			"dist": 200.0,
			"label": "Normal Land 200m - Countryside Meadow & Flora"
		},
		{
			"filename": "res://docs/previews/normal_land_redesign_500m.png",
			"dist": 500.0,
			"label": "Normal Land 500m - Rolling Hills, Fences & Berry Bushes"
		},
		{
			"filename": "res://docs/previews/normal_land_redesign_800m.png",
			"dist": 800.0,
			"label": "Normal Land 800m - Rich Soil Strata & Rustic Scenery"
		},
		{
			"filename": "res://docs/previews/screenshot_normal_land.png",
			"dist": 350.0,
			"label": "Normal Land Primary Deliverable (350m)"
		}
	]

	for item in targets:
		print("Capturing: %s..." % item["label"])
		var game: GameScene = packed_game.instantiate() as GameScene
		game.use_procedural_terrain = true
		vp.add_child(game)

		# Initialize and advance game
		for f in range(15):
			await process_frame
			await physics_frame

		if is_instance_valid(game.game_manager):
			game.game_manager.start_run()
			game.game_manager.update_distance(item["dist"])

		var world_x: float = item["dist"] * 100.0
		var terrain_gen: TerrainGenerator = null
		if is_instance_valid(game.terrain_slot):
			terrain_gen = game.terrain_slot.get_node_or_null("TerrainGenerator")
		
		var surf_y: float = 420.0
		if is_instance_valid(terrain_gen):
			# ensure generator generates around this area
			terrain_gen.target.global_position.x = world_x
			terrain_gen._process(0.016)
			await physics_frame
			await process_frame
			surf_y = terrain_gen.get_surface_y_at_world_x(world_x)

		if is_instance_valid(game.vehicle):
			game.vehicle.global_position = Vector2(world_x, surf_y - 25.0)
			game.vehicle.linear_velocity = Vector2(400.0, 0.0)
			game.vehicle.set("throttle_input", 0.7)

		if is_instance_valid(game.follow_camera):
			game.follow_camera.global_position = Vector2(world_x + 120.0, surf_y - 50.0)

		# Allow rendering to settle
		for f in range(30):
			await physics_frame
			await process_frame

		var img: Image = vp.get_texture().get_image()
		if img:
			img.save_png(item["filename"])
			print("  ✓ Saved %s (%dx%d)" % [item["filename"], img.get_width(), img.get_height()])

		game.queue_free()
		for f in range(5):
			await process_frame

	vp.queue_free()
	print("✓ All Normal Land showcase screenshots captured successfully!")
