@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_white_circles.png"
	var img := Image.load_from_file(path)
	if not img:
		printerr("Cannot load ", path)
		quit(1)
		return
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Image size: %dx%d" % [w, h])

	# Check white pixels (the user's white circles)
	# White drawn lines usually have r > 0.85, g > 0.85, b > 0.85 and low saturation
	var white_pts: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# Exclude top HUD text (y < 120)
			if y < 120:
				continue
			if c.r > 0.90 and c.g > 0.90 and c.b > 0.90:
				# check saturation
				var max_c: float = maxf(c.r, maxf(c.g, c.b))
				var min_c: float = minf(c.r, minf(c.g, c.b))
				if (max_c - min_c) < 0.08:
					white_pts.append(Vector2i(x, y))

	print("Found %d white candidate pixels (below y=120)" % white_pts.size())

	# Cluster white points
	var clusters: Array[Array] = []
	for pt in white_pts:
		var placed := false
		for cl in clusters:
			var cl_first: Vector2i = cl[0]
			# If reasonably close to cluster bounds
			if abs(pt.x - cl_first.x) < 200 and abs(pt.y - cl_first.y) < 200:
				cl.append(pt)
				placed = true
				break
		if not placed:
			clusters.append([pt])

	# Merge nearby clusters
	var merged: Array[Dictionary] = []
	for cl in clusters:
		if cl.size() < 40:
			continue # noise
		var min_x := 9999
		var min_y := 9999
		var max_x := -1
		var max_y := -1
		for pt: Vector2i in cl:
			min_x = mini(min_x, pt.x)
			min_y = mini(min_y, pt.y)
			max_x = maxi(max_x, pt.x)
			max_y = maxi(max_y, pt.y)
		merged.append({"min_x": min_x, "min_y": min_y, "max_x": max_x, "max_y": max_y, "count": cl.size()})

	print("Clusters count: %d" % merged.size())
	for i in range(merged.size()):
		var m = merged[i]
		print("Cluster %d: x=[%d..%d] (w=%d), y=[%d..%d] (h=%d), pts=%d" % [
			i, m.min_x, m.max_x, m.max_x - m.min_x,
			m.min_y, m.max_y, m.max_y - m.min_y, m.count
		])
		# Save crop
		var cw := mini(w - m.min_x, (m.max_x - m.min_x) + 40)
		var ch := mini(h - m.min_y, (m.max_y - m.min_y) + 40)
		var cx := maxi(0, m.min_x - 20)
		var cy := maxi(0, m.min_y - 20)
		var crop := img.get_region(Rect2i(cx, cy, cw, ch))
		crop.save_png("res://references/white_circle_crop_%d.png" % i)

	quit(0)
