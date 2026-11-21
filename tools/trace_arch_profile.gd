@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/environments/heaven/architecture/heaven_viaduct_arch_cutout.png")
	var w := img.get_width()
	var h := img.get_height()

	print("--- TRACING VIADUCT ARCH PROFILE ---")
	# For various X positions, find top-most opaque pixel, bottom-most opaque pixel of top arch ring, etc.
	for x in [0, 10, 20, 35, 36, 50, 100, 160, 240, 320, 400, 480, 540, 603, 604, 620, 630, 639]:
		var first_opaque = -1
		var first_transparent = -1
		var second_opaque = -1
		for y in range(h):
			var a = img.get_pixel(x, y).a
			if a > 0.1 and first_opaque == -1:
				first_opaque = y
			elif a < 0.1 and first_opaque != -1 and first_transparent == -1:
				first_transparent = y
			elif a > 0.1 and first_transparent != -1 and second_opaque == -1:
				second_opaque = y
		print("x=%3d | top_y=%s | opening_top_y=%s | opening_bottom_y=%s" % [
			x, str(first_opaque), str(first_transparent), str(second_opaque)
		])
	quit(0)
