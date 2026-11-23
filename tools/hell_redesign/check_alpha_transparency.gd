@tool
extends SceneTree

func _init() -> void:
	var files := [
		"res://assets/environments/hell/architecture/chains/hell_cavern_ceiling_chains.png",
		"res://assets/environments/hell/architecture/cages/hell_hanging_cage_skeleton.png",
		"res://assets/environments/hell/architecture/banners/hell_skull_banner_left.png",
		"res://assets/environments/hell/architecture/banners/hell_skull_banner_right.png",
		"res://assets/environments/hell/foreground/decorations/hell_foreground_skulls_rocks.png"
	]
	print("--- CHECKING ALPHA TRANSPARENCY OF HELL ASSETS ---")
	for path in files:
		var img := Image.load_from_file(path)
		if not img:
			print("Could not load: ", path)
			continue
		var has_transparency := false
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				if img.get_pixel(x, y).a < 0.9:
					has_transparency = true
					break
			if has_transparency:
				break
		print("%s (%dx%d) - has transparency: %s" % [path.get_file(), img.get_width(), img.get_height(), has_transparency])
	quit(0)
