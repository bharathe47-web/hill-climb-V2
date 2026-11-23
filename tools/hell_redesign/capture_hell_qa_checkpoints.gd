@tool
extends SceneTree

const HELL_TARGET_REF = "res://references/hell_target.png"
const OUT_DIR = "res://docs/hell_redesign/qa_screenshots"

func _init() -> void:
	print("==================================================")
	print("CAPTURING HELL BIOME REDESIGN QA CHECKPOINTS...")
	print("==================================================")
	await _run_captures()
	quit(0)

func _run_captures() -> void:
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

	# Initial warm up
	for f in range(30):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	var checkpoints = [569.0, 600.0, 650.0, 700.0, 750.0, 800.0, 850.0, 890.0]
	var captured_images: Dictionary = {}

	for dist_m in checkpoints:
		var dist_val: float = float(dist_m)
		var world_x: float = float(game.start_x) + (dist_val * 100.0)

		game.game_manager.update_distance(dist_val)
		game.game_manager.add_coins(int(dist_val * 10.0))

		if is_instance_valid(prog):
			prog.update_distance(dist_val)

		# Ensure Hell environment is exclusively active for Hell checkpoints
		if is_instance_valid(host):
			host.activate_biome_exclusive(WorldCycleSchedule.BiomeType.HELL)

		if is_instance_valid(gen):
			gen._update_generation(world_x + 4000.0)
			for enc in gen.active_encounters:
				if enc.has_method("isolate_route"):
					enc.isolate_route(WorldCycleSchedule.BiomeType.HELL)

		var surf_y: float = gen.get_surface_y_at_world_x(world_x) if is_instance_valid(gen) else 350.0
		var surf_y_ahead: float = gen.get_surface_y_at_world_x(world_x + 15.0) if is_instance_valid(gen) else surf_y
		var surf_y_behind: float = gen.get_surface_y_at_world_x(world_x - 15.0) if is_instance_valid(gen) else surf_y
		var local_slope: float = atan2(surf_y_ahead - surf_y_behind, 30.0)

		if is_instance_valid(game.vehicle):
			var v: Node2D = game.vehicle
			v.global_position = Vector2(world_x, surf_y - 45.0)
			v.rotation = local_slope
			if v is RigidBody2D:
				var rb := v as RigidBody2D
				rb.linear_velocity = Vector2.ZERO
				rb.angular_velocity = 0.0
			if "current_fuel" in v:
				v.set("current_fuel", 85.0)

		if is_instance_valid(game.hud) and game.hud.has_method("update_fuel"):
			game.hud.update_fuel(85.0, 100.0)
		if is_instance_valid(game.hud) and game.hud.has_method("update_nitro"):
			game.hud.update_nitro(90.0, 100.0)

		if is_instance_valid(game.follow_camera):
			game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
			if game.follow_camera.has_method("reset_smoothing"):
				game.follow_camera.reset_smoothing()

		# Render several frames so animations, shaders, and particle emitters settle
		for f in range(25):
			await process_frame
			await physics_frame

		var img: Image = vp.get_texture().get_image()
		if img and not img.is_empty():
			var out_file := "hell_checkpoint_%dm.png" % int(dist_m)
			var out_res := OUT_DIR + "/" + out_file
			var abs_out := ProjectSettings.globalize_path(out_res)
			img.save_png(abs_out)
			captured_images[dist_m] = img.duplicate()
			print("[✓] Saved QA checkpoint: %s (%dx%d)" % [out_res, img.get_width(), img.get_height()])
		else:
			printerr("Failed to grab image for checkpoint %fm" % dist_m)

	# Generate Master Side-by-Side Comparison (Target Reference vs 750m Redesigned Hell Biome)
	var target_img := Image.load_from_file(HELL_TARGET_REF)
	if target_img and captured_images.has(750.0):
		var game_img: Image = captured_images[750.0]
		var half_w := 1280
		var cmp_h := 720
		var cmp_w := half_w * 2 # 2560 x 720 True 16:9 Side-by-Side
		var cmp_img := Image.create(cmp_w, cmp_h, false, Image.FORMAT_RGBA8)

		# 1. Left side: Target reference at true 16:9
		target_img.convert(Image.FORMAT_RGBA8)
		var tw := target_img.get_width() # 1600
		var th := target_img.get_height() # 533

		# Target fitted uniformly into 1280x720 canvas
		var target_fitted := Image.create(half_w, cmp_h, false, Image.FORMAT_RGBA8)
		# Background gradient matching crimson sky and magma abyss
		for y in range(cmp_h):
			var t := float(y) / float(cmp_h)
			var bg_c := Color(0.24, 0.03, 0.04, 1.0).lerp(Color(0.85, 0.28, 0.05, 1.0), t)
			for x in range(half_w):
				target_fitted.set_pixel(x, y, bg_c)

		# Scale 1600x533 uniformly to 1280x426 and place at y=147
		var scale_t := float(half_w) / float(tw) # 0.8
		var scaled_th := int(round(float(th) * scale_t)) # 426
		var target_scaled := target_img.duplicate()
		target_scaled.resize(half_w, scaled_th, Image.INTERPOLATE_LANCZOS)
		var y_target_offset := (cmp_h - scaled_th) / 2 # 147
		target_fitted.blit_rect(target_scaled, Rect2i(0, 0, half_w, scaled_th), Vector2i(0, y_target_offset))

		cmp_img.blit_rect(target_fitted, Rect2i(0, 0, half_w, cmp_h), Vector2i.ZERO)

		# 2. Right side: Live game screenshot (1280 x 720)
		var game_scaled := game_img.duplicate()
		game_scaled.convert(Image.FORMAT_RGBA8)
		if game_scaled.get_width() != half_w or game_scaled.get_height() != cmp_h:
			game_scaled.resize(half_w, cmp_h, Image.INTERPOLATE_LANCZOS)
		cmp_img.blit_rect(game_scaled, Rect2i(0, 0, half_w, cmp_h), Vector2i(half_w, 0))

		# 3. Radiant fiery vertical divider line at x = 1280
		for y in range(cmp_h):
			cmp_img.set_pixel(half_w - 2, y, Color(0.85, 0.25, 0.05, 1.0))
			cmp_img.set_pixel(half_w - 1, y, Color(1.0, 0.55, 0.12, 1.0))
			cmp_img.set_pixel(half_w, y, Color(1.0, 0.85, 0.25, 1.0))
			cmp_img.set_pixel(half_w + 1, y, Color(1.0, 0.55, 0.12, 1.0))
			cmp_img.set_pixel(half_w + 2, y, Color(0.85, 0.25, 0.05, 1.0))

		var cmp_res := OUT_DIR + "/hell_target_vs_redesign_comparison.png"
		var abs_cmp := ProjectSettings.globalize_path(cmp_res)
		cmp_img.save_png(abs_cmp)
		print("\n[✓] Saved Master Side-by-Side Comparison (2560x720): %s" % abs_cmp)

		var cmp_16x9_res := OUT_DIR + "/hell_target_vs_redesign_comparison_16x9.png"
		var abs_16x9 := ProjectSettings.globalize_path(cmp_16x9_res)
		cmp_img.save_png(abs_16x9)
		print("[✓] Saved 16:9 Side-by-Side Comparison: %s" % abs_16x9)

	print("\n[✓] ALL HELL BIOME QA SCREENSHOTS CAPTURED SUCCESSFULLY!")
