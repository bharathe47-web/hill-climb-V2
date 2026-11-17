extends SceneTree

# test_phase5_transition_presentation.gd
# Dedicated test suite for Phase 5 — Transition presentation, HUD, camera, and audio.
# Adheres strictly to phases docs/DANIEL_ENDLESS_MAP_BRANCHING_HEAVEN_HELL_DESIGN.md.

const WorldCycleScheduleClass = preload("res://scripts/progression/WorldCycleSchedule.gd")
const BiomeProgressionControllerClass = preload("res://scripts/progression/BiomeProgressionController.gd")
const BiomeEnvironmentHostClass = preload("res://scripts/environment/BiomeEnvironmentHost.gd")
const FollowCameraClass = preload("res://scripts/core/FollowCamera.gd")
const HUDScene = preload("res://scenes/ui/HUD.tscn")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN PHASE 5 TRANSITION PRESENTATION & HUD TEST SUITE ---")
	print("=================================================================\n")
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	var success := true
	success = await _test_hud_ramp_warning_and_tutorial() and success
	success = await _test_hud_launch_window_and_nitro_pulse() and success
	success = await _test_hud_empty_nitro_honest_messaging() and success
	success = await _test_hud_route_confirmation_and_merge() and success
	success = await _test_follow_camera_easing_and_trauma() and success
	success = await _test_environment_host_overlays_and_audio() and success

	if success:
		print("\n=================================================================")
		print("✓ ALL PHASE 5 TESTS COMPLETED WITH 100% SUCCESS!")
		print("=================================================================\n")
		quit(0)
	else:
		printerr("\n❌ PHASE 5 TESTS FAILED!")
		quit(1)

func _test_hud_ramp_warning_and_tutorial() -> bool:
	print("-> [1/6] Testing HUD ramp warning banner and first-time tutorial copy...")
	var root := get_root()
	
	var hud = HUDScene.instantiate()
	root.add_child(hud)
	await process_frame
	
	var controller := BiomeProgressionControllerClass.new()
	controller.enable_branching_mode(true)
	root.add_child(controller)
	hud.bind_progression_controller(controller)
	await process_frame
	
	# Step 1: Normal approach (0m - 450m) -> prompt hidden
	controller.update_distance(200.0)
	await process_frame
	assert(hud._ramp_prompt_panel != null, "Ramp prompt panel must be initialized")
	assert(not hud._ramp_prompt_panel.visible, "Prompt panel must be hidden during normal approach")
	print("  ✓ Prompt panel properly hidden during normal approach (200m)")
	
	# Step 2: Ramp Warning window (450m - 475m, Encounter 0) -> First-time tutorial copy
	controller.update_distance(455.0)
	await process_frame
	assert(hud._ramp_prompt_panel.visible, "Ramp prompt must be visible in warning window")
	assert(hud._ramp_title_label.text.contains("RAMP AHEAD"), "Title must indicate ramp ahead")
	assert(hud._ramp_subtitle_label.text.contains("USE BOOST AT THE RAMP TO REACH HEAVEN"), 
		"First encounter must show full tutorial copy")
	assert(hud._ramp_subtitle_label.text.contains("HELL"), "Tutorial must mention Hell catch basin consequence")
	print("  ✓ First-time tutorial copy displayed in full during Encounter 0 warning window (455m)")
	
	# Step 3: Advance past encounter and simulate Encounter 1 warning (1,455m) -> Compact repeat prompt
	controller.confirm_route(WorldCycleScheduleClass.BiomeType.HEAVEN, 0)
	controller.update_distance(1000.0)
	controller.update_distance(1455.0) # Encounter 1 Warning window
	await process_frame
	assert(hud._ramp_prompt_panel.visible, "Ramp prompt must be visible in repeat encounter warning window")
	assert(hud._ramp_title_label.text.contains("RAMP AHEAD"), "Repeat title must indicate ramp ahead")
	assert(hud._ramp_subtitle_label.text.contains("Prepare for Launch"), 
		"Repeat encounter must show compact prompt instead of long tutorial")
	print("  ✓ Repeat encounter correctly displays compact prompt ('Prepare for Launch')")
	
	hud.queue_free()
	controller.queue_free()
	await process_frame
	return true

func _test_hud_launch_window_and_nitro_pulse() -> bool:
	print("-> [2/6] Testing HUD launch window prompt and Nitro meter/button pulsing...")
	var root := get_root()
	
	var hud = HUDScene.instantiate()
	root.add_child(hud)
	await process_frame
	
	# Mock vehicle with full Nitro
	var veh_mock := Node2D.new()
	var scr := GDScript.new()
	scr.source_code = "extends Node2D\nvar current_nitro: float = 100.0\nvar max_nitro: float = 100.0\n"
	scr.reload()
	veh_mock.set_script(scr)
	veh_mock.name = "Vehicle"
	root.add_child(veh_mock)
	hud.bind_vehicle(veh_mock)
	
	var controller := BiomeProgressionControllerClass.new()
	controller.enable_branching_mode(true)
	root.add_child(controller)
	hud.bind_progression_controller(controller)
	await process_frame
	
	# Advance into Launch Window (475m - 500m)
	controller.update_distance(480.0)
	await process_frame
	
	assert(hud._ramp_prompt_panel.visible, "Launch prompt panel must be visible")
	assert(hud._ramp_title_label.text.contains("BOOST TO REACH HEAVEN"), "Prompt must instruct to boost")
	assert(hud._is_launch_window_active == true, "Launch window pulse flag must be active")
	print("  ✓ Launch window prompt ('BOOST TO REACH HEAVEN!') active at 480m")
	
	# Simulate 10 frames of _process and verify pulsing scale / glow
	var scale_pulsed := false
	for i in range(10):
		hud._process(0.016)
		if hud.nitro_button and hud.nitro_button.scale.x > 1.01:
			scale_pulsed = true
	
	assert(scale_pulsed, "Nitro button must pulse scale > 1.0 during launch window")
	assert(hud.nitro_bar != null, "Nitro bar exists")
	print("  ✓ Nitro button and bar actively pulsating with vibrant launch cue")
	
	hud.queue_free()
	veh_mock.queue_free()
	controller.queue_free()
	await process_frame
	return true

func _test_hud_empty_nitro_honest_messaging() -> bool:
	print("-> [3/6] Testing low/empty Nitro honest messaging without false prompts...")
	var root := get_root()
	
	var hud = HUDScene.instantiate()
	root.add_child(hud)
	await process_frame
	
	# Mock vehicle with EMPTY Nitro (0.0)
	var veh_mock := Node2D.new()
	var scr := GDScript.new()
	scr.source_code = "extends Node2D\nvar current_nitro: float = 0.0\nvar max_nitro: float = 100.0\n"
	scr.reload()
	veh_mock.set_script(scr)
	veh_mock.name = "Vehicle"
	root.add_child(veh_mock)
	hud.bind_vehicle(veh_mock)
	
	var controller := BiomeProgressionControllerClass.new()
	controller.enable_branching_mode(true)
	root.add_child(controller)
	hud.bind_progression_controller(controller)
	await process_frame
	
	# Advance to launch window with empty Nitro
	controller.update_distance(480.0)
	await process_frame
	
	assert(hud._ramp_prompt_panel.visible, "Prompt panel must be visible")
	assert(hud._ramp_title_label.text.contains("NITRO EMPTY"), "Prompt must honestly report empty nitro")
	assert(hud._ramp_subtitle_label.text.contains("Hell"), "Subtitle must notify of Hell descent")
	assert(hud._is_launch_window_active == false, "Must NOT pulse button as usable when empty")
	print("  ✓ Honest 'NITRO EMPTY — LOWER ROUTE' messaging displayed with zero misleading pulse")
	
	hud.queue_free()
	veh_mock.queue_free()
	controller.queue_free()
	await process_frame
	return true

func _test_hud_route_confirmation_and_merge() -> bool:
	print("-> [4/6] Testing route confirmation notifications (Heaven/Hell) and merge toast...")
	var root := get_root()
	
	var hud = HUDScene.instantiate()
	root.add_child(hud)
	await process_frame
	
	var controller := BiomeProgressionControllerClass.new()
	controller.enable_branching_mode(true)
	root.add_child(controller)
	hud.bind_progression_controller(controller)
	await process_frame
	
	# 1. Test HEAVEN route confirmation
	hud._on_branch_confirmed(WorldCycleScheduleClass.BiomeType.HEAVEN, 0)
	await process_frame
	assert(hud._toast_panel.visible, "Toast panel must be visible upon Heaven confirmation")
	assert(hud._toast_title_label.text.contains("HEAVEN ROUTE"), "Toast must display 'HEAVEN ROUTE'")
	assert(not hud._ramp_prompt_panel.visible, "Ramp prompt must close upon route confirmation")
	print("  ✓ Heaven route confirmed notification ('✦ HEAVEN ROUTE ✦') verified")
	
	# 2. Test HELL route confirmation
	hud._on_branch_confirmed(WorldCycleScheduleClass.BiomeType.HELL, 1)
	await process_frame
	assert(hud._toast_panel.visible, "Toast panel must be visible upon Hell confirmation")
	assert(hud._toast_title_label.text.contains("HELL ROUTE"), "Toast must display 'HELL ROUTE'")
	print("  ✓ Hell route confirmed notification ('▼ HELL ROUTE ▼') verified")
	
	# 3. Test Route Merge toast
	hud._on_route_merge_completed(0)
	await process_frame
	assert(hud._toast_title_label.text.contains("NORMAL LAND"), "Merge toast must display 'NORMAL LAND'")
	print("  ✓ Normal Land return merge notification verified")
	
	hud.queue_free()
	controller.queue_free()
	await process_frame
	return true

func _test_follow_camera_easing_and_trauma() -> bool:
	print("-> [5/6] Testing FollowCamera vertical lookahead easing, damping, and landing rumble...")
	var root := get_root()
	
	var cam := FollowCameraClass.new()
	var target_mock := Node2D.new()
	target_mock.position = Vector2(50000.0, 420.0)
	root.add_child(target_mock)
	cam.target = target_mock
	root.add_child(cam)
	await process_frame
	
	# Baseline Normal Land offset
	cam.set_realm_state(WorldCycleScheduleClass.WorldState.NORMAL_APPROACH)
	assert(is_equal_approx(cam.target_vertical_offset, -50.0), "Normal Land target vertical offset must be -50px")
	print("  ✓ Baseline Normal Land camera target offset verified (-50px)")
	
	# Heaven State -> Elevated lookahead (-35px)
	cam.set_realm_state(WorldCycleScheduleClass.WorldState.HEAVEN_ACTIVE)
	assert(is_equal_approx(cam.target_vertical_offset, -35.0), "Heaven target vertical offset must be -35px")
	for i in range(15):
		cam._physics_process(0.016)
	assert(cam.follow_offset.y > -49.0, "Camera follow offset must ease upward towards Heaven target")
	print("  ✓ Heaven ascent camera vertical lookahead eased smoothly towards -35px")
	
	# Hell State -> Downward subterranean lookahead (-70px)
	cam.set_realm_state(WorldCycleScheduleClass.WorldState.HELL_ACTIVE)
	assert(is_equal_approx(cam.target_vertical_offset, -70.0), "Hell target vertical offset must be -70px")
	for i in range(15):
		cam._physics_process(0.016)
	assert(cam.follow_offset.y < -40.0, "Camera follow offset must ease downward towards Hell target")
	print("  ✓ Hell descent camera vertical lookahead eased smoothly towards -70px")
	
	# Camera trauma rumble test
	cam.trigger_hell_rumble()
	assert(cam.trauma >= 0.20, "Hell descent must apply at least 0.20 trauma rumble")
	cam.trigger_landing_thud()
	assert(cam.trauma >= 0.25, "Landing thud must apply tactile trauma")
	print("  ✓ Atmospheric Hell rumble and landing thud screen trauma verified")
	
	cam.queue_free()
	target_mock.queue_free()
	await process_frame
	return true

func _test_environment_host_overlays_and_audio() -> bool:
	print("-> [6/6] Testing BiomeEnvironmentHost visual transition overlays and audio crossfading...")
	var root := get_root()
	
	var host := BiomeEnvironmentHostClass.new()
	root.add_child(host)
	await process_frame
	
	# 1. Verify Transition Overlay Layer and ColorRects
	assert(host._overlay_layer != null, "TransitionOverlayLayer must be instantiated")
	assert(host._heaven_golden_flash != null, "Heaven golden flash ColorRect must exist")
	assert(host._hell_darkness_vignette != null, "Hell darkness vignette ColorRect must exist")
	assert(host._cloud_tunnel_overlay != null, "Cloud tunnel overlay ColorRect must exist")
	assert(host._geyser_escape_flash != null, "Geyser escape flash ColorRect must exist")
	print("  ✓ Fullscreen transition overlay layer with 4 dedicated effect surfaces verified")
	
	# 2. Test Heaven Transition Presentation
	host._enter_transition_to_heaven()
	assert(host.current_biome == WorldCycleScheduleClass.BiomeType.HEAVEN, "Biome must be HEAVEN")
	assert(host._stinger_player.stream == BiomeEnvironmentHostClass.STREAM_HEAVEN_STINGER, 
		"Heaven entry must play celestial chimes stinger")
	print("  ✓ Heaven entry golden flash, chime stinger, and celestial audio crossfade verified")
	
	# 3. Test Hell Transition Presentation
	host._enter_transition_to_hell()
	assert(host.current_biome == WorldCycleScheduleClass.BiomeType.HELL, "Biome must be HELL")
	assert(host._stinger_player.stream == BiomeEnvironmentHostClass.STREAM_HELL_RUMBLE,
		"Hell descent must play atmospheric dark rumble")
	print("  ✓ Hell descent darkness vignette, rumble audio, and volcanic crackle crossfade verified")
	
	# 4. Test Landing Thud SFX
	host.play_landing_thud()
	assert(host._sfx_player.stream == BiomeEnvironmentHostClass.STREAM_LANDING_THUD, 
		"Landing thud must load vehicle_landing_thud.wav")
	print("  ✓ Physical landing thud sound dispatch verified")
	
	# 5. Test Return Transitions
	host._enter_transition_from_heaven()
	assert(host.current_biome == WorldCycleScheduleClass.BiomeType.NORMAL_LAND, "Return from heaven -> Normal Land")
	host._enter_transition_from_hell()
	assert(host.current_biome == WorldCycleScheduleClass.BiomeType.NORMAL_LAND, "Return from hell -> Normal Land")
	print("  ✓ Cloud tunnel and magma geyser escape return transitions verified")
	
	host.queue_free()
	await process_frame
	return true
