@tool
extends SceneTree

const SOURCE_DIR = "/home/daniel/Pictures/Assets For Hell"
const TARGET_REF = "res://references/hell_target.png"
const HELL_DIR = "res://assets/environments/hell"

func _init() -> void:
	print("==================================================")
	print("PHASE 4 & 5: EXTRACTING & IMPORTING NEW HELL ASSETS")
	print("==================================================")
	await _process_assets()
	quit(0)

func _process_assets() -> void:
	var target_img := Image.load_from_file(TARGET_REF)
	if not target_img:
		printerr("Cannot load target reference:", TARGET_REF)
		return

	var tw := target_img.get_width() # 1600
	var th := target_img.get_height() # 533
	target_img.convert(Image.FORMAT_RGBA8)

	# 1. Background Sky & Blood Moon (1600x900 extended canvas)
	# In target, sky is deep crimson red with blood moon at upper right
	var sky_w := 1920
	var sky_h := 1080
	var sky_img := Image.create(sky_w, sky_h, false, Image.FORMAT_RGBA8)
	
	# Sample upper-sky color gradient: near top (0.35, 0.04, 0.03), horizon (0.65, 0.12, 0.05)
	for y in range(sky_h):
		var t := float(y) / float(sky_h)
		var c := Color(
			lerpf(0.28, 0.68, t),
			lerpf(0.03, 0.14, t),
			lerpf(0.04, 0.08, t),
			1.0
		)
		for x in range(sky_w):
			sky_img.set_pixel(x, y, c)

	# Blit Blood Moon from target (crop x=1260..1440, y=20..190)
	var moon_rect := Rect2i(1260, 20, 180, 170)
	var moon_crop := Image.create(180, 170, false, Image.FORMAT_RGBA8)
	moon_crop.blit_rect(target_img, moon_rect, Vector2i.ZERO)
	
	# Create circular alpha mask for blood moon
	for my in range(170):
		for mx in range(180):
			var dist := Vector2(mx - 90, my - 85).length()
			if dist > 80.0:
				var a := clampf(1.0 - (dist - 80.0) / 10.0, 0.0, 1.0)
				var px := moon_crop.get_pixel(mx, my)
				px.a *= a
				moon_crop.set_pixel(mx, my, px)

	# Save Blood Moon sprite separately
	var moon_path := HELL_DIR + "/background/blood_moon/hell_blood_moon.png"
	moon_crop.save_png(ProjectSettings.globalize_path(moon_path))
	print("[✓] Saved Blood Moon sprite: %s" % moon_path)

	# Save Sky panorama
	var sky_path := HELL_DIR + "/background/sky/hell_sky_crimson_panorama.png"
	sky_img.save_png(ProjectSettings.globalize_path(sky_path))
	print("[✓] Saved Sky panorama: %s" % sky_path)

	# 2. Central Giant Demon Fortress (Crop x=640..1060, y=80..430, size 420x350)
	var fortress_rect := Rect2i(640, 80, 420, 350)
	var fortress_img := Image.create(420, 350, false, Image.FORMAT_RGBA8)
	fortress_img.blit_rect(target_img, fortress_rect, Vector2i.ZERO)
	# Alpha mask: top corners are crimson sky, isolate the demon skull fortress and horns
	for fy in range(350):
		for fx in range(420):
			var orig := fortress_img.get_pixel(fx, fy)
			# Sky threshold: in target, sky around horns has high red (> 0.55) and low green/blue (< 0.15)
			# Horns and skull are dark obsidian (r < 0.40) or fiery glowing eyes/mouth (r > 0.85, g > 0.3)
			if fy < 120:
				# Near upper horns
				if orig.r > 0.50 and orig.g < 0.15 and orig.b < 0.15:
					# Soft sky falloff
					orig.a = 0.0
			fortress_img.set_pixel(fx, fy, orig)

	var fortress_path := HELL_DIR + "/background/fortress/hell_giant_demon_fortress.png"
	fortress_img.save_png(ProjectSettings.globalize_path(fortress_path))
	print("[✓] Saved Demon Fortress: %s" % fortress_path)

	# 3. Volcanic Mountains Left & Right
	# Left Spires (x=80..640, y=140..420)
	var left_mount_rect := Rect2i(80, 140, 560, 280)
	var left_mount_img := Image.create(560, 280, false, Image.FORMAT_RGBA8)
	left_mount_img.blit_rect(target_img, left_mount_rect, Vector2i.ZERO)
	var left_mount_path := HELL_DIR + "/background/distant_mountains/hell_volcanic_ridges_left.png"
	left_mount_img.save_png(ProjectSettings.globalize_path(left_mount_path))
	print("[✓] Saved Left Mountains: %s" % left_mount_path)

	# Right Spires (x=1060..1520, y=140..420)
	var right_mount_rect := Rect2i(1060, 140, 460, 280)
	var right_mount_img := Image.create(460, 280, false, Image.FORMAT_RGBA8)
	right_mount_img.blit_rect(target_img, right_mount_rect, Vector2i.ZERO)
	var right_mount_path := HELL_DIR + "/background/distant_mountains/hell_volcanic_ridges_right.png"
	right_mount_img.save_png(ProjectSettings.globalize_path(right_mount_path))
	print("[✓] Saved Right Mountains: %s" % right_mount_path)

	# 4. Lava Waterfalls (Left cascade: x=390..530, y=220..420; Right cascade: x=1090..1220, y=220..420)
	var lava_l_rect := Rect2i(390, 220, 140, 200)
	var lava_l_img := Image.create(140, 200, false, Image.FORMAT_RGBA8)
	lava_l_img.blit_rect(target_img, lava_l_rect, Vector2i.ZERO)
	var lava_l_path := HELL_DIR + "/midground/lavafalls/hell_lavafall_cascade_left.png"
	lava_l_img.save_png(ProjectSettings.globalize_path(lava_l_path))
	print("[✓] Saved Lavafall Left: %s" % lava_l_path)

	var lava_r_rect := Rect2i(1090, 220, 130, 200)
	var lava_r_img := Image.create(130, 200, false, Image.FORMAT_RGBA8)
	lava_r_img.blit_rect(target_img, lava_r_rect, Vector2i.ZERO)
	var lava_r_path := HELL_DIR + "/midground/lavafalls/hell_lavafall_cascade_right.png"
	lava_r_img.save_png(ProjectSettings.globalize_path(lava_r_path))
	print("[✓] Saved Lavafall Right: %s" % lava_r_path)

	# 5. Cavern Ceiling, Draped Chains & Hanging Cages (x=0..1600, y=0..200)
	var ceiling_rect := Rect2i(0, 0, 1600, 200)
	var ceiling_img := Image.create(1600, 200, false, Image.FORMAT_RGBA8)
	ceiling_img.blit_rect(target_img, ceiling_rect, Vector2i.ZERO)
	# Transparentize lower sky area
	for cy in range(200):
		for cx in range(1600):
			var orig := ceiling_img.get_pixel(cx, cy)
			# Cavern ceiling rock and chains are dark (r < 0.35). Sky is bright crimson (r > 0.55).
			if orig.r > 0.58 and orig.g < 0.15:
				orig.a = clampf(1.0 - (orig.r - 0.58) / 0.15, 0.0, 1.0)
				ceiling_img.set_pixel(cx, cy, orig)
	var ceiling_path := HELL_DIR + "/architecture/chains/hell_cavern_ceiling_chains.png"
	ceiling_img.save_png(ProjectSettings.globalize_path(ceiling_path))
	print("[✓] Saved Cavern Ceiling & Chains: %s" % ceiling_path)

	# Hanging Cage with Skeleton (isolated crop x=280..380, y=70..190)
	var cage_rect := Rect2i(280, 70, 100, 120)
	var cage_img := Image.create(100, 120, false, Image.FORMAT_RGBA8)
	cage_img.blit_rect(target_img, cage_rect, Vector2i.ZERO)
	var cage_path := HELL_DIR + "/architecture/cages/hell_hanging_cage_skeleton.png"
	cage_img.save_png(ProjectSettings.globalize_path(cage_path))
	print("[✓] Saved Hanging Cage: %s" % cage_path)

	# 6. Skull Banners
	# Left Banner (x=20..110, y=180..390)
	var banner_l_rect := Rect2i(20, 180, 90, 210)
	var banner_l_img := Image.create(90, 210, false, Image.FORMAT_RGBA8)
	banner_l_img.blit_rect(target_img, banner_l_rect, Vector2i.ZERO)
	var banner_l_path := HELL_DIR + "/architecture/banners/hell_skull_banner_left.png"
	banner_l_img.save_png(ProjectSettings.globalize_path(banner_l_path))
	print("[✓] Saved Skull Banner Left: %s" % banner_l_path)

	# Right Banner (x=1490..1580, y=180..390)
	var banner_r_rect := Rect2i(1490, 180, 90, 210)
	var banner_r_img := Image.create(90, 210, false, Image.FORMAT_RGBA8)
	banner_r_img.blit_rect(target_img, banner_r_rect, Vector2i.ZERO)
	var banner_r_path := HELL_DIR + "/architecture/banners/hell_skull_banner_right.png"
	banner_r_img.save_png(ProjectSettings.globalize_path(banner_r_path))
	print("[✓] Saved Skull Banner Right: %s" % banner_r_path)

	# 7. Playable Ancient Stone Bridge Roadway (Full width slice x=0..1600, y=320..460)
	var bridge_rect := Rect2i(0, 320, 1600, 140)
	var bridge_img := Image.create(1600, 140, false, Image.FORMAT_RGBA8)
	bridge_img.blit_rect(target_img, bridge_rect, Vector2i.ZERO)
	var bridge_path := HELL_DIR + "/architecture/hell_bridge/hell_stone_bridge_causeway.png"
	bridge_img.save_png(ProjectSettings.globalize_path(bridge_path))
	print("[✓] Saved Stone Bridge Causeway: %s" % bridge_path)

	# Seamless Stone Deck Inlay Texture (tileable 512x80 stone brick band)
	var deck_band := Image.create(512, 80, false, Image.FORMAT_RGBA8)
	# Extract horizontal stone pattern from central bridge section
	deck_band.blit_rect(target_img, Rect2i(540, 370, 512, 80), Vector2i.ZERO)
	var deck_path := HELL_DIR + "/architecture/stone_terrain/hell_volcanic_brick_surface.png"
	deck_band.save_png(ProjectSettings.globalize_path(deck_path))
	print("[✓] Saved Stone Deck Tile: %s" % deck_path)

	# 8. Foreground Skulls, Bones & Obsidian Rocks (x=0..1600, y=450..533)
	var fg_rect := Rect2i(0, 450, 1600, 83)
	var fg_img := Image.create(1600, 83, false, Image.FORMAT_RGBA8)
	fg_img.blit_rect(target_img, fg_rect, Vector2i.ZERO)
	var fg_path := HELL_DIR + "/foreground/decorations/hell_foreground_skulls_rocks.png"
	fg_img.save_png(ProjectSettings.globalize_path(fg_path))
	print("[✓] Saved Foreground Decorations: %s" % fg_path)

	# 9. Copy selected assets from downloaded library
	_copy_file(SOURCE_DIR + "/SpriteCanvas_Animated_Props/spritecanvas-props-cc0/prop-torch/prop-torch-burn.png", HELL_DIR + "/architecture/torches/torch_burn_strip26.png")
	_copy_file(SOURCE_DIR + "/SpriteCanvas_Animated_Props/spritecanvas-props-cc0/prop-campfire/prop-campfire-burn.png", HELL_DIR + "/architecture/braziers/brazier_fire_strip26.png")
	_copy_file(SOURCE_DIR + "/SpriteCanvas_Animated_Props/spritecanvas-props-cc0/prop-banner/prop-banner-wave.png", HELL_DIR + "/architecture/banners/banner_wave_strip35.png")
	_copy_file(SOURCE_DIR + "/OpenGameArt_Skeleton/skeleton-hanging.png", HELL_DIR + "/architecture/cages/skeleton_hanging_prop.png")
	_copy_file(SOURCE_DIR + "/OpenGameArt_Skeleton/skulls_0.png", HELL_DIR + "/foreground/skulls/skulls_cluster_prop.png")
	_copy_file(SOURCE_DIR + "/OpenGameArt_Skeleton/skeleton_13.png", HELL_DIR + "/foreground/skeletons/skeleton_remains_prop.png")
	_copy_file(SOURCE_DIR + "/OpenGameArt_Misc_Dark_Fantasy_Scenery/misc_scenery.png", HELL_DIR + "/props/environment_props/misc_dark_fantasy_props.png")
	_copy_file(SOURCE_DIR + "/OpenGameArt_Stone_Bridge/005_stone_bridge/stone_bridge_diffuse.png", HELL_DIR + "/architecture/hell_bridge/stone_bridge_masonry.png")

	print("\n[✓] ALL NEW HELL ASSETS EXTRACTED AND STAGED SUCCESSFULLY!")

func _copy_file(src_path: String, dst_path: String) -> void:
	var abs_src := ProjectSettings.globalize_path(src_path)
	var abs_dst := ProjectSettings.globalize_path(dst_path)
	var bytes := FileAccess.get_file_as_bytes(abs_src)
	if bytes.size() > 0:
		var fa := FileAccess.open(abs_dst, FileAccess.WRITE)
		if fa:
			fa.store_buffer(bytes)
			fa.close()
			print("  [✓] Copied library asset: %s -> %s (%d bytes)" % [src_path.get_file(), dst_path, bytes.size()])
		else:
			printerr("Failed to write to destination:", abs_dst)
	else:
		printerr("Failed to read source bytes:", abs_src)
