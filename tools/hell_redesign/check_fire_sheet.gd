@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/environments/hell/vfx/fire/fire_sheet_5x5.png")
	if img:
		print("fire_sheet_5x5.png size: ", img.get_size(), " format: ", img.get_format())
		var c := img.get_pixel(0, 0)
		print("Top-left pixel (0,0): R=%.2f G=%.2f B=%.2f A=%.2f" % [c.r, c.g, c.b, c.a])
		var c_center := img.get_pixel(img.get_width() / 2, img.get_height() / 2)
		print("Center pixel: R=%.2f G=%.2f B=%.2f A=%.2f" % [c_center.r, c_center.g, c_center.b, c_center.a])
		# Count black pixels vs transparent
		var black_count := 0
		var trans_count := 0
		for y in range(0, img.get_height(), 10):
			for x in range(0, img.get_width(), 10):
				var p := img.get_pixel(x, y)
				if p.a < 0.1:
					trans_count += 1
				elif p.r < 0.05 and p.g < 0.05 and p.b < 0.05:
					black_count += 1
		print("Sampled: transparent=%d, black=%d" % [trans_count, black_count])

	quit(0)
