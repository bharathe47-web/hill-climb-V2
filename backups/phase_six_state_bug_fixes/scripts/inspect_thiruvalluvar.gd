extends SceneTree

func _init():
	print("--- INSPECTING THIRUVALLUVAR CANDIDATES ---")
	for name in ["thiruvalluvar_front", "thiruvalluvar_kavi"]:
		var img = Image.new()
		img.load("res://assets/indian_roads_replacements/" + name + ".jpg")
		var w = img.get_width()
		var h = img.get_height()
		print(name, " Dims: ", w, "x", h)
		print("  Top left (sky): ", img.get_pixel(30, 30))
		print("  Center (statue): ", img.get_pixel(w / 2, h / 2))
		print("  Lower center (pedestal): ", img.get_pixel(w / 2, int(h * 0.85)))
	quit(0)
