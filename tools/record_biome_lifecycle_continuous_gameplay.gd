@tool
class_name RecordBiomeLifecycleContinuousGameplay
extends SceneTree

const TOTAL_FRAMES := 450
const FRAME_DIR := "/tmp/lifecycle_video1_frames"
const ARTIFACT_PREVIEWS_DIR = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"
const DOCS_PREVIEWS_DIR = "res://docs/previews"

func _init() -> void:
	print("=================================================================")
	print("--- RECORDING VIDEO 1: CONTINUOUS THREE-BIOME PROGRESSION ---")
	print("=================================================================")
	await _record_video()
	quit(0)

func _record_video() -> void:
	var dir := DirAccess.open("/tmp")
	if not dir.dir_exists("lifecycle_video1_frames"):
		dir.make_dir("lifecycle_video1_frames")
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

	var phases = [
		{"start_dist": 270.0, "frames": 130, "name": "Normal Land -> Heaven Portal Crossing (300m)"},
		{"start_dist": 570.0, "frames": 130, "name": "Heaven -> Hell Portal Crossing (600m)"},
		{"start_dist": 870.0, "frames": 140, "name": "Hell -> Normal Return Portal Crossing (900m)"},
		{"start_dist": 915.0, "frames": 50, "name": "Second Cycle Normal Land Continuation"}
	]

	var global_frame := 0

	for p_idx in range(phases.size()):
		var p = phases[p_idx]
		var s_dist: float = p["start_dist"]
		var s_x: float = s_dist * 100.0
		var n_frames: int = p["frames"]

		print("\n>>> Video 1 Phase %d: %s (Starting at %.0fm)..." % [p_idx + 1, p["name"], s_dist])

		game.game_manager.update_distance(s_dist)
		if is_instance_valid(prog):
			prog.update_distance(s_dist)
		if is_instance_valid(gen):
			gen._update_generation(s_x + 3500.0)
			gen._update_culling(s_x)

		var surf_y := gen.get_surface_y_at_world_x(s_x) if gen else 380.0
		if vehicle:
			vehicle.reset_vehicle(Vector2(s_x, surf_y - 40.0))
			vehicle.linear_velocity = Vector2(450.0, 0.0)
			vehicle.angular_velocity = 0.0
			vehicle.rotation = 0.0

		for f in range(n_frames):
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
				if vehicle.linear_velocity.x < 500.0:
					vehicle.apply_central_force(Vector2(28000.0, 0.0))
				if absf(vehicle.rotation) > 0.15:
					vehicle.angular_velocity = -vehicle.rotation * 4.0

			await physics_frame
			await process_frame

			var img: Image = vp.get_texture().get_image()
			if img:
				var fpath := "%s/frame_%04d.jpg" % [FRAME_DIR, global_frame]
				img.save_jpg(fpath, 0.92)
				global_frame += 1

			if global_frame % 50 == 0:
				print("   ... captured frame %d / %d" % [global_frame, TOTAL_FRAMES])

	print("\n✓ Captured %d frames for Video 1!" % global_frame)
	vp.queue_free()
