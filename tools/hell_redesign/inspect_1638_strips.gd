@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_road_strips_1638.png")
	img.convert(Image.FORMAT_RGBA8)
	var w := img.get_width()
	var h := img.get_height()
	print("Latest screenshot size: %dx%d" % [w, h])

	# Let's check the road surface (y ≈ 400..600)
	# Check where monster truck is (typically x ≈ 250..450, y ≈ 380..520)
	# Behind monster truck: x ≈ 100..300, y ≈ 420..550
	var behind_truck := img.get_region(Rect2i(100, 420, 250, 100))
	behind_truck.save_png("res://references/behind_truck_1638.png")

	# Ahead on the right: x ≈ 600..1000, y ≈ 380..520
	var ahead_right := img.get_region(Rect2i(600, 380, 400, 140))
	ahead_right.save_png("res://references/ahead_right_1638.png")

	print("Saved behind_truck_1638.png and ahead_right_1638.png")
	quit(0)
