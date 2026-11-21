extends SceneTree

func _init() -> void:
	for fname: String in ["hell_cleanup_600m.png", "hell_cleanup_569m.png"]:
		var path := "res://references/" + fname
		var img := Image.load_from_file(path)
		if not img: continue
		var w := img.get_width()
		var h := img.get_height()
		var count := 0
		for y in range(h):
			for x in range(w):
				var c := img.get_pixel(x, y)
				if c.b > 0.55 and c.g > 0.45 and c.r < 0.40 and (c.b + c.g) > 1.2:
					count += 1
		print(fname, " cyan count: ", count)
	quit(0)
