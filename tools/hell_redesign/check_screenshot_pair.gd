@tool
extends SceneTree

func _init() -> void:
	var path_a := "/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-10-19.png"
	var path_b := "/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-43-03.png"
	var img_a := Image.load_from_file(path_a)
	var img_b := Image.load_from_file(path_b)
	img_a.convert(Image.FORMAT_RGBA8)
	img_b.convert(Image.FORMAT_RGBA8)

	var w := img_a.get_width()
	var h := img_a.get_height()

	var diff_map := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var total_diff := 0
	for y in range(h):
		for x in range(w):
			var ca := img_a.get_pixel(x, y)
			var cb := img_b.get_pixel(x, y)
			var d := absf(ca.r - cb.r) + absf(ca.g - cb.g) + absf(ca.b - cb.b)
			if d > 0.15:
				total_diff += 1
				diff_map.set_pixel(x, y, Color.WHITE)
			else:
				diff_map.set_pixel(x, y, Color.BLACK)

	print("Total diff pixels: %d" % total_diff)
	diff_map.save_png("res://references/diff_1410_vs_1443.png")
	quit(0)
