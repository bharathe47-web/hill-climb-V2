@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_blue_strips.png"
	var img := Image.load_from_file(path)
	if not img: quit(1); return
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# Sample blue pen pixels:
	# Blue in paint/markup tools: high blue, lower red/green
	var blue_pixels: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# check if blue pen: c.b > 0.5 and c.b - c.r > 0.25 and c.b - c.g > 0.15
			if c.b > 0.5 and (c.b - c.r) > 0.2 and (c.b - c.g) > 0.1:
				blue_pixels.append(Vector2i(x, y))

	print("Total blue markup pixels: %d" % blue_pixels.size())

	# Group into Left vs Right (split by x around w/2 = 683)
	var left_pts: Array[Vector2i] = []
	var right_pts: Array[Vector2i] = []
	for p in blue_pixels:
		# Exclude HUD (y < 80) and pedals (y > 620)
		if p.y < 80 or (p.y > 620 and (p.x < 260 or p.x > 1050)):
			continue
		if p.x < w / 2:
			left_pts.append(p)
		else:
			right_pts.append(p)

	print("Left blue pts: %d, Right blue pts: %d" % [left_pts.size(), right_pts.size()])

	_process_region("LEFT", left_pts, img)
	_process_region("RIGHT", right_pts, img)

	quit(0)

func _process_region(name: String, pts: Array[Vector2i], img: Image) -> void:
	if pts.is_empty():
		print("No points for %s" % name)
		return
	var min_x := 9999; var min_y := 9999; var max_x := -1; var max_y := -1
	for p: Vector2i in pts:
		min_x = mini(min_x, p.x); min_y = mini(min_y, p.y)
		max_x = maxi(max_x, p.x); max_y = maxi(max_y, p.y)

	print("\n--- %s BLUE REGION ---" % name)
	print("Bounding box: x=[%d..%d] (w=%d), y=[%d..%d] (h=%d)" % [
		min_x, max_x, max_x - min_x, min_y, max_y, max_y - min_y
	])

	# Crop the entire region enclosed by the marking
	var pad := 10
	var cx := maxi(0, min_x - pad)
	var cy := maxi(0, min_y - pad)
	var cw := mini(img.get_width() - cx, (max_x - min_x) + pad * 2)
	var ch := mini(img.get_height() - cy, (max_y - min_y) + pad * 2)
	var crop := img.get_region(Rect2i(cx, cy, cw, ch))
	var out_name := "res://references/blue_marked_%s.png" % name.to_lower()
	crop.save_png(out_name)
	print("Saved %s" % out_name)

	# Also crop INSIDE the bounding box to sample the actual artwork strip!
	# The inner content is inside [min_x + 15 .. max_x - 15], [min_y + 10 .. max_y - 10]
	var in_x := min_x + 10
	var in_y := min_y + 10
	var in_w := maxi(10, (max_x - min_x) - 20)
	var in_h := maxi(10, (max_y - min_y) - 20)
	var inner_crop := img.get_region(Rect2i(in_x, in_y, in_w, in_h))
	var inner_out := "res://references/inner_strip_%s.png" % name.to_lower()
	inner_crop.save_png(inner_out)
	print("Saved inner strip: %s (%dx%d)" % [inner_out, in_w, in_h])
