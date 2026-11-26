extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/joel/Downloads/Pasted image.png")
	if img:
		var min_x := img.get_width()
		var max_x := 0
		var min_y := img.get_height()
		var max_y := 0
		for y in range(0, img.get_height(), 2):
			for x in range(0, img.get_width(), 2):
				if img.get_pixel(x, y).a > 0.05:
					if x < min_x: min_x = x
					if x > max_x: max_x = x
					if y < min_y: min_y = y
					if y > max_y: max_y = y
		print("Pasted image.png visible bounds:")
		print("  X: ", min_x, " .. ", max_x, " (width: ", max_x - min_x, ")")
		print("  Y: ", min_y, " .. ", max_y, " (height: ", max_y - min_y, ")")
	quit()
