@tool
class_name VerifyPhase24HeavenSignoff
extends SceneTree

const ARTIFACT_PREVIEWS_DIR = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"
const DOCS_PREVIEWS_DIR = "res://docs/previews"

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN HEAVEN FINAL VISUAL SIGN-OFF (PHASE 2.4) ---")
	print("=================================================================")
	await _run_verification()
	quit(0)

func _run_verification() -> void:
	DirAccess.make_dir_recursive_absolute(ARTIFACT_PREVIEWS_DIR)
	DirAccess.make_dir_recursive_absolute(DOCS_PREVIEWS_DIR)

	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed:
		printerr("Failed to load Game.tscn")
		return

	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var game: GameScene = packed.instantiate() as GameScene
	game.use_procedural_terrain = true
	vp.add_child(game)

	# Warm up frames for shaders, materials, and physics
	for f in range(25):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	# ---------------------------------------------------------------
	# 1. SIX AUTHORITATIVE GAMEPLAY SCREENSHOTS
	# ---------------------------------------------------------------
	var shots = [
		{"dist": 314.0, "name": "314m - Heaven Driving Roadway & Bridge", "file": "heaven_signoff_314m.png"},
		{"dist": 360.0, "name": "360m - Palace Colonnade & Rose Window", "file": "heaven_signoff_360m.png"},
		{"dist": 420.0, "name": "420m - Ceremonial Fountain Plaza", "file": "heaven_signoff_420m.png"},
		{"dist": 480.0, "name": "480m - Golden Portal Archway (Bay 3)", "file": "heaven_signoff_480m.png"},
		{"dist": 540.0, "name": "540m - Angel Monument Niche (Bay 4)", "file": "heaven_signoff_540m.png"},
		{"dist": 600.0, "name": "600m - Heaven-to-Hell Portal Boundary", "file": "heaven_signoff_600m.png"}
	]

	var captured_images: Dictionary = {}

	for s in shots:
		var target_dist: float = s["dist"]
		var world_x := game.start_x + (target_dist * 100.0)

		game.game_manager.update_distance(target_dist)
		if is_instance_valid(prog):
			prog.update_distance(target_dist)
		if is_instance_valid(gen):
			gen._update_generation(world_x + 3500.0)
			gen._update_culling(world_x)

		var surf_y := gen.get_surface_y_at_world_x(world_x) if is_instance_valid(gen) else 380.0
		if is_instance_valid(game.vehicle):
			var v := game.vehicle
			v.global_position = Vector2(world_x, surf_y - 42.0)
			v.rotation = 0.0
			v.linear_velocity = Vector2(0.0, 0.0)
			v.angular_velocity = 0.0

		if is_instance_valid(game.follow_camera):
			game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
			if game.follow_camera.has_method("reset_smoothing"):
				game.follow_camera.reset_smoothing()

		for f in range(12):
			await process_frame
			await physics_frame

		var img := vp.get_texture().get_image()
		assert(img and not img.is_empty(), "Captured image must not be empty for %s" % s["name"])
		var art_path := "%s/%s" % [ARTIFACT_PREVIEWS_DIR, s["file"]]
		var docs_path := "%s/%s" % [DOCS_PREVIEWS_DIR, s["file"]]
		img.save_png(art_path)
		img.save_png(docs_path)
		captured_images[s["dist"]] = img
		print("  [✓] Captured %s -> %s" % [s["name"], s["file"]])

	# ---------------------------------------------------------------
	# 2. PIXEL VERIFICATION AUDIT
	# ---------------------------------------------------------------
	print("\n--- RUNNING OBJECTIVE PIXEL VERIFICATION ---")

	# Check 2A: Verify 314m driving surface (Ivory Marble Roadway, zero countryside dirt/grass)
	var img_314: Image = captured_images[314.0]
	var ivory_road_pixels := 0
	var countryside_grass_pixels := 0
	var mainland_dirt_pixels := 0
	# Sample roadway strip ahead of vehicle (x: 550..950, y: 535..580)
	for y in range(535, 580):
		for x in range(550, 950):
			var col: Color = img_314.get_pixel(x, y)
			# Ivory marble roadway color: bright cream/champagne (R > 0.70, G > 0.70, B > 0.55)
			if col.r > 0.70 and col.g > 0.70 and col.b > 0.55:
				ivory_road_pixels += 1
			# Countryside grass color: dominant vivid green
			if col.g > col.r * 1.2 and col.g > 0.35:
				countryside_grass_pixels += 1
			# Mainland dirt color: dark reddish earthy brown
			if col.r > 0.25 and col.r < 0.55 and col.g < 0.27 and col.b < 0.20 and col.r > col.g * 1.5:
				mainland_dirt_pixels += 1
	print("  -> Road surface check at 314m: %d ivory pixels, %d grass pixels, %d mainland dirt pixels" % [ivory_road_pixels, countryside_grass_pixels, mainland_dirt_pixels])
	assert(ivory_road_pixels > 12000, "Road surface must have abundant ivory marble roadway pixels (got %d)" % ivory_road_pixels)
	assert(countryside_grass_pixels == 0, "Road surface must contain ZERO countryside grass pixels (got %d)" % countryside_grass_pixels)
	assert(mainland_dirt_pixels == 0, "Road surface must contain ZERO mainland dirt pixels (got %d)" % mainland_dirt_pixels)
	print("  ✓ Verified: Driving surface is authentic ivory marble, zero mainland dirt/grass leak.")

	# Check 2B: Verify 540m Angel Monument (Zero opaque black box artifact)
	var img_540: Image = captured_images[540.0]
	var black_box_pixels := 0
	# Sky zone above statue / monument niche (x: 500..850, y: 80..320)
	for y in range(80, 320):
		for x in range(500, 850):
			var col: Color = img_540.get_pixel(x, y)
			# An opaque black box pixel has col.a > 0.95 and col.r < 0.04 and col.g < 0.04 and col.b < 0.04
			if col.a > 0.95 and col.r < 0.04 and col.g < 0.04 and col.b < 0.04:
				black_box_pixels += 1
	print("  -> Black box check above Angel Monument at 540m: %d black pixels" % black_box_pixels)
	assert(black_box_pixels == 0, "Sky above Angel Monument must contain ZERO black box pixels (got %d)" % black_box_pixels)
	print("  ✓ Verified: Zero black particle artifacts in celestial sky.")

	# Check 2C: Verify 480m Bay 3 (Zero opaque flat white rectangle)
	var img_480: Image = captured_images[480.0]
	var flat_white_box_pixels := 0
	# Upper-right region (x: 800..1200, y: 60..280)
	for y in range(60, 280):
		for x in range(800, 1200):
			var col: Color = img_480.get_pixel(x, y)
			# A flat opaque white box artifact has R > 0.96, G > 0.96, B > 0.96 with zero color saturation
			if col.r > 0.97 and col.g > 0.97 and col.b > 0.97 and absf(col.r - col.b) < 0.01:
				flat_white_box_pixels += 1
	print("  -> Flat white box check at 480m: %d flat white pixels" % flat_white_box_pixels)
	assert(flat_white_box_pixels == 0, "Upper right at 480m must contain ZERO flat white box pixels (got %d)" % flat_white_box_pixels)
	print("  ✓ Verified: Zero flat white box artifacts (golden archway rendered).")

	# ---------------------------------------------------------------
	# 3. BOUNDARY CLAMPING & DECORATION PROFILE PURITY AUDIT
	# ---------------------------------------------------------------
	print("\n--- RUNNING BIOME BOUNDARY CLAMPING AUDIT ---")
	assert(is_instance_valid(gen), "TerrainGenerator must be valid")

	# Test exact segment boundaries across the 300m and 600m transitions
	var active_segs := gen.active_segments
	print("  Auditing %d active terrain segments in scene:" % active_segs.size())
	for seg in active_segs:
		var s_start: float = seg.start_world_x
		var s_end: float = seg.end_world_x
		var s_start_m := s_start / 100.0
		var s_end_m := s_end / 100.0
		var b_type: int = seg.biome_type

		print("    - Segment [%.1fm -> %.1fm] Biome: %d, Profile: %s, Floating: %s, Thickness: %.1f" % [
			s_start_m, s_end_m, b_type,
			seg.terrain_profile.profile_name if seg.terrain_profile else "null",
			str(seg.is_floating_platform),
			seg.platform_thickness
		])

		# Invariant: Segments starting in Heaven (300m..600m) must be floating platforms with 120 thickness
		if s_start_m >= 300.0 and s_end_m <= 600.0:
			assert(b_type == 1, "Segment in [300m, 600m] must be BiomeType.HEAVEN (got %d)" % b_type)
			assert(seg.is_floating_platform == true, "Heaven segment must be floating platform")
			assert(is_equal_approx(seg.platform_thickness, 120.0), "Heaven segment platform thickness must be 120.0 (got %.1f)" % seg.platform_thickness)
			assert(seg.terrain_profile != null and seg.terrain_profile.profile_name == "Heaven", "Heaven segment profile must be 'Heaven'")

		# Invariant: No segment may straddle across 300m (30000px) or 600m (60000px)
		if s_start_m < 300.0:
			assert(s_end_m <= 300.0, "Normal segment starting at %.1fm must not cross 300.0m boundary (ended at %.1fm)" % [s_start_m, s_end_m])
		elif s_start_m >= 300.0 and s_start_m < 600.0:
			assert(s_end_m <= 600.0, "Heaven segment starting at %.1fm must not cross 600.0m boundary (ended at %.1fm)" % [s_start_m, s_end_m])
	print("  ✓ Verified: Strictly zero boundary crossing; all segments clamp exactly at biome portals.")

	# ---------------------------------------------------------------
	# 4. NITRO HUD POSITIONING ACROSS ASPECT RATIOS
	# ---------------------------------------------------------------
	print("\n--- RUNNING NITRO HUD MULTI-ASPECT RATIO AUDIT ---")
	var hud_scene: PackedScene = load("res://scenes/ui/HUD.tscn")
	assert(hud_scene != null, "HUD.tscn must load")

	var aspect_ratios = [
		{"name": "16:9 Standard", "size": Vector2i(1280, 720)},
		{"name": "18:9 / 2:1 Wide", "size": Vector2i(1440, 720)},
		{"name": "19.5:9 Ultra-Wide Mobile", "size": Vector2i(1560, 720)},
		{"name": "20:9 Modern Flagship", "size": Vector2i(1600, 720)},
		{"name": "4:3 Tablet", "size": Vector2i(960, 720)}
	]

	for ar in aspect_ratios:
		var test_vp := SubViewport.new()
		test_vp.size = ar["size"]
		root.add_child(test_vp)

		var test_hud: Control = hud_scene.instantiate() as Control
		test_vp.add_child(test_hud)

		for f in range(2):
			await process_frame

		var nitro_btn: TextureButton = test_hud.find_child("NitroButton", true, false) as TextureButton
		var brake_btn: TextureButton = test_hud.find_child("BrakePedal", true, false) as TextureButton
		assert(nitro_btn != null, "NitroButton must exist in HUD")
		assert(brake_btn != null, "BrakePedal must exist in HUD")

		var nitro_rect := nitro_btn.get_global_rect()
		var brake_rect := brake_btn.get_global_rect()

		print("  Aspect [%s] Viewport: %dx%d" % [ar["name"], ar["size"].x, ar["size"].y])
		print("    BrakePedal: x=%.1f, y=%.1f, w=%.1f, h=%.1f" % [brake_rect.position.x, brake_rect.position.y, brake_rect.size.x, brake_rect.size.y])
		print("    NitroButton: x=%.1f, y=%.1f, w=%.1f, h=%.1f" % [nitro_rect.position.x, nitro_rect.position.y, nitro_rect.size.x, nitro_rect.size.y])

		# Invariant 1: NitroButton sits in bottom margin (y >= 540 in 720p height)
		assert(nitro_rect.position.y >= 540.0, "NitroButton must stay in bottom HUD bar (y=%.1f >= 540.0)" % nitro_rect.position.y)
		# Invariant 2: NitroButton is horizontally to the right of BrakePedal
		assert(nitro_rect.position.x >= brake_rect.end.x, "NitroButton must sit to the right of BrakePedal")
		# Invariant 3: Active driving line (y < 500) is 100% unobstructed by touch controls
		assert(nitro_rect.position.y >= 550.0 and nitro_rect.end.y <= 700.0, "NitroButton must stay strictly in the bottom control strip")

		test_vp.queue_free()

	print("  ✓ Verified: Nitro HUD button maintains perfect bottom-docked layout across 16:9, 18:9, 19.5:9, 20:9, and 4:3.")

	# ---------------------------------------------------------------
	# 5. HEAVEN CRASH AND CLEAN RETRY LIFECYCLE AUDIT
	# ---------------------------------------------------------------
	print("\n--- RUNNING HEAVEN CRASH & CLEAN RETRY LIFECYCLE AUDIT ---")
	if is_instance_valid(prog):
		prog.reset_progression()
		prog.update_distance(450.0)
	game.game_manager.update_distance(450.0)
	if is_instance_valid(host):
		host.apply_biome_state(WorldCycleSchedule.BiomeType.HEAVEN)
	for f in range(5):
		await process_frame
		await physics_frame
	assert(host.current_biome == WorldCycleSchedule.BiomeType.HEAVEN, "Must be in Heaven before crash")

	# Crash
	game.game_manager.finish_run("Simulated crash at 450m inside Heaven")
	for f in range(5):
		await process_frame

	# Trigger Retry
	if game.has_method("restart_game"):
		game.restart_game()
	else:
		game.game_manager.restart_run()

	for f in range(30):
		await process_frame
		await physics_frame

	assert(is_equal_approx(game.game_manager.current_distance, 0.0), "Restart must reset distance to 0.0m (got %.1f)" % game.game_manager.current_distance)
	assert(host.current_biome == WorldCycleSchedule.BiomeType.NORMAL_LAND, "Restart must reset active biome to NORMAL_LAND (got %d)" % host.current_biome)
	assert(host.heaven_environment.visible == false, "Heaven environment must be completely culled on restart")
	assert(host.normal_environment.visible == true, "Normal Land environment must be active on restart")

	# Capture restart screenshot
	var restart_img := vp.get_texture().get_image()
	restart_img.save_png("%s/heaven_signoff_retry_clean_normal.png" % ARTIFACT_PREVIEWS_DIR)
	restart_img.save_png("%s/heaven_signoff_retry_clean_normal.png" % DOCS_PREVIEWS_DIR)
	print("  ✓ Verified: Crash inside Heaven cleanly resets to 0m Normal Land countryside.")

	vp.queue_free()
	print("\n=================================================================")
	print("--- HEAVEN FINAL VISUAL SIGN-OFF COMPLETED WITH 100% SUCCESS ---")
	print("=================================================================")
