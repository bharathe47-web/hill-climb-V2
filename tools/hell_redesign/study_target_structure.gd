@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_target.png")
	var w := img.get_width() # 1600
	var h := img.get_height() # 533
	print("--- HELL TARGET FULL COMPOSITION STUDY ---")
	print("Dimensions: %dx%d" % [w, h])

	# Let's check left edge vs right edge:
	var edge_diff := 0.0
	for y in range(h):
		var cl := img.get_pixel(0, y)
		var cr := img.get_pixel(w - 1, y)
		edge_diff += abs(cl.r - cr.r) + abs(cl.g - cr.g) + abs(cl.b - cr.b)
	edge_diff /= float(h * 3)
	print("Left vs Right edge average color diff: %.4f" % edge_diff)

	# Let's check the road curve across the entire width:
	# Scan for the top edge of the dark stone bridge causeway
	# And the bottom edge of the bridge causeway
	var road_top_y := []
	var road_bot_y := []
	for x in range(0, w, 50):
		var top := -1
		var bot := -1
		for y in range(250, 480):
			var c := img.get_pixel(x, y)
			# Road is dark stone (low R, low G, low B compared to fiery red background)
			# Background red: r > 0.45, g < 0.20
			# Road stone: r < 0.25, g < 0.18, b < 0.20
			if top == -1 and c.r < 0.25 and c.g < 0.18 and c.b < 0.20:
				top = y
			if top != -1 and (c.r > 0.45 or y > 460):
				bot = y
				break
		road_top_y.append(top)
		road_bot_y.append(bot)

	print("Road top Y (every 50px across width): ", road_top_y)

	quit(0)
