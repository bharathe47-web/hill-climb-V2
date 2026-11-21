@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_blue_strips.png"
	var img := Image.load_from_file(path)
	if not img:
		printerr("Cannot load ", path)
		quit(1)
		return
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Image size: %dx%d" % [w, h])

	# Check HUD distance around x=500..850, y=10..60
	var hud := img.get_region(Rect2i(550, 10, 260, 50))
	hud.save_png("res://references/hud_blue_strips.png")

	# Find blue pixels (pen strokes):
	# Usually blue has low red, moderate green, high blue (e.g. r < 0.3, b > 0.6)
	# Or cyan (r < 0.2, g > 0.6, b > 0.8), or pure blue (r < 0.2, g < 0.4, b > 0.7)
	var blue_pts: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			# Skip top HUD (y < 90) and bottom pedals (y > 600)
			if y < 90 or (y > 600 and (x < 260 or x > 1050)):
				continue
			var c := img.get_pixel(x, y)
			# Look for blue / cyan pen strokes: b > 0.6 and (b - r) > 0.3
			if c.b > 0.55 and (c.b - c.r) > 0.25:
				blue_pts.append(Vector2i(x, y))

	print("Found %d blue stroke candidate pixels" % blue_pts.size())

	# Cluster blue points
	var clusters: Array[Array] = []
	for pt in blue_pts:
		var placed := false
		for cl in clusters:
			var f: Vector2i = cl[0]
			if abs(pt.x - f.x) < 200 and abs(pt.y - f.y) < 150:
				cl.append(pt)
				placed = true
				break
		if not placed:
			clusters.append([pt])

	print("Total clusters: %d" % clusters.size())
	for i in range(clusters.size()):
		var cl = clusters[i]
		if cl.size() < 40:
			continue
		var min_x := 9999; var min_y := 9999; var max_x := -1; var max_y := -1
		for p: Vector2i in cl:
			min_x = mini(min_x, p.x); min_y = mini(min_y, p.y)
			max_x = maxi(max_x, p.x); max_y = maxi(max_y, p.y)
		print("Cluster %d: x=[%d..%d] (w=%d), y=[%d..%d] (h=%d), pts=%d" % [
			i, min_x, max_x, max_x - min_x, min_y, max_y, max_y - min_y, cl.size()
		])
		var pad := 30
		var cx := maxi(0, min_x - pad)
		var cy := maxi(0, min_y - pad)
		var cw := mini(w - cx, (max_x - min_x) + pad * 2)
		var ch := mini(h - cy, (max_y - min_y) + pad * 2)
		var crop := img.get_region(Rect2i(cx, cy, cw, ch))
		crop.save_png("res://references/blue_strip_crop_%d.png" % i)

	quit(0)
