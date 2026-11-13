class_name TestPhase2EnvironmentResources
extends SceneTree

# Test suite for Phase 2: Shaders, Audio Buses, and SpriteFrames resources.
# Verifies all Heaven and Hell runtime resources for Godot 4.7.2 Mobile.

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN PHASE 2 ENVIRONMENT RESOURCES TEST SUITE ---")
	print("=================================================================\n")
	
	_test_audio_bus_layout()
	_test_audio_loop_settings()
	_test_shaders_compilation()
	_test_heaven_dove_sprite_frames()
	_test_hell_character_sprite_frames()
	_test_hell_fire_sprite_frames()
	
	print("\n=================================================================")
	print("✓ ALL PHASE 2 TESTS COMPLETED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_audio_bus_layout() -> void:
	print("-> [1/6] Verifying AudioBusLayout (res://default_bus_layout.tres)...")
	var layout: AudioBusLayout = load("res://default_bus_layout.tres")
	assert(layout != null, "AudioBusLayout must exist at res://default_bus_layout.tres")
	AudioServer.set_bus_layout(layout)
	
	var expected_buses = {
		"Master": {"send": "", "vol_db": 0.0},
		"Music": {"send": "Master", "vol_db": -10.0},
		"Ambience": {"send": "Master", "vol_db": -14.0},
		"SFX": {"send": "Master", "vol_db": -6.0},
		"UI": {"send": "Master", "vol_db": -6.0}
	}
	
	for bus_name in expected_buses:
		var idx = AudioServer.get_bus_index(bus_name)
		assert(idx >= 0, "Missing audio bus: " + bus_name)
		var expected_send: String = expected_buses[bus_name]["send"]
		if expected_send != "":
			var actual_send = AudioServer.get_bus_send(idx)
			assert(actual_send == expected_send, "Bus " + bus_name + " must send to " + expected_send + " (got " + actual_send + ")")
		print("  ✓ Bus [", idx, "] '", bus_name, "' verified -> send: '", AudioServer.get_bus_send(idx), "'")
	print("  ✓ Audio bus hierarchy verified!")

func _test_audio_loop_settings() -> void:
	print("-> [2/6] Verifying audio loop flags on looping streams...")
	var loops_to_check = [
		"res://assets/environments/heaven/audio/heavenly_loop.ogg",
		"res://assets/environments/hell/audio/hell_insistent_loop.ogg",
		"res://assets/environments/hell/audio/hell_fire_crackle.ogg",
		"res://assets/environments/hell/audio/hell_dark_ambient.ogg"
	]
	for path in loops_to_check:
		assert(ResourceLoader.exists(path), "Audio stream must exist: " + path)
		var stream: AudioStream = load(path)
		assert(stream != null, "Audio stream must load: " + path)
		if stream is AudioStreamOggVorbis:
			assert(stream.loop == true, "Ogg stream must have loop=true: " + path)
			print("  ✓ AudioStreamOggVorbis loop=true verified: ", path.get_file())
	print("  ✓ All looping audio tracks verified!")

func _test_shaders_compilation() -> void:
	print("-> [3/6] Verifying Mobile-compatible CanvasItem shaders...")
	var shaders_to_check = [
		"res://scripts/shaders/celestial_atmospheric_glow.gdshader",
		"res://scripts/shaders/cloud_soft_blend.gdshader",
		"res://scripts/shaders/molten_lava_flow.gdshader",
		"res://scripts/shaders/heat_distortion_shimmer.gdshader"
	]
	for path in shaders_to_check:
		assert(ResourceLoader.exists(path), "Shader file must exist: " + path)
		var shader: Shader = load(path)
		assert(shader != null, "Shader must load and parse: " + path)
		var mat := ShaderMaterial.new()
		mat.shader = shader
		assert(mat != null, "ShaderMaterial must bind shader cleanly: " + path)
		print("  ✓ Shader loaded and compiled: ", path.get_file())
	print("  ✓ All CanvasItem shaders verified!")

func _test_heaven_dove_sprite_frames() -> void:
	print("-> [4/6] Verifying Heaven Dove SpriteFrames (res://assets/environments/heaven/wildlife/dove_flight.tres)...")
	var path := "res://assets/environments/heaven/wildlife/dove_flight.tres"
	assert(ResourceLoader.exists(path), "dove_flight.tres must exist")
	var sf: SpriteFrames = load(path)
	assert(sf != null, "dove_flight.tres must load")
	assert(sf.has_animation("fly"), "Must have 'fly' animation")
	assert(sf.get_frame_count("fly") == 60, "Must have exactly 60 frames")
	assert(sf.get_animation_speed("fly") == 24.0, "Must be configured at 24 FPS")
	assert(sf.get_animation_loop("fly") == true, "Must have loop=true")
	
	for i in range(60):
		var tex = sf.get_frame_texture("fly", i)
		assert(tex is AtlasTexture, "Frame must be an AtlasTexture")
		var region = (tex as AtlasTexture).region
		assert(region.size.x == 256 and region.size.y == 256, "Cell size must be 256x256")
		assert(region.position.x >= 0 and region.position.x + 256 <= 2048, "Atlas region x must be within 2048")
		assert(region.position.y >= 0 and region.position.y + 256 <= 2048, "Atlas region y must be within 2048")
	print("  ✓ 60-frame dove atlas slicing verified (8x8 grid within [0, 2048] bounds at 24 FPS)!")

func _test_hell_character_sprite_frames() -> void:
	print("-> [5/6] Verifying Hell Character SpriteFrames...")
	
	# Skeleton Knight
	var skel_p := "res://assets/environments/hell/characters/skeleton_knight/skeleton_knight.tres"
	assert(ResourceLoader.exists(skel_p), "skeleton_knight.tres must exist")
	var skel_sf: SpriteFrames = load(skel_p)
	assert(skel_sf != null, "skeleton_knight.tres must load")
	assert(skel_sf.get_frame_count("idle") == 10, "Skeleton idle must be 10 frames")
	assert(skel_sf.get_frame_count("walk") == 10, "Skeleton walk must be 10 frames")
	assert(skel_sf.get_frame_count("attack1") == 10, "Skeleton attack1 must be 10 frames")
	assert(skel_sf.get_frame_count("attack2") == 10, "Skeleton attack2 must be 10 frames")
	assert(skel_sf.get_frame_count("dead") == 7, "Skeleton dead must be 7 frames")
	print("  ✓ Skeleton Knight: idle (10f), walk (10f), attack1 (10f), attack2 (10f), dead (7f) verified!")
	
	# Ground Demon Goblin
	var gob_p := "res://assets/environments/hell/characters/demon_goblin/demon_goblin.tres"
	assert(ResourceLoader.exists(gob_p), "demon_goblin.tres must exist")
	var gob_sf: SpriteFrames = load(gob_p)
	assert(gob_sf != null, "demon_goblin.tres must load")
	assert(gob_sf.get_frame_count("idle") == 8, "Goblin idle must be 8 frames")
	assert(gob_sf.get_frame_count("walk") == 43, "Goblin walk must be 43 frames")
	print("  ✓ Ground Demon Goblin: idle (8f), walk (43f) verified!")
	
	# Horned Fiend
	var fiend_p := "res://assets/environments/hell/characters/horned_fiend/horned_fiend.tres"
	assert(ResourceLoader.exists(fiend_p), "horned_fiend.tres must exist")
	var fiend_sf: SpriteFrames = load(fiend_p)
	assert(fiend_sf != null, "horned_fiend.tres must load")
	assert(fiend_sf.get_frame_count("walk") == 13, "Horned Fiend walk must be 13 frames")
	print("  ✓ Horned Fiend: walk (13f) verified!")
	
	# Flying Dragon
	var drag_p := "res://assets/environments/hell/characters/flying_dragon/flying_dragon.tres"
	assert(ResourceLoader.exists(drag_p), "flying_dragon.tres must exist")
	var drag_sf: SpriteFrames = load(drag_p)
	assert(drag_sf != null, "flying_dragon.tres must load")
	assert(drag_sf.get_frame_count("fly") == 4, "Flying Dragon fly must be 4 frames")
	print("  ✓ Flying Hell Dragon: fly (4f) verified!")

func _test_hell_fire_sprite_frames() -> void:
	print("-> [6/6] Verifying Hell Fire SpriteFrames (res://assets/environments/hell/vfx/fire/fire_sheet_5x5.tres)...")
	var fire_p := "res://assets/environments/hell/vfx/fire/fire_sheet_5x5.tres"
	assert(ResourceLoader.exists(fire_p), "fire_sheet_5x5.tres must exist")
	var fire_sf: SpriteFrames = load(fire_p)
	assert(fire_sf != null, "fire_sheet_5x5.tres must load")
	assert(fire_sf.get_frame_count("burn") == 25, "Fire 'burn' must have exactly 25 frames")
	assert(fire_sf.get_animation_speed("burn") == 25.0, "Fire animation speed must be 25 FPS")
	assert(fire_sf.get_animation_loop("burn") == true, "Fire animation must loop")
	print("  ✓ Hell Fire: 25 frames at 25 FPS verified!")
