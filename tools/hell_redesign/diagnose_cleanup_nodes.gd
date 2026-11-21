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
	game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)

	for f in range(25):
		await process_frame
		await physics_frame

	var cam_pos: Vector2 = game.follow_camera.global_position
	print("Camera pos at 569m: ", cam_pos)

	# Traverse all nodes in vp and print anything with Sprite2D or AnimatedSprite2D
	_dump_sprites(game, cam_pos)

	quit(0)

func _dump_sprites(node: Node, cam_pos: Vector2) -> void:
	if node is Sprite2D or node is AnimatedSprite2D:
		var n2d := node as Node2D
		var gpos: Vector2 = n2d.global_position
		# Screen coordinates approx: gpos - cam_pos + Vector2(1366/2, 768/2)
		var spos: Vector2 = gpos - cam_pos + Vector2(1366.0 / 2.0, 768.0 / 2.0)
		var tex_name := ""
		if node is Sprite2D and node.texture:
			tex_name = node.texture.resource_path.get_file()
		elif node is AnimatedSprite2D and node.sprite_frames:
			tex_name = "AnimatedFrames:" + node.animation
		if spos.x >= -200 and spos.x <= 1566 and spos.y >= -200 and spos.y <= 968:
			print("Sprite: name=%s type=%s tex=%s gpos=%s spos=%s vis=%s z=%d" % [node.name, node.get_class(), tex_name, gpos, spos, node.is_visible_in_tree(), node.z_index])

	for c in node.get_children():
		_dump_sprites(c, cam_pos)
