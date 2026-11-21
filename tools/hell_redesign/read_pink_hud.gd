extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	if not img:
		quit(1)
		return
	# Crop top-left HUD (distance, coins)
	# Screen is 1366x768
	var hud_crop := img.get_region(Rect2i(0, 0, 500, 150))
	hud_crop.save_png("res://references/pink_hud.png")
	
	# Also let's find the exact differences between hell_cleanup_pink.png and hell_cleanup_600m.png
	var img600 := Image.load_from_file("res://references/hell_cleanup_600m.png")
	if img600 and img600.get_size() == img.get_size():
		print("Comparing with 600m...")
		var diff_count := 0
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var c1 := img.get_pixel(x, y)
				var c2 := img600.get_pixel(x, y)
				if abs(c1.r - c2.r) > 0.1 or abs(c1.g - c2.g) > 0.1 or abs(c1.b - c2.b) > 0.1:
					diff_count += 1
		print("Diff pixels vs 600m: ", diff_count)
	else:
		print("Sizes: pink=", img.get_size(), " 600m=", img600.get_size() if img600 else "null")
		
	quit(0)
