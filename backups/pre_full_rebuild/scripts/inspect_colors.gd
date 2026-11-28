extends SceneTree

func _init():
	for idx in [1, 2, 3]:
		var img = Image.new()
		img.load("res://assets/indian_roads_replacements/thumb_meenakshi_" + str(idx) + ".png")
		var w = img.get_width()
		var h = img.get_height()
		var saturated = 0
		for y in range(h):
			for x in range(w):
				var c = img.get_pixel(x, y)
				if c.s > 0.25 and c.v > 0.2:
					saturated += 1
		print("Thumb ", idx, " (", w, "x", h, ") saturated pixels: ", saturated, " (", float(saturated)/(w*h)*100.0, "%)")
	quit(0)
