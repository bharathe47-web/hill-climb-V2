extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_cyan_latest.png")
	
	# We want to see what is drawn in cluster 1, 2, 3, 4, 5
	var cluster_rects = [
		{"name": "Cluster 1 (HUD area?)", "rect": Rect2i(70, 150, 300, 100)},
		{"name": "Cluster 2 (Truck / Crate?)", "rect": Rect2i(230, 400, 230, 130)},
		{"name": "Cluster 3 (Road / Obstacle?)", "rect": Rect2i(220, 610, 140, 130)},
		{"name": "Cluster 4/5 (Top Right?)", "rect": Rect2i(1080, 80, 230, 60)}
	]
	
	for c in cluster_rects:
		print("\n====================", c.name, "====================")
		var r: Rect2i = c.rect
		# Render ASCII: . for background, # for annotation, @ for high contrast game content
		var step_x: int = maxi(1, r.size.x / 70)
		var step_y: int = maxi(1, r.size.y / 25)
		for y in range(r.position.y, r.end.y, step_y):
			var line := ""
			for x in range(r.position.x, r.end.x, step_x):
				var col := img.get_pixel(x, y)
				if col.b > 0.45 and (col.b - col.r) > 0.15 and (col.g > 0.35 or col.b > 0.6):
					line += "#" # Cyan/blue pen stroke!
				elif col.r > 0.8 and col.g > 0.8 and col.b > 0.8:
					line += "W" # White text/sprite
				elif col.r > 0.7 and col.g > 0.4:
					line += "o" # Orange/yellow
				elif col.r > 0.4:
					line += "r" # Red
				elif col.r < 0.15 and col.g < 0.15 and col.b < 0.15:
					line += "." # Dark
				else:
					line += " "
			print(line)
			
	quit(0)
