extends SceneTree

func _init():
	print("--- INSPECTING MEENAKSHI TOWER SOURCE 2 ---")
	var img = Image.new()
	var err = img.load("res://assets/indian_roads_replacements/meenakshi_tower_source_2.jpg")
	if err == OK:
		var w = img.get_width()
		var h = img.get_height()
		print("Dims: ", w, "x", h)
		print("Top left (sky): ", img.get_pixel(50, 50))
		print("Top right (sky): ", img.get_pixel(w - 50, 50))
		print("Mid left: ", img.get_pixel(50, h / 2))
		print("Center (gopuram): ", img.get_pixel(w / 2, h / 2))
		print("Lower center (base): ", img.get_pixel(w / 2, int(h * 0.85)))
	quit(0)
