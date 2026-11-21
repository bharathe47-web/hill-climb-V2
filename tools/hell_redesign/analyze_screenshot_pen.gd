@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_white_circles.png"
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# Let's count high-intensity colors across the image (excluding HUD and pedals)
	# Check for pure white, pure yellow, pure cyan, pure red, pure green, magenta, etc.
	var color_counts: Dictionary = {}
	for y in range(120, 600):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# If pixel is very bright
			if c.r > 0.8 or c.g > 0.8 or c.b > 0.8:
				# Categorize color
				var key := "R%.1f_G%.1f_B%.1f" % [round(c.r * 10.0)/10.0, round(c.g * 10.0)/10.0, round(c.b * 10.0)/10.0]
				color_counts[key] = color_counts.get(key, 0) + 1

	# Print top bright colors
	var keys = color_counts.keys()
	keys.sort_custom(func(a, b): return color_counts[a] > color_counts[b])
	print("Top bright colors in y=[120..600]:")
	for i in range(mini(25, keys.size())):
		var k: String = keys[i]
		print("  %s: %d pixels" % [k, color_counts[k]])

	quit(0)
