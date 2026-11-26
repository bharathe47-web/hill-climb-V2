extends SceneTree

func _init() -> void:
	print("=== INSPECTING KEY EVENT FRAMES ===")
	var event_frames = [7, 14, 20, 31, 37, 45, 54, 64, 68, 76, 85, 98, 103]
	for f in event_frames:
		var p = "/tmp/screencast_frames/frame_%03d.png" % f
		var img = Image.load_from_file(p)
		if img == null:
			continue
		print("\n--- Frame %03d (t=%ds) ---" % [f, f])
		# Let's inspect bottom card area: x=400..900, y=630..720
		# Find if there is text in the bottom card area by sampling high contrast pixels
		var has_text = false
		var text_pixels = 0
		for y in range(630, 720, 2):
			for x in range(400, 900, 2):
				var c = img.get_pixel(x, y)
				# text is bright white/yellow: r > 0.8, g > 0.8, b > 0.8
				if c.r > 0.8 and c.g > 0.8 and c.b > 0.8:
					text_pixels += 1
		print("  Bottom card text pixel count: ", text_pixels)
		
		# Also check center of screen: is there a pause menu, game over dialog, or result dialog?
		var center_text_pixels = 0
		for y in range(250, 450, 4):
			for x in range(450, 850, 4):
				var c = img.get_pixel(x, y)
				if c.r > 0.8 and c.g > 0.8 and c.b > 0.8:
					center_text_pixels += 1
		print("  Center screen text pixel count: ", center_text_pixels)
	quit()
