extends SceneTree

const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")
const RouteRegistry = preload("res://scripts/modes/indian_roads/RouteRegistry.gd")

func _init() -> void:
	call_deferred("_capture_traversal_shots")

func _capture_traversal_shots() -> void:
	print("=================================================================")
	print("--- CAPTURING KANYAKUMARI GLASS BRIDGE TRAVERSAL SCREENSHOTS ---")
	print("=================================================================")

	RouteRegistry.dev_unlock_all_routes = true

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var mode := IndianRoadsModeV2Scene.instantiate() as IndianRoadsControllerV2
	mode.start_with_selection = false
	mode.default_state_id = "tamil_nadu"
	vp.add_child(mode)

	for i in range(15):
		await process_frame

	var terr := mode.active_terrain
	var veh := mode.active_vehicle
	var cam := mode.follow_camera
	var hud := mode.hud

	var shots = [
		{
			"dist_m": 250.0,
			"path": "docs/screenshots/glass_bridge_1_before_entrance.png",
			"desc": "Before entrance: approaching Kanyakumari Glass Bridge entrance portal (250m)"
		},
		{
			"dist_m": 285.0,
			"path": "docs/screenshots/glass_bridge_2_entering_ramp.png",
			"desc": "Entering ramp: vehicle climbing smoothstep ramp onto elevated ocean deck (285m)"
		},
		{
			"dist_m": 360.0,
			"path": "docs/screenshots/glass_bridge_3_halfway_deck.png",
			"desc": "Halfway deck: elevated arched glass deck spanning ocean between Vivekananda Rock and Thiruvalluvar Statue (360m)"
		},
		{
			"dist_m": 430.0,
			"path": "docs/screenshots/glass_bridge_4_near_exit.png",
			"desc": "Near exit: descending ramp past Thiruvalluvar Statue pedestal platform (430m)"
		},
		{
			"dist_m": 465.0,
			"path": "docs/screenshots/glass_bridge_5_after_exit.png",
			"desc": "After exit: vehicle back on mainland coastal highway towards Vattakottai (465m)"
		}
	]

	for s in shots:
		var dist_m: float = s["dist_m"]
		var x: float = dist_m * 100.0
		var y: float = terr.get_height_at(x)

		# Position vehicle
		veh.global_position = Vector2(x, y - 35.0)
		veh.linear_velocity = Vector2(350.0, 0.0)

		# Position camera centered on vehicle with gentle offset
		if cam != null:
			cam.global_position = Vector2(x + 100.0, y - 60.0)

		# Update HUD labels
		if hud != null:
			if hud.has_node("TopBanner/DistanceLabel"):
				hud.get_node("TopBanner/DistanceLabel").text = "DIST: %dm / 1800m" % int(dist_m)
			if hud.has_node("TopBanner/NextWaypointLabel"):
				if dist_m < 270.0:
					hud.get_node("TopBanner/NextWaypointLabel").text = "NEXT: Glass Bridge Skywalk (270m)"
				elif dist_m < 315.0:
					hud.get_node("TopBanner/NextWaypointLabel").text = "NEXT: Vivekananda Rock Island (315m)"
				elif dist_m < 415.0:
					hud.get_node("TopBanner/NextWaypointLabel").text = "NEXT: Thiruvalluvar Statue Island (415m)"
				else:
					hud.get_node("TopBanner/NextWaypointLabel").text = "NEXT: Vattakottai Coastal Fort (550m)"

		# Render several physics frames for settle and draw
		for f in range(25):
			await physics_frame

		var img := vp.get_texture().get_image()
		if img != null and not img.is_empty():
			img.save_png(s["path"])
			print("✓ CAPTURED [%.0fm]: %s" % [dist_m, s["path"]])
			print("   Description: %s" % s["desc"])
		else:
			print("❌ FAILED to capture viewport for %s" % s["path"])

	mode.queue_free()
	vp.queue_free()
	RouteRegistry.dev_unlock_all_routes = false

	print("=================================================================")
	print("✓ ALL 5 GLASS BRIDGE TRAVERSAL SCREENSHOTS CAPTURED!")
	print("=================================================================")
	quit(0)
