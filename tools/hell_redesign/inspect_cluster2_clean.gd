@tool
extends SceneTree

func _init() -> void:
	var img1 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 14-43-03.png")
	var img2 := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 15-38-29.png")
	img1.convert(Image.FORMAT_RGBA8)
	img2.convert(Image.FORMAT_RGBA8)

	var c1 := img1.get_region(Rect2i(275, 435, 135, 80))
	c1.save_png("res://references/cluster2_in_1443.png")
	print("Saved cluster2_in_1443.png")

	var c2 := img2.get_region(Rect2i(275, 435, 135, 80))
	c2.save_png("res://references/cluster2_in_1538.png")
	print("Saved cluster2_in_1538.png")

	quit(0)
