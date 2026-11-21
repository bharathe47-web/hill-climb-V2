extends SceneTree

func _init() -> void:
	var list: Array[String] = [
		"references/hell_cleanup_cyan_latest.png",
		"references/hell_cleanup_cyan_prev.png",
		"references/hell_cleanup_569m.png",
		"references/hell_cleanup_600m.png"
	]
	for path in list:
		var img := Image.load_from_file(path)
		if not img:
			print("Could not load ", path)
			continue
		print("\n=== ", path, " (", img.get_size(), ") ===")
		# Check average sky color (y=50..150, x=500..800)
		var r_sum := 0.0
		var g_sum := 0.0
		var b_sum := 0.0
		for y in range(50, 150):
			for x in range(500, 800):
				var c := img.get_pixel(x, y)
				r_sum += c.r
				g_sum += c.g
				b_sum += c.b
		var n := 100 * 300
		print("Average upper color: R=%.2f G=%.2f B=%.2f" % [r_sum/n, g_sum/n, b_sum/n])
	quit(0)
