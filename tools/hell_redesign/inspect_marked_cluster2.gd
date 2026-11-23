extends SceneTree

func _init() -> void:
	var annot_img := Image.load_from_file("res://references/hell_cleanup_cyan_latest.png")
	var clean_img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png")
	
	# In annot_img, find the cyan loop of Cluster 2:
	# Bounds: X=[242, 446], Y=[410, 521]
	# Inside that loop, what does clean_img look like?
	var pad := 10
	var rx := 230
	var ry := 400
	var rw := 230
	var rh := 130
	
	var a_crop := annot_img.get_region(Rect2i(rx, ry, rw, rh))
	var c_crop := clean_img.get_region(Rect2i(rx, ry, rw, rh))
	
	a_crop.save_png("res://references/marked_cluster2.png")
	c_crop.save_png("res://references/clean_cluster2.png")
	print("Saved marked_cluster2.png and clean_cluster2.png")
	
	# Let's inspect what is in clean_cluster2:
	# Print a 40x25 ASCII of clean_cluster2:
	var tw := 46
	var th := 26
	var sm := c_crop.duplicate()
	sm.resize(tw, th)
	print("\n--- CLEAN CLUSTER 2 (Object A / Monster Truck) ---")
	for y in range(th):
		var line := ""
		for x in range(tw):
			var c: Color = sm.get_pixel(x, y)
			# Sky / Background:
			if c.r > 0.45 and c.g < 0.25 and c.b < 0.25:
				line += " " # red sky
			elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
				line += "." # dark tire / black
			elif c.r > 0.7 and c.g > 0.7 and c.b > 0.7:
				line += "W" # white/silver
			elif c.r > 0.7 and c.g > 0.4:
				line += "O" # orange
			elif c.r > 0.3 and c.g > 0.15 and c.b < 0.25:
				line += "B" # brown / rock / structure
			else:
				line += "+"
		print(line)
		
	quit(0)
