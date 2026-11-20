extends SceneTree

const HUDScene = preload("res://scenes/ui/HUD.tscn")
const GameHUDScene = preload("res://scenes/ui/hud/game_hud.tscn")

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN METAL PEDALS ACROSS ALL GAME MODES VERIFICATION ---")
	print("=================================================================\n")
	call_deferred("_run_tests")

func _run_tests() -> void:
	# 1. Verify Shared HUD Scene Pedal Assets
	print("-> [1/4] Verifying Base Shared HUD.tscn Pedal Textures...")
	var hud = HUDScene.instantiate()
	root.add_child(hud)
	
	for i in range(3):
		await process_frame
		
	var brake: TextureButton = hud.get_node("%BrakePedal")
	var gas: TextureButton = hud.get_node("%GasPedal")
	
	assert(brake != null, "BrakePedal node must exist")
	assert(gas != null, "GasPedal node must exist")
	assert(brake.texture_normal != null, "Brake normal texture must not be null")
	assert(brake.texture_pressed != null, "Brake pressed texture must not be null")
	assert(gas.texture_normal != null, "Gas normal texture must not be null")
	assert(gas.texture_pressed != null, "Gas pressed texture must not be null")
	
	print("  • Brake normal texture: ", brake.texture_normal.resource_path)
	print("  • Brake pressed texture: ", brake.texture_pressed.resource_path)
	print("  • Gas normal texture: ", gas.texture_normal.resource_path)
	print("  • Gas pressed texture: ", gas.texture_pressed.resource_path)
	
	assert(brake.texture_normal.resource_path.ends_with("brake_pedal_normal.png"), "Brake normal points to brake_pedal_normal.png")
	assert(brake.texture_pressed.resource_path.ends_with("brake_pedal_pressed.png"), "Brake pressed points to brake_pedal_pressed.png")
	assert(gas.texture_normal.resource_path.ends_with("accelerator_pedal_normal.png"), "Gas normal points to accelerator_pedal_normal.png")
	assert(gas.texture_pressed.resource_path.ends_with("accelerator_pedal_pressed.png"), "Gas pressed points to accelerator_pedal_pressed.png")
	print("  ✓ Shared HUD pedal textures correctly configured!")

	# 2. Verify Pedal Dimensions and Touch Area
	print("-> [2/4] Verifying Pedal Dimensions, Margins, and Stretch Mode...")
	assert(brake.stretch_mode == TextureButton.STRETCH_KEEP_ASPECT_CENTERED, "Brake preserves aspect ratio centered")
	assert(gas.stretch_mode == TextureButton.STRETCH_KEEP_ASPECT_CENTERED, "Gas preserves aspect ratio centered")
	assert(brake.size.x >= 120.0 and brake.size.y >= 120.0, "Brake has generous touch target (140x140)")
	assert(gas.size.x >= 120.0 and gas.size.y >= 120.0, "Gas has generous touch target (140x140)")
	print("  ✓ Touch targets and aspect ratios verified!")

	# 3. Verify Survival Mode (game_hud.tscn) Inherits Same Assets
	print("-> [3/4] Verifying Survival Mode (game_hud.tscn) Uses Same Pedal Assets...")
	var surv_hud = GameHUDScene.instantiate()
	root.add_child(surv_hud)
	for i in range(3):
		await process_frame
		
	var s_brake: TextureButton = surv_hud.get_node("%BrakePedal")
	var s_gas: TextureButton = surv_hud.get_node("%GasPedal")
	assert(s_brake != null and s_gas != null, "Survival HUD has BrakePedal and GasPedal")
	assert(s_brake.texture_normal.resource_path == brake.texture_normal.resource_path, "Survival brake matches shared HUD")
	assert(s_gas.texture_normal.resource_path == gas.texture_normal.resource_path, "Survival gas matches shared HUD")
	print("  ✓ Survival Mode confirmed using identical metal pedal artwork!")

	# 4. Verify Input Event Dispatch
	print("-> [4/4] Verifying Input Functionality (Action Press / Release)...")
	# Simulate gas down
	surv_hud._on_gas_down()
	assert(Input.is_action_pressed("accelerate"), "Gas down triggers accelerate action")
	surv_hud._on_gas_up()
	assert(not Input.is_action_pressed("accelerate"), "Gas up releases accelerate action")
	
	# Simulate brake down
	surv_hud._on_brake_down()
	assert(Input.is_action_pressed("brake_reverse"), "Brake down triggers brake_reverse action")
	surv_hud._on_brake_up()
	assert(not Input.is_action_pressed("brake_reverse"), "Brake up releases brake_reverse action")
	print("  ✓ Full input press and release cycle verified!")

	hud.queue_free()
	surv_hud.queue_free()

	print("\n=================================================================")
	print("✓ ALL METAL PEDAL VERIFICATION TESTS PASSED 100%!")
	print("=================================================================\n")
	quit(0)
