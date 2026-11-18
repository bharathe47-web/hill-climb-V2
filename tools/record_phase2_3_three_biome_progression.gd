@tool
extends SceneTree

## Video recording script for Phase 2.3: Fixed Recurring Three-Biome Progression.
## Captures continuous frame-by-frame gameplay through:
## 1. Normal Land drive and launch approach (270m prompt)
## 2. Nitro launch on countryside ramp (285-300m) launching into Heaven
## 3. Heaven celestial palace driving and Hell Portal approach (585m)
## 4. Traversing through the physical HellPortal at 600m into Hell
## 5. Hell basalt & magma cavern driving and Return Portal approach (885m)
## 6. Traversing through the physical ReturnPortal at 900m back to Normal Land
## 7. Starting the next cycle in Normal Land

const TOTAL_FRAMES := 450
const FRAME_DIR := "/tmp/phase2_3_frames"

func _init() -> void:
	print("=================================================================")
	print("--- RECORDING PHASE 2.3 THREE-BIOME PROGRESSION VIDEO ---")
	print("=================================================================")
	await _record_video()
	quit(0)

func _record_video() -> void:
	var dir := DirAccess.open("/tmp")
	if not dir.dir_exists("phase2_3_frames"):
		dir.make_dir("phase2_3_frames")
	else:
		# Clean old frames
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

	# Initial warm-up
	for f in range(20):
		await process_frame
		await physics_frame

	var vehicle: VehicleController = game.vehicle as VehicleController
	var host: BiomeEnvironmentHost = game.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null
	var gen: TerrainGenerator = game.terrain_slot.get_node_or_null("TerrainGenerator")

	# Sequence phases through the run:
	# Phase 1: Normal Land approaching and traversing Heaven Portal on roadway (270m - 320m) - ZERO nitro required!
	# Phase 2: Heaven palace driving and Hell portal crossing on roadway (570m - 620m)
	# Phase 3: Hell cavern driving and Return portal crossing on roadway (870m - 920m)
	# Phase 4: Normal Land cycle 1 continuation (915m - 950m)

	var phases = [
		{"start_dist": 270.0, "frames": 130, "nitro": false, "name": "Normal Land -> Heaven Physical Portal Crossing (Zero Nitro)"},
		{"start_dist": 570.0, "frames": 130, "nitro": false, "name": "Heaven -> Hell Physical Portal Crossing"},
		{"start_dist": 870.0, "frames": 140, "nitro": false, "name": "Hell -> Normal Land Return Portal Crossing"},
		{"start_dist": 915.0, "frames": 50, "nitro": false, "name": "Second Cycle Normal Land Continuation"}
	]

	var global_frame := 0

	for p_idx in range(phases.size()):
		var p = phases[p_idx]
		var s_dist: float = p["start_dist"]
		var s_x: float = s_dist * 100.0
		var n_frames: int = p["frames"]
		var use_nitro: bool = p["nitro"]

		print("\n>>> Phase %d: %s (Starting at %.0fm)..." % [p_idx + 1, p["name"], s_dist])

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

		if is_instance_valid(game.follow_camera):
			game.follow_camera.global_position = Vector2(s_x + 180.0, surf_y - 50.0)
			if game.follow_camera.has_method("snap_to_target"):
				game.follow_camera.snap_to_target()

		for f in range(6):
			await process_frame
			await physics_frame

		for step in range(n_frames):
			var cur_x := vehicle.global_position.x if vehicle else s_x + step * 16.0
			var cur_d := cur_x / 100.0

			game.game_manager.update_distance(cur_d)
			if is_instance_valid(prog):
				prog.update_distance(cur_d)
			if is_instance_valid(gen):
				gen._update_generation(cur_x + 3500.0)

			if vehicle:
				vehicle.set("throttle_input", 1.0)
				if vehicle.linear_velocity.x < 500.0:
					vehicle.apply_central_force(Vector2(28000.0, 0.0))
				# Upright stabilizer
				if absf(vehicle.rotation) > 0.15:
					vehicle.angular_velocity = -vehicle.rotation * 4.0

				# Optional nitro boost (purely standard gameplay speed boost, not required for portals)
				if use_nitro and vehicle.has_method("set_nitro_active"):
					vehicle.set_nitro_active(true)

			await physics_frame
			await process_frame

			# Grab frame
			var img: Image = vp.get_texture().get_image()
			if img:
				var fpath := "%s/frame_%04d.jpg" % [FRAME_DIR, global_frame]
				img.save_jpg(fpath, 0.92)
				global_frame += 1

			if global_frame % 50 == 0:
				print("   ... captured frame %d / %d" % [global_frame, TOTAL_FRAMES])

	print("\n✓ Captured %d frames for video recording!" % global_frame)
	vp.queue_free()
