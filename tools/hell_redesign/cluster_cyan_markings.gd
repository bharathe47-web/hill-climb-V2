extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_cyan_latest.png")
	var w := img.get_width()
	var h := img.get_height()
	
	# Create binary mask of annotation pixels
	var mask := Image.create(w, h, false, Image.FORMAT_L8)
	var count := 0
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# Blue/cyan annotation pen:
			if c.b > 0.45 and (c.b - c.r) > 0.15 and (c.g > 0.35 or c.b > 0.6):
				mask.set_pixel(x, y, Color(1, 1, 1, 1))
				count += 1
			else:
				mask.set_pixel(x, y, Color(0, 0, 0, 1))
	print("Total annotation mask pixels: ", count)
	
	# Cluster with 10px jump distance
	var visited := Image.create(w, h, false, Image.FORMAT_L8)
	var clusters: Array = []
	
	for y in range(h):
		for x in range(w):
			if mask.get_pixel(x, y).r > 0.5 and visited.get_pixel(x, y).r < 0.5:
				var q: Array[Vector2i] = [Vector2i(x, y)]
				visited.set_pixel(x, y, Color(1, 1, 1, 1))
				var min_x := x
				var max_x := x
				var min_y := y
				var max_y := y
				var sz := 0
				var head := 0
				while head < q.size():
					var cur: Vector2i = q[head]
					head += 1
					sz += 1
					min_x = min(min_x, cur.x)
					max_x = max(max_x, cur.x)
					min_y = min(min_y, cur.y)
					max_y = max(max_y, cur.y)
					for dy in range(-12, 13):
						for dx in range(-12, 13):
							var nx := cur.x + dx
							var ny := cur.y + dy
							if nx >= 0 and nx < w and ny >= 0 and ny < h:
								if mask.get_pixel(nx, ny).r > 0.5 and visited.get_pixel(nx, ny).r < 0.5:
									visited.set_pixel(nx, ny, Color(1, 1, 1, 1))
									q.append(Vector2i(nx, ny))
				if sz >= 50:
					clusters.append({
						"size": sz,
						"min_x": min_x,
						"max_x": max_x,
						"min_y": min_y,
						"max_y": max_y
					})
					
	print("Found %d distinct stroke clusters:" % clusters.size())
	# Sort by size descending
	clusters.sort_custom(func(a, b): return a.size > b.size)
	
	for i in range(clusters.size()):
		var c = clusters[i]
		var bw := int(c.max_x - c.min_x)
		var bh := int(c.max_y - c.min_y)
		var cx := int((c.min_x + c.max_x) / 2)
		var cy := int((c.min_y + c.max_y) / 2)
		print("[%d] pixels=%d, bounds: X=[%d, %d] (w=%d), Y=[%d, %d] (h=%d), center=(%d, %d)" % [
			i + 1, c.size, c.min_x, c.max_x, bw, c.min_y, c.max_y, bh, cx, cy
		])
		
		# Save crop of this marked region (including a margin around it)
		var pad := 30
		var rx := clampi(c.min_x - pad, 0, w - 1)
		var ry := clampi(c.min_y - pad, 0, h - 1)
		var rw := clampi(bw + 2 * pad, 1, w - rx)
		var rh := clampi(bh + 2 * pad, 1, h - ry)
		var crop := img.get_region(Rect2i(rx, ry, rw, rh))
		crop.save_png("res://references/cyan_cluster_%d.png" % (i + 1))
		print("  -> Saved references/cyan_cluster_%d.png (%dx%d)" % [i + 1, rw, rh])
		
	quit(0)
