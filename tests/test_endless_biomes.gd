extends SceneTree

const TerrainGeneratorScript = preload("res://scripts/terrain/TerrainGenerator.gd")
const TerrainSegmentScript = preload("res://scripts/terrain/TerrainSegment.gd")
const ParallaxEnvironmentScript = preload("res://scripts/environment/ParallaxEnvironment.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN ENDLESS BIOMES & MULTI-ZONE ACCEPTANCE TEST SUITE ---")
	print("=================================================================")
	
	# ----------------------------------------------------
	# Test 1: TerrainSegment Multi-Biome Theming & Collision Invariance
	# ----------------------------------------------------
	print("-> [1/4] Verifying TerrainSegment multi-biome visual and collision synchronization...")
	var seg_scene: PackedScene = load("res://scenes/terrain/TerrainSegment.tscn")
	assert(seg_scene != null, "TerrainSegment.tscn must exist and load")
	
	var seg: TerrainSegment = seg_scene.instantiate()
	root.add_child(seg)
	
	var biomes = [
		TerrainSegment.BiomeType.COUNTRYSIDE,
		TerrainSegment.BiomeType.HEAVEN,
		TerrainSegment.BiomeType.HELL
	]
	
	for b in biomes:
		seg.biome_type = b
		seg.rebuild_segment()
		assert(seg.collision_polygon.polygon.size() > 0, "Biome %d: collision polygon must have vertices" % b)
		assert(seg.ground_polygon.polygon == seg.collision_polygon.polygon, "Biome %d: visual polygon and collision must match exactly" % b)
		if b == TerrainSegment.BiomeType.HEAVEN or b == TerrainSegment.BiomeType.HELL:
			assert(seg.grass_highlight_line.visible == true, "Biome %d: highlight line must be active" % b)
		else:
			assert(seg.grass_highlight_line.visible == false, "Biome %d: highlight line must be inactive" % b)
		print("  ✓ Biome %d (%s) geometry and collision verified: %d vertices" % [b, b, seg.collision_polygon.polygon.size()])
	
	seg.queue_free()
	print("✓ TerrainSegment multi-biome synchronization verified!")
	
	# ----------------------------------------------------
	# Test 2: ParallaxEnvironment Atmosphere Biome Switching
	# ----------------------------------------------------
	print("-> [2/4] Verifying ParallaxEnvironment atmospheric theme switching...")
	var parallax_scene: PackedScene = load("res://scenes/environment/ParallaxEnvironment.tscn")
	assert(parallax_scene != null, "ParallaxEnvironment.tscn must load")
	var parallax: ParallaxEnvironment = parallax_scene.instantiate()
	root.add_child(parallax)
	await process_frame
	
	parallax.set_biome_theme(1) # HEAVEN
	assert(parallax.mountain_range.color == Color(0.82, 0.88, 0.98, 0.85), "Heaven mountain range color mismatch")
	
	parallax.set_biome_theme(2) # HELL
	assert(parallax.mountain_range.color == Color(0.24, 0.12, 0.14, 0.95), "Hell mountain range color mismatch")
	
	parallax.set_biome_theme(0) # COUNTRYSIDE
	assert(parallax.mountain_range.color == Color(0.55, 0.62, 0.72, 0.95), "Countryside mountain range color mismatch")
	
	parallax.queue_free()
	print("✓ ParallaxEnvironment atmospheric theme switching verified!")
	
	# ----------------------------------------------------
	# Test 3: TerrainGenerator Biome Progression & Signal Emission
	# ----------------------------------------------------
	print("-> [3/4] Verifying TerrainGenerator biome progression across distances...")
	var gen: TerrainGenerator = TerrainGenerator.new()
	var dummy := Node2D.new()
	dummy.position = Vector2(0.0, 380.0)
	root.add_child(dummy)
	root.add_child(gen)
	gen.target = dummy
	gen.biome_interval_distance = 6000.0 # Shorter interval for rapid progression test
	gen.reset_generator(Vector2(0.0, 380.0))
	
	var detected_biomes: Array[int] = []
	gen.biome_changed.connect(func(b_id: int, b_name: String):
		detected_biomes.append(b_id)
		print("  [SIGNAL] Biome Transition Event: %d (%s)" % [b_id, b_name])
	)
	
	# Advance target to 7000px (~70m, entering Heaven)
	dummy.position.x = 7500.0
	gen._process(0.016)
	await process_frame
	
	# Advance target to 13500px (~135m, entering Hell)
	dummy.position.x = 14000.0
	gen._process(0.016)
	await process_frame
	
	assert(detected_biomes.has(1), "Generator must emit biome_changed for Heaven (1)")
	assert(detected_biomes.has(2), "Generator must emit biome_changed for Hell (2)")
	print("  ✓ Biome progression signals verified: %s" % str(detected_biomes))
	
	# ----------------------------------------------------
	# Test 4: Seamless Joints Across Biome Transitions
	# ----------------------------------------------------
	print("-> [4/4] Verifying seamless connections (0 gap) across biome transitions...")
	for i in range(gen.active_segments.size() - 1):
		var s1 := gen.active_segments[i]
		var s2 := gen.active_segments[i + 1]
		var p1 := s1.global_position + s1.get_exit_point()
		var p2 := s2.global_position + s2.get_entry_point()
		var gap := p1.distance_to(p2)
		assert(gap < 0.01, "Segments at index %d and %d have gap: %f px" % [i, i+1, gap])
	print("  ✓ All active segments across multiple biomes join with 0.00 px gap")
	
	dummy.queue_free()
	gen.queue_free()
	
	print("=================================================================")
	print("✓ ALL ENDLESS BIOMES & MULTI-ZONE TESTS PASSED (100%)!")
	print("=================================================================")
	quit(0)
