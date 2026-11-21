@tool
extends SceneTree

func _init() -> void:
	var img1410 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-10-19.png")
	var img1443 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-43-03.png")

	if img1410:
		img1410.convert(Image.FORMAT_RGBA8)
		print("14-10-19 size: %dx%d" % [img1410.get_width(), img1410.get_height()])
	if img1443:
		img1443.convert(Image.FORMAT_RGBA8)
		print("14-43-03 size: %dx%d" % [img1443.get_width(), img1443.get_height()])

	# Find differences between 1410 and 1443 if they are of the same screen, OR find user annotations
	# Let's cluster the cyan pixels in 1443:
	var cyan_pts: Array[Vector2i] = []
	var white_pts: Array[Vector2i] = []
	var w := img1443.get_width()
	var h := img1443.get_height()

	for y in range(100, 620):
		for x in range(w):
			var c := img1443.get_pixel(x, y)
			if c.r < 0.2 and c.g > 0.6 and c.b > 0.8:
				cyan_pts.append(Vector2i(x, y))
			elif c.r > 0.9 and c.g > 0.9 and c.b > 0.9:
				white_pts.append(Vector2i(x, y))

	print("1443: cyan points in [100..620]: %d" % cyan_pts.size())
	print("1443: white points in [100..620]: %d" % white_pts.size())

	# Let's cluster both and print bounding boxes
	_print_clusters("CYAN", cyan_pts)
	_print_clusters("WHITE", white_pts)

	quit(0)

func _print_clusters(name: String, pts: Array[Vector2i]) -> void:
	var clusters: Array[Array] = []
	for pt in pts:
		var placed := false
		for cl in clusters:
			var cl_first: Vector2i = cl[0]
			if abs(pt.x - cl_first.x) < 120 and abs(pt.y - cl_first.y) < 120:
				cl.append(pt)
				placed = true
				break
		if not placed:
			clusters.append([pt])

	print("--- %s CLUSTERS ---" % name)
	for i in range(clusters.size()):
		var cl = clusters[i]
		if cl.size() < 25: continue
		var min_x := 9999; var min_y := 9999; var max_x := -1; var max_y := -1
		for p: Vector2i in cl:
			min_x = mini(min_x, p.x); min_y = mini(min_y, p.y)
			max_x = maxi(max_x, p.x); max_y = maxi(max_y, p.y)
		print("  Cluster %d: x=[%d..%d] (w=%d), y=[%d..%d] (h=%d), count=%d" % [
			i, min_x, max_x, max_x - min_x, min_y, max_y, max_y - min_y, cl.size()
		])
