@tool
class_name CaptureRealGameplay452m
extends SceneTree

const TARGET_REF = "res://references/heaven_target.png"
const OUT_SCREENSHOT = "res://references/gameplay_reconstructed_452m.png"
const OUT_COMPARISON = "res://references/side_by_side_reconstruction_vs_target.png"

func _init() -> void:
	print("==================================================")
	print("CAPTURING REAL GAMEPLAY SCREENSHOT AT 452M...")
	print("==================================================")
	await _run_capture()
	quit(0)

func _run_capture() -> void:
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

	# Warm up frames for shaders, textures, and physics
	for f in range(30):
		await process_frame
		await physics_frame

	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")
	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null

	var target_dist: float = 452.0
	var world_x := game.start_x + (target_dist * 100.0)

	game.game_manager.update_distance(target_dist)
	game.game_manager.add_coins(12450)

	if is_instance_valid(prog):
		prog.update_distance(target_dist)
	if is_instance_valid(gen):
		gen._update_generation(world_x + 3500.0)

	var surf_y := gen.get_surface_y_at_world_x(world_x) if is_instance_valid(gen) else 380.0
	if is_instance_valid(game.vehicle):
		var v := game.vehicle
		v.global_position = Vector2(world_x, surf_y - 42.0)
		v.rotation = -0.12 # Natural uphill climbing angle
		v.linear_velocity = Vector2.ZERO
		v.angular_velocity = 0.0
		if "current_fuel" in v:
			v.set("current_fuel", 85.0)

	if is_instance_valid(game.hud) and game.hud.has_method("update_fuel"):
		game.hud.update_fuel(85.0, 100.0)
	if is_instance_valid(game.hud) and game.hud.has_method("update_nitro"):
		game.hud.update_nitro(100.0, 100.0)

	if is_instance_valid(game.follow_camera):
		game.follow_camera.global_position = Vector2(world_x + 180.0, surf_y - 50.0)
		if game.follow_camera.has_method("reset_smoothing"):
			game.follow_camera.reset_smoothing()

	# Settle frames for terrain, particles and environment
	for f in range(35):
		await process_frame
		await physics_frame

	var img: Image = vp.get_texture().get_image()
	if img and not img.is_empty():
		var abs_shot = ProjectSettings.globalize_path(OUT_SCREENSHOT)
		img.save_png(abs_shot)
		print("[✓] Saved live gameplay screenshot: %s (%dx%d)" % [OUT_SCREENSHOT, img.get_width(), img.get_height()])
		
		# Generate side-by-side comparison with heaven_target.png
		var target_img := Image.load_from_file(TARGET_REF)
		if target_img:
			var tw := 1280
			var th := 720
			var target_scaled := target_img.duplicate()
			target_scaled.convert(Image.FORMAT_RGBA8)
			target_scaled.resize(tw, th, Image.INTERPOLATE_LANCZOS)
			img.convert(Image.FORMAT_RGBA8)
			
			var comparison := Image.create(tw * 2, th, false, Image.FORMAT_RGBA8)
			comparison.blit_rect(target_scaled, Rect2i(0, 0, tw, th), Vector2i(0, 0))
			comparison.blit_rect(img, Rect2i(0, 0, tw, th), Vector2i(tw, 0))
			
			var abs_comp = ProjectSettings.globalize_path(OUT_COMPARISON)
			comparison.save_png(abs_comp)
			print("[✓] Saved side-by-side comparison: %s (%dx%d)" % [OUT_COMPARISON, tw * 2, th])
	else:
		printerr("Failed to grab image for gameplay capture")
