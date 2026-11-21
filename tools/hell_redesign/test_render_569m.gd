@tool
extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var vp := SubViewport.new()
	vp.size = Vector2i(1366, 768)
	root.add_child(vp)

	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	for f in range(15):
		await process_frame
		await physics_frame

	var dist_m := 569.0
	var world_x: float = float(game.start_x) + (dist_m * 100.0)
	game.game_manager.update_distance(dist_m)
	if is_instance_valid(game.biome_environment_host):
		game.biome_environment_host.activate_biome_exclusive(WorldCycleSchedule.BiomeType.HELL)
	if is_instance_valid(game.terrain_slot.get_node_or_null("TerrainGenerator")):
		game.terrain_slot.get_node_or_null("TerrainGenerator")._update_generation(world_x + 4000.0)

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var surf_y: float = gen.get_surface_y_at_world_x(world_x) if gen else 350.0
	if is_instance_valid(game.vehicle):
		game.vehicle.global_position = Vector2(world_x, surf_y - 45.0)
	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)

	for f in range(25):
		await process_frame
		await physics_frame

	var img_with_hud := vp.get_texture().get_image()
	img_with_hud.save_png(ProjectSettings.globalize_path("res://docs/hell_redesign/test_render_569m_with_hud.png"))

	# Now hide HUD touch controls
	if is_instance_valid(game.hud):
		var touch := game.hud.get_node_or_null("TouchControls")
		if touch:
			touch.visible = false

	for f in range(5):
		await process_frame
		await physics_frame

	var img_no_touch := vp.get_texture().get_image()
	img_no_touch.save_png(ProjectSettings.globalize_path("res://docs/hell_redesign/test_render_569m_no_touch.png"))

	print("Saved test renders with and without touch controls!")
	quit(0)
