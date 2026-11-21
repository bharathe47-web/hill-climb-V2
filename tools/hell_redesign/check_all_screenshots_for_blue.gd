@tool
extends SceneTree

func _init() -> void:
	var dir := DirAccess.open("/home/daniel/Pictures/Screenshots")
	if not dir: quit(1); return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".png"):
			var full_path := "/home/daniel/Pictures/Screenshots/" + fname
			var img := Image.load_from_file(full_path)
			if img:
				img.convert(Image.FORMAT_RGBA8)
				var blue_count := 0
				for y in range(img.get_height()):
					for x in range(img.get_width()):
						var c := img.get_pixel(x, y)
						if c.b > 0.5 and (c.b - c.r) > 0.2 and (c.b - c.g) > 0.1:
							blue_count += 1
				if blue_count > 500:
					print("FILE WITH BLUE: %s (%d blue pixels)" % [fname, blue_count])
		fname = dir.get_next()

	quit(0)
