extends SceneTree

func _init() -> void:
	var suspect := Image.load_from_file("res://references/suspect_region_large.png")
	if not suspect:
		quit(1)
		return
	suspect.convert(Image.FORMAT_RGBA8)
	var sw := suspect.get_width()
	var sh := suspect.get_height()
	
	print("Scanning all PNG assets to see which one matches pixels in suspect_region_large.png...")
	var all_pngs: Array[String] = []
	_scan_dir("res://assets", all_pngs)
	_scan_dir("res://quarantine", all_pngs)
	_scan_dir("/home/daniel/Pictures/Assets For Hell", all_pngs)
	
	print("Total candidate PNGs: ", all_pngs.size())
	
	# Sample a 8x8 patch from suspect at a few non-pink locations
	var test_patches: Array[Dictionary] = []
	for py in range(50, sh - 50, 40):
		for px in range(50, sw - 50, 40):
			# Make sure it's not pink annotation
			var c := suspect.get_pixel(px, py)
			if c.r > 0.65 and c.g > 0.35 and c.b > 0.30:
				continue # skip pink
			# Grab 8x8
			var patch := suspect.get_region(Rect2i(px, py, 8, 8))
			test_patches.append({"pos": Vector2i(px, py), "img": patch})
			
	print("Extracted %d test patches from suspect region" % test_patches.size())
	
	# Test candidates
	for path in all_pngs:
		if "button" in path.to_lower() or "font" in path.to_lower() or "hud" in path.to_lower() or "particle" in path.to_lower():
			continue
		var tex := Image.load_from_file(path)
		if not tex or tex.get_width() < 30 or tex.get_height() < 30:
			continue
		tex.convert(Image.FORMAT_RGBA8)
		
		# Let's test if any test patch matches anywhere in tex (accounting for scale?)
		# First let's check exact match at 1:1 scale
		var tw := tex.get_width()
		var th := tex.get_height()
		
		var match_found := false
		for tp in test_patches:
			var patch_img: Image = tp.img
			var p0 := patch_img.get_pixel(0, 0)
			# Find occurrences of p0 in tex
			for ty in range(0, th - 8, 2):
				for tx in range(0, tw - 8, 2):
					var tc := tex.get_pixel(tx, ty)
					if abs(tc.r - p0.r) < 0.03 and abs(tc.g - p0.g) < 0.03 and abs(tc.b - p0.b) < 0.03:
						# check rest of 8x8
						var ok := true
						for dy in range(1, 8):
							for dx in range(1, 8):
								var p1 := patch_img.get_pixel(dx, dy)
								var p2 := tex.get_pixel(tx + dx, ty + dy)
								if abs(p1.r - p2.r) > 0.05 or abs(p1.g - p2.g) > 0.05 or abs(p1.b - p2.b) > 0.05:
									ok = false
									break
							if not ok:
								break
						if ok:
							print(">>> MATCH FOUND! File: %s at (%d, %d), matches suspect pos %s" % [path, tx, ty, tp.pos])
							match_found = true
							break
				if match_found:
					break
			if match_found:
				break
				
	quit(0)

func _scan_dir(path: String, out: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var f := dir.get_next()
	while f != "":
		if not f.begins_with("."):
			var full := path.path_join(f)
			if dir.current_is_dir():
				_scan_dir(full, out)
			elif f.ends_with(".png"):
				out.append(full)
		f = dir.get_next()
