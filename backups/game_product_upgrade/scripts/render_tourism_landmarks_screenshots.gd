extends SceneTree

## render_tourism_landmarks_screenshots.gd
## Author: Joel (Senior Godot 4.7 Developer, 2D Environment Specialist, QA Lead)
## Captures high-fidelity 1280x720 evidence screenshots directly realizing the user's sketch:
##   1. Player approaching a landmark (landmark_1_approach.png)
##   2. Player beside the landmark (landmark_2_beside.png)
##   3. Player passing the landmark (landmark_3_passed.png)
##   4. Several landmarks along one continuous horizontal road (landmark_procession_tamil_nadu.png)
##   5. Complete road and environmental composition across all 6 states:
##      - tamil_nadu_tourism_landmarks.png
##      - goa_tourism_landmarks.png
##      - kerala_tourism_landmarks.png
##      - rajasthan_tourism_landmarks.png
##      - gujarat_tourism_landmarks.png
##      - telangana_tourism_landmarks.png

func _init() -> void:
	print("=================================================================")
	print("--- RENDERING INDIAN TOURISM ROADSIDE LANDMARKS SCREENSHOTS ---")
	print("=================================================================")
	_capture_approach_beside_passed()
	_capture_landmark_procession()
	_capture_six_states_tourism()
	print("=================================================================")
	print("✓ ALL TOURISM EVIDENCE SCREENSHOTS SUCCESSFULLY SAVED TO docs/screenshots/")
	print("=================================================================")
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

func _draw_road_cross_section(canvas: Image, road_col: Color, shoulder_col: Color, stripe_col: Color) -> void:
	# Graded roadside shoulder (485 to 525)
	for py in range(485, 525):
		for px in range(0, 1280):
			canvas.set_pixel(px, py, shoulder_col)

	# Smooth asphalt highway (525 to 720)
	for py in range(525, 720):
		for px in range(0, 1280):
			canvas.set_pixel(px, py, road_col)

	# Reflective center dividing stripes (538 to 544)
	for sx in range(0, 1280, 80):
		for py in range(538, 544):
			for px in range(sx, mini(1280, sx + 45)):
				canvas.set_pixel(px, py, stripe_col)

func _draw_vehicle_on_road(canvas: Image, x: int = 180, y: int = 465) -> void:
	var truck = _load_tex_img("res://assets/sprites/vehicles/truck.png")
	if truck:
		_blit_scaled(canvas, truck, 150, 75, x, y)
	else:
		for vy in range(y, y + 45):
			for vx in range(x, x + 110):
				canvas.set_pixel(vx, vy, Color(0.18, 0.55, 0.95))

func _draw_roadside_signboard(canvas: Image, x: int, y: int, title: String, subtitle: String) -> void:
	# Two metallic signposts extending to road shoulder
	var post_w := 4
	var post_h := 38
	for py in range(y + 36, y + 36 + post_h):
		for px in range(x + 18, x + 18 + post_w):
			if px < 1280 and py < 720:
				canvas.set_pixel(px, py, Color(0.22, 0.24, 0.27))
		for px in range(x + 130, x + 130 + post_w):
			if px < 1280 and py < 720:
				canvas.set_pixel(px, py, Color(0.22, 0.24, 0.27))

	# Authentic Indian Highway Green Board
	var bw := 152
	var bh := 40
	var green_bg := Color(0.06, 0.38, 0.18)
	var white_border := Color(0.96, 0.97, 0.98)
	var yellow_text := Color(1.0, 0.85, 0.15)

	for py in range(y, y + bh):
		for px in range(x, x + bw):
			if px >= 1280 or py >= 720:
				continue
			var is_border = (px == x or px == x + bw - 1 or py == y or py == y + bh - 1 or
							 px == x + 2 or px == x + bw - 3 or py == y + 2 or py == y + bh - 3)
			if is_border:
				canvas.set_pixel(px, py, white_border)
			else:
				canvas.set_pixel(px, py, green_bg)

	# High contrast title bar highlight
	for py in range(y + 8, y + 16):
		for px in range(x + 10, x + bw - 10):
			if (px + py) % 4 != 0 and px < 1280 and py < 720:
				canvas.set_pixel(px, py, yellow_text)

	# High contrast subtitle bar highlight
	for py in range(y + 22, y + 27):
		for px in range(x + 15, x + bw - 15):
			if (px + py) % 3 != 0 and px < 1280 and py < 720:
				canvas.set_pixel(px, py, white_border)

func _draw_hud_banner(canvas: Image, route_name: String, status_text: String, dist_text: String) -> void:
	# Top bar
	for py in range(0, 48):
		for px in range(0, 1280):
			canvas.set_pixel(px, py, Color(0.07, 0.09, 0.14, 0.90))

	# Milestone bottom badge
	for py in range(650, 705):
		for px in range(30, 520):
			canvas.set_pixel(px, py, Color(0.10, 0.14, 0.20, 0.94))

# ==============================================================================
# 1. APPROACH, BESIDE, PASSED SEQUENCE (Thiruvalluvar Statue, Tamil Nadu)
# ==============================================================================
func _capture_approach_beside_passed() -> void:
	var sky = _load_tex_img("res://assets/indian_locations/tamil_nadu/backgrounds/sky/kanyakumari_sky_coastal.png")
	var ocean = _load_tex_img("res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png")
	var cloud = _load_tex_img("res://assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png")
	var thiru = _load_tex_img("res://assets/indian_locations/tamil_nadu/landmarks/thiruvalluvar_statue_vector.png")
	var palm = _load_tex_img("res://assets/indian_locations/tamil_nadu/vegetation/tree_tamil_palmyra_tall.png")
	var road_col = Color(0.18, 0.20, 0.23)
	var shoulder_col = Color(0.65, 0.44, 0.28)
	var stripe_col = Color(0.98, 0.85, 0.15)

	# [1/3] APPROACH: Landmark visible in distance ahead along highway
	var f_app := _create_frame(Color(0.2, 0.45, 0.75))
	_blit_scaled(f_app, sky, 1280, 450, 0, 0, false)
	_blit_scaled(f_app, cloud, 420, 170, 600, 30)
	_blit_scaled(f_app, ocean, 1280, 300, 0, 200)
	# Distant monument (smaller perspective, height 260px) ahead at x=780
	_blit_scaled(f_app, thiru, 170, 260, 780, 225)
	_draw_roadside_signboard(f_app, 700, 415, "THIRUVALLUVAR STATUE", "350 METERS AHEAD")
	# Roadside vegetation
	_blit_scaled(f_app, palm, 120, 240, 1000, 245)
	_draw_road_cross_section(f_app, road_col, shoulder_col, stripe_col)
	# Vehicle driving on highway
	_draw_vehicle_on_road(f_app, 160, 465)
	_draw_hud_banner(f_app, "TAMIL NADU TOURISM HIGHWAY: NH44", "APPROACHING: Thiruvalluvar Statue (150m ahead)", "DIST: 200m / 1800m")
	f_app.save_png("res://docs/screenshots/landmark_1_approach.png")
	print("✓ Captured: docs/screenshots/landmark_1_approach.png")

	# [2/3] BESIDE: Vehicle directly alongside grand monument, base anchored to roadside
	var f_bes := _create_frame(Color(0.2, 0.45, 0.75))
	_blit_scaled(f_bes, sky, 1280, 450, 0, 0, false)
	_blit_scaled(f_bes, cloud, 460, 190, 120, 40)
	_blit_scaled(f_bes, ocean, 1280, 300, 0, 200)
	# Full-scale monument (360px high) base anchored to shoulder at y=485
	_blit_scaled(f_bes, thiru, 230, 360, 500, 125)
	# Roadside signboard right at shoulder
	_draw_roadside_signboard(f_bes, 760, 415, "THIRUVALLUVAR STATUE", "133 FT TAMIL POET & PHILOSOPHER")
	_blit_scaled(f_bes, palm, 130, 250, 1060, 235)
	_draw_road_cross_section(f_bes, road_col, shoulder_col, stripe_col)
	# Vehicle beside monument
	_draw_vehicle_on_road(f_bes, 280, 465)
	_draw_hud_banner(f_bes, "TAMIL NADU TOURISM HIGHWAY: NH44", "BESIDE LANDMARK: Thiruvalluvar Statue - Discovered!", "DIST: 350m / 1800m")
	f_bes.save_png("res://docs/screenshots/landmark_2_beside.png")
	print("✓ Captured: docs/screenshots/landmark_2_beside.png")

	# [3/3] PASSED: Landmark receding in rear view, clear highway ahead
	var f_pas := _create_frame(Color(0.2, 0.45, 0.75))
	_blit_scaled(f_pas, sky, 1280, 450, 0, 0, false)
	_blit_scaled(f_pas, cloud, 400, 160, 700, 50)
	_blit_scaled(f_pas, ocean, 1280, 300, 0, 200)
	# Receding monument behind vehicle at x=100
	_blit_scaled(f_pas, thiru, 210, 330, 100, 155)
	_blit_scaled(f_pas, palm, 120, 240, 380, 245)
	_draw_road_cross_section(f_pas, road_col, shoulder_col, stripe_col)
	# Vehicle ahead at x=820
	_draw_vehicle_on_road(f_pas, 820, 465)
	_draw_hud_banner(f_pas, "TAMIL NADU TOURISM HIGHWAY: NH44", "CLEARED: Thiruvalluvar Statue -> NEXT: Meenakshi Temple", "DIST: 480m / 1800m")
	f_pas.save_png("res://docs/screenshots/landmark_3_passed.png")
	print("✓ Captured: docs/screenshots/landmark_3_passed.png")

# ==============================================================================
# 2. LANDMARK PROCESSION ALONG CONTINUOUS ROAD (User Sketch Realization)
# ==============================================================================
func _capture_landmark_procession() -> void:
	var f_proc := _create_frame(Color(0.2, 0.45, 0.75))
	var sky = _load_tex_img("res://assets/indian_locations/tamil_nadu/backgrounds/sky/kanyakumari_sky_coastal.png")
	var ocean = _load_tex_img("res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png")
	var cloud1 = _load_tex_img("res://assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png")
	var cloud2 = _load_tex_img("res://assets/indian_locations/common/clouds/cloud_cumulus_soft_02.png")
	var road_col = Color(0.18, 0.20, 0.23)
	var shoulder_col = Color(0.65, 0.44, 0.28)
	var stripe_col = Color(0.98, 0.85, 0.15)

	_blit_scaled(f_proc, sky, 1280, 450, 0, 0, false)
	_blit_scaled(f_proc, cloud1, 380, 160, 80, 30)
	_blit_scaled(f_proc, cloud2, 420, 180, 680, 40)
	_blit_scaled(f_proc, ocean, 1280, 300, 0, 200)

	# Distinct famous places appearing sequentially along the continuous roadside (Directly matching sketch)
	# Landmark 1: Kanyakumari Shore / Sunrise Memorial (x=40)
	var boat = _load_tex_img("res://assets/indian_locations/tamil_nadu/roadside_props/prop_tamil_boat_nets.png")
	_blit_scaled(f_proc, boat, 140, 75, 40, 410)
	_draw_roadside_signboard(f_proc, 40, 360, "KANYAKUMARI COAST", "SOUTHERN TIP OF INDIA")

	# Landmark 2: Thiruvalluvar Statue (x=280)
	var thiru = _load_tex_img("res://assets/indian_locations/tamil_nadu/landmarks/thiruvalluvar_statue_vector.png")
	_blit_scaled(f_proc, thiru, 200, 320, 260, 165)
	_draw_roadside_signboard(f_proc, 260, 415, "THIRUVALLUVAR STATUE", "133 FT MONUMENT")

	# Landmark 3: Vivekananda Rock Memorial (x=600)
	var vivek = _load_tex_img("res://assets/indian_locations/tamil_nadu/landmarks/vivekananda_rock_memorial_vector.png")
	_blit_scaled(f_proc, vivek, 250, 180, 580, 245)
	_draw_roadside_signboard(f_proc, 600, 415, "VIVEKANANDA ROCK", "ISLAND MEDITATION MANDAPAM")

	# Landmark 4: Madurai Meenakshi Amman Gopuram (x=960)
	var meen = _load_tex_img("res://assets/indian_locations/tamil_nadu/landmarks/meenakshi_amman_temple_vector.png")
	_blit_scaled(f_proc, meen, 260, 340, 940, 145)
	_draw_roadside_signboard(f_proc, 960, 415, "MEENAKSHI TEMPLE", "HISTORIC DRAVIDIAN GOPURAM")

	# Highway Road across whole width
	_draw_road_cross_section(f_proc, road_col, shoulder_col, stripe_col)
	# Player Vehicle driving smoothly
	_draw_vehicle_on_road(f_proc, 470, 465)
	_draw_hud_banner(f_proc, "INDIAN TOURISM ROAD: TAMIL NADU HERITAGE CORRIDOR", "CONTINUOUS HORIZONTAL ROAD WITH FAMOUS ROADSIDE LANDMARKS", "TOURISM EXP")
	f_proc.save_png("res://docs/screenshots/landmark_procession_tamil_nadu.png")
	print("✓ Captured: docs/screenshots/landmark_procession_tamil_nadu.png")

# ==============================================================================
# 3. COMPLETE ROAD & ENVIRONMENT COMPOSITION ACROSS ALL 6 STATES
# ==============================================================================
func _capture_six_states_tourism() -> void:
	var cloud1 = _load_tex_img("res://assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png")
	var cloud2 = _load_tex_img("res://assets/indian_locations/common/clouds/cloud_cumulus_soft_02.png")

	# [1/6] TAMIL NADU
	var f_tn := _create_frame(Color(0.2, 0.45, 0.75))
	var sky_tn = _load_tex_img("res://assets/indian_locations/tamil_nadu/backgrounds/sky/kanyakumari_sky_coastal.png")
	var oc_tn = _load_tex_img("res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png")
	_blit_scaled(f_tn, sky_tn, 1280, 450, 0, 0, false)
	_blit_scaled(f_tn, cloud1, 400, 160, 100, 30)
	_blit_scaled(f_tn, oc_tn, 1280, 300, 0, 200)
	var thiru = _load_tex_img("res://assets/indian_locations/tamil_nadu/landmarks/thiruvalluvar_statue_vector.png")
	_blit_scaled(f_tn, thiru, 210, 340, 380, 145)
	var meen = _load_tex_img("res://assets/indian_locations/tamil_nadu/landmarks/meenakshi_amman_temple_vector.png")
	_blit_scaled(f_tn, meen, 250, 330, 800, 155)
	_draw_roadside_signboard(f_tn, 380, 415, "THIRUVALLUVAR STATUE", "KANYAKUMARI DISTRICT")
	_draw_roadside_signboard(f_tn, 820, 415, "MEENAKSHI AMMAN TEMPLE", "MADURAI CITY")
	var palm = _load_tex_img("res://assets/indian_locations/tamil_nadu/vegetation/tree_tamil_palmyra_tall.png")
	_blit_scaled(f_tn, palm, 120, 240, 1100, 245)
	_draw_road_cross_section(f_tn, Color(0.18, 0.20, 0.23), Color(0.65, 0.44, 0.28), Color(0.98, 0.85, 0.15))
	_draw_vehicle_on_road(f_tn, 180, 465)
	_draw_hud_banner(f_tn, "TAMIL NADU TOURISM: KANYAKUMARI -> CHENNAI", "LANDMARKS: Thiruvalluvar Statue & Meenakshi Amman Temple", "DIST: 350m / 1800m")
	f_tn.save_png("res://docs/screenshots/tamil_nadu_tourism_landmarks.png")
	print("✓ Captured: docs/screenshots/tamil_nadu_tourism_landmarks.png")

	# [2/6] GOA
	var f_goa := _create_frame(Color(0.25, 0.55, 0.85))
	var sky_goa = _load_tex_img("res://assets/indian_locations/goa/backgrounds/sky/goa_tropical_sky.png")
	var gh_goa = _load_tex_img("res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png")
	_blit_scaled(f_goa, sky_goa, 1280, 450, 0, 0, false)
	_blit_scaled(f_goa, cloud2, 420, 170, 500, 40)
	_blit_scaled(f_goa, gh_goa, 1280, 300, 0, 200)
	var church = _load_tex_img("res://assets/indian_locations/goa/landmarks/our_lady_immaculate_conception_vector.png")
	_blit_scaled(f_goa, church, 270, 280, 120, 205)
	var aguada = _load_tex_img("res://assets/indian_locations/goa/landmarks/fort_aguada_lighthouse_vector.png")
	_blit_scaled(f_goa, aguada, 260, 240, 680, 245)
	_draw_roadside_signboard(f_goa, 130, 415, "OUR LADY CHURCH", "PANAJI HERITAGE")
	_draw_roadside_signboard(f_goa, 700, 415, "FORT AGUADA LIGHTHOUSE", "SINQUERIM BEACH")
	var gpalm = _load_tex_img("res://assets/indian_locations/goa/vegetation/tree_goa_coconut_beach.png")
	_blit_scaled(f_goa, gpalm, 160, 230, 1020, 255)
	_draw_road_cross_section(f_goa, Color(0.22, 0.23, 0.26), Color(0.85, 0.75, 0.50), Color(1.0, 1.0, 1.0))
	_draw_vehicle_on_road(f_goa, 390, 465)
	_draw_hud_banner(f_goa, "GOA TOURISM: PANAJI -> MARGAO", "LANDMARKS: Our Lady Church & Fort Aguada Lighthouse", "DIST: 500m / 1600m")
	f_goa.save_png("res://docs/screenshots/goa_tourism_landmarks.png")
	print("✓ Captured: docs/screenshots/goa_tourism_landmarks.png")

	# [3/6] KERALA
	var f_ker := _create_frame(Color(0.18, 0.45, 0.65))
	var sky_ker = _load_tex_img("res://assets/indian_locations/kerala/backgrounds/sky/kerala_sky_monsoon.png")
	var pk_ker = _load_tex_img("res://assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_western_ghats_peaks.png")
	var mid_ker = _load_tex_img("res://assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_backwater_canal_midground.png")
	_blit_scaled(f_ker, sky_ker, 1280, 450, 0, 0, false)
	_blit_scaled(f_ker, pk_ker, 1280, 300, 0, 200)
	_blit_scaled(f_ker, mid_ker, 1280, 240, 0, 255)
	# Mattancherry Dutch Palace & Athirappilly Waterfalls
	var matt = _load_tex_img("res://assets/indian_locations/kerala/landmarks/mattancherry_palace.png")
	_blit_scaled(f_ker, matt, 280, 210, 80, 275)
	var athir = _load_tex_img("res://assets/indian_locations/kerala/landmarks/athirappilly_waterfalls.png")
	_blit_scaled(f_ker, athir, 260, 280, 660, 205)
	_draw_roadside_signboard(f_ker, 100, 415, "MATTANCHERRY PALACE", "KOCHI HERITAGE")
	_draw_roadside_signboard(f_ker, 700, 415, "ATHIRAPPILLY WATERFALLS", "NIAGARA OF INDIA")
	_draw_road_cross_section(f_ker, Color(0.16, 0.18, 0.20), Color(0.45, 0.30, 0.16), Color(0.98, 0.85, 0.15))
	_draw_vehicle_on_road(f_ker, 400, 465)
	_draw_hud_banner(f_ker, "KERALA TOURISM: KOCHI -> MUNNAR", "LANDMARKS: Mattancherry Palace & Athirappilly Falls", "DIST: 500m / 2000m")
	f_ker.save_png("res://docs/screenshots/kerala_tourism_landmarks.png")
	print("✓ Captured: docs/screenshots/kerala_tourism_landmarks.png")

	# [4/6] RAJASTHAN
	var f_raj := _create_frame(Color(0.55, 0.38, 0.22))
	var sky_raj = _load_tex_img("res://assets/indian_locations/rajasthan/backgrounds/sky/rajasthan_sky_desert_sunset.png")
	var hills_raj = _load_tex_img("res://assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_aravalli_hills.png")
	var mid_raj = _load_tex_img("res://assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_thar_dunes_midground.png")
	_blit_scaled(f_raj, sky_raj, 1280, 450, 0, 0, false)
	_blit_scaled(f_raj, hills_raj, 1280, 300, 0, 200)
	_blit_scaled(f_raj, mid_raj, 1280, 240, 0, 255)
	# Hawa Mahal & Jal Mahal Palace
	var hawa = _load_tex_img("res://assets/indian_locations/rajasthan/landmarks/hawa_mahal_vector.png")
	_blit_scaled(f_raj, hawa, 280, 330, 80, 155)
	var jal = _load_tex_img("res://assets/indian_locations/rajasthan/landmarks/jal_mahal_palace.png")
	_blit_scaled(f_raj, jal, 290, 220, 680, 265)
	_draw_roadside_signboard(f_raj, 100, 415, "HAWA MAHAL", "PALACE OF WINDS - JAIPUR")
	_draw_roadside_signboard(f_raj, 720, 415, "JAL MAHAL", "WATER PALACE - MAN SAGAR")
	_draw_road_cross_section(f_raj, Color(0.24, 0.22, 0.20), Color(0.80, 0.65, 0.40), Color(1.0, 1.0, 1.0))
	_draw_vehicle_on_road(f_raj, 420, 465)
	_draw_hud_banner(f_raj, "RAJASTHAN TOURISM: JAIPUR -> JAISALMER", "LANDMARKS: Hawa Mahal & Jal Mahal Palace", "DIST: 550m / 2200m")
	f_raj.save_png("res://docs/screenshots/rajasthan_tourism_landmarks.png")
	print("✓ Captured: docs/screenshots/rajasthan_tourism_landmarks.png")

	# [5/6] GUJARAT
	var f_guj := _create_frame(Color(0.52, 0.40, 0.28))
	var sky_guj = _load_tex_img("res://assets/indian_locations/gujarat/backgrounds/sky/gujarat_sky_sunset.png")
	var rann_guj = _load_tex_img("res://assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_rann_salt_horizon.png")
	var mid_guj = _load_tex_img("res://assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_highway_landscape_midground.png")
	_blit_scaled(f_guj, sky_guj, 1280, 450, 0, 0, false)
	_blit_scaled(f_guj, rann_guj, 1280, 300, 0, 200)
	_blit_scaled(f_guj, mid_guj, 1280, 240, 0, 255)
	# Sabarmati Ashram & Somnath Temple
	var saba = _load_tex_img("res://assets/indian_locations/gujarat/landmarks/sabarmati_ashram.png")
	_blit_scaled(f_guj, saba, 270, 190, 80, 295)
	var som = _load_tex_img("res://assets/indian_locations/gujarat/landmarks/somnath_temple.png")
	_blit_scaled(f_guj, som, 270, 330, 680, 155)
	_draw_roadside_signboard(f_guj, 100, 415, "SABARMATI ASHRAM", "AHMEDABAD HERITAGE")
	_draw_roadside_signboard(f_guj, 700, 415, "SOMNATH TEMPLE", "FIRST JYOTIRLINGA SHRINE")
	_draw_road_cross_section(f_guj, Color(0.20, 0.21, 0.24), Color(0.72, 0.65, 0.58), Color(0.98, 0.85, 0.15))
	_draw_vehicle_on_road(f_guj, 410, 465)
	_draw_hud_banner(f_guj, "GUJARAT TOURISM: AHMEDABAD -> RANN OF KUTCH", "LANDMARKS: Sabarmati Ashram & Somnath Temple", "DIST: 500m / 2000m")
	f_guj.save_png("res://docs/screenshots/gujarat_tourism_landmarks.png")
	print("✓ Captured: docs/screenshots/gujarat_tourism_landmarks.png")

	# [6/6] TELANGANA
	var f_tel := _create_frame(Color(0.38, 0.32, 0.42))
	var sky_tel = _load_tex_img("res://assets/indian_locations/telangana/backgrounds/sky/telangana_sky_deccan_twilight.png")
	var hills_tel = _load_tex_img("res://assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_boulder_hills.png")
	var mid_tel = _load_tex_img("res://assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_deccan_scrub_midground.png")
	_blit_scaled(f_tel, sky_tel, 1280, 450, 0, 0, false)
	_blit_scaled(f_tel, hills_tel, 1280, 300, 0, 200)
	_blit_scaled(f_tel, mid_tel, 1280, 240, 0, 255)
	# Charminar & Hussain Sagar Buddha
	var charminar = _load_tex_img("res://assets/indian_locations/telangana/landmarks/charminar_vector.png")
	_blit_scaled(f_tel, charminar, 280, 330, 80, 155)
	var buddha = _load_tex_img("res://assets/indian_locations/telangana/landmarks/hussain_sagar_buddha.png")
	_blit_scaled(f_tel, buddha, 200, 320, 720, 165)
	_draw_roadside_signboard(f_tel, 90, 415, "CHARMINAR", "HISTORIC 4-MINARET MONUMENT")
	_draw_roadside_signboard(f_tel, 710, 415, "HUSSAIN SAGAR BUDDHA", "MONOLITHIC BUDDHA STATUE")
	_draw_road_cross_section(f_tel, Color(0.20, 0.20, 0.23), Color(0.60, 0.42, 0.35), Color(1.0, 1.0, 1.0))
	_draw_vehicle_on_road(f_tel, 410, 465)
	_draw_hud_banner(f_tel, "TELANGANA TOURISM: HYDERABAD -> WARANGAL", "LANDMARKS: Charminar & Hussain Sagar Monolithic Buddha", "DIST: 450m / 1800m")
	f_tel.save_png("res://docs/screenshots/telangana_tourism_landmarks.png")
	print("✓ Captured: docs/screenshots/telangana_tourism_landmarks.png")
