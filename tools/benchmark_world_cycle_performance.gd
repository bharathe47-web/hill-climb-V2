@tool
extends SceneTree

## Tool script to measure real in-engine performance metrics on AMD Radeon 610M
## Forward Mobile Vulkan renderer.
## Tests:
## 1. Normal Land baseline
## 2. Transition 1: Normal -> Heaven (Peak 50% / 50% Overlap)
## 3. Heaven Environment baseline
## 4. Transition 3: Normal -> Hell (Peak 50% / 50% Overlap)
## 5. Hell Environment baseline (Lava & Heat shaders, particles, characters)

const SAMPLES_PER_SCENARIO := 120

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN RADEON 610M PERFORMANCE & FILL-RATE BENCHMARK ---")
	print("=================================================================\n")
	await _run_benchmarks()
	quit(0)

func _run_benchmarks() -> void:
	# Create SubViewport with target mobile rendering resolution (1280x720)
	var vp := SubViewport.new()
	vp.size = Vector2i(1280, 720)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var camera := Camera2D.new()
	camera.position = Vector2(640, 360)
	vp.add_child(camera)

	# Setup BiomeEnvironmentHost
	var host_scene: PackedScene = load("res://scenes/environment/BiomeEnvironmentHost.tscn")
	var host = host_scene.instantiate()
	vp.add_child(host)

	# Ensure environments are resolved
	host._resolve_environment_references()

	var scenarios: Array[Dictionary] = [
		{"name": "Normal Land Baseline", "state": 0, "cam_x": 400.0, "progress": 0.0},
		{"name": "Transition 1 (Normal -> Heaven Peak)", "state": 1, "cam_x": 1075.0, "progress": 0.5},
		{"name": "Heaven Environment Baseline", "state": 2, "cam_x": 1600.0, "progress": 1.0},
		{"name": "Transition 3 (Normal -> Hell Peak)", "state": 5, "cam_x": 3575.0, "progress": 0.5},
		{"name": "Hell Environment Baseline", "state": 6, "cam_x": 4200.0, "progress": 1.0}
	]

	var results: Array[Dictionary] = []

	for s in scenarios:
		print("-> Profiling: %s..." % s["name"])
		
		# Set state and progress
		camera.position.x = s["cam_x"]
		host._on_progression_state_changed(0, s["state"], {})
		if s["progress"] < 1.0 and s["progress"] > 0.0:
			host._on_transition_progress_updated(s["progress"], s["state"])

		# Warmup 10 frames
		for w in range(10):
			await process_frame

		var frame_times: Array[float] = []
		var draw_calls: Array[int] = []
		var objects_count: Array[int] = []

		for f in range(SAMPLES_PER_SCENARIO):
			var t_start := Time.get_ticks_usec()
			# Simulate camera motion
			camera.position.x += 2.0
			await process_frame
			var t_end := Time.get_ticks_usec()
			var dt_ms := float(t_end - t_start) / 1000.0
			frame_times.append(dt_ms)

			var dc := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
			draw_calls.append(dc)
			var objs := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)
			objects_count.append(objs)

		# Statistical analysis
		frame_times.sort()
		var min_time: float = frame_times[0]
		var max_time: float = frame_times[frame_times.size() - 1]
		var sum_time := 0.0
		for t in frame_times:
			sum_time += t
		var mean_time: float = sum_time / float(frame_times.size())
		var p95_idx := int(float(frame_times.size()) * 0.95)
		var p95_time: float = frame_times[p95_idx]
		var median_time: float = frame_times[frame_times.size() / 2]

		var sum_dc := 0
		for d in draw_calls:
			sum_dc += d
		var avg_dc: float = float(sum_dc) / float(draw_calls.size())

		var mem_static_mb: float = float(OS.get_static_memory_usage()) / (1024.0 * 1024.0)
		var mem_peak_mb: float = float(OS.get_static_memory_peak_usage()) / (1024.0 * 1024.0)
		var vram_mb: float = float(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED)) / (1024.0 * 1024.0)

		var res := {
			"scenario": s["name"],
			"mean_ms": mean_time,
			"median_ms": median_time,
			"p95_ms": p95_time,
			"min_ms": min_time,
			"max_ms": max_time,
			"approx_fps": 1000.0 / mean_time if mean_time > 0 else 0.0,
			"avg_draw_calls": avg_dc,
			"static_mem_mb": mem_static_mb,
			"peak_mem_mb": mem_peak_mb,
			"vram_mb": vram_mb
		}
		results.append(res)
		print("   Mean: %.2f ms (%.1f FPS) | P95: %.2f ms | Avg Draw Calls: %.1f | VRAM: %.1f MB" % [
			mean_time, 1000.0 / mean_time, p95_time, avg_dc, vram_mb
		])

	# Output final table
	print("\n=================================================================")
	print("--- RADEON 610M PERFORMANCE SUMMARY TABLE ---")
	print("=================================================================")
	print("%-36s | %-8s | %-8s | %-8s | %-8s | %-8s" % [
		"Scenario", "Mean ms", "P95 ms", "Est FPS", "DrawCalls", "VRAM (MB)"
	])
	print("-------------------------------------+----------+----------+----------+----------+----------")
	for r in results:
		print("%-36s | %8.2f | %8.2f | %8.1f | %8.1f | %8.1f" % [
			r["scenario"], r["mean_ms"], r["p95_ms"], r["approx_fps"], r["avg_draw_calls"], r["vram_mb"]
		])
	print("=================================================================\n")

	# Save results to json
	var json_str := JSON.stringify(results, "  ")
	var file := FileAccess.open("res://docs/previews/benchmark_results.json", FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
		print("✓ Benchmark results saved to res://docs/previews/benchmark_results.json")

	vp.queue_free()
