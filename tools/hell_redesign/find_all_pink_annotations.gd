extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	if not img:
		quit(1)
		return
	var w := img.get_width()
	var h := img.get_height()
	
	# Mark pink annotation pixels
	var mask := Image.create(w, h, false, Image.FORMAT_L8)
	var count := 0
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.r > 0.65 and c.g > 0.35 and c.b > 0.30 and abs(c.g - c.b) < 0.15:
				mask.set_pixel(x, y, Color(1, 1, 1, 1))
				count += 1
			else:
				mask.set_pixel(x, y, Color(0, 0, 0, 1))
				
	print("Found %d annotation pixels" % count)
	
	# Connected components with BFS (allowing 5px jumps)
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
					for dy in range(-6, 7):
						for dx in range(-6, 7):
							var nx := cur.x + dx
							var ny := cur.y + dy
							if nx >= 0 and nx < w and ny >= 0 and ny < h:
								if mask.get_pixel(nx, ny).r > 0.5 and visited.get_pixel(nx, ny).r < 0.5:
									visited.set_pixel(nx, ny, Color(1, 1, 1, 1))
									q.append(Vector2i(nx, ny))
				if size >= 50:
					components.append({
						"size": size,
						"min_x": min_x,
						"max_x": max_x,
						"min_y": min_y,
						"max_y": max_y
					})
					
	print("Found %d annotation components:" % components.size())
	var i := 0
	for c in components:
		i += 1
		print("[%d] size=%d, X=[%d, %d] (w=%d), Y=[%d, %d] (h=%d), center=(%d, %d)" % [
			i, c.size, c.min_x, c.max_x, c.max_x - c.min_x, c.min_y, c.max_y, c.max_y - c.min_y,
			(c.min_x + c.max_x) / 2, (c.min_y + c.max_y) / 2
		])
		# Save crop of what is enclosed / around this annotation
		var pad := 30
		var cx := clampi(c.min_x - pad, 0, w - 1)
		var cy := clampi(c.min_y - pad, 0, h - 1)
		var cw := clampi(c.max_x - c.min_x + 2*pad, 1, w - cx)
		var ch := clampi(c.max_y - c.min_y + 2*pad, 1, h - cy)
		var crop := img.get_region(Rect2i(cx, cy, cw, ch))
		crop.save_png("res://references/annotation_obj_%d.png" % i)
		print("  -> Saved references/annotation_obj_%d.png (%dx%d)" % [i, cw, ch])
	quit(0)
