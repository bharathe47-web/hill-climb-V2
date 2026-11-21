extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	print("Sample pixels at (840..860, 320..330):")
	for y in range(320, 335):
		for x in range(840, 870):
			var c := img.get_pixel(x, y)
			# print if it looks like an annotation (bright, saturated, pink/red)
			if c.r > 0.7:
				print("x=%d, y=%d: R=%.3f G=%.3f B=%.3f" % [x, y, c.r, c.g, c.b])
	quit(0)
