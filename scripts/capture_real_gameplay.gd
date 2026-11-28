extends SceneTree

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const StateSelectionScene = preload("res://scenes/modes/indian_roads/StateSelection.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_capture_all")

func _capture_all() -> void:
	print("--- CAPTURING ACTUAL RUNTIME GAMEPLAY SCREENSHOTS ---")
	RouteRegistry.dev_unlock_all_routes = true

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	# 1. State Selection Hub Screenshot
	var sel = StateSelectionScene.instantiate()
	vp.add_child(sel)
	for i in range(10):
		await process_frame
	var img_sel = vp.get_texture().get_image()
	if img_sel != null:
		img_sel.save_png("docs/screenshots/state_selection_screen.png")
		print("✓ Captured: docs/screenshots/state_selection_screen.png")
	sel.queue_free()
	await process_frame

	# 2. State Routes Gameplay
	var states_to_capture = [
		["tamil_nadu", "docs/screenshots/kanyakumari_gameplay.png"],
		["goa", "docs/screenshots/goa_gameplay.png"],
		["kerala", "docs/screenshots/kerala_gameplay.png"],
		["rajasthan", "docs/screenshots/rajasthan_gameplay.png"]
	]

	for item in states_to_capture:
		var state_id: String = item[0]
		var out_path: String = item[1]
		var mode = IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
		mode.start_with_selection = false
		mode.default_state_id = state_id
		vp.add_child(mode)

		# Simulate 40 frames of driving to populate vehicle, camera, road, and parallax
		Input.action_press("accelerate")
		for i in range(40):
			await physics_frame
		Input.action_release("accelerate")

		var img = vp.get_texture().get_image()
		if img != null:
			img.save_png(out_path)
			print("✓ Captured: %s (State: %s)" % [out_path, state_id])

		mode.queue_free()
		await process_frame

	RouteRegistry.dev_unlock_all_routes = false
	vp.queue_free()
	print("--- ALL SCREENSHOTS CAPTURED SUCCESSFULLY ---")
	quit(0)
