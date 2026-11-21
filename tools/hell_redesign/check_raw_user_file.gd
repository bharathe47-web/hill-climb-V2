@tool
extends SceneTree

func _init() -> void:
	var path := "/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 15-38-29.png"
	var img := Image.load_from_file(path)
	if not img:
		print("Could not load file!")
		quit(1)
		return
	img.convert(Image.FORMAT_RGBA8)
	print("Loaded %s: %dx%d" % [path, img.get_width(), img.get_height()])

	# Check where blue markup is
	# Blue pen in paint tool: e.g. RGB around (0..50, 80..150, 200..255)
	var blue_pts: Array[Vector2i] = []
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2 and (c.b - c.g) > 0.1:
				blue_pts.append(Vector2i(x, y))

	print("Total blue pixels in 15-38-29: %d" % blue_pts.size())

	# Find bounding boxes of all continuous strokes of blue
	var visited: Dictionary = {}
	var clusters: Array = []
	for p in blue_pts:
		if visited.has(p): continue
		var cl: Array[Vector2i] = []
		var q: Array[Vector2i] = [p]
		visited[p] = true
		while not q.is_empty():
			var curr: Vector2i = q.pop_back()
			cl.append(curr)
			for dy in range(-3, 4):
				for dx in range(-3, 4):
					var nb := curr + Vector2i(dx, dy)
					if not visited.has(nb) and blue_pts.has(nb):
						visited[nb] = true
						q.append(nb)
		if cl.size() > 30:
			clusters.append(cl)

	print("Found %d clusters > 30px:" % clusters.size())
	for i in range(clusters.size()):
		var cl: Array = clusters[i]
		var min_x := 9999; var max_x := -1; var min_y := 9999; var max_y := -1
		for pt: Vector2i in cl:
			min_x = mini(min_x, pt.x); max_x = maxi(max_x, pt.x)
			min_y = mini(min_y, pt.y); max_y = maxi(max_y, pt.y)
		print("  Cluster %d: %d px, x=[%d..%d] (w=%d), y=[%d..%d] (h=%d)" % [
			i, cl.size(), min_x, max_x, max_x - min_x, min_y, max_y, max_y - min_y
		])

	quit(0)
