@tool
extends SceneTree

func _init() -> void:
	var paths := [
		"res://assets/environments/hell/terrain/volcanic_obsidian_spikes_cluster.png",
		"res://assets/environments/hell/terrain/volcanic_obsidian_spike_single.png"
	]
	for p in paths:
		print("\n==========================================")
		print(p)
		print("==========================================")
		var img := Image.load_from_file(p)
		if not img: continue
		img.convert(Image.FORMAT_RGBA8)
		var w := img.get_width()
		var h := img.get_height()
		print("Size: %dx%d" % [w, h])
		var step_x := maxi(1, w / 60)
		var step_y := maxi(1, h / 30)
		for y in range(0, h, step_y):
			var line := ""
			for x in range(0, w, step_x):
				var c := img.get_pixel(x, y)
				if c.a < 0.2:
					line += " "
				elif c.r > 0.6 and c.g > 0.2 and c.b < 0.3:
					line += "*"
				elif c.r < 0.2 and c.g < 0.2 and c.b < 0.2:
					line += "#"
				else:
					line += "."
			if line.strip_edges() != "":
				print(line)
	quit(0)
