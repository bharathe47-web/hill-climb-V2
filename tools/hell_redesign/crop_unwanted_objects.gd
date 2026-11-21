@tool
extends SceneTree

func _init() -> void:
	_crop_regions("res://references/hell_cleanup_569m.png", "569m")
	_crop_regions("res://references/hell_cleanup_600m.png", "600m")
	quit(0)

func _crop_regions(path: String, tag: String) -> void:
	var img := Image.load_from_file(path)
	if not img:
		return
	img.convert(Image.FORMAT_RGBA8)

	# Expand the regions slightly to capture the enclosed object
	var regions = {
		"A_dragon_upper_right": Rect2i(1040, 40, 320, 160),
		"B_monster_or_creature": Rect2i(380, 410, 180, 140),
		"C_platforms_or_pads": Rect2i(60, 180, 340, 120),
		"D_obstacle_blocks_bottom": Rect2i(220, 580, 160, 180),
		"F_rock_fragments": Rect2i(100, 360, 120, 140)
	}

	for key in regions:
		var r: Rect2i = regions[key]
		# Ensure within bounds
		r.position.x = clampi(r.position.x, 0, img.get_width() - 1)
		r.position.y = clampi(r.position.y, 0, img.get_height() - 1)
		r.size.x = clampi(r.size.x, 1, img.get_width() - r.position.x)
		r.size.y = clampi(r.size.y, 1, img.get_height() - r.position.y)

		var crop := Image.create(r.size.x, r.size.y, false, Image.FORMAT_RGBA8)
		crop.blit_rect(img, r, Vector2i.ZERO)
		var out_path := "res://docs/hell_redesign/unwanted_%s_%s.png" % [tag, key]
		crop.save_png(ProjectSettings.globalize_path(out_path))
		print("Saved: ", out_path)
