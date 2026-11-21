extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/cluster_right.png")
	if not img:
		print("Cannot load cluster_right.png")
		quit(1)
		return
		
	print("cluster_right.png: ", img.get_width(), "x", img.get_height())
	# Let's see what is inside this image!
	# The user described: "The large rectangular image shows a separate dark cave/rocky bridge scene with a waterfall-like opening. It does not match the seamless crimson Hell environment."
	# Is there a rectangular sub-image within cluster_right.png?
	# Let's search all textures in the project to see which one matches pixels in cluster_right.png!
	var candidates: Array[String] = []
	var dir := DirAccess.open("res://assets")
	_scan_dir_for_textures("res://assets", candidates)
	_scan_dir_for_textures("res://references", candidates)
	print("Found %d texture candidates in project" % candidates.size())
	
	# Also check Assets For Hell directory
	var ext_candidates: Array[String] = []
	_scan_dir_for_textures("/home/daniel/Pictures/Assets For Hell", ext_candidates)
	print("Found %d texture candidates in /home/daniel/Pictures/Assets For Hell" % ext_candidates.size())
	
	# Now let's test if any candidate texture appears inside references/hell_cleanup_pink.png!
	var full_img := Image.load_from_file("res://references/hell_cleanup_pink.png")
	var matched: Array[Dictionary] = []
	
	for path in candidates + ext_candidates:
		if not path.ends_with(".png"):
			continue
		if "hud" in path.to_lower() or "button" in path.to_lower() or "coin" in path.to_lower() or "wheel" in path.to_lower() or "dust" in path.to_lower() or "strip" in path.to_lower() or "font" in path.to_lower():
			continue
		var tex := Image.load_from_file(path)
		if not tex or tex.get_width() < 50 or tex.get_height() < 50:
			continue
		
		# Sample a 20x20 patch from the middle of tex (if opaque)
		var mid_x := tex.get_width() / 2
		var mid_y := tex.get_height() / 2
		var p_mid := tex.get_pixel(mid_x, mid_y)
		if p_mid.a < 0.8:
			continue
			
		# Check if there is an exact or near match in full_img
		var found_match := false
		var sample_pts: Array[Vector2i] = [
			Vector2i(mid_x, mid_y),
			Vector2i(mid_x - 10, mid_y - 10),
			Vector2i(mid_x + 10, mid_y + 10),
			Vector2i(mid_x - 10, mid_y + 10),
			Vector2i(mid_x + 10, mid_y - 10)
		]
		
		# Quick check: does the candidate filename match keywords?
		var kw := ["cave", "cavern", "waterfall", "bridge", "rock", "lake", "portal", "dark", "underground"]
		var has_kw := false
		for k in kw:
			if k in path.to_lower():
				has_kw = true
				break
		if has_kw:
			print("Keyword candidate: ", path, " (", tex.get_width(), "x", tex.get_height(), ")")

	quit(0)

func _scan_dir_for_textures(path: String, out: Array[String]) -> void:
	var dir := DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not fname.begins_with("."):
			var full := path.path_join(fname)
			if dir.current_is_dir():
				_scan_dir_for_textures(full, out)
			elif fname.ends_with(".png"):
				out.append(full)
		fname = dir.get_next()
