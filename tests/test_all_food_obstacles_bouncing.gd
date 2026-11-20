extends SceneTree

## Automated test suite verifying universal ground-bouncing across ALL 8 Indian food obstacles.
## Confirms each obstacle's distinct movement identity is preserved, bounce count increments,
## bounce height diminishes, and vehicle collision works cleanly.

const OBSTACLES := [
	{"id": "idli", "path": "res://scenes/modes/survival/obstacles/idli_obstacle.tscn", "type": FoodObstacle.MovementType.STRAIGHT},
	{"id": "dosa", "path": "res://scenes/modes/survival/obstacles/dosa_obstacle.tscn", "type": FoodObstacle.MovementType.ROTATING},
	{"id": "vada", "path": "res://scenes/modes/survival/obstacles/vada_obstacle.tscn", "type": FoodObstacle.MovementType.SPINNING},
	{"id": "samosa", "path": "res://scenes/modes/survival/obstacles/samosa_obstacle.tscn", "type": FoodObstacle.MovementType.TUMBLING},
	{"id": "murukku", "path": "res://scenes/modes/survival/obstacles/murukku_obstacle.tscn", "type": FoodObstacle.MovementType.SPINNING},
	{"id": "pani_puri", "path": "res://scenes/modes/survival/obstacles/pani_puri_obstacle.tscn", "type": FoodObstacle.MovementType.CLUSTER},
	{"id": "jalebi", "path": "res://scenes/modes/survival/obstacles/jalebi_obstacle.tscn", "type": FoodObstacle.MovementType.WOBBLE},
	{"id": "coconut", "path": "res://scenes/modes/survival/obstacles/coconut_obstacle.tscn", "type": FoodObstacle.MovementType.BOUNCE}
]

const SurvivalScene: PackedScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const LandingDustClass = preload("res://scripts/components/effects/landing_dust_effect.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN ALL 8 FOOD OBSTACLES UNIVERSAL BOUNCING TEST SUITE ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var root := get_root()

	_test_1_universal_bounce_initialization(root)
	_test_2_all_eight_obstacles_bounce_physics_and_count(root)
	_test_3_diminishing_bounce_height_progression(root)
	_test_4_preserve_individual_movement_identities(root)
	_test_5_pani_puri_cluster_moves_together(root)
	_test_6_bouncing_on_uneven_procedural_terrain(root)
	_test_7_vehicle_collision_during_bounce(root)

	print("\n=================================================================")
	print("✓ ALL 8 FOOD OBSTACLE BOUNCING TESTS PASSED (100% SUCCESS)!")
	print("=================================================================\n")
	quit(0)

func _test_1_universal_bounce_initialization(root: Window) -> void:
	print("-> [1/7] Verifying Universal Bounce Initialization for All 8 Obstacles...")
	for item in OBSTACLES:
		var scene: PackedScene = load(item["path"])
		assert(scene != null, "Scene %s must exist" % item["path"])
		var obs: FoodObstacle = scene.instantiate()
		root.add_child(obs)

		assert(obs.movement_type == item["type"], "Movement type preserved for %s" % item["id"])
		assert(obs.max_bounces == 2, "%s must have max_bounces == 2" % item["id"])
		assert(obs._bounces_left == 2, "%s must initialize _bounces_left == 2" % item["id"])
		assert(obs.ground_bounce_count == 0, "%s must start with ground_bounce_count == 0" % item["id"])
		assert(absf(obs.bounce_velocity - (-280.0)) < 1.0, "%s bounce_velocity should be -280.0" % item["id"])

		obs.queue_free()

	print("  ✓ All 8 food obstacles universally initialized with 2 bounces and 0 bounce count!")

func _test_2_all_eight_obstacles_bounce_physics_and_count(root: Window) -> void:
	print("-> [2/7] Verifying Bounce Physics, Velocity Reversal & Count Increment on All 8...")
	for item in OBSTACLES:
		var scene: PackedScene = load(item["path"])
		var obs: FoodObstacle = scene.instantiate()
		obs.global_position = Vector2(300.0, 390.0)
		obs.ground_y = 400.0
		root.add_child(obs)

		# Initial state
		assert(obs.ground_bounce_count == 0, "Starts at 0 bounces")
		assert(obs._bounces_left == 2, "Starts with 2 bounces left")
		assert(obs._has_hit == false, "Starts unhit")

		# First ground contact
		obs.global_position.y = 401.0
		obs._current_velocity.y = 350.0
		obs._physics_process(0.016)

		assert(obs.ground_bounce_count == 1, "%s ground_bounce_count incremented to 1" % item["id"])
		assert(obs._bounces_left == 1, "%s _bounces_left decremented to 1" % item["id"])
		assert(obs._current_velocity.y < 0.0, "%s upward bounce velocity applied" % item["id"])
		assert(obs._has_hit == false, "%s still alive during bounce" % item["id"])

		# Second ground contact
		obs.global_position.y = 401.0
		obs._current_velocity.y = 250.0
		obs._physics_process(0.016)

		assert(obs.ground_bounce_count == 2, "%s ground_bounce_count incremented to 2" % item["id"])
		assert(obs._bounces_left == 0, "%s _bounces_left decremented to 0" % item["id"])
		assert(obs._current_velocity.y < 0.0, "%s upward bounce velocity applied on second bounce" % item["id"])
		assert(obs._has_hit == false, "%s still alive during second bounce" % item["id"])

		# Final ground contact (bounces exhausted -> cleanup)
		obs.global_position.y = 401.0
		obs._current_velocity.y = 200.0
		obs._physics_process(0.016)

		assert(obs.ground_bounce_count == 2, "%s ground_bounce_count remains 2 after exhaustion" % item["id"])
		assert(obs._bounces_left == 0, "%s _bounces_left is 0" % item["id"])
		assert(obs._has_hit == true, "%s executes ground impact cleanup after exhausting bounces" % item["id"])

		obs.queue_free()

	print("  ✓ All 8 food obstacles successfully bounce twice, track bounce count, and clean up!")

func _test_3_diminishing_bounce_height_progression(root: Window) -> void:
	print("-> [3/7] Verifying Diminishing Bounce Height (0.65 damping) on All 8 Obstacles...")
	for item in OBSTACLES:
		var scene: PackedScene = load(item["path"])
		var obs: FoodObstacle = scene.instantiate()
		obs.global_position = Vector2(300.0, 390.0)
		obs.ground_y = 400.0
		root.add_child(obs)

		# First bounce
		obs.global_position.y = 401.0
		obs._current_velocity.y = 300.0
		obs._physics_process(0.016)
		var v1: float = absf(obs._current_velocity.y)

		# Second bounce
		obs.global_position.y = 401.0
		obs._current_velocity.y = 300.0
		obs._physics_process(0.016)
		var v2: float = absf(obs._current_velocity.y)

		# Verify reduction: v2 must be less than v1 (0.65 scaling factor)
		assert(v2 < v1, "%s bounce 2 speed (%f) must be less than bounce 1 speed (%f)" % [item["id"], v2, v1])
		var ratio: float = v2 / v1
		assert(absf(ratio - 0.65) < 0.05, "%s dampening ratio should be ~0.65 (got %f)" % [item["id"], ratio])

		obs.queue_free()

	print("  ✓ Consistent diminishing bounce height confirmed across all 8 obstacles!")

func _test_4_preserve_individual_movement_identities(root: Window) -> void:
	print("-> [4/7] Verifying Individual Movement Identities Preserved During Falling & Bouncing...")
	# 1. Idli: STRAIGHT (no rotation)
	var idli_scene: PackedScene = load("res://scenes/modes/survival/obstacles/idli_obstacle.tscn")
	var idli: FoodObstacle = idli_scene.instantiate()
	root.add_child(idli)
	var idli_spr: Sprite2D = idli.get_node("Sprite2D")
	var r0: float = idli_spr.rotation
	idli._physics_process(0.1)
	assert(idli_spr.rotation == r0, "Idli must remain straight (no rotation)")
	idli._trigger_bounce()
	idli._physics_process(0.1)
	assert(idli_spr.rotation == r0, "Idli must remain straight during bounce")
	idli.queue_free()

	# 2. Dosa: ROTATING
	var dosa_scene: PackedScene = load("res://scenes/modes/survival/obstacles/dosa_obstacle.tscn")
	var dosa: FoodObstacle = dosa_scene.instantiate()
	root.add_child(dosa)
	var dosa_spr: Sprite2D = dosa.get_node("Sprite2D")
	dosa._physics_process(0.1)
	assert(dosa_spr.rotation > 0.0, "Dosa must rotate while falling")
	var dosa_rot1: float = dosa_spr.rotation
	dosa._trigger_bounce()
	dosa._physics_process(0.1)
	assert(dosa_spr.rotation > dosa_rot1, "Dosa continues rotating during bounce")
	dosa.queue_free()

	# 3. Vada & Murukku: SPINNING (fast rotation)
	var vada_scene: PackedScene = load("res://scenes/modes/survival/obstacles/vada_obstacle.tscn")
	var vada: FoodObstacle = vada_scene.instantiate()
	root.add_child(vada)
	var vada_spr: Sprite2D = vada.get_node("Sprite2D")
	vada._physics_process(0.1)
	assert(vada_spr.rotation > 0.5, "Vada spins rapidly")
	vada._trigger_bounce()
	var vada_rot1: float = vada_spr.rotation
	vada._physics_process(0.1)
	assert(vada_spr.rotation > vada_rot1, "Vada continues spinning during bounce")
	vada.queue_free()

	# 4. Samosa: TUMBLING
	var samosa_scene: PackedScene = load("res://scenes/modes/survival/obstacles/samosa_obstacle.tscn")
	var samosa: FoodObstacle = samosa_scene.instantiate()
	root.add_child(samosa)
	var sam_spr: Sprite2D = samosa.get_node("Sprite2D")
	samosa._physics_process(0.1)
	assert(sam_spr.rotation > 0.3, "Samosa tumbles while falling")
	samosa._trigger_bounce()
	var sam_rot1: float = sam_spr.rotation
	samosa._physics_process(0.1)
	assert(sam_spr.rotation > sam_rot1, "Samosa continues tumbling during bounce")
	samosa.queue_free()

	# 5. Jalebi: WOBBLE (scale pulsation + rotation)
	var jalebi_scene: PackedScene = load("res://scenes/modes/survival/obstacles/jalebi_obstacle.tscn")
	var jalebi: FoodObstacle = jalebi_scene.instantiate()
	root.add_child(jalebi)
	var jal_spr: Sprite2D = jalebi.get_node("Sprite2D")
	var init_scale: Vector2 = jal_spr.scale
	jalebi._physics_process(0.15)
	assert(jal_spr.scale != init_scale, "Jalebi wobbles scale during fall")
	jalebi._trigger_bounce()
	jalebi._physics_process(0.15)
	assert(jal_spr.scale != init_scale, "Jalebi wobbles scale during bounce")
	jalebi.queue_free()

	# 6. Coconut: BOUNCE (existing reference preserved)
	var coco_scene: PackedScene = load("res://scenes/modes/survival/obstacles/coconut_obstacle.tscn")
	var coco: FoodObstacle = coco_scene.instantiate()
	root.add_child(coco)
	assert(coco.movement_type == FoodObstacle.MovementType.BOUNCE, "Coconut movement type preserved")
	coco._physics_process(0.1)
	coco._trigger_bounce()
	assert(coco.ground_bounce_count == 1, "Coconut bounce count incremented")
	assert(coco._bounces_left == 1, "Coconut bounces left is 1")
	coco.queue_free()

	print("  ✓ All movement identities (straight, rotating, spinning, tumbling, wobbling, cluster, bounce) preserved!")

func _test_5_pani_puri_cluster_moves_together(root: Window) -> void:
	print("-> [5/7] Verifying Pani Puri Cluster Bounces Together as a Coordinated Unit...")
	var scene: PackedScene = load("res://scenes/modes/survival/obstacles/pani_puri_obstacle.tscn")
	var pp: FoodObstacle = scene.instantiate()
	pp.global_position = Vector2(250.0, 390.0)
	pp.ground_y = 400.0
	root.add_child(pp)

	var p1: Sprite2D = pp.get_node("Sprite2D")
	var p2: Sprite2D = pp.get_node("Piece2")
	var p3: Sprite2D = pp.get_node("Piece3")
	assert(p1 != null and p2 != null and p3 != null, "All cluster pieces exist in Pani Puri scene")

	var initial_offset_2: Vector2 = p2.position
	var initial_offset_3: Vector2 = p3.position

	# Trigger bounce
	pp.global_position.y = 401.0
	pp._current_velocity.y = 300.0
	pp._physics_process(0.016)

	assert(pp.ground_bounce_count == 1, "Pani Puri ground bounce count is 1")
	assert(pp._current_velocity.y < 0.0, "Pani Puri bouncing upward")

	# Simulate 5 airborne bounce frames
	for frame in range(5):
		pp._physics_process(0.016)
		# Verify relative piece offsets remain rigid within cluster
		assert(p2.position == initial_offset_2, "Piece2 maintains cluster relative position")
		assert(p3.position == initial_offset_3, "Piece3 maintains cluster relative position")
		# Verify global positions moved upward with the root
		assert(p1.global_position.y == pp.global_position.y, "Main piece global Y matches root Y")
		assert(p2.global_position.y == pp.global_position.y + initial_offset_2.y, "Piece2 global Y matches root Y + offset")
		assert(p3.global_position.y == pp.global_position.y + initial_offset_3.y, "Piece3 global Y matches root Y + offset")

	pp.queue_free()
	print("  ✓ Complete Pani Puri cluster bounces together cleanly with zero piece separation!")

func _test_6_bouncing_on_uneven_procedural_terrain(root: Window) -> void:
	print("-> [6/7] Verifying Bouncing on Uneven Procedural Terrain Elevations...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	surv.load_default_obstacles()
	root.add_child(surv)

	for item in OBSTACLES:
		var scene: PackedScene = load(item["path"])
		var obs: FoodObstacle = scene.instantiate()
		obs.terrain_generator = surv.terrain_generator

		# Place at an arbitrary X on procedural terrain
		var test_x := randf_range(200.0, 1200.0)
		var surf_y := surv.get_terrain_surface_y(test_x)
		obs.global_position = Vector2(test_x, surf_y - 20.0)
		obs.ground_y = surf_y
		surv.obstacle_container.add_child(obs)

		# Fall onto uneven terrain
		obs.global_position.y = surf_y + 1.0
		obs._current_velocity.y = 300.0
		obs._physics_process(0.016)

		assert(obs.ground_bounce_count == 1, "%s bounced on terrain at Y=%f" % [item["id"], surf_y])
		assert(obs._current_velocity.y < 0.0, "%s velocity reversed upward on terrain" % item["id"])
		assert(absf(obs.ground_y - surf_y) < 2.0, "%s ground_y accurately tracks terrain surface Y" % item["id"])

		obs.queue_free()

	surv.queue_free()
	print("  ✓ All 8 food obstacles bounce dynamically off uneven procedural terrain!")

func _test_7_vehicle_collision_during_bounce(root: Window) -> void:
	print("-> [7/7] Verifying Damage Disabled After First Ground Contact Across All 8 Obstacles...")
	var mock_veh := Area2D.new()
	mock_veh.name = "Vehicle"
	root.add_child(mock_veh)

	for item in OBSTACLES:
		var scene: PackedScene = load(item["path"])

		# 1. Test falling before ground contact: damage enabled
		var obs_falling: FoodObstacle = scene.instantiate()
		obs_falling.global_position = Vector2(200.0, 200.0)
		obs_falling.ground_y = 400.0
		root.add_child(obs_falling)
		assert(obs_falling.can_damage_vehicle == true, "%s has damage enabled while falling" % item["id"])
		assert(obs_falling.has_touched_ground == false, "%s has not touched ground yet" % item["id"])

		var falling_hit := {"hit": false}
		obs_falling.obstacle_hit.connect(func(id, _pos):
			falling_hit["hit"] = true
		)
		obs_falling._on_area_entered(mock_veh)
		assert(falling_hit["hit"] == true, "%s directly hitting vehicle while falling emits hit" % item["id"])
		assert(obs_falling._has_hit == true, "%s marks _has_hit on direct falling hit" % item["id"])
		obs_falling.queue_free()

		# 2. Test active mid-bounce: damage DISABLED
		var obs_bounced: FoodObstacle = scene.instantiate()
		obs_bounced.global_position = Vector2(200.0, 390.0)
		obs_bounced.ground_y = 400.0
		root.add_child(obs_bounced)

		# Trigger first ground bounce
		obs_bounced.global_position.y = 401.0
		obs_bounced._current_velocity.y = 300.0
		obs_bounced._physics_process(0.016)

		assert(obs_bounced.has_touched_ground == true, "%s marked has_touched_ground=true" % item["id"])
		assert(obs_bounced.can_damage_vehicle == false, "%s has can_damage_vehicle=false after ground contact" % item["id"])
		assert(obs_bounced.ground_bounce_count == 1, "Obstacle is at bounce 1")
		assert(obs_bounced._has_hit == false, "Obstacle is still active during bounce")

		var bounced_hit := {"hit": false}
		obs_bounced.obstacle_hit.connect(func(id, _pos):
			bounced_hit["hit"] = true
		)

		# Simulate collision with vehicle while bouncing
		obs_bounced._on_area_entered(mock_veh)

		assert(bounced_hit["hit"] == false, "%s must NOT emit hit signal when touching vehicle after bouncing" % item["id"])
		assert(obs_bounced._has_hit == false, "%s must NOT mark _has_hit=true or be destroyed by vehicle while bouncing" % item["id"])

		obs_bounced.queue_free()

	mock_veh.queue_free()
	print("  ✓ Damage correctly enabled for falling and strictly DISABLED post-bounce for all 8 obstacles!")
