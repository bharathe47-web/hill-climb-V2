@tool
extends SceneTree

func _init() -> void:
	print("--- GENERATING HIGH-FIDELITY VOLCANIC MASONRY TEXTURES ---")
	_create_brick_surface()
	_create_bridge_masonry()
	_create_bridge_arch()
	print("--- FINISHED GENERATING MASONRY TEXTURES ---")
	quit(0)

func _create_brick_surface() -> void:
	var w := 512
	var h := 128
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)

	var block_w := 64
	var block_h := 28
	var noise := FastNoiseLite.new()
	noise.seed = 1337
	noise.frequency = 0.08

	for y in range(h):
		var row := int(y / block_h)
		var row_y := y % block_h
		var row_offset := (row % 2) * (block_w / 2)

		for x in range(w):
			var bx := (x + row_offset) % block_w
			var col := int((x + row_offset) / block_w)

			# Distance to block mortar seam
			var dist_to_h_seam := mini(row_y, block_h - 1 - row_y)
			var dist_to_v_seam := mini(bx, block_w - 1 - bx)
			var dist_to_seam := mini(dist_to_h_seam, dist_to_v_seam)

			var n := noise.get_noise_2d(float(x), float(y)) # -1..1

			if dist_to_seam <= 1:
				# Glowing molten magma mortar crack
				var magma_t := clampf((n + 1.0) * 0.5, 0.0, 1.0)
				var crack_col := Color(0.98, 0.28, 0.05, 1.0).lerp(Color(1.0, 0.65, 0.12, 1.0), magma_t)
				img.set_pixel(x, y, crack_col)
			elif dist_to_seam == 2:
				# Molten heated border glow
				var glow_col := Color(0.75, 0.18, 0.08, 1.0)
				img.set_pixel(x, y, glow_col)
			else:
				# Dark reddish-brown volcanic stone block body
				var stone_var := (n * 0.06) + (float((col * 17 + row * 23) % 11) / 100.0)
				var r := clampf(0.28 + stone_var, 0.18, 0.38)
				var g := clampf(0.09 + stone_var * 0.4, 0.05, 0.14)
				var b := clampf(0.08 + stone_var * 0.4, 0.04, 0.13)
				var stone_col := Color(r, g, b, 1.0)

				# Top fire-lit rim on upper surface (y < 4)
				if y < 4:
					var rim_t := float(y) / 4.0
					stone_col = Color(1.0, 0.55, 0.15, 1.0).lerp(stone_col, rim_t)

				img.set_pixel(x, y, stone_col)

	var path := "res://assets/environments/hell/architecture/stone_terrain/hell_volcanic_brick_surface.png"
	img.save_png(ProjectSettings.globalize_path(path))
	print("[✓] Generated hell_volcanic_brick_surface.png (%dx%d)" % [w, h])

func _create_bridge_masonry() -> void:
	var w := 512
	var h := 512
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)

	var block_w := 64
	var block_h := 32
	var noise := FastNoiseLite.new()
	noise.seed = 2048
	noise.frequency = 0.06

	for y in range(h):
		var row := int(y / block_h)
		var row_y := y % block_h
		var row_offset := (row % 2) * (block_w / 2)

		for x in range(w):
			var bx := (x + row_offset) % block_w
			var col := int((x + row_offset) / block_w)

			var dist_to_h := mini(row_y, block_h - 1 - row_y)
			var dist_to_v := mini(bx, block_w - 1 - bx)
			var dist := mini(dist_to_h, dist_to_v)

			var n := noise.get_noise_2d(float(x), float(y))

			if dist <= 1:
				var crack_col := Color(0.92, 0.25, 0.04, 1.0).lerp(Color(0.98, 0.52, 0.08, 1.0), (n + 1.0) * 0.5)
				img.set_pixel(x, y, crack_col)
			elif dist == 2:
				img.set_pixel(x, y, Color(0.65, 0.14, 0.06, 1.0))
			else:
				var stone_var := (n * 0.05) + (float((col * 13 + row * 19) % 9) / 100.0)
				var r := clampf(0.22 + stone_var, 0.14, 0.30)
				var g := clampf(0.08 + stone_var * 0.3, 0.04, 0.11)
				var b := clampf(0.07 + stone_var * 0.3, 0.03, 0.10)
				img.set_pixel(x, y, Color(r, g, b, 1.0))

	var path := "res://assets/environments/hell/architecture/hell_bridge/stone_bridge_masonry.png"
	img.save_png(ProjectSettings.globalize_path(path))
	print("[✓] Generated stone_bridge_masonry.png (%dx%d)" % [w, h])

func _create_bridge_arch() -> void:
	var w := 640
	var h := 280
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)

	var masonry_img := Image.load_from_file("res://assets/environments/hell/architecture/hell_bridge/stone_bridge_masonry.png")
	if not masonry_img:
		printerr("Cannot load stone_bridge_masonry.png")
		return
	masonry_img.convert(Image.FORMAT_RGBA8)
	var mw := masonry_img.get_width()
	var mh := masonry_img.get_height()

	var center_x := w * 0.5
	var arch_rx := 205.0
	var arch_ry := 175.0
	var arch_cy := float(h) + 12.0

	for y in range(h):
		for x in range(w):
			var smp_x := x % mw
			var smp_y := y % mh
			var stone_col := masonry_img.get_pixel(smp_x, smp_y)

			var dx := (float(x) - center_x) / arch_rx
			var dy := (float(y) - arch_cy) / arch_ry
			var dist_sq := dx * dx + dy * dy

			if dist_sq < 1.0:
				var edge_d := 1.0 - sqrt(dist_sq)
				if edge_d < 0.04:
					var a := clampf(edge_d / 0.04, 0.0, 1.0)
					stone_col = Color(1.0, 0.52, 0.10, 1.0).lerp(stone_col, a)
					stone_col.a = 1.0 - a
				else:
					stone_col.a = 0.0
			elif dist_sq < 1.06:
				var rim_t := (sqrt(dist_sq) - 1.0) / 0.06
				stone_col = Color(1.0, 0.55, 0.12, 1.0).lerp(stone_col, rim_t)
				stone_col.a = 1.0
			else:
				stone_col.a = 1.0

			if y < 8:
				stone_col = stone_col.darkened(0.15)

			img.set_pixel(x, y, stone_col)

	var path := "res://assets/environments/hell/architecture/hell_bridge/hell_volcanic_bridge_arch.png"
	img.save_png(ProjectSettings.globalize_path(path))
	print("[✓] Generated hell_volcanic_bridge_arch.png (%dx%d)" % [w, h])
