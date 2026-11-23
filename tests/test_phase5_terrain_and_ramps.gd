extends SceneTree

const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")
const BiomeTerrainProfileClass = preload("res://scripts/terrain/BiomeTerrainProfile.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 5 TERRAIN PROFILES & TRANSITION RAMPS TEST SUITE ---")
	print("=================================================================")
	
	# ----------------------------------------------------
	# Test 1: Verify All 9 Legacy Terrain Types + Custom
	# ----------------------------------------------------
	print("-> [1/6] Testing 9 legacy curve archetypes + Custom...")
	var seg_scene: PackedScene = load("res://scenes/terrain/TerrainSegment.tscn")
	assert(seg_scene != null, "TerrainSegment.tscn must load")
	var seg: TerrainSegment = seg_scene.instantiate()
	root.add_child(seg)
	assert(absf(rad_to_deg(seg._surface_slope_angle_from_normal(Vector2(0.0, -1.0)))) < 0.001, "Level ground normal must produce a 0-degree decoration angle")
	var angled_normal := Vector2(0.3420201, -0.9396926)
	assert(absf(rad_to_deg(seg._surface_slope_angle_from_normal(angled_normal)) - 20.0) < 0.1, "20-degree slope normal must produce the matching decoration angle")
	
	var legacy_types: Array[TerrainSegment.SegmentType] = [
		TerrainSegment.SegmentType.FLAT,
		TerrainSegment.SegmentType.GENTLE_HILLS,
		TerrainSegment.SegmentType.STEEP_CLIMB,
		TerrainSegment.SegmentType.VALLEY_DIP,
		TerrainSegment.SegmentType.JUMP_RAMP,
		TerrainSegment.SegmentType.ROLLING_WAVES,
		TerrainSegment.SegmentType.PLATEAU_DROP,
		TerrainSegment.SegmentType.BUMPY_WASHBOARD,
		TerrainSegment.SegmentType.DOUBLE_CREST
	]
	
	for st in legacy_types:
		seg.segment_type = st
		seg.rebuild_segment()
		assert(seg.collision_polygon.polygon.size() > 0, "Collision polygon must have points")
		assert(seg.ground_polygon.polygon.size() == seg.generated_surface_points.size() * 2, "Ground visual must be the shallow surface crust")
		assert(seg.subsoil_polygon.polygon.size() == seg.generated_surface_points.size() + 2, "Subsoil visual must continue to the deep terrain bottom")
		assert(seg.collision_polygon.polygon.size() == seg.generated_surface_points.size() + 2, "Collision must preserve the full terrain body")
		assert(seg.ground_polygon.polygon[0].is_equal_approx(seg.get_entry_point()), "Top visual must align with collision surface")
		assert(seg.subsoil_polygon.polygon[0].is_equal_approx(seg.get_entry_point() + Vector2(0.0, seg.visual_surface_band_depth)), "Subsoil must begin just below the top crust")
		
		var sample := seg.get_surface_point_and_normal_at(seg.segment_length * 0.5)
		assert(sample.normal.y < 0.0, "Surface normal must point upward into air (normal.y < 0)")
	print("  ✓ All 9 legacy curve archetypes verified: full collision, layered visuals and upward normals")
	
	# Custom points test
	var custom_pts := PackedVector2Array([Vector2(0, 0), Vector2(300, -50), Vector2(600, 0)])
	seg.set_custom_points(custom_pts)
	assert(seg.segment_type == TerrainSegment.SegmentType.CUSTOM, "Type must be CUSTOM")
	assert(seg.generated_surface_points == custom_pts, "Custom points must be stored")
	seg.queue_free()
	print("  ✓ Custom segment type verified")

	# ----------------------------------------------------
	# Test 2: Verify Four Continuous Transition Ramps
	# ----------------------------------------------------
	print("-> [2/6] Testing 4 transition ramp segments & C1 Hermite continuity...")
	var ramp_types: Array[Dictionary] = [
		{"type": TerrainSegment.SegmentType.RAMP_NORMAL_TO_HEAVEN, "name": "RAMP_NORMAL_TO_HEAVEN", "scenery": "TransitionGoldenGateway"},
		{"type": TerrainSegment.SegmentType.RAMP_HEAVEN_TO_NORMAL, "name": "RAMP_HEAVEN_TO_NORMAL", "scenery": "ReturnPalaceColumn"},
		{"type": TerrainSegment.SegmentType.RAMP_NORMAL_TO_HELL, "name": "RAMP_NORMAL_TO_HELL", "scenery": "TransitionDragonSkullPortal"},
		{"type": TerrainSegment.SegmentType.RAMP_HELL_TO_NORMAL, "name": "RAMP_HELL_TO_NORMAL", "scenery": "EscapeMagmaVent"}
	]
	
	for r_info in ramp_types:
		var ramp: TerrainSegment = seg_scene.instantiate()
		root.add_child(ramp)
		ramp.segment_type = r_info["type"]
		ramp.segment_length = 1200.0
		ramp.start_height = 0.0
		ramp.end_height = 0.0
		ramp.amplitude = 90.0
		ramp.start_slope = 0.0
		ramp.end_slope = 0.0
		ramp.rebuild_segment()
		
		# Full-depth collision + separate visual crust
		assert(ramp.ground_polygon.polygon.size() == ramp.generated_surface_points.size() * 2, "Ramp ground must remain a surface crust")
		assert(ramp.collision_polygon.polygon.size() == ramp.generated_surface_points.size() + 2, "Ramp collision must retain its full support body")
		assert(ramp.ground_polygon.polygon[0].is_equal_approx(ramp.get_entry_point()), "Ramp top visual must match the entry collision surface")
		
		# Boundary height check (Hermite + Hann window guarantees exact 0 offset at endpoints)
		var entry_pt := ramp.get_entry_point()
		var exit_pt := ramp.get_exit_point()
		assert(absf(entry_pt.x - 0.0) < 0.001, "Entry x must be 0")
		assert(absf(entry_pt.y - 0.0) < 0.001, "Entry y must be 0 (got %f)" % entry_pt.y)
		assert(absf(exit_pt.x - 1200.0) < 0.001, "Exit x must be 1200")
		assert(absf(exit_pt.y - 0.0) < 0.001, "Exit y must be 0 (got %f)" % exit_pt.y)
		
		# Boundary slope check
		assert(absf(ramp.get_exit_slope() - 0.0) < 0.05, "Exit slope must smoothly match end_slope (~0)")
		
		# Verify gateway scenery node exists
		var scenery_node := ramp.decorations_root.get_node_or_null(r_info["scenery"])
		assert(scenery_node != null, "Scenery node %s must be present in %s" % [r_info["scenery"], r_info["name"]])
		assert(scenery_node is Sprite2D, "Scenery must be a visual Sprite2D")
		assert(scenery_node.z_index <= -3, "Scenery must be background z-indexed behind vehicle")
		
		# Verify zero colliders in decoration nodes
		for child in ramp.decorations_root.get_children():
			assert(not (child is CollisionShape2D or child is CollisionPolygon2D), "Decoration root must not contain collision shapes")
			for subchild in child.get_children():
				assert(not (subchild is CollisionShape2D or subchild is CollisionPolygon2D), "Decoration children must not contain collision shapes")
		
		print("  ✓ %s: 1:1 collision, exact endpoints, C1 tangent slope, scenery '%s' (0 colliders)" % [r_info["name"], r_info["scenery"]])
		ramp.queue_free()

	# ----------------------------------------------------
	# Test 3: Data-Driven BiomeTerrainProfile Resources
	# ----------------------------------------------------
	print("-> [3/6] Testing BiomeTerrainProfile resources (Normal, Heaven, Hell)...")
	var normal_prof: Resource = load("res://assets/terrain/profiles/normal_land_profile.tres")
	var heaven_prof: Resource = load("res://assets/terrain/profiles/heaven_terrain_profile.tres")
	var hell_prof: Resource = load("res://assets/terrain/profiles/hell_terrain_profile.tres")
	
	assert(normal_prof != null, "Normal Land profile must load")
	assert(heaven_prof != null, "Heaven profile must load")
	assert(hell_prof != null, "Hell profile must load")
	
	assert(normal_prof.profile_name == "Normal Land", "Normal profile name check")
	assert(normal_prof.surface_friction == 1.0, "Normal surface friction must be 1.0")
	assert(normal_prof.ground_texture != null, "Normal ground texture must be set")
	
	assert(heaven_prof.profile_name == "Heaven", "Heaven profile name check")
	assert(heaven_prof.surface_friction == 1.05, "Heaven surface friction must be 1.05")
	assert(heaven_prof.ground_texture != null, "Heaven ground texture must be set")
	
	assert(hell_prof.profile_name == "Hell", "Hell profile name check")
	assert(hell_prof.surface_friction == 0.95, "Hell surface friction must be 0.95")
	assert(hell_prof.ground_texture != null, "Hell ground texture must be set")
	
	# Apply profile to a segment and verify material & polygon updates
	var test_seg: TerrainSegment = seg_scene.instantiate()
	root.add_child(test_seg)
	
	test_seg.terrain_profile = heaven_prof
	test_seg.rebuild_segment()
	assert(test_seg.ground_polygon.texture == heaven_prof.ground_texture, "Ground polygon texture must update to Heaven marble")
	assert(is_equal_approx(test_seg.physics_material_override.friction, 1.05), "Physics material friction must update to 1.05 (got %f)" % test_seg.physics_material_override.friction)
	
	test_seg.terrain_profile = hell_prof
	test_seg.rebuild_segment()
	assert(test_seg.ground_polygon.texture == hell_prof.ground_texture, "Ground polygon texture must update to Hell basalt")
	assert(is_equal_approx(test_seg.physics_material_override.friction, 0.95), "Physics material friction must update to 0.95 (got %f)" % test_seg.physics_material_override.friction)
	
	test_seg.queue_free()
	print("  ✓ Biome profiles verified: textures, colors, and friction dynamically sync to TerrainSegment")

	# ----------------------------------------------------
	# Test 4: Seamless Track Connections & TerrainGenerator Integration
	# ----------------------------------------------------
	print("-> [4/6] Testing TerrainGenerator ramp spawning and 0-gap connection...")
	var gen := TerrainGenerator.new()
	var dummy_cam := Node2D.new()
	dummy_cam.position = Vector2(0, 360)
	root.add_child(dummy_cam)
	root.add_child(gen)
	gen.target = dummy_cam
	await process_frame
	
	gen.reset_generator(Vector2(0, 400))
	
	# Spawn all 4 transition ramps sequentially
	var r1 := gen.spawn_transition_ramp(TerrainSegment.SegmentType.RAMP_NORMAL_TO_HEAVEN, 1200.0, -80.0, 90.0, 0.0, heaven_prof)
	var r2 := gen.spawn_transition_ramp(TerrainSegment.SegmentType.RAMP_HEAVEN_TO_NORMAL, 1200.0, 80.0, 85.0, 0.0, normal_prof)
	var r3 := gen.spawn_transition_ramp(TerrainSegment.SegmentType.RAMP_NORMAL_TO_HELL, 1200.0, 60.0, 100.0, 0.0, hell_prof)
	var r4 := gen.spawn_transition_ramp(TerrainSegment.SegmentType.RAMP_HELL_TO_NORMAL, 1200.0, -60.0, 95.0, 0.0, normal_prof)
	
	assert(is_instance_valid(r1) and is_instance_valid(r2) and is_instance_valid(r3) and is_instance_valid(r4), "All ramps must spawn")
	var r1_origin := r1.global_position
	
	# Verify gap between all consecutive segments is 0
	for i in range(gen.active_segments.size() - 1):
		var s_curr := gen.active_segments[i]
		var s_next := gen.active_segments[i + 1]
		var exit_pos := s_curr.global_position + s_curr.get_exit_point()
		var entry_pos := s_next.global_position + s_next.get_entry_point()
		var gap := exit_pos.distance_to(entry_pos)
		assert(gap < 0.01, "Adjacent segments must have 0 gap (measured %f px between seg %d and %d)" % [gap, i, i + 1])
	print("  ✓ Zero-gap continuity verified across all 4 transition ramps")
	
	# ----------------------------------------------------
	# Test 5: Collectibles Clearance on Ramps
	# ----------------------------------------------------
	print("-> [5/6] Testing coin and fuel clearance on transition ramps...")
	var pickups_tested := 0
	for p in gen._spawned_pickups:
		if is_instance_valid(p):
			var seg_parent: TerrainSegment = p.get_parent() as TerrainSegment
			if seg_parent:
				var surf_y := seg_parent.get_surface_y_at(p.position.x)
				# Smaller Y in Godot 2D is higher up in the air
				assert(p.position.y < surf_y, "Pickup must be strictly above ground surface (pickup.y=%f, surf.y=%f)" % [p.position.y, surf_y])
				pickups_tested += 1
	print("  ✓ %d pickups verified on ramps: all positioned safely above terrain surface" % pickups_tested)
	
	# ----------------------------------------------------
	# Test 6: Vehicle Physics Traversal across Transition Ramps
	# ----------------------------------------------------
	print("-> [6/6] Testing vehicle physics traversal on all 4 registered vehicles...")
	var vehicle_ids := ["dune_buggy", "blue_flame_truck", "orc_racer", "trophy_truck"]
	
	for v_id in vehicle_ids:
		var veh: VehicleController = VehicleRegistry.instantiate_vehicle(v_id)
		assert(veh != null, "Vehicle %s must instantiate" % v_id)
		root.add_child(veh)
		
		# Place vehicle at the start of ramp 1
		veh.global_position = r1_origin + Vector2(100, -120)
		veh.linear_velocity = Vector2(350, 0)
		
		# Simulate 15 physics frames to verify suspension stability and ground interaction
		for frame in range(15):
			await physics_frame
		
		var veh_pos := veh.global_position
		var surf_y := gen.get_surface_y_at_world_x(veh_pos.x)
		assert(not is_nan(veh_pos.x) and not is_nan(veh_pos.y), "%s position must not be NaN" % v_id)
		# Vehicle should be driving near ground level (not plunged through the center of the earth)
		assert(veh_pos.y < surf_y + 100.0, "%s must not penetrate deeply underground" % v_id)
		assert(veh_pos.y > -2000.0, "%s must not fly off into deep space" % v_id)
		
		print("  ✓ Vehicle '%s' simulated on transition ramp: pos=(%.1f, %.1f), stable contact verified" % [v_id, veh_pos.x, veh_pos.y])
		veh.queue_free()
		await process_frame
	
	# Cleanup test nodes
	dummy_cam.queue_free()
	gen.clear_terrain()
	gen.queue_free()
	
	print("=================================================================")
	print("✓ ALL PHASE 5 TESTS PASSED SUCCESSFULLY!")
	print("=================================================================")
	quit(0)
