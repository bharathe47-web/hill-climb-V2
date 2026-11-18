@tool
extends SceneTree

func _init() -> void:
	var packed_game: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed_game.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)
	for f in range(10):
		await process_frame
		await physics_frame

	var host = game.biome_environment_host
	var prog = host.progression_controller if host else null
	var gen = game.terrain_slot.get_node_or_null("TerrainGenerator")
	if gen and prog:
		gen.bind_progression_controller(prog)
		gen._update_generation(215000.0)
		prog.update_distance(2205.0)
		gen._update_generation(225000.0)
		
		for s in gen.active_segments:
			if s.segment_type == TerrainSegment.SegmentType.RAMP_HEAVEN_TO_NORMAL:
				print("Found RAMP_HEAVEN_TO_NORMAL at global_pos: ", s.global_position)
				var gw = s.decorations_root.get_node_or_null("ReturnGoldenGateway")
				if gw:
					print("  Found ReturnGoldenGateway at global_pos: ", gw.global_position)
				var col = s.decorations_root.get_node_or_null("ReturnPalaceColumn")
				if col:
					print("  Found ReturnPalaceColumn at global_pos: ", col.global_position)

	game.queue_free()
	quit(0)
