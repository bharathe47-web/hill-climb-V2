extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png")
	var rim := Image.load_from_file("res://assets/vehicles/wheels/rims/wheel_rim_hub_detailed.png")
	
	# Rim has bright silver hub: R>0.8, G>0.8, B>0.8
	# Let's find clusters of silver pixels near y=400..600:
	var rim_pixels: Array[Vector2i] = []
	for y in range(350, 600):
		for x in range(100, 1000):
			var c: Color = img.get_pixel(x, y)
			if c.r > 0.85 and c.g > 0.85 and c.b > 0.85:
				rim_pixels.append(Vector2i(x, y))
				
	print("Found %d bright pixels in y=350..600" % rim_pixels.size())
	# Group by X into clusters
	var by_x := {}
	for p in rim_pixels:
		var bx: int = int(p.x / 40) * 40
		by_x[bx] = by_x.get(bx, 0) + 1
	for bx in by_x.keys():
		if by_x[bx] > 20:
			print("  Cluster at X~%d: %d pixels" % [bx, by_x[bx]])
			
	quit(0)
