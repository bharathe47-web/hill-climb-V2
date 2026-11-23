extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png")
	
	# Sample a 16x16 patch from (x=380, y=480)
	var patch := img.get_region(Rect2i(360, 460, 40, 40))
	patch.save_png("res://references/crate_patch.png")
	print("Saved crate_patch.png")
	
	# Let's search all textures in res://assets and res://quarantine for this patch!
	var all_paths: Array[String] = []
	_scan_dir("res://assets", all_paths)
	_scan_dir("res://quarantine", all_paths)
	
	var p_center := patch.get_pixel(20, 20)
	print("Patch center color: R=%.3f G=%.3f B=%.3f" % [p_center.r, p_center.g, p_center.b])
	
	for path in all_paths:
		var tex := Image.load_from_file(path)
		if not tex or tex.get_width() < 16 or tex.get_height() < 16:
			continue
		tex.convert(Image.FORMAT_RGBA8)
		
		# Check if tex contains a pixel close to p_center
		var found_match := false
		for ty in range(tex.get_height()):
			for tx in range(tex.get_width()):
				var tp := tex.get_pixel(tx, ty)
				if abs(tp.r - p_center.r) < 0.03 and abs(tp.g - p_center.g) < 0.03 and abs(tp.b - p_center.b) < 0.03:
					# Check 8x8 around tx, ty against patch(16..24, 16..24)
					var match_all := true
					for dy in range(-4, 5):
						for dx in range(-4, 5):
							var tp2 := tex.get_pixel(clampi(tx + dx, 0, tex.get_width() - 1), clampi(ty + dy, 0, tex.get_height() - 1))
							var pp2 := patch.get_pixel(20 + dx, 20 + dy)
							if abs(tp2.r - pp2.r) > 0.06 or abs(tp2.g - pp2.g) > 0.06 or abs(tp2.b - pp2.b) > 0.06:
								match_all = false
								break
						if not match_all: break
					if match_all:
						print("EXACT MATCH IN: ", path, " at (", tx, ", ", ty, ")")
						found_match = true
						break
			if found_match: break
	quit(0)

func _scan_dir(dir_path: String, out: Array[String]) -> void:
	var dir := DirAccess.open(dir_path)
	if not dir: return
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not f.begins_with("."):
			var full := dir_path + "/" + f
			if dir.current_is_dir():
				_scan_dir(full, out)
			elif f.ends_with(".png"):
				out.append(full)
		f = dir.get_next()
	dir.list_dir_end()
