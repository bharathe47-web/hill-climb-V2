@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_target.png")
	var w := img.get_width()
	var h := img.get_height()
	print("--- TARGET ANALYSIS: 1600x533 ---")

	# Average luminance and color across horizontal slices
	for y in range(0, h, 20):
		var r := 0.0
		var g := 0.0
		var b := 0.0
		for x in range(0, w, 10):
			var c := img.get_pixel(x, y)
			r += c.r
			g += c.g
			b += c.b
		var count := float(w / 10)
		r /= count
		g /= count
		b /= count
		print("Y=%3d..%3d | Avg Color: R=%.2f G=%.2f B=%.2f" % [y, y + 20, r, g, b])

	quit(0)
