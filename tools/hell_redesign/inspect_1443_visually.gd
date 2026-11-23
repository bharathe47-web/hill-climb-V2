@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-43-03.png")
	if not img: quit(1); return
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# Save three crops from 14-43-03:
	# 1. centre-left road (e.g. x=300..600, y=350..600)
	# 2. middle-right (e.g. x=600..1000, y=350..600)
	# 3. far-right (e.g. x=950..1366, y=350..600)
	var c1 := img.get_region(Rect2i(250, 350, 350, 250))
	c1.save_png("res://references/crop_centre_left.png")

	var c2 := img.get_region(Rect2i(600, 350, 400, 250))
	c2.save_png("res://references/crop_middle_right.png")

	var c3 := img.get_region(Rect2i(950, 350, 400, 250))
	c3.save_png("res://references/crop_far_right.png")

	print("Saved crops: crop_centre_left.png, crop_middle_right.png, crop_far_right.png")

	# Also let's check differences between 14-10-19 and 14-43-03
	var img_old := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-10-19.png")
	if img_old:
		img_old.convert(Image.FORMAT_RGBA8)
		var diff_count := 0
		var diff_pts: Array[Vector2i] = []
		for y in range(h):
			for x in range(w):
				var c_new := img.get_pixel(x, y)
				var c_prev := img_old.get_pixel(x, y)
				var diff := absf(c_new.r - c_prev.r) + absf(c_new.g - c_prev.g) + absf(c_new.b - c_prev.b)
				if diff > 0.2:
					diff_count += 1
					diff_pts.append(Vector2i(x, y))
		print("Total diff points between 14-10-19 and 14-43-03: %d" % diff_count)
		
		# Cluster diff points
		var clusters: Array[Array] = []
		for pt in diff_pts:
			var placed := false
			for cl in clusters:
				var f: Vector2i = cl[0]
				if abs(pt.x - f.x) < 100 and abs(pt.y - f.y) < 100:
					cl.append(pt)
					placed = true
					break
			if not placed:
				clusters.append([pt])
		
		print("Diff clusters count: %d" % clusters.size())
		for i in range(clusters.size()):
			var cl = clusters[i]
			if cl.size() < 30: continue
			var min_x := 9999; var min_y := 9999; var max_x := -1; var max_y := -1
			for p: Vector2i in cl:
				min_x = mini(min_x, p.x); min_y = mini(min_y, p.y)
				max_x = maxi(max_x, p.x); max_y = maxi(max_y, p.y)
			print("  Diff cluster %d: x=[%d..%d], y=[%d..%d], count=%d" % [i, min_x, max_x, min_y, max_y, cl.size()])
			var crop := img.get_region(Rect2i(maxi(0, min_x - 10), maxi(0, min_y - 10), (max_x - min_x) + 20, (max_y - min_y) + 20))
			crop.save_png("res://references/diff_cluster_%d.png" % i)

	quit(0)
