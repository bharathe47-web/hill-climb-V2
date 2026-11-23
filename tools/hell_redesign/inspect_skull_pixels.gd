extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/environments/hell/decorations/giant_dragon_skull_decal.png")
	if not img:
		print("Cannot load")
		quit(1)
		return
	print("Size: ", img.get_size())
	# Save a copy so we can see
	img.save_png("res://references/dragon_skull_inspect.png")
	
	# Sample average color
	var r_sum := 0.0
	var g_sum := 0.0
	var b_sum := 0.0
	var count := 0
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c := img.get_pixel(x, y)
			if c.a > 0.1:
				r_sum += c.r
				g_sum += c.g
				b_sum += c.b
				count += 1
	if count > 0:
		print("Average color of non-transparent pixels: R=%.2f G=%.2f B=%.2f (total=%d)" % [
			r_sum / count, g_sum / count, b_sum / count, count
		])
	quit(0)
