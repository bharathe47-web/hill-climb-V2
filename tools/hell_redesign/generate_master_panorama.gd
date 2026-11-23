@tool
extends SceneTree

const TARGET_PATH = "res://references/hell_target.png"
const OUT_PATH = "res://assets/environments/hell/background/sky/hell_sky_crimson_panorama.png"

func _init() -> void:
	print("==================================================")
	print("GENERATING MASTER HELL PANORAMA (1920x720)")
	print("==================================================")
	_generate_panorama()
	quit(0)

func _generate_panorama() -> void:
	var target_img := Image.load_from_file(TARGET_PATH)
	if not target_img:
		printerr("Cannot load target image: ", TARGET_PATH)
		return
	target_img.convert(Image.FORMAT_RGBA8)

	var tw := target_img.get_width() # 1600
	var th := target_img.get_height() # 533

	var out_w := 1920
	var out_h := 720
	var out_img := Image.create(out_w, out_h, false, Image.FORMAT_RGBA8)

	var noise := FastNoiseLite.new()
	noise.seed = 666
	noise.frequency = 0.04

	# Dimensions and vertical offsets:
	# Canvas: 1920 x 720
	# Target sits at y_offset = 93, x_offset = 160
	var y_offset := 93
	var x_offset := 160

	# 1. First, create an inpainted version of target_img (1600x533) where the road band (y=330..435)
	# is replaced by continuous vertical lavafalls, molten chasm, and basalt rock faces.
	var clean_target := target_img.duplicate()

	for x in range(tw):
		# Sample above road at y=320, and below road at y=445
		var top_col := target_img.get_pixel(x, 320)
		var bot_col := target_img.get_pixel(x, 445)
		var is_lava := (top_col.r > 0.75 and top_col.g > 0.12) or (bot_col.r > 0.75 and bot_col.g > 0.12)

		for y in range(325, 445):
			var t := float(y - 325) / 120.0 # 0.0 to 1.0
			var n := noise.get_noise_2d(float(x) * 1.5, float(y) * 2.0) # -1..1

			var base_col: Color
			if is_lava:
				# Vertical cascading molten lava
				var lava_t := clampf(t + n * 0.15, 0.0, 1.0)
				base_col = top_col.lerp(bot_col, lava_t)
				# Add bright core streaks
				if absf(n) < 0.25:
					base_col = base_col.lerp(Color(1.0, 0.75, 0.20, 1.0), 0.35)
			else:
				# Basalt chasm rock with dark crimson volcanic tones
				var rock_t := clampf(t + n * 0.2, 0.0, 1.0)
				base_col = top_col.lerp(bot_col, rock_t)
				# Subtle stone texture variation
				var var_amt := n * 0.05
				base_col.r = clampf(base_col.r + var_amt, 0.15, 0.55)
				base_col.g = clampf(base_col.g + var_amt * 0.3, 0.03, 0.14)
				base_col.b = clampf(base_col.b + var_amt * 0.3, 0.03, 0.14)

			clean_target.set_pixel(x, y, base_col)

	# 2. Blit clean_target into out_img at (x_offset, y_offset) -> (160, 93)
	out_img.blit_rect(clean_target, Rect2i(0, 0, tw, th), Vector2i(x_offset, y_offset))

	# 3. Top extension: y = 0 to 92 (cavern ceiling, jagged stalactites, deep shadow)
	for x in range(out_w):
		var target_x: int = clampi(x - x_offset, 0, tw - 1)
		var edge_col: Color = clean_target.get_pixel(target_x, 0)
		for y in range(y_offset):
			var dist_from_edge := float(y_offset - 1 - y) # 0 at y=92, 92 at y=0
			var falloff := dist_from_edge / float(y_offset) # 0.0 at edge, 1.0 at y=0
			var n := noise.get_noise_2d(float(x) * 2.0, float(y) * 1.5)

			# Dark cavern rock fading into deep burgundy-black shadow
			var top_col: Color = edge_col
			# Add jagged stalactite silhouettes
			var stalactite_len := 25.0 + n * 35.0 # can reach down 60px
			if dist_from_edge > (y_offset - stalactite_len):
				# Stalactite rock
				top_col = Color(0.18, 0.03, 0.04, 1.0).lerp(edge_col, 0.4)
			else:
				# Deep cavern roof
				var shadow_t := clampf(falloff + (n * 0.1), 0.0, 1.0)
				top_col = edge_col.lerp(Color(0.12, 0.02, 0.03, 1.0), shadow_t * 0.75)

			out_img.set_pixel(x, y, top_col)

	# 4. Bottom extension: y = 626 to 719 (molten magma lake, bubbling lava, abyss)
	var bottom_start_y := y_offset + th # 93 + 533 = 626
	for x in range(out_w):
		var target_x: int = clampi(x - x_offset, 0, tw - 1)
		var edge_col: Color = clean_target.get_pixel(target_x, th - 1)
		var is_magma: bool = (edge_col.r > 0.6 and edge_col.g > 0.08)

		for y in range(bottom_start_y, out_h):
			var dist := float(y - bottom_start_y)
			var t := dist / float(out_h - bottom_start_y) # 0.0 to 1.0
			var n := noise.get_noise_2d(float(x) * 1.8, float(y) * 2.5)

			var bot_col: Color
			if is_magma:
				# Bubbling molten magma abyss
				var magma_glow: Color = Color(0.98, 0.35, 0.05, 1.0).lerp(Color(1.0, 0.65, 0.12, 1.0), (n + 1.0) * 0.5)
				bot_col = edge_col.lerp(magma_glow, clampf(t * 0.6, 0.0, 1.0))
			else:
				# Dark volcanic rock shelves with magma seams
				var stone_base := Color(0.14, 0.03, 0.04, 1.0)
				if absf(n) < 0.15:
					# Magma fissure
					bot_col = Color(0.95, 0.30, 0.05, 1.0)
				else:
					bot_col = edge_col.lerp(stone_base, clampf(t * 0.8, 0.0, 1.0))

			out_img.set_pixel(x, y, bot_col)

	# 5. Left and Right horizontal extensions (x = 0..159 and x = 1760..1919)
	# Wrap from opposite sides to create continuous landscape
	for y in range(out_h):
		for lx in range(x_offset): # 0..159
			# Sample from right side of clean canvas (1600 - 160 + lx)
			var src_x := tw - x_offset + lx
			var target_y := clampi(y - y_offset, 0, th - 1)
			var col: Color
			if y < y_offset or y >= bottom_start_y:
				col = out_img.get_pixel(src_x + x_offset, y)
			else:
				col = clean_target.get_pixel(src_x, target_y)
			out_img.set_pixel(lx, y, col)

		for rx in range(x_offset): # 0..159 -> 1760..1919
			# Sample from left side of clean canvas (rx)
			var target_y := clampi(y - y_offset, 0, th - 1)
			var col: Color
			if y < y_offset or y >= bottom_start_y:
				col = out_img.get_pixel(rx + x_offset, y)
			else:
				col = clean_target.get_pixel(rx, target_y)
			out_img.set_pixel(x_offset + tw + rx, y, col)

	# 6. Smooth horizontal crossfade over blend zone (120 pixels) at edges x=0..119 and x=1800..1919
	# so that x=0 and x=1919 match 100% seamlessly for infinite Parallax mirroring
	var blend_w := 120
	for y in range(out_h):
		for bx in range(blend_w):
			var t := 0.5 - 0.5 * cos(PI * float(bx) / float(blend_w)) # 0.0 at bx=0, 1.0 at bx=blend_w
			var left_col := out_img.get_pixel(bx, y)
			var right_col := out_img.get_pixel(out_w - blend_w + bx, y)
			var blended := right_col.lerp(left_col, t)

			out_img.set_pixel(bx, y, blended)
			out_img.set_pixel(out_w - blend_w + bx, y, blended)

	# Ensure exact match at boundary
	for y in range(out_h):
		var edge := out_img.get_pixel(0, y)
		out_img.set_pixel(out_w - 1, y, edge)

	var abs_out := ProjectSettings.globalize_path(OUT_PATH)
	var err := out_img.save_png(abs_out)
	if err == OK:
		print("[✓] Successfully saved master panorama: %s (%dx%d)" % [OUT_PATH, out_w, out_h])
	else:
		printerr("Failed to save panorama, error code: ", err)
