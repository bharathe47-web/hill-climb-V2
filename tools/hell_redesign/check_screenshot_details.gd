@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_white_circles.png"
	var img := Image.load_from_file(path)
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# Find cyan pixels: R < 0.2, G > 0.6, B > 0.8
	var cyan_pts: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.r < 0.2 and c.g > 0.6 and c.b > 0.8:
				cyan_pts.append(Vector2i(x, y))

	print("Cyan pixels count: %d" % cyan_pts.size())

	# Find pure white pixels: R > 0.95, G > 0.95, B > 0.95
	var white_pts: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.r > 0.95 and c.g > 0.95 and c.b > 0.95:
				white_pts.append(Vector2i(x, y))

	print("White pixels count: %d" % white_pts.size())

	# Also check what screenshot files exist in /home/daniel/Pictures/Screenshots/
	var dir := DirAccess.open("/home/daniel/Pictures/Screenshots")
	if dir:
		dir.list_dir_begin()
		var fname := dir.get_next()
		print("Recent screenshots:")
		while fname != "":
			if fname.ends_with(".png"):
				print("  ", fname)
			fname = dir.get_next()

	quit(0)
