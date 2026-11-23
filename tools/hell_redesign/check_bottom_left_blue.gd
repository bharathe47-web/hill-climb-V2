@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_569m.png")
	var blue_pts := []
	for y in range(500, 768):
		for x in range(0, 500):
			var c := img.get_pixel(x, y)
			if c.b > 0.65 and c.b > c.r + 0.3 and c.b > c.g:
				blue_pts.append(Vector2i(x, y))
	print("Found %d blue pixels in bottom-left quadrant" % blue_pts.size())
	if blue_pts.size() > 0:
		var min_x = 9999; var max_x = 0; var min_y = 9999; var max_y = 0
		for p in blue_pts:
			min_x = mini(min_x, p.x)
			max_x = maxi(max_x, p.x)
			min_y = mini(min_y, p.y)
			max_y = maxi(max_y, p.y)
		print("Bounding box of blue mark in bottom-left: X=[%d..%d], Y=[%d..%d]" % [min_x, max_x, min_y, max_y])
	quit(0)
