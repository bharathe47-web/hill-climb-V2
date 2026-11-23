@tool
extends SceneTree

func _init() -> void:
	var diff_img := Image.load_from_file("res://references/diff_1443_vs_1538.png")
	diff_img.convert(Image.FORMAT_RGBA8)
	var w := diff_img.get_width()
	var h := diff_img.get_height()

	var new_pts: Dictionary = {}
	for y in range(h):
		for x in range(w):
			var c := diff_img.get_pixel(x, y)
			# Red pixels were new blue:
			if c.r > 0.8 and c.g < 0.2 and c.b < 0.2:
				new_pts[Vector2i(x, y)] = true

	print("Total new blue pixels: %d" % new_pts.size())

	# Cluster
	var visited: Dictionary = {}
	var clusters: Array = []
	for p in new_pts:
		if visited.has(p): continue
		var cl: Array[Vector2i] = []
		var q: Array[Vector2i] = [p]
		visited[p] = true
		while not q.is_empty():
			var curr: Vector2i = q.pop_back()
			cl.append(curr)
			for dy in range(-4, 5):
				for dx in range(-4, 5):
					var nb := curr + Vector2i(dx, dy)
					if not visited.has(nb) and new_pts.has(nb):
						visited[nb] = true
						q.append(nb)
		if cl.size() > 50:
			clusters.append(cl)

	print("Found %d distinct new blue clusters:" % clusters.size())
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
