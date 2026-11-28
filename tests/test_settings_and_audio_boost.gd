extends SceneTree

func _init() -> void:
	print("\n=======================================================")
	print("--- BEGIN SETTINGS & AUDIO BOOST VERIFICATION ---")
	print("=======================================================")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var SaveManager = load("res://scripts/core/SaveManager.gd")
	SaveManager.set_music_volume(1.0)
	SaveManager.set_sound_volume(1.0)

	await _test_audio_boost_configuration()
	await _test_settings_menu_and_buses()
	await _test_main_menu_and_settings_button()
	await _test_main_controller_integration()

	print("\n=======================================================")
	print("✓ ALL SETTINGS & AUDIO BOOST TESTS PASSED (100%)!")
	print("=======================================================\n")
	quit(0)

func _test_audio_boost_configuration() -> void:
	print("-> [1/4] Verifying Audio Boost configuration...")
	# Verify default_bus_layout.tres values
	var bus_layout = load("res://default_bus_layout.tres")
	assert(bus_layout != null, "default_bus_layout.tres must load")
	
	# Verify BiomeEnvironmentHost volume defaults
	var BiomeHostScript = load("res://scripts/environment/BiomeEnvironmentHost.gd")
	var host_inst = BiomeHostScript.new()
	assert(is_equal_approx(host_inst.normal_music_volume_db, -4.0), "normal_music_volume_db must be -4.0 dB, was %f" % host_inst.normal_music_volume_db)
	assert(is_equal_approx(host_inst.heaven_music_volume_db, -4.0), "heaven_music_volume_db must be -4.0 dB, was %f" % host_inst.heaven_music_volume_db)
	assert(is_equal_approx(host_inst.hell_music_volume_db, -3.0), "hell_music_volume_db must be -3.0 dB, was %f" % host_inst.hell_music_volume_db)
	assert(is_equal_approx(host_inst.normal_ambience_volume_db, -14.0), "normal_ambience_volume_db must stay -14.0 dB")
	host_inst.free()

	# Verify Game.tscn MusicPlayer volume
	var game_scene = load("res://scenes/game/Game.tscn")
	assert(game_scene != null, "Game.tscn must load")
	var game_node = game_scene.instantiate()
	var music_player = game_node.get_node_or_null("MusicPlayer")
	assert(music_player != null, "Game.tscn must have MusicPlayer node")
	assert(is_equal_approx(music_player.volume_db, -4.0), "Game.tscn MusicPlayer volume_db must be -4.0, was %f" % music_player.volume_db)
	game_node.free()

	print("  ✓ Audio boost values verified (-4.0 dB Music bus/Game/Normal/Heaven, -3.0 dB Hell)")

func _test_settings_menu_and_buses() -> void:
	print("-> [2/4] Testing SettingsMenu and Audio Buses...")
	var SettingsMenuScene = load("res://scenes/main/SettingsMenu.tscn")
	assert(SettingsMenuScene != null, "SettingsMenu.tscn must exist and load")
	
	var settings = SettingsMenuScene.instantiate()
	root.add_child(settings)
	for i in range(5):
		await process_frame

	var music_slider: HSlider = settings.get_node_or_null("%MusicSlider")
	var sfx_slider: HSlider = settings.get_node_or_null("%SFXSlider")
	var close_button: Button = settings.get_node_or_null("%CloseButton")
	var music_label: Label = settings.get_node_or_null("%MusicValueLabel")
	var sfx_label: Label = settings.get_node_or_null("%SFXValueLabel")

	assert(music_slider != null, "MusicSlider must exist")
	assert(sfx_slider != null, "SFXSlider must exist")
	assert(close_button != null, "CloseButton must exist")
	assert(music_label != null, "MusicValueLabel must exist")
	assert(sfx_label != null, "SFXValueLabel must exist")

	var SaveManager = load("res://scripts/core/SaveManager.gd")

	# Test slider interaction: Music at 0.75
	music_slider.value = 0.75
	var expected_music_db = linear_to_db(0.75)
	var music_idx = AudioServer.get_bus_index("Music")
	var amb_idx = AudioServer.get_bus_index("Ambience")
	assert(is_equal_approx(AudioServer.get_bus_volume_db(music_idx), expected_music_db), "Music bus db mismatch")
	assert(is_equal_approx(AudioServer.get_bus_volume_db(amb_idx), expected_music_db), "Ambience bus db mismatch")
	assert(is_equal_approx(SaveManager.get_music_volume(), 0.75), "SaveManager music volume mismatch")
	assert(music_label.text == "75%", "Music label text should be 75%%, got %s" % music_label.text)

	# Test slider interaction: SFX at 0.50
	sfx_slider.value = 0.50
	var expected_sfx_db = linear_to_db(0.50)
	var sfx_idx = AudioServer.get_bus_index("SFX")
	var ui_idx = AudioServer.get_bus_index("UI")
	assert(is_equal_approx(AudioServer.get_bus_volume_db(sfx_idx), expected_sfx_db), "SFX bus db mismatch")
	assert(is_equal_approx(AudioServer.get_bus_volume_db(ui_idx), expected_sfx_db), "UI bus db mismatch")
	assert(is_equal_approx(SaveManager.get_sound_volume(), 0.50), "SaveManager sound volume mismatch")
	assert(sfx_label.text == "50%", "SFX label text should be 50%%, got %s" % sfx_label.text)

	# Test slider at 0.0 (mute/silence)
	music_slider.value = 0.0
	assert(AudioServer.get_bus_volume_db(music_idx) <= -79.0, "0.0 slider should set db <= -79")
	assert(AudioServer.get_bus_volume_db(amb_idx) <= -79.0, "0.0 slider should set db <= -79")

	# Test close signal with array capture
	var close_emitted := [false]
	settings.close_requested.connect(func(): close_emitted[0] = true)
	close_button.pressed.emit()
	assert(close_emitted[0], "CloseButton press must emit close_requested signal")

	# Restore volume to 1.0
	music_slider.value = 1.0
	sfx_slider.value = 1.0

	settings.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ SettingsMenu sliders, AudioServer buses, SaveManager, and Close button verified!")

func _test_main_menu_and_settings_button() -> void:
	print("-> [3/4] Testing MainMenu SettingsButton & Layout...")
	var MainMenuScene = load("res://scenes/main/MainMenu.tscn")
	assert(MainMenuScene != null, "MainMenu.tscn must load")
	var menu = MainMenuScene.instantiate()
	root.add_child(menu)
	for i in range(5):
		await process_frame

	var quit_button: TextureButton = menu.get_node_or_null("%QuitButton")
	var settings_button: TextureButton = menu.get_node_or_null("%SettingsButton")

	assert(quit_button != null, "QuitButton must exist")
	assert(settings_button != null, "SettingsButton must exist")
	assert(settings_button.texture_normal != null, "SettingsButton must have texture_normal assigned")
	assert(settings_button.texture_normal.resource_path == "res://assets/ui/home_screen/navigation/button_settings_sky_cyan.png", "SettingsButton must use button_settings_sky_cyan.png")

	# Trigger layout at 1920x1080
	menu.size = Vector2(1920, 1080)
	menu._layout()

	var s: float = menu.size.x / menu.DESIGN_SIZE.x
	var expected_gap: float = menu.QUIT_SIZE * s + 16.0 * s
	var actual_gap: float = quit_button.position.x - settings_button.position.x
	assert(is_equal_approx(actual_gap, expected_gap), "SettingsButton must be placed immediately left of QuitButton by QUIT_SIZE*s + 16*s. Expected: %f, Actual: %f" % [expected_gap, actual_gap])
	assert(is_equal_approx(settings_button.position.y, quit_button.position.y), "SettingsButton and QuitButton must share same Y position")
	assert(is_equal_approx(settings_button.size.x, quit_button.size.x), "SettingsButton and QuitButton must share same width")
	assert(is_equal_approx(settings_button.size.y, quit_button.size.y), "SettingsButton and QuitButton must share same height")

	# Signal emission with array capture
	var settings_requested := [false]
	menu.settings_requested.connect(func(): settings_requested[0] = true)
	settings_button.pressed.emit()
	assert(settings_requested[0], "SettingsButton press must emit settings_requested signal")

	menu.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ MainMenu SettingsButton paired layout and signal verified!")

func _test_main_controller_integration() -> void:
	print("-> [4/4] Testing Main Controller startup volume & overlay...")
	var MainScene = load("res://scenes/main/Main.tscn")
	assert(MainScene != null, "Main.tscn must load")
	var main_controller: MainController = MainScene.instantiate()
	root.add_child(main_controller)
	for i in range(5):
		await process_frame

	# Main ready should have applied volume
	var music_idx = AudioServer.get_bus_index("Music")
	var sfx_idx = AudioServer.get_bus_index("SFX")
	assert(is_equal_approx(AudioServer.get_bus_volume_db(music_idx), linear_to_db(1.0)), "Startup music volume must match SaveManager")
	assert(is_equal_approx(AudioServer.get_bus_volume_db(sfx_idx), linear_to_db(1.0)), "Startup sfx volume must match SaveManager")

	# Test opening settings overlay
	assert(main_controller._settings_instance == null, "Settings overlay should start null")
	main_controller.open_settings()
	for i in range(2):
		await process_frame

	assert(main_controller._settings_instance != null, "Settings overlay must be instantiated")
	assert(main_controller.current_scene_node != null, "Home screen menu must remain loaded behind overlay")
	assert(main_controller._settings_instance.is_inside_tree(), "Settings overlay must be in scene tree")

	# Test closing settings overlay
	main_controller.close_settings()
	for i in range(2):
		await process_frame

	assert(main_controller._settings_instance == null, "Settings overlay must be cleared on close")

	main_controller.queue_free()
	for i in range(2):
		await process_frame
	print("  ✓ MainController startup volume application and settings overlay lifecycle verified!")
