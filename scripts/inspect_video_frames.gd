extends SceneTree

func _init() -> void:
	print("--- INSPECTING VIDEO FRAMES ---")
	# Sample frames across the recording
	for sec in [2, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 70, 80, 90, 100, 110]:
		var fname := "/tmp/screencast_frames/frame_%03d.png" % sec
		var img := Image.load_from_file(fname)
		if not img:
			continue
		var w := img.get_width()
		var h := img.get_height()
		# Sample top bar color (around x=w/2, y=30)
		var top_col := img.get_pixel(w / 2, 30)
		# Sample center sky color (around x=w/2, y=200)
		var sky_col := img.get_pixel(w / 2, 200)
		# Sample ground color (around x=w/2, y=600)
		var gnd_col := img.get_pixel(w / 2, 600)
		print("t=%3ds: Sky=(%.2f, %.2f, %.2f) Gnd=(%.2f, %.2f, %.2f) Top=(%.2f, %.2f, %.2f)" % [
			sec, sky_col.r, sky_col.g, sky_col.b, gnd_col.r, gnd_col.g, gnd_col.b, top_col.r, top_col.g, top_col.b
		])
	quit()
