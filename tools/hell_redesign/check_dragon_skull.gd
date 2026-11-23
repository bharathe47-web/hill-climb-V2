extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/environments/hell/decorations/giant_dragon_skull_decal.png")
	if img:
		print("giant_dragon_skull_decal.png: size=", img.get_size(), " format=", img.get_format())
		# Check alpha
		var non_transparent := 0
		var opaque_corners := 0
		if img.get_pixel(0, 0).a > 0.5: opaque_corners += 1
		if img.get_pixel(img.get_width()-1, 0).a > 0.5: opaque_corners += 1
		if img.get_pixel(0, img.get_height()-1).a > 0.5: opaque_corners += 1
		if img.get_pixel(img.get_width()-1, img.get_height()-1).a > 0.5: opaque_corners += 1
		print("Corners opaque: ", opaque_corners)
	else:
		print("Failed to load giant_dragon_skull_decal.png")
	quit(0)
