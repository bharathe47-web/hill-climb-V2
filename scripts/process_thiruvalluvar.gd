extends SceneTree

func _init():
	print("--- SEGMENTING THIRUVALLUVAR STATUE FRONT VIEW ---")
	var img = Image.new()
	var err = img.load("res://assets/indian_roads_replacements/thiruvalluvar_front.jpg")
	if err != OK:
		print("Failed to load thiruvalluvar_front.jpg")
		quit(1)
		return
		
	var w = img.get_width()
	var h = img.get_height()
	print("Source dimensions: ", w, "x", h)
	
	var out = Image.create(w, h, false, Image.FORMAT_RGBA8)
	
	for y in range(h):
		for x in range(w):
			var c = img.get_pixel(x, y)
			# Sky condition in thiruvalluvar_front:
			# Sky has strong cyan/blue: c.b > 0.65 and c.g > 0.6 and (c.b > c.r + 0.12)
			var is_sky = false
			if c.b > 0.6 and c.g > 0.55 and (c.b > c.r + 0.1):
				is_sky = true
			elif (c.r > 0.85 and c.g > 0.85 and c.b > 0.85) and (abs(c.r - c.g) < 0.05 and abs(c.g - c.b) < 0.05):
				# bright white clouds in sky
				if y < int(h * 0.82):
					is_sky = true
					
			if is_sky and y < int(h * 0.96): # preserve pedestal base
				out.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				# Granite stone enhancement for stylized 2D game illustration
				var col = Color(
					clampf(c.r * 1.05, 0.0, 1.0),
					clampf(c.g * 1.05, 0.0, 1.0),
					clampf(c.b * 1.05, 0.0, 1.0),
					1.0
				)
				out.set_pixel(x, y, col)
				
	# Crop unused transparent borders
	var used = out.get_used_rect()
	print("Used rect: ", used)
	var cropped = Image.create(used.size.x, used.size.y, false, Image.FORMAT_RGBA8)
	cropped.blit_rect(out, used, Vector2i.ZERO)
	
	# Scale to 1500px longest dimension (target AAA landmark resolution)
	var target_h = 1500
	var target_w = int(float(used.size.x) * float(target_h) / float(used.size.y))
	cropped.resize(target_w, target_h, Image.INTERPOLATE_LANCZOS)
	
	var save_path = "res://assets/indian_roads_replacements/replacement_tamil_nadu_thiruvalluvar_statue.png"
	cropped.save_png(save_path)
	print("Saved replacement Thiruvalluvar statue: ", target_w, "x", target_h, " -> ", save_path)
	quit(0)
