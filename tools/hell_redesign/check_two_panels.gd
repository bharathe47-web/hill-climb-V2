@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_blue_strips.png")
	img.convert(Image.FORMAT_RGBA8)

	# Check y=18..70 at x=1126..1288
	var panel1 := img.get_region(Rect2i(1100, 15, 200, 60))
	panel1.save_png("res://references/panel_upper.png")

	# Check y=86..145 at x=1100..1300
	var panel2 := img.get_region(Rect2i(1100, 86, 200, 60))
	panel2.save_png("res://references/panel_lower.png")

	print("Saved panel_upper.png and panel_lower.png")
	quit(0)
