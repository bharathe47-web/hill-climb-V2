extends SceneTree

func _init() -> void:
	print("--- RENDERING HIGH QUALITY GAMEPLAY PREVIEWS FOR ALL STATES ---")
	_render_kanyakumari()
	_render_goa()
	_render_kerala()
	_render_rajasthan()
	print("--- ALL STATE GAMEPLAY PREVIEWS RENDERED TO docs/screenshots/ ---")
	quit(0)

func _render_kanyakumari() -> void:
	var canvas := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.2, 0.45, 0.75, 1.0))

	# 1. Coastal Sky
	var sky = _load_img("res://assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/sky/kanyakumari_sky_coastal.png")
	if sky:
		sky.resize(1280, 450, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect(sky, Rect2i(0, 0, 1280, 450), Vector2i.ZERO)

	# 2. Ocean Horizon & Distant Hills
	var ocean = _load_img("res://assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png")
	if ocean:
		ocean.resize(1280, 320, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(ocean, ocean, Rect2i(0, 0, 1280, 320), Vector2i(0, 220))

	# 3. Tamil Village Row Midground
	var village = _load_img("res://assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/village/tamil_village_row.png")
	if village:
		village.resize(1280, 260, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(village, village, Rect2i(0, 0, 1280, 260), Vector2i(0, 290))

	# 4. Landmarks: Vivekananda Rock Memorial & Thiruvalluvar Statue & Glass Bridge
	var vivek = _load_img("res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/vivekananda_rock/vivekananda_rock_memorial.png")
	if vivek:
		var vw = 260
		var vh = int(float(vivek.get_height()) * vw / float(vivek.get_width()))
		vivek.resize(vw, vh, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(vivek, vivek, Rect2i(0, 0, vw, vh), Vector2i(40, 260))

	var glass = _load_img("res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/glass_bridge/kanyakumari_glass_bridge.png")
	if glass:
		var gw = 320
		var gh = int(float(glass.get_height()) * gw / float(glass.get_width()))
		glass.resize(gw, gh, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(glass, glass, Rect2i(0, 0, gw, gh), Vector2i(270, 280))

	var thiru = _load_img("res://assets/indian_locations/tamil_nadu/kanyakumari/landmarks/thiruvalluvar_statue/thiruvalluvar_statue.png")
	if thiru:
		var tw = 250
		var th = int(float(thiru.get_height()) * tw / float(thiru.get_width()))
		thiru.resize(tw, th, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(thiru, thiru, Rect2i(0, 0, tw, th), Vector2i(560, 140))

	# 5. Road Surface (Red laterite shoulder + asphalt)
	_draw_road(canvas, Color(0.18, 0.20, 0.23), Color(0.65, 0.44, 0.28), Color(0.98, 0.85, 0.15))

	# 6. Roadside Props
	var sign = _load_img("res://assets/indian_locations/tamil_nadu/kanyakumari/signs/road_sign_nh44.png")
	if sign:
		sign.resize(110, 140, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(sign, sign, Rect2i(0, 0, 110, 140), Vector2i(120, 410))

	var auto = _load_img("res://assets/indian_locations/tamil_nadu/kanyakumari/village_props/auto_rickshaw.png")
	if auto:
		var aw = 140
		var ah = int(float(auto.get_height()) * aw / float(auto.get_width()))
		auto.resize(aw, ah, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(auto, auto, Rect2i(0, 0, aw, ah), Vector2i(920, 450))

	canvas.save_png("res://docs/screenshots/kanyakumari_gameplay.png")
	print("✓ Saved docs/screenshots/kanyakumari_gameplay.png")

func _render_goa() -> void:
	var canvas := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.2, 0.5, 0.85, 1.0))

	# 1. Tropical Sky
	var sky = _load_img("res://assets/indian_locations/goa/backgrounds/sky/goa_tropical_sky.png")
	if sky:
		sky.resize(1280, 450, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect(sky, Rect2i(0, 0, 1280, 450), Vector2i.ZERO)

	# 2. Lush Western Ghats (Zero Snow)
	var ghats = _load_img("res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png")
	if ghats:
		ghats.resize(1280, 350, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(ghats, ghats, Rect2i(0, 0, 1280, 350), Vector2i(0, 180))

	# 3. Colourful Portuguese Village Row
	var village = _load_img("res://assets/indian_locations/goa/backgrounds/village/goa_portuguese_village_row.png")
	if village:
		village.resize(1280, 260, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(village, village, Rect2i(0, 0, 1280, 260), Vector2i(0, 290))

	# 4. Landmarks: Basilica of Bom Jesus & Calangute Beach
	var bom = _load_img("res://assets/indian_locations/goa/old_goa/basilica_of_bom_jesus.png")
	if bom:
		var bw = 320
		var bh = int(float(bom.get_height()) * bw / float(bom.get_width()))
		bom.resize(bw, bh, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(bom, bom, Rect2i(0, 0, bw, bh), Vector2i(480, 180))

	var church = _load_img("res://assets/indian_locations/goa/panaji/our_lady_immaculate_conception_church.png")
	if church:
		var cw = 300
		var ch = int(float(church.get_height()) * cw / float(church.get_width()))
		church.resize(cw, ch, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(church, church, Rect2i(0, 0, cw, ch), Vector2i(80, 190))

	# 5. Road Surface (Golden coastal sand shoulder + asphalt)
	_draw_road(canvas, Color(0.22, 0.23, 0.26), Color(0.85, 0.75, 0.50), Color(1.0, 1.0, 1.0))

	canvas.save_png("res://docs/screenshots/goa_gameplay.png")
	print("✓ Saved docs/screenshots/goa_gameplay.png")

func _render_kerala() -> void:
	var canvas := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.2, 0.5, 0.8, 1.0))

	var sky = _load_img("res://assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/sky/kanyakumari_sky_coastal.png")
	if sky:
		sky.resize(1280, 450, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect(sky, Rect2i(0, 0, 1280, 450), Vector2i.ZERO)

	var ghats = _load_img("res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png")
	if ghats:
		ghats.resize(1280, 350, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(ghats, ghats, Rect2i(0, 0, 1280, 350), Vector2i(0, 180))

	var boat = _load_img("res://assets/indian_locations/kerala/alleppey_houseboat_backwaters.png")
	if boat:
		var bw = 340
		var bh = int(float(boat.get_height()) * bw / float(boat.get_width()))
		boat.resize(bw, bh, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(boat, boat, Rect2i(0, 0, bw, bh), Vector2i(100, 240))

	var tea = _load_img("res://assets/indian_locations/kerala/munnar_tea_plantations.png")
	if tea:
		var tw = 360
		var th = int(float(tea.get_height()) * tw / float(tea.get_width()))
		tea.resize(tw, th, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(tea, tea, Rect2i(0, 0, tw, th), Vector2i(540, 230))

	_draw_road(canvas, Color(0.16, 0.18, 0.20), Color(0.45, 0.30, 0.16), Color(0.98, 0.85, 0.15))

	canvas.save_png("res://docs/screenshots/kerala_gameplay.png")
	print("✓ Saved docs/screenshots/kerala_gameplay.png")

func _render_rajasthan() -> void:
	var canvas := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.85, 0.70, 0.45, 1.0))

	var thar = _load_img("res://assets/indian_roads/indian_parallax_thar_desert.png")
	if thar:
		thar.resize(1280, 450, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect(thar, Rect2i(0, 0, 1280, 450), Vector2i.ZERO)

	var amber = _load_img("res://assets/indian_locations/rajasthan/amber_fort_gateway.png")
	if amber:
		var aw = 380
		var ah = int(float(amber.get_height()) * aw / float(amber.get_width()))
		amber.resize(aw, ah, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(amber, amber, Rect2i(0, 0, aw, ah), Vector2i(100, 170))

	var mehran = _load_img("res://assets/indian_locations/rajasthan/mehrangarh_fort_vista.png")
	if mehran:
		var mw = 380
		var mh = int(float(mehran.get_height()) * mw / float(mehran.get_width()))
		mehran.resize(mw, mh, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(mehran, mehran, Rect2i(0, 0, mw, mh), Vector2i(580, 160))

	_draw_road(canvas, Color(0.26, 0.27, 0.28), Color(0.86, 0.72, 0.44), Color(0.95, 0.80, 0.15))

	canvas.save_png("res://docs/screenshots/rajasthan_gameplay.png")
	print("✓ Saved docs/screenshots/rajasthan_gameplay.png")

func _draw_road(canvas: Image, road_col: Color, shoulder_col: Color, stripe_col: Color) -> void:
	# Shoulder (520 to 540)
	for py in range(510, 540):
		for px in range(0, 1280):
			canvas.set_pixel(px, py, shoulder_col)

	# Asphalt (540 to 720)
	for py in range(540, 720):
		for px in range(0, 1280):
			canvas.set_pixel(px, py, road_col)

	# Centre stripes
	for sx in range(0, 1280, 80):
		for py in range(550, 555):
			for px in range(sx, mini(1280, sx + 45)):
				canvas.set_pixel(px, py, stripe_col)

func _load_img(path: String) -> Image:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			var img: Image = res.get_image()
			if img.get_format() != Image.FORMAT_RGBA8:
				img.convert(Image.FORMAT_RGBA8)
			return img
	return null
