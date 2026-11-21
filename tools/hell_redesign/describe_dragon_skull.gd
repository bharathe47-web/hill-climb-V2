extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/dragon_skull_inspect.png")
	if not img:
		quit(1)
		return
	print("Size: ", img.get_size())
	# Let's inspect brightness across the image in a 10x10 grid:
	var gw := 10
	var gh := 10
	var cell_w := img.get_width() / gw
	var cell_h := img.get_height() / gh
	print("--- 10x10 grid of brightness & dominant color ---")
	for gy in range(gh):
		var row := ""
		for gx in range(gw):
			var r_sum := 0.0
			var g_sum := 0.0
			var b_sum := 0.0
			var a_sum := 0.0
			var count := 0
			for y in range(gy * cell_h, (gy + 1) * cell_h):
				for x in range(gx * cell_w, (gx + 1) * cell_w):
					var c := img.get_pixel(x, y)
					r_sum += c.r
					g_sum += c.g
					b_sum += c.b
					a_sum += c.a
					count += 1
			var lum := (r_sum * 0.299 + g_sum * 0.587 + b_sum * 0.114) / count
			var avg_a := a_sum / count
			if avg_a < 0.2:
				row += "   .  "
			else:
				var tag := "D" # dark
				if lum > 0.6: tag = "W" # white/bright (waterfall/opening?)
				elif lum > 0.4: tag = "M" # medium
				elif lum > 0.25: tag = "L" # low
				row += "%s(%.2f)" % [tag, lum]
		print(row)
		
	quit(0)
