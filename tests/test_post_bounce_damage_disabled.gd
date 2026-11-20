extends SceneTree

## Dedicated automated test suite verifying:
## PREVENT POST-BOUNCE FOOD OBSTACLES FROM REDUCING VEHICLE LIVES
## Rule:
## FALLING FOOD = DAMAGE ENABLED.
## FIRST GROUND CONTACT = DAMAGE DISABLED.
## BOUNCED FOOD = NO LIFE DAMAGE.

const SurvivalScene: PackedScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const FoodObstacle = preload("res://scripts/components/survival_obstacles/food_obstacle.gd")
const GameHUD = preload("res://scripts/ui/game_hud.gd")

const OBSTACLES: Array[Dictionary] = [
	{"id": "idli", "path": "res://scenes/modes/survival/obstacles/idli_obstacle.tscn"},
	{"id": "dosa", "path": "res://scenes/modes/survival/obstacles/dosa_obstacle.tscn"},
	{"id": "vada", "path": "res://scenes/modes/survival/obstacles/vada_obstacle.tscn"},
	{"id": "samosa", "path": "res://scenes/modes/survival/obstacles/samosa_obstacle.tscn"},
	{"id": "murukku", "path": "res://scenes/modes/survival/obstacles/murukku_obstacle.tscn"},
	{"id": "pani_puri", "path": "res://scenes/modes/survival/obstacles/pani_puri_obstacle.tscn"},
	{"id": "jalebi", "path": "res://scenes/modes/survival/obstacles/jalebi_obstacle.tscn"},
	{"id": "coconut", "path": "res://scenes/modes/survival/obstacles/coconut_obstacle.tscn"}
]

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN POST-BOUNCE DAMAGE DISABLED VERIFICATION SUITE ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var root := get_root()

	_test_1_explicit_damage_state_initialization()
	_test_2_first_ground_contact_disables_damage_synchronously(root)
	_test_3_direct_falling_collision_reduces_one_life(root)
	_test_4_post_bounce_collision_zero_damage_all_eight(root)
	_test_5_multiple_bounces_remain_harmless(root)
	_test_6_collision_order_protection(root)
	_test_7_controller_double_layer_defense(root)

	print("\n=================================================================")
	print("✓ ALL POST-BOUNCE DAMAGE CORRECTION TESTS PASSED (100% SUCCESS)!")
	print("=================================================================\n")
	quit(0)

func _test_1_explicit_damage_state_initialization() -> void:
	print("-> [1/7] Verifying Explicit Damage State Initialization for All 8 Obstacles...")
	for item in OBSTACLES:
		var scene: PackedScene = load(item["path"])
		var obs: FoodObstacle = scene.instantiate()
		assert(obs.can_damage_vehicle == true, "%s must have can_damage_vehicle=true on spawn" % item["id"])
		assert(obs.has_touched_ground == false, "%s must have has_touched_ground=false on spawn" % item["id"])
		assert(obs._has_hit == false, "%s must have _has_hit=false on spawn" % item["id"])
		obs.queue_free()
	print("  ✓ All 8 food obstacles correctly initialize with can_damage_vehicle=true!")

func _test_2_first_ground_contact_disables_damage_synchronously(root: Window) -> void:
	print("-> [2/7] Verifying Damage State Disabled Synchronously BEFORE Bounce Velocity Applied...")
	for item in OBSTACLES:
		var scene: PackedScene = load(item["path"])
		var obs: FoodObstacle = scene.instantiate()
		obs.global_position = Vector2(100.0, 395.0)
		obs.ground_y = 400.0
		root.add_child(obs) # Triggers _ready() to initialize _bounces_left = max_bounces
		obs._current_velocity.y = 300.0

		# Simulate physics step that crosses ground_y
		obs.global_position.y = 401.0
		obs._physics_process(0.016)

		assert(obs.has_touched_ground == true, "%s must set has_touched_ground=true upon ground contact" % item["id"])
		assert(obs.can_damage_vehicle == false, "%s must set can_damage_vehicle=false upon ground contact" % item["id"])
		assert(obs._current_velocity.y < 0.0, "%s upward bounce velocity must be active" % item["id"])
		assert(obs.ground_bounce_count == 1, "%s ground_bounce_count must be 1" % item["id"])
		obs.queue_free()
	print("  ✓ State transition can_damage_vehicle=false occurs immediately at first ground contact!")

func _test_3_direct_falling_collision_reduces_one_life(root: Window) -> void:
	print("-> [3/7] Verifying Direct Falling Collision Reduces Exactly 1 Life & Debounces...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	assert(surv.current_lives == 3, "Run starts with 3 lives")

	var idli_scene: PackedScene = load("res://scenes/modes/survival/obstacles/idli_obstacle.tscn")
	var obs: FoodObstacle = idli_scene.instantiate()
	obs.global_position = surv.vehicle.global_position + Vector2(0.0, -100.0) # Directly above vehicle
	obs.ground_y = surv.vehicle.global_position.y + 150.0
	surv.obstacle_container.add_child(obs)
	obs.obstacle_hit.connect(surv._on_obstacle_reported_hit.bind(obs))

	# Falling collision before ground contact
	assert(obs.can_damage_vehicle == true, "Damage enabled while falling")
	assert(obs.has_touched_ground == false, "Not touched ground yet")

	obs._on_body_entered(surv.vehicle)

	assert(surv.current_lives == 2, "1 life deducted from direct falling hit (now 2 lives)")
	assert(obs._has_hit == true, "Obstacle marked _has_hit=true")
	assert(obs.can_damage_vehicle == false, "Damage disabled after hit registered")

	# Secondary collision signal from wheels should be debounced and not deduct another life
	obs._on_body_entered(surv.vehicle)
	assert(surv.current_lives == 2, "Debounce prevents duplicate life reduction from same obstacle")

	surv.queue_free()
	print("  ✓ Direct falling hits correctly deduct 1 life with proper hit debouncing!")

func _test_4_post_bounce_collision_zero_damage_all_eight(root: Window) -> void:
	print("-> [4/7] Verifying Zero Damage When Bounced Food Touches Vehicle Across All 8 Obstacles...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	for item in OBSTACLES:
		var initial_lives := surv.current_lives
		var scene: PackedScene = load(item["path"])
		var obs: FoodObstacle = scene.instantiate()
		obs.global_position = Vector2(surv.vehicle.global_position.x + 10.0, 395.0)
		obs.ground_y = 400.0
		obs._current_velocity.y = 350.0
		surv.obstacle_container.add_child(obs)

		# Advance physics to contact ground and initiate first bounce
		obs.global_position.y = 401.0
		obs._physics_process(0.016)

		assert(obs.has_touched_ground == true, "%s has touched ground" % item["id"])
		assert(obs.can_damage_vehicle == false, "%s damage is disabled" % item["id"])
		assert(obs.ground_bounce_count == 1, "%s is in bounce phase" % item["id"])

		# Now simulate vehicle touching the bouncing food
		obs._on_body_entered(surv.vehicle)
		obs._on_area_entered(surv.vehicle.get_node_or_null("Hitbox") if surv.vehicle.has_node("Hitbox") else Area2D.new())

		assert(surv.current_lives == initial_lives, "%s post-bounce collision must NOT reduce lives (lives=%d)" % [item["id"], surv.current_lives])
		assert(obs._has_hit == false, "%s must NOT mark _has_hit or disappear prematurely on vehicle touch" % item["id"])

		obs.queue_free()

	surv.queue_free()
	print("  ✓ Bounced food touching the vehicle produces ZERO life reductions for all 8 obstacles!")

func _test_5_multiple_bounces_remain_harmless(root: Window) -> void:
	print("-> [5/7] Verifying Obstacles Remain Completely Harmless Across Multiple Subsequent Bounces...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	var coconut_scene: PackedScene = load("res://scenes/modes/survival/obstacles/coconut_obstacle.tscn")
	var coconut: FoodObstacle = coconut_scene.instantiate()
	coconut.global_position = Vector2(surv.vehicle.global_position.x, 395.0)
	coconut.ground_y = 400.0
	surv.obstacle_container.add_child(coconut)

	# Bounce 1
	coconut.global_position.y = 401.0
	coconut._current_velocity.y = 300.0
	coconut._physics_process(0.016)
	assert(coconut.ground_bounce_count == 1, "Coconut at bounce 1")
	assert(coconut.can_damage_vehicle == false, "Damage disabled at bounce 1")

	# Vehicle touches during bounce 1
	coconut._on_body_entered(surv.vehicle)
	assert(surv.current_lives == 3, "Lives intact after bounce 1 contact")

	# Simulate trajectory rising and falling back to ground
	coconut.global_position.y = 350.0
	coconut._current_velocity.y = 200.0
	coconut._physics_process(0.016)

	# Bounce 2
	coconut.global_position.y = 401.0
	coconut._current_velocity.y = 300.0
	coconut._physics_process(0.016)
	assert(coconut.ground_bounce_count == 2, "Coconut at bounce 2")
	assert(coconut.can_damage_vehicle == false, "Damage still disabled at bounce 2")

	# Vehicle touches during bounce 2
	coconut._on_body_entered(surv.vehicle)
	assert(surv.current_lives == 3, "Lives intact after bounce 2 contact")

	coconut.queue_free()
	surv.queue_free()
	print("  ✓ Harmlessness persists consistently across multiple subsequent bounces!")

func _test_6_collision_order_protection(root: Window) -> void:
	print("-> [6/7] Verifying Collision-Order Protection (Ground Contact Takes Priority Over Vehicle)...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	var samosa_scene: PackedScene = load("res://scenes/modes/survival/obstacles/samosa_obstacle.tscn")
	var samosa: FoodObstacle = samosa_scene.instantiate()
	# Position exactly at ground height where vehicle also sits
	samosa.ground_y = 400.0
	samosa.global_position = Vector2(surv.vehicle.global_position.x, 400.5)
	surv.obstacle_container.add_child(samosa)

	# Collision signal arrives before _physics_process was called
	samosa._on_body_entered(surv.vehicle)

	assert(samosa.has_touched_ground == true, "Ground contact recognized immediately")
	assert(samosa.can_damage_vehicle == false, "Damage disabled immediately")
	assert(surv.current_lives == 3, "Zero lives deducted when collision coincides with ground contact")

	samosa.queue_free()
	surv.queue_free()
	print("  ✓ Collision-order priority cleanly protects against simultaneous frame edge-cases!")

func _test_7_controller_double_layer_defense(root: Window) -> void:
	print("-> [7/7] Verifying SurvivalController Double-Layer Defense (Gating Damaged Obstacles)...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.start_run()

	var idli_scene: PackedScene = load("res://scenes/modes/survival/obstacles/idli_obstacle.tscn")

	# 1. Bounced obstacle with can_damage_vehicle = false passed to register_obstacle_hit
	var bounced_obs: FoodObstacle = idli_scene.instantiate()
	bounced_obs.can_damage_vehicle = false
	bounced_obs.has_touched_ground = true

	var registered := surv.register_obstacle_hit("idli", bounced_obs)
	assert(registered == false, "SurvivalController must reject hits from obstacles with can_damage_vehicle=false")
	assert(surv.current_lives == 3, "Lives remain 3 when controller rejects post-bounce hit")

	# 2. Obstacle with can_damage_vehicle = true is accepted
	var falling_obs: FoodObstacle = idli_scene.instantiate()
	falling_obs.can_damage_vehicle = true
	falling_obs.has_touched_ground = false

	var valid_reg := surv.register_obstacle_hit("idli", falling_obs)
	assert(valid_reg == true, "SurvivalController must accept direct falling hits")
	assert(surv.current_lives == 2, "Lives reduced to 2 for valid falling hit")

	bounced_obs.queue_free()
	falling_obs.queue_free()
	surv.queue_free()
	print("  ✓ Controller-level validation reliably blocks post-bounce hits!")
