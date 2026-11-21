extends SceneTree

func _init() -> void:
	var cluster_img := Image.load_from_file("res://references/cyan_cluster_2.png")
	if not cluster_img:
		printerr("Cannot load cyan_cluster_2.png")
		quit(1)
		return
	cluster_img.convert(Image.FORMAT_RGBA8)
	var cw := cluster_img.get_width()
	var ch := cluster_img.get_height()
	print("Cluster 2 size: %dx%d" % [cw, ch])
	
	# Scan candidate textures across project
	var all_paths: Array[String] = []
	_scan_dir("res://assets", all_paths)
	_scan_dir("res://quarantine", all_paths)
	
	print("Scanning %d textures..." % all_paths.size())
	
	for path in all_paths:
		var tex := Image.load_from_file(path)
		if not tex or tex.get_width() < 16 or tex.get_height() < 16:
			continue
		tex.convert(Image.FORMAT_RGBA8)
		
		# Find prominent solid color features in candidate texture
		var tw := tex.get_width()
		var th := tex.get_height()
		
		# Sample 5 distinct solid pixels in tex
		var sample_points: Array[Vector2i] = []
		for sy in range(int(th * 0.2), int(th * 0.8), maxi(1, int(th * 0.15))):
			for sx in range(int(tw * 0.2), int(tw * 0.8), maxi(1, int(tw * 0.15))):
				var p := tex.get_pixel(sx, sy)
				if p.a > 0.95 and not (p.r < 0.05 and p.g < 0.05 and p.b < 0.05):
					sample_points.append(Vector2i(sx, sy))
					if sample_points.size() >= 5:
						break
			if sample_points.size() >= 5:
				break
				
		if sample_points.size() < 3:
			continue
			
		# Check if at least 3 sample points match with a scale/translation
		# Simpler: check if 10x10 patch from center of tex appears anywhere in cluster_img (try scales 0.2 to 1.0)
		var center_pt: Vector2i = sample_points[0]
		var col0 := tex.get_pixel(center_pt.x, center_pt.y)
		
		var match_count := 0
		for y in range(0, ch, 2):
			for x in range(0, cw, 2):
				var cp := cluster_img.get_pixel(x, y)
				# Ignore cyan annotations
				if cp.b > 0.45 and (cp.b - cp.r) > 0.15:
					continue
				if abs(cp.r - col0.r) < 0.04 and abs(cp.g - col0.g) < 0.04 and abs(cp.b - col0.b) < 0.04:
					# Check 4x4 neighborhood
					var ok := true
					for dy in range(-2, 3):
						for dx in range(-2, 3):
							var tx_val := tex.get_pixel(clampi(center_pt.x + dx, 0, tw - 1), clampi(center_pt.y + dy, 0, th - 1))
							var cx_val := cluster_img.get_pixel(clampi(x + dx, 0, cw - 1), clampi(y + dy, 0, ch - 1))
							if abs(tx_val.r - cx_val.r) > 0.08 or abs(tx_val.g - cx_val.g) > 0.08 or abs(tx_val.b - cx_val.b) > 0.08:
								ok = false
								break
						if not ok: break
					if ok:
						match_count += 1
		if match_count >= 5:
			print("MATCH: %s (matches=%d)" % [path, match_count])
			
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
