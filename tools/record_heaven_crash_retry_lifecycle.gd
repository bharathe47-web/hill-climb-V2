@tool
class_name RecordHeavenCrashRetryLifecycle
extends SceneTree

const TOTAL_FRAMES := 360
const FRAME_DIR := "/tmp/lifecycle_video2_frames"
const ARTIFACT_PREVIEWS_DIR = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"
const DOCS_PREVIEWS_DIR = "res://docs/previews"

func _init() -> void:
	print("=================================================================")
	print("--- RECORDING VIDEO 2: HEAVEN CRASH AND RETRY LIFECYCLE ---")
	print("=================================================================")
	await _record_video()
	quit(0)

func _record_video() -> void:
	var dir := DirAccess.open("/tmp")
	if not dir.dir_exists("lifecycle_video2_frames"):
		dir.make_dir("lifecycle_video2_frames")
	else:
		var fdir := DirAccess.open(FRAME_DIR)
		if fdir:
			fdir.list_dir_begin()
			var fn := fdir.get_next()
			while fn != "":
				if fn.ends_with(".jpg"):
					fdir.remove(fn)
				fn = fdir.get_next()
			fdir.list_dir_end()

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

	# Warm-up frames
	for f in range(20):
		await process_frame
		await physics_frame

	var vehicle: VehicleController = game.vehicle as VehicleController
	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null
	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")

	var global_frame := 0

	# Sequence 1: Drive inside Heaven (420m to 450m)
	print("\n>>> Video 2 Phase 1: Driving inside Heaven at 420m...")
	var s_dist: float = 420.0
	var s_x: float = s_dist * 100.0
	game.game_manager.update_distance(s_dist)
	if is_instance_valid(prog):
		prog.update_distance(s_dist)
	if is_instance_valid(gen):
		gen._update_generation(s_x + 3500.0)
		gen._update_culling(s_x)

	var surf_y := gen.get_surface_y_at_world_x(s_x) if gen else 380.0
	if vehicle:
		vehicle.reset_vehicle(Vector2(s_x, surf_y - 40.0))
		vehicle.linear_velocity = Vector2(400.0, 0.0)

	for f in range(80):
		var cur_x: float = vehicle.global_position.x if vehicle else s_x
		var cur_dist_m := (cur_x - game.start_x) / 100.0
		game.game_manager.update_distance(cur_dist_m)
		if is_instance_valid(prog):
			prog.update_distance(cur_dist_m)
		if is_instance_valid(gen):
			gen._update_generation(cur_x + 3500.0)
			gen._update_culling(cur_x)

		if vehicle:
			vehicle.set("throttle_input", 1.0)
			if vehicle.linear_velocity.x < 450.0:
				vehicle.apply_central_force(Vector2(24000.0, 0.0))

		await physics_frame
		await process_frame

		var img: Image = vp.get_texture().get_image()
		if img:
			var fpath := "%s/frame_%04d.jpg" % [FRAME_DIR, global_frame]
			img.save_jpg(fpath, 0.92)
			global_frame += 1

	# Sequence 2: Crash event at 450m
	print("\n>>> Video 2 Phase 2: Triggering crash in Heaven...")
	if vehicle:
		vehicle.angular_velocity = 8.0
		vehicle.linear_velocity = Vector2(250.0, -180.0)
	for f in range(40):
		await physics_frame
		await process_frame
		var img: Image = vp.get_texture().get_image()
		if img:
			var fpath := "%s/frame_%04d.jpg" % [FRAME_DIR, global_frame]
			img.save_jpg(fpath, 0.92)
			global_frame += 1

	game.game_manager.finish_run("crashed")
	if is_instance_valid(game.results_screen):
		game.results_screen.visible = true

	# Hold on ResultsScreen
	for f in range(50):
		await physics_frame
		await process_frame
		var img: Image = vp.get_texture().get_image()
		if img:
			var fpath := "%s/frame_%04d.jpg" % [FRAME_DIR, global_frame]
			img.save_jpg(fpath, 0.92)
			global_frame += 1

	# Sequence 3: Player clicks Retry -> Execute 8-phase authoritative restart
	print("\n>>> Video 2 Phase 3: Player clicks Retry -> Authoritative restart transaction...")
	game.game_manager.restart_run()
	for f in range(10):
		await physics_frame
		await process_frame
		var img: Image = vp.get_texture().get_image()
		if img:
			var fpath := "%s/frame_%04d.jpg" % [FRAME_DIR, global_frame]
			img.save_jpg(fpath, 0.92)
			global_frame += 1

	# Sequence 4: Driving forward in clean Normal Land (0m to 60m)
	print("\n>>> Video 2 Phase 4: Driving in fresh, clean Normal Land world at 0m...")
	for f in range(150):
		var cur_x: float = vehicle.global_position.x if vehicle else 0.0
		var cur_dist_m := (cur_x - game.start_x) / 100.0
		game.game_manager.update_distance(cur_dist_m)
		if is_instance_valid(prog):
			prog.update_distance(cur_dist_m)
		if is_instance_valid(gen):
			gen._update_generation(cur_x + 3500.0)
			gen._update_culling(cur_x)

		if vehicle:
			vehicle.set("throttle_input", 1.0)
			if vehicle.linear_velocity.x < 450.0:
				vehicle.apply_central_force(Vector2(26000.0, 0.0))
			if absf(vehicle.rotation) > 0.15:
				vehicle.angular_velocity = -vehicle.rotation * 4.0

		await physics_frame
		await process_frame

		var img: Image = vp.get_texture().get_image()
		if img:
			var fpath := "%s/frame_%04d.jpg" % [FRAME_DIR, global_frame]
			img.save_jpg(fpath, 0.92)
			global_frame += 1

	print("\n✓ Captured %d frames for Video 2!" % global_frame)
	vp.queue_free()
