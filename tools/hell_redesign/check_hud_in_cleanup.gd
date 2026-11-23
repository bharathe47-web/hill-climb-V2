@tool
extends SceneTree

func _init() -> void:
	for tag in ["569m", "600m"]:
		var path := "res://references/hell_cleanup_%s.png" % tag
		var img := Image.load_from_file(path)
		if not img:
			continue
		# HUD distance is at top left, roughly x=50..250, y=20..80
		# Let's crop HUD area
		var hud_rect := Rect2i(40, 20, 250, 70)
		var crop := Image.create(hud_rect.size.x, hud_rect.size.y, false, Image.FORMAT_RGBA8)
		crop.blit_rect(img, hud_rect, Vector2i.ZERO)
		var out_p := "res://docs/hell_redesign/hud_%s.png" % tag
		crop.save_png(ProjectSettings.globalize_path(out_p))
		print("Saved HUD crop: ", out_p)
	quit(0)
