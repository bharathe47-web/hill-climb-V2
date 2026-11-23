extends SceneTree

func _init() -> void:
	var path := "/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-47.png"
	var img := Image.load_from_file(path)
	if not img:
		print("Cannot load ", path)
		quit(1)
		return
		
	var w := img.get_width()
	var h := img.get_height()
	print("Image loaded: %dx%d" % [w, h])
	
	# Let's crop several key areas:
	# 1. Left side of the roadway: x=100..450, y=350..650
	var c_left := img.get_region(Rect2i(100, 350, 350, 300))
	c_left.save_png("res://references/cyan_crop_left.png")
	
	# 2. Center area (truck & immediate right): x=350..850, y=300..650
	var c_mid := img.get_region(Rect2i(350, 300, 500, 350))
	c_mid.save_png("res://references/cyan_crop_mid.png")
	
	# 3. Lower center (underneath): x=450..850, y=450..720
	var c_low := img.get_region(Rect2i(450, 450, 400, 270))
	c_low.save_png("res://references/cyan_crop_low.png")
	
	# 4. Middle-right: x=800..1250, y=350..650
	var c_right := img.get_region(Rect2i(800, 350, 450, 300))
	c_right.save_png("res://references/cyan_crop_right.png")
	
	print("Saved crops: cyan_crop_left, cyan_crop_mid, cyan_crop_low, cyan_crop_right.")
	quit(0)
