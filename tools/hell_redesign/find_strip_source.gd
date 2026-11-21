@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/marked_strip_right.png")
	img.convert(Image.FORMAT_RGBA8)
	
	# Sample a 60x30 patch from inside the right strip: x=50..110, y=20..50
	var patch := img.get_region(Rect2i(50, 20, 60, 30))
	patch.save_png("res://references/strip_sample_60x30.png")
	print("Saved strip_sample_60x30.png")

	# Collect colors from patch (excluding user's blue pen @)
	var patch_colors: Array[Color] = []
	for y in range(patch.get_height()):
		for x in range(patch.get_width()):
			var c := patch.get_pixel(x, y)
			# skip blue pen:
			if c.b > 0.5 and (c.b - c.r) > 0.2 and (c.b - c.g) > 0.1:
				continue
			patch_colors.append(c)

	print("Sampled %d pixels from strip" % patch_colors.size())

	# Search all images in project
	var files: Array[String] = []
	_scan_dir("res://", files)
	_scan_dir("/home/daniel/Pictures/Assets For Hell", files)
	print("Total files to scan: %d" % files.size())

	var matches: Dictionary = {}
	for f in files:
		if f.begins_with("res://references/") or f.begins_with("res://docs/"):
			continue
		var tex := Image.load_from_file(f)
		if not tex: continue
		tex.convert(Image.FORMAT_RGBA8)
		var tw := tex.get_width()
		var th := tex.get_height()
		
		# Sample 25 colors from patch_colors
		var match_count := 0
		var step := maxi(1, patch_colors.size() / 25)
		for i in range(0, patch_colors.size(), step):
			var sc: Color = patch_colors[i]
			var found := false
			for ty in range(0, th, maxi(1, th / 25)):
				for tx in range(0, tw, maxi(1, tw / 25)):
					var tp := tex.get_pixel(tx, ty)
					if abs(tp.r - sc.r) < 0.02 and abs(tp.g - sc.g) < 0.02 and abs(tp.b - sc.b) < 0.02:
						match_count += 1
						found = true
						break
				if found: break
		if match_count > 12:
			matches[f] = match_count

	var sorted_matches = matches.keys()
	sorted_matches.sort_custom(func(a, b): return matches[a] > matches[b])
	print("\n--- MATCHING TEXTURES ---")
	for i in range(mini(15, sorted_matches.size())):
		var m: String = sorted_matches[i]
		print("  %s: %d matches" % [m, matches[m]])

	quit(0)

func _scan_dir(dir_path: String, results: Array[String]) -> void:
	var d := DirAccess.open(dir_path)
	if not d: return
	d.list_dir_begin()
	var fname := d.get_next()
	while fname != "":
		if fname != "." and fname != "..":
			var sub_path := dir_path.path_join(fname)
			if d.current_is_dir():
				_scan_dir(sub_path, results)
			elif fname.ends_with(".png"):
				results.append(sub_path)
		fname = d.get_next()
