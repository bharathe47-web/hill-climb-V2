extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_cyan_latest.png")
	
	print("--- DISTANCE SCAN (x=15..85, y=115..145) ---")
	for y in range(115, 145):
		var line := ""
		for x in range(15, 85):
			var c := img.get_pixel(x, y)
			line += "#" if (c.r > 0.8 and c.g > 0.8 and c.b > 0.8) else " "
		if line.strip_edges() != "":
			print(line)
			
	quit(0)
