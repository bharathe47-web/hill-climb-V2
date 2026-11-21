extends SceneTree

func _init() -> void:
	var user_img := Image.load_from_file("references/hell_cleanup_pink.png")
	var moon_img := Image.load_from_file("assets/environments/hell/background/blood_moon/hell_blood_moon.png")
	var fortress_img := Image.load_from_file("assets/environments/hell/background/fortress/hell_giant_demon_fortress.png")
	
	# Check if moon or fortress pixels exist in user_img
	# Let's check user_img at top-right (x=1000..1366, y=0..250)
	print("Checking if blood moon is in user_img:")
	var red_moon_pixels := 0
	for y in range(0, 250):
		for x in range(900, 1366):
			var c := user_img.get_pixel(x, y)
			# Blood moon has high red (0.7-1.0) and moderate green (0.1-0.3)
			if c.r > 0.75 and c.g > 0.15 and c.g < 0.35 and c.b < 0.2:
				red_moon_pixels += 1
	print("Blood moon candidate pixels in upper right: ", red_moon_pixels)
	quit(0)
