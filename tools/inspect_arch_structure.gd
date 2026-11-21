@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/environments/heaven/architecture/heaven_viaduct_arch_cutout.png")
	var w := img.get_width()
	var h := img.get_height()
	print("Arch size: %dx%d" % [w, h])

	# Check left edge (x=0..30), center (x=300..340), right edge (x=610..639)
	for y in [0, 1, 5, 10, 20, 30, 50, 100, 150, 200, 250, 279]:
		var left_col = img.get_pixel(0, y)
		var left5_col = img.get_pixel(5, y)
		var mid_col = img.get_pixel(w / 2, y)
		var right5_col = img.get_pixel(w - 6, y)
		var right_col = img.get_pixel(w - 1, y)
		print("y=%3d | x=0: a=%.2f | x=5: a=%.2f | mid: a=%.2f | x=w-6: a=%.2f | x=w-1: a=%.2f" % [
			y, left_col.a, left5_col.a, mid_col.a, right5_col.a, right_col.a
		])

	# Also check top horizontal strip: across x=0..639 at y=0, y=1, y=2, y=5
	print("\n--- Horizontal strip at y=0: min alpha, max alpha, transparent count ---")
	for y in [0, 1, 2, 5, 10]:
		var min_a: float = 1.0
		var max_a: float = 0.0
		var zero_count: int = 0
		for x in range(w):
			var a := img.get_pixel(x, y).a
			min_a = minf(min_a, a)
			max_a = maxf(max_a, a)
			if a < 0.05:
				zero_count += 1
		print("y=%d: min_a=%.2f, max_a=%.2f, transparent_pixels=%d / %d" % [y, min_a, max_a, zero_count, w])

	# Also check vertical column of pixels at x=0 and x=w-1
	print("\n--- Pier thickness (how many solid pixels from left and right) at y=150 ---")
	var left_solid = 0
	for x in range(w):
		if img.get_pixel(x, 150).a > 0.5:
			left_solid += 1
		else:
			break
	var right_solid = 0
	for x in range(w - 1, -1, -1):
		if img.get_pixel(x, 150).a > 0.5:
			right_solid += 1
		else:
			break
	print("At y=150: left pier width=%d px, right pier width=%d px, arch opening width=%d px" % [
		left_solid, right_solid, w - left_solid - right_solid
	])

	quit(0)
