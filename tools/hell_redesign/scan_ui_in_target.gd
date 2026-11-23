@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_target.png")
	var w := img.get_width()
	var h := img.get_height()
	print("Scanning for non-environment elements (UI, vehicle, text) in hell_target.png...")

	# Scan for white or bright neon colors typical of UI text or vehicle
	var non_env_pixels := []
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# UI text or meters often have pure white (r>0.95, g>0.95, b>0.95)
			# or bright cyan/green/yellow (e.g. green nitro or yellow coin)
			if c.r > 0.95 and c.g > 0.95 and c.b > 0.95:
				non_env_pixels.append(Vector2i(x, y))

	print("Found %d pure white pixels" % non_env_pixels.size())
	if non_env_pixels.size() > 0:
		var min_x = w; var max_x = 0; var min_y = h; var max_y = 0
		for p in non_env_pixels:
			min_x = mini(min_x, p.x)
			max_x = maxi(max_x, p.x)
			min_y = mini(min_y, p.y)
			max_y = maxi(max_y, p.y)
		print("Pure white pixel bounds: x=[%d..%d], y=[%d..%d]" % [min_x, max_x, min_y, max_y])

	quit(0)
