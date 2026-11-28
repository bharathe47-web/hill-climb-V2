extends SceneTree

func _init():
	print("--- SEGMENTING MEENAKSHI GOPURAM TOWER ---")
	var img = Image.new()
	var err = img.load("res://assets/indian_roads_replacements/meenakshi_tower_source_1.jpg")
	if err != OK:
		print("Failed to load source image")
		quit(1)
		return
		
	var w = img.get_width()
	var h = img.get_height()
	print("Source dimensions: ", w, "x", h)
	
	# Target game asset dimensions: high resolution, e.g. height 1200 or 1500 px
	var out = Image.create(w, h, false, Image.FORMAT_RGBA8)
	
	# Detect sky: in meenakshi_tower_source_1, sky is blue/cyan (c.b > c.r + 0.08 and c.b > 0.45)
	# Also near top corners
	for y in range(h):
		for x in range(w):
			var c = img.get_pixel(x, y)
			# Sky check
			var is_sky = false
			# Sky condition: blue dominant, low saturation of warm colors
			if c.b > c.r + 0.06 and c.b > c.g and c.b > 0.35:
				is_sky = true
			elif c.b > 0.65 and c.g > 0.6 and (c.r < 0.55):
				is_sky = true
			elif y < int(h * 0.15) and (x < int(w * 0.25) or x > int(w * 0.75)):
				# Sky at top sides
				if c.b > c.r:
					is_sky = true
					
			if is_sky and y < int(h * 0.92): # don't clip temple base
				out.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				# Rich vibrant color boost for 2D game illustration
				var col = Color(
					clampf(c.r * 1.08, 0.0, 1.0),
					clampf(c.g * 1.06, 0.0, 1.0),
					clampf(c.b * 1.04, 0.0, 1.0),
					1.0
				)
				out.set_pixel(x, y, col)
				
	# Crop unused transparent borders
	var used = out.get_used_rect()
	print("Used rect: ", used)
	var cropped = Image.create(used.size.x, used.size.y, false, Image.FORMAT_RGBA8)
	cropped.blit_rect(out, used, Vector2i.ZERO)
	
	# Scale to 1500px longest dimension (preferred AAA landmark specification)
	var target_h = 1500
	var target_w = int(float(used.size.x) * float(target_h) / float(used.size.y))
	cropped.resize(target_w, target_h, Image.INTERPOLATE_LANCZOS)
	
	var save_path = "res://assets/indian_roads_replacements/replacement_tamil_nadu_madurai_meenakshi_temple.png"
	cropped.save_png(save_path)
	print("Saved replacement Meenakshi temple: ", target_w, "x", target_h, " -> ", save_path)
	quit(0)
