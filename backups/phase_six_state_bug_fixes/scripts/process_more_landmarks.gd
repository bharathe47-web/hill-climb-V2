extends SceneTree

func _init():
	print("--- PROCESSING CHENNAI LIGHTHOUSE AND VIVEKANANDA ROCK ---")
	
	# 1. Chennai Lighthouse (1200x1600 source)
	var lh = Image.new()
	var err = lh.load("res://assets/indian_roads_replacements/chennai_lighthouse_source.jpg")
	if err == OK:
		var w = lh.get_width()
		var h = lh.get_height()
		var out = Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y in range(h):
			for x in range(w):
				var c = lh.get_pixel(x, y)
				# Sky is cyan/blue (c.b > 0.55 and c.b > c.r + 0.1)
				var is_sky = (c.b > 0.55 and c.b > c.r + 0.08 and c.b >= c.g) or (c.r > 0.85 and c.g > 0.85 and c.b > 0.85 and y < int(h * 0.8))
				if is_sky and y < int(h * 0.95):
					out.set_pixel(x, y, Color(0,0,0,0))
				else:
					out.set_pixel(x, y, Color(c.r, c.g, c.b, 1.0))
		var rect = out.get_used_rect()
		var crop = Image.create(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
		crop.blit_rect(out, rect, Vector2i.ZERO)
		var th = 1500
		var tw = int(float(rect.size.x) * float(th) / float(rect.size.y))
		crop.resize(tw, th, Image.INTERPOLATE_LANCZOS)
		crop.save_png("res://assets/indian_roads_replacements/replacement_tamil_nadu_chennai_marina_lighthouse.png")
		print("Saved Chennai Lighthouse replacement: ", tw, "x", th)
	else:
		print("Failed to load lighthouse source")
		
	# 2. Vivekananda Rock Memorial (3935x2557 source)
	var vr = Image.new()
	err = vr.load("res://assets/indian_roads_replacements/vivekananda_rock_source.jpg")
	if err == OK:
		var w = vr.get_width()
		var h = vr.get_height()
		var out = Image.create(w, h, false, Image.FORMAT_RGBA8)
		for y in range(h):
			for x in range(w):
				var c = vr.get_pixel(x, y)
				# Sky is bright blue/white overcast in upper half
				var is_sky = (c.b > 0.6 and c.b > c.r + 0.08) or (c.r > 0.8 and c.g > 0.8 and c.b > 0.8)
				if is_sky and y < int(h * 0.65):
					out.set_pixel(x, y, Color(0,0,0,0))
				else:
					out.set_pixel(x, y, Color(c.r, c.g, c.b, 1.0))
		var rect = out.get_used_rect()
		var crop = Image.create(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
		crop.blit_rect(out, rect, Vector2i.ZERO)
		var tw = 1600
		var th = int(float(rect.size.y) * float(tw) / float(rect.size.x))
		crop.resize(tw, th, Image.INTERPOLATE_LANCZOS)
		crop.save_png("res://assets/indian_roads_replacements/replacement_tamil_nadu_vivekananda_rock_memorial.png")
		print("Saved Vivekananda Rock replacement: ", tw, "x", th)
	else:
		print("Failed to load vivekananda rock source")
		
	quit(0)
