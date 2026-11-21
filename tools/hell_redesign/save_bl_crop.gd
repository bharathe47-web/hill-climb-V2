@tool
extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/hell_cleanup_569m.png")
	if not img:
		quit(1)
		return
	var crop := Image.create(350, 160, false, Image.FORMAT_RGBA8)
	crop.blit_rect(img, Rect2i(20, 600, 350, 160), Vector2i.ZERO)
	crop.save_png(ProjectSettings.globalize_path("res://docs/hell_redesign/bottom_left_crop_569m.png"))
	print("Saved bottom_left_crop_569m.png (350x160)")
	quit(0)
