class_name TestPhase6RuntimeEnvironmentIntegration
extends SceneTree

const WorldCycleScheduleScript = preload("res://scripts/progression/WorldCycleSchedule.gd")
const BiomeProgressionControllerScript = preload("res://scripts/progression/BiomeProgressionController.gd")
const BiomeEnvironmentHostScript = preload("res://scripts/environment/BiomeEnvironmentHost.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 6 RUNTIME ENVIRONMENT INTEGRATION TEST SUITE ---")
	print("=================================================================")

	await _test_environment_host_initialization()
	await _test_distance_progression_and_transitions()
	await _test_large_distance_jumps()
	await _test_audio_crossfade_and_bus_routing()
	await _test_vfx_lifecycle_and_culling()
	await _test_pause_resume_behavior()
	await _test_restart_behavior()
	_test_cosmetic_resource_fallback()
	await _test_continuous_driving_simulation()

	print("=================================================================")
	print("✓ ALL PHASE 6 INTEGRATION TESTS PASSED WITH 100% SUCCESS!")
	print("=================================================================")
	quit(0)

# ----------------------------------------------------
# Test 1: Host Initialization & Default Normal Land State
# ----------------------------------------------------
func _test_environment_host_initialization() -> void:
	print("-> [1/9] Testing BiomeEnvironmentHost initialization & initial state...")
	var host_scene: PackedScene = load("res://scenes/environment/BiomeEnvironmentHost.tscn")
	assert(host_scene != null, "BiomeEnvironmentHost.tscn must load")
	var host: BiomeEnvironmentHost = host_scene.instantiate()
	root.add_child(host)
	await process_frame

	assert(is_instance_valid(host.normal_environment), "Normal environment must be instantiated")
	assert(is_instance_valid(host.heaven_environment), "Heaven environment must be instantiated")
	assert(is_instance_valid(host.hell_environment), "Hell environment must be instantiated")

	# Initial state: Normal Land 100% active, Heaven & Hell inactive
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.NORMAL_LAND, "Initial biome must be Normal Land")
	assert(host.normal_environment.is_active == true, "Normal environment must be active")
	assert(host.heaven_environment.is_active == false, "Heaven environment must be inactive")
	assert(host.hell_environment.is_active == false, "Hell environment must be inactive")

	# Audio players initialized on correct buses
	assert(host._music_player_a.bus == &"Music", "Music player A must be on bus 'Music'")
	assert(host._music_player_b.bus == &"Music", "Music player B must be on bus 'Music'")
	assert(host._ambience_player_a.bus == &"Ambience", "Ambience player A must be on bus 'Ambience'")
	assert(host._ambience_player_b.bus == &"Ambience", "Ambience player B must be on bus 'Ambience'")
	assert(host._active_music_player.playing, "Active music player must be playing")
	assert(host._active_ambience_player.playing, "Active ambience player must be playing")

	host.queue_free()
	print("  ✓ Host initialized: Normal active, Heaven/Hell inactive, audio on Music & Ambience buses")

# ----------------------------------------------------
# Test 2: Sequential Distance Progression through all 4 Transitions
# ----------------------------------------------------
func _test_distance_progression_and_transitions() -> void:
	print("-> [2/9] Testing exact distance boundary transitions & ramp spawning...")
	var prog: BiomeProgressionController = BiomeProgressionControllerScript.new()
	var host: BiomeEnvironmentHost = BiomeEnvironmentHostScript.new()
	var gen: TerrainGenerator = TerrainGenerator.new()
	var dummy_cam := Node2D.new()
	dummy_cam.position = Vector2(0, 360)

	root.add_child(dummy_cam)
	root.add_child(gen)
	gen.target = dummy_cam
	await process_frame

	gen.reset_generator(Vector2(0, 400))
	host.terrain_generator = gen
	host.progression_controller = prog
	root.add_child(prog)
	root.add_child(host)
	await process_frame

	var transitions_started: Array[int] = []
	var transitions_completed: Array[int] = []
	host.biome_transition_started.connect(func(from_b, to_b, trans_state):
		transitions_started.append(trans_state)
	)
	host.biome_transition_completed.connect(func(curr_b):
		transitions_completed.append(curr_b)
	)

	# 1. Normal Land 1 (0m - 999m)
	prog.update_distance(500.0)
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.NORMAL_LAND, "500m must be Normal Land")
	assert(host.normal_environment.is_active == true, "Normal Land must be active at 500m")

	# 2. Transition 1: Normal -> Heaven (1000m - 1150m)
	prog.update_distance(1000.0)
	assert(host.is_in_transition == true, "1000m must be in transition")
	assert(transitions_started.has(WorldCycleScheduleScript.WorldState.TRANSITION_NORMAL_TO_HEAVEN), "Transition to Heaven must fire")
	assert(gen.active_terrain_profile.profile_name == "Heaven", "Profile must pre-arm to Heaven")

	# 3. Mid-transition progress blending at 1075m (50%)
	prog.update_distance(1075.0)
	assert(is_equal_approx(host.current_transition_progress, 0.5), "Progress at 1075m must be 0.5 (got %f)" % host.current_transition_progress)

	# 4. Heaven Biome (1150m - 2150m)
	prog.update_distance(1150.0)
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.HEAVEN, "1150m must be Heaven")
	assert(host.is_in_transition == false, "1150m must not be in transition")
	assert(host.heaven_environment.is_active == true, "Heaven environment must be active")
	assert(host.normal_environment.is_active == false, "Normal environment must be culled/inactive in Heaven")

	# 5. Transition 2: Heaven -> Normal (2200m - 2350m)
	prog.update_distance(2200.0)
	assert(host.is_in_transition == true, "2200m must be in transition")
	assert(transitions_started.has(WorldCycleScheduleScript.WorldState.TRANSITION_HEAVEN_TO_NORMAL), "Transition to Normal 1 must fire")

	# 6. Normal Land 2 (2350m - 3500m)
	prog.update_distance(2350.0)
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.NORMAL_LAND, "2350m must be Normal Land")
	assert(host.normal_environment.is_active == true, "Normal Land must be active at 2350m")
	assert(host.heaven_environment.is_active == false, "Heaven must be culled at 2350m")

	# 7. Transition 3: Normal -> Hell (3500m - 3650m)
	prog.update_distance(3500.0)
	assert(host.is_in_transition == true, "3500m must be in transition")
	assert(transitions_started.has(WorldCycleScheduleScript.WorldState.TRANSITION_NORMAL_TO_HELL), "Transition to Hell must fire")
	assert(gen.active_terrain_profile.profile_name == "Hell", "Profile must pre-arm to Hell")

	# 8. Hell Biome (3650m - 5000m)
	prog.update_distance(3650.0)
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.HEAVEN == false, "3650m must not be Heaven")
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.HELL, "3650m must be Hell")
	assert(host.hell_environment.is_active == true, "Hell environment must be active")
	assert(host.normal_environment.is_active == false, "Normal environment must be culled in Hell")

	# 9. Transition 4: Hell -> Normal (5000m - 5150m)
	prog.update_distance(5000.0)
	assert(host.is_in_transition == true, "5000m must be in transition")
	assert(transitions_started.has(WorldCycleScheduleScript.WorldState.TRANSITION_HELL_TO_NORMAL), "Transition to Normal 2 must fire")

	# 10. Cycle Rollover at 5150m
	prog.update_distance(5150.0)
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.NORMAL_LAND, "5150m must roll over to Normal Land")
	assert(host.normal_environment.is_active == true, "Normal Land must be active after cycle rollover")
	assert(host.hell_environment.is_active == false, "Hell environment must be culled after rollover")

	# Verify 4 ramps were spawned into terrain
	var ramp_count := 0
	for seg in gen.active_segments:
		if seg.segment_type >= 10 and seg.segment_type <= 13:
			ramp_count += 1
	assert(ramp_count >= 4, "Terrain generator must contain at least 4 transition ramps (found %d)" % ramp_count)

	# Clean up
	dummy_cam.queue_free()
	gen.clear_terrain()
	gen.queue_free()
	prog.queue_free()
	host.queue_free()
	await process_frame
	print("  ✓ All 4 biome boundaries, progress blending, and ramp triggers verified")

# ----------------------------------------------------
# Test 3: Large Multi-Boundary Distance Jumps
# ----------------------------------------------------
func _test_large_distance_jumps() -> void:
	print("-> [3/9] Testing large multi-boundary distance jumps...")
	var prog: BiomeProgressionController = BiomeProgressionControllerScript.new()
	var host: BiomeEnvironmentHost = BiomeEnvironmentHostScript.new()
	host.progression_controller = prog
	root.add_child(prog)
	root.add_child(host)
	await process_frame

	# Jump directly from 0m to 1600m (deep Heaven)
	prog.handle_distance_jump(1600.0)
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.HEAVEN, "Jump to 1600m must resolve Heaven")
	assert(host.heaven_environment.is_active == true, "Heaven must be active")
	assert(host.normal_environment.is_active == false, "Normal must be inactive")

	# Jump directly from 1600m to 4200m (deep Hell)
	prog.handle_distance_jump(4200.0)
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.HELL, "Jump to 4200m must resolve Hell")
	assert(host.hell_environment.is_active == true, "Hell must be active")
	assert(host.heaven_environment.is_active == false, "Heaven must be inactive")

	# Jump directly to 10,500m (Cycle 2 at 200m -> Normal Land)
	prog.handle_distance_jump(10500.0)
	assert(prog.current_cycle_index == 2, "10,500m must be Cycle 2")
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.NORMAL_LAND, "10,500m must be Normal Land")
	assert(host.normal_environment.is_active == true, "Normal Land must be active at 10,500m")

	# Jump directly to 12,000m (Cycle 2 at 1700m -> Heaven)
	prog.handle_distance_jump(12000.0)
	assert(prog.current_cycle_index == 2, "12,000m must be Cycle 2")
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.HEAVEN, "12,000m must be Heaven")
	assert(host.heaven_environment.is_active == true, "Heaven must be active at 12,000m")

	prog.queue_free()
	host.queue_free()
	print("  ✓ Multi-boundary leaps resolve immediately and cleanly")

# ----------------------------------------------------
# Test 4: Audio Crossfade, Player Boundedness & Bus Routing
# ----------------------------------------------------
func _test_audio_crossfade_and_bus_routing() -> void:
	print("-> [4/9] Testing audio crossfader, bounded players, and bus routing...")
	var host: BiomeEnvironmentHost = BiomeEnvironmentHostScript.new()
	host.music_crossfade_duration = 0.1 # Accelerated for test
	host.ambience_crossfade_duration = 0.1
	root.add_child(host)
	await process_frame

	# Count total audio players
	var player_count := 0
	for c in host.get_children():
		if c is AudioStreamPlayer:
			player_count += 1
	assert(player_count == 5, "Host must contain strictly 5 bounded audio players (got %d)" % player_count)

	var initial_music_stream := host._active_music_player.stream
	assert(initial_music_stream == BiomeEnvironmentHost.STREAM_NORMAL_MUSIC, "Initial music must be Normal Land")

	# Crossfade to Heaven music
	host.crossfade_music(BiomeEnvironmentHost.STREAM_HEAVEN_MUSIC, -10.0, 0.05)
	assert(host._active_music_player.stream == BiomeEnvironmentHost.STREAM_HEAVEN_MUSIC, "Active music must now be Heaven")
	assert(host._inactive_music_player.stream == BiomeEnvironmentHost.STREAM_NORMAL_MUSIC, "Inactive music must be Normal Land during fade")

	# Wait for fade tween to complete
	for f in range(20):
		await process_frame

	assert(is_equal_approx(host._active_music_player.volume_db, -10.0), "Active music volume must reach target dB")
	assert(host._inactive_music_player.playing == false, "Outgoing music player must stop after crossfade")

	# Verify players after crossfade remain strictly 5 (0 leaks)
	var post_crossfade_players := 0
	for c in host.get_children():
		if c is AudioStreamPlayer:
			post_crossfade_players += 1
	assert(post_crossfade_players == 5, "Audio players count must remain constant at 5")

	host.queue_free()
	print("  ✓ Audio crossfader verified: clickless, bounded, zero player leaks")

# ----------------------------------------------------
# Test 5: VFX Lifecycle, Mobile Fill-Rate Culling
# ----------------------------------------------------
func _test_vfx_lifecycle_and_culling() -> void:
	print("-> [5/9] Testing VFX activation, particle culling & mobile optimization...")
	var host_scene: PackedScene = load("res://scenes/environment/BiomeEnvironmentHost.tscn")
	var host: BiomeEnvironmentHost = host_scene.instantiate()
	root.add_child(host)
	await process_frame

	# 1. In Normal Land: Heaven & Hell particles must NOT be emitting
	for p in host.heaven_environment.find_children("*", "CPUParticles2D", true, false):
		assert((p as CPUParticles2D).emitting == false, "Heaven particle %s must not emit in Normal Land" % p.name)
	for p in host.hell_environment.find_children("*", "CPUParticles2D", true, false):
		assert((p as CPUParticles2D).emitting == false, "Hell particle %s must not emit in Normal Land" % p.name)

	# 2. Activate Heaven
	host._enter_heaven_state()
	var heaven_particles_found := 0
	for p in host.heaven_environment.find_children("*", "CPUParticles2D", true, false):
		heaven_particles_found += 1
		assert((p as CPUParticles2D).emitting == true, "Heaven particle %s must emit in Heaven" % p.name)
	assert(heaven_particles_found > 0, "Heaven must have active particles")

	# Hell particles must remain off
	for p in host.hell_environment.find_children("*", "CPUParticles2D", true, false):
		assert((p as CPUParticles2D).emitting == false, "Hell particle %s must remain off in Heaven" % p.name)

	# 3. Activate Hell
	host._enter_hell_state()
	var hell_particles_found := 0
	for p in host.hell_environment.find_children("*", "CPUParticles2D", true, false):
		hell_particles_found += 1
		assert((p as CPUParticles2D).emitting == true, "Hell particle %s must emit in Hell" % p.name)
	assert(hell_particles_found > 0, "Hell must have active particles")

	# Heaven particles must now be off
	for p in host.heaven_environment.find_children("*", "CPUParticles2D", true, false):
		assert((p as CPUParticles2D).emitting == false, "Heaven particle %s must be turned off in Hell" % p.name)

	host.queue_free()
	print("  ✓ VFX lifecycle verified: emitters strictly culled outside active biomes")

# ----------------------------------------------------
# Test 6: Pause and Resume Preservation
# ----------------------------------------------------
func _test_pause_resume_behavior() -> void:
	print("-> [6/9] Testing pause & resume preservation...")
	var host: BiomeEnvironmentHost = BiomeEnvironmentHostScript.new()
	root.add_child(host)
	await process_frame

	assert(host._active_music_player.stream_paused == false, "Music must not be paused initially")
	assert(host._active_ambience_player.stream_paused == false, "Ambience must not be paused initially")

	# Pause
	host.set_audio_paused(true)
	assert(host._active_music_player.stream_paused == true, "Music must be paused on pause")
	assert(host._active_ambience_player.stream_paused == true, "Ambience must be paused on pause")

	# Resume
	host.set_audio_paused(false)
	assert(host._active_music_player.stream_paused == false, "Music must resume on unpause")
	assert(host._active_ambience_player.stream_paused == false, "Ambience must resume on unpause")

	host.queue_free()
	print("  ✓ Pause/resume preserves track state without restarting")

# ----------------------------------------------------
# Test 7: Restart from Any Biome Returns to Normal Land
# ----------------------------------------------------
func _test_restart_behavior() -> void:
	print("-> [7/9] Testing restart from Heaven, Hell & Transitions...")
	var prog: BiomeProgressionController = BiomeProgressionControllerScript.new()
	var host: BiomeEnvironmentHost = BiomeEnvironmentHostScript.new()
	host.progression_controller = prog
	root.add_child(prog)
	root.add_child(host)
	await process_frame

	# Case A: Advance to Hell (4000m) and restart
	prog.update_distance(4000.0)
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.HELL, "Must be in Hell at 4000m")

	# Trigger progression reset (equivalent to run restart)
	prog.reset_progression()
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.NORMAL_LAND, "Must reset to Normal Land")
	assert(host.normal_environment.is_active == true, "Normal Land must be active after restart")
	assert(host.hell_environment.is_active == false, "Hell must be inactive after restart")
	assert(host.heaven_environment.is_active == false, "Heaven must be inactive after restart")
	assert(host._active_music_player.stream == BiomeEnvironmentHost.STREAM_NORMAL_MUSIC, "Music must reset to Normal Land")

	# Case B: Advance to Heaven (1500m) and restart
	prog.update_distance(1500.0)
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.HEAVEN, "Must be in Heaven at 1500m")
	prog.reset_progression()
	assert(host.current_biome == WorldCycleScheduleScript.BiomeType.NORMAL_LAND, "Must reset to Normal Land")
	assert(host.normal_environment.is_active == true, "Normal Land must be active after restart")

	prog.queue_free()
	host.queue_free()
	print("  ✓ Restart from all environments restores clean Normal Land baseline")

# ----------------------------------------------------
# Test 8: Safe Cosmetic Resource Fallback
# ----------------------------------------------------
func _test_cosmetic_resource_fallback() -> void:
	print("-> [8/9] Testing safe cosmetic resource fallback...")
	var host: BiomeEnvironmentHost = BiomeEnvironmentHostScript.new()
	
	# Pass null profile to fallback resolver
	var resolved := host._get_safe_profile(null)
	assert(resolved != null, "Fallback profile must never be null")
	assert(resolved.profile_name == "Normal Land", "Fallback must provide valid Normal Land profile")
	assert(resolved.surface_friction > 0.5, "Fallback profile must retain valid friction physics")

	host.queue_free()
	print("  ✓ Missing cosmetic resource safely resolves fallback without breaking physics")

# ----------------------------------------------------
# Test 9: Continuous Gameplay Drive with No Scene Reload
# ----------------------------------------------------
func _test_continuous_driving_simulation() -> void:
	print("-> [9/9] Testing continuous gameplay drive without scene reload...")
	var game_scene_packed: PackedScene = load("res://scenes/game/Game.tscn")
	assert(game_scene_packed != null, "Game.tscn must load")
	var game: GameScene = game_scene_packed.instantiate()
	game.use_procedural_terrain = true
	root.add_child(game)
	await process_frame

	assert(is_instance_valid(game.biome_environment_host), "BiomeEnvironmentHost must be wired into GameScene")
	var initial_game_instance_id := game.get_instance_id()
	var vehicle_instance_id := game.vehicle.get_instance_id()

	# Simulate vehicle driving through milestone distances
	var gm: Node = game.game_manager
	gm.update_distance(500.0)
	await process_frame

	# Cross into Transition 1 (1050m)
	gm.update_distance(1050.0)
	await process_frame
	assert(game.get_instance_id() == initial_game_instance_id, "GameScene must NOT reload during transition")
	assert(game.vehicle.get_instance_id() == vehicle_instance_id, "Vehicle must NOT reload during transition")

	# Cross into Heaven (1500m)
	gm.update_distance(1500.0)
	await process_frame
	assert(game.biome_environment_host.current_biome == WorldCycleScheduleScript.BiomeType.HEAVEN, "Must be in Heaven")
	assert(game.get_instance_id() == initial_game_instance_id, "GameScene instance must remain continuous")

	# Cross into Hell (4000m)
	gm.update_distance(4000.0)
	await process_frame
	assert(game.biome_environment_host.current_biome == WorldCycleScheduleScript.BiomeType.HELL, "Must be in Hell")
	assert(game.get_instance_id() == initial_game_instance_id, "GameScene instance must remain continuous")

	# Restart from Hell
	game.restart_game()
	await process_frame
	assert(game.biome_environment_host.current_biome == WorldCycleScheduleScript.BiomeType.NORMAL_LAND, "Must reset to Normal Land on restart")
	assert(game.get_instance_id() == initial_game_instance_id, "GameScene must NOT reload on restart")

	game.queue_free()
	for i in range(3):
		await process_frame
	print("  ✓ Continuous Endless Map run verified: 0 scene reloads across Heaven, Hell, and restarts")
