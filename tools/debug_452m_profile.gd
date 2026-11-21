@tool
extends SceneTree

func _init():
	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	root.add_child(game)
	for f in range(5):
		await process_frame

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	gen._update_generation(50000.0)

	print("--- INSPECTING TERRAIN NEAR 452M (x=45200) ---")
	for seg in gen.active_segments:
		if seg.start_world_x <= 46500.0 and seg.end_world_x >= 43500.0:
			print("SEG start=%.1f end=%.1f (%.1fm - %.1fm) type=%s amp=%.1f start_h=%.1f end_h=%.1f start_s=%.3f end_s=%.3f glob_pos=%s" % [
				seg.start_world_x, seg.end_world_x,
				seg.start_distance_m, seg.end_distance_m,
				TerrainSegment.SegmentType.keys()[seg.segment_type],
				seg.amplitude, seg.start_height, seg.end_height,
				seg.start_slope, seg.end_slope,
				seg.global_position
			])
			# Sample points across segment
			for i in range(0, seg.generated_surface_points.size(), 4):
				var p = seg.generated_surface_points[i]
				var wx = seg.global_position.x + p.x
				var wy = seg.global_position.y + p.y
				print("   pt[%d]: local=(%.1f, %.1f) -> world=(%.1f, %.1f)" % [i, p.x, p.y, wx, wy])
	quit(0)
