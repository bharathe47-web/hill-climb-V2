@tool
class_name CaptureForensicVerificationCheckpoints
extends SceneTree

const TARGET_REF = "res://references/heaven_target.png"
const ASCENT_REF = "res://Heavenly Monster Truck Ascent.png"

func _init() -> void:
	print("==================================================")
	print("CAPTURING FORENSIC VERIFICATION CHECKPOINTS...")
	print("==================================================")
	await _run_all_captures()
	quit(0)

func _run_all_captures() -> void:
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
	for f in range(25):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	var checkpoints = [360.0, 420.0, 452.0, 512.0, 540.0, 569.0, 590.0]
	var captured_images: Dictionary = {}

	for dist_m in checkpoints:
		var dist_val: float = float(dist_m)
		var world_x: float = float(game.start_x) + (dist_val * 100.0)

		game.game_manager.update_distance(dist_val)
		game.game_manager.add_coins(int(dist_val * 25.0))

		if is_instance_valid(prog):
			prog.update_distance(dist_val)
		if is_instance_valid(gen):
			gen._update_generation(world_x + 4000.0)

		var surf_y: float = gen.get_surface_y_at_world_x(world_x) if is_instance_valid(gen) else 350.0
		var surf_y_ahead: float = gen.get_surface_y_at_world_x(world_x + 15.0) if is_instance_valid(gen) else surf_y
		var surf_y_behind: float = gen.get_surface_y_at_world_x(world_x - 15.0) if is_instance_valid(gen) else surf_y
		var local_slope: float = atan2(surf_y_ahead - surf_y_behind, 30.0)

		if is_instance_valid(game.vehicle):
			var v: Node2D = game.vehicle
			v.global_position = Vector2(world_x, surf_y - 40.0)
			v.rotation = local_slope
			if v is RigidBody2D:
				var rb := v as RigidBody2D
				rb.linear_velocity = Vector2.ZERO
				rb.angular_velocity = 0.0
			if "current_fuel" in v:
				v.set("current_fuel", 80.0)

		if is_instance_valid(game.hud) and game.hud.has_method("update_fuel"):
			game.hud.update_fuel(80.0, 100.0)
		if is_instance_valid(game.hud) and game.hud.has_method("update_nitro"):
			game.hud.update_nitro(90.0, 100.0)

		if is_instance_valid(game.follow_camera):
			game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
			if game.follow_camera.has_method("reset_smoothing"):
				game.follow_camera.reset_smoothing()

		# Allow frames to render environment, parallax, and particles
		for f in range(20):
			await process_frame
			await physics_frame

		var img: Image = vp.get_texture().get_image()
		if img and not img.is_empty():
			var out_path = "res://docs/forensic_debug/gameplay_clean_%dm.png" % int(dist_m)
			var abs_out = ProjectSettings.globalize_path(out_path)
			img.save_png(abs_out)
			captured_images[dist_m] = img.duplicate()
			print("[✓] Saved live checkpoint screenshot: %s (%dx%d)" % [out_path, img.get_width(), img.get_height()])
		else:
			printerr("Failed to grab image for checkpoint %fm" % dist_m)

	# Generate Side-by-Side comparisons with TARGET_REF
	var target_img := Image.load_from_file(TARGET_REF)
	if target_img:
		var tw := 1280
		var th := 720
		var target_scaled := target_img.duplicate()
		target_scaled.convert(Image.FORMAT_RGBA8)
		target_scaled.resize(tw, th, Image.INTERPOLATE_LANCZOS)

		for dist_m in checkpoints:
			if captured_images.has(dist_m):
				var shot: Image = captured_images[dist_m]
				shot.convert(Image.FORMAT_RGBA8)
				var comp := Image.create(tw * 2, th, false, Image.FORMAT_RGBA8)
				comp.blit_rect(target_scaled, Rect2i(0, 0, tw, th), Vector2i(0, 0))
				comp.blit_rect(shot, Rect2i(0, 0, tw, th), Vector2i(tw, 0))
				var comp_path = "res://docs/forensic_debug/comparison_%dm_vs_target.png" % int(dist_m)
				var abs_comp = ProjectSettings.globalize_path(comp_path)
				comp.save_png(abs_comp)
				print("[✓] Saved comparison: %s (%dx%d)" % [comp_path, tw * 2, th])

	# Also generate comparison with ASCENT_REF if available
	var ascent_img := Image.load_from_file(ASCENT_REF)
	if ascent_img and captured_images.has(452.0):
		var tw := 1280
		var th := 720
		var ascent_scaled := ascent_img.duplicate()
		ascent_scaled.convert(Image.FORMAT_RGBA8)
		ascent_scaled.resize(tw, th, Image.INTERPOLATE_LANCZOS)
		var shot: Image = captured_images[452.0]
		shot.convert(Image.FORMAT_RGBA8)
		var comp_ascent := Image.create(tw * 2, th, false, Image.FORMAT_RGBA8)
		comp_ascent.blit_rect(ascent_scaled, Rect2i(0, 0, tw, th), Vector2i(0, 0))
		comp_ascent.blit_rect(shot, Rect2i(0, 0, tw, th), Vector2i(tw, 0))
		var ascent_comp_path = "res://docs/forensic_debug/terrain_comparison_analysis.png"
		var abs_ascent_comp = ProjectSettings.globalize_path(ascent_comp_path)
		comp_ascent.save_png(abs_ascent_comp)
		print("[✓] Saved ascent comparison: %s (%dx%d)" % [ascent_comp_path, tw * 2, th])
