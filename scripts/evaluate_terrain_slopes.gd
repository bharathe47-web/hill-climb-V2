extends SceneTree

func _init() -> void:
	print("=== EVALUATING TAMIL NADU TERRAIN PROFILE & SLOPES ===")
	# In IndianRoadTerrain, step is 60 px.
	# Let's inspect terrain heights and slopes every 10 meters (1000 px)
	var route_res = load("res://data/routes/indian_roads_tamil_nadu.tres")
	var terr = preload("res://scripts/modes/indian_roads/IndianRoadTerrain.gd").new()
	terr.active_route = route_res
	terr.total_length_px = 1200.0 * 100.0 # 120,000 px
	terr._apply_state_theme("tamil_nadu")
	
	var max_slope = 0.0
	var max_slope_x = 0.0
	var max_slope_desc = ""
	
	for dist_m in range(0, 1250, 10):
		var x = dist_m * 100.0
		var y1 = terr._calculate_road_height(x - 30.0)
		var y2 = terr._calculate_road_height(x + 30.0)
		var slope = (y2 - y1) / 60.0
		var angle_deg = rad_to_deg(atan(slope))
		if absf(angle_deg) > max_slope:
			max_slope = absf(angle_deg)
			max_slope_x = dist_m
		if dist_m % 100 == 0 or absf(angle_deg) > 12.0:
			print("Dist: %4dm (x=%6d px) | Height: %6.1f | Slope: %5.1f deg" % [
				dist_m, int(x), y1, angle_deg
			])
	print("\nMax Slope encountered: %.1f deg at dist=%dm" % [max_slope, int(max_slope_x)])
	quit()
