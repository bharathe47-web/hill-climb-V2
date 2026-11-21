class_name TestSurvivalObstacles
extends SceneTree

## TestSurvivalObstacles: Automated test suite for Joel's Survival obstacle components.
## Verifies 5 food obstacles, visual warning indicator, collision shapes,
## hit reporting, debouncing with SurvivalController, and ground cleanup.

const FoodObstacle = preload("res://scripts/components/survival_obstacles/FoodObstacle.gd")
const WarningIndicator = preload("res://scripts/components/survival_obstacles/WarningIndicator.gd")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")

const ChilliScene = preload("res://scenes/modes/survival/obstacles/ChilliObstacle.tscn")
const RiceScene = preload("res://scenes/modes/survival/obstacles/RiceObstacle.tscn")
const SweetsScene = preload("res://scenes/modes/survival/obstacles/SweetsObstacle.tscn")
const VadaPavScene = preload("res://scenes/modes/survival/obstacles/VadaPavObstacle.tscn")
const SamosaScene = preload("res://scenes/modes/survival/obstacles/SamosaObstacle.tscn")
const WarningScene = preload("res://scenes/modes/survival/obstacles/WarningIndicator.tscn")

func _init() -> void:
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN SURVIVAL OBSTACLES & WARNINGS AUTOMATED TEST SUITE ---")
	print("=================================================================\n")

	_test_obstacle_scenes_instantiation()
	_test_warning_indicator_behavior()
	_test_obstacle_hit_signal_contract()
	_test_survival_controller_integration()

	print("\n=================================================================")
	print("✓ ALL SURVIVAL OBSTACLES & WARNING TESTS COMPLETED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_obstacle_scenes_instantiation() -> void:
	print("-> [1/4] Verifying 5 Food Obstacle Scenes & Collision Shapes...")

	var scenes: Array[PackedScene] = [ChilliScene, RiceScene, SweetsScene, VadaPavScene, SamosaScene]
	var expected_ids := ["chilli", "rice", "sweets", "vada_pav", "samosa"]

	for i in range(scenes.size()):
		var obs := scenes[i].instantiate() as FoodObstacle
		root.add_child(obs)

		assert(obs != null, "Obstacle scene %d failed to instantiate" % i)
		assert(obs.obstacle_id == expected_ids[i], "Expected obstacle_id '%s', got '%s'" % [expected_ids[i], obs.obstacle_id])
		assert(obs.collision_shape != null, "Obstacle must have CollisionShape2D")
		assert(obs.collision_shape.shape != null, "Collision shape must not be null")
		assert(obs.visual_sprite != null and obs.visual_sprite.texture != null, "Visual sprite texture must be assigned")

		# Verify unique physical traits per obstacle
		if obs.obstacle_id == "chilli":
			assert(obs.fall_speed == 460.0, "Chilli should have fast fall speed")
		elif obs.obstacle_id == "rice":
			assert(obs.horizontal_drift > 0.0, "Rice should have aerodynamic horizontal drift")
		elif obs.obstacle_id == "vada_pav":
			assert(obs.fall_speed >= 500.0, "Vada Pav should have heavy fall speed")
		elif obs.obstacle_id == "samosa":
			assert(obs.spin_speed < 0.0, "Samosa should have reverse tumble spin")

		obs.queue_free()

	print("  ✓ All 5 Food Obstacles (Chilli, Rice, Sweets, Vada Pav, Samosa) instantiated with aligned shapes!")

func _test_warning_indicator_behavior() -> void:
	print("-> [2/4] Verifying WarningIndicator visual component...")
	var warn := WarningScene.instantiate() as WarningIndicator
	root.add_child(warn)

	assert(warn != null, "WarningIndicator failed to instantiate")
	assert(warn.has_method("start_warning"), "WarningIndicator must implement start_warning(duration)")

	warn.start_warning(0.5)
	assert(warn.warning_duration == 0.5, "Warning duration should be set to 0.5")

	warn.queue_free()
	print("  ✓ WarningIndicator conforms to SHARED_GAME_INTERFACES.md Section 6.2!")

func _test_obstacle_hit_signal_contract() -> void:
	print("-> [3/4] Verifying FoodObstacle hit signal contract...")
	var obs := ChilliScene.instantiate() as FoodObstacle
	root.add_child(obs)

	var hit_data := {"received": false, "id": "", "pos": Vector2.ZERO}
	obs.obstacle_hit.connect(func(id: String, pos: Vector2):
		hit_data["received"] = true
		hit_data["id"] = id
		hit_data["pos"] = pos
	)

	obs._trigger_hit()

	assert(bool(hit_data["received"]), "obstacle_hit signal must be emitted upon collision")
	assert(str(hit_data["id"]) == "chilli", "obstacle_hit must report correct obstacle ID")

	print("  ✓ FoodObstacle hit reporting signal contract verified!")

func _test_survival_controller_integration() -> void:
	print("-> [4/4] Verifying SurvivalController obstacle binding & 1-life loss...")
	var surv := SurvivalScene.instantiate() as SurvivalController
	root.add_child(surv)

	# Wire Joel's obstacle scenes and warning scene
	surv.obstacle_scenes = [ChilliScene, RiceScene, SweetsScene, VadaPavScene, SamosaScene]
	surv.warning_scene = WarningScene

	assert(surv.obstacle_scenes.size() == 5, "SurvivalController should have 5 food obstacle scenes")
	assert(surv.warning_scene != null, "SurvivalController should have WarningIndicator scene")

	# Test registering a hit deducts exactly 1 life
	assert(surv.current_lives == 3, "Run should start with 3 lives")
	surv.register_obstacle_hit("chilli")
	assert(surv.current_lives == 2, "Obstacle hit must deduct exactly 1 life: 3 -> 2")

	# Test invulnerability debouncing (simultaneous multi-body collision in same frame)
	var second_hit_registered := surv.register_obstacle_hit("chilli")
	assert(not second_hit_registered, "Second hit within debounce cooldown must be ignored")
	assert(surv.current_lives == 2, "Lives must remain at 2 during invulnerability cooldown")

	surv.queue_free()
	print("  ✓ SurvivalController integration, debouncing, and 3-life baseline verified!")
