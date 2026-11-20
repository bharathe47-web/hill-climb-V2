extends SceneTree

const SurvivalScene: PackedScene = preload("res://scenes/modes/survival/Survival.tscn")
const UnburnedAsteroidScene: PackedScene = preload("res://scenes/modes/survival/obstacles/unburned_asteroid_obstacle.tscn")
const BurningAsteroidScene: PackedScene = preload("res://scenes/modes/survival/obstacles/burning_asteroid_obstacle.tscn")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN SURVIVAL MODE AUDIO INTEGRATION VERIFICATION ---")
	print("=================================================================\n")
	call_deferred("_run_audio_tests")

func _run_audio_tests() -> void:
	var win = root
	var survival = SurvivalScene.instantiate()
	win.add_child(survival)

	for i in range(10):
		await process_frame

	var controller = survival

	# 1. Background Music Verification
	print("-> [1/5] Verifying Survival Mode Background Music Player & Bus Routing...")
	var music_player: AudioStreamPlayer = controller.get_node_or_null("%SurvivalMusicPlayer")
	assert(music_player != null, "SurvivalMusicPlayer must exist in Survival scene")
	assert(music_player.stream != null, "Background music stream must be assigned")
	assert(music_player.bus == &"Music", "Music player must route to dedicated Music audio bus")
	assert(music_player.volume_db <= 0.0, "Background music volume must be balanced (<= 0 dB)")
	assert(music_player.stream.resource_path.ends_with("survival_main_theme_loop.ogg"), "BGM stream must be survival_main_theme_loop.ogg")
	assert(music_player.playing == true, "Survival music must start automatically on Survival Mode load")
	print("  • Music stream: ", music_player.stream.resource_path, " | Bus: ", music_player.bus, " | Volume: ", music_player.volume_db, " dB")
	print("  ✓ Background music auto-start and bus routing verified!")

	# 2. Music Continuity & No Duplication on Retry/Restart
	print("\n-> [2/5] Testing Music Continuity on Retry & No Playback Duplication...")
	var initial_playback_pos: float = music_player.get_playback_position()
	# Trigger retry / restart_run
	controller.start_run()
	for i in range(5):
		await process_frame
	assert(music_player.playing == true, "Music must remain playing after start_run")
	# Count how many music players exist
	var bgm_count := 0
	for child in controller.get_children():
		if child is AudioStreamPlayer and child.bus == &"Music":
			bgm_count += 1
	assert(bgm_count == 1, "Exactly one music player must exist (no duplicate players spawned)")
	print("  ✓ Music continuity preserved across retries without duplicate audio players!")

	# 3. SFX Pool & Audio Bus Configuration
	print("\n-> [3/5] Verifying Polyphonic SFX Pool on Dedicated SFX Bus...")
	assert(controller._sfx_players.size() == 4, "SFX pool must contain 4 AudioStreamPlayer nodes")
	for i in range(controller._sfx_players.size()):
		var p: AudioStreamPlayer = controller._sfx_players[i]
		assert(p.bus == &"SFX", "SFX pool player %d must route to dedicated SFX audio bus" % i)
	print("  • SFX Pool: 4 players initialized on &\"SFX\" bus")
	print("  ✓ Dedicated SFX bus and player pool verified!")

	# 4. Obstacle Collision Sounds Dispatch & Distinct Audio Mapping
	print("\n-> [4/5] Testing Distinct Collision Impact Sounds on Vehicle Hit...")
	var initial_lives: int = controller.current_lives

	# A: Normal Asteroid
	print("  • Testing Normal Asteroid collision SFX...")
	while controller.is_invulnerable:
		await physics_frame
	var hit_ok: bool = controller.register_obstacle_hit("unburned_asteroid", null)
	assert(hit_ok == true, "Hit must register")
	assert(controller.current_lives == initial_lives - 1, "Life must decrement")
	# Check SFX player was assigned normal asteroid impact
	var sfx_used: AudioStreamPlayer = null
	for p in controller._sfx_players:
		if p.stream != null and "normal_asteroid_impact" in p.stream.resource_path:
			sfx_used = p
			break
	assert(sfx_used != null, "Normal asteroid impact sound must be played on SFX bus")
	print("    ✓ Normal asteroid played: ", sfx_used.stream.resource_path)

	# B: Flaming Asteroid
	print("  • Testing Flaming Asteroid collision SFX...")
	while controller.is_invulnerable:
		await physics_frame
	var lives_before: int = controller.current_lives
	hit_ok = controller.register_obstacle_hit("burning_asteroid", null)
	assert(hit_ok == true, "Hit must register")
	assert(controller.current_lives == lives_before - 1, "Life must decrement")
	sfx_used = null
	for p in controller._sfx_players:
		if p.stream != null and "flaming_asteroid_impact" in p.stream.resource_path:
			sfx_used = p
			break
	assert(sfx_used != null, "Flaming asteroid impact sound must be played on SFX bus")
	print("    ✓ Flaming asteroid played: ", sfx_used.stream.resource_path)

	# Reset lives for food obstacle audio testing
	controller.current_lives = 3
	controller.is_invulnerable = false

	# C: Indian Food Obstacles (Soft Squish vs Crisp Thud vs Pop vs Bounce)
	print("  • Testing Indian Food Obstacle SFX mappings...")
	var food_tests := [
		{"id": "idli", "expected": "food_impact_soft_squish.wav"},
		{"id": "jalebi", "expected": "food_impact_soft_squish.wav"},
		{"id": "samosa", "expected": "food_impact_crisp_thud.wav"},
		{"id": "dosa", "expected": "food_impact_crisp_thud.wav"},
		{"id": "vada", "expected": "food_impact_crisp_thud.wav"},
		{"id": "murukku", "expected": "food_impact_crisp_thud.wav"},
		{"id": "pani_puri", "expected": "food_pani_puri_pop.wav"},
		{"id": "coconut", "expected": "food_coconut_bounce.wav"}
	]
	for ft in food_tests:
		while controller.is_invulnerable:
			await physics_frame
		controller.current_lives = 3
		controller._play_obstacle_impact_sfx(ft["id"], null)
		var matched: bool = false
		for p in controller._sfx_players:
			if p.stream != null and p.stream.resource_path.ends_with(ft["expected"]):
				matched = true
				break
		assert(matched, "Food %s must trigger %s" % [ft["id"], ft["expected"]])
		print("    ✓ Food '%s' mapped to '%s'" % [ft["id"], ft["expected"]])

	# D: Other Hazards (Pothole & Warning Marker)
	print("  • Testing Pothole & Warning Sound Triggers...")
	controller.play_sfx(controller.SFX_POTHOLE, -2.0)
	var pothole_played := false
	for p in controller._sfx_players:
		if p.stream != null and "pothole_suspension_thud" in p.stream.resource_path:
			pothole_played = true
			break
	assert(pothole_played, "Pothole suspension thud sound must play")
	print("    ✓ Pothole crater sound verified!")

	controller.play_sfx(controller.SFX_WARNING, -4.0)
	var warning_played := false
	for p in controller._sfx_players:
		if p.stream != null and "obstacle_warning_blip" in p.stream.resource_path:
			warning_played = true
			break
	assert(warning_played, "Warning marker blip sound must play")
	print("    ✓ Warning marker chime verified!")

	print("  ✓ All collision sounds, hazard sounds, and audio dispatches verified!")

	# 5. Clean Music Shutdown on Exit / Menu Press
	print("\n-> [5/5] Testing Clean Audio Stop on Exit to Main Menu...")
	assert(music_player.playing == true, "Music playing before exit")
	controller._on_menu_pressed()
	assert(music_player.playing == false, "Music must be stopped when returning to main menu")
	print("  ✓ Background music stops cleanly on exit (no audio leak to other game modes)!")

	print("\n=================================================================")
	print("✓ ALL SURVIVAL MODE AUDIO INTEGRATION TESTS PASSED (100%)!")
	print("=================================================================\n")

	survival.queue_free()
	quit(0)
