@tool
extends SceneTree

func _init() -> void:
	var path := "res://references/hell_cleanup_white_circles.png"
	var img := Image.load_from_file(path)
	if not img:
		printerr("Cannot load ", path)
		quit(1)
		return
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()

	# Also load the previous clean screenshot or check what colors are present
	# Let's find pixels where R, G, B are high and close together
	# But let's check between y=200 and y=600 (gameplay area, excluding HUD and pedals)
	print("Scanning gameplay area y in [180..600]...")
	var drawn_pts: Array[Vector2i] = []
	for y in range(180, 600):
		for x in range(w):
			var c := img.get_pixel(x, y)
			# Check brightness
			var lum := 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
			# In the Hell biome, the background is dark red / crimson / black
			# A white drawing has high luminance (> 0.75) and low saturation
			var sat := (maxf(c.r, maxf(c.g, c.b)) - minf(c.r, minf(c.g, c.b)))
			if lum > 0.65 and sat < 0.20:
				drawn_pts.append(Vector2i(x, y))

	print("Found %d white/bright drawn points in gameplay area" % drawn_pts.size())

	# Group by x coordinate buckets (e.g. 50px buckets)
	var x_buckets: Dictionary = {}
	for pt in drawn_pts:
		var bx: int = int(pt.x / 40) * 40
		x_buckets[bx] = x_buckets.get(bx, 0) + 1

	for k in x_buckets.keys():
		if x_buckets[k] > 10:
			print("Bucket x=%d: %d points" % [k, x_buckets[k]])

	quit(0)
