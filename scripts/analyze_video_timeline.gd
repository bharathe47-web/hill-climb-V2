extends SceneTree

func _init() -> void:
	print("=== DETAILED VIDEO TIMELINE ANALYSIS (114s) ===")
	# Let's inspect each frame from 1 to 114
	# We want to detect:
	# 1. Car position (detect red car body pixels or wheel pixels)
	# 2. Checkpoint banner or info card appearance
	# 3. Background changes
	var car_r_min = 0.55
	var car_g_max = 0.35
	var car_b_max = 0.35
	
	for sec in range(1, 115):
		var path = "/tmp/screencast_frames/frame_%03d.png" % sec
		var img = Image.load_from_file(path)
		if img == null:
			continue
		var w = img.get_width()
		var h = img.get_height()
		
		# Count red pixels in the middle-left area where player car is (x: 100 to 500, y: 250 to 650)
		var car_pixels = 0
		var car_avg_y = 0.0
		var car_avg_x = 0.0
		for y in range(250, 650, 5):
			for x in range(100, 500, 5):
				var c = img.get_pixel(x, y)
				if c.r > car_r_min and c.g < car_g_max and c.b < car_b_max:
					car_pixels += 1
					car_avg_x += x
					car_avg_y += y
		if car_pixels > 0:
			car_avg_x /= car_pixels
			car_avg_y /= car_pixels
		
		# Check for UI popup / banner in top middle (x: 400 to 900, y: 50 to 180)
		var ui_card_pixels = 0
		for y in range(50, 180, 5):
			for x in range(400, 900, 5):
				var c = img.get_pixel(x, y)
				# Checkpoint banners usually have distinct bright or dark rectangular backgrounds
				if (c.r < 0.15 and c.g < 0.15 and c.b < 0.15 and c.a > 0.8) or (c.r > 0.85 and c.g > 0.75 and c.b < 0.2):
					ui_card_pixels += 1
		
		# Check for Bottom landmark card (x: 350 to 1000, y: 620 to 740)
		var bottom_card_pixels = 0
		for y in range(620, 740, 5):
			for x in range(350, 1000, 5):
				var c = img.get_pixel(x, y)
				if c.r > 0.05 and c.r < 0.25 and c.g > 0.08 and c.g < 0.28 and c.b > 0.12 and c.b < 0.35:
					bottom_card_pixels += 1
		
		# Sample ground height at x=400: scan down from y=200 to 760 to find road surface
		var road_y = -1
		for y in range(200, 760, 4):
			var c = img.get_pixel(400, y)
			# Road is dark gray / asphalt (r ~ 0.2, g ~ 0.2, b ~ 0.2) or road line
			if y > 300 and c.r > 0.12 and c.r < 0.35 and c.g > 0.12 and c.g < 0.35 and c.b > 0.12 and c.b < 0.35:
				var below = img.get_pixel(400, min(y+30, 767))
				# Check if below is dirt/soil
				if below.r > 0.25 or below.g > 0.25:
					road_y = y
					break
		
		if sec % 5 == 0 or sec == 1 or ui_card_pixels > 200 or bottom_card_pixels > 400:
			print("t=%3ds: Car(x=%.0f, y=%.0f, px=%d) | UI_top=%d UI_btm=%d | RoadY=%d" % [
				sec, car_avg_x, car_avg_y, car_pixels, ui_card_pixels, bottom_card_pixels, road_y
			])
	quit()
