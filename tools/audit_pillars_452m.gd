@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/forensic_debug/gameplay_clean_452m.png")
	if not img:
		printerr("Image not found")
		quit(0)
		return

	# In backup_before_heaven_smoothing, Column1 is at x=640 in layer.
	# At 452m, let's find columns in gameplay_clean_452m.png
	print("--- AUDITING VISUAL PILLARS IN GAMEPLAY_CLEAN_452M.PNG ---")
	for x in range(20, 1260, 20):
		# Look for column shaft at y = 250
		var c = img.get_pixel(x, 250)
		if c.r > 0.85 and c.g > 0.80 and c.b > 0.70 and c.r > c.b + 0.04:
			# Check vertical span
			var top_y = -1
			var bot_y = -1
			for y in range(50, 600, 5):
				var cy = img.get_pixel(x, y)
				if (cy.r > 0.80 and cy.g > 0.75 and cy.b > 0.65) or (cy.r > 0.75 and cy.g > 0.55 and cy.b < 0.45):
					if top_y == -1:
						top_y = y
					bot_y = y
			print("  Column found around X = %d: visible Y span = [%d, %d] (height = %d px)" % [
				x, top_y, bot_y, bot_y - top_y
			])

	quit(0)
