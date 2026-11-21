extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png")
	
	# The monster truck has large wheels (wheel_rear, wheel_front) and vehicle body
	# Let's find the driver sprite or truck rims (bright silver rims / white hub)
	# Rim has silver/white pixels and dark tire rubber
	# Let's scan for the wheels:
	var w := img.get_width()
	var h := img.get_height()
	
	# Let's search across the whole image for the truck wheels or body
	# In 13-37-08, let's find the lowest/highest coordinates of the vehicle:
	# Monster truck has purple/dark body: R=0.235, G=0.047, B=0.243
	var body_pixels: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			var c: Color = img.get_pixel(x, y)
			if abs(c.r - 0.235) < 0.04 and abs(c.g - 0.047) < 0.04 and abs(c.b - 0.243) < 0.04:
				body_pixels.append(Vector2i(x, y))
				
	print("Found %d purple truck body pixels!" % body_pixels.size())
	if body_pixels.size() > 0:
		var min_x := 9999
		var max_x := -1
		var min_y := 9999
		var max_y := -1
		for p in body_pixels:
			min_x = min(min_x, p.x)
			max_x = max(max_x, p.x)
			min_y = min(min_y, p.y)
			max_y = max(max_y, p.y)
		print("Truck body bounds: X=[%d, %d] (w=%d), Y=[%d, %d] (h=%d), center=(%d, %d)" % [
			min_x, max_x, max_x - min_x, min_y, max_y, max_y - min_y, (min_x + max_x) / 2, (min_y + max_y) / 2
		])
		
	quit(0)
