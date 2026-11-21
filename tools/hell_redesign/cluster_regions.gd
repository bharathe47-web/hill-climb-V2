@tool
extends SceneTree

func _init() -> void:
	_cluster_blue_regions("res://references/hell_cleanup_569m.png")
	_cluster_blue_regions("res://references/hell_cleanup_600m.png")
	quit(0)

func _cluster_blue_regions(path: String) -> void:
	var img := Image.load_from_file(path)
	print("\n=======================================================")
	print("CLUSTERING BLUE REGIONS IN: ", path.get_file())
	print("=======================================================")
	var w := img.get_width()
	var h := img.get_height()

	# Downsample grid 16x16 to cluster fast
	var gw := w / 16
	var gh := h / 16
	var grid := []
	for gy in range(gh):
		var row := []
		for gx in range(gw):
			var has_blue := false
			for dy in range(16):
				for dx in range(16):
					var c := img.get_pixel(gx * 16 + dx, gy * 16 + dy)
					if c.b > 0.65 and c.b > c.r + 0.3 and c.b > c.g:
						has_blue = true
						break
				if has_blue:
					break
			row.append(has_blue)
		grid.append(row)

	# Connected components on grid
	var visited := []
	for gy in range(gh):
		var vrow := []
		for gx in range(gw):
			vrow.append(false)
		visited.append(vrow)

	var clusters := []
	for gy in range(gh):
		for gx in range(gw):
			if grid[gy][gx] and not visited[gy][gx]:
				var comp := []
				var queue := [Vector2i(gx, gy)]
				visited[gy][gx] = true
				while queue.size() > 0:
					var p: Vector2i = queue.pop_back()
					comp.append(p)
					for dy: int in [-1, 0, 1]:
						for dx: int in [-1, 0, 1]:
							var nx: int = p.x + dx
							var ny: int = p.y + dy
							if nx >= 0 and nx < gw and ny >= 0 and ny < gh:
								if grid[ny][nx] and not visited[ny][nx]:
									visited[ny][nx] = true
									queue.append(Vector2i(nx, ny))
				if comp.size() >= 2:
					var min_gx = gw; var max_gx = 0; var min_gy = gh; var max_gy = 0
					for cp in comp:
						min_gx = mini(min_gx, cp.x)
						max_gx = maxi(max_gx, cp.x)
						min_gy = mini(min_gy, cp.y)
						max_gy = maxi(max_gy, cp.y)
					clusters.append(Rect2i(min_gx * 16, min_gy * 16, (max_gx - min_gx + 1) * 16, (max_gy - min_gy + 1) * 16))

	print("Found %d distinct blue-marked regions:" % clusters.size())
	for i in range(clusters.size()):
		var r: Rect2i = clusters[i]
		# Find the center of this region
		var cx := r.position.x + r.size.x / 2
		var cy := r.position.y + r.size.y / 2
		print("  Region [%d]: rect=%s center=(%d, %d)" % [i + 1, str(r), cx, cy])
