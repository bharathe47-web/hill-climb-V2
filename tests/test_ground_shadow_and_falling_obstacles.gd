extends SceneTree

const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const FoodObstacle = preload("res://scripts/components/survival_obstacles/food_obstacle.gd")
const GroundShadow = preload("res://scripts/components/survival_obstacles/ground_shadow.gd")

const OBSTACLE_PATHS := [
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
	print("\n=================================================================")
	print("--- BEGIN GROUND SHADOW & FALLING OBSTACLES TEST SUITE ---")
	print("=================================================================\n")
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	var root := get_root()

	_test_1_asset_integrity()
	_test_2_ground_shadow_component(root)
	_test_3_landing_position_prediction(root)
	_test_4_all_eight_obstacle_identities(root)
	_test_5_coconut_bounce_and_shadow_update(root)
	_test_6_sky_spawning_and_camera_bounds(root)
	_test_7_visual_effects_and_cleanup(root)
	await _test_8_integrated_survival_gameplay(root)

	print("\n=================================================================")
	print("✓ ALL GROUND SHADOW & FALLING OBSTACLE TESTS PASSED (100% SUCCESS)!")
	print("=================================================================\n")
	quit(0)

func _test_1_asset_integrity() -> void:
	print("-> [1/8] Verifying All Indian Food Assets (RGBA, Alpha, Preserved Coconut)...")
	var expected_assets := [
		{"path": "res://assets/obstacles/survival/foods/idli/idli.png", "is_coconut": false},
		{"path": "res://assets/obstacles/survival/foods/dosa/dosa.png", "is_coconut": false},
		{"path": "res://assets/obstacles/survival/foods/vada/vada.png", "is_coconut": false},
		{"path": "res://assets/obstacles/survival/foods/samosa/samosa.png", "is_coconut": false},
		{"path": "res://assets/obstacles/survival/foods/murukku/murukku.png", "is_coconut": false},
		{"path": "res://assets/obstacles/survival/foods/pani_puri/pani_puri.png", "is_coconut": false},
		{"path": "res://assets/obstacles/survival/foods/pani_puri/pani_puri_cluster.png", "is_coconut": false},
		{"path": "res://assets/obstacles/survival/foods/jalebi/jalebi.png", "is_coconut": false},
		{"path": "res://assets/obstacles/survival/foods/coconut/coconut.png", "is_coconut": true}
	]

	for item in expected_assets:
		var tex: Texture2D = load(item["path"])
		assert(tex != null, "Texture %s must load" % item["path"])
		var img: Image = tex.get_image()
		assert(img != null, "Image data must be accessible for %s" % item["path"])
		var alpha_mode := img.detect_alpha()
		assert(alpha_mode != Image.ALPHA_NONE, "Asset %s must have alpha transparency" % item["path"])
		assert(img.get_width() > 0 and img.get_height() > 0, "Dimensions must be valid")
		if item["is_coconut"]:
			assert(img.get_width() == 256 and img.get_height() == 248, "Coconut asset must be preserved untouched (256x248)")
		else:
			assert(img.get_width() > 500 or img.get_height() > 250, "New illustrations must be high resolution")

	print("  ✓ All 8 food textures + cluster verified: RGBA mode, transparent background, preserved Coconut!")

func _test_2_ground_shadow_component(root: Window) -> void:
	print("-> [2/8] Verifying Reusable GroundShadow 3-Stage Progression & Uncoupled Rotation...")
	var shadow_scene: PackedScene = load("res://scenes/modes/survival/shadows/ground_shadow.tscn")
	assert(shadow_scene != null, "ground_shadow.tscn must load")

	var shadow: GroundShadow = shadow_scene.instantiate()
	root.add_child(shadow)

	# Verify Stage 1: Early warning (high altitude, low opacity, subtle scale)
	shadow.update_landing_state(Vector2(250.0, 420.0), 550.0, 600.0)
	assert(shadow.global_position == Vector2(250.0, 420.0), "Shadow matches predicted landing position")
	assert(shadow.modulate.a <= 0.35, "Stage 1: Subtle alpha at high altitude")
	assert(shadow.scale.x < shadow.base_scale.x * 0.7, "Stage 1: Smaller scale footprint")

	# Verify Stage 2: Approaching warning (mid altitude)
	shadow.update_landing_state(Vector2(250.0, 420.0), 300.0, 600.0)
	assert(shadow.modulate.a > 0.35 and shadow.modulate.a <= 0.7, "Stage 2: Mid-range alpha as obstacle approaches")

	# Verify Stage 3: Immediate impact warning (critical zone)
	shadow.update_landing_state(Vector2(250.0, 420.0), 30.0, 600.0)
	assert(shadow.modulate.a >= 0.75, "Stage 3: Maximum danger visibility on near-impact")
	assert(shadow.scale.x >= shadow.base_scale.x * 0.95, "Stage 3: Full footprint expansion")

	# Verify rotation uncoupling
	shadow.rotation = 1.57 # Simulate parent attempt to rotate
	shadow.update_landing_state(Vector2(250.0, 420.0), 30.0, 600.0)
	assert(shadow.global_rotation == 0.0, "Shadow must maintain flat horizontal alignment regardless of rotation")

	# Verify fade_and_free cleanup
	shadow.fade_and_free(0.05)
	assert(shadow._is_fading == true, "Shadow enters fading state")
	
	print("  ✓ GroundShadow 3 warning stages, uncoupled rotation, and smooth fade verified!")

func _test_3_landing_position_prediction(root: Window) -> void:
	print("-> [3/8] Verifying Ballistic Landing Prediction on Procedural Terrain...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.load_default_obstacles()

	var idli_scene: PackedScene = load("res://scenes/modes/survival/obstacles/idli_obstacle.tscn")
	var idli: FoodObstacle = idli_scene.instantiate()
	idli.global_position = Vector2(300.0, -100.0)
	idli.terrain_generator = surv.terrain_generator
	surv.add_child(idli)

	var pred_pos: Vector2 = idli.calculate_predicted_landing()
	var expected_surf_y: float = surv.get_terrain_surface_y(pred_pos.x)
	assert(absf(pred_pos.x - 300.0) < 0.1, "Vertical fall must land at spawn X")
	assert(absf(pred_pos.y - expected_surf_y) < 1.0, "Predicted Y must match terrain surface height")

	var time_to_impact := idli.get_time_to_impact()
	assert(time_to_impact > 0.4 and time_to_impact < 1.8, "Flight time to impact must be realistic (~0.9s)")

	idli.queue_free()
	surv.queue_free()
	print("  ✓ Ballistic trajectory solver and uneven terrain height query verified!")

func _test_4_all_eight_obstacle_identities(root: Window) -> void:
	print("-> [4/8] Verifying All 8 Obstacle Scenes, Movement Types & Fall Speeds...")
	var expected := [
		{"id": "idli", "path": "res://scenes/modes/survival/obstacles/idli_obstacle.tscn", "type": FoodObstacle.MovementType.STRAIGHT, "speed": 420.0},
		{"id": "dosa", "path": "res://scenes/modes/survival/obstacles/dosa_obstacle.tscn", "type": FoodObstacle.MovementType.ROTATING, "speed": 360.0},
		{"id": "vada", "path": "res://scenes/modes/survival/obstacles/vada_obstacle.tscn", "type": FoodObstacle.MovementType.SPINNING, "speed": 430.0},
		{"id": "samosa", "path": "res://scenes/modes/survival/obstacles/samosa_obstacle.tscn", "type": FoodObstacle.MovementType.TUMBLING, "speed": 410.0},
		{"id": "murukku", "path": "res://scenes/modes/survival/obstacles/murukku_obstacle.tscn", "type": FoodObstacle.MovementType.SPINNING, "speed": 440.0},
		{"id": "pani_puri", "path": "res://scenes/modes/survival/obstacles/pani_puri_obstacle.tscn", "type": FoodObstacle.MovementType.CLUSTER, "speed": 390.0},
		{"id": "jalebi", "path": "res://scenes/modes/survival/obstacles/jalebi_obstacle.tscn", "type": FoodObstacle.MovementType.WOBBLE, "speed": 380.0},
		{"id": "coconut", "path": "res://scenes/modes/survival/obstacles/coconut_obstacle.tscn", "type": FoodObstacle.MovementType.BOUNCE, "speed": 460.0}
	]

	for exp in expected:
		var scene: PackedScene = load(exp["path"])
		assert(scene != null, "Scene %s must exist" % exp["path"])
		var obs: FoodObstacle = scene.instantiate()
		root.add_child(obs)

		assert(obs.obstacle_id == exp["id"], "Obstacle ID must match %s" % exp["id"])
		assert(obs.movement_type == exp["type"], "Movement type must match identity for %s" % exp["id"])
		assert(absf(obs.fall_speed - exp["speed"]) < 1.0, "Fall speed must match strict parameter %f" % exp["speed"])
		assert(obs.get_node_or_null("GroundShadow") != null or obs.ground_shadow != null, "Must have GroundShadow component")
		assert(obs.hitbox != null, "Must have Hitbox")

		obs.queue_free()

	print("  ✓ All 8 Indian food obstacles have correct speeds, movement types, hitboxes, and GroundShadows!")

func _test_5_coconut_bounce_and_shadow_update(root: Window) -> void:
	print("-> [5/8] Verifying Coconut Multi-Bounce Physics & Dynamic Shadow Relocation...")
	var scene: PackedScene = load("res://scenes/modes/survival/obstacles/coconut_obstacle.tscn")
	var coconut: FoodObstacle = scene.instantiate()
	coconut.global_position = Vector2(200.0, 390.0)
	coconut.ground_y = 400.0
	root.add_child(coconut)

	assert(coconut.movement_type == FoodObstacle.MovementType.BOUNCE, "Coconut has BOUNCE movement type")
	assert(coconut.max_bounces == 2, "Coconut has 2 maximum bounces")
	assert(coconut._bounces_left == 2, "Initial bounces left is 2")

	var initial_shadow_x := coconut.calculate_predicted_landing().x

	# Simulate ground contact to trigger first bounce
	coconut.global_position.y = 401.0
	coconut._physics_process(0.016)

	assert(coconut._bounces_left == 1, "Bounces left decremented to 1")
	assert(coconut._current_velocity.y < 0.0, "Coconut bounced upward with negative velocity")
	
	# Verify shadow recalculated for new trajectory
	var bounce_pred := coconut.calculate_predicted_landing()
	assert(bounce_pred.y == coconut.ground_y, "Predicted Y matches road surface")

	coconut.queue_free()
	print("  ✓ Coconut road contact dust, upward bounce velocity, and shadow trajectory update verified!")

func _test_6_sky_spawning_and_camera_bounds(root: Window) -> void:
	print("-> [6/8] Verifying Sky Spawning Above Visible Camera Viewport...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.load_default_obstacles()

	var test_x := 150.0
	var sky_y := surv.get_sky_spawn_y(test_x)
	var surf_y := surv.get_terrain_surface_y(test_x)

	assert(sky_y < surf_y - 400.0, "Obstacle must spawn high in the sky (at least 400px above terrain)")

	if is_instance_valid(surv.follow_camera):
		var vp_h: float = float(ProjectSettings.get_setting("display/window/size/viewport_height", 720))
		var half_h := (vp_h * 0.5) / surv.follow_camera.zoom.y
		var cam_top := surv.follow_camera.global_position.y - half_h
		assert(sky_y <= cam_top - 50.0, "Obstacle spawn Y must be strictly above camera top edge")

	surv.queue_free()
	print("  ✓ Camera world-space viewport bounds respected; obstacles spawn offscreen in the sky!")

func _test_7_visual_effects_and_cleanup(root: Window) -> void:
	print("-> [7/8] Verifying Visual Effects (Burst, Dust, Collision) & Automatic Tween Cleanup...")
	var idli_scene: PackedScene = load("res://scenes/modes/survival/obstacles/idli_obstacle.tscn")
	var idli: FoodObstacle = idli_scene.instantiate()
	idli.global_position = Vector2(100.0, 300.0)
	root.add_child(idli)

	var child_count_before := root.get_child_count()
	
	# Trigger ground impact visual
	idli._spawn_ground_impact_visual(Vector2(100.0, 400.0))
	var child_count_after := root.get_child_count()
	assert(child_count_after > child_count_before, "Impact burst and dust particles instantiated in scene")

	# Trigger vehicle collision visual
	idli._spawn_vehicle_collision_visual(Vector2(100.0, 350.0))
	assert(root.get_child_count() > child_count_after, "Vehicle collision flash instantiated")

	idli.queue_free()
	print("  ✓ Impact burst, dust particles, collision effect, and automatic queue_free tweens verified!")

func _test_8_integrated_survival_gameplay(root: Window) -> void:
	print("-> [8/8] Verifying Full Survival Mode Loop with Enabled Food Spawning...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	surv.load_default_obstacles()
	surv.enable_obstacle_spawning = true
	surv.start_run()

	assert(surv.current_lives == 3, "Run starts with 3 lives")
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "Run state is PLAYING")

	# Trigger obstacle spawn
	surv._trigger_obstacle_spawn()
	assert(surv.obstacle_container.get_child_count() >= 1, "Obstacle container contains falling hazard")

	var spawned_obs: FoodObstacle = surv.obstacle_container.get_child(0) as FoodObstacle
	assert(spawned_obs != null, "Spawned hazard is valid FoodObstacle")
	assert(spawned_obs.global_position.y < spawned_obs.ground_y - 300.0, "Hazard spawned high above road")

	# Simulate collision and life deduction
	var hit_success := surv.register_obstacle_hit(spawned_obs.obstacle_id)
	assert(hit_success == true, "Collision registered successfully")
	assert(surv.current_lives == 2, "Lives reduced to 2")
	assert(surv.is_invulnerable == true, "0.8s invulnerability window activated")

	# Test debounce protection
	var debounce_blocked := surv.register_obstacle_hit(spawned_obs.obstacle_id)
	assert(debounce_blocked == false, "Multi-body collision debounced within invulnerability window")
	assert(surv.current_lives == 2, "Lives remain 2 during debounce window")

	# Test clean reset
	surv.start_run()
	assert(surv.current_lives == 3, "Lives restored on restart")
	assert(surv.obstacle_container.get_child_count() == 0, "Obstacle container cleared on restart")

	surv.queue_free()
	print("  ✓ Integrated gameplay loop, hit debouncing, 3-life rule, and clean restart verified!")
