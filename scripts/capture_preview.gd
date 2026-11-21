extends SceneTree

func _init():
	print("--- RENDERING COMPREHENSIVE VISUAL PREVIEW OF INDIAN ROADS UPGRADE V2 ---")
	
	# Load assets preferentially from visual_upgrade_v2
	var bg_tex: Texture2D = _load_first([
		"res://assets/indian_roads/visual_upgrade_v2/indian_parallax_western_ghats.png",
		"res://assets/indian_roads/indian_parallax_western_ghats.png"
	])
	var asphalt_tex: Texture2D = _load_first([
		"res://assets/indian_roads/visual_upgrade_v2/indian_road_asphalt_straight.png",
		"res://assets/indian_roads/indian_road_asphalt_straight.png"
	])
	var meenakshi_tex: Texture2D = _load_first([
		"res://assets/indian_locations/visual_upgrade_v2/tamil_nadu_madurai_meenakshi_temple.png",
		"res://assets/indian_locations/tamil_nadu_madurai_meenakshi_temple.png"
	])
	var thiru_tex: Texture2D = _load_first([
		"res://assets/indian_locations/visual_upgrade_v2/tamil_nadu_thiruvalluvar_statue.png",
		"res://assets/indian_locations/tamil_nadu_thiruvalluvar_statue.png"
	])
	var vivek_tex: Texture2D = _load_first([
		"res://assets/indian_locations/visual_upgrade_v2/tamil_nadu_vivekananda_rock_memorial.png",
		"res://assets/indian_locations/tamil_nadu_vivekananda_rock_memorial.png"
	])
	var lighthouse_tex: Texture2D = _load_first([
		"res://assets/indian_locations/visual_upgrade_v2/tamil_nadu_chennai_marina_lighthouse.png",
		"res://assets/indian_locations/tamil_nadu_chennai_marina_lighthouse.png"
	])
	var rickshaw_tex: Texture2D = _load_first([
		"res://assets/indian_roads/visual_upgrade_v2/indian_roadside_auto_rickshaw.png",
		"res://assets/indian_roads/indian_roadside_auto_rickshaw.png"
	])
	var sign_tex: Texture2D = _load_first([
		"res://assets/indian_roads/visual_upgrade_v2/indian_road_sign_nh44.png",
		"res://assets/indian_roads/indian_road_sign_nh44.png"
	])
	var milestone_tex: Texture2D = _load_first([
		"res://assets/indian_roads/visual_upgrade_v2/indian_roadside_milestone_km.png",
		"res://assets/indian_roads/indian_roadside_milestone_km.png"
	])
	var tea_tex: Texture2D = _load_first([
		"res://assets/indian_roads/visual_upgrade_v2/indian_roadside_tea_stall.png",
		"res://assets/indian_roads/indian_roadside_tea_stall.png"
	])
	var dhaba_tex: Texture2D = _load_first([
		"res://assets/indian_roads/visual_upgrade_v2/indian_roadside_dhaba_stall.png",
		"res://assets/indian_roads/indian_roadside_dhaba_stall.png"
	])
	var palm_tex: Texture2D = _load_first([
		"res://assets/indian_roads/visual_upgrade_v2/indian_roadside_coconut_tree.png",
		"res://assets/indian_roads/indian_roadside_coconut_tree.png"
	])
	
	# Create 1280x720 canvas
	var canvas := Image.create(1280, 720, false, Image.FORMAT_RGBA8)
	canvas.fill(Color(0.2, 0.4, 0.7, 1.0))
	
	# 1. Background
	if bg_tex:
		var bg_img: Image = bg_tex.get_image()
		var scaled_bg := bg_img.duplicate()
		scaled_bg.resize(1280, 720, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect(scaled_bg, Rect2i(0, 0, 1280, 720), Vector2i.ZERO)
		
	# 2. Distant Landmarks (Marina Lighthouse & Vivekananda Memorial)
	if vivek_tex:
		var v_img: Image = vivek_tex.get_image()
		var vh := 220
		var vw: int = int(float(v_img.get_width()) * float(vh) / float(v_img.get_height()))
		v_img.resize(vw, vh, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(v_img, v_img, Rect2i(0, 0, vw, vh), Vector2i(20, 310))
		
	if lighthouse_tex:
		var lh_img: Image = lighthouse_tex.get_image()
		var lhh := 320
		var lhw: int = int(float(lh_img.get_width()) * float(lhh) / float(lh_img.get_height()))
		lh_img.resize(lhw, lhh, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(lh_img, lh_img, Rect2i(0, 0, lhw, lhh), Vector2i(1120, 210))

	# 3. Midground Palm Trees
	if palm_tex:
		var p_img: Image = palm_tex.get_image()
		var ph := 280
		var pw: int = int(float(p_img.get_width()) * float(ph) / float(p_img.get_height()))
		p_img.resize(pw, ph, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(p_img, p_img, Rect2i(0, 0, pw, ph), Vector2i(290, 250))
		canvas.blit_rect_mask(p_img, p_img, Rect2i(0, 0, pw, ph), Vector2i(850, 250))

	# 4. Foreground Monuments: Thiruvalluvar Statue (x: 400) & Meenakshi Gopuram (x: 580)
	if thiru_tex:
		var t_img: Image = thiru_tex.get_image()
		var th := 380
		var tw: int = int(float(t_img.get_width()) * float(th) / float(t_img.get_height()))
		t_img.resize(tw, th, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(t_img, t_img, Rect2i(0, 0, tw, th), Vector2i(380, 150))
		
	if meenakshi_tex:
		var m_img: Image = meenakshi_tex.get_image()
		var mh := 420
		var mw: int = int(float(m_img.get_width()) * float(mh) / float(m_img.get_height()))
		m_img.resize(mw, mh, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(m_img, m_img, Rect2i(0, 0, mw, mh), Vector2i(580, 110))

	# 5. Road Surface (y = 530 to 720)
	if asphalt_tex:
		var asp_img: Image = asphalt_tex.get_image()
		for x_offset in range(0, 1280, 256):
			var scaled_asp := asp_img.duplicate()
			scaled_asp.resize(256, 190, Image.INTERPOLATE_LANCZOS)
			canvas.blit_rect(scaled_asp, Rect2i(0, 0, 256, 190), Vector2i(x_offset, 530))
			
	# Yellow road center stripes
	for sx in range(0, 1280, 70):
		for py in range(542, 546):
			for px in range(sx, mini(1280, sx + 40)):
				canvas.set_pixel(px, py, Color(1.0, 0.85, 0.2, 1.0))

	# 6. Roadside Props (Chai Stall, Dhaba, NH44 Sign, Auto-Rickshaw, Milestone)
	if tea_tex and dhaba_tex and sign_tex and rickshaw_tex and milestone_tex:
		var tea_img: Image = tea_tex.get_image()
		tea_img.resize(135, 112, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(tea_img, tea_img, Rect2i(0, 0, 135, 112), Vector2i(220, 420))
		
		var s_img: Image = sign_tex.get_image()
		s_img.resize(115, 144, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(s_img, s_img, Rect2i(0, 0, 115, 144), Vector2i(90, 390))

		var r_img: Image = rickshaw_tex.get_image()
		var rh: int = int(float(r_img.get_height()) * 140.0 / float(r_img.get_width()))
		r_img.resize(140, rh, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(r_img, r_img, Rect2i(0, 0, 140, rh), Vector2i(900, 440))
		
		var ms_img: Image = milestone_tex.get_image()
		ms_img.resize(60, 80, Image.INTERPOLATE_LANCZOS)
		canvas.blit_rect_mask(ms_img, ms_img, Rect2i(0, 0, 60, 80), Vector2i(1050, 452))
		
	canvas.save_png("res://docs/screenshots/indian_roads_gameplay_preview.png")
	print("✓ Successfully saved visual preview: docs/screenshots/indian_roads_gameplay_preview.png")
	quit(0)

func _load_first(paths: Array) -> Texture2D:
	for p in paths:
		if ResourceLoader.exists(p):
			var r = load(p)
			if r is Texture2D:
				return r
	return null
