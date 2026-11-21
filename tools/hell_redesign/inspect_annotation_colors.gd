extends SceneTree

func _init() -> void:
	var user_img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	if not user_img:
		print("No hell_cleanup_pink.png")
		quit(1)
		return
		
	print("User image: ", user_img.get_width(), "x", user_img.get_height())
	
	# Let's find pixels that are vivid or drawn:
	# A screenshot of the game has certain characteristics.
	# What colors in the user image have high saturation or are distinct?
	# Let's count color frequencies or find colors where R, G, B are distinctive.
	# Let's check a histogram of colors with high red or magenta/pink or cyan/blue.
	var color_counts: Dictionary = {}
	for y in range(0, user_img.get_height(), 2):
		for x in range(0, user_img.get_width(), 2):
			var c := user_img.get_pixel(x, y)
			# Look for pink / magenta / purple / bright red:
			# If R > 0.6 and B > 0.4 and G < 0.6:
			if c.r > 0.6 and c.b > 0.3 and c.r > c.g + 0.15:
				var key := "R=%.2f G=%.2f B=%.2f" % [snappedf(c.r, 0.05), snappedf(c.g, 0.05), snappedf(c.b, 0.05)]
				color_counts[key] = color_counts.get(key, 0) + 1
				
	var sorted_keys = color_counts.keys()
	sorted_keys.sort_custom(func(a, b): return color_counts[a] > color_counts[b])
	
	print("Top candidate annotation colors:")
	for i in range(min(20, sorted_keys.size())):
		var k = sorted_keys[i]
		print("  %s: %d pixels" % [k, color_counts[k]])
		
	quit(0)
