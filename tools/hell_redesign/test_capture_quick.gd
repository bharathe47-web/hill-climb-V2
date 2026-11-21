extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	for f in range(10):
		await process_frame
		await physics_frame

	var dist_m := 650.0
	var world_x: float = float(game.start_x) + (dist_m * 100.0)
	game.game_manager.update_distance(dist_m)
	if is_instance_valid(game.biome_environment_host):
		game.biome_environment_host.activate_biome_exclusive(WorldCycleSchedule.BiomeType.HELL)
	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	if is_instance_valid(gen):
		gen._update_generation(world_x + 4000.0)

	var surf_y: float = gen.get_surface_y_at_world_x(world_x) if gen else 350.0
	if is_instance_valid(game.vehicle):
		game.vehicle.global_position = Vector2(world_x, surf_y - 45.0)
	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)

	for f in range(20):
		await process_frame
		await physics_frame

	var tex := vp.get_texture()
	if tex:
		var img := tex.get_image()
		if img and not img.is_empty():
			img.save_png("res://docs/hell_redesign/qa_screenshots/hell_checkpoint_650m.png")
			print("SUCCESS: Grabbed 650m image: ", img.get_size())
		else:
			print("img is empty or null")
	else:
		print("tex is null")
	quit(0)
