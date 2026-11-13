@tool
extends SceneTree

func _init() -> void:
	print("=================================================================")
	print("--- GENERATING PHASE 3 ENVIRONMENT SCENES (GODOT 4.7.2) ---")
	print("=================================================================")

	var heaven_res := _build_heaven_scene()
	if heaven_res != OK:
		print("FAILED to build HeavenEnvironment.tscn")
		quit(1)
		return

	var hell_res := _build_hell_scene()
	if hell_res != OK:
		print("FAILED to build HellEnvironment.tscn")
		quit(1)
		return

	print("=================================================================")
	print("✓ ALL PHASE 3 ENVIRONMENT SCENES GENERATED SUCCESSFULLY!")
	print("=================================================================")
	quit(0)

func _set_owner_recursive(node: Node, scene_root: Node) -> void:
	if node != scene_root:
		node.owner = scene_root
	for child in node.get_children():
		_set_owner_recursive(child, scene_root)

func _build_heaven_scene() -> Error:
	print("-> Building HeavenEnvironment.tscn...")
	var root := ParallaxBackground.new()
	root.name = "HeavenEnvironment"
	root.set_script(load("res://scripts/environment/HeavenEnvironment.gd"))
	root.layer = -100
	root.set("enable_cloud_drift", true)
	root.set("cloud_drift_speed", 8.0)
	root.set("enable_dove_flight", true)
	root.set("dove_speed", 45.0)

	# 1. SkyLayer
	var sky_layer := ParallaxLayer.new()
	sky_layer.name = "SkyLayer"
	sky_layer.motion_scale = Vector2(0.0, 0.0)
	root.add_child(sky_layer)

	var sky_bg := TextureRect.new()
	sky_bg.name = "SkyBackground"
	sky_bg.texture = load("res://assets/environments/heaven/sky/puffy_sky_blue_01.png")
	sky_bg.stretch_mode = TextureRect.STRETCH_TILE
	sky_bg.offset_left = -6000.0
	sky_bg.offset_top = -2000.0
	sky_bg.offset_right = 30000.0
	sky_bg.offset_bottom = 2000.0
	sky_layer.add_child(sky_bg)

	var sun_glow := Sprite2D.new()
	sun_glow.name = "CelestialSunGlow"
	sun_glow.position = Vector2(640.0, 110.0)
	sun_glow.texture = load("res://assets/environments/heaven/vfx/light_masks/circle_rings_a.png")
	sun_glow.scale = Vector2(1.2, 1.2)
	var glow_mat := ShaderMaterial.new()
	glow_mat.shader = load("res://scripts/shaders/celestial_atmospheric_glow.gdshader")
	glow_mat.set_shader_parameter("glow_color", Color(1.0, 0.94, 0.78, 0.6))
	glow_mat.set_shader_parameter("glow_intensity", 1.3)
	glow_mat.set_shader_parameter("pulse_speed", 0.8)
	sun_glow.material = glow_mat
	sky_layer.add_child(sun_glow)

	var rays := Sprite2D.new()
	rays.name = "AtmosphericRays"
	rays.position = Vector2(640.0, 140.0)
	rays.texture = load("res://assets/environments/heaven/vfx/light_masks/streaks_composed_c.png")
	rays.scale = Vector2(2.5, 1.6)
	rays.modulate = Color(1.0, 0.95, 0.85, 0.28)
	sky_layer.add_child(rays)

	# 2. DistantCloudsLayer
	var dist_clouds_layer := ParallaxLayer.new()
	dist_clouds_layer.name = "DistantCloudsLayer"
	dist_clouds_layer.motion_scale = Vector2(0.04, 0.02)
	dist_clouds_layer.motion_mirroring = Vector2(2560.0, 0.0)
	root.add_child(dist_clouds_layer)

	var dc1 := Sprite2D.new()
	dc1.name = "DistCloud1"
	dc1.texture = load("res://assets/environments/heaven/vfx/clouds/white_puff_01.png")
	dc1.position = Vector2(320.0, 90.0)
	dc1.scale = Vector2(1.2, 1.2)
	dc1.modulate = Color(1.0, 1.0, 1.0, 0.55)
	dist_clouds_layer.add_child(dc1)

	var dc2 := Sprite2D.new()
	dc2.name = "DistCloud2"
	dc2.texture = load("res://assets/environments/heaven/vfx/clouds/white_puff_08.png")
	dc2.position = Vector2(1150.0, 120.0)
	dc2.scale = Vector2(1.35, 1.25)
	dc2.modulate = Color(1.0, 1.0, 1.0, 0.60)
	dist_clouds_layer.add_child(dc2)

	var dc3 := Sprite2D.new()
	dc3.name = "DistCloud3"
	dc3.texture = load("res://assets/environments/heaven/vfx/clouds/white_puff_15.png")
	dc3.position = Vector2(1980.0, 80.0)
	dc3.scale = Vector2(1.25, 1.2)
	dc3.modulate = Color(1.0, 1.0, 1.0, 0.55)
	dist_clouds_layer.add_child(dc3)

	# 3. DistantPalaceLayer
	var dist_palace_layer := ParallaxLayer.new()
	dist_palace_layer.name = "DistantPalaceLayer"
	dist_palace_layer.motion_scale = Vector2(0.12, 0.05)
	dist_palace_layer.motion_mirroring = Vector2(2400.0, 0.0)
	root.add_child(dist_palace_layer)

	var win1 := Sprite2D.new()
	win1.name = "PalaceWindow1"
	win1.texture = load("res://assets/environments/heaven/architecture/heaven_palace_window.png")
	win1.position = Vector2(420.0, 260.0)
	win1.scale = Vector2(0.42, 0.42)
	win1.modulate = Color(0.88, 0.92, 1.0, 0.75)
	dist_palace_layer.add_child(win1)

	var beam1 := Sprite2D.new()
	beam1.name = "WindowBeam1"
	beam1.texture = load("res://assets/environments/heaven/vfx/light_masks/cone_b.png")
	beam1.position = Vector2(420.0, 360.0)
	beam1.scale = Vector2(0.6, 0.8)
	beam1.modulate = Color(1.0, 0.95, 0.75, 0.25)
	dist_palace_layer.add_child(beam1)

	var win2 := Sprite2D.new()
	win2.name = "PalaceWindow2"
	win2.texture = load("res://assets/environments/heaven/architecture/heaven_palace_window.png")
	win2.position = Vector2(1620.0, 260.0)
	win2.scale = Vector2(0.42, 0.42)
	win2.modulate = Color(0.88, 0.92, 1.0, 0.75)
	dist_palace_layer.add_child(win2)

	var beam2 := Sprite2D.new()
	beam2.name = "WindowBeam2"
	beam2.texture = load("res://assets/environments/heaven/vfx/light_masks/cone_b.png")
	beam2.position = Vector2(1620.0, 360.0)
	beam2.scale = Vector2(0.6, 0.8)
	beam2.modulate = Color(1.0, 0.95, 0.75, 0.25)
	dist_palace_layer.add_child(beam2)

	var col_positions := [200.0, 800.0, 1400.0, 2000.0]
	for i in range(col_positions.size()):
		var col := Sprite2D.new()
		col.name = "DistantColumn%d" % (i + 1)
		col.texture = load("res://assets/environments/heaven/architecture/heaven_palace_column.png")
		col.position = Vector2(col_positions[i], 320.0)
		col.scale = Vector2(0.35, 0.35)
		col.modulate = Color(0.88, 0.92, 0.98, 0.78)
		dist_palace_layer.add_child(col)

	# 4. DoveFlockLayer
	var dove_layer := ParallaxLayer.new()
	dove_layer.name = "DoveFlockLayer"
	dove_layer.motion_scale = Vector2(0.18, 0.08)
	dove_layer.motion_mirroring = Vector2(2048.0, 0.0)
	root.add_child(dove_layer)

	var dove_frames: SpriteFrames = load("res://assets/environments/heaven/wildlife/dove_flight.tres")

	var dove_lead := AnimatedSprite2D.new()
	dove_lead.name = "DoveLead"
	dove_lead.sprite_frames = dove_frames
	dove_lead.animation = &"fly"
	dove_lead.autoplay = "fly"
	dove_lead.position = Vector2(500.0, 140.0)
	dove_lead.scale = Vector2(0.36, 0.36)
	dove_layer.add_child(dove_lead)

	var dove_right := AnimatedSprite2D.new()
	dove_right.name = "DoveRight"
	dove_right.sprite_frames = dove_frames
	dove_right.animation = &"fly"
	dove_right.autoplay = "fly"
	dove_right.position = Vector2(430.0, 175.0)
	dove_right.scale = Vector2(0.30, 0.30)
	dove_layer.add_child(dove_right)

	var dove_left := AnimatedSprite2D.new()
	dove_left.name = "DoveLeft"
	dove_left.sprite_frames = dove_frames
	dove_left.animation = &"fly"
	dove_left.autoplay = "fly"
	dove_left.position = Vector2(570.0, 165.0)
	dove_left.scale = Vector2(0.32, 0.32)
	dove_layer.add_child(dove_left)

	# 5. CelestialCloudsLayer
	var celestial_clouds_layer := ParallaxLayer.new()
	celestial_clouds_layer.name = "CelestialCloudsLayer"
	celestial_clouds_layer.motion_scale = Vector2(0.20, 0.08)
	celestial_clouds_layer.motion_mirroring = Vector2(2048.0, 0.0)
	root.add_child(celestial_clouds_layer)

	var puff1 := Sprite2D.new()
	puff1.name = "CumulusPuff1"
	puff1.texture = load("res://assets/environments/heaven/vfx/clouds/white_puff_06.png")
	puff1.position = Vector2(280.0, 160.0)
	puff1.scale = Vector2(0.9, 0.8)
	puff1.modulate = Color(1.0, 0.98, 0.95, 0.7)
	celestial_clouds_layer.add_child(puff1)

	var puff2 := Sprite2D.new()
	puff2.name = "CumulusPuff2"
	puff2.texture = load("res://assets/environments/heaven/vfx/clouds/white_puff_18.png")
	puff2.position = Vector2(1300.0, 130.0)
	puff2.scale = Vector2(1.0, 0.85)
	puff2.modulate = Color(1.0, 0.98, 0.95, 0.72)
	celestial_clouds_layer.add_child(puff2)

	var puff3 := Sprite2D.new()
	puff3.name = "CumulusPuff3"
	puff3.texture = load("res://assets/environments/heaven/vfx/clouds/white_puff_22.png")
	puff3.position = Vector2(1750.0, 170.0)
	puff3.scale = Vector2(0.85, 0.75)
	puff3.modulate = Color(1.0, 0.98, 0.95, 0.65)
	celestial_clouds_layer.add_child(puff3)

	# 6. MidPalaceArchitectureLayer
	var mid_palace_layer := ParallaxLayer.new()
	mid_palace_layer.name = "MidPalaceArchitectureLayer"
	mid_palace_layer.motion_scale = Vector2(0.28, 0.12)
	mid_palace_layer.motion_mirroring = Vector2(2560.0, 0.0)
	root.add_child(mid_palace_layer)

	var ceiling := Sprite2D.new()
	ceiling.name = "PalaceCeiling"
	ceiling.texture = load("res://assets/environments/heaven/architecture/heaven_palace_ceiling.png")
	ceiling.position = Vector2(1280.0, 20.0)
	ceiling.scale = Vector2(1.35, 1.0)
	mid_palace_layer.add_child(ceiling)

	var arch := Sprite2D.new()
	arch.name = "GoldenArchway"
	arch.texture = load("res://assets/environments/heaven/architecture/heaven_golden_archway.png")
	arch.position = Vector2(650.0, 220.0)
	arch.scale = Vector2(0.65, 0.65)
	mid_palace_layer.add_child(arch)

	var arch_front := Sprite2D.new()
	arch_front.name = "GoldenArchwayFront"
	arch_front.texture = load("res://assets/environments/heaven/architecture/heaven_golden_archway_front.png")
	arch_front.position = Vector2(650.0, 220.0)
	arch_front.scale = Vector2(0.65, 0.65)
	mid_palace_layer.add_child(arch_front)

	var pcol_left := Sprite2D.new()
	pcol_left.name = "PalaceColumnLeft"
	pcol_left.texture = load("res://assets/environments/heaven/architecture/heaven_palace_column.png")
	pcol_left.position = Vector2(450.0, 330.0)
	pcol_left.scale = Vector2(0.55, 0.55)
	mid_palace_layer.add_child(pcol_left)

	var pcol_right := Sprite2D.new()
	pcol_right.name = "PalaceColumnRight"
	pcol_right.texture = load("res://assets/environments/heaven/architecture/heaven_palace_column.png")
	pcol_right.position = Vector2(850.0, 330.0)
	pcol_right.scale = Vector2(0.55, 0.55)
	mid_palace_layer.add_child(pcol_right)

	var angel_statue := Sprite2D.new()
	angel_statue.name = "IvoryAngelStatue"
	angel_statue.texture = load("res://assets/environments/heaven/decorations/heaven_angel_statue.png")
	angel_statue.position = Vector2(1850.0, 250.0)
	angel_statue.scale = Vector2(0.42, 0.42)
	mid_palace_layer.add_child(angel_statue)

	var angel_glow := Sprite2D.new()
	angel_glow.name = "AngelHaloGlow"
	angel_glow.texture = load("res://assets/environments/heaven/vfx/light_masks/circle_b.png")
	angel_glow.position = Vector2(1850.0, 180.0)
	angel_glow.scale = Vector2(0.6, 0.6)
	angel_glow.modulate = Color(1.0, 0.95, 0.8, 0.35)
	mid_palace_layer.add_child(angel_glow)

	var floor_trim := Sprite2D.new()
	floor_trim.name = "PalaceMarbleTrim"
	floor_trim.texture = load("res://assets/environments/heaven/architecture/heaven_marble_floor.png")
	floor_trim.position = Vector2(1280.0, 580.0)
	floor_trim.scale = Vector2(1.35, 0.8)
	mid_palace_layer.add_child(floor_trim)

	# 7. NearFloraLayer
	var flora_layer := ParallaxLayer.new()
	flora_layer.name = "NearFloraLayer"
	flora_layer.motion_scale = Vector2(0.45, 0.18)
	flora_layer.motion_mirroring = Vector2(2048.0, 0.0)
	root.add_child(flora_layer)

	var flowers_config := [
		{"name": "Flower1", "path": "flower_01.png", "pos": Vector2(340.0, 470.0), "scale": Vector2(0.7, 0.7)},
		{"name": "Flower3", "path": "flower_03.png", "pos": Vector2(380.0, 475.0), "scale": Vector2(0.65, 0.65)},
		{"name": "Flower5", "path": "flower_05.png", "pos": Vector2(420.0, 480.0), "scale": Vector2(0.7, 0.7)},
		{"name": "Flower2", "path": "flower_02.png", "pos": Vector2(1130.0, 475.0), "scale": Vector2(0.7, 0.7)},
		{"name": "Flower7", "path": "flower_07.png", "pos": Vector2(1170.0, 470.0), "scale": Vector2(0.65, 0.65)},
		{"name": "Flower8", "path": "flower_08.png", "pos": Vector2(1210.0, 480.0), "scale": Vector2(0.7, 0.7)},
		{"name": "Flower4", "path": "flower_04.png", "pos": Vector2(1830.0, 470.0), "scale": Vector2(0.7, 0.7)},
		{"name": "Flower6", "path": "flower_06.png", "pos": Vector2(1880.0, 475.0), "scale": Vector2(0.7, 0.7)}
	]

	for fc in flowers_config:
		var fl := Sprite2D.new()
		fl.name = fc["name"]
		fl.texture = load("res://assets/environments/heaven/decorations/flowers/" + fc["path"])
		fl.position = fc["pos"]
		fl.scale = fc["scale"]
		flora_layer.add_child(fl)

	var sparkles := CPUParticles2D.new()
	sparkles.name = "CelestialSparkles"
	sparkles.amount = 12
	sparkles.lifetime = 3.5
	sparkles.texture = load("res://assets/environments/heaven/vfx/particles/spark_01.png")
	sparkles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	sparkles.emission_rect_extents = Vector2(640.0, 200.0)
	sparkles.position = Vector2(640.0, 250.0)
	sparkles.gravity = Vector2(5.0, -12.0)
	sparkles.scale_amount_min = 0.04
	sparkles.scale_amount_max = 0.08
	sparkles.color = Color(1.0, 0.95, 0.6, 0.65)
	flora_layer.add_child(sparkles)

	# Set recursive ownership for proper Godot scene serialization
	_set_owner_recursive(root, root)

	var packed := PackedScene.new()
	var pack_err := packed.pack(root)
	if pack_err != OK:
		print("ERROR packing HeavenEnvironment: ", pack_err)
		return pack_err

	var save_err := ResourceSaver.save(packed, "res://scenes/environment/heaven/HeavenEnvironment.tscn")
	if save_err != OK:
		print("ERROR saving HeavenEnvironment.tscn: ", save_err)
		return save_err

	print("  ✓ res://scenes/environment/heaven/HeavenEnvironment.tscn saved successfully!")
	root.free()
	return OK

func _build_hell_scene() -> Error:
	print("-> Building HellEnvironment.tscn...")
	var root := ParallaxBackground.new()
	root.name = "HellEnvironment"
	root.set_script(load("res://scripts/environment/HellEnvironment.gd"))
	root.layer = -100
	root.set("enable_smoke_drift", true)
	root.set("smoke_drift_speed", 6.0)
	root.set("enable_dragon_patrol", true)
	root.set("dragon_patrol_speed", 55.0)

	# 1. SkyLayer
	var sky_layer := ParallaxLayer.new()
	sky_layer.name = "SkyLayer"
	sky_layer.motion_scale = Vector2(0.0, 0.0)
	root.add_child(sky_layer)

	var sky_bg := TextureRect.new()
	sky_bg.name = "VolcanicSkyBackground"
	sky_bg.texture = load("res://assets/environments/hell/backgrounds/hell_volcanic_bridge_bg.jpg")
	sky_bg.stretch_mode = TextureRect.STRETCH_TILE
	sky_bg.offset_left = -6000.0
	sky_bg.offset_top = -1500.0
	sky_bg.offset_right = 30000.0
	sky_bg.offset_bottom = 1500.0
	sky_layer.add_child(sky_bg)

	var sub_glow := Sprite2D.new()
	sub_glow.name = "SubterraneanGlow"
	sub_glow.position = Vector2(640.0, 550.0)
	sub_glow.texture = load("res://assets/environments/hell/vfx/particles/subterranean_magma_glow_mask.png")
	sub_glow.scale = Vector2(3.0, 1.2)
	sub_glow.modulate = Color(1.0, 0.35, 0.05, 0.45)
	sky_layer.add_child(sub_glow)

	# 2. DistantCragsLayer
	var dist_crags_layer := ParallaxLayer.new()
	dist_crags_layer.name = "DistantCragsLayer"
	dist_crags_layer.motion_scale = Vector2(0.06, 0.03)
	dist_crags_layer.motion_mirroring = Vector2(2560.0, 0.0)
	root.add_child(dist_crags_layer)

	var crag1 := Sprite2D.new()
	crag1.name = "VolcanicCrag1"
	crag1.texture = load("res://assets/environments/hell/terrain/hell_volcanic_rock_a.png")
	crag1.position = Vector2(300.0, 320.0)
	crag1.scale = Vector2(0.8, 0.8)
	crag1.modulate = Color(0.25, 0.15, 0.18, 0.9)
	dist_crags_layer.add_child(crag1)

	var crag2 := Sprite2D.new()
	crag2.name = "VolcanicCrag2"
	crag2.texture = load("res://assets/environments/hell/terrain/hell_volcanic_rock_b.png")
	crag2.position = Vector2(1100.0, 330.0)
	crag2.scale = Vector2(0.85, 0.85)
	crag2.modulate = Color(0.22, 0.14, 0.16, 0.9)
	dist_crags_layer.add_child(crag2)

	var crag3 := Sprite2D.new()
	crag3.name = "VolcanicCrag3"
	crag3.texture = load("res://assets/environments/hell/terrain/hell_volcanic_rock_c.png")
	crag3.position = Vector2(1900.0, 310.0)
	crag3.scale = Vector2(0.8, 0.8)
	crag3.modulate = Color(0.24, 0.15, 0.17, 0.9)
	dist_crags_layer.add_child(crag3)

	var smoke1 := Sprite2D.new()
	smoke1.name = "SmokeWisp1"
	smoke1.texture = load("res://assets/environments/hell/vfx/particles/volcanic_smoke_wisp_01.png")
	smoke1.position = Vector2(650.0, 180.0)
	smoke1.scale = Vector2(0.7, 0.7)
	smoke1.modulate = Color(0.4, 0.25, 0.25, 0.4)
	dist_crags_layer.add_child(smoke1)

	var smoke2 := Sprite2D.new()
	smoke2.name = "SmokeWisp2"
	smoke2.texture = load("res://assets/environments/hell/vfx/particles/volcanic_ash_cloud_02.png")
	smoke2.position = Vector2(1500.0, 150.0)
	smoke2.scale = Vector2(0.8, 0.8)
	smoke2.modulate = Color(0.35, 0.2, 0.2, 0.35)
	dist_crags_layer.add_child(smoke2)

	# 3. AmbientDragonLayer
	var dragon_layer := ParallaxLayer.new()
	dragon_layer.name = "AmbientDragonLayer"
	dragon_layer.motion_scale = Vector2(0.12, 0.05)
	dragon_layer.motion_mirroring = Vector2(2400.0, 0.0)
	root.add_child(dragon_layer)

	var dragon_frames: SpriteFrames = load("res://assets/environments/hell/characters/flying_dragon/flying_dragon.tres")
	var dragon := AnimatedSprite2D.new()
	dragon.name = "FlyingHellDragon"
	dragon.sprite_frames = dragon_frames
	dragon.animation = &"fly"
	dragon.autoplay = "fly"
	dragon.position = Vector2(600.0, 130.0)
	dragon.scale = Vector2(0.55, 0.55)
	dragon_layer.add_child(dragon)

	# 4. MidBasaltArchitectureLayer
	var mid_basalt_layer := ParallaxLayer.new()
	mid_basalt_layer.name = "MidBasaltArchitectureLayer"
	mid_basalt_layer.motion_scale = Vector2(0.24, 0.10)
	mid_basalt_layer.motion_mirroring = Vector2(2560.0, 0.0)
	root.add_child(mid_basalt_layer)

	var dragon_skull := Sprite2D.new()
	dragon_skull.name = "DragonSkullPortal"
	dragon_skull.texture = load("res://assets/environments/hell/decorations/giant_dragon_skull_decal.png")
	dragon_skull.position = Vector2(1300.0, 260.0)
	dragon_skull.scale = Vector2(0.7, 0.7)
	mid_basalt_layer.add_child(dragon_skull)

	var col_left := Sprite2D.new()
	col_left.name = "BasaltColumnLeft"
	col_left.texture = load("res://assets/environments/hell/terrain/hell_basalt_column.png")
	col_left.position = Vector2(1000.0, 310.0)
	col_left.scale = Vector2(0.55, 0.55)
	mid_basalt_layer.add_child(col_left)

	var col_right := Sprite2D.new()
	col_right.name = "BasaltColumnRight"
	col_right.texture = load("res://assets/environments/hell/terrain/hell_basalt_column.png")
	col_right.position = Vector2(1600.0, 310.0)
	col_right.scale = Vector2(0.55, 0.55)
	mid_basalt_layer.add_child(col_right)

	var arch_col1 := Sprite2D.new()
	arch_col1.name = "BasaltArchColumn1"
	arch_col1.texture = load("res://assets/environments/hell/terrain/hell_basalt_column.png")
	arch_col1.position = Vector2(350.0, 310.0)
	arch_col1.scale = Vector2(0.5, 0.5)
	mid_basalt_layer.add_child(arch_col1)

	var arch_col2 := Sprite2D.new()
	arch_col2.name = "BasaltArchColumn2"
	arch_col2.texture = load("res://assets/environments/hell/terrain/hell_basalt_column.png")
	arch_col2.position = Vector2(2150.0, 310.0)
	arch_col2.scale = Vector2(0.5, 0.5)
	mid_basalt_layer.add_child(arch_col2)

	var skull_pile := Sprite2D.new()
	skull_pile.name = "CatacombSkullPile"
	skull_pile.texture = load("res://assets/environments/hell/decorations/catacomb_skull_pile_decal.png")
	skull_pile.position = Vector2(450.0, 460.0)
	skull_pile.scale = Vector2(0.4, 0.4)
	mid_basalt_layer.add_child(skull_pile)

	var skull_decal1 := Sprite2D.new()
	skull_decal1.name = "SkullDecal1"
	skull_decal1.texture = load("res://assets/environments/hell/decorations/skulls/skull_01.png")
	skull_decal1.position = Vector2(950.0, 440.0)
	skull_decal1.scale = Vector2(0.25, 0.25)
	mid_basalt_layer.add_child(skull_decal1)

	var skull_decal2 := Sprite2D.new()
	skull_decal2.name = "SkullDecal2"
	skull_decal2.texture = load("res://assets/environments/hell/decorations/skulls/skull_05.png")
	skull_decal2.position = Vector2(1650.0, 440.0)
	skull_decal2.scale = Vector2(0.25, 0.25)
	mid_basalt_layer.add_child(skull_decal2)

	var spikes1 := Sprite2D.new()
	spikes1.name = "ObsidianSpikesCluster"
	spikes1.texture = load("res://assets/environments/hell/terrain/volcanic_obsidian_spikes_cluster.png")
	spikes1.position = Vector2(250.0, 430.0)
	spikes1.scale = Vector2(0.35, 0.35)
	mid_basalt_layer.add_child(spikes1)

	var spikes2 := Sprite2D.new()
	spikes2.name = "ObsidianSpikeSingle"
	spikes2.texture = load("res://assets/environments/hell/terrain/volcanic_obsidian_spike_single.png")
	spikes2.position = Vector2(2250.0, 440.0)
	spikes2.scale = Vector2(0.35, 0.35)
	mid_basalt_layer.add_child(spikes2)

	var basalt_trim := Sprite2D.new()
	basalt_trim.name = "BasaltPlatformTrim"
	basalt_trim.texture = load("res://assets/environments/hell/terrain/hell_basalt_platform.png")
	basalt_trim.position = Vector2(1280.0, 580.0)
	basalt_trim.scale = Vector2(1.35, 0.8)
	basalt_trim.modulate = Color(0.6, 0.5, 0.5, 0.9)
	mid_basalt_layer.add_child(basalt_trim)

	# 5. AmbientCharactersLayer (Zero colliders, pure visuals)
	var char_layer := ParallaxLayer.new()
	char_layer.name = "AmbientCharactersLayer"
	char_layer.motion_scale = Vector2(0.24, 0.10)
	char_layer.motion_mirroring = Vector2(2560.0, 0.0)
	root.add_child(char_layer)

	var skel_frames: SpriteFrames = load("res://assets/environments/hell/characters/skeleton_knight/skeleton_knight.tres")
	var skel := AnimatedSprite2D.new()
	skel.name = "SkeletonKnight"
	skel.sprite_frames = skel_frames
	skel.animation = &"idle"
	skel.autoplay = "idle"
	skel.position = Vector2(1020.0, 275.0)
	skel.scale = Vector2(0.35, 0.35)
	char_layer.add_child(skel)

	var demon_frames: SpriteFrames = load("res://assets/environments/hell/characters/demon_goblin/demon_goblin.tres")
	var demon := AnimatedSprite2D.new()
	demon.name = "DemonGoblin"
	demon.sprite_frames = demon_frames
	demon.animation = &"idle"
	demon.autoplay = "idle"
	demon.position = Vector2(1580.0, 275.0)
	demon.scale = Vector2(0.35, 0.35)
	char_layer.add_child(demon)

	var fiend_frames: SpriteFrames = load("res://assets/environments/hell/characters/horned_fiend/horned_fiend.tres")
	var fiend := AnimatedSprite2D.new()
	fiend.name = "HornedFiend"
	fiend.sprite_frames = fiend_frames
	fiend.animation = &"walk"
	fiend.autoplay = "walk"
	fiend.position = Vector2(450.0, 370.0)
	fiend.scale = Vector2(0.35, 0.35)
	char_layer.add_child(fiend)

	# 6. LavaThermalLayer
	var lava_layer := ParallaxLayer.new()
	lava_layer.name = "LavaThermalLayer"
	lava_layer.motion_scale = Vector2(0.35, 0.14)
	lava_layer.motion_mirroring = Vector2(2048.0, 0.0)
	root.add_child(lava_layer)

	var lava_stream := Sprite2D.new()
	lava_stream.name = "LavaStreamSurface"
	lava_stream.texture = load("res://assets/environments/hell/vfx/lava/lava_tiles.png")
	lava_stream.position = Vector2(1024.0, 640.0)
	lava_stream.scale = Vector2(8.0, 0.6)
	var lava_mat := ShaderMaterial.new()
	lava_mat.shader = load("res://scripts/shaders/molten_lava_flow.gdshader")
	lava_mat.set_shader_parameter("wave_speed", 1.2)
	lava_mat.set_shader_parameter("distortion_strength", 0.05)
	lava_mat.set_shader_parameter("thermal_pulse_speed", 1.5)
	lava_mat.set_shader_parameter("magma_color", Color(1.0, 0.4, 0.05, 1.0))
	lava_stream.material = lava_mat
	lava_layer.add_child(lava_stream)

	var vent := Sprite2D.new()
	vent.name = "MagmaVentProp"
	vent.texture = load("res://assets/environments/hell/terrain/magma_vent_fissure_prop.png")
	vent.position = Vector2(750.0, 520.0)
	vent.scale = Vector2(0.65, 0.65)
	lava_layer.add_child(vent)

	var heat_shimmer := ColorRect.new()
	heat_shimmer.name = "HeatShimmer"
	heat_shimmer.position = Vector2(650.0, 480.0)
	heat_shimmer.size = Vector2(200.0, 60.0)
	var shimmer_mat := ShaderMaterial.new()
	shimmer_mat.shader = load("res://scripts/shaders/heat_distortion_shimmer.gdshader")
	shimmer_mat.set_shader_parameter("shimmer_speed", 3.0)
	shimmer_mat.set_shader_parameter("shimmer_frequency", 15.0)
	shimmer_mat.set_shader_parameter("distortion_strength", 0.02)
	heat_shimmer.material = shimmer_mat
	lava_layer.add_child(heat_shimmer)

	var fire_frames: SpriteFrames = load("res://assets/environments/hell/vfx/fire/fire_sheet_5x5.tres")

	var torch_left := AnimatedSprite2D.new()
	torch_left.name = "TorchFlameLeft"
	torch_left.sprite_frames = fire_frames
	torch_left.animation = &"burn"
	torch_left.autoplay = "burn"
	torch_left.position = Vector2(950.0, 330.0)
	torch_left.scale = Vector2(0.35, 0.35)
	lava_layer.add_child(torch_left)

	var torch_right := AnimatedSprite2D.new()
	torch_right.name = "TorchFlameRight"
	torch_right.sprite_frames = fire_frames
	torch_right.animation = &"burn"
	torch_right.autoplay = "burn"
	torch_right.position = Vector2(1650.0, 330.0)
	torch_right.scale = Vector2(0.35, 0.35)
	lava_layer.add_child(torch_right)

	var cinders := CPUParticles2D.new()
	cinders.name = "FloatingCinders"
	cinders.amount = 16
	cinders.lifetime = 3.0
	cinders.texture = load("res://assets/environments/hell/vfx/particles/volcanic_cinder_spark_01.png")
	cinders.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	cinders.emission_rect_extents = Vector2(640.0, 100.0)
	cinders.position = Vector2(640.0, 580.0)
	cinders.gravity = Vector2(10.0, -35.0)
	cinders.scale_amount_min = 0.03
	cinders.scale_amount_max = 0.07
	cinders.color = Color(1.0, 0.55, 0.1, 0.8)
	lava_layer.add_child(cinders)

	# Set recursive ownership for proper Godot scene serialization
	_set_owner_recursive(root, root)

	var packed := PackedScene.new()
	var pack_err := packed.pack(root)
	if pack_err != OK:
		print("ERROR packing HellEnvironment: ", pack_err)
		return pack_err

	var save_err := ResourceSaver.save(packed, "res://scenes/environment/hell/HellEnvironment.tscn")
	if save_err != OK:
		print("ERROR saving HellEnvironment.tscn: ", save_err)
		return save_err

	print("  ✓ res://scenes/environment/hell/HellEnvironment.tscn saved successfully!")
	root.free()
	return OK
