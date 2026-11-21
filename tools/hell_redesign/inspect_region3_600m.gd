@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_600m.png")
	# Inspect X=[120..170], Y=[380..470]
	var colors := {}
	for y in range(380, 470):
		for x in range(120, 170):
			var c := img.get_pixel(x, y)
			if not (c.b > 0.65 and c.b > c.r + 0.3 and c.b > c.g):
				var h := c.to_html(false)
				colors[h] = colors.get(h, 0) + 1
	var sorted_cols := colors.keys()
	sorted_cols.sort_custom(func(a, b): return colors[a] > colors[b])
	print("Region 3 in 600m top colors:")
	for i in range(mini(10, sorted_cols.size())):
		var h: String = sorted_cols[i]
		print("  #", h, ": ", colors[h])
	quit(0)
