@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/forensic_debug/gameplay_clean_452m.png")
	var w = img.get_width()
	var h = img.get_height()

	# heaven_column_corinthian_gold.png has bright gold capital and base, and fluted white shaft
	# Let's search across x = 0..1279 at y = 200..360 for column pixels
	print("Searching for column positions in gameplay_clean_452m.png:")
	for x in range(0, w, 20):
		# Sample y = 250 (column shaft level)
		var c = img.get_pixel(x, 250)
		# Fluted marble shaft is ivory white/gold: r > 0.85, g > 0.80, b > 0.70
		if c.r > 0.85 and c.g > 0.80 and c.b > 0.70 and c.r > c.b + 0.05:
			# Check if there is gold trim below (base) around y = 340..370
			for y_base in range(320, 420, 5):
				var c_base = img.get_pixel(x, y_base)
				# Gold base: r > 0.8, g > 0.6, b < 0.4
				if c_base.r > 0.8 and c_base.g > 0.6 and c_base.b < 0.45:
					print("  Potential column at screen X = %d (y_base=%d, col=rgba(%.2f, %.2f, %.2f))" % [
						x, y_base, c_base.r, c_base.g, c_base.b
					])
					break
	quit(0)
