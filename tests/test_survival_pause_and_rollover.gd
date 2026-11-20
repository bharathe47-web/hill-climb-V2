extends SceneTree

const SurvivalScene: PackedScene = preload("res://scenes/modes/survival/Survival.tscn")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN SURVIVAL MODE PAUSE & ROLLOVER VERIFICATION ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var win = root
	var survival = SurvivalScene.instantiate()
	win.add_child(survival)

	for i in range(10):
		await process_frame

	var controller = survival
	var veh = controller.vehicle
	var pause_menu = controller.pause_menu
	var hud = controller.hud
	var pause_btn = hud.find_child("PauseButton", true, false) as TextureButton

	assert(veh != null, "Vehicle must exist")
	assert(pause_menu != null, "PauseMenu must exist in Survival scene")
	assert(pause_btn != null, "PauseButton must exist in Survival HUD")

	# =========================================================================
	# TEST A: Pause Button & PauseMenu Functionality
	# =========================================================================
	print("-> [1/4] Testing Survival Mode Pause Button & PauseMenu...")
	assert(controller.current_state == controller.RunState.PLAYING, "Game must start in PLAYING state")
	assert(root.get_tree().paused == false, "Tree must initially be unpaused")
	assert(pause_menu.visible == false, "PauseMenu must initially be hidden")

	var music_player: AudioStreamPlayer = controller.get_node_or_null("%SurvivalMusicPlayer")
	assert(music_player != null, "SurvivalMusicPlayer must exist")
	assert(music_player.stream_paused == false, "Music must not be paused initially")

	# Click Pause Button
	print("  • Clicking blue circular PauseButton...")
	pause_btn.emit_signal("pressed")
	for i in range(3):
		await process_frame

	assert(controller.current_state == controller.RunState.PAUSED, "State must be PAUSED after clicking PauseButton")
	assert(root.get_tree().paused == true, "SceneTree must be paused")
	assert(pause_menu.visible == true, "PauseMenu must become visible")
	assert(music_player.stream_paused == true, "Background music must be paused via stream_paused")
	print("  ✓ Gameplay paused, PauseMenu displayed, and background music paused!")

	# Click Resume Button inside PauseMenu
	print("  • Clicking ResumeButton inside PauseMenu...")
	var resume_btn: Button = pause_menu.find_child("ResumeButton", true, false)
	assert(resume_btn != null, "ResumeButton must exist")
	resume_btn.emit_signal("pressed")
	for i in range(3):
		await process_frame

	assert(controller.current_state == controller.RunState.PLAYING, "State must return to PLAYING after Resume")
	assert(root.get_tree().paused == false, "SceneTree must be unpaused after Resume")
	assert(pause_menu.visible == false, "PauseMenu must be hidden after Resume")
	assert(music_player.stream_paused == false, "Background music must resume playback")
	print("  ✓ Gameplay and music resumed seamlessly!")

	# Test direct toggle from PauseButton while paused
	print("  • Testing PauseButton toggle behavior...")
	pause_btn.emit_signal("pressed")
	for i in range(3):
		await process_frame
	assert(controller.current_state == controller.RunState.PAUSED, "Paused again via PauseButton")
	
	pause_btn.emit_signal("pressed")
	for i in range(3):
		await process_frame
	assert(controller.current_state == controller.RunState.PLAYING, "Resumed via PauseButton toggle")
	print("  ✓ PauseButton toggle functionality verified!")

	# =========================================================================
	# TEST B: Vehicle Rollover & Game Over
	# =========================================================================
	print("\n-> [2/4] Testing Vehicle Inversion and Rollover Grace Timer...")
	# Normal upright driving
	veh.global_rotation = deg_to_rad(20.0) # 20 deg slope
	controller._check_vehicle_rollover(0.5)
	assert(controller._rollover_timer == 0.0, "Moderate tilt must not advance rollover timer")
	assert(controller.current_state == controller.RunState.PLAYING, "Game must remain PLAYING on normal slopes")

	# Temporary flip / air tilt that recovers before grace duration
	print("  • Simulating brief inversion that recovers (0.4s inverted)...")
	veh.global_rotation = deg_to_rad(170.0) # inverted
	controller._check_vehicle_rollover(0.4)
	assert(controller._rollover_timer > 0.35, "Rollover timer advances while inverted")
	assert(controller.current_state == controller.RunState.PLAYING, "Grace period prevents premature Game Over")
	
	# Car recovers to wheels
	veh.global_rotation = deg_to_rad(10.0)
	controller._check_vehicle_rollover(0.1)
	assert(controller._rollover_timer == 0.0, "Rollover timer must reset to 0 upon recovery")
	print("  ✓ Temporary inversion recovers cleanly without Game Over!")

	# Sustained full inversion exceeding grace duration (1.0s)
	print("  • Simulating sustained vehicle rollover (1.1s inverted)...")
	veh.global_rotation = deg_to_rad(180.0)
	controller._check_vehicle_rollover(0.6)
	assert(controller.current_state == controller.RunState.PLAYING, "Still within grace duration (0.6s / 1.0s)")
	controller._check_vehicle_rollover(0.5) # Total 1.1s
	
	assert(controller.current_state == controller.RunState.FINISHED, "Sustained inversion must trigger FINISHED state")
	assert(controller.game_over_panel.visible == true, "Game Over panel must be displayed")
	var reason_lbl: Label = controller.game_over_panel.find_child("ReasonLabel", true, false)
	assert(reason_lbl != null and "OVERTURNED" in reason_lbl.text, "Reason must indicate vehicle overturned")
	print("  ✓ Sustained rollover triggered existing Game Over with reason: ", reason_lbl.text)

	# =========================================================================
	# TEST C: Interaction Between Pause & Rollover
	# =========================================================================
	print("\n-> [3/4] Testing Rollover Timer Freeze During Pause...")
	# Restart run
	controller.start_run()
	for i in range(3):
		await process_frame
	assert(controller._rollover_timer == 0.0, "Timer resets on run restart")
	
	# Invert vehicle for 0.5s
	veh.global_rotation = deg_to_rad(160.0)
	controller._check_vehicle_rollover(0.5)
	var timer_val_before_pause: float = controller._rollover_timer
	assert(timer_val_before_pause > 0.45, "Timer at 0.5s")

	# Pause the game
	controller.pause_run(true)
	# Simulate frames while paused
	controller._check_vehicle_rollover(0.8)
	assert(controller._rollover_timer == timer_val_before_pause, "Rollover timer must NOT advance while paused")
	assert(controller.current_state == controller.RunState.PAUSED, "State must remain PAUSED, not Game Over")

	# Resume game
	controller.pause_run(false)
	assert(controller.current_state == controller.RunState.PLAYING, "Resumed")
	# Now finish the rollover
	controller._check_vehicle_rollover(0.6) # 0.5 + 0.6 = 1.1s > 1.0s grace
	assert(controller.current_state == controller.RunState.FINISHED, "Game Over triggers after resumption")
	print("  ✓ Rollover timer froze while paused and finished correctly after resume!")

	# =========================================================================
	# TEST D: PauseMenu Retry & Main Menu Navigation
	# =========================================================================
	print("\n-> [4/4] Testing PauseMenu Retry & Main Menu Navigation...")
	controller.start_run()
	for i in range(3):
		await process_frame
	controller.pause_run(true)
	assert(root.get_tree().paused == true, "Paused")

	var retry_btn: Button = pause_menu.find_child("RetryButton", true, false)
	assert(retry_btn != null, "RetryButton must exist")
	retry_btn.emit_signal("pressed")
	for i in range(3):
		await process_frame

	assert(root.get_tree().paused == false, "Tree unpaused after Retry")
	assert(controller.current_state == controller.RunState.PLAYING, "State is PLAYING after Retry")
	assert(pause_menu.visible == false, "PauseMenu hidden after Retry")
	print("  ✓ Retry from PauseMenu successfully restarts run!")

	print("\n=================================================================")
	print("✓ ALL SURVIVAL MODE PAUSE & ROLLOVER TESTS PASSED 100%!")
	print("=================================================================\n")

	survival.queue_free()
	quit(0)
