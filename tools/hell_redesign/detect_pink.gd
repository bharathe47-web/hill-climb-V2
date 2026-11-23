@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_pink.png"
	var img := Image.load_from_file(path)
	if not img:
		quit(1)
		return

	print("Image size: ", img.get_size())
	# Let's find pixels that have high saturation or unusual hues
	# In Hell, most pixels are shades of dark crimson, orange, black, or grey.
	# Let's compute for each pixel how "pink" it is:
	# Pink/Magenta: R is high, G is low, B is high. Or R is very high and B is moderate.
	# What if the user drew with a pink pen that has e.g. R=255, G=105, B=180 (hot pink)?
	# In normalized: R ~ 1.0, G ~ 0.41, B ~ 0.70! Notice G is 0.41!
	# In our previous check we had g < 0.4! So G=0.41 would be excluded!
	var hot_pink_count := 0
	var samples := []
	for y in range(0, img.get_height(), 1):
		for x in range(0, img.get_width(), 1):
			var c := img.get_pixel(x, y)
			# Let's check for any pink-like color:
			# R > G and B > G, or R > 0.6 and B > 0.3 and R > G*1.3
			# Or R > 0.7 and G between 0.1 and 0.6 and B > 0.4
			if c.r > 0.6 and c.b > 0.35 and c.r > c.g * 1.2:
				# check if pinkish (r high, b high, g lower than b or close to b)
				if c.b > c.g * 0.9:
					hot_pink_count += 1
					if samples.size() < 10:
						samples.append("x=%d,y=%d: R=%.2f G=%.2f B=%.2f" % [x, y, c.r, c.g, c.b])

	print("Found %d candidate pixels" % hot_pink_count)
	for s in samples:
		print("  ", s)
	quit(0)
