extends SceneTree

func _init() -> void:
	print("=== ANALYZING VIDEO FRAMES & SCREENSHOTS ===")
	# Let's inspect frames at intervals: 1, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110
	var sample_frames = [1, 5, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100, 110, 114]
	for f in sample_frames:
		var p = "/tmp/screencast_frames/frame_%03d.png" % f
		var img = Image.load_from_file(p)
		if img == null:
			continue
		# HUD is typically at the top left/top right/top center
		# Let's inspect center-top area or checkpoint text if visible
		# We can also check average brightness and dominant colors in sky (top 20%) and ground (bottom 30%)
		var sky_r = 0.0
		var sky_g = 0.0
		var sky_b = 0.0
		var sky_count = 0
		for y in range(20, 120, 10):
			for x in range(200, 800, 20):
				var c = img.get_pixel(x, y)
				sky_r += c.r
				sky_g += c.g
				sky_b += c.b
				sky_count += 1
		var g_r = 0.0
		var g_g = 0.0
		var g_b = 0.0
		var g_count = 0
		for y in range(img.get_height() - 150, img.get_height() - 50, 10):
			for x in range(200, 800, 20):
				var c = img.get_pixel(x, y)
				g_r += c.r
				g_g += c.g
				g_b += c.b
				g_count += 1
		print("Frame %03d (t=%3ds): Sky RGB(%.2f, %.2f, %.2f) | Ground RGB(%.2f, %.2f, %.2f)" % [
			f, f, sky_r/sky_count, sky_g/sky_count, sky_b/sky_count, g_r/g_count, g_g/g_count, g_b/g_count
		])
	quit()
