extends SceneTree

func _init() -> void:
	print("--- MATCHING CANDIDATE TEXTURES IN CROPS ---")
	var crop_names: Array[String] = ["cyan_crop_left.png", "cyan_crop_mid.png", "cyan_crop_low.png", "cyan_crop_right.png"]
	var crops: Array[Image] = []
	for cname in crop_names:
		var img := Image.load_from_file("res://references/" + cname)
		img.convert(Image.FORMAT_RGBA8)
		crops.append(img)
		
	# Collect all candidate props
	var candidate_paths: Array[String] = []
	_collect_pngs("res://assets/environment/countryside", candidate_paths)
	_collect_pngs("res://assets/terrain", candidate_paths)
	_collect_pngs("res://assets/environments/hell", candidate_paths)
	_collect_pngs("res://quarantine", candidate_paths)
	_collect_pngs("res://assets/props", candidate_paths)
	
	print("Found %d candidate textures" % candidate_paths.size())
	
	for path in candidate_paths:
		var tex := Image.load_from_file(path)
		if not tex or tex.get_width() < 16 or tex.get_height() < 16:
			continue
		tex.convert(Image.FORMAT_RGBA8)
		
		# Sample center 12x12
		var cx := tex.get_width() / 2
		var cy := tex.get_height() / 2
		var p_center := tex.get_pixel(cx, cy)
		if p_center.a < 0.8:
			# find a solid pixel
			for ty in range(tex.get_height()):
				for tx in range(tex.get_width()):
					if tex.get_pixel(tx, ty).a > 0.9:
						cx = tx
						cy = ty
						p_center = tex.get_pixel(cx, cy)
						break
				if p_center.a > 0.9: break
		if p_center.a < 0.8: continue
		
		# Test against each crop
		for i in range(crops.size()):
			var cimg: Image = crops[i]
			var cw := cimg.get_width()
			var ch := cimg.get_height()
			var matches := 0
			# Scan for p_center in crop
			for y in range(0, ch, 2):
				for x in range(0, cw, 2):
					var cp := cimg.get_pixel(x, y)
					if abs(cp.r - p_center.r) < 0.03 and abs(cp.g - p_center.g) < 0.03 and abs(cp.b - p_center.b) < 0.03:
						# verify 6x6 patch
						var ok := true
						for dy in range(-3, 4):
							for dx in range(-3, 4):
								var px := clampi(cx + dx, 0, tex.get_width() - 1)
								var py := clampi(cy + dy, 0, tex.get_height() - 1)
								var qx := clampi(x + dx, 0, cw - 1)
								var qy := clampi(y + dy, 0, ch - 1)
								var tp := tex.get_pixel(px, py)
								var qp := cimg.get_pixel(qx, qy)
								if abs(tp.r - qp.r) > 0.06 or abs(tp.g - qp.g) > 0.06 or abs(tp.b - qp.b) > 0.06:
									ok = false
									break
							if not ok: break
						if ok:
							matches += 1
			if matches >= 1:
				print("MATCH (%s in %s): matches=%d" % [path, crop_names[i], matches])
				
	quit(0)

func _collect_pngs(dir_path: String, out: Array[String]) -> void:
	var dir := DirAccess.open(dir_path)
	if not dir: return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not fname.begins_with("."):
			var full := dir_path.path_join(fname)
			if dir.current_is_dir():
				_collect_pngs(full, out)
			elif fname.ends_with(".png"):
				out.append(full)
		fname = dir.get_next()
