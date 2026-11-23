@tool
extends SceneTree

func _init():
	var gen: TerrainGenerator = TerrainGenerator.new()
	root.add_child(gen)
	gen._ready()
	gen._update_generation(65000.0)
	print("Total segments: ", gen.active_segments.size())
	for seg in gen.active_segments:
		if seg.end_world_x >= 28000.0 and seg.start_world_x <= 62000.0:
			print("SEG [%.1fm - %.1fm] (len=%.0f) type=%s amp=%.1f start_h=%.1f end_h=%.1f start_s=%.2f end_s=%.2f glob_y=%.1f" % [
				seg.start_distance_m, seg.end_distance_m,
				seg.segment_length,
				TerrainSegment.SegmentType.keys()[seg.segment_type],
				seg.amplitude, seg.start_height, seg.end_height,
				seg.start_slope, seg.end_slope,
				seg.global_position.y
			])
	quit(0)
