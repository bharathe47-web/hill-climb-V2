extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_cyan_latest.png")
	
	# TopStatsPanel is at offset_left=20, offset_top=18, offset_right=350, offset_bottom=228
	# DistanceLabel is roughly at x=35..200, y=40..90
	print("--- TopStatsPanel text scan (x=30..300, y=30..110) ---")
	for y in range(30, 110, 2):
		var line := ""
		for x in range(30, 300, 2):
			var c := img.get_pixel(x, y)
			if c.r > 0.8 and c.g > 0.8 and c.b > 0.8:
				line += "#"
			else:
				line += " "
		if line.strip_edges() != "":
			print("%2d: %s" % [y, line])
			
	quit(0)
