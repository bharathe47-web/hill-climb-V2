@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_target.png")
	var w := img.get_width()
	var h := img.get_height()

	print("Tracing bridge roadway in references/hell_target.png (1600x533):")
	var road_pts := PackedVector2Array()

	for x in range(0, w, 20):
		# Scan Y between 300 and 460
		# The bridge surface is the dark stone causeway below the lava falls / mountains
		# and above the bottom abyss.
		# Specifically, look for the top surface of the dark stone causeway:
		var surface_y := -1
		for y in range(320, 460):
			var c := img.get_pixel(x, y)
			# Look for the transition from background (brighter lava / red cliffs) to dark stone bridge
			# Background is reddish (r > 0.35), bridge stone is dark (r < 0.22, g < 0.15, b < 0.15)
			if c.r < 0.22 and c.g < 0.15 and c.b < 0.18:
				# Verify it stays dark for at least 8 pixels (bridge slab)
				var is_slab := true
				for dy in range(1, 8):
					if y + dy < h:
						var cy := img.get_pixel(x, y + dy)
						if cy.r > 0.35:
							is_slab = false
							break
				if is_slab:
					surface_y = y
					break

		if surface_y != -1:
			road_pts.append(Vector2(x, surface_y))

	print("Found %d road trace points:" % road_pts.size())
	for i in range(0, road_pts.size(), 4):
		var pt := road_pts[i]
		print("  x=%4d: y=%3d (relative=%.3f)" % [int(pt.x), int(pt.y), pt.y / float(h)])

	quit(0)
