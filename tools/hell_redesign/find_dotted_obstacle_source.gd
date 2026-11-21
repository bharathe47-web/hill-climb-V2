@tool
extends SceneTree

func _init() -> void:
	# Load crop_centre_left.png
	var crop := Image.load_from_file("res://references/crop_centre_left.png")
	crop.convert(Image.FORMAT_RGBA8)
	
	# Sample a 40x40 patch of the obstacle
	# In crop_centre_left, between x=80..160, y=100..180 is the obstacle!
	var patch := crop.get_region(Rect2i(80, 110, 50, 50))
	patch.save_png("res://references/obstacle_sample_50x50.png")
	print("Saved obstacle_sample_50x50.png")

	# Collect all unique colors from this patch (excluding transparent / pure white)
	var sample_colors: Array[Color] = []
	for y in range(patch.get_height()):
		for x in range(patch.get_width()):
			var c := patch.get_pixel(x, y)
			if c.a > 0.8:
				# avoid user's white pen:
				if c.r > 0.85 and c.g > 0.85 and c.b > 0.85:
					continue
				sample_colors.append(c)

	print("Sampled %d colors from obstacle patch" % sample_colors.size())

	# Now search ALL .png files in the repository
	var files: Array[String] = []
	_scan_dir("res://", files)
	print("Total png files to scan: %d" % files.size())

	var matches: Dictionary = {}
	for f in files:
		# skip references and docs
		if f.begins_with("res://references/") or f.begins_with("res://docs/") or f.begins_with("res://quarantine/"):
			continue
		var tex := Image.load_from_file(f)
		if not tex: continue
		tex.convert(Image.FORMAT_RGBA8)
		var match_count := 0
		var tw := tex.get_width()
		var th := tex.get_height()
		
		# Sample up to 50 points from sample_colors
		var step := maxi(1, sample_colors.size() / 40)
		for i in range(0, sample_colors.size(), step):
			var sc: Color = sample_colors[i]
			var found := false
			for ty in range(0, th, maxi(1, th / 30)):
				for tx in range(0, tw, maxi(1, tw / 30)):
					var tp := tex.get_pixel(tx, ty)
					if tp.a > 0.8 and abs(tp.r - sc.r) < 0.03 and abs(tp.g - sc.g) < 0.03 and abs(tp.b - sc.b) < 0.03:
						match_count += 1
						found = true
						break
				if found:
					break
		if match_count > 10:
			matches[f] = match_count

	var sorted_matches = matches.keys()
	sorted_matches.sort_custom(func(a, b): return matches[a] > matches[b])
	print("\n--- TOP MATCHING TEXTURES IN PROJECT ---")
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
