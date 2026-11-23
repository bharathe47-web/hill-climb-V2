@tool
extends SceneTree

func _init() -> void:
	var fg_skulls := Image.load_from_file("res://assets/environments/hell/foreground/decorations/hell_foreground_skulls_rocks.png")
	fg_skulls.convert(Image.FORMAT_RGBA8)
	
	var c2 := Image.load_from_file("res://references/cluster2_in_1443.png")
	c2.convert(Image.FORMAT_RGBA8)

	print("fg_skulls: %dx%d, cluster2: %dx%d" % [
		fg_skulls.get_width(), fg_skulls.get_height(),
		c2.get_width(), c2.get_height()
	])

	# Scale fg_skulls by 0.25
	var scaled_25: Image = fg_skulls.duplicate()
	scaled_25.resize(int(fg_skulls.get_width() * 0.25), int(fg_skulls.get_height() * 0.25), Image.INTERPOLATE_BILINEAR)
	print("Scaled 0.25 size: %dx%d" % [scaled_25.get_width(), scaled_25.get_height()])

	# Check match between scaled_25 and c2
	var patch: Image = scaled_25.get_region(Rect2i(100, 2, 30, 15))
	var min_diff: float = 999999.0
	var best_pos := Vector2i(-1, -1)
	for y in range(c2.get_height() - 15):
		for x in range(c2.get_width() - 30):
			var diff: float = 0.0
			for py in range(15):
				for px in range(30):
					var p1: Color = patch.get_pixel(px, py)
					var p2: Color = c2.get_pixel(x + px, y + py)
					if p1.a > 0.5:
						diff += abs(p1.r - p2.r) + abs(p1.g - p2.g) + abs(p1.b - p2.b)
			if diff < min_diff:
				min_diff = diff
				best_pos = Vector2i(x, y)

	print("Best match of scaled 0.25 in cluster2: diff=%.2f at %s" % [min_diff, best_pos])

	quit(0)
