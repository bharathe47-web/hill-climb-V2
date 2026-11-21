@tool
extends SceneTree

func _init() -> void:
	var gen := TerrainGenerator.new()
	root.add_child(gen)
	gen._ready()
	gen._update_generation(60000.0)

	print("--- AUDITING BRIDGE ARCH CONNECTIONS IN HEAVEN (300m - 600m) ---")
	var prev_seg_last_arch_right_world: Vector2 = Vector2.ZERO
	var prev_seg_last_arch_valid := false

	for seg in gen.active_segments:
		if seg.end_world_x >= 30000.0 and seg.start_world_x <= 60000.0:
			var facade = seg.get_node_or_null("BridgeFacade")
			if not facade:
				continue
			var arch_children = []
			for c in facade.get_children():
				if c is Sprite2D and c.name.begins_with("ViaductArch"):
					arch_children.append(c)

			print("\nSEG [%.1fm - %.1fm] len=%.1f arches=%d" % [
				seg.start_distance_m, seg.end_distance_m, seg.segment_length, arch_children.size()
			])

			for ai in range(arch_children.size()):
				var arch: Sprite2D = arch_children[ai]
				# Local transform to world transform
				var arch_world_pos: Vector2 = seg.global_position + arch.position
				var angle = arch.rotation
				var scale_x = arch.scale.x
				var half_w = (640.0 * 0.5) * scale_x
				
				# Top-left and top-right in world coordinates
				# arch.offset is (0, 140), so top-center in local arch coords is (0, 0)
				# top-left is (-half_w, 0) rotated by angle
				var top_left_local = Vector2(-half_w, 0.0).rotated(angle)
				var top_right_local = Vector2(half_w, 0.0).rotated(angle)
				var top_left_world = arch_world_pos + top_left_local
				var top_right_world = arch_world_pos + top_right_local

				# Road surface world Y at these X coordinates
				var road_y_left = gen.get_surface_y_at_world_x(top_left_world.x)
				var road_y_right = gen.get_surface_y_at_world_x(top_right_world.x)
				var road_underside_left = road_y_left + seg.visual_surface_band_depth
				var road_underside_right = road_y_right + seg.visual_surface_band_depth

				var gap_left = top_left_world.y - road_underside_left
				var gap_right = top_right_world.y - road_underside_right

				print("  Arch %d: world_x=[%.1f, %.1f] rot=%.3f | gap_left=%.2f px | gap_right=%.2f px" % [
					ai, top_left_world.x, top_right_world.x, angle, gap_left, gap_right
				])

				# Check connection with previous arch in same segment
				if ai > 0:
					var prev_arch: Sprite2D = arch_children[ai - 1]
					var prev_half_w = (640.0 * 0.5) * prev_arch.scale.x
					var prev_top_right = seg.global_position + prev_arch.position + Vector2(prev_half_w, 0.0).rotated(prev_arch.rotation)
					var inter_arch_gap = top_left_world.distance_to(prev_top_right)
					print("    -> Inter-arch junction (Arch %d -> %d): gap = %.2f px" % [ai - 1, ai, inter_arch_gap])

				# Check connection with previous segment's last arch
				if ai == 0 and prev_seg_last_arch_valid:
					var inter_seg_gap = top_left_world.distance_to(prev_seg_last_arch_right_world)
					print("    -> Inter-segment junction (prev seg -> this seg): gap = %.2f px" % inter_seg_gap)

			if not arch_children.is_empty():
				var last_arch: Sprite2D = arch_children[arch_children.size() - 1]
				var last_half_w = (640.0 * 0.5) * last_arch.scale.x
				prev_seg_last_arch_right_world = seg.global_position + last_arch.position + Vector2(last_half_w, 0.0).rotated(last_arch.rotation)
				prev_seg_last_arch_valid = true

	quit(0)
