@tool
extends SceneTree

func _init() -> void:
	var img1 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-43-03.png")
	var img2 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 15-38-29.png")
	img1.convert(Image.FORMAT_RGBA8)
	img2.convert(Image.FORMAT_RGBA8)

	var w := img1.get_width()
	var h := img1.get_height()

	var diff_img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var new_blue_pts: Array[Vector2i] = []

	for y in range(h):
		for x in range(w):
			var c1: Color = img1.get_pixel(x, y)
			var c2: Color = img2.get_pixel(x, y)
			var is_blue1: bool = c1.b > 0.5 and (c1.b - c1.r) > 0.2 and (c1.b - c1.g) > 0.1
			var is_blue2: bool = c2.b > 0.5 and (c2.b - c2.r) > 0.2 and (c2.b - c2.g) > 0.1
			if is_blue2 and not is_blue1:
				new_blue_pts.append(Vector2i(x, y))
				diff_img.set_pixel(x, y, Color(1, 0, 0, 1))
			elif is_blue1 and not is_blue2:
				diff_img.set_pixel(x, y, Color(0, 0, 1, 1))

	diff_img.save_png("res://references/diff_1443_vs_1538.png")
	print("Saved diff_1443_vs_1538.png. Total new blue pixels: %d" % new_blue_pts.size())

	if not new_blue_pts.is_empty():
		var min_x := 9999; var max_x := -1; var min_y := 9999; var max_y := -1
		for p: Vector2i in new_blue_pts:
			min_x = mini(min_x, p.x); max_x = maxi(max_x, p.x)
			min_y = mini(min_y, p.y); max_y = maxi(max_y, p.y)
		print("New blue pixels bbox: x=[%d..%d] (w=%d), y=[%d..%d] (h=%d)" % [
			min_x, max_x, max_x - min_x, min_y, max_y, max_y - min_y
		])

	quit(0)
