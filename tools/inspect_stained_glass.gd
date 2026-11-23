@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/environments/heaven/architecture/heaven_arch_stained_glass.png")
	print("Stained glass size: ", img.get_size(), " format: ", img.get_format())
	# Check where non-transparent pixels are
	var min_x = 999
	var max_x = -1
	var min_y = 999
	var max_y = -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.05:
				min_x = mini(min_x, x)
				max_x = maxi(max_x, x)
				min_y = mini(min_y, y)
				max_y = maxi(max_y, y)
	print("Non-transparent bbox: x=[%d, %d] (w=%d), y=[%d, %d] (h=%d)" % [
		min_x, max_x, max_x - min_x + 1,
		min_y, max_y, max_y - min_y + 1
	])
	quit(0)
