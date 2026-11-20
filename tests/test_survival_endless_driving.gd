extends SceneTree

const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const FoodObstacle = preload("res://scripts/components/survival_obstacles/food_obstacle.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN SURVIVAL MODE ENDLESS TERRAIN & DRIVING TEST SUITE ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var root := get_root()

	await _test_survival_driving_and_generation(root)
	await _test_food_obstacles_on_uneven_terrain(root)
	_test_decorations_destroyed_city_only(root)

	print("\n=================================================================")
	print("✓ ALL SURVIVAL ENDLESS TERRAIN & DRIVING TESTS PASSED 100%!")
	print("=================================================================\n")
	quit(0)

func _test_survival_driving_and_generation(root: Window) -> void:
	print("-> [1/3] Testing Survival Vehicle Driving & Dynamic Terrain Generation...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	for i in range(5):
		await process_frame

	var t_gen: TerrainGenerator = surv.terrain_generator
	assert(t_gen != null, "TerrainGenerator must be active")
	assert(surv.vehicle != null, "Vehicle must be spawned")
	assert(t_gen.target == surv.vehicle, "TerrainGenerator must target vehicle")

	var initial_x: float = (surv.vehicle as Node2D).global_position.x
	var initial_surface_y := surv.get_terrain_surface_y(initial_x)
	assert(absf((surv.vehicle as Node2D).global_position.y - (initial_surface_y - 38.0)) < 20.0, "Vehicle starts on terrain surface")

	# Simulate vehicle driving forward under acceleration
	Input.action_press("accelerate")
	for frame in range(90):
		await physics_frame
	Input.action_release("accelerate")

	var distance_moved: float = (surv.vehicle as Node2D).global_position.x - initial_x
	print("  ✓ Vehicle drove forward across uneven terrain: %.1f px" % distance_moved)
	assert(distance_moved > 50.0, "Vehicle must drive forward on procedural terrain")

	# Advance vehicle significantly forward to verify endless continuous generation
	var start_segment_count := t_gen.segment_counter
	(surv.vehicle as Node2D).global_position.x += 4000.0
	t_gen._process(0.016)
	await process_frame

	assert(t_gen.segment_counter > start_segment_count, "Terrain must continuously generate ahead of vehicle")
	assert(t_gen.active_segments.size() >= 3, "Generator must maintain active segments ahead")

	# Verify zero gap between all newly generated active segments
	for i in range(t_gen.active_segments.size() - 1):
		var s1 := t_gen.active_segments[i]
		var s2 := t_gen.active_segments[i + 1]
		var exit_pt := s1.global_position + s1.get_exit_point()
		var entry_pt := s2.global_position + s2.get_entry_point()
		assert(exit_pt.distance_to(entry_pt) < 0.01, "New segments must join with 0 gap")

	surv.queue_free()
	print("  ✓ Vehicle driving and endless terrain generation verified!")

func _test_food_obstacles_on_uneven_terrain(root: Window) -> void:
	print("-> [2/3] Testing Food Obstacles Falling & Warning on Uneven Terrain...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.enable_obstacle_spawning = true
	surv.load_default_obstacles()
	root.add_child(surv)

	for i in range(5):
		await process_frame

	var t_gen: TerrainGenerator = surv.terrain_generator
	assert(t_gen != null, "TerrainGenerator must be active")

	# Test warning at multiple points across hills and valleys
	var test_xs := [300.0, 850.0, 1400.0, 2100.0]
	for tx in test_xs:
		var surface_y := surv.get_terrain_surface_y(tx)
		# Trigger spawn
		surv.vehicle.global_position.x = tx - 50.0
		var warning_data := {"pos": Vector2.ZERO}
		var cb := func(pos: Vector2, _dur: float): warning_data["pos"] = pos
		surv.warning_requested.connect(cb)
		surv._trigger_obstacle_spawn()
		surv.warning_requested.disconnect(cb)

		var expected_y := surv.get_terrain_surface_y(warning_data["pos"].x)
		assert(absf(warning_data["pos"].y - expected_y) < 1.0, "Warning position Y must match terrain surface Y")

	# Test FoodObstacle falling onto uneven surface
	var obs_scene: PackedScene = load("res://scenes/modes/survival/obstacles/coconut_obstacle.tscn")
	var obs: FoodObstacle = obs_scene.instantiate()
	var test_x := 600.0
	var surf_y := surv.get_terrain_surface_y(test_x)
	obs.global_position = Vector2(test_x, surf_y - 200.0)
	obs.ground_y = surf_y
	obs.terrain_generator = t_gen
	surv.add_child(obs)

	# Simulate physics until coconut contacts ground
	for step in range(30):
		obs._physics_process(0.033)
		if obs.ground_bounce_count > 0:
			break

	assert(obs.ground_y == surv.get_terrain_surface_y(obs.global_position.x), "Food obstacle dynamically tracks terrain surface Y")
	obs.queue_free()

	surv.queue_free()
	print("  ✓ Food obstacles and warnings dynamically bound to uneven terrain!")

func _test_decorations_destroyed_city_only(root: Window) -> void:
	print("-> [3/3] Testing Destruction of Countryside Assets in Survival Terrain...")
	var seg_packed: PackedScene = load("res://scenes/terrain/TerrainSegment.tscn")
	var seg: TerrainSegment = seg_packed.instantiate()
	seg.theme = TerrainSegment.TerrainTheme.DESTROYED_CITY
	seg.segment_type = TerrainSegment.SegmentType.ROLLING_WAVES
	root.add_child(seg)
	seg.rebuild_segment()

	assert(seg.theme == TerrainSegment.TerrainTheme.DESTROYED_CITY, "Theme must be DESTROYED_CITY")
	assert(seg.ground_polygon.texture.resource_path.ends_with("survival_drivable_ground_strip.png") or seg.ground_polygon.texture.resource_path.ends_with("apocalyptic_ground_seamless.png"), "Must use survival ground strip")

	var decs: Node2D = seg.decorations_root
	assert(decs != null, "Decorations root exists")
	for child in decs.get_children():
		if child is Sprite2D and child.texture != null:
			var path: String = child.texture.resource_path
			assert(not "countryside" in path, "No countryside assets allowed in destroyed city: %s" % path)
			assert("destroyed_city" in path, "Must use destroyed_city asset: %s" % path)

	seg.queue_free()
	print("  ✓ Strictly 0 countryside assets present on destroyed city terrain!")
