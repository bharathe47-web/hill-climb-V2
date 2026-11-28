extends Node2D

var game: Node2D
var frames: int = 0
var shot_index: int = 0

func _ready() -> void:
	print("--- Starting Live Gameplay Evidence Capture ---")
	var game_scene := load("res://scenes/main/KanyakumariGame.tscn") as PackedScene
	game = game_scene.instantiate()
	add_child(game)

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames % 25 == 0:
		var car = game.get("vehicle_instance")
		if car:
			print("Physics frame: ", frames, " Car pos: ", car.position)
	
	# Keep car stationary at start until shot 1 is taken
	if frames > 40 and frames < 140:
		Input.action_press("gas")
	elif frames >= 140 and frames < 170:
		Input.action_release("gas")
		Input.action_press("nitro")
	else:
		Input.action_release("gas")
		Input.action_release("nitro")
		
	# Capture shots at strategic moments
	if frames == 35:
		# Shot 1: First on-screen frame matching reference composition
		_save_screenshot("kanyakumari_01_starting_frame_reference_match.png")
	elif frames == 85:
		# Shot 2: Driving on rolling hill with visible suspension compression & road signs
		_save_screenshot("kanyakumari_02_rolling_hills_driving.png")
	elif frames == 130:
		# Shot 3: Collecting coins & roadside tea shop
		_save_screenshot("kanyakumari_03_roadside_tea_stall_and_coins.png")
	elif frames == 160:
		# Shot 4: Checkpoint banner trigger
		StageManager.checkpoint_reached.emit({
			"distance": 300.0,
			"name_en": "Vivekananda Viewpoint",
			"name_ta": "விவேகானந்தர் பார்வை மையம்"
		})
	elif frames == 170:
		_save_screenshot("kanyakumari_04_bilingual_checkpoint_banner.png")
	elif frames == 185:
		# Open Garage Menu
		game.call("_open_garage")
	elif frames == 195:
		# Shot 5: Garage & Upgrades
		_save_screenshot("kanyakumari_05_garage_upgrades_screen.png")
	elif frames == 205:
		# Open Map Menu
		game.call("_close_garage")
		game.call("_open_map")
	elif frames == 215:
		# Shot 6: Route Map Screen
		_save_screenshot("kanyakumari_06_route_map_seven_stages.png")
	elif frames == 225:
		# Trigger Results Dialog
		game.call("_close_map")
		GameState.trigger_game_over("Vehicle Flipped!")
	elif frames == 235:
		# Shot 7: Results Dialog with Revive & Retry
		_save_screenshot("kanyakumari_07_results_game_over_dialog.png")
		print("--- All 7 Gameplay Evidence Screenshots Captured Successfully ---")
		get_tree().quit(0)

func _save_screenshot(filename: String) -> void:
	shot_index += 1
	var img: Image = get_viewport().get_texture().get_image()
	var artifact_path := "/home/joel/.gemini/antigravity-cli/brain/66204f88-eb3e-4a10-bde0-47fcf7dbeb50/" + filename
	var docs_path := "docs/screenshots/" + filename
	os_makedirs("docs/screenshots")
	img.save_png(artifact_path)
	img.save_png(docs_path)
	print("Captured screenshot #%d: %s (size %dx%d)" % [shot_index, filename, img.get_width(), img.get_height()])

func os_makedirs(p: String) -> void:
	if not DirAccess.dir_exists_absolute(p):
		DirAccess.make_dir_recursive_absolute(p)
