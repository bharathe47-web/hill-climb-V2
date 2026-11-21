extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	if not img:
		quit(1)
		return
		
	var w := img.get_width()
	var h := img.get_height()
	
	# Create binary mask of pink
	var mask := Image.create(w, h, false, Image.FORMAT_L8)
	var pink_count := 0
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.r > 0.75 and c.g > 0.4 and c.g < 0.75 and c.b > 0.4 and c.b < 0.75 and abs(c.g - c.b) < 0.12:
				mask.set_pixel(x, y, Color(1, 1, 1, 1))
				pink_count += 1
			else:
				mask.set_pixel(x, y, Color(0, 0, 0, 1))
				
	print("Total pink pixels: ", pink_count)
	
	# Find connected components with simple BFS
	var visited := Image.create(w, h, false, Image.FORMAT_L8)
	var components: Array = []
	
	for y in range(h):
		for x in range(w):
			if mask.get_pixel(x, y).r > 0.5 and visited.get_pixel(x, y).r < 0.5:
				# Start BFS
				var q: Array[Vector2i] = [Vector2i(x, y)]
				visited.set_pixel(x, y, Color(1, 1, 1, 1))
				var comp_pixels: Array[Vector2i] = []
				
				var min_x := x
				var max_x := x
				var min_y := y
				var max_y := y
				
				var head := 0
				while head < q.size():
					var cur: Vector2i = q[head]
					head += 1
					comp_pixels.append(cur)
					min_x = min(min_x, cur.x)
					max_x = max(max_x, cur.x)
					min_y = min(min_y, cur.y)
					max_y = max(max_y, cur.y)
					
					# 8-connectivity with distance up to 4 pixels (to bridge pen gaps)
					for dy in range(-4, 5):
						for dx in range(-4, 5):
							var nx := cur.x + dx
							var ny := cur.y + dy
							if nx >= 0 and nx < w and ny >= 0 and ny < h:
								if mask.get_pixel(nx, ny).r > 0.5 and visited.get_pixel(nx, ny).r < 0.5:
									visited.set_pixel(nx, ny, Color(1, 1, 1, 1))
									q.append(Vector2i(nx, ny))
									
				if comp_pixels.size() >= 30: # Ignore tiny noise
					components.append({
						"pixels": comp_pixels.size(),
						"min_x": min_x,
						"max_x": max_x,
						"min_y": min_y,
						"max_y": max_y
					})
					
	print("Found %d distinct pink components:" % components.size())
	var idx := 0
	for c in components:
		idx += 1
		print("Component #%d: pixels=%d X=[%d, %d] (w=%d) Y=[%d, %d] (h=%d)" % [
			idx, c.pixels, c.min_x, c.max_x, c.max_x - c.min_x, c.min_y, c.max_y, c.max_y - c.min_y
		])
		var pad := 10
		var cx := clampi(c.min_x - pad, 0, w - 1)
		var cy := clampi(c.min_y - pad, 0, h - 1)
		var cw := clampi(c.max_x - c.min_x + 2*pad, 1, w - cx)
		var ch := clampi(c.max_y - c.min_y + 2*pad, 1, h - cy)
		var crop := img.get_region(Rect2i(cx, cy, cw, ch))
		crop.save_png("res://references/pink_box_%d.png" % idx)
		
	quit(0)
