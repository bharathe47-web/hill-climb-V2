@tool
extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed:
		printerr("Failed to load Game.tscn")
		quit(1)
		return

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	for f in range(20):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	var dist_val: float = 600.0 # or 650.0
	var world_x: float = float(game.start_x) + (dist_val * 100.0)

	game.game_manager.update_distance(dist_val)
	if is_instance_valid(prog):
		prog.update_distance(dist_val)
	if is_instance_valid(host):
		host.activate_biome_exclusive(WorldCycleSchedule.BiomeType.HELL)
	if is_instance_valid(gen):
		gen._update_generation(world_x + 4000.0)
		for enc in gen.active_encounters:
			if enc.has_method("isolate_route"):
				enc.isolate_route(WorldCycleSchedule.BiomeType.HELL)

	var surf_y: float = gen.get_surface_y_at_world_x(world_x) if is_instance_valid(gen) else 350.0
	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)

	for f in range(15):
		await process_frame
		await physics_frame

	print("=== SCANNING ALL TEXTURES IN SCENE AT 600m ===")
	_dump_nodes(game, "")
	quit(0)

func _dump_nodes(node: Node, indent: String) -> void:
	if not is_instance_valid(node):
		return
	if node is CanvasItem:
		if not (node as CanvasItem).is_visible_in_tree():
			return
	
	var desc := ""
	if node is Sprite2D:
		var s := node as Sprite2D
		desc = "Sprite2D tex=%s pos=%s gpos=%s scale=%s z=%d" % [
			s.texture.resource_path if s.texture else "null",
			s.position, s.global_position, s.scale, s.z_index
		]
	elif node is AnimatedSprite2D:
		var a := node as AnimatedSprite2D
		desc = "AnimatedSprite2D frames=%s anim=%s pos=%s gpos=%s scale=%s z=%d" % [
			a.sprite_frames.resource_path if a.sprite_frames else "null",
			a.animation, a.position, a.global_position, a.scale, a.z_index
		]
	elif node is TextureRect:
		var tr := node as TextureRect
		desc = "TextureRect tex=%s size=%s pos=%s gpos=%s z=%d" % [
			tr.texture.resource_path if tr.texture else "null",
			tr.size, tr.position, tr.global_position, tr.z_index
		]
	elif node is ParallaxLayer:
		var pl := node as ParallaxLayer
		desc = "ParallaxLayer motion_scale=%s motion_mirroring=%s" % [pl.motion_scale, pl.motion_mirroring]

	if desc != "":
		print("%s%s (%s): %s" % [indent, node.name, node.get_class(), desc])

	for child in node.get_children():
		_dump_nodes(child, indent + "  ")
