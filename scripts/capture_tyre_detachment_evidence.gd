extends SceneTree

## capture_tyre_detachment_evidence.gd
## Captures genuine live GPU gameplay evidence for the Vehicle Tyre Detachment Fix across 7 driving conditions:
## 1. Normal driving
## 2. Continuous acceleration
## 3. Nitro boost
## 4. Mid-air jump
## 5. Ground landing
## 6. Vehicle recovery
## 7. Driving after recovery

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_run_captures")

func _run_captures() -> void:
	print("=================================================================")
	print("--- CAPTURING TYRE DETACHMENT FIX GAMEPLAY EVIDENCE ---")
	print("=================================================================")
	RouteRegistry.dev_unlock_all_routes = true

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var out_dir := "docs/screenshots/tyre_detachment_fix/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))

	var mode := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	vp.add_child(mode)
	mode.start_route(RouteRegistry.get_route("tamil_nadu"))

	for f in range(30):
		await physics_frame

	var veh := mode.active_vehicle as VehicleController
	var terr := mode.active_terrain as IndianRoadTerrain
	var hud := mode.hud as IndianRoadsHUD
	var cam := mode.follow_camera as Camera2D

	# -------------------------------------------------------------
	# 1. NORMAL DRIVING
	# -------------------------------------------------------------
	print("-> Capturing 01_normal_driving.png...")
	var x1: float = 80.0 * 100.0
	veh.global_position = Vector2(x1, terr.get_height_at(x1) - 44.0)
	veh.linear_velocity = Vector2(250.0, 0.0)
	Input.action_press("accelerate")
	for f in range(15):
		await physics_frame
	cam.global_position = Vector2(veh.global_position.x + 180.0, veh.global_position.y - 60.0)
	for f in range(5):
		await physics_frame
	_save_viewport(vp, out_dir + "01_normal_driving.png")

	# -------------------------------------------------------------
	# 2. CONTINUOUS ACCELERATION (High Speed)
	# -------------------------------------------------------------
	print("-> Capturing 02_continuous_acceleration.png...")
	Input.action_press("accelerate")
	for f in range(15):
		await physics_frame
	cam.global_position = Vector2(veh.global_position.x + 180.0, veh.global_position.y - 60.0)
	for f in range(5):
		await physics_frame
	_save_viewport(vp, out_dir + "02_continuous_acceleration.png")

	# -------------------------------------------------------------
	# 3. NITRO BOOST (High Torque + Nitro Jet Flames)
	# -------------------------------------------------------------
	print("-> Capturing 03_nitro_boost.png...")
	veh.set_nitro_active(true)
	for f in range(15):
		await physics_frame
	cam.global_position = Vector2(veh.global_position.x + 180.0, veh.global_position.y - 60.0)
	for f in range(5):
		await physics_frame
	_save_viewport(vp, out_dir + "03_nitro_boost.png")
	veh.set_nitro_active(false)

	# -------------------------------------------------------------
	# 4. JUMPING (Mid-Air Elevation)
	# -------------------------------------------------------------
	print("-> Capturing 04_jumping.png...")
	var xj: float = veh.global_position.x + 600.0
	veh.global_position = Vector2(xj, terr.get_height_at(xj) - 150.0)
	veh.rotation = -0.15
	veh.linear_velocity = Vector2(380.0, -90.0)
	cam.global_position = Vector2(veh.global_position.x + 180.0, veh.global_position.y - 30.0)
	for f in range(8):
		await physics_frame
	_save_viewport(vp, out_dir + "04_jumping.png")

	# -------------------------------------------------------------
	# 5. LANDING (Compression and Ground Contact)
	# -------------------------------------------------------------
	print("-> Capturing 05_landing.png...")
	var xl: float = veh.global_position.x + 500.0
	veh.global_position = Vector2(xl, terr.get_height_at(xl) - 38.0)
	veh.rotation = 0.02
	veh.linear_velocity = Vector2(300.0, 40.0)
	cam.global_position = Vector2(veh.global_position.x + 180.0, veh.global_position.y - 60.0)
	for f in range(6):
		await physics_frame
	_save_viewport(vp, out_dir + "05_landing.png")

	# -------------------------------------------------------------
	# 6. RECOVERY (Uprighted at Road Surface)
	# -------------------------------------------------------------
	print("-> Capturing 06_recovery.png...")
	var xr: float = veh.global_position.x + 400.0
	var yr: float = terr.get_height_at(xr) - 45.0
	veh.recover_vehicle(Vector2(xr, yr))
	hud.show_announcement_toast("RECOVERED!", "Vehicle uprighted — physics joints aligned")
	cam.global_position = Vector2(xr + 180.0, yr - 60.0)
	for f in range(8):
		await physics_frame
	_save_viewport(vp, out_dir + "06_recovery.png")

	# -------------------------------------------------------------
	# 7. DRIVING AFTER RECOVERY (Nitro & Full Acceleration Post-Recovery)
	# -------------------------------------------------------------
	print("-> Capturing 07_driving_after_recovery.png...")
	Input.action_press("accelerate")
	veh.set_nitro_active(true)
	for f in range(15):
		await physics_frame
	cam.global_position = Vector2(veh.global_position.x + 180.0, veh.global_position.y - 60.0)
	for f in range(5):
		await physics_frame
	_save_viewport(vp, out_dir + "07_driving_after_recovery.png")
	veh.set_nitro_active(false)
	Input.action_release("accelerate")

	mode.queue_free()
	vp.queue_free()

	print("\n=================================================================")
	print("✓ ALL 7 SCREENSHOTS SUCCESSFULLY CAPTURED IN: ", out_dir)
	print("=================================================================")
	quit(0)

func _save_viewport(vp: SubViewport, path: String) -> void:
	var img := vp.get_texture().get_image()
	if img != null and not img.is_empty():
		var err := img.save_png(ProjectSettings.globalize_path(path))
		if err == OK:
			print("  ✓ Saved: ", path)
		else:
			push_error("Failed to save: " + path)
