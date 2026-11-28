extends SceneTree

const BiomeEnvironmentHostScene = preload("res://scenes/environment/BiomeEnvironmentHost.tscn")
const SurvivalScene = preload("res://scenes/modes/survival/Survival.tscn")
const IndianRoadsModeV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadsModeV2.tscn")

func _init() -> void:
	print("\n=======================================================")
	print("--- BEGIN ALL MODES BACKGROUND MUSIC VERIFICATION ---")
	print("=======================================================")
	call_deferred("_run_tests")

func _run_tests() -> void:
	await _test_endless_audio()
	await _test_survival_audio()
	await _test_indian_roads_audio()
	
	print("\n=======================================================")
	print("✓ ALL BACKGROUND MUSIC TESTS PASSED WITH 100% SUCCESS!")
	print("=======================================================\n")
	quit(0)

func _test_endless_audio() -> void:
	print("-> [1/3] Testing Endless Mode Audio (Normal, Heaven, Hell)...")
	var host = BiomeEnvironmentHostScene.instantiate()
	root.add_child(host)
	await process_frame
	
	# Verify stream resource paths
	assert(host.STREAM_NORMAL_MUSIC.resource_path.ends_with("normal.mp3"), "Normal music must be normal.mp3")
	assert(host.STREAM_HEAVEN_MUSIC.resource_path.ends_with("heaven.mp3"), "Heaven music must be heaven.mp3")
	assert(host.STREAM_HELL_MUSIC.resource_path.ends_with("hell.mp3"), "Hell music must be hell.mp3")
	
	# Initial state should be Normal Land
	assert(host._active_music_player.stream == host.STREAM_NORMAL_MUSIC, "Active music must be normal.mp3")
	assert(host._active_music_player.playing, "Active music player must be playing")
	assert(host._active_music_player.bus == &"Music", "Music player must route to 'Music' bus")
	
	# Crossfade to Heaven
	host.crossfade_music(host.STREAM_HEAVEN_MUSIC, -10.0, 0.1)
	assert(host._active_music_player.stream == host.STREAM_HEAVEN_MUSIC, "Crossfaded active music must be heaven.mp3")
	assert(host._active_music_player.playing, "Heaven music must be playing")
	
	# Crossfade to Hell
	host.crossfade_music(host.STREAM_HELL_MUSIC, -8.0, 0.1)
	assert(host._active_music_player.stream == host.STREAM_HELL_MUSIC, "Crossfaded active music must be hell.mp3")
	assert(host._active_music_player.playing, "Hell music must be playing")
	
	# Test pause/resume
	host.set_audio_paused(true)
	assert(host._active_music_player.stream_paused, "Active music player must be paused")
	host.set_audio_paused(false)
	assert(not host._active_music_player.stream_paused, "Active music player must resume")
	
	root.remove_child(host)
	host.free()
	print("  ✓ Endless mode music (normal.mp3, heaven.mp3, hell.mp3) verified!")

func _test_survival_audio() -> void:
	print("-> [2/3] Testing Survival Mode Difficulty-Based Music...")
	var survival = SurvivalScene.instantiate()
	root.add_child(survival)
	for i in range(5):
		await process_frame
	
	var music_player = survival.music_player
	assert(is_instance_valid(music_player), "Survival music player must exist")
	assert(music_player.bus == &"Music", "Survival music must be on 'Music' bus")
	assert(music_player.playing, "Survival music must be playing")
	
	# Test Easy difficulty (0)
	survival.set_difficulty(0)
	await process_frame
	assert(music_player.stream == survival.BGM_SURVIVAL_EASY, "Difficulty 0 must play BGM_SURVIVAL_EASY")
	assert(music_player.stream.resource_path.ends_with("easy-survial.mp3"), "Easy stream must be easy-survial.mp3")
	assert(music_player.playing, "Music must be playing after set_difficulty(0)")
	
	# Test Medium difficulty (1)
	survival.set_difficulty(1)
	await process_frame
	assert(music_player.stream == survival.BGM_SURVIVAL_MEDIUM, "Difficulty 1 must play BGM_SURVIVAL_MEDIUM")
	assert(music_player.stream.resource_path.ends_with("survival-mid.mp3"), "Medium stream must be survival-mid.mp3")
	assert(music_player.playing, "Music must be playing after set_difficulty(1)")
	
	# Test Hard difficulty (2)
	survival.set_difficulty(2)
	await process_frame
	assert(music_player.stream == survival.BGM_SURVIVAL_HARD, "Difficulty 2 must play BGM_SURVIVAL_HARD")
	assert(music_player.stream.resource_path.ends_with("hard.mp3"), "Hard stream must be hard.mp3")
	assert(music_player.playing, "Music must be playing after set_difficulty(2)")
	
	# Test pause / resume
	survival.pause_run(true)
	assert(music_player.stream_paused, "Survival music must pause on pause_run(true)")
	survival.pause_run(false)
	assert(not music_player.stream_paused, "Survival music must unpause on pause_run(false)")
	
	# Test loop on finished signal
	music_player._on_music_finished() if music_player.has_method("_on_music_finished") else survival._on_music_finished()
	assert(music_player.playing, "Music must restart on finished signal")
	
	root.remove_child(survival)
	survival.free()
	print("  ✓ Survival mode difficulty-based music (easy, mid, hard) verified!")

func _test_indian_roads_audio() -> void:
	print("-> [3/3] Testing Indian Roads Mode V2 Music...")
	var ir = IndianRoadsModeV2Scene.instantiate()
	root.add_child(ir)
	for i in range(5):
		await process_frame
	
	var music_player = ir.get_node_or_null("MusicPlayer")
	assert(is_instance_valid(music_player), "IndianRoadsModeV2 must have a MusicPlayer node")
	assert(music_player.bus == &"Music", "Indian Roads music must be on 'Music' bus")
	assert(music_player.stream != null, "Music player must have stream assigned")
	assert(music_player.stream.resource_path.ends_with("hitslab-indian-indian-music-634358.mp3"),
		"Indian Roads music must be hitslab-indian-indian-music-634358.mp3")
	assert(music_player.playing, "Indian Roads music must start playing on load")
	
	# Test pause / resume
	ir._on_pause_requested()
	assert(music_player.stream_paused, "Indian Roads music must pause on pause_requested")
	ir._on_resume_requested()
	assert(not music_player.stream_paused, "Indian Roads music must resume on resume_requested")
	
	# Test map open / close pause
	ir._on_map_requested()
	assert(music_player.stream_paused, "Indian Roads music must pause when map is requested")
	ir._on_map_closed()
	assert(not music_player.stream_paused, "Indian Roads music must resume when map is closed")
	
	# Test loop on finished signal
	ir._on_music_finished()
	assert(music_player.playing, "Indian Roads music must replay on finished signal")
	
	root.remove_child(ir)
	ir.free()
	print("  ✓ Indian Roads mode music and pause/resume verified!")
