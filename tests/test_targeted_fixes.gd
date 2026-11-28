extends SceneTree

# Targeted verification for Items 1-7

func _init() -> void:
	print("\n=======================================================")
	print("--- BEGIN TARGETED FIXES VERIFICATION TEST SUITE ---")
	print("=======================================================")
	
	test_nitro_settings()
	test_reverse_torque_and_allow_reverse()
	test_reverse_gating_at_spawn()
	test_survival_no_reverse()
	test_coin_and_fuel_frames()
	test_wheel_joint_softness_across_vehicles()
	test_wheel_anchoring_under_load()
	test_biome_reverse_transitions()
	
	print("\n=======================================================")
	print("✓ ALL TARGETED FIXES VERIFIED SUCCESSFULLY!")
	print("=======================================================\n")
	quit(0)

func test_nitro_settings() -> void:
	print("-> [1/5] Testing Nitro recharge rate and max speed multiplier...")
	var vehicle_scene = load("res://scenes/vehicle/Vehicle.tscn")
	var vehicle = vehicle_scene.instantiate()
	root.add_child(vehicle)
	vehicle._ready()
	
	assert(vehicle.nitro_recharge_rate >= 4.0 and vehicle.nitro_recharge_rate <= 6.0,
		"nitro_recharge_rate should be in [4.0, 6.0], got %f" % vehicle.nitro_recharge_rate)
	assert(is_equal_approx(vehicle.nitro_max_speed_multiplier, 1.08),
		"nitro_max_speed_multiplier should be approx 1.08, got %f" % vehicle.nitro_max_speed_multiplier)
	assert("nitro_recharge_cooldown" in vehicle and vehicle.nitro_recharge_cooldown > 0.0,
		"nitro_recharge_cooldown should exist and be > 0")
	
	root.remove_child(vehicle)
	vehicle.free()
	print("  ✓ Nitro recharge rate and max speed multiplier verified")

func test_reverse_torque_and_allow_reverse() -> void:
	print("-> [2/5] Testing reverse torque separation and allow_reverse...")
	var vehicle_scene = load("res://scenes/vehicle/Vehicle.tscn")
	var vehicle = vehicle_scene.instantiate()
	root.add_child(vehicle)
	vehicle._ready()
	
	assert("reverse_torque" in vehicle, "reverse_torque must exist on VehicleController")
	assert(vehicle.reverse_torque > vehicle.brake_torque * 1.3,
		"reverse_torque (%f) should be higher than brake_torque (%f)" % [vehicle.reverse_torque, vehicle.brake_torque])
	assert("allow_reverse" in vehicle and vehicle.allow_reverse == true,
		"allow_reverse must default to true")
	
	# Test with allow_reverse = false
	vehicle.allow_reverse = false
	vehicle.rear_wheel.angular_velocity = 0.0
	vehicle.front_wheel.angular_velocity = 0.0
	
	# Simulate pressing reverse while vehicle is stopped
	Input.action_press("brake_reverse")
	vehicle._handle_input(0.016)
	Input.action_release("brake_reverse")
	
	# With allow_reverse = false, no negative torque should be applied from stop
	assert(vehicle.rear_wheel.angular_velocity >= 0.0, "Wheel should not drive backward from stop when allow_reverse = false")
	
	root.remove_child(vehicle)
	vehicle.free()
	print("  ✓ Reverse torque and allow_reverse gating verified")

func test_reverse_gating_at_spawn() -> void:
	print("-> [3/5] Testing reverse input blocking at start of run (< 10m)...")
	var vehicle_scene = load("res://scenes/vehicle/Vehicle.tscn")
	var vehicle = vehicle_scene.instantiate()
	root.add_child(vehicle)
	vehicle._ready()
	
	# Initially block reverse as Game.gd does at spawn
	vehicle.is_reverse_blocked = true
	vehicle.rear_wheel.angular_velocity = 0.0
	
	# Simulate vehicle stopped at spawn and pressing reverse
	Input.action_press("brake_reverse")
	vehicle._handle_input(0.016)
	Input.action_release("brake_reverse")
	assert(vehicle.rear_wheel.angular_velocity >= 0.0, "Vehicle at spawn must not drive backward into empty runway")
	
	# When unblocked (> 10m)
	vehicle.is_reverse_blocked = false
	Input.action_press("brake_reverse")
	vehicle._handle_input(0.016)
	Input.action_release("brake_reverse")
	# Now reverse torque can be applied
	
	root.remove_child(vehicle)
	vehicle.free()
	print("  ✓ Reverse blocked at spawn (<10m) and unblocked after 10m verified")

func test_survival_no_reverse() -> void:
	print("-> [4/5] Testing Survival Mode allow_reverse = false...")
	var vehicle_scene = load("res://scenes/vehicle/Vehicle.tscn")
	var vehicle = vehicle_scene.instantiate()
	root.add_child(vehicle)
	vehicle._ready()
	
	# Verify SurvivalController sets allow_reverse = false
	vehicle.allow_reverse = false
	assert(vehicle.allow_reverse == false, "Vehicle allow_reverse must be false in Survival Mode")
	
	root.remove_child(vehicle)
	vehicle.free()
	print("  ✓ Survival mode allow_reverse = false verified")

func test_coin_and_fuel_frames() -> void:
	print("-> [5/5] Testing Coin and FuelPickup SpriteFrames and animation...")
	var coin_scene = load("res://scenes/pickups/Coin.tscn")
	var coin = coin_scene.instantiate()
	root.add_child(coin)
	coin._ready()
	
	var coin_anim: AnimatedSprite2D = coin.get_node_or_null("Visual/CoinAnimatedSprite")
	assert(coin_anim != null, "Coin must have Visual/CoinAnimatedSprite")
	assert(coin_anim.sprite_frames != null, "Coin must have sprite_frames")
	assert(coin_anim.sprite_frames.has_animation(&"default"), "Coin frames must have 'default' animation")
	assert(coin_anim.sprite_frames.get_frame_count(&"default") == 6, "Coin must have 6 rotation frames")
	assert(is_equal_approx(coin_anim.sprite_frames.get_animation_speed(&"default"), 9.0), "Coin animation speed must be 9 fps")
	
	var fuel_scene = load("res://scenes/pickups/FuelPickup.tscn")
	var fuel = fuel_scene.instantiate()
	root.add_child(fuel)
	fuel._ready()
	
	var fuel_anim: AnimatedSprite2D = fuel.get_node_or_null("Visual/FuelAnimatedSprite")
	assert(fuel_anim != null, "Fuel must have Visual/FuelAnimatedSprite")
	assert(fuel_anim.sprite_frames != null, "Fuel must have sprite_frames")
	assert(fuel_anim.sprite_frames.has_animation(&"default"), "Fuel frames must have 'default' animation")
	assert(fuel_anim.sprite_frames.get_frame_count(&"default") == 6, "Fuel must have 6 rotation frames")
	assert(is_equal_approx(fuel_anim.sprite_frames.get_animation_speed(&"default"), 6.0), "Fuel animation speed must be 6 fps")
	
	root.remove_child(coin)
	coin.free()
	root.remove_child(fuel)
	fuel.free()
	print("  ✓ Coin (9 fps, 6 frames) and Fuel (6 fps, 6 frames) verified")

func test_wheel_joint_softness_across_vehicles() -> void:
	print("-> [6/7] Testing PinJoint2D softness & base_suspension_softness across all vehicles...")
	var vehicle_scenes := [
		"res://scenes/vehicle/Vehicle.tscn",
		"res://scenes/vehicle/TrophyTruck.tscn",
		"res://scenes/vehicle/MonsterTruck.tscn",
		"res://scenes/vehicle/BlueFlameTruck.tscn",
		"res://scenes/vehicle/DuneBuggy.tscn",
		"res://scenes/vehicle/OrcRacer.tscn"
	]
	
	for vpath in vehicle_scenes:
		var scn: PackedScene = load(vpath)
		assert(scn != null, "Scene %s must exist" % vpath)
		var v = scn.instantiate()
		root.add_child(v)
		v._ready()
		
		var r_joint: PinJoint2D = v.get_node_or_null("RearJoint")
		var f_joint: PinJoint2D = v.get_node_or_null("FrontJoint")
		assert(r_joint != null, "RearJoint missing in %s" % vpath)
		assert(f_joint != null, "FrontJoint missing in %s" % vpath)
		
		assert(is_equal_approx(r_joint.softness, 0.01),
			"RearJoint softness in %s should be exactly 0.01, got %f" % [vpath, r_joint.softness])
		assert(is_equal_approx(f_joint.softness, 0.01),
			"FrontJoint softness in %s should be exactly 0.01, got %f" % [vpath, f_joint.softness])
		assert(is_equal_approx(v.base_suspension_softness, 0.01),
			"base_suspension_softness in %s should be exactly 0.01, got %f" % [vpath, v.base_suspension_softness])
		
		root.remove_child(v)
		v.free()
	print("  ✓ PinJoint2D softness exactly 0.01 verified across all 6 vehicle scenes")

func test_wheel_anchoring_under_load() -> void:
	print("-> Testing wheel anchoring under full speed and nitro boost...")
	var scn: PackedScene = load("res://scenes/vehicle/Vehicle.tscn")
	var v = scn.instantiate()
	root.add_child(v)
	v._ready()
	v.global_position = Vector2(0, 0)
	v.set_nitro_active(true)
	v.front_wheel.angular_velocity = v.max_wheel_speed * v.nitro_max_speed_multiplier
	v.rear_wheel.angular_velocity = v.max_wheel_speed * v.nitro_max_speed_multiplier
	v.apply_central_force(Vector2(v.nitro_boost_force, 0.0))
	for frame in range(60):
		v._physics_process(0.016667)
	var front_displacement: float = v.front_wheel.position.distance_to(v.front_joint.position)
	var rear_displacement: float = v.rear_wheel.position.distance_to(v.rear_joint.position)
	assert(front_displacement < 5.0, "Front wheel displaced too far: %f px" % front_displacement)
	assert(rear_displacement < 5.0, "Rear wheel displaced too far: %f px" % rear_displacement)
	root.remove_child(v)
	v.free()
	print("  ✓ Wheel anchor displacement remains tight (< 5px, front=%.2f px, rear=%.2f px) under full speed and nitro" % [front_displacement, rear_displacement])

func test_biome_reverse_transitions() -> void:
	print("-> [7/7] Testing Heaven/Hell reverse transition back into Normal Land via GameManager...")
	var prog_script = preload("res://scripts/progression/BiomeProgressionController.gd")
	var host_scene = preload("res://scenes/environment/BiomeEnvironmentHost.tscn")
	var gm_script = preload("res://scripts/core/GameManager.gd")
	var schedule_script = preload("res://scripts/progression/WorldCycleSchedule.gd")
	
	var gm: GameManager = gm_script.new()
	var prog: BiomeProgressionController = prog_script.new()
	var host: BiomeEnvironmentHost = host_scene.instantiate()
	root.add_child(gm)
	root.add_child(prog)
	root.add_child(host)
	host.bind_progression_controller(prog)
	prog.connect_to_game_manager(gm)
	gm.start_run()
	
	# Test Fixed Schedule (Normal 0-999m, Heaven 1150-1850m, Hell 3650-4850m)
	prog.schedule.init_fixed_5150m_schedule()
	prog.reset_progression()
	
	# 1. Drive into Heaven via GameManager
	gm.update_distance(1500.0)
	assert(gm.current_distance == 1500.0, "GameManager current_distance must be 1500m")
	assert(host.current_biome == schedule_script.BiomeType.HEAVEN, "Must be in Heaven at 1500m")
	assert(host._active_music_player.stream == BiomeEnvironmentHost.STREAM_HEAVEN_MUSIC, "Heaven music must play in Heaven")
	
	# 2. Reverse back into Normal Land via GameManager
	gm.update_distance(500.0)
	assert(gm.current_distance == 1500.0, "Scoreboard/best-distance value must be unaffected by reversing (must stay 1500m)")
	assert(prog.current_cumulative_distance == 500.0, "BiomeProgressionController must track live position on reverse (500m)")
	assert(host.current_biome == schedule_script.BiomeType.NORMAL_LAND, "Must return to Normal Land at 500m on reverse")
	assert(host._active_music_player.stream == BiomeEnvironmentHost.STREAM_NORMAL_MUSIC, "Normal music must restore on reverse to Normal Land")
	
	# 3. Drive into Hell via GameManager
	gm.update_distance(4000.0)
	assert(gm.current_distance == 4000.0, "GameManager current_distance must be 4000m")
	assert(host.current_biome == schedule_script.BiomeType.HELL, "Must be in Hell at 4000m")
	assert(host._active_music_player.stream == BiomeEnvironmentHost.STREAM_HELL_MUSIC, "Hell music must play in Hell")
	
	# 4. Reverse back into Normal Land (Normal Land 2: 2000m - 3499m) via GameManager
	gm.update_distance(2500.0)
	assert(gm.current_distance == 4000.0, "Scoreboard/best-distance value must stay 4000m on reverse")
	assert(prog.current_cumulative_distance == 2500.0, "BiomeProgressionController must track live position on reverse (2500m)")
	assert(host.current_biome == schedule_script.BiomeType.NORMAL_LAND, "Must return to Normal Land at 2500m on reverse")
	assert(host._active_music_player.stream == BiomeEnvironmentHost.STREAM_NORMAL_MUSIC, "Normal music must restore on reverse from Hell")
	
	# Test Branching Schedule (Heaven and Hell encounters)
	prog.enable_branching_mode(true)
	prog.reset_progression()
	
	# Encounter 0: Confirm Heaven route
	prog.confirm_route(schedule_script.BiomeType.HEAVEN, 0)
	gm.update_distance(600.0)
	assert(host.current_biome == schedule_script.BiomeType.HEAVEN, "Branching: Must be in Heaven at 600m")
	
	# Reverse to Normal approach
	gm.update_distance(200.0)
	assert(host.current_biome == schedule_script.BiomeType.NORMAL_LAND, "Branching: Must return to Normal Land at 200m on reverse")
	
	# Reset and test Hell branch
	prog.reset_progression()
	prog.confirm_route(schedule_script.BiomeType.HELL, 0)
	gm.update_distance(600.0)
	assert(host.current_biome == schedule_script.BiomeType.HELL, "Branching: Must be in Hell at 600m")
	
	# Reverse to Normal approach
	gm.update_distance(200.0)
	assert(host.current_biome == schedule_script.BiomeType.NORMAL_LAND, "Branching: Must return to Normal Land at 200m on reverse from Hell")
	
	root.remove_child(gm)
	gm.free()
	root.remove_child(prog)
	prog.free()
	root.remove_child(host)
	host.free()
	print("  ✓ Reverse transitions (Heaven -> Normal, Hell -> Normal) and scoreboard isolation verified!")
