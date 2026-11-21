@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_569m.png")
	# Let's inspect the region 240..352, 624..736
	# Print non-blue pixels and see what colors they are
	var total_pixels := 0
	var blue_pixels := 0
	var colors := {}
	for y in range(624, 736):
		for x in range(240, 352):
			total_pixels += 1
			var c := img.get_pixel(x, y)
			if c.b > 0.65 and c.b > c.r + 0.3:
				blue_pixels += 1
			else:
				var hex := c.to_html(false)
				colors[hex] = colors.get(hex, 0) + 1
	print("Total: ", total_pixels, " Blue: ", blue_pixels)
	# Sort top colors
	var sorted_cols := colors.keys()
	sorted_cols.sort_custom(func(a, b): return colors[a] > colors[b])
	for i in range(mini(15, sorted_cols.size())):
		var h: String = sorted_cols[i]
		print("Color: #", h, " Count: ", colors[h])
	quit(0)
