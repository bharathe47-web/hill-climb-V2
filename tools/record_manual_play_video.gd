@tool
extends SceneTree

# tools/record_manual_play_video.gd
# Captures frame-by-frame gameplay video demonstrating:
# 1. Acceleration
# 2. Braking
# 3. Pickups (Coin & Fuel collection)
# 4. Nitro Boost & Speedometer Spike
# 5. Pause & Resume (Pause Menu overlay)
# 6. Crash & Game Over banner
# 7. Restart & Clean progression continuation

const TOTAL_FRAMES := 550
const FRAME_DIR := "/tmp/video_frames"

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN REALTIME GAMEPLAY VIDEO RECORDING ---")
	print("=================================================================\n")
	await _record_gameplay()
	quit(0)

func _record_gameplay() -> void:
	var dir := DirAccess.open("/tmp")
	if not dir.dir_exists("video_frames"):
		dir.make_dir("video_frames")

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var packed_game: PackedScene = load("res://scenes/game/Game.tscn")
	var game: GameScene = packed_game.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	# Initial warm-up
	for f in range(15):
		await process_frame
		await physics_frame

	var vehicle: VehicleController = game.vehicle as VehicleController
	var gm = game.game_manager

	print(">>> Recording %d frames (~18.3 seconds @ 30 FPS)..." % TOTAL_FRAMES)
	var t_start := Time.get_ticks_msec()

	for frame_idx in range(TOTAL_FRAMES):
		# Scripted input controller simulating active manual play
		# Phase 1: Acceleration (Frames 0 - 50)
		if frame_idx >= 0 and frame_idx < 50:
			Input.action_press("accelerate", 1.0)
			Input.action_release("brake_reverse")
			Input.action_release("nitro")

		# Phase 2: Braking (Frames 50 - 90)
		elif frame_idx >= 50 and frame_idx < 90:
			Input.action_release("accelerate")
			Input.action_press("brake_reverse", 1.0)
			Input.action_release("nitro")

		# Phase 3: Acceleration & Pickup collection (Frames 90 - 180)
		elif frame_idx >= 90 and frame_idx < 180:
			Input.action_release("brake_reverse")
			Input.action_press("accelerate", 1.0)
			Input.action_release("nitro")

		# Phase 4: Nitro Boost (Frames 180 - 260)
		elif frame_idx >= 180 and frame_idx < 260:
			Input.action_press("accelerate", 1.0)
			Input.action_press("nitro", 1.0)
			if vehicle and vehicle.has_method("set_nitro_active"):
				vehicle.set_nitro_active(true)

		# Phase 5: Pause (Frames 260 - 310)
		elif frame_idx == 260:
			Input.action_release("accelerate")
			Input.action_release("nitro")
			if vehicle and vehicle.has_method("set_nitro_active"):
				vehicle.set_nitro_active(false)
			if gm and gm.current_state != gm.RunState.PAUSED:
				gm.toggle_pause()

		# Phase 5b: Resume (Frames 310 - 360)
		elif frame_idx == 310:
			if gm and gm.current_state == gm.RunState.PAUSED:
				gm.toggle_pause()
			Input.action_press("accelerate", 1.0)

		# Phase 6: Crash trigger (Frames 360 - 410)
		elif frame_idx >= 360 and frame_idx < 410:
			Input.action_release("accelerate")
			Input.action_press("tilt_right", 1.0)
			if frame_idx == 370 and vehicle:
				vehicle.angular_velocity = 8.5
				vehicle.rotation = PI * 0.95
			if frame_idx == 385 and vehicle:
				vehicle.crashed.emit()

		# Phase 7: Restart & Smooth progression (Frames 410 - 550)
		elif frame_idx == 410:
			Input.action_release("tilt_right")
			game.restart_game()
			# Re-acquire vehicle after restart
			vehicle = game.vehicle as VehicleController

		elif frame_idx > 415:
			Input.action_press("accelerate", 1.0)

		# Advance physics & frame
		await physics_frame
		await process_frame

		# Capture frame image
		var img: Image = vp.get_texture().get_image()
		if img:
			var frame_path := "%s/frame_%04d.jpg" % [FRAME_DIR, frame_idx]
			img.save_jpg(frame_path, 0.90)

		if frame_idx % 50 == 0:
			print("   ... captured frame %d / %d" % [frame_idx, TOTAL_FRAMES])

	# Cleanup inputs
	Input.action_release("accelerate")
	Input.action_release("brake_reverse")
	Input.action_release("nitro")
	Input.action_release("tilt_right")

	var t_end := Time.get_ticks_msec()
	print("\n✓ Captured %d frames in %.2f seconds (Avg %.1f FPS)" % [
		TOTAL_FRAMES, (t_end - t_start) / 1000.0, float(TOTAL_FRAMES) / ((t_end - t_start) / 1000.0)
	])
	vp.queue_free()
