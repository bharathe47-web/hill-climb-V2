class_name IndianRoadsControllerV2
extends IndianRoadsController

## IndianRoadsControllerV2: Enhanced lifecycle coordinator for Indian Roads Mode (Visual Upgrade v2).
## Instantiates IndianRoadTerrainV2 with advanced 4-plane parallax layers (Sky, Clouds, Distant, Midground)
## and organic, zone-based roadside scenery without repetitive looped textures.

const IndianRoadTerrainV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")

func _setup_terrain() -> void:
	if not is_instance_valid(terrain_slot):
		return

	for child in terrain_slot.get_children():
		child.queue_free()

	var terr_inst := IndianRoadTerrainV2Scene.instantiate() as IndianRoadTerrainV2
	terrain_slot.add_child(terr_inst)
	active_terrain = terr_inst as Variant

	terr_inst.generate_route(active_route)
	terr_inst.checkpoint_cleared.connect(_on_checkpoint_cleared)
	terr_inst.landmark_reached.connect(_on_landmark_reached)
	terr_inst.destination_reached.connect(_on_destination_reached)
	if terr_inst.has_signal("coin_collected"):
		terr_inst.coin_collected.connect(_on_coin_collected)
	if terr_inst.has_signal("fuel_collected"):
		terr_inst.fuel_collected.connect(_on_fuel_collected)

func _setup_parallax_textures() -> void:
	if active_route == null or not is_instance_valid(parallax_bg):
		return

	var state_id := active_route.state_id
	var sky_path := ""
	var bg_path := ""
	var mid_path := ""
	var cloud_path := ""

	match state_id:
		"tamil_nadu":
			sky_path = "res://assets/indian_locations/tamil_nadu/backgrounds/sky/kanyakumari_sky_coastal.png"
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_countryside_midground.png"
			cloud_path = "res://assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png"
		"goa":
			sky_path = "res://assets/indian_locations/goa/backgrounds/sky/goa_tropical_sky.png"
			bg_path = "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png"
			mid_path = "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_coastal_midground.png"
			cloud_path = "res://assets/indian_locations/common/clouds/cloud_cumulus_soft_02.png"
		"kerala":
			sky_path = "res://assets/indian_locations/kerala/backgrounds/sky/kerala_sky_monsoon.png"
			bg_path = "res://assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_western_ghats_peaks.png"
			mid_path = "res://assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_backwater_canal_midground.png"
			cloud_path = "res://assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png"
		"rajasthan":
			sky_path = "res://assets/indian_locations/rajasthan/backgrounds/sky/rajasthan_sky_desert_dawn.png"
			bg_path = "res://assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_thar_sand_dunes.png"
			mid_path = "res://assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_aravalli_hills_midground.png"
			cloud_path = "res://assets/indian_locations/common/clouds/cloud_cirrus_wispy.png"
		"gujarat":
			sky_path = "res://assets/indian_locations/gujarat/backgrounds/sky/gujarat_sky_pale_azure.png"
			bg_path = "res://assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_great_rann_white_salt.png"
			mid_path = "res://assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_saurashtra_savanna_midground.png"
			cloud_path = "res://assets/indian_locations/common/clouds/cloud_stratus_horizon.png"
		"telangana":
			sky_path = "res://assets/indian_locations/telangana/backgrounds/sky/telangana_sky_deccan_twilight.png"
			bg_path = "res://assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_granite_boulder_ridges.png"
			mid_path = "res://assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_plateau_countryside_midground.png"
			cloud_path = "res://assets/indian_locations/common/clouds/cloud_cumulus_soft_02.png"
		_:
			sky_path = active_route.sky_texture_path
			bg_path = active_route.parallax_bg_path

	# 1. Sky Plane (motion_scale 0.02, centered at w * 0.5, h * 0.5)
	var sky_layer: ParallaxLayer = parallax_bg.get_node_or_null("SkyLayer")
	if is_instance_valid(sky_layer):
		sky_layer.motion_scale = Vector2(0.02, 0)
	if is_instance_valid(parallax_sky_sprite) and ResourceLoader.exists(sky_path):
		var sky_tex: Texture2D = load(sky_path)
		parallax_sky_sprite.texture = sky_tex
		var w: float = float(sky_tex.get_width())
		var h: float = float(sky_tex.get_height())
		parallax_sky_sprite.position = Vector2(w * 0.5, h * 0.5)
		if is_instance_valid(sky_layer):
			sky_layer.motion_mirroring = Vector2(w, 0)

	# 2. Distant Horizon Plane (motion_scale 0.12, centered at w * 0.5, h * 0.5)
	var plains_layer: ParallaxLayer = parallax_bg.get_node_or_null("PlainsLayer")
	if is_instance_valid(plains_layer):
		plains_layer.motion_scale = Vector2(0.12, 0)
	if is_instance_valid(parallax_plains_sprite) and ResourceLoader.exists(bg_path):
		var bg_tex: Texture2D = load(bg_path)
		parallax_plains_sprite.texture = bg_tex
		var w: float = float(bg_tex.get_width())
		var h: float = float(bg_tex.get_height())
		parallax_plains_sprite.position = Vector2(w * 0.5, h * 0.5)
		if is_instance_valid(plains_layer):
			plains_layer.motion_mirroring = Vector2(w, 0)

	# 3. Stylized Natural Clouds Layer (motion_scale 0.06)
	_setup_clouds_layer(cloud_path)

	# 4. Midground Landscape Layer (motion_scale 0.25)
	_setup_midground_layer(mid_path)

	# Clean up any legacy single-texture village layer
	var old_village: Node = parallax_bg.get_node_or_null("VillageLayer")
	if is_instance_valid(old_village):
		old_village.visible = false

func _setup_clouds_layer(cloud_path: String) -> void:
	if not is_instance_valid(parallax_bg):
		return

	var cloud_layer: ParallaxLayer = parallax_bg.get_node_or_null("CloudsLayer")
	if cloud_path != "" and ResourceLoader.exists(cloud_path):
		var tex: Texture2D = load(cloud_path)
		var w: float = float(tex.get_width())
		var h: float = float(tex.get_height())
		if cloud_layer == null:
			cloud_layer = ParallaxLayer.new()
			cloud_layer.name = "CloudsLayer"
			cloud_layer.motion_scale = Vector2(0.06, 0)
			cloud_layer.motion_mirroring = Vector2(w, 0)

			var spr := Sprite2D.new()
			spr.name = "CloudsSprite"
			spr.position = Vector2(w * 0.5, h * 0.5)
			cloud_layer.add_child(spr)
			parallax_bg.add_child(cloud_layer)
			parallax_bg.move_child(cloud_layer, 1)

		cloud_layer.motion_mirroring = Vector2(w, 0)
		var spr: Sprite2D = cloud_layer.get_node_or_null("CloudsSprite")
		if is_instance_valid(spr):
			spr.texture = tex
			spr.position = Vector2(w * 0.5, h * 0.5)
			spr.modulate = Color(1.0, 1.0, 1.0, 0.85)
		cloud_layer.visible = true
	else:
		if is_instance_valid(cloud_layer):
			cloud_layer.visible = false

func _setup_midground_layer(mid_path: String) -> void:
	if not is_instance_valid(parallax_bg):
		return

	var mid_layer: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer")
	if mid_path != "" and ResourceLoader.exists(mid_path):
		var tex: Texture2D = load(mid_path)
		var w: float = float(tex.get_width())
		var h: float = float(tex.get_height())
		if mid_layer == null:
			mid_layer = ParallaxLayer.new()
			mid_layer.name = "MidgroundLayer"
			mid_layer.motion_scale = Vector2(0.25, 0)
			mid_layer.motion_mirroring = Vector2(w, 0)

			var spr := Sprite2D.new()
			spr.name = "MidgroundSprite"
			spr.position = Vector2(w * 0.5, h * 0.5)
			mid_layer.add_child(spr)
			parallax_bg.add_child(mid_layer)

		mid_layer.motion_mirroring = Vector2(w, 0)
		var spr: Sprite2D = mid_layer.get_node_or_null("MidgroundSprite")
		if is_instance_valid(spr):
			spr.texture = tex
			spr.position = Vector2(w * 0.5, h * 0.5)
		mid_layer.visible = true
	else:
		if is_instance_valid(mid_layer):
			mid_layer.visible = false
