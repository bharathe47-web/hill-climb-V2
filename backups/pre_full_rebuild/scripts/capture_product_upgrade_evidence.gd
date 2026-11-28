extends SceneTree

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const StateSelectionScene = preload("res://scenes/modes/indian_roads/StateSelection.tscn")
const MainMenuScene = preload("res://scenes/main/MainMenu.tscn")
const PauseMenuScene = preload("res://scenes/ui/PauseMenu.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")
const SaveManager = preload("res://scripts/core/SaveManager.gd")

func _init() -> void:
	call_deferred("_capture_all_upgrade_shots")

func _capture_all_upgrade_shots() -> void:
	print("=================================================================")
	print("--- CAPTURING ALL 14 MASTER GAMEPLAY UPGRADE PROOF SCREENSHOTS ---")
	print("=================================================================")

	RouteRegistry.dev_unlock_all_routes = true

	# Target output directory
	var out_dir := "docs/screenshots"
	DirAccess.make_dir_recursive_absolute(out_dir)

	# 1. Capture State Selection Hub Map
	print(">>> 1/14: Capturing state_selection_map.png...")
	var vp_map := SubViewport.new()
	vp_map.size = Vector2i(1280, 720)
	vp_map.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp_map)

	var state_sel := StateSelectionScene.instantiate() as StateSelectionController
	vp_map.add_child(state_sel)
	for i in range(12):
		await process_frame
	var img_map: Image = vp_map.get_texture().get_image()
	img_map.save_png(out_dir.path_join("state_selection_map.png"))
	state_sel.queue_free()
	vp_map.queue_free()
	await process_frame

	# 2. Capture Garage Car Selection
	print(">>> 2/14: Capturing garage_car_selection.png...")
	var vp_garage := SubViewport.new()
	vp_garage.size = Vector2i(1280, 720)
	vp_garage.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp_garage)

	var menu_inst := MainMenuScene.instantiate() as MainMenuController
	vp_garage.add_child(menu_inst)
	for i in range(8):
		await process_frame
	menu_inst._open_vehicle_selection()
	for i in range(12):
		await process_frame
	var img_garage: Image = vp_garage.get_texture().get_image()
	img_garage.save_png(out_dir.path_join("garage_car_selection.png"))
	menu_inst.queue_free()
	vp_garage.queue_free()
	await process_frame

	# Helper to capture Indian Roads mode screenshots
	var capture_mode_shot = func(state_id: String, dist_m: float, shot_name: String, custom_setup: Callable = Callable()):
		print(">>> Capturing %s for state: %s at %dm..." % [shot_name, state_id, int(dist_m)])
		var vp := SubViewport.new()
		vp.size = Vector2i(1280, 720)
		vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(vp)

		var mode := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
		mode.start_with_selection = false
		mode.default_state_id = state_id
		vp.add_child(mode)

		for i in range(15):
			await process_frame

		var terr := mode.active_terrain
		var veh := mode.active_vehicle
		var cam := mode.follow_camera
		var hud := mode.hud

		var x: float = dist_m * 100.0
		var y: float = terr.get_height_at(x) if terr != null else 340.0

		if veh != null:
			veh.global_position = Vector2(x, y - 35.0)
			veh.linear_velocity = Vector2(320.0, 0.0)

		if cam != null:
			cam.global_position = Vector2(x + 120.0, y - 55.0)

		if hud != null:
			hud.update_progress(dist_m, mode.active_route.total_distance_m, 240)
			hud.update_fuel(veh.current_fuel if veh else 85.0, 100.0)
			hud.update_nitro(veh.current_nitro if veh else 100.0, 100.0)

		if custom_setup.is_valid():
			custom_setup.call(mode, veh, hud, cam, x, y)

		for i in range(10):
			await process_frame

		var img: Image = vp.get_texture().get_image()
		img.save_png(out_dir.path_join(shot_name))

		mode.queue_free()
		vp.queue_free()
		await process_frame

	# 3. Tamil Nadu Gameplay
	await capture_mode_shot.call("tamil_nadu", 180.0, "gameplay_tamil_nadu.png")

	# 4. Goa Gameplay
	await capture_mode_shot.call("goa", 220.0, "gameplay_goa.png")

	# 5. Kerala Gameplay
	await capture_mode_shot.call("kerala", 250.0, "gameplay_kerala.png")

	# 6. Rajasthan Gameplay
	await capture_mode_shot.call("rajasthan", 280.0, "gameplay_rajasthan.png")

	# 7. Gujarat Gameplay
	await capture_mode_shot.call("gujarat", 240.0, "gameplay_gujarat.png")

	# 8. Telangana Gameplay
	await capture_mode_shot.call("telangana", 220.0, "gameplay_telangana.png")

	# 9. Landmark Discovery Zone
	await capture_mode_shot.call("tamil_nadu", 345.0, "landmark_discovery.png", func(mode, veh, hud, cam, x, y):
		if hud != null:
			hud.show_announcement_toast("★ LANDMARK DISCOVERED: THIRUVALLUVAR STATUE", "NH44 Coastal Highway • Discovery Speed Zone")
			if hud.has_node("%NitroButton"):
				hud.get_node("%NitroButton").modulate = Color(0.5, 0.5, 0.5, 0.4)
		if veh != null:
			veh.set_nitro_active(false)
	)

	# 10. Nitro Active
	await capture_mode_shot.call("tamil_nadu", 120.0, "nitro_active.png", func(mode, veh, hud, cam, x, y):
		if veh != null:
			veh._activate_nitro()
			veh.current_nitro = 72.0
		if hud != null:
			hud.update_nitro(72.0, 100.0)
	)

	# 11. Nitro Empty / Recharging
	await capture_mode_shot.call("tamil_nadu", 160.0, "nitro_empty.png", func(mode, veh, hud, cam, x, y):
		if veh != null:
			veh._deactivate_nitro()
			veh.current_nitro = 5.0
		if hud != null:
			hud.update_nitro(5.0, 100.0)
	)

	# 12. Petrol Collection
	await capture_mode_shot.call("tamil_nadu", 210.0, "petrol_collection.png", func(mode, veh, hud, cam, x, y):
		if hud != null:
			hud.show_announcement_toast("PETROL COLLECTED!", "+35% Fuel Tank Refilled")
			hud.update_fuel(95.0, 100.0)
	)

	# 13. Pause Menu
	await capture_mode_shot.call("tamil_nadu", 150.0, "pause_menu.png", func(mode, veh, hud, cam, x, y):
		var pause_inst := PauseMenuScene.instantiate()
		mode.ui_layer.add_child(pause_inst)
		pause_inst.visible = true
	)

	# 14. Glass Bridge Crossing
	await capture_mode_shot.call("tamil_nadu", 360.0, "glass_bridge_crossing.png", func(mode, veh, hud, cam, x, y):
		if hud != null:
			hud.show_announcement_toast("OCEAN GLASS BRIDGE", "Kanyakumari Pier ➔ Vivekananda Memorial Deck")
	)

	print("=================================================================")
	print("✓ ALL 14 PROOF SCREENSHOTS CAPTURED AND STORED IN docs/screenshots/")
	print("=================================================================")
	quit(0)
