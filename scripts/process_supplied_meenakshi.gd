extends SceneTree

func _init() -> void:
	var src_path = "/home/joel/Downloads/Pasted image.png"
	var dest_path = "res://assets/indian_locations/tamil_nadu/landmarks/madurai_meenakshi_amman_temple_supplied.png"
	var real_dest = "assets/indian_locations/tamil_nadu/landmarks/madurai_meenakshi_amman_temple_supplied.png"
	
	var img = Image.load_from_file(src_path)
	if img == null:
		print("ERROR: Failed to load source image: ", src_path)
		quit()
		return
	
	var w = img.get_width()
	var h = img.get_height()
	print("Loaded image: ", w, "x", h, " format: ", img.get_format())
	
	# Find exact bounds of non-transparent pixels (alpha > 0.02)
	var min_x = w
	var min_y = h
	var max_x = 0
	var max_y = 0
	
	for y in range(h):
		for x in range(w):
			var a = img.get_pixel(x, y).a
			if a > 0.02:
				if x < min_x: min_x = x
				if y < min_y: min_y = y
				if x > max_x: max_x = x
				if y > max_y: max_y = y
				
	print("Exact content bounds: min=(%d, %d), max=(%d, %d)" % [min_x, min_y, max_x, max_y])
	var content_w = max_x - min_x + 1
	var content_h = max_y - min_y + 1
	print("Content dimensions: %dx%d" % [content_w, content_h])
	
	# Add a small padding of 8px left/right/top, but align bottom flush
	var pad = 8
	var crop_x = max(0, min_x - pad)
	var crop_y = max(0, min_y - pad)
	var crop_w = min(w - crop_x, content_w + pad * 2)
	var crop_h = min(h - crop_y, (max_y - crop_y) + 1)
	
	var cropped = img.get_region(Rect2i(crop_x, crop_y, crop_w, crop_h))
	var err = cropped.save_png(real_dest)
	if err == OK:
		print("Successfully saved processed Meenakshi temple to: ", real_dest)
		print("Final dimensions: ", cropped.get_size())
	else:
		print("Failed to save cropped image: ", err)
	quit()
