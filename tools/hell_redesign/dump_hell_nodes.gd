@tool
extends SceneTree

func _init() -> void:
	print("--- DUMPING ACTIVE NODES AND PROPS IN HELL (569m - 850m) ---")
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)
	
	for f in range(20):
		await process_frame
		await physics_frame
		
	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game.biome_environment_host
	if is_instance_valid(host):
		host.activate_biome_exclusive(WorldCycleSchedule.BiomeType.HELL)
		
	# Check Hell segments
	# 600m is world_x = 60000.0
	gen._update_generation(75000.0)
	
	print("Active segments count: ", gen.active_segments.size())
	for seg in gen.active_segments:
		if not is_instance_valid(seg) or not (seg is TerrainSegment): continue
		var tseg := seg as TerrainSegment
		print("\nSegment: start=%.1fm, end=%.1fm, biome=%d" % [tseg.start_distance_m, tseg.end_distance_m, tseg.biome_type])
		var dec_root = tseg.decorations_root
		if dec_root:
			for c in dec_root.get_children():
				if c is Sprite2D:
					var spr := c as Sprite2D
					print("  Deco Sprite: name=%s, tex=%s, pos=%s, z=%d, scale=%s" % [
						spr.name,
						spr.texture.resource_path if spr.texture else "null",
						spr.position,
						spr.z_index,
						spr.scale
					])
					
	# Check HellEnvironment nodes
	var hell_env = host.get_node_or_null("HellEnvironment")
	if hell_env:
		print("\nHellEnvironment children:")
		_print_canvas(hell_env, "  ")
		
	quit(0)

func _print_canvas(node: Node, indent: String) -> void:
	for c in node.get_children():
		var info = "%s%s (%s)" % [indent, c.name, c.get_class()]
		if c is Sprite2D:
			info += " tex=%s pos=%s z=%d" % [c.texture.resource_path if c.texture else "null", c.position, c.z_index]
		elif c is AnimatedSprite2D:
			info += " frames=%s anim=%s pos=%s" % [c.sprite_frames.resource_path if c.sprite_frames else "null", c.animation, c.position]
		print(info)
		_print_canvas(c, indent + "  ")
