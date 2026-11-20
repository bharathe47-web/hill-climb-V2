extends SceneTree

const BurningAsteroidScene = preload("res://scenes/modes/survival/obstacles/burning_asteroid_obstacle.tscn")
const UnburnedAsteroidScene = preload("res://scenes/modes/survival/obstacles/unburned_asteroid_obstacle.tscn")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN FLAMING ASTEROID ARTWORK & SPEED VERIFICATION ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	# 1. Verify Burning Asteroid Scene & Artwork
	print("-> [1/4] Verifying New Flaming Asteroid Artwork & Sprite Assignment...")
	var b_ast = BurningAsteroidScene.instantiate()
	root.add_child(b_ast)
	for i in range(2):
		await process_frame
		
	var sprite: Sprite2D = b_ast.get_node_or_null("Sprite2D")
	assert(sprite != null and sprite.texture != null, "BurningAsteroid must have Sprite2D with texture")
	var tex_path: String = sprite.texture.resource_path
	print("  • Burning Asteroid sprite texture: ", tex_path)
	assert("flaming_asteroid" in tex_path or "burning_asteroid_main_sprite" in tex_path, "Uses new flaming asteroid asset")
	
	# Verify texture is valid image with non-zero size
	var img: Image = sprite.texture.get_image()
	assert(img != null and img.get_width() > 0 and img.get_height() > 0, "Texture must be valid loaded image")
	print("  • Texture dimensions: %dx%d" % [img.get_width(), img.get_height()])
	print("  ✓ New flaming asteroid artwork verified!")

	# 2. Verify Speed Reduction (Moderately Slower Fall)
	print("-> [2/4] Verifying Moderate Fall Speed Reduction...")
	print("  • Configured fall_speed: %0.1f (was 520.0)" % b_ast.fall_speed)
	print("  • Configured fall_acceleration: %0.1f (was 500.0)" % b_ast.fall_acceleration)
	assert(b_ast.fall_speed <= 360.0, "fall_speed must be reduced from 520.0 (actual: %f)" % b_ast.fall_speed)
	assert(b_ast.fall_speed >= 250.0, "fall_speed must remain a meaningful threat (actual: %f)" % b_ast.fall_speed)
	assert(b_ast.fall_acceleration <= 250.0, "fall_acceleration must be reduced from 500.0 (actual: %f)" % b_ast.fall_acceleration)
	print("  ✓ Fall speed and acceleration moderately reduced for clear visual recognition!")

	# 3. Simulate Airborne Descent Timing & Visual Visibility
	print("-> [3/4] Simulating Airborne Descent Timing...")
	b_ast.setup_spawn(400.0, 0.0, 500.0)
	var start_y: float = b_ast.global_position.y
	var sim_time: float = 0.0
	var sim_delta: float = 0.016
	while not b_ast.has_touched_ground and sim_time < 3.0:
		b_ast._process(sim_delta)
		sim_time += sim_delta
		
	print("  • Descent from y=%0.1f to y=%0.1f took %0.2f seconds" % [start_y, b_ast.global_position.y, sim_time])
	assert(sim_time >= 1.0, "Descent duration must be >= 1.0s to allow clear visibility of flames (actual: %0.2fs)" % sim_time)
	assert(sim_time <= 2.2, "Descent duration must be <= 2.2s so obstacle remains threatening (actual: %0.2fs)" % sim_time)
	assert(b_ast.has_touched_ground, "Asteroid must reach ground naturally")
	print("  ✓ Smooth descent timing and natural ground contact verified!")

	# 4. Verify Unburned Asteroid Is Unmodified
	print("-> [4/4] Verifying Unburned Asteroid (Medium Mode) Remains Intact...")
	var unburned = UnburnedAsteroidScene.instantiate()
	root.add_child(unburned)
	for i in range(2):
		await process_frame
		
	assert(unburned.obstacle_id == "unburned_asteroid", "Unburned asteroid identity preserved")
	assert(unburned.fall_speed == 460.0, "Unburned asteroid speed preserved")
	print("  ✓ Medium mode unburned asteroid completely unaffected!")

	b_ast.queue_free()
	unburned.queue_free()

	print("\n=================================================================")
	print("✓ ALL FLAMING ASTEROID TESTS PASSED 100%!")
	print("=================================================================\n")
	quit(0)
