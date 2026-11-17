@tool
extends SceneTree

## Comprehensive visual inspection and snapshot capture across Normal Land, Heaven, and Hell

func _init() -> void:
	print("--- BEGIN VISUAL QUALITY INSPECTION & SCREENSHOT CAPTURE ---")
	await _run_inspection()
	quit(0)

func _run_inspection() -> void:
	var dir := DirAccess.open("res://docs/previews")
	if not dir:
		DirAccess.make_dir_recursive_absolute("res://docs/previews")

	var packed: PackedScene = load("res://scenes/game/Game.tscn")
	if not packed:
		printerr("Failed to load Game.tscn")
		return

	var sub_viewport := SubViewport.new()
	sub_viewport.size = Vector2i(1280, 720)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sub_viewport)

	var game_inst: GameScene = packed.instantiate() as GameScene
	game_inst.use_procedural_terrain = true
	sub_viewport.add_child(game_inst)

	# 1. Capture Normal Land driving (frame 120, ~2 sec of driving)
	print("1. Simulating Normal Land driving...")
	for i in range(120):
		if is_instance_valid(game_inst.vehicle):
			game_inst.vehicle.set("throttle_input", 1.0)
		await physics_frame
		await process_frame

	var img1: Image = sub_viewport.get_texture().get_image()
	if img1:
		img1.save_png("res://docs/previews/gameplay_normal_land_driving.png")
		print("  ✓ Saved docs/previews/gameplay_normal_land_driving.png")

	# 2. Drive further to inspect undulations and scenery alignment (frame 240)
	print("2. Simulating extended driving on hills...")
	for i in range(120):
		if is_instance_valid(game_inst.vehicle):
			game_inst.vehicle.set("throttle_input", 1.0)
		await physics_frame
		await process_frame

	var img2: Image = sub_viewport.get_texture().get_image()
	if img2:
		img2.save_png("res://docs/previews/gameplay_hills_scenery.png")
		print("  ✓ Saved docs/previews/gameplay_hills_scenery.png")

	# 3. Simulate transition to Heaven (distance 1500m)
	print("3. Capturing Heaven gameplay...")
	if is_instance_valid(game_inst.vehicle):
		game_inst.vehicle.global_position = Vector2(1600.0, 300.0)
		if is_instance_valid(game_inst.follow_camera):
			game_inst.follow_camera.global_position = game_inst.vehicle.global_position
	
	for i in range(30):
		if is_instance_valid(game_inst.vehicle):
			game_inst.vehicle.set("throttle_input", 0.8)
		await physics_frame
		await process_frame

	var img3: Image = sub_viewport.get_texture().get_image()
	if img3:
		img3.save_png("res://docs/previews/gameplay_heaven_driving.png")
		print("  ✓ Saved docs/previews/gameplay_heaven_driving.png")

	# 4. Simulate transition to Hell (distance 4200m)
	print("4. Capturing Hell gameplay...")
	if is_instance_valid(game_inst.vehicle):
		game_inst.vehicle.global_position = Vector2(4200.0, 300.0)
		if is_instance_valid(game_inst.follow_camera):
			game_inst.follow_camera.global_position = game_inst.vehicle.global_position
	
	for i in range(30):
		if is_instance_valid(game_inst.vehicle):
			game_inst.vehicle.set("throttle_input", 0.8)
		await physics_frame
		await process_frame

	var img4: Image = sub_viewport.get_texture().get_image()
	if img4:
		img4.save_png("res://docs/previews/gameplay_hell_driving.png")
		print("  ✓ Saved docs/previews/gameplay_hell_driving.png")

	# Teardown
	game_inst.queue_free()
	for i in range(3):
		await process_frame
	sub_viewport.queue_free()
	for i in range(3):
		await process_frame
