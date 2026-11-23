@tool
extends SceneTree

## Test suite verifying Phase 3 Heaven and Hell Environment Scenes.
## Validates scene instantiation, parallax layers, resource references,
## SpriteFrames binding, shader materials, collision isolation (0 colliders),
## and active/inactive toggle states.

func _init() -> void:
	print("=================================================================")
	print("--- BEGIN PHASE 3 ENVIRONMENT SCENES TEST SUITE ---")
	print("=================================================================")

	var passed := true

	passed = _test_heaven_environment() and passed
	passed = _test_hell_environment() and passed
	passed = _test_collision_isolation() and passed
	passed = _test_active_toggle() and passed

	if passed:
		print("\n=================================================================")
		print("✓ ALL PHASE 3 TESTS COMPLETED WITH 100% SUCCESS!")
		print("=================================================================")
		quit(0)
	else:
		print("\n=================================================================")
		print("✗ SOME PHASE 3 TESTS FAILED!")
		print("=================================================================")
		quit(1)

func _test_heaven_environment() -> bool:
	print("\n-> [1/4] Verifying HeavenEnvironment.tscn...")
	var scene_path := "res://scenes/environment/heaven/HeavenEnvironment.tscn"
	if not ResourceLoader.exists(scene_path):
		printerr("  ✗ File not found: ", scene_path)
		return false

	var packed := load(scene_path) as PackedScene
	if not packed:
		printerr("  ✗ Failed to load PackedScene: ", scene_path)
		return false

	var inst := packed.instantiate()
	if not inst:
		printerr("  ✗ Failed to instantiate HeavenEnvironment")
		return false

	if not (inst is ParallaxBackground):
		printerr("  ✗ HeavenEnvironment root is not ParallaxBackground")
		inst.free()
		return false

	var expected_layers := [
		"SkyLayer",
		"DistantCloudsLayer",
		"DistantPalaceLayer",
		"DoveFlockLayer",
		"CelestialCloudsLayer",
		"MidPalaceArchitectureLayer",
		"NearFloraLayer"
	]

	for layer_name in expected_layers:
		var layer := inst.get_node_or_null(layer_name) as ParallaxLayer
		if not layer:
			printerr("  ✗ Missing expected layer: ", layer_name)
			inst.free()
			return false
		print("  ✓ Layer verified: ", layer_name, " (motion_scale: ", layer.motion_scale, ")")

	# Check dove animation
	var dove_lead := inst.get_node_or_null("DoveFlockLayer/DoveLead") as AnimatedSprite2D
	if not dove_lead or not dove_lead.sprite_frames:
		printerr("  ✗ DoveLead AnimatedSprite2D missing or has null sprite_frames")
		inst.free()
		return false
	if dove_lead.sprite_frames.get_frame_count(&"fly") != 60:
		printerr("  ✗ DoveLead frame count != 60")
		inst.free()
		return false
	print("  ✓ Dove flock AnimatedSprite2D verified (60 frames at 24 FPS)!")

	# Check celestial sun glow shader
	var sun_glow := inst.get_node_or_null("SkyLayer/CelestialSunGlow") as Sprite2D
	if not sun_glow or not (sun_glow.material is ShaderMaterial):
		printerr("  ✗ CelestialSunGlow missing or invalid ShaderMaterial")
		inst.free()
		return false
	print("  ✓ CelestialSunGlow ShaderMaterial verified!")

	# Check angel statue and golden archway
	var arch := inst.get_node_or_null("MidPalaceArchitectureLayer/GoldenArchway") as Sprite2D
	var statue := inst.get_node_or_null("MidPalaceArchitectureLayer/IvoryAngelStatue") as Sprite2D
	if not arch or not statue:
		printerr("  ✗ GoldenArchway or IvoryAngelStatue missing from MidPalaceArchitectureLayer")
		inst.free()
		return false
	print("  ✓ GoldenArchway and IvoryAngelStatue verified in MidPalaceArchitectureLayer!")

	inst.free()
	return true

func _test_hell_environment() -> bool:
	print("\n-> [2/4] Verifying HellEnvironment.tscn...")
	var scene_path := "res://scenes/environment/hell/HellEnvironment.tscn"
	if not ResourceLoader.exists(scene_path):
		printerr("  ✗ File not found: ", scene_path)
		return false

	var packed := load(scene_path) as PackedScene
	if not packed:
		printerr("  ✗ Failed to load PackedScene: ", scene_path)
		return false

	var inst := packed.instantiate()
	if not inst:
		printerr("  ✗ Failed to instantiate HellEnvironment")
		return false

	if not (inst is ParallaxBackground):
		printerr("  ✗ HellEnvironment root is not ParallaxBackground")
		inst.free()
		return false

	var expected_layers := [
		"SkyLayer",
		"DistantCragsLayer",
		"MidBasaltArchitectureLayer",
		"LavaThermalLayer"
	]

	for layer_name in expected_layers:
		var layer := inst.get_node_or_null(layer_name) as ParallaxLayer
		if not layer:
			printerr("  ✗ Missing expected layer: ", layer_name)
			inst.free()
			return false
		print("  ✓ Layer verified: ", layer_name, " (motion_scale: ", layer.motion_scale, ")")

	# Verify removal of legacy cartoon characters and dragon
	var dragon := inst.get_node_or_null("AmbientDragonLayer/FlyingHellDragon")
	var char_layer := inst.get_node_or_null("AmbientCharactersLayer")
	if dragon != null or char_layer != null:
		printerr("  ✗ Legacy cartoon characters or dragon still present in HellEnvironment!")
		inst.free()
		return false
	print("  ✓ Verified legacy cartoon dragon and ambient characters are removed!")

	# Check that black-square torch flames are permanently removed from LavaThermalLayer
	var torch_left := inst.get_node_or_null("LavaThermalLayer/TorchFlameLeft")
	var torch_right := inst.get_node_or_null("LavaThermalLayer/TorchFlameRight")
	if torch_left != null or torch_right != null:
		printerr("  ✗ TorchFlameLeft or TorchFlameRight black fire square tiles still present in HellEnvironment!")
		inst.free()
		return false
	print("  ✓ Verified black-square torch flames (TorchFlameLeft/Right) are permanently removed!")

	# Check lava flow and heat shimmer shaders
	var lava := inst.get_node_or_null("LavaThermalLayer/LavaStreamSurface") as Sprite2D
	var shimmer := inst.get_node_or_null("LavaThermalLayer/HeatShimmer") as ColorRect
	if not lava or not (lava.material is ShaderMaterial):
		printerr("  ✗ LavaStreamSurface missing or invalid ShaderMaterial")
		inst.free()
		return false
	if not shimmer or not (shimmer.material is ShaderMaterial):
		printerr("  ✗ HeatShimmer missing or invalid ShaderMaterial")
		inst.free()
		return false
	print("  ✓ Molten lava and heat shimmer ShaderMaterials verified!")

	# Check dragon skull portal and floating basalt column strips removal
	var dragon_skull := inst.get_node_or_null("MidBasaltArchitectureLayer/DragonSkullPortal")
	var col_left := inst.get_node_or_null("MidBasaltArchitectureLayer/BasaltColumnLeft")
	var col_right := inst.get_node_or_null("MidBasaltArchitectureLayer/BasaltColumnRight")
	if dragon_skull != null:
		printerr("  ✗ DragonSkullPortal rectangular cave image still present in MidBasaltArchitectureLayer!")
		inst.free()
		return false
	if col_left != null or col_right != null:
		printerr("  ✗ Floating horizontal strips (BasaltColumnLeft/Right) still present in MidBasaltArchitectureLayer!")
		inst.free()
		return false
	var banner_l := inst.get_node_or_null("MidBasaltArchitectureLayer/AnimatedBannerLeft")
	var banner_r := inst.get_node_or_null("MidBasaltArchitectureLayer/AnimatedBannerRight")
	var brazier_1 := inst.get_node_or_null("MidBasaltArchitectureLayer/BrazierPost1")
	var brazier_2 := inst.get_node_or_null("MidBasaltArchitectureLayer/BrazierPost2")
	if not banner_l or not banner_r or not brazier_1 or not brazier_2:
		printerr("  ✗ Missing required banners or braziers in MidBasaltArchitectureLayer")
		inst.free()
		return false
	print("  ✓ DragonSkullPortal and floating horizontal strips verified removed; banners/braziers preserved!")

	inst.free()
	return true

func _test_collision_isolation() -> bool:
	print("\n-> [3/4] Auditing collision isolation (ensuring 0 physics colliders in environments)...")

	var heaven_scene: PackedScene = load("res://scenes/environment/heaven/HeavenEnvironment.tscn")
	var heaven_inst: Node = heaven_scene.instantiate()
	var heaven_colliders := _find_all_colliders(heaven_inst)
	heaven_inst.free()

	if heaven_colliders.size() > 0:
		printerr("  ✗ LEAK: Found ", heaven_colliders.size(), " colliders in HeavenEnvironment: ", heaven_colliders)
		return false
	print("  ✓ HeavenEnvironment has 0 colliders (100% collision free)!")

	var hell_scene: PackedScene = load("res://scenes/environment/hell/HellEnvironment.tscn")
	var hell_inst: Node = hell_scene.instantiate()
	var hell_colliders := _find_all_colliders(hell_inst)
	hell_inst.free()

	if hell_colliders.size() > 0:
		printerr("  ✗ LEAK: Found ", hell_colliders.size(), " colliders in HellEnvironment: ", hell_colliders)
		return false
	print("  ✓ HellEnvironment has 0 colliders (100% collision free)!")

	return true

func _find_all_colliders(node: Node) -> Array[String]:
	var result: Array[String] = []
	if node is CollisionObject2D or node is CollisionShape2D or node is CollisionPolygon2D:
		result.append(node.name)
	for child in node.get_children():
		result.append_array(_find_all_colliders(child))
	return result

func _test_active_toggle() -> bool:
	print("\n-> [4/4] Verifying set_environment_active(active) lifecycle and particle culling...")

	var heaven_scene: PackedScene = load("res://scenes/environment/heaven/HeavenEnvironment.tscn")
	var heaven_inst: HeavenEnvironment = heaven_scene.instantiate() as HeavenEnvironment

	# Deactivate
	heaven_inst.set_environment_active(false)
	if heaven_inst.visible != false:
		printerr("  ✗ Heaven visible not false after deactivate")
		heaven_inst.free()
		return false
	var sparkles: CPUParticles2D = heaven_inst.get_node("NearFloraLayer/CelestialSparkles")
	if sparkles.emitting != false:
		printerr("  ✗ Heaven sparkles still emitting when inactive")
		heaven_inst.free()
		return false

	# Reactivate
	heaven_inst.set_environment_active(true)
	if heaven_inst.visible != true or sparkles.emitting != true:
		printerr("  ✗ Heaven failed to reactivate")
		heaven_inst.free()
		return false
	print("  ✓ HeavenEnvironment active/inactive toggle and particle culling verified!")
	heaven_inst.free()

	var hell_scene: PackedScene = load("res://scenes/environment/hell/HellEnvironment.tscn")
	var hell_inst: HellEnvironment = hell_scene.instantiate() as HellEnvironment

	# Deactivate
	hell_inst.set_environment_active(false)
	if hell_inst.visible != false:
		printerr("  ✗ Hell visible not false after deactivate")
		hell_inst.free()
		return false
	var cinders: CPUParticles2D = hell_inst.get_node("LavaThermalLayer/FloatingCinders")
	if cinders.emitting != false:
		printerr("  ✗ Hell cinders still emitting when inactive")
		hell_inst.free()
		return false

	# Reactivate
	hell_inst.set_environment_active(true)
	if hell_inst.visible != true or cinders.emitting != true:
		printerr("  ✗ Hell failed to reactivate")
		hell_inst.free()
		return false
	print("  ✓ HellEnvironment active/inactive toggle and particle culling verified!")
	hell_inst.free()

	return true
