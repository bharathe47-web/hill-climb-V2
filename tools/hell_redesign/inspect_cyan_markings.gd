extends SceneTree

func _init() -> void:
	print("--- INSPECTING CYAN ANNOTATED SCREENSHOTS ---")
	var files: Array[String] = ["hell_cleanup_cyan_latest.png", "hell_cleanup_cyan_prev.png"]
	for fname in files:
		var path: String = "res://references/" + fname
		var img := Image.load_from_file(path)
		if not img:
			printerr("Failed to load ", path)
			continue
		print("\nAnalyzing %s (%dx%d)..." % [fname, img.get_width(), img.get_height()])
		_find_cyan_regions(img, fname.get_basename())
	quit(0)

func _find_cyan_regions(img: Image, base_name: String) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var mask := Image.create(w, h, false, Image.FORMAT_L8)
	var count := 0
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# Cyan/blue pen: High G and B, lower R. E.g. G > 0.6, B > 0.6, R < 0.45, or B > 0.7 and R < 0.5.
			if c.b > 0.55 and c.g > 0.45 and c.r < 0.40 and (c.b + c.g) > 1.2:
				mask.set_pixel(x, y, Color(1, 1, 1, 1))
				count += 1
			else:
				mask.set_pixel(x, y, Color(0, 0, 0, 1))
	print("Found %d cyan annotation pixels" % count)
	
	if count < 50:
		# Maybe different color? Let's sample blue/cyan pixels
		print("Checking alternative blue/cyan thresholds...")
		for y in range(0, h, 10):
			for x in range(0, w, 10):
				var c := img.get_pixel(x, y)
				if c.b > 0.5 and c.r < 0.5:
					print("Sample (x=%d, y=%d): R=%.2f G=%.2f B=%.2f" % [x, y, c.r, c.g, c.b])
		return
		
	# Connected components (BFS with 6px jump distance)
	var visited := Image.create(w, h, false, Image.FORMAT_L8)
	var components: Array = []
	for y in range(h):
		for x in range(w):
			if mask.get_pixel(x, y).r > 0.5 and visited.get_pixel(x, y).r < 0.5:
				var q: Array[Vector2i] = [Vector2i(x, y)]
				visited.set_pixel(x, y, Color(1, 1, 1, 1))
				var min_x := x
				var max_x := x
				var min_y := y
				var max_y := y
				var size := 0
				var head := 0
				while head < q.size():
					var cur: Vector2i = q[head]
					head += 1
					size += 1
					min_x = min(min_x, cur.x)
					max_x = max(max_x, cur.x)
					min_y = min(min_y, cur.y)
					max_y = max(max_y, cur.y)
					for dy in range(-7, 8):
						for dx in range(-7, 8):
							var nx := cur.x + dx
							var ny := cur.y + dy
							if nx >= 0 and nx < w and ny >= 0 and ny < h:
								if mask.get_pixel(nx, ny).r > 0.5 and visited.get_pixel(nx, ny).r < 0.5:
									visited.set_pixel(nx, ny, Color(1, 1, 1, 1))
									q.append(Vector2i(nx, ny))
				if size >= 40:
					components.append({
						"size": size,
						"min_x": min_x,
						"max_x": max_x,
						"min_y": min_y,
						"max_y": max_y
					})
					
	print("Found %d cyan components in %s:" % [components.size(), base_name])
	var i := 0
	for c in components:
		i += 1
		print("[%d] size=%d, X=[%d, %d] (w=%d), Y=[%d, %d] (h=%d), center=(%d, %d)" % [
			i, c.size, c.min_x, c.max_x, c.max_x - c.min_x, c.min_y, c.max_y, c.max_y - c.min_y,
			(c.min_x + c.max_x) / 2, (c.min_y + c.max_y) / 2
		])
		var pad := 25
		var cx := clampi(c.min_x - pad, 0, w - 1)
		var cy := clampi(c.min_y - pad, 0, h - 1)
		var cw := clampi(c.max_x - c.min_x + 2*pad, 1, w - cx)
		var ch := clampi(c.max_y - c.min_y + 2*pad, 1, h - cy)
		var crop := img.get_region(Rect2i(cx, cy, cw, ch))
		crop.save_png("res://references/%s_cyan_obj_%d.png" % [base_name, i])
		print("  -> Saved references/%s_cyan_obj_%d.png (%dx%d)" % [base_name, i, cw, ch])
