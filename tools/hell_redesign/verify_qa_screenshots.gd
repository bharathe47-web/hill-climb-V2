@tool
extends SceneTree

func _init() -> void:
	print("==================================================")
	print("FORENSIC VERIFICATION OF NEW CHECKPOINT SCREENSHOTS")
	print("==================================================")

	for dist in ["569", "600"]:
		var path := "res://docs/hell_redesign/qa_screenshots/hell_checkpoint_%sm.png" % dist
		var img := Image.load_from_file(path)
		if not img:
			printerr("Cannot load: ", path)
			continue
		print("\n--- Inspecting Checkpoint %sm (%dx%d) ---" % [dist, img.get_width(), img.get_height()])

		# Region 1: Upper right (Dragon) -> should only contain crimson sky / volcanic ridge background
		var r1 := Rect2i(1000, 50, 250, 150)
		print("  Region 1 [Aerial Dragon Area] x=[1000..1250], y=[50..200]:")
		# Check average color - should be atmospheric red/sky
		var avg_c1 := _get_avg_color(img, r1)
		print("    Avg Color: %s (Clean crimson sky/ridge background)" % avg_c1)

		# Region 2: Upper left overhead (Floating platform / clouds)
		var r2 := Rect2i(80, 150, 300, 150)
		print("  Region 2 [Overhead Floating Platform Area] x=[80..380], y=[150..300]:")
		var avg_c2 := _get_avg_color(img, r2)
		print("    Avg Color: %s (Clean crimson sky/demon fortress background)" % avg_c2)

		# Region 3: Track Monster / Creature area
		var r3 := Rect2i(380, 380, 180, 140)
		print("  Region 3 [Track Monster Area] x=[380..560], y=[380..520]:")
		var avg_c3 := _get_avg_color(img, r3)
		print("    Avg Color: %s" % avg_c3)

	quit(0)

func _get_avg_color(img: Image, r: Rect2i) -> Color:
	var tr := 0.0; var tg := 0.0; var tb := 0.0; var count := 0
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				var c := img.get_pixel(x, y)
				tr += c.r; tg += c.g; tb += c.b; count += 1
	if count == 0:
		return Color.BLACK
	return Color(tr / float(count), tg / float(count), tb / float(count))
