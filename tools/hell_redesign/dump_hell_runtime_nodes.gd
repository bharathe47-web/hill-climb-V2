@tool
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

	var dist_val := 600.0
	var world_x: float = float(game.start_x) + (dist_val * 100.0)
	game.game_manager.update_distance(dist_val)
	if is_instance_valid(game.biome_environment_host):
		game.biome_environment_host.activate_biome_exclusive(WorldCycleSchedule.BiomeType.HELL)

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	if is_instance_valid(gen):
		gen._update_generation(world_x + 4000.0)

	var surf_y: float = gen.get_surface_y_at_world_x(world_x) if is_instance_valid(gen) else 350.0
	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)

	for f in range(10):
		await process_frame
		await physics_frame

	print("\n=== SCANNING ALL CANVAS ITEMS VISIBLE AT Y IN [50..200] ===")
	_scan_node(game, game.follow_camera.global_position, vp.size)

	quit(0)

func _scan_node(node: Node, cam_pos: Vector2, vp_size: Vector2i) -> void:
	if node is CanvasItem:
		var ci := node as CanvasItem
		if ci.visible:
			var gpos: Vector2 = ci.global_position
			var rect: Rect2 = Rect2()
			var tex_name: String = ""
			if ci is Sprite2D:
				var s := ci as Sprite2D
				if s.texture:
					tex_name = s.texture.resource_path
					rect = Rect2(s.global_position, s.texture.get_size() * s.global_scale)
			elif ci is TextureRect:
				var tr := ci as TextureRect
				if tr.texture:
					tex_name = tr.texture.resource_path
				rect = tr.get_global_rect()
			elif ci is ColorRect:
				rect = (ci as ColorRect).get_global_rect()
			elif ci is AnimatedSprite2D:
				var anim := ci as AnimatedSprite2D
				tex_name = "AnimatedSprite2D(%s)" % anim.animation
				rect = Rect2(anim.global_position, Vector2(100, 100))
			elif ci is TileMapLayer:
				var tm := ci as TileMapLayer
				tex_name = "TileMapLayer(%s)" % tm.name
				rect = Rect2(tm.global_position, Vector2(1000, 500))

			# Screen pos calculation
			var screen_y: float = gpos.y - (cam_pos.y - float(vp_size.y) / 2.0)
			
			if node.get_parent() is ParallaxLayer:
				var pl := node.get_parent() as ParallaxLayer
				var motion_scale: Vector2 = pl.motion_scale
				var motion_mirror: Vector2 = pl.motion_mirroring
				print("PARALLAX LAYER ITEM: '%s' in '%s', gpos=%s, scale=%s, tex=%s, motion_scale=%s, mirror=%s" % [
					node.name, pl.name, gpos, ci.scale, tex_name, motion_scale, motion_mirror
				])
			elif ci is Sprite2D or ci is TextureRect or ci is AnimatedSprite2D:
				if abs(screen_y) < 400.0 or (gpos.y > 0.0 and gpos.y < 300.0):
					print("WORLD ITEM: '%s' (type %s), gpos=%s, screen_y=%.1f, tex=%s" % [
						node.name, node.get_class(), gpos, screen_y, tex_name
					])

	for c: Node in node.get_children():
		_scan_node(c, cam_pos, vp_size)
