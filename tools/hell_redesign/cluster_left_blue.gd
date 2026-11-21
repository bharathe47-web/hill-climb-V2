@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_blue_strips.png"
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	var blue_pts: Array[Vector2i] = []
	for y in range(h):
		for x in range(w / 2): # left half
			var c := img.get_pixel(x, y)
			if c.b > 0.5 and (c.b - c.r) > 0.2 and (c.b - c.g) > 0.1:
				blue_pts.append(Vector2i(x, y))

	# Cluster points with distance threshold
	var clusters: Array[Array] = []
	for pt in blue_pts:
		var placed := false
		for cl in clusters:
			var f: Vector2i = cl[0]
			if abs(pt.x - f.x) < 80 and abs(pt.y - f.y) < 60:
				cl.append(pt)
				placed = true
				break
		if not placed:
			clusters.append([pt])

	print("Left half clusters:")
	for i in range(clusters.size()):
		var cl = clusters[i]
		if cl.size() < 40: continue
		var min_x := 9999; var min_y := 9999; var max_x := -1; var max_y := -1
		for p: Vector2i in cl:
			min_x = mini(min_x, p.x); min_y = mini(min_y, p.y)
			max_x = maxi(max_x, p.x); max_y = maxi(max_y, p.y)
		print("  Cluster %d: x=[%d..%d] (w=%d), y=[%d..%d] (h=%d), pts=%d" % [
			i, min_x, max_x, max_x - min_x, min_y, max_y, max_y - min_y, cl.size()
		])
		var crop := img.get_region(Rect2i(maxi(0, min_x - 10), maxi(0, min_y - 10), (max_x - min_x) + 20, (max_y - min_y) + 20))
		crop.save_png("res://references/left_cluster_%d.png" % i)

	quit(0)
