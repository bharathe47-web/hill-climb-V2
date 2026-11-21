extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_cyan_latest.png")
	
	print("--- Colors in TopStatsPanel (x=40..200, y=30..90) ---")
	for y in range(30, 90, 5):
		for x in range(40, 200, 10):
			var c := img.get_pixel(x, y)
			if c.r > 0.4 or c.g > 0.4 or c.b > 0.4:
				print("x=%d, y=%d: R=%.2f G=%.2f B=%.2f A=%.2f" % [x, y, c.r, c.g, c.b, c.a])
	quit(0)
