@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_blue_strips.png"
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# Find blue pixels:
	# Blue ink: c.b > 0.5 and (c.b - c.r) > 0.2 and (c.b - c.g) > 0.1
	var blue_grid: Dictionary = {}
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2 and (c.b - c.g) > 0.1:
				blue_grid[Vector2i(x, y)] = true

	print("Total blue pixels found: %d" % blue_grid.size())

	# Connected components (with 8-neighbor expansion and radius=5)
	var visited: Dictionary = {}
	var clusters: Array[Array] = []

	for pt in blue_grid:
		if visited.has(pt):
			continue
		var cluster: Array[Vector2i] = []
		var queue: Array[Vector2i] = [pt]
		visited[pt] = true

		while not queue.is_empty():
			var curr: Vector2i = queue.pop_back()
			cluster.append(curr)

			# Search within distance 5
			for dy in range(-4, 5):
				for dx in range(-4, 5):
					var nb := curr + Vector2i(dx, dy)
					if blue_grid.has(nb) and not visited.has(nb):
						visited[nb] = true
						queue.append(nb)

		if cluster.size() > 50:
			clusters.append(cluster)

	print("Found %d distinct blue marking clusters:" % clusters.size())
	for i in range(clusters.size()):
		var cl: Array = clusters[i]
		var min_x := 9999; var max_x := -1; var min_y := 9999; var max_y := -1
		for p: Vector2i in cl:
			min_x = mini(min_x, p.x); max_x = maxi(max_x, p.x)
			min_y = mini(min_y, p.y); max_y = maxi(max_y, p.y)
		print("Cluster %d: %d pixels, bbox x=[%d..%d] (w=%d), y=[%d..%d] (h=%d)" % [
			i, cl.size(), min_x, max_x, max_x - min_x, min_y, max_y, max_y - min_y
		])

		# Save crop of each cluster with 10px margin
		var crop_x := maxi(0, min_x - 10)
		var crop_y := maxi(0, min_y - 10)
		var crop_w := mini(w - crop_x, (max_x - min_x) + 20)
		var crop_h := mini(h - crop_y, (max_y - min_y) + 20)
		var crop := img.get_region(Rect2i(crop_x, crop_y, crop_w, crop_h))
		var out_path := "res://references/user_blue_cluster_%d.png" % i
		crop.save_png(out_path)
		print("  Saved %s (%dx%d)" % [out_path, crop_w, crop_h])

	quit(0)
