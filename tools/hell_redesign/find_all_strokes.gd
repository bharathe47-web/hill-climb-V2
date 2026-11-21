@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_white_circles.png"
	var img := Image.load_from_file(path)
	if not img: quit(1); return
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# Also let's inspect the HUD distance
	# The distance label is around x=500..800, y=10..60
	# Let's save a crop of the top HUD
	var hud_crop := img.get_region(Rect2i(w/2 - 250, 0, 500, 100))
	hud_crop.save_png("res://references/user_screen_hud.png")

	# Let's render an ASCII map (40 cols x 20 rows) of the whole image
	var grid_w := 60
	var grid_h := 30
	var cell_w := w / grid_w
	var cell_h := h / grid_h
	
	print("ASCII map of brightest pixels or strokes:")
	for gy in range(grid_h):
		var line := ""
		for gx in range(grid_w):
			# find max lum or stroke in this cell
			var has_stroke := false
			var max_lum := 0.0
			for dy in range(cell_h):
				for dx in range(cell_w):
					var px := gx * cell_w + dx
					var py := gy * cell_h + dy
					var c := img.get_pixel(px, py)
					var lum := 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
					if lum > max_lum:
						max_lum = lum
					# check if white stroke: lum > 0.85
					if lum > 0.85 and (maxf(c.r, maxf(c.g, c.b)) - minf(c.r, minf(c.g, c.b))) < 0.15:
						has_stroke = true
			if has_stroke and gy > 3 and gy < 24 and gx > 2 and gx < 57:
				line += "O"
			elif max_lum > 0.7:
				line += "*"
			elif max_lum > 0.4:
				line += "."
			else:
				line += " "
		print(line)

	quit(0)
