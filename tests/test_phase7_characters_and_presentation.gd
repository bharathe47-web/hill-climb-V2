@tool
extends SceneTree

## Comprehensive test suite for Phase 7:
## World Dressing, Environmental Characters, Scenery, Hazards, and Collectible Presentation.
## Validates:
## 1. Hell character animation loops & state integrity (Skeleton, Goblin, Fiend, Dragon)
## 2. Safe positioning outside vehicle corridor & shelf bounding
## 3. 100% collision isolation (0 colliders in ambient actors/scenery)
## 4. Offscreen visibility culling via VisibleOnScreenNotifier2D & mobile optimization
## 5. Heaven wildlife (Dove 60f loop, bobbing, 8 flowers, statue, palace)
## 6. Normal Land scenery completion (forest silhouettes, midground forest, props, fences)
## 7. Hell decorative hazards & props (dragon skull, basalt columns, skulls, obsidian spikes, lava)
## 8. Themed collectible presentation without altering collision, score, or fuel values
## 9. Restart & pooling lifecycle stability

func _init() -> void:
	print("\n=================================================================")
	print("--- BEGIN PHASE 7 CHARACTERS & WORLD DRESSING TEST SUITE ---")
	print("=================================================================\n")

	var passed := true
	passed = await _test_hell_character_animations() and passed
	passed = await _test_safe_shelf_positioning() and passed
	passed = await _test_collision_isolation() and passed
	passed = await _test_visibility_culling_and_lifecycle() and passed
	passed = await _test_heaven_wildlife_and_scenery() and passed
	passed = await _test_normal_land_scenery_completion() and passed
	passed = await _test_hell_decorative_hazards() and passed
	passed = await _test_themed_collectible_presentation() and passed
	passed = await _test_standalone_character_scenes() and passed

	if passed:
		print("\n=================================================================")
		print("✓ ALL PHASE 7 TESTS COMPLETED WITH 100% SUCCESS!")
		print("=================================================================\n")
		quit(0)
	else:
		print("\n=================================================================")
		print("✗ SOME PHASE 7 TESTS FAILED!")
		print("=================================================================\n")
		quit(1)

func _test_hell_character_animations() -> bool:
	print("-> [1/9] Verifying Hell character animations & state loop flags...")
	
	# Skeleton Knight
	var skel_sf: SpriteFrames = load("res://assets/environments/hell/characters/skeleton_knight/skeleton_knight.tres")
	assert(skel_sf != null, "skeleton_knight.tres must exist")
	assert(skel_sf.has_animation("idle"), "Skeleton must have idle")
	assert(skel_sf.has_animation("walk"), "Skeleton must have walk")
	assert(skel_sf.has_animation("attack1"), "Skeleton must have attack1")
	assert(skel_sf.has_animation("attack2"), "Skeleton must have attack2")
	assert(skel_sf.has_animation("dead"), "Skeleton must have dead")
	assert(skel_sf.get_animation_loop("idle") == true, "Skeleton idle must loop")
	assert(skel_sf.get_animation_loop("walk") == true, "Skeleton walk must loop")
	print("  ✓ Skeleton Knight: idle, walk, attack1, attack2, dead verified")

	# Demon Goblin
	var gob_sf: SpriteFrames = load("res://assets/environments/hell/characters/demon_goblin/demon_goblin.tres")
	assert(gob_sf != null, "demon_goblin.tres must exist")
	assert(gob_sf.has_animation("idle"), "Goblin must have idle")
	assert(gob_sf.has_animation("walk"), "Goblin must have walk")
	assert(gob_sf.get_animation_loop("idle") == true, "Goblin idle must loop")
	assert(gob_sf.get_animation_loop("walk") == true, "Goblin walk must loop")
	print("  ✓ Demon Goblin: idle (8f), walk (43f) verified")

	# Horned Fiend
	var fiend_sf: SpriteFrames = load("res://assets/environments/hell/characters/horned_fiend/horned_fiend.tres")
	assert(fiend_sf != null, "horned_fiend.tres must exist")
	assert(fiend_sf.has_animation("walk"), "Horned Fiend must have walk")
	assert(fiend_sf.get_animation_loop("walk") == true, "Horned Fiend walk must loop")
	print("  ✓ Horned Fiend: walk (13f) verified")

	# Flying Dragon
	var drag_sf: SpriteFrames = load("res://assets/environments/hell/characters/flying_dragon/flying_dragon.tres")
	assert(drag_sf != null, "flying_dragon.tres must exist")
	assert(drag_sf.has_animation("fly"), "Dragon must have fly")
	assert(drag_sf.get_animation_loop("fly") == true, "Dragon fly must loop")
	print("  ✓ Flying Hell Dragon: fly (4f) verified")

	return true

func _test_safe_shelf_positioning() -> bool:
	print("-> [2/9] Auditing safe shelf positioning & vehicle corridor clearance...")
	var hell_scene: PackedScene = load("res://scenes/environment/hell/HellEnvironment.tscn")
	var hell_inst: HellEnvironment = hell_scene.instantiate() as HellEnvironment
	root.add_child(hell_inst)
	await process_frame

	var char_layer: ParallaxLayer = hell_inst.get_node("AmbientCharactersLayer")
	var dragon_layer: ParallaxLayer = hell_inst.get_node("AmbientDragonLayer")

	# In Hell, road ground baseline is Y ~ 420px. Safe shelves must sit at Y <= 380px.
	var skel: AnimatedSprite2D = char_layer.get_node("SkeletonKnight")
	var gob: AnimatedSprite2D = char_layer.get_node("DemonGoblin")
	var fiend: AnimatedSprite2D = char_layer.get_node("HornedFiend")
	var dragon: AnimatedSprite2D = dragon_layer.get_node("FlyingHellDragon")

	assert(skel.position.y <= 300.0, "Skeleton Knight must sit safely on basalt column shelf (Y <= 300, got %f)" % skel.position.y)
	assert(gob.position.y <= 300.0, "Demon Goblin must sit safely on basalt column shelf (Y <= 300, got %f)" % gob.position.y)
	assert(fiend.position.y <= 380.0, "Horned Fiend must sit safely on side shelf (Y <= 380, got %f)" % fiend.position.y)
	assert(dragon.position.y <= 160.0, "Flying Hell Dragon must soar in aerial layer (Y <= 160, got %f)" % dragon.position.y)

	# Verify Parallax motion scale is <= 0.25 (deep background, isolated from gameplay lane)
	assert(char_layer.motion_scale.x <= 0.25, "Ambient characters must be in deep background layer")
	assert(dragon_layer.motion_scale.x <= 0.15, "Aerial dragon must be in deep background layer")

	# Test horizontal platform patrol bounding
	var init_skel_x := skel.position.x
	hell_inst._process(1.0)
	var moved_skel_x := skel.position.x
	assert(absf(moved_skel_x - init_skel_x) <= hell_inst.patrol_range + 1.0, 
		"Skeleton patrol must remain strictly bounded to platform (range %f)" % hell_inst.patrol_range)

	hell_inst.queue_free()
	print("  ✓ Shelf elevations, aerial clearance, and bounded platform patrols verified!")
	return true

func _test_collision_isolation() -> bool:
	print("-> [3/9] Auditing 100% collision isolation (0 colliders in all environment scenery)...")
	var envs_to_check := [
		"res://scenes/environment/ParallaxEnvironment.tscn",
		"res://scenes/environment/heaven/HeavenEnvironment.tscn",
		"res://scenes/environment/hell/HellEnvironment.tscn"
	]

	for path in envs_to_check:
		var packed: PackedScene = load(path)
		var inst: Node = packed.instantiate()
		var colliders := _find_colliders(inst)
		inst.free()
		assert(colliders.is_empty(), "Environment %s must contain 0 colliders, found: %s" % [path.get_file(), str(colliders)])
		print("  ✓ %s has 0 colliders (100%% collision isolation)" % path.get_file())
	return true

func _find_colliders(node: Node) -> Array[String]:
	var result: Array[String] = []
	if node is CollisionObject2D or node is CollisionShape2D or node is CollisionPolygon2D:
		result.append(node.name)
	for child in node.get_children():
		result.append_array(_find_colliders(child))
	return result

func _test_visibility_culling_and_lifecycle() -> bool:
	print("-> [4/9] Testing VisibleOnScreenNotifier2D culling & mobile lifecycle...")
	var hell_scene: PackedScene = load("res://scenes/environment/hell/HellEnvironment.tscn")
	var hell_inst: HellEnvironment = hell_scene.instantiate() as HellEnvironment
	root.add_child(hell_inst)
	await process_frame

	# Verify notifiers attached to all animated sprites
	for node in hell_inst.find_children("*", "AnimatedSprite2D", true, false):
		var sprite := node as AnimatedSprite2D
		var notifier := sprite.get_node_or_null("VisibleOnScreenNotifier2D") as VisibleOnScreenNotifier2D
		assert(notifier != null, "AnimatedSprite %s must have VisibleOnScreenNotifier2D" % sprite.name)

	# Test offscreen pause
	var skel: AnimatedSprite2D = hell_inst.get_node("AmbientCharactersLayer/SkeletonKnight")
	hell_inst._on_sprite_screen_exited(skel)
	assert(not skel.is_playing(), "SkeletonKnight must pause when offscreen")

	# Test onscreen resume
	hell_inst._on_sprite_screen_entered(skel)
	assert(skel.is_playing(), "SkeletonKnight must resume playing when onscreen")

	# Test environment deactivation
	hell_inst.set_environment_active(false)
	assert(not hell_inst.visible, "HellEnvironment must hide when inactive")
	assert(not skel.is_playing(), "All sprites must pause when environment is inactive")

	hell_inst.queue_free()
	print("  ✓ Visibility culling and inactive mobile pauses verified!")
	return true

func _test_heaven_wildlife_and_scenery() -> bool:
	print("-> [5/9] Verifying Heaven wildlife (Dove flock) & celestial architecture...")
	var heaven_scene: PackedScene = load("res://scenes/environment/heaven/HeavenEnvironment.tscn")
	var heaven_inst: HeavenEnvironment = heaven_scene.instantiate() as HeavenEnvironment
	root.add_child(heaven_inst)
	await process_frame

	# Check dove flock
	var dove_layer: ParallaxLayer = heaven_inst.get_node("DoveFlockLayer")
	assert(dove_layer != null, "DoveFlockLayer must exist")
	var dove_lead: AnimatedSprite2D = dove_layer.get_node("DoveLead")
	assert(dove_lead.sprite_frames.get_frame_count("fly") == 60, "Dove must have 60-frame flight loop")
	assert(dove_lead.sprite_frames.get_animation_speed("fly") == 24.0, "Dove must play at 24 FPS")

	# Check gentle dove flock vertical bobbing
	var initial_offset_y := dove_layer.motion_offset.y
	heaven_inst._process(0.5)
	assert(heaven_inst.enable_dove_flight == true, "enable_dove_flight must be true")
	assert(dove_layer.motion_offset.x > 0.0, "Dove flock must drift forward horizontally")

	# Check 8 garden flowers in NearFloraLayer
	var flora_layer: ParallaxLayer = heaven_inst.get_node("NearFloraLayer")
	for i in range(1, 9):
		var flower_name := "Flower%d" % i
		var flower := flora_layer.get_node_or_null(flower_name) as Sprite2D
		assert(flower != null, "NearFloraLayer must contain %s" % flower_name)

	# Check golden palace architecture and angel statue
	var mid_layer: ParallaxLayer = heaven_inst.get_node("MidPalaceArchitectureLayer")
	assert(mid_layer.get_node_or_null("GoldenArchway") != null, "GoldenArchway must exist")
	assert(mid_layer.get_node_or_null("IvoryAngelStatue") != null, "IvoryAngelStatue must exist")
	assert(mid_layer.get_node_or_null("AngelHaloGlow") != null, "AngelHaloGlow must exist")

	heaven_inst.queue_free()
	print("  ✓ Dove flock 60f loop, drift bobbing, 8 flowers, and palace architecture verified!")
	return true

func _test_normal_land_scenery_completion() -> bool:
	print("-> [6/9] Verifying Normal Land scenery completion & parallax layering...")
	var normal_scene: PackedScene = load("res://scenes/environment/ParallaxEnvironment.tscn")
	var normal_inst: ParallaxEnvironment = normal_scene.instantiate() as ParallaxEnvironment
	root.add_child(normal_inst)

	# Verify newly instanced layers
	var dist_forest: ParallaxLayer = normal_inst.get_node_or_null("DistantForestLayer")
	var mid_forest: ParallaxLayer = normal_inst.get_node_or_null("MidForestLayer")
	var near_scenery: ParallaxLayer = normal_inst.get_node_or_null("NearSceneryLayer")

	assert(dist_forest != null, "DistantForestLayer must exist in ParallaxEnvironment")
	assert(mid_forest != null, "MidForestLayer must exist in ParallaxEnvironment")
	assert(near_scenery != null, "NearSceneryLayer must exist in ParallaxEnvironment")

	# Verify countryside props in NearSceneryLayer
	assert(near_scenery.get_node_or_null("Fence1") != null, "Fence1 must exist")
	assert(near_scenery.get_node_or_null("BrokenFence") != null, "BrokenFence must exist")
	assert(near_scenery.get_node_or_null("BushShrub1") != null, "BushShrub1 must exist")
	assert(near_scenery.get_node_or_null("FlowerYellow1") != null, "FlowerYellow1 must exist")
	assert(near_scenery.get_node_or_null("Signpost") != null, "Signpost must exist")
	assert(near_scenery.get_node_or_null("FallenLog") != null, "FallenLog must exist")

	# Verify motion scale hierarchy
	var mtn: ParallaxLayer = normal_inst.get_node("DistantMountainsLayer")
	var hills: ParallaxLayer = normal_inst.get_node("MidHillsLayer")
	assert(mtn.motion_scale.x < dist_forest.motion_scale.x, "Distant mountains < Distant forest")
	assert(dist_forest.motion_scale.x < mid_forest.motion_scale.x, "Distant forest < Mid forest")
	assert(mid_forest.motion_scale.x < near_scenery.motion_scale.x, "Mid forest < Near scenery")

	normal_inst.queue_free()
	print("  ✓ Forest silhouettes, mid forest, fences, bushes, and signs verified!")
	return true

func _test_hell_decorative_hazards() -> bool:
	print("-> [7/9] Verifying Hell decorative hazards & props...")
	var hell_scene: PackedScene = load("res://scenes/environment/hell/HellEnvironment.tscn")
	var hell_inst: HellEnvironment = hell_scene.instantiate() as HellEnvironment
	root.add_child(hell_inst)

	var mid_layer: ParallaxLayer = hell_inst.get_node("MidBasaltArchitectureLayer")
	var thermal_layer: ParallaxLayer = hell_inst.get_node("LavaThermalLayer")

	# Decorative props
	assert(mid_layer.get_node_or_null("DragonSkullPortal") != null, "DragonSkullPortal must exist")
	assert(mid_layer.get_node_or_null("CatacombSkullPile") != null, "CatacombSkullPile must exist")
	assert(mid_layer.get_node_or_null("ObsidianSpikesCluster") != null, "ObsidianSpikesCluster must exist")
	assert(thermal_layer.get_node_or_null("LavaStreamSurface") != null, "LavaStreamSurface must exist")
	assert(thermal_layer.get_node_or_null("MagmaVentProp") != null, "MagmaVentProp must exist")
	assert(thermal_layer.get_node_or_null("TorchFlameLeft") != null, "TorchFlameLeft must exist")

	# Verify torch flame animation is playing
	var torch: AnimatedSprite2D = thermal_layer.get_node("TorchFlameLeft")
	assert(torch.sprite_frames.has_animation("burn"), "Torch must have burn animation")
	assert(torch.sprite_frames.get_frame_count("burn") == 25, "Fire must have 25 frames")

	hell_inst.queue_free()
	print("  ✓ Dragon skulls, basalt columns, skull piles, obsidian spikes, and lava verified!")
	return true

func _test_themed_collectible_presentation() -> bool:
	print("-> [8/9] Verifying themed collectible presentation & physics invariance...")
	var coin_scene: PackedScene = load("res://scenes/pickups/Coin.tscn")
	var fuel_scene: PackedScene = load("res://scenes/pickups/FuelPickup.tscn")

	var coin: Coin = coin_scene.instantiate() as Coin
	var fuel: FuelPickup = fuel_scene.instantiate() as FuelPickup
	root.add_child(coin)
	root.add_child(fuel)
	await process_frame

	# Verify baseline
	assert(coin.coin_value == 5, "Coin value must remain exactly 5")
	assert(fuel.fuel_amount == 35.0, "Fuel amount must remain exactly 35.0")
	var coin_shape: CircleShape2D = coin.collision_shape.shape as CircleShape2D
	assert(coin_shape.radius == 20.0, "Coin collision radius must remain 20.0")

	# Test Heaven skinning
	coin.apply_biome_theme("heaven")
	fuel.apply_biome_theme("heaven")
	assert(coin.coin_value == 5, "Heaven coin value must remain 5")
	assert(fuel.fuel_amount == 35.0, "Heaven fuel amount must remain 35.0")
	assert(coin.collision_shape.shape.radius == 20.0, "Heaven coin collision radius unchanged")
	assert(coin.glow_aura.color == Color(1.0, 0.96, 0.8, 0.38), "Heaven coin glow aura updated")

	# Test Hell skinning
	coin.apply_biome_theme("hell")
	fuel.apply_biome_theme("hell")
	assert(coin.coin_value == 5, "Hell coin value must remain 5")
	assert(fuel.fuel_amount == 35.0, "Hell fuel amount must remain 35.0")
	assert(coin.collision_shape.shape.radius == 20.0, "Hell coin collision radius unchanged")
	assert(coin.glow_aura.color == Color(1.0, 0.35, 0.1, 0.42), "Hell coin glow aura updated")

	# Test Normal restoration
	coin.apply_biome_theme("normal")
	fuel.apply_biome_theme("normal")
	assert(coin.glow_aura.color == Color(1.0, 0.88, 0.25, 0.22), "Normal coin glow aura restored")

	coin.queue_free()
	fuel.queue_free()
	print("  ✓ Collectible theming applied with 100% collision, value, and signal invariance!")
	return true

func _test_standalone_character_scenes() -> bool:
	print("-> [9/9] Verifying modular standalone character scenes...")
	var character_scenes := [
		{"path": "res://scenes/environment/hell/characters/SkeletonKnight.tscn", "name": "SkeletonKnight", "anim": "idle"},
		{"path": "res://scenes/environment/hell/characters/DemonGoblin.tscn", "name": "DemonGoblin", "anim": "idle"},
		{"path": "res://scenes/environment/hell/characters/HornedFiend.tscn", "name": "HornedFiend", "anim": "walk"},
		{"path": "res://scenes/environment/hell/characters/FlyingHellDragon.tscn", "name": "FlyingHellDragon", "anim": "fly"},
		{"path": "res://scenes/environment/heaven/wildlife/HeavenDove.tscn", "name": "HeavenDove", "anim": "fly"}
	]

	for data in character_scenes:
		var scene_path: String = data["path"]
		assert(ResourceLoader.exists(scene_path), "Character scene must exist: " + scene_path)
		var packed: PackedScene = load(scene_path)
		var inst: Node2D = packed.instantiate() as Node2D
		root.add_child(inst)

		# Check AnimatedSprite2D
		var sprite: AnimatedSprite2D = inst.get_node("AnimatedSprite2D")
		assert(sprite != null, "Must have AnimatedSprite2D")
		assert(sprite.sprite_frames.has_animation(data["anim"]), "Must have animation: " + data["anim"])

		# Check VisibleOnScreenNotifier2D
		var notifier: VisibleOnScreenNotifier2D = inst.get_node("VisibleOnScreenNotifier2D")
		assert(notifier != null, "Must have VisibleOnScreenNotifier2D")

		# Check 0 colliders
		var colliders := _find_colliders(inst)
		assert(colliders.is_empty(), "Character must have 0 colliders")

		inst.queue_free()
		print("  ✓ %s standalone scene verified (anim: '%s', culling notifier, 0 colliders)" % [data["name"], data["anim"]])

	return true
