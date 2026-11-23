@tool
extends SceneTree

func _init() -> void:
	print("Generating Hell Volcanic Bridge Arch cutout...")
	var arch_w := 640
	var arch_h := 280
	var arch_img := Image.create(arch_w, arch_h, false, Image.FORMAT_RGBA8)

	var masonry_img := Image.load_from_file("res://assets/environments/hell/architecture/hell_bridge/stone_bridge_masonry.png")
	if not masonry_img:
		printerr("Cannot load stone_bridge_masonry.png")
		quit(1)
		return
	masonry_img.convert(Image.FORMAT_RGBA8)
	var mw := masonry_img.get_width()
	var mh := masonry_img.get_height()

	var center_x := arch_w * 0.5
	var arch_radius_x := 195.0
	var arch_radius_y := 170.0
	var arch_center_y := float(arch_h) + 10.0

	for y in range(arch_h):
		for x in range(arch_w):
			# Sample masonry texture seamlessly
			var smp_x := x % mw
			var smp_y := y % mh
			var stone_col := masonry_img.get_pixel(smp_x, smp_y)
			# Dark volcanic grade tint: dark charcoal basalt with subtle crimson undertone
			stone_col.r = clampf(stone_col.r * 0.38 + 0.05, 0.0, 1.0)
			stone_col.g = clampf(stone_col.g * 0.32 + 0.02, 0.0, 1.0)
			stone_col.b = clampf(stone_col.b * 0.32 + 0.02, 0.0, 1.0)
			stone_col.a = 1.0

			# Semicircular arch cutout from the bottom
			var dx := (float(x) - center_x) / arch_radius_x
			var dy := (float(y) - arch_center_y) / arch_radius_y
			var dist_sq := dx * dx + dy * dy

			if dist_sq < 1.0:
				# Inside arch cutout -> transparent to reveal the lava abyss behind
				var edge_dist := 1.0 - sqrt(dist_sq)
				if edge_dist < 0.05:
					# Soft anti-aliased edge with faint molten orange glow
					var a := clampf((1.0 - sqrt(dist_sq)) / 0.05, 0.0, 1.0)
					stone_col = Color(0.95, 0.45, 0.1, 1.0).lerp(stone_col, a)
					stone_col.a = 1.0 - a
				else:
					stone_col.a = 0.0
			elif dist_sq < 1.06:
				# Glowing volcanic mortar rim along voussoirs
				var rim_t := (sqrt(dist_sq) - 1.0) / 0.06
				stone_col = Color(0.95, 0.40, 0.08, 1.0).lerp(stone_col, rim_t)

			# Top edge trim: slight dark fascia lip
			if y < 8:
				stone_col = stone_col.darkened(0.2)

			arch_img.set_pixel(x, y, stone_col)

	var out_path := "res://assets/environments/hell/architecture/hell_bridge/hell_volcanic_bridge_arch.png"
	var abs_out := ProjectSettings.globalize_path(out_path)
	arch_img.save_png(abs_out)
	print("[✓] Generated Hell bridge arch cutout: ", out_path)
	quit(0)
