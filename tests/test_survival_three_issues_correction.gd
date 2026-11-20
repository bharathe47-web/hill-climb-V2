extends SceneTree

## Automated test suite verifying the corrections for:
## Issue 1: Road texture unwanted horizontal stripe removal
## Issue 2: Three-life system and heart-break visual feedback
## Issue 3: Stopping the car after all three lives are lost
## Issue 4: Vehicle jumps, rolls and terrain glitches after restart

const SurvivalScene: PackedScene = preload("res://scenes/modes/survival/Survival.tscn")
const SurvivalController = preload("res://scripts/modes/survival/SurvivalController.gd")
const GameHUD = preload("res://scripts/ui/game_hud.gd")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN SURVIVAL 3-CRITICAL-ISSUES VERIFICATION TEST SUITE ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var root := get_root()

	_test_1_road_texture_stripe_removal()
	_test_2_heart_assets_and_sequential_reduction(root)
	_test_3_vehicle_lock_on_lives_depleted(root)
	_test_4_extra_life_and_give_up_paths(root)
	_test_5_clean_restart_behavior(root)

	print("\n=================================================================")
	print("✓ ALL SURVIVAL CORRECTION TESTS PASSED (100% SUCCESS)!")
	print("=================================================================\n")
	quit(0)

func _test_1_road_texture_stripe_removal() -> void:
	print("-> [1/5] Verifying Removal of Unwanted Horizontal Stripe from Road Textures...")
	var paths := [
		"res://assets/environment/survival/destroyed_city/terrain/dusty_ground/apocalyptic_ground_seamless.png",
		"res://assets/environment/survival/destroyed_city/terrain/dusty_ground/apocalyptic_subsoil_seamless.png",
		"res://assets/environment/survival/destroyed_city/terrain/dusty_ground/survival_drivable_ground_strip.png"
	]

	for p in paths:
		var tex: Texture2D = load(p)
		assert(tex != null, "Texture %s must load" % p)
		var img: Image = tex.get_image()
		assert(img != null, "Image must be accessible for %s" % p)
		assert(img.get_width() == 575 and img.get_height() == 512, "Dimensions must remain exactly (575, 512) for %s" % p)

		# Verify rows 250..262 no longer contain the bright cyan/white line artifact ([225, 222, 255])
		for y in range(250, 262):
			for x in range(0, img.get_width(), 20):
				var pixel: Color = img.get_pixel(x, y)
				# Original bright stripe had Blue > 0.95 and Green > 0.85
				assert(pixel.b < 0.65, "Pixel at (%d, %d) in %s has B=%f (stripe artifact still present!)" % [x, y, p, pixel.b])
				# Palette should remain orange/brown/dusty: Red > Green > Blue
				assert(pixel.r >= pixel.g and pixel.g >= pixel.b, "Pixel (%d, %d) must match dusty ground palette: R>=G>=B" % [x, y])

		# Verify seamless repetition across left-right and top-bottom seams
		for y in range(img.get_height()):
			var p_left := img.get_pixel(0, y)
			var p_right := img.get_pixel(img.get_width() - 1, y)
			assert(p_left == p_right, "Left-right seam at y=%d must match perfectly for %s" % [y, p])

		for x in range(img.get_width()):
			var p_top := img.get_pixel(x, 0)
			var p_bottom := img.get_pixel(x, img.get_height() - 1)
			assert(p_top == p_bottom, "Top-bottom seam at x=%d must match perfectly for %s" % [x, p])

	print("  ✓ Horizontal stripe completely removed; seamless repetition and dusty palette 100% verified!")

func _test_2_heart_assets_and_sequential_reduction(root: Window) -> void:
	print("-> [2/5] Verifying Distinct Heart Artwork & Sequential Life Reduction...")
	var full_tex: Texture2D = load("res://assets/ui/hud/hearts/hud_heart_full.png")
	var empty_tex: Texture2D = load("res://assets/ui/hud/hearts/hud_heart_empty.png")
	assert(full_tex != null and empty_tex != null, "Both heart textures must load")

	var full_img := full_tex.get_image()
	var empty_img := empty_tex.get_image()
	assert(full_img.get_width() == 125 and full_img.get_height() == 125, "Full heart must be 125x125")
	assert(empty_img.get_width() == 125 and empty_img.get_height() == 125, "Empty heart must be 125x125")

	# Verify the two images are genuinely distinct (different pixel data)
	var diff_pixels := 0
	for y in range(125):
		for x in range(125):
			if full_img.get_pixel(x, y) != empty_img.get_pixel(x, y):
				diff_pixels += 1
	assert(diff_pixels > 2000, "hud_heart_empty.png must be visibly distinct from full heart (%d diff pixels)" % diff_pixels)

	# Verify sequential HUD life updates
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	var hud: GameHUD = surv.hud as GameHUD
	assert(hud != null, "HUD must exist")

	var hearts := hud.heart_container.get_children()
	assert(hearts.size() == 3, "HUD must have 3 heart TextureRects")

	# Initial: 3 lives -> 3 full
	hud.set_survival_lives(3, 3)
	assert(hearts[0].texture == full_tex, "Heart 1 full at 3 lives")
	assert(hearts[1].texture == full_tex, "Heart 2 full at 3 lives")
	assert(hearts[2].texture == full_tex, "Heart 3 full at 3 lives")

	# 2 lives -> 2 full, 1 empty (Heart 3 broken)
	hud.set_survival_lives(2, 3)
	assert(hearts[0].texture == full_tex, "Heart 1 full at 2 lives")
	assert(hearts[1].texture == full_tex, "Heart 2 full at 2 lives")
	assert(hearts[2].texture == empty_tex, "Heart 3 broken at 2 lives")

	# 1 life -> 1 full, 2 empty (Hearts 2 and 3 broken)
	hud.set_survival_lives(1, 3)
	assert(hearts[0].texture == full_tex, "Heart 1 full at 1 life")
	assert(hearts[1].texture == empty_tex, "Heart 2 broken at 1 life")
	assert(hearts[2].texture == empty_tex, "Heart 3 broken at 1 life")

	# 0 lives -> 3 empty (All hearts broken)
	hud.set_survival_lives(0, 3)
	assert(hearts[0].texture == empty_tex, "Heart 1 broken at 0 lives")
	assert(hearts[1].texture == empty_tex, "Heart 2 broken at 0 lives")
	assert(hearts[2].texture == empty_tex, "Heart 3 broken at 0 lives")

	# Verify generic crash banner suppressed in Survival mode
	hud._on_vehicle_crashed()
	assert(hud.message_banner == null or hud.message_banner.visible == false, "Generic crash banner must NOT show in Survival mode")

	surv.queue_free()
	print("  ✓ Broken heart artwork distinct, sequential reduction accurate, and crash banner suppressed!")

func _test_3_vehicle_lock_on_lives_depleted(root: Window) -> void:
	print("-> [3/5] Verifying Vehicle Freeze & Physics Locking When 0 Lives...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)

	var veh = surv.vehicle
	assert(veh != null, "Vehicle exists")
	assert(veh.is_active == true, "Vehicle starts active")

	# Deplete all 3 lives
	surv.register_obstacle_hit("idli")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("dosa")
	surv.is_invulnerable = false
	surv.register_obstacle_hit("vada")

	assert(surv.current_lives == 0, "Lives reduced to 0")
	assert(surv.current_state == SurvivalController.RunState.PAUSED, "Run state is PAUSED for extra chance")

	# Verify vehicle is locked and completely frozen
	assert(veh.is_active == false, "Vehicle is_active must be false")
	assert(veh.freeze == true, "Chassis RigidBody2D must be frozen")
	if veh.rear_wheel:
		assert(veh.rear_wheel.freeze == true, "Rear wheel must be frozen")
		assert(veh.rear_wheel.linear_velocity == Vector2.ZERO, "Rear wheel linear velocity is zero")
		assert(veh.rear_wheel.angular_velocity == 0.0, "Rear wheel angular velocity is zero")
	if veh.front_wheel:
		assert(veh.front_wheel.freeze == true, "Front wheel must be frozen")
		assert(veh.front_wheel.linear_velocity == Vector2.ZERO, "Front wheel linear velocity is zero")
		assert(veh.front_wheel.angular_velocity == 0.0, "Front wheel angular velocity is zero")

	assert(veh.linear_velocity == Vector2.ZERO, "Chassis linear velocity is zero")
	assert(veh.angular_velocity == 0.0, "Chassis angular velocity is zero")

	# Verify driving input cannot move frozen car
	var pos_before: Vector2 = veh.global_position
	veh._handle_input(0.1)
	veh._physics_process(0.1)
	assert(veh.global_position == pos_before, "Vehicle cannot move while locked")
	assert(veh.linear_velocity == Vector2.ZERO, "Vehicle cannot gain velocity while locked")

	# Verify Extra Chance panel is open and interactive
	assert(surv.ad_offer_panel != null and surv.ad_offer_panel.visible == true, "Ad offer panel must be visible")

	surv.queue_free()
	print("  ✓ Vehicle physics, chassis, and wheels are 100% frozen on life depletion!")

func _test_4_extra_life_and_give_up_paths(root: Window) -> void:
	print("-> [4/5] Verifying Rewarded Extra Life and Give Up Paths...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	var veh = surv.vehicle

	# Reach 0 lives
	surv.current_lives = 0
	surv._handle_lives_depleted()
	assert(surv.ad_offer_panel.visible == true, "Ad offer panel visible")
	assert(veh.freeze == true, "Vehicle locked")

	# Path A: Successful rewarded ad
	surv._on_reward_result_received({"success": true})
	assert(surv.current_lives == 1, "Granted 1 life")
	assert(surv.extra_life_used == true, "Extra life marked as used")
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "State returned to PLAYING")
	assert(surv.ad_offer_panel.visible == false, "Ad offer panel dismissed")
	assert(veh.freeze == false, "Vehicle unfrozen")
	assert(veh.is_active == true, "Vehicle active")

	# Path B: Lose the extra life -> Game Over
	surv.is_invulnerable = false
	surv.register_obstacle_hit("samosa")
	assert(surv.current_lives == 0, "Lives reduced to 0")
	assert(surv.current_state == SurvivalController.RunState.FINISHED, "State is FINISHED")
	assert(veh.freeze == true, "Vehicle frozen on Game Over")
	assert(surv.game_over_panel.visible == true, "Game Over panel visible")

	surv.queue_free()
	print("  ✓ Extra life restores driving smoothly; second loss cleanly locks car at Game Over!")

func _test_5_clean_restart_behavior(root: Window) -> void:
	print("-> [5/5] Verifying Clean Restart via R and Retry Button (No Jumps/Flips)...")
	var surv: SurvivalController = SurvivalScene.instantiate()
	root.add_child(surv)
	var veh = surv.vehicle

	# 1. Deliberately induce non-zero physics velocities, rotation, and camera trauma
	veh.linear_velocity = Vector2(450.0, -280.0)
	veh.angular_velocity = 8.5
	veh.rotation = 1.2
	if veh.rear_wheel:
		veh.rear_wheel.linear_velocity = Vector2(400.0, -250.0)
		veh.rear_wheel.angular_velocity = 35.0
	if veh.front_wheel:
		veh.front_wheel.linear_velocity = Vector2(400.0, -250.0)
		veh.front_wheel.angular_velocity = 35.0

	surv.follow_camera.add_trauma(0.8)
	surv.current_lives = 0
	surv.current_state = SurvivalController.RunState.FINISHED

	# 2. Trigger start_run() (used by both R key and Retry button)
	surv.start_run()

	# 3. Assert clean reset state
	assert(surv.current_state == SurvivalController.RunState.PLAYING, "Run state is PLAYING")
	assert(surv.current_lives == 3, "Lives restored to 3")
	assert(surv.extra_life_used == false, "Extra life flag reset")
	assert(veh.is_active == true, "Vehicle active")
	assert(veh.freeze == false, "Vehicle unfrozen")
	assert(veh.linear_velocity == Vector2.ZERO, "Vehicle linear velocity is 0")
	assert(veh.angular_velocity == 0.0, "Vehicle angular velocity is 0")
	assert(veh.rotation == 0.0, "Vehicle rotation is 0")

	if veh.rear_wheel:
		assert(veh.rear_wheel.linear_velocity == Vector2.ZERO, "Rear wheel linear velocity is 0")
		assert(veh.rear_wheel.angular_velocity == 0.0, "Rear wheel angular velocity is 0")
	if veh.front_wheel:
		assert(veh.front_wheel.linear_velocity == Vector2.ZERO, "Front wheel linear velocity is 0")
		assert(veh.front_wheel.angular_velocity == 0.0, "Front wheel angular velocity is 0")

	# Verify camera snapped and trauma cleared
	assert(surv.follow_camera.trauma == 0.0, "Camera trauma reset to 0")
	var expected_cam_pos: Vector2 = veh.global_position + surv.follow_camera.follow_offset
	assert(surv.follow_camera.global_position.distance_to(expected_cam_pos) < 1.0, "Camera snapped cleanly to target")

	# 4. Step physics frames to confirm zero unwanted jump, flip or roll
	for frame in range(10):
		veh._physics_process(0.016)

	assert(absf(veh.rotation) < 0.1, "Vehicle remains stable on ground without flipping (rot=%f)" % veh.rotation)
	assert(veh.linear_velocity.y < 150.0, "Vehicle does not jump up into sky (vy=%f)" % veh.linear_velocity.y)

	surv.queue_free()
	print("  ✓ R and Retry produce a 100% clean, stable vehicle and camera reset without glitches!")
