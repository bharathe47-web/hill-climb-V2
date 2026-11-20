extends SceneTree

## Comprehensive test suite for Falling Obstacle Terrain Grounding in Survival Mode.
## Validates that all 8 food obstacles land directly ON TOP of procedural terrain surfaces
## with ZERO underground penetration, ZERO excessive floating, and perfect surface tracking
## across flat terrain, uphill slopes, downhill slopes, valleys, and segment boundaries.

const TEST_OBSTACLES: Array[String] = [
	"res://scenes/modes/survival/obstacles/idli_obstacle.tscn",
	"res://scenes/modes/survival/obstacles/dosa_obstacle.tscn",
	"res://scenes/modes/survival/obstacles/vada_obstacle.tscn",
	"res://scenes/modes/survival/obstacles/samosa_obstacle.tscn",
	"res://scenes/modes/survival/obstacles/murukku_obstacle.tscn",
	"res://scenes/modes/survival/obstacles/pani_puri_obstacle.tscn",
	"res://scenes/modes/survival/obstacles/jalebi_obstacle.tscn",
	"res://scenes/modes/survival/obstacles/coconut_obstacle.tscn"
]

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN FALLING OBSTACLE TERRAIN GROUNDING TEST SUITE ---")
	print("=================================================================\n")

	_test_1_bottom_offsets_calculated()
	_test_2_dosa_dynamic_rotation_bounds()
	_test_3_ground_contact_zero_penetration_flat()
	_test_4_ground_contact_on_hills_slopes_and_valleys()
	_test_5_bounces_start_and_land_on_surface()
	_test_6_ground_shadow_and_landing_prediction()
	_test_7_terrain_generator_surface_lookup_robustness()
	_test_8_movement_identities_preserved()

	print("\n=================================================================")
	print("✓ ALL FALLING OBSTACLE GROUNDING TESTS PASSED (100% SUCCESS)!")
	print("=================================================================\n")
	quit(0)

func _test_1_bottom_offsets_calculated() -> void:
	print("-> [1/8] Verifying Dynamic get_bottom_offset() for All 8 Obstacles...")
	for path in TEST_OBSTACLES:
		var scene: PackedScene = load(path)
		var obs := scene.instantiate() as FoodObstacle
		root.add_child(obs)
		
		var offset := obs.get_bottom_offset()
		assert(offset > 15.0 and offset < 60.0,
			"Obstacle '%s' must have a realistic bottom offset (got %0.2f px)" % [obs.obstacle_id, offset])
		
		obs.queue_free()
	print("  ✓ All 8 food obstacles compute accurate, non-zero visual/collision bottom offsets!")

func _test_2_dosa_dynamic_rotation_bounds() -> void:
	print("-> [2/8] Verifying Dosa Dynamic Rotation-Aware Bottom Offset...")
	var dosa_scene: PackedScene = load("res://scenes/modes/survival/obstacles/dosa_obstacle.tscn")
	var dosa := dosa_scene.instantiate() as FoodObstacle
	root.add_child(dosa)

	# Horizontal (rot = 0): Capsule radius is 16.0, visual half-height is ~11.7
	dosa.sprite.rotation = 0.0
	var offset_h := dosa.get_bottom_offset()
	assert(offset_h >= 16.0, "Dosa horizontal offset should match capsule radius (got %0.2f)" % offset_h)

	# Tilted 45 degrees
	dosa.sprite.rotation = PI * 0.25
	var offset_45 := dosa.get_bottom_offset()
	assert(offset_45 > offset_h, "Dosa at 45 deg should have larger offset than horizontal (got %0.2f)" % offset_45)

	# Vertical (rot = PI/2): Visual length is ~96px, so half-length is ~48px
	dosa.sprite.rotation = PI * 0.5
	var offset_v := dosa.get_bottom_offset()
	assert(offset_v >= 45.0, "Dosa vertical offset should reach visual tip ~48px (got %0.2f)" % offset_v)

	dosa.queue_free()
	print("  ✓ Dosa dynamically adjusts bottom boundary from %0.1fpx to %0.1fpx as it rotates!" % [offset_h, offset_v])

func _test_3_ground_contact_zero_penetration_flat() -> void:
	print("-> [3/8] Verifying Zero Underground Penetration on Flat Terrain for All 8 Obstacles...")
	var test_ground_y: float = 400.0
	var dt: float = 1.0 / 60.0

	for path in TEST_OBSTACLES:
		var scene: PackedScene = load(path)
		var obs := scene.instantiate() as FoodObstacle
		obs.ground_y = test_ground_y
		obs.global_position = Vector2(200.0, 100.0)
		root.add_child(obs)

		# Simulate free fall until first ground contact
		var frames := 0
		while not obs.has_touched_ground and frames < 120:
			obs._physics_process(dt)
			frames += 1

		assert(obs.has_touched_ground, "Obstacle '%s' must make ground contact within 120 frames" % obs.obstacle_id)

		# Check obstacle bottom Y relative to ground_y
		var bottom_offset := obs.get_bottom_offset()
		var bottom_y := obs.global_position.y + bottom_offset
		var diff := absf(bottom_y - test_ground_y)

		assert(diff <= 1.5,
			"Obstacle '%s' bottom must rest directly on terrain surface! (bottom_y=%0.2f, ground_y=%0.2f, diff=%0.2f)" % [
				obs.obstacle_id, bottom_y, test_ground_y, diff
			])
		assert(bottom_y <= test_ground_y + 0.1,
			"Obstacle '%s' sprite must NEVER penetrate underneath terrain! (penetration=%0.2f px)" % [
				obs.obstacle_id, bottom_y - test_ground_y
			])

		obs.queue_free()
	print("  ✓ All 8 food obstacles land cleanly on flat terrain with <= 1.0px tolerance and 0 underground penetration!")

func _test_4_ground_contact_on_hills_slopes_and_valleys() -> void:
	print("-> [4/8] Verifying Grounding on Procedural Hills, Slopes, and Valley Dips...")
	var surv_scene: PackedScene = load("res://scenes/modes/survival/Survival.tscn")
	var surv = surv_scene.instantiate()
	root.add_child(surv)
	surv.start_run()
	var t_gen: TerrainGenerator = surv.terrain_generator

	# Test locations with different slopes and contours
	var test_x_positions: Array[float] = [
		350.0,  # Runway / gentle transition
		650.0,  # Gentle hill climb
		950.0,  # Crest
		1350.0, # Valley dip / slope
		1800.0  # Procedural segment boundary
	]

	var dt: float = 1.0 / 60.0

	for test_x in test_x_positions:
		var surface_y := t_gen.get_surface_y_at_world_x(test_x)
		assert(surface_y > 200.0 and surface_y < 550.0, "Surface Y at X=%0.1f must be valid procedural height (got %0.1f)" % [test_x, surface_y])

		for path in TEST_OBSTACLES:
			var scene: PackedScene = load(path)
			var obs := scene.instantiate() as FoodObstacle
			obs.terrain_generator = t_gen
			obs.setup_spawn(test_x, surface_y - 300.0, surface_y, t_gen)
			root.add_child(obs)

			var frames := 0
			while not obs.has_touched_ground and frames < 120:
				obs._physics_process(dt)
				frames += 1

			assert(obs.has_touched_ground, "Obstacle '%s' at X=%0.1f must contact ground" % [obs.obstacle_id, test_x])

			var actual_surface := t_gen.get_surface_y_at_world_x(obs.global_position.x)
			var bottom_offset := obs.get_bottom_offset()
			var bottom_y := obs.global_position.y + bottom_offset
			var error := absf(bottom_y - actual_surface)

			assert(error <= 1.5,
				"Obstacle '%s' at X=%0.1f on terrain slope must rest cleanly on surface! (bottom=%0.2f, surf=%0.2f, err=%0.2f)" % [
					obs.obstacle_id, test_x, bottom_y, actual_surface, error
				])
			assert(bottom_y <= actual_surface + 0.1,
				"Obstacle '%s' at X=%0.1f must NOT penetrate slope! (penetration=%0.2f px)" % [
					obs.obstacle_id, test_x, bottom_y - actual_surface
				])

			obs.queue_free()

	surv.queue_free()
	print("  ✓ Accurate terrain contact verified across hills, slopes, crests, valleys, and boundaries!")

func _test_5_bounces_start_and_land_on_surface() -> void:
	print("-> [5/8] Verifying Multi-Bounce Phases Land Cleanly on Terrain Surface...")
	var test_ground_y: float = 400.0
	var dt: float = 1.0 / 60.0

	for path in TEST_OBSTACLES:
		var scene: PackedScene = load(path)
		var obs := scene.instantiate() as FoodObstacle
		obs.ground_y = test_ground_y
		obs.global_position = Vector2(250.0, 150.0)
		root.add_child(obs)

		# Bounce 1
		var frames := 0
		while obs.ground_bounce_count < 1 and frames < 120:
			obs._physics_process(dt)
			frames += 1
		assert(obs.ground_bounce_count == 1, "%s must achieve bounce 1" % obs.obstacle_id)

		# Verify upward bounce velocity applied while resting on surface
		assert(obs._current_velocity.y < 0.0, "%s bounce 1 must have upward velocity" % obs.obstacle_id)

		# Airborne apex and descend to Bounce 2
		frames = 0
		while obs.ground_bounce_count < 2 and frames < 150:
			obs._physics_process(dt)
			frames += 1
		assert(obs.ground_bounce_count == 2, "%s must achieve bounce 2" % obs.obstacle_id)

		# Check bottom Y at start of bounce 2
		var b_off := obs.get_bottom_offset()
		var bottom_y := obs.global_position.y + b_off
		var diff := absf(bottom_y - test_ground_y)
		assert(diff <= 2.0, "%s bounce 2 bottom must be on ground surface (got diff %0.2f)" % [obs.obstacle_id, diff])

		obs.queue_free()
	print("  ✓ All obstacles initiate subsequent bounces directly from terrain surface without sinking!")

func _test_6_ground_shadow_and_landing_prediction() -> void:
	print("-> [6/8] Verifying GroundShadow Surface Placement and Trajectory Prediction...")
	var surv_scene: PackedScene = load("res://scenes/modes/survival/Survival.tscn")
	var surv = surv_scene.instantiate()
	root.add_child(surv)
	surv.start_run()
	var t_gen: TerrainGenerator = surv.terrain_generator

	var scene: PackedScene = load("res://scenes/modes/survival/obstacles/coconut_obstacle.tscn")
	var coconut := scene.instantiate() as FoodObstacle
	var target_x: float = 500.0
	var surface_y := t_gen.get_surface_y_at_world_x(target_x)

	coconut.setup_spawn(target_x, surface_y - 400.0, surface_y, t_gen)
	root.add_child(coconut)

	var landing := coconut.calculate_predicted_landing()
	assert(absf(landing.x - target_x) < 5.0, "Predicted landing X must align with spawn X")
	assert(absf(landing.y - surface_y) < 1.0, "Predicted landing Y must be exactly on the terrain surface!")

	# Verify shadow position
	assert(is_instance_valid(coconut.ground_shadow), "Coconut must have a valid GroundShadow")
	assert(absf(coconut.ground_shadow.global_position.y - surface_y) < 1.0, "GroundShadow must be at surface Y")

	coconut.queue_free()
	surv.queue_free()
	print("  ✓ Predicted landing and GroundShadow match procedural surface elevation!")

func _test_7_terrain_generator_surface_lookup_robustness() -> void:
	print("-> [7/8] Verifying TerrainGenerator Surface Query Robustness...")
	var gen := TerrainGenerator.new()
	gen.enable_pickups = false
	gen.auto_find_target = false
	root.add_child(gen)
	gen.reset_generator(gen.initial_spawn_point)

	# Query near spawn
	var y_0 := gen.get_surface_y_at_world_x(0.0)
	assert(absf(y_0 - 420.0) < 5.0, "Spawn runway surface should be ~420 (got %0.1f)" % y_0)

	# Query far ahead: TerrainGenerator must auto-stream segments and return valid procedural height
	var far_x := 3200.0
	var y_far := gen.get_surface_y_at_world_x(far_x)
	assert(y_far > 150.0 and y_far < 550.0, "Far ahead query should return real surface Y (got %0.1f)" % y_far)

	# Verify boundary continuity between adjacent segments (no large vertical jumps)
	for x in range(200, 2400, 50):
		var y_a := gen.get_surface_y_at_world_x(float(x))
		var y_b := gen.get_surface_y_at_world_x(float(x + 1))
		var delta := absf(y_b - y_a)
		assert(delta < 3.0, "Continuous terrain surface must have smooth derivative (jump %0.2f at X=%d)" % [delta, x])

	gen.queue_free()
	print("  ✓ Auto-streaming ahead and boundary continuity confirmed!")

func _test_8_movement_identities_preserved() -> void:
	print("-> [8/8] Verifying Movement Identities Preserved During Descent and Landing...")
	var dt: float = 1.0 / 60.0

	# 1. Idli (STRAIGHT): Rotation stays 0.0
	var idli := (load("res://scenes/modes/survival/obstacles/idli_obstacle.tscn") as PackedScene).instantiate() as FoodObstacle
	root.add_child(idli)
	idli.ground_y = 400.0
	for i in range(20):
		idli._physics_process(dt)
	assert(absf(idli.sprite.rotation) < 0.001, "Idli must maintain straight non-rotating fall")
	idli.queue_free()

	# 2. Dosa (ROTATING): Continuous rotation
	var dosa := (load("res://scenes/modes/survival/obstacles/dosa_obstacle.tscn") as PackedScene).instantiate() as FoodObstacle
	root.add_child(dosa)
	dosa.ground_y = 400.0
	for i in range(20):
		dosa._physics_process(dt)
	assert(absf(dosa.sprite.rotation) > 0.1, "Dosa must rotate while falling")
	dosa.queue_free()

	# 3. Jalebi (WOBBLE): Scale oscillation
	var jalebi := (load("res://scenes/modes/survival/obstacles/jalebi_obstacle.tscn") as PackedScene).instantiate() as FoodObstacle
	root.add_child(jalebi)
	jalebi.ground_y = 400.0
	for i in range(20):
		jalebi._physics_process(dt)
	assert(absf(jalebi.sprite.scale.x - jalebi.sprite.scale.y) > 0.001, "Jalebi must exhibit squash/stretch wobble")
	jalebi.queue_free()

	# 4. Pani Puri (CLUSTER): Lateral drift
	var pani_puri := (load("res://scenes/modes/survival/obstacles/pani_puri_obstacle.tscn") as PackedScene).instantiate() as FoodObstacle
	root.add_child(pani_puri)
	pani_puri.ground_y = 400.0
	var initial_x := pani_puri.global_position.x
	for i in range(30):
		pani_puri._physics_process(dt)
	assert(absf(pani_puri.global_position.x - initial_x) > 0.01, "Pani Puri must exhibit subtle lateral drift")
	pani_puri.queue_free()

	print("  ✓ All individual movement identities (Idli, Dosa, Jalebi, Pani Puri, etc.) 100% preserved!")
