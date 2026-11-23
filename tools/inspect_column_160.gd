@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://assets/environments/heaven/architecture/heaven_viaduct_arch_cutout.png")
	print("Inspecting x=160 pixels:")
	for y in range(0, img.get_height(), 5):
		var col = img.get_pixel(160, y)
		if col.a > 0.05:
			print("  y=%3d: rgba(%.2f, %.2f, %.2f, %.2f)" % [y, col.r, col.g, col.b, col.a])
	quit(0)
