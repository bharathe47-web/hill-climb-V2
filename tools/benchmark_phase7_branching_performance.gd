@tool
extends SceneTree

# tools/benchmark_phase7_branching_performance.gd
# Profiles real runtime performance on AMD Radeon 610M (Vulkan 1.4 / Forward Mobile @ 1280x720)
# Measures Mean/P95 frame time, FPS, Draw Calls, and VRAM across all branching game states.

const SAMPLES_PER_SCENARIO := 120

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN RADEON 610M PHASE 7 BENCHMARK & PERFORMANCE AUDIT ---")
	print("=================================================================\n")
	await _run_benchmarks()
	quit(0)

func _run_benchmarks() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed:
		printerr("Failed to load Game.tscn")
		return

	var game_inst: GameScene = packed.instantiate() as GameScene
	game_inst.use_procedural_terrain = true
	vp.add_child(game_inst)

	for i in range(15):
		await process_frame
		await physics_frame

	var host: BiomeEnvironmentHost = game_inst.biome_environment_host
	var prog: BiomeProgressionController = host.progression_controller if is_instance_valid(host) else null
	if not prog:
		prog = game_inst.find_child("BiomeProgressionController", true, false)
	if prog:
		prog.enable_branching_mode(true)

	var scenarios: Array[Dictionary] = [
		{"name": "1. Normal Approach (400m Baseline)", "dist": 400.0, "state": WorldCycleSchedule.WorldState.NORMAL_APPROACH, "realm": -1},
		{"name": "2. Decision Window (485m Lip & HUD Prompt)", "dist": 485.0, "state": WorldCycleSchedule.WorldState.LAUNCH_WINDOW, "realm": -1},
		{"name": "3. Heaven Route (750m Clouds & Palace)", "dist": 750.0, "state": WorldCycleSchedule.WorldState.HEAVEN_ACTIVE, "realm": WorldCycleSchedule.BiomeType.HEAVEN},
		{"name": "4. Hell Route (750m Basalt & Magma Cavern)", "dist": 750.0, "state": WorldCycleSchedule.WorldState.HELL_ACTIVE, "realm": WorldCycleSchedule.BiomeType.HELL},
		{"name": "5. Return Merge (1,000m Normal Re-entry)", "dist": 1000.0, "state": WorldCycleSchedule.WorldState.NORMAL_MERGE, "realm": -1},
		{"name": "6. Endless Milestone (5,020m 5th Cycle)", "dist": 5020.0, "state": WorldCycleSchedule.WorldState.NORMAL_APPROACH, "realm": -1}
	]

	var results: Array[Dictionary] = []

	for s in scenarios:
		print("-> Profiling: %s..." % s["name"])
		if s["realm"] != -1 and prog:
			prog.confirm_route(s["realm"], 0)
		if prog:
			prog.update_distance(s["dist"])
		if is_instance_valid(game_inst.game_manager):
			game_inst.game_manager.update_distance(s["dist"])

		game_inst.vehicle.global_position = Vector2(s["dist"] * 100.0, 380.0)
		if s["state"] == WorldCycleSchedule.WorldState.HEAVEN_ACTIVE:
			game_inst.vehicle.global_position.y = 190.0
		elif s["state"] == WorldCycleSchedule.WorldState.HELL_ACTIVE:
			game_inst.vehicle.global_position.y = 560.0

		if is_instance_valid(game_inst.follow_camera):
			game_inst.follow_camera.global_position = game_inst.vehicle.global_position + Vector2(100.0, -30.0)

		# Warmup 10 frames
		for w in range(10):
			await process_frame
			await physics_frame

		var frame_times: Array[float] = []
		var draw_calls: Array[int] = []

		for f in range(SAMPLES_PER_SCENARIO):
			var t_start := Time.get_ticks_usec()
			game_inst.vehicle.global_position.x += 10.0
			if is_instance_valid(game_inst.follow_camera):
				game_inst.follow_camera.global_position.x += 10.0
			await process_frame
			var t_end := Time.get_ticks_usec()
			var dt_ms := float(t_end - t_start) / 1000.0
			frame_times.append(dt_ms)

			var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			draw_calls.append(dc)

		frame_times.sort()
		var sum_time := 0.0
		for t in frame_times:
			sum_time += t
		var mean_time: float = sum_time / float(frame_times.size())
		var p50_idx := int(float(frame_times.size()) * 0.50)
		var p95_idx := int(float(frame_times.size()) * 0.95)
		var p99_idx := int(float(frame_times.size()) * 0.99)
		var p50_time: float = frame_times[p50_idx]
		var p95_time: float = frame_times[p95_idx]
		var p99_time: float = frame_times[p99_idx]
		var fps := 1000.0 / mean_time if mean_time > 0.0 else 0.0

		var sum_dc := 0
		for d in draw_calls:
			sum_dc += d
		var avg_dc: float = float(sum_dc) / float(draw_calls.size())

		var vram_mb: float = float(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)) / (1024.0 * 1024.0)
		var static_mem_mb: float = float(OS.get_static_memory_usage()) / (1024.0 * 1024.0)

		results.append({
			"scenario": s["name"],
			"mean_ms": mean_time,
			"p50_ms": p50_time,
			"p95_ms": p95_time,
			"p99_ms": p99_time,
			"fps": fps,
			"draw_calls": int(avg_dc),
			"vram_mb": vram_mb,
			"static_mem_mb": static_mem_mb
		})

	print("\n=================================================================")
	print("--- RADEON 610M PERFORMANCE BENCHMARK RESULTS ---")
	print("=================================================================")
	print("%-42s | %8s | %8s | %8s | %8s | %6s | %5s | %8s" % ["Scenario", "Mean(ms)", "P50(ms)", "P95(ms)", "P99(ms)", "FPS", "Draws", "VRAM(MB)"])
	print("---------------------------------------------------------------------------------------------------------------------------------")
	for r in results:
		print("%-42s | %7.2fms | %7.2fms | %7.2fms | %7.2fms | %6.1f | %5d | %7.1fMB" % [
			r["scenario"],
			r["mean_ms"],
			r["p50_ms"],
			r["p95_ms"],
			r["p99_ms"],
			r["fps"],
			r["draw_calls"],
			r["vram_mb"]
		])
	print("=================================================================\n")
