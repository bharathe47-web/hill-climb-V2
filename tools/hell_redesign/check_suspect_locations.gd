@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://docs/hell_redesign/qa_screenshots/hell_checkpoint_600m.png")
	img.convert(Image.FORMAT_RGBA8)
	print("Suspect pixel locations in 600m:")
	for y: int in range(350, 650):
		for x: int in range(img.get_width()):
			if y > 580 and (x < 260 or x > 1050): continue
			var c: Color = img.get_pixel(x, y)
			if c.r < 0.12 and c.g < 0.12 and c.b < 0.12:
				var has_orange := false
				for dy: int in [-2, 0, 2]:
					for dx: int in [-2, 0, 2]:
						var nx: int = x + dx
						var ny: int = y + dy
						if nx >= 0 and nx < img.get_width() and ny >= 0 and ny < img.get_height():
							var nc: Color = img.get_pixel(nx, ny)
							if nc.r > 0.75 and nc.g > 0.35 and nc.g < 0.65 and nc.b < 0.15:
								has_orange = true
								break
					if has_orange: break
				if has_orange:
					print("  (%d, %d)" % [x, y])
	quit(0)
