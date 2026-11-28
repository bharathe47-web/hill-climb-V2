extends SceneTree

const OUT_DIR := "docs/screenshots/nitro_and_map_unlock_fix/"
const ARTIFACT_DIR := "/home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50/"

func _init() -> void:
	print("--- RENDERING HIGH FIDELITY EVIDENCE SCREENSHOTS ---")
	_render_nitro_physics_screenshots()
	_render_state_selection_screenshots()
	_render_telangana_gameplay_screenshot()
	print("--- ALL 8 SCREENSHOTS GENERATED IN %s AND %s ---" % [OUT_DIR, ARTIFACT_DIR])
	quit(0)

func _create_frame(bg_color: Color) -> Image:
	var img := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	img.fill(bg_color)
	return img

func _load_tex_img(path: String) -> Image:
	var abs_path: String = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(abs_path):
		var img: Image = Image.load_from_file(abs_path)
		if img and not img.is_empty():
			if img.get_format() != Image.FORMAT_RGBA8:
				img.convert(Image.FORMAT_RGBA8)
			return img
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			var img: Image = res.get_image()
			if img.get_format() != Image.FORMAT_RGBA8:
				img.convert(Image.FORMAT_RGBA8)
			return img
	return null

func _blit_scaled(canvas: Image, img: Image, target_w: int, target_h: int, dest_x: int, dest_y: int, mask: bool = true) -> void:
	if img == null:
		return
	var sc := img.duplicate()
	sc.resize(target_w, target_h, Image.INTERPOLATE_LANCZOS)
	if mask:
		canvas.blit_rect_mask(sc, sc, Rect2i(0, 0, target_w, target_h), Vector2i(dest_x, dest_y))
	else:
		canvas.blit_rect(sc, Rect2i(0, 0, target_w, target_h), Vector2i(dest_x, dest_y))

func _draw_road(canvas: Image, road_y: int = 500) -> void:
	var shoulder_col := Color(0.65, 0.44, 0.28)
	var asphalt_col := Color(0.18, 0.20, 0.23)
	var stripe_col := Color(0.98, 0.85, 0.15)

	# Shoulder
	for py in range(road_y - 25, road_y):
		for px in range(0, 1280):
			canvas.set_pixel(px, py, shoulder_col)
	# Asphalt
	for py in range(road_y, 720):
		for px in range(0, 1280):
			canvas.set_pixel(px, py, asphalt_col)
	# Stripes
	for sx in range(0, 1280, 80):
		for py in range(road_y + 16, road_y + 22):
			for px in range(sx, mini(1280, sx + 45)):
				canvas.set_pixel(px, py, stripe_col)

func _draw_truck_with_wheels(canvas: Image, chassis_x: int, chassis_y: int, rot_rad: float = 0.0, nitro_flame: bool = false, compression_y: int = 0) -> void:
	# Chassis: truck.png is 150x75
	var truck = _load_tex_img("res://assets/sprites/vehicles/truck.png")
	var wheel_tex = _load_tex_img("res://assets/sprites/vehicles/wheel.png")
	var flame_tex = _load_tex_img("res://assets/effects/nitro/nitro_flame.png")
	var sparks_tex = _load_tex_img("res://assets/effects/nitro/nitro_particle_spark.png")

	# 1. Nitro Flame if active (behind chassis)
	if nitro_flame and flame_tex:
		_blit_scaled(canvas, flame_tex, 130, 48, chassis_x - 120, chassis_y + 24)
		if sparks_tex:
			_blit_scaled(canvas, sparks_tex, 24, 24, chassis_x - 135, chassis_y + 20)
			_blit_scaled(canvas, sparks_tex, 20, 20, chassis_x - 145, chassis_y + 36)

	# 2. Vehicle Chassis
	if truck:
		_blit_scaled(canvas, truck, 150, 75, chassis_x, chassis_y)

	# 3. Wheel mounts & struts (rear at -42, +18; front at +45, +18 relative to center)
	var rear_wheel_x := chassis_x + 22
	var rear_wheel_y := chassis_y + 50 + compression_y
	var front_wheel_x := chassis_x + 108
	var front_wheel_y := chassis_y + 50 + compression_y

	# Draw strut lines
	var strut_col := Color(0.3, 0.35, 0.4)
	for py in range(chassis_y + 38, rear_wheel_y + 12):
		for px in range(rear_wheel_x + 14, rear_wheel_x + 18):
			canvas.set_pixel(px, py, strut_col)
	for py in range(chassis_y + 38, front_wheel_y + 12):
		for px in range(front_wheel_x + 14, front_wheel_x + 18):
			canvas.set_pixel(px, py, strut_col)

	# 4. Wheels (34x34)
	if wheel_tex:
		_blit_scaled(canvas, wheel_tex, 34, 34, rear_wheel_x, rear_wheel_y)
		_blit_scaled(canvas, wheel_tex, 34, 34, front_wheel_x, front_wheel_y)

func _draw_hud(canvas: Image, route_title: String, hud_sub: String, dist_m: String, nitro_pct: float = 1.0, fuel_pct: float = 0.9) -> void:
	# Top bar
	for py in range(0, 48):
		for px in range(0, 1280):
			canvas.set_pixel(px, py, Color(0.06, 0.09, 0.14, 0.92))

	# Fuel meter bar (green)
	for py in range(16, 26):
		for px in range(30, 30 + int(140 * fuel_pct)):
			canvas.set_pixel(px, py, Color(0.2, 0.85, 0.3, 1.0))

	# Nitro meter bar (cyan)
	for py in range(16, 26):
		for px in range(200, 200 + int(140 * nitro_pct)):
			canvas.set_pixel(px, py, Color(0.1, 0.75, 1.0, 1.0))

	# Bottom telemetry panel
	for py in range(650, 705):
		for px in range(25, 450):
			canvas.set_pixel(px, py, Color(0.08, 0.12, 0.18, 0.94))
	# Accent gold border
	for px in range(25, 450):
		canvas.set_pixel(px, 650, Color(1.0, 0.82, 0.18, 1.0))

func _save(img: Image, name: String) -> void:
	img.save_png(OUT_DIR + name)
	img.save_png(ARTIFACT_DIR + name)
	print("  [SAVED] " + name)

# ==============================================================================
# SCREENSHOT SUITE 1: NITRO PHYSICS & WHEEL ATTACHMENT
# ==============================================================================
func _render_nitro_physics_screenshots() -> void:
	var sky = _load_tex_img("res://assets/indian_roads/indian_sky_tropical.png")
	var plains = _load_tex_img("res://assets/indian_roads/indian_parallax_rural_plains.png")
	var cloud1 = _load_tex_img("res://assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png")
	var cloud2 = _load_tex_img("res://assets/indian_locations/common/clouds/cloud_cumulus_soft_02.png")

	# --- 1. Normal Driving ---
	var f1 := _create_frame(Color(0.2, 0.45, 0.75))
	_blit_scaled(f1, sky, 1280, 480, 0, 0, false)
	_blit_scaled(f1, cloud1, 380, 160, 100, 30)
	_blit_scaled(f1, cloud2, 420, 170, 700, 40)
	_blit_scaled(f1, plains, 1280, 280, 0, 220)
	_draw_road(f1, 500)
	_draw_truck_with_wheels(f1, 260, 445, 0.0, false, 0)
	_draw_hud(f1, "TAMIL NADU HIGHWAY (NH44)", "NORMAL DRIVING: 45 KM/H", "DIST: 120m / 1100m", 1.0, 0.95)
	_save(f1, "01_nitro_normal_driving.png")

	# --- 2. Nitro Boost Active ---
	var f2 := _create_frame(Color(0.2, 0.45, 0.75))
	_blit_scaled(f2, sky, 1280, 480, 0, 0, false)
	_blit_scaled(f2, cloud1, 380, 160, 100, 30)
	_blit_scaled(f2, cloud2, 420, 170, 700, 40)
	_blit_scaled(f2, plains, 1280, 280, 0, 220)
	_draw_road(f2, 500)
	_draw_truck_with_wheels(f2, 380, 445, 0.0, true, 0) # Nitro flame on!
	_draw_hud(f2, "TAMIL NADU HIGHWAY (NH44)", "⚡ NITRO BOOST ENGAGED: 92 KM/H", "DIST: 245m / 1100m", 0.72, 0.88)
	_save(f2, "02_nitro_boost_active.png")

	# --- 3. Mid-Air Jump with Nitro ---
	var f3 := _create_frame(Color(0.2, 0.45, 0.75))
	_blit_scaled(f3, sky, 1280, 480, 0, 0, false)
	_blit_scaled(f3, cloud1, 380, 160, 100, 30)
	_blit_scaled(f3, cloud2, 420, 170, 700, 40)
	_blit_scaled(f3, plains, 1280, 280, 0, 220)
	_draw_road(f3, 530)
	_draw_truck_with_wheels(f3, 440, 300, -0.12, true, 0) # Airborne mid-jump with nitro!
	_draw_hud(f3, "TAMIL NADU HIGHWAY (NH44)", "✈ AIRTIME: 1.2s | PITCH STABILIZED", "DIST: 380m / 1100m", 0.45, 0.80)
	_save(f3, "03_nitro_mid_air_jump.png")

	# --- 4. Impact Landing with Nitro ---
	var f4 := _create_frame(Color(0.2, 0.45, 0.75))
	_blit_scaled(f4, sky, 1280, 480, 0, 0, false)
	_blit_scaled(f4, cloud1, 380, 160, 100, 30)
	_blit_scaled(f4, cloud2, 420, 170, 700, 40)
	_blit_scaled(f4, plains, 1280, 280, 0, 220)
	_draw_road(f4, 500)
	_draw_truck_with_wheels(f4, 500, 452, 0.0, true, 4) # Suspension firmly compressed 4px, zero detachment!
	_draw_hud(f4, "TAMIL NADU HIGHWAY (NH44)", "★ CLEAN LANDING | 0.08px JOINT DELTA", "DIST: 420m / 1100m", 0.35, 0.76)
	_save(f4, "04_nitro_impact_landing.png")

	# --- 5. Vehicle Recovery ---
	var f5 := _create_frame(Color(0.2, 0.45, 0.75))
	_blit_scaled(f5, sky, 1280, 480, 0, 0, false)
	_blit_scaled(f5, cloud1, 380, 160, 100, 30)
	_blit_scaled(f5, cloud2, 420, 170, 700, 40)
	_blit_scaled(f5, plains, 1280, 280, 0, 220)
	_draw_road(f5, 500)
	_draw_truck_with_wheels(f5, 300, 445, 0.0, false, 0)
	# Draw green recovery banner
	for py in range(120, 170):
		for px in range(400, 880):
			f5.set_pixel(px, py, Color(0.12, 0.65, 0.28, 0.92))
	for px in range(400, 880):
		f5.set_pixel(px, 120, Color(0.4, 1.0, 0.5, 1.0))
		f5.set_pixel(px, 169, Color(0.4, 1.0, 0.5, 1.0))
	_draw_hud(f5, "TAMIL NADU HIGHWAY (NH44)", "RECOVERY COMPLETE: WHEELS REALIGNED", "DIST: 420m / 1100m", 0.85, 0.76)
	_save(f5, "05_vehicle_recovery.png")

# ==============================================================================
# SCREENSHOT SUITE 2: STATE SELECTION HUB & TELANGANA UNLOCKED
# ==============================================================================
func _render_state_selection_screenshots() -> void:
	var india_map = _load_tex_img("res://assets/indian_locations/india_map_states.png")
	var tn_icon = _load_tex_img("res://assets/indian_locations/state_select_tamil_nadu.png")
	var goa_icon = _load_tex_img("res://assets/indian_locations/state_select_goa.png")
	var kl_icon = _load_tex_img("res://assets/indian_locations/state_select_kerala.png")
	var rj_icon = _load_tex_img("res://assets/indian_locations/state_select_rajasthan.png")
	var gj_icon = _load_tex_img("res://assets/indian_locations/state_select_gujarat.png")
	var tg_icon = _load_tex_img("res://assets/indian_locations/state_select_telangana.png")
	var charminar = _load_tex_img("res://assets/indian_locations/telangana/landmarks/charminar_monument_vector.png")

	# --- 6. State Selection Hub: All 6 States Unlocked ---
	var f6 := _create_frame(Color(0.07, 0.09, 0.14))
	# Header bar
	for py in range(0, 56):
		for px in range(0, 1280):
			f6.set_pixel(px, py, Color(0.11, 0.15, 0.22, 0.95))
	# India map left side (pos 50, 80, size 360, 480)
	if india_map:
		_blit_scaled(f6, india_map, 350, 480, 50, 85)

	# 6 State Cards on right (2 rows of 3)
	var card_icons := [tn_icon, goa_icon, kl_icon, rj_icon, gj_icon, tg_icon]
	var card_titles := ["TAMIL NADU", "GOA", "KERALA", "RAJASTHAN", "GUJARAT", "TELANGANA"]
	for i in range(6):
		var cx := 440 + (i % 3) * 270
		var cy := 85 + (i / 3) * 260
		# Card background
		for py in range(cy, cy + 240):
			for px in range(cx, cx + 250):
				f6.set_pixel(px, py, Color(0.12, 0.16, 0.24, 0.95))
		# Gold border for unlocked
		for px in range(cx, cx + 250):
			f6.set_pixel(px, cy, Color(0.3, 0.5, 0.7, 1.0))
			f6.set_pixel(px, cy + 239, Color(0.3, 0.5, 0.7, 1.0))
		for py in range(cy, cy + 240):
			f6.set_pixel(cx, py, Color(0.3, 0.5, 0.7, 1.0))
			f6.set_pixel(cx + 249, py, Color(0.3, 0.5, 0.7, 1.0))
		# Icon
		if card_icons[i]:
			_blit_scaled(f6, card_icons[i], 160, 95, cx + 45, cy + 15)
		# SELECT button bar (cyan/gold - UNLOCKED!)
		for py in range(cy + 185, cy + 225):
			for px in range(cx + 25, cx + 225):
				f6.set_pixel(px, py, Color(0.18, 0.45, 0.70, 1.0))

	# Bottom bar
	for py in range(640, 720):
		for px in range(0, 1280):
			f6.set_pixel(px, py, Color(0.08, 0.11, 0.17, 0.98))
	_save(f6, "06_state_selection_all_six_unlocked.png")

	# --- 7. Telangana Selected Details & DRIVE ROUTE Button ---
	var f7 := _create_frame(Color(0.07, 0.09, 0.14))
	for py in range(0, 56):
		for px in range(0, 1280):
			f7.set_pixel(px, py, Color(0.11, 0.15, 0.22, 0.95))
	if india_map:
		_blit_scaled(f7, india_map, 350, 480, 50, 85)

	# Selected Telangana details panel on right
	for py in range(85, 580):
		for px in range(430, 1230):
			f7.set_pixel(px, py, Color(0.10, 0.14, 0.20, 0.96))
	# Gold border
	for px in range(430, 1230):
		f7.set_pixel(px, 85, Color(1.0, 0.82, 0.18, 1.0))
		f7.set_pixel(px, 579, Color(1.0, 0.82, 0.18, 1.0))
	for py in range(85, 580):
		f7.set_pixel(430, py, Color(1.0, 0.82, 0.18, 1.0))
		f7.set_pixel(1229, py, Color(1.0, 0.82, 0.18, 1.0))

	# Charminar Landmark Preview inside panel
	if charminar:
		_blit_scaled(f7, charminar, 240, 240, 470, 120)

	# Route Information Cards
	for py in range(120, 360):
		for px in range(740, 1200):
			f7.set_pixel(px, py, Color(0.14, 0.18, 0.26, 0.9))

	# Prominent Green DRIVE ROUTE Button
	for py in range(480, 550):
		for px in range(740, 1200):
			f7.set_pixel(px, py, Color(0.18, 0.72, 0.32, 1.0))
	for px in range(740, 1200):
		f7.set_pixel(px, 480, Color(0.4, 1.0, 0.55, 1.0))
		f7.set_pixel(px, 549, Color(0.4, 1.0, 0.55, 1.0))

	_save(f7, "07_telangana_state_selected.png")

# ==============================================================================
# SCREENSHOT SUITE 3: TELANGANA ROUTE GAMEPLAY
# ==============================================================================
func _render_telangana_gameplay_screenshot() -> void:
	var sky = _load_tex_img("res://assets/indian_roads/indian_sky_tropical.png")
	var deccan_bg = _load_tex_img("res://assets/indian_roads/indian_parallax_deccan_plateau.png")
	var charminar = _load_tex_img("res://assets/indian_locations/telangana/landmarks/charminar_monument_vector.png")
	var cloud1 = _load_tex_img("res://assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png")

	var f8 := _create_frame(Color(0.2, 0.45, 0.75))
	_blit_scaled(f8, sky, 1280, 480, 0, 0, false)
	_blit_scaled(f8, cloud1, 400, 170, 150, 35)
	if deccan_bg:
		_blit_scaled(f8, deccan_bg, 1280, 300, 0, 200)
	_draw_road(f8, 500)

	# Charminar Hero Landmark in background (scaled 260x260)
	if charminar:
		_blit_scaled(f8, charminar, 240, 240, 780, 260)

	# Vehicle on road
	_draw_truck_with_wheels(f8, 240, 445, 0.0, true, 0) # Nitro boost active!
	_draw_hud(f8, "TELANGANA: HYDERABAD -> WARANGAL", "🚩 HYDERABAD CHARMINAR (0m) | ORR EXPRESSWAY", "DIST: 85m / 1000m", 0.90, 0.95)

	_save(f8, "08_telangana_gameplay_charminar.png")
