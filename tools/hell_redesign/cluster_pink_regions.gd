@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_pink.png"
	var img := Image.load_from_file(path)
	if not img:
		printerr("Cannot load ", path)
		quit(1)
		return

	var w := img.get_width()
	var h := img.get_height()
	print("Loaded %s: %dx%d" % [path.get_file(), w, h])

	# Pink/magenta: high red, high blue, lower green (e.g. r > 0.7, b > 0.6, g < 0.5)
	# Also let's check for any pink pixels:
	var pink_pixels: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# Pink / magenta line
			if c.r > 0.65 and c.b > 0.55 and c.g < 0.4 and (c.r + c.b) > (c.g * 2.5):
				pink_pixels.append(Vector2i(x, y))

	print("Found %d pink annotation pixels" % pink_pixels.size())

	# Downsample grid 16x16 to cluster
	var gw := w / 16
	var gh := h / 16
	var grid := []
	for gy in range(gh):
		var row := []
		for gx in range(gw):
			var has_pink := false
			for dy in range(16):
				for dx in range(16):
					var c := img.get_pixel(gx * 16 + dx, gy * 16 + dy)
					if c.r > 0.65 and c.b > 0.55 and c.g < 0.4 and (c.r + c.b) > (c.g * 2.5):
						has_pink = true
						break
				if has_pink:
					break
			row.append(has_pink)
		grid.append(row)

	var visited := []
	for gy in range(gh):
		var vrow := []
		for gx in range(gw):
			vrow.append(false)
		visited.append(vrow)

	var clusters := []
	for gy in range(gh):
		for gx in range(gw):
			if grid[gy][gx] and not visited[gy][gx]:
				var comp := []
				var queue := [Vector2i(gx, gy)]
				visited[gy][gx] = true
				while queue.size() > 0:
					var p: Vector2i = queue.pop_back()
					comp.append(p)
					for dy: int in [-1, 0, 1]:
						for dx: int in [-1, 0, 1]:
							var nx: int = p.x + dx
							var ny: int = p.y + dy
							if nx >= 0 and nx < gw and ny >= 0 and ny < gh:
								if grid[ny][nx] and not visited[ny][nx]:
									visited[ny][nx] = true
									queue.append(Vector2i(nx, ny))
				if comp.size() >= 2:
					var min_gx = gw; var max_gx = 0; var min_gy = gh; var max_gy = 0
					for cp in comp:
						min_gx = mini(min_gx, cp.x)
						max_gx = maxi(max_gx, cp.x)
						min_gy = mini(min_gy, cp.y)
						max_gy = maxi(max_gy, cp.y)
					clusters.append(Rect2i(min_gx * 16, min_gy * 16, (max_gx - min_gx + 1) * 16, (max_gy - min_gy + 1) * 16))

	print("\nFound %d distinct pink-marked regions:" % clusters.size())
	for i in range(clusters.size()):
		var r: Rect2i = clusters[i]
		var cx := r.position.x + r.size.x / 2
		var cy := r.position.y + r.size.y / 2
		print("  Region [%d]: rect=%s center=(%d, %d)" % [i + 1, str(r), cx, cy])

		# Crop with margin
		var crop_r := Rect2i(r.position.x - 20, r.position.y - 20, r.size.x + 40, r.size.y + 40)
		crop_r.position.x = clampi(crop_r.position.x, 0, w - 1)
		crop_r.position.y = clampi(crop_r.position.y, 0, h - 1)
		crop_r.size.x = clampi(crop_r.size.x, 1, w - crop_r.position.x)
		crop_r.size.y = clampi(crop_r.size.y, 1, h - crop_r.position.y)

		var crop := Image.create(crop_r.size.x, crop_r.size.y, false, Image.FORMAT_RGBA8)
		crop.blit_rect(img, crop_r, Vector2i.ZERO)
		var out_p := "res://docs/hell_redesign/pink_region_%d.png" % [i + 1]
		crop.save_png(ProjectSettings.globalize_path(out_p))
		print("    Saved crop: %s (%dx%d)" % [out_p, crop.get_width(), crop.get_height()])

	quit(0)
