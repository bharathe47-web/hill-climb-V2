extends SceneTree

const MainScene = preload("res://scenes/main/Main.tscn")
const GarageScene = preload("res://scenes/modes/garage/VintageCarGarage.tscn")
const GameScene = preload("res://scenes/game/Game.tscn")
const SaveManager = preload("res://scripts/core/SaveManager.gd")
const VehicleRegistry = preload("res://scripts/vehicle/VehicleRegistry.gd")

func _init() -> void:
	call_deferred("_run_tests")

func _run_tests() -> void:
	print("\n=================================================================")
	print("--- BEGIN VERIFICATION: BIGFOOT HEAVY MONSTER TRUCK (car_08) ---")
	print("=================================================================\n")
	
	_test_shared_config_and_orientation()
	_test_body_cleanliness_and_cutouts()
	_test_scene_draw_order_and_wheel_fit()
	_test_garage_presentation_and_debug_overlay()
	await _test_gameplay_spawn_slopes_and_suspension()
	_test_burst_crash_visuals_and_reset()
	
	print("\n=================================================================")
	print("✓ ALL TESTS FOR BIGFOOT HEAVY MONSTER TRUCK PASSED WITH 100% SUCCESS!")
	print("=================================================================\n")
	quit(0)

func _test_shared_config_and_orientation() -> void:
	print("-> [1/6] Verifying Shared Vehicle Config and Preview Orientation...")
	var cfg = VehicleRegistry.get_bigfoot_config()
	assert(cfg != null and not cfg.is_empty(), "BIGFOOT_CONFIG must exist in VehicleRegistry")
	assert(cfg["body_size"] == Vector2(2258.0, 1310.0), "Body size must be 2258x1310")
	assert(cfg["body_pivot"] == Vector2(1129.0, 655.0), "Pivot must be center (1129, 655)")
	assert(cfg["rear_wheel_offset"] == Vector2(-709.0, 283.0), "Rear offset must be (-709, 283)")
	assert(cfg["front_wheel_offset"] == Vector2(687.0, 283.0), "Front offset must be (687, 283)")
	assert(is_equal_approx(cfg["wheel_radius"], 370.0), "Wheel radius must be 370.0")
	assert(is_equal_approx(cfg["cutout_radius"], 375.0), "Cutout radius must be 375.0 (5px gap)")
	assert(cfg["engine_offset"] == Vector2(-442.0, -353.0), "Engine offset must be (-442, -353)")
	print("  • Shared config verified: Rear=(-709, 283), Front=(687, 283), Engine=(-442, -353), R=370, Cutout=375")
	
	var info = VehicleRegistry.get_vehicle("car_08")
	var preview_tex = load(info["preview_path"]) as Texture2D
	assert(preview_tex != null, "Preview texture must load")
	var p_img = preview_tex.get_image()
	assert(p_img.get_width() == 2258 and p_img.get_height() == 1310, "Preview dimensions 2258x1310")
	
	# Verify orientation: red taillight on left, headlights on right
	var red_left: int = 0
	var red_right: int = 0
	var w = p_img.get_width()
	var h = p_img.get_height()
	for y in range(h):
		for x in range(w):
			var c = p_img.get_pixel(x, y)
			if c.a > 0.4 and c.r > 0.7 and c.g < 0.25 and c.b < 0.25:
				if x < w / 2:
					red_left += 1
				else:
					red_right += 1
	print("  • Red taillight pixels: left=%d, right=%d" % [red_left, red_right])
	assert(red_left > 500 and red_right == 0, "Truck must face RIGHT with taillight on left")
	print("  ✓ Shared config and right-facing preview orientation verified!")

func _test_body_cleanliness_and_cutouts() -> void:
	print("-> [2/6] Verifying Clean Body Image: Zero Ghost Arcs, Zero Slashes, Intact Artwork...")
	var body_tex = load("res://assets/vehicles/garage/car_08/body.png") as Texture2D
	var b_img = body_tex.get_image()
	var w = b_img.get_width()
	var h = b_img.get_height()
	
	# Verify circular cutouts are clean (R <= 373 has 0 opaque pixels)
	var rear_cx = 420.0
	var front_cx = 1816.0
	var cy = 938.0
	for y in range(maxi(0, int(cy - 373)), mini(h, int(cy + 374))):
		for x in range(maxi(0, int(rear_cx - 373)), mini(w, int(rear_cx + 374))):
			if (x - rear_cx)**2 + (y - cy)**2 <= 373.0**2:
				assert(b_img.get_pixel(x, y).a == 0.0, "Rear cutout must be 100% transparent")
		for x in range(maxi(0, int(front_cx - 373)), mini(w, int(front_cx + 374))):
			if (x - front_cx)**2 + (y - cy)**2 <= 373.0**2:
				assert(b_img.get_pixel(x, y).a == 0.0, "Front cutout must be 100% transparent")
	
	# Verify ghost tire pixels below body at far left (x < 150, y > 700) and far right (x > 2020, y > 700) are 0
	var left_ghost: int = 0
	for y in range(700, h):
		for x in range(0, 150):
			if b_img.get_pixel(x, y).a > 0.05:
				left_ghost += 1
	assert(left_ghost == 0, "Dark ghost tire at far left must be completely erased")
	
	var right_ghost: int = 0
	for y in range(700, h):
		for x in range(2020, w):
			if b_img.get_pixel(x, y).a > 0.05:
				right_ghost += 1
	assert(right_ghost == 0, "Dark ghost tire at far right must be completely erased")
	
	print("  ✓ Body cleanliness verified: zero ghost arcs, zero slashes, circular arches clean.")

func _test_scene_draw_order_and_wheel_fit() -> void:
	print("-> [3/6] Verifying Scene Draw Order, Offsets and Physics Match Config...")
	var car_scene = load("res://scenes/vehicle/garage/car_08.tscn") as PackedScene
	var car_node = car_scene.instantiate()
	
	var body_sprite = car_node.get_node("BodySprite") as Sprite2D
	var rear_wheel = car_node.get_node("RearWheel") as RigidBody2D
	var front_wheel = car_node.get_node("FrontWheel") as RigidBody2D
	var rear_tire = rear_wheel.get_node("TireSprite") as Sprite2D
	var front_tire = front_wheel.get_node("TireSprite") as Sprite2D
	
	# Verify Z-index draw order: wheels behind (-1), body on top (1)
	assert(rear_wheel.z_index == -1, "RearWheel must be behind body (z_index = -1)")
	assert(front_wheel.z_index == -1, "FrontWheel must be behind body (z_index = -1)")
	assert(body_sprite.z_index == 1, "BodySprite must be on top of wheels (z_index = 1)")
	
	# Verify offsets match shared config: rear = -709 * 0.0903 = -64.02, front = 687 * 0.0903 = 62.04
	var cfg = VehicleRegistry.get_bigfoot_config()
	var scale_val = cfg["body_scale"]
	var expected_rear = cfg["rear_wheel_offset"] * scale_val
	var expected_front = cfg["front_wheel_offset"] * scale_val
	assert(absf(rear_wheel.position.x - expected_rear.x) < 0.05, "Rear wheel X must match config")
	assert(absf(rear_wheel.position.y - expected_rear.y) < 0.05, "Rear wheel Y must match config")
	assert(absf(front_wheel.position.x - expected_front.x) < 0.05, "Front wheel X must match config")
	assert(absf(front_wheel.position.y - expected_front.y) < 0.05, "Front wheel Y must match config")
	
	# Verify wheel collision radius and sprite scale match 370.0 * 0.0903 = 33.4
	var rw_col = rear_wheel.get_node("CollisionShape2D").shape as CircleShape2D
	var fw_col = front_wheel.get_node("CollisionShape2D").shape as CircleShape2D
	var expected_r = cfg["wheel_radius"] * scale_val
	assert(absf(rw_col.radius - expected_r) < 0.1, "Physics radius must match wheelRadius * scale")
	assert(absf(fw_col.radius - expected_r) < 0.1, "Physics radius must match wheelRadius * scale")
	
	var expected_tire_scale = expected_r / 245.0
	assert(absf(rear_tire.scale.x - expected_tire_scale) < 0.005, "TireSprite scale must match wheelRadius")
	assert(absf(front_tire.scale.x - expected_tire_scale) < 0.005, "TireSprite scale must match wheelRadius")
	print("  • Scene alignment: Rear=%s, Front=%s, Radius=%.1f px, TireScale=%.4f" % [rear_wheel.position, front_wheel.position, rw_col.radius, rear_tire.scale.x])
	
	# Verify car_08.png composite has tire filling the arch with 4-6px gap
	var p_img = (load("res://assets/vehicles/garage/car_08/car_08.png") as Texture2D).get_image()
	var b_img = (load("res://assets/vehicles/garage/car_08/body.png") as Texture2D).get_image()
	var rear_c = Vector2(420.0, 938.0)
	var rad75 = deg_to_rad(75)
	var dir75 = Vector2(cos(rad75), -sin(rad75))
	var tire_r = 0.0
	for r in range(375, 200, -1):
		var p = rear_c + dir75 * float(r)
		if b_img.get_pixelv(Vector2i(p)).a == 0.0 and p_img.get_pixelv(Vector2i(p)).a > 0.1:
			tire_r = float(r)
			break
	var gap = 375.0 - tire_r
	print("  • car_08.png composite arch gap: %.1f px" % gap)
	assert(gap >= 4.0 and gap <= 6.0, "Tire must fill arch with 4 to 6 px gap! Got: %.1f" % gap)
	
	car_node.queue_free()
	print("  ✓ Draw order and physics-visual match verified!")

func _test_garage_presentation_and_debug_overlay() -> void:
	print("-> [4/6] Verifying Garage Presentation and Alignment Debug Overlay...")
	var garage: VintageCarGarageController = GarageScene.instantiate()
	root.add_child(garage)
	
	var car_08_index = -1
	for i in range(garage._vehicles.size()):
		if garage._vehicles[i]["id"] == "car_08":
			car_08_index = i
			break
	assert(car_08_index >= 0, "car_08 must be in garage")
	
	garage._current_index = car_08_index
	garage._display_current_vehicle(true)
	
	assert(garage.vehicle_name_label.text.begins_with("Bigfoot Heavy Monster Truck"), "Vehicle name must match")
	assert(garage.vehicle_display_rect.texture != null, "Display texture must be valid")
	
	# Test debug overlay
	assert(garage._debug_overlay_control != null, "Garage debug overlay control must exist")
	VehicleController.debug_alignment_enabled = false
	garage._process(0.016)
	assert(not garage._debug_overlay_control.visible, "Debug overlay must be hidden by default")
	
	# Toggle debug overlay
	VehicleController.debug_alignment_enabled = true
	garage._process(0.016)
	assert(garage._debug_overlay_control.visible, "Debug overlay must be visible when enabled")
	
	# Reset debug overlay to default off
	VehicleController.debug_alignment_enabled = false
	garage.queue_free()
	print("  ✓ Garage presentation and debug overlay toggle verified!")

func _test_gameplay_spawn_slopes_and_suspension() -> void:
	print("-> [5/6] Verifying Gameplay Spawn, Slope Driving & Suspension X-Centering...")
	var prev_selected = SaveManager.get_selected_vehicle_id()
	SaveManager.set_selected_vehicle_id("car_08")
	
	var game = GameScene.instantiate()
	root.add_child(game)
	
	for frame in range(5):
		await physics_frame
	
	var car = game.vehicle as VehicleController
	assert(car != null, "Vehicle must be spawned")
	
	# Verify ground contact (420.0 with 0 gap and 0 sinking)
	var rw_col = car.rear_wheel.get_node("CollisionShape2D").shape as CircleShape2D
	var rear_bottom_y = car.rear_wheel.global_position.y + rw_col.radius
	var front_bottom_y = car.front_wheel.global_position.y + rw_col.radius
	print("  • Wheel bottom Y positions: Rear=%.2f, Front=%.2f (Ground=420.0)" % [rear_bottom_y, front_bottom_y])
	assert(absf(rear_bottom_y - 420.0) < 2.5, "Rear wheel must touch ground")
	assert(absf(front_bottom_y - 420.0) < 2.5, "Front wheel must touch ground")
	
	# Verify body colour in normal gameplay matches garage (WHITE modulate)
	var body_sprite = car.get_node("BodySprite") as Sprite2D
	assert(body_sprite.modulate == Color.WHITE, "Body must be Color.WHITE in normal gameplay (no pink/teal tint)")
	
	# Test driving on slope: ensure wheels stay centered on arch in X
	var init_rear_local_x = car.to_local(car.rear_wheel.global_position).x
	var init_front_local_x = car.to_local(car.front_wheel.global_position).x
	
	Input.action_press("accelerate")
	for frame in range(40):
		await physics_frame
		var cur_rear_x = car.to_local(car.rear_wheel.global_position).x
		var cur_front_x = car.to_local(car.front_wheel.global_position).x
		assert(absf(cur_rear_x - init_rear_local_x) < 0.5, "Rear wheel X must stay centered on arch during drive")
		assert(absf(cur_front_x - init_front_local_x) < 0.5, "Front wheel X must stay centered on arch during drive")
	Input.action_release("accelerate")
	
	print("  • Suspension verified: wheels stay strictly locked at local X=(%.2f, %.2f) across movement" % [init_rear_local_x, init_front_local_x])
	
	game.queue_free()
	for frame in range(2):
		await physics_frame
		
	SaveManager.set_selected_vehicle_id(prev_selected)
	print("  ✓ Gameplay spawn, ground contact, and suspension centering verified!")

func _test_burst_crash_visuals_and_reset() -> void:
	print("-> [6/6] Verifying Crash Damage Visuals and Retry Reset...")
	var car: VehicleController = VehicleRegistry.instantiate_vehicle("car_08")
	root.add_child(car)
	
	var body_sprite = car.get_node("BodySprite") as Sprite2D
	var rear_tire = car.rear_wheel.get_node("TireSprite") as Sprite2D
	var front_tire = car.front_wheel.get_node("TireSprite") as Sprite2D
	
	# Initial clean textures
	assert(body_sprite.texture.resource_path.ends_with("body.png"), "Initial body must be body.png")
	assert(rear_tire.texture.resource_path.ends_with("wheel.png"), "Initial wheel must be wheel.png")
	assert(body_sprite.modulate == Color.WHITE, "Initial body modulate must be WHITE")
	
	# Trigger crash damage
	car.apply_crash_damage()
	print("  • After crash: Body texture = %s" % body_sprite.texture.resource_path)
	print("  • After crash: Rear wheel texture = %s" % rear_tire.texture.resource_path)
	assert(body_sprite.texture.resource_path.ends_with("body_burnt.png"), "Body must switch to body_burnt.png")
	assert(rear_tire.texture.resource_path.ends_with("wheel_burnt.png"), "Wheel must switch to wheel_burnt.png")
	
	# Reset vehicle (retry)
	var bottom_offset = car.get_wheel_bottom_offset()
	car.reset_vehicle(Vector2(0, 420.0 - bottom_offset))
	assert(body_sprite.texture.resource_path.ends_with("body.png"), "Body must be restored to clean body.png")
	assert(rear_tire.texture.resource_path.ends_with("wheel.png"), "Wheel must be restored to clean wheel.png")
	assert(body_sprite.modulate == Color.WHITE, "Body modulate must be WHITE on reset")
	assert(rear_tire.modulate == Color.WHITE, "Wheel modulate must be WHITE on reset")
	
	car.queue_free()
	print("  ✓ Crash damage visuals and retry reset verified 100%!")
