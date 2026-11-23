extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png")
	var img_annot := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-47.png")
	
	# In 13-37-47, find the large cyan marking enclosing Object A:
	# Earlier we found Cluster 2:
	# bounds: X=[242, 446] (w=204), Y=[410, 521] (h=111), center=(344, 465)
	# Let's inspect all pixels inside the bounding box of Cluster 2 in the UNANNOTATED image (13-37-08)!
	var min_x := 240
	var max_x := 450
	var min_y := 400
	var max_y := 530
	
	print("--- OBJECT A PIXEL ANALYSIS (x=%d..%d, y=%d..%d) ---" % [min_x, max_x, min_y, max_y])
	
	# Find what textures are present
	# Save a crisp PNG of just Object A without the truck (x=330..450, y=410..520)
	var obj_a_crop := img.get_region(Rect2i(320, 410, 130, 110))
	obj_a_crop.save_png("res://references/object_a_crisp.png")
	print("Saved res://references/object_a_crisp.png")
	
	# Check color distribution in obj_a_crop
	var colors := {}
	for y in range(obj_a_crop.get_height()):
		for x in range(obj_a_crop.get_width()):
			var c: Color = obj_a_crop.get_pixel(x, y)
			# Quantize color to 0.1
			var key := "R=%.1f G=%.1f B=%.1f" % [round(c.r * 10) / 10.0, round(c.g * 10) / 10.0, round(c.b * 10) / 10.0]
			colors[key] = colors.get(key, 0) + 1
			
	var sorted_keys = colors.keys()
	sorted_keys.sort_custom(func(a, b): return colors[a] > colors[b])
	print("Top colors in Object A crop:")
	for k in sorted_keys.slice(0, 10):
		print("  %s: %d pixels" % [k, colors[k]])
		
	quit(0)
