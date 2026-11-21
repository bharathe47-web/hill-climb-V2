extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_cyan_latest.png")
	var w := img.get_width()
	var h := img.get_height()
	
	# Find where white pixels are
	var row_counts := {}
	for y in range(0, 300):
		var count := 0
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.r > 0.85 and c.g > 0.85 and c.b > 0.85:
				count += 1
		if count > 20:
			row_counts[y] = count
			
	print("Rows with white pixels: ", row_counts.keys())
	
	# Find col ranges
	for y in [10, 15, 20, 48, 52, 116, 120, 126, 132]:
		if not row_counts.has(y): continue
		var xs := []
		for x in range(w):
			var c := img.get_pixel(x, y)
			if c.r > 0.85 and c.g > 0.85 and c.b > 0.85:
				xs.append(x)
		print("Row %d: xs min=%d max=%d (count=%d)" % [y, xs.min(), xs.max(), xs.size()])
	quit(0)
