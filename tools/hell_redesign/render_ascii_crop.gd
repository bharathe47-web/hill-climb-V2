@tool
extends SceneTree

func _init() -> void:
	print("--- INSPECTING CROP D & F ---")
	var crop_d := Image.load_from_file("res://docs/hell_redesign/unwanted_569m_D_obstacle_blocks_bottom.png")
	var crop_f := Image.load_from_file("res://docs/hell_redesign/unwanted_600m_F_rock_fragments.png")

	if crop_d:
		print("Crop D size: ", crop_d.get_size())
		# Render a downsampled ASCII representation (32x20)
		var dw := 32
		var dh := 20
		for y in range(dh):
			var line := ""
			for x in range(dw):
				var px := int(float(x) / float(dw) * crop_d.get_width())
				var py := int(float(y) / float(dh) * crop_d.get_height())
				var c := crop_d.get_pixel(px, py)
				# Check if blue line
				if c.b > 0.6 and c.b > c.r + 0.2:
					line += "#" # Blue annotation
				elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
					line += " " # Black
				elif c.r > 0.6 and c.g > 0.3:
					line += "*" # Orange/Bright
				elif c.r > 0.4:
					line += "." # Red/Brown
				else:
					line += "-"
			print(line)

	if crop_f:
		print("\nCrop F size: ", crop_f.get_size())
		var dw := 24
		var dh := 16
		for y in range(dh):
			var line := ""
			for x in range(dw):
				var px := int(float(x) / float(dw) * crop_f.get_width())
				var py := int(float(y) / float(dh) * crop_f.get_height())
				var c := crop_f.get_pixel(px, py)
				if c.b > 0.6 and c.b > c.r + 0.2:
					line += "#"
				elif c.r < 0.15 and c.g < 0.15 and c.b < 0.15:
					line += " "
				elif c.r > 0.6 and c.g > 0.3:
					line += "*"
				elif c.r > 0.4:
					line += "."
				else:
					line += "-"
			print(line)

	quit(0)
