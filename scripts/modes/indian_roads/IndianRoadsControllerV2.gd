class_name IndianRoadsControllerV2
extends IndianRoadsController

## IndianRoadsControllerV2: Enhanced lifecycle coordinator for Indian Roads Mode (Visual Upgrade v2).
## Instantiates IndianRoadTerrainV2 with advanced 4-plane parallax layers (Sky, Clouds, Distant, Midground)
## and organic, zone-based roadside scenery without repetitive looped textures.

const IndianRoadTerrainV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
const BGM_INDIAN_ROADS: AudioStream = preload("res://assets/audio/indian_roads/music/hitslab-indian-indian-music-634358.mp3")

@onready var music_player: AudioStreamPlayer = get_node_or_null("MusicPlayer")

func _ready() -> void:
	_setup_audio()
	super._ready()

func _setup_audio() -> void:
	if not is_instance_valid(music_player):
		music_player = get_node_or_null("MusicPlayer")
	if not is_instance_valid(music_player):
		music_player = AudioStreamPlayer.new()
		music_player.name = "MusicPlayer"
		music_player.bus = &"Music"
		add_child(music_player)

	music_player.stream = BGM_INDIAN_ROADS
	music_player.volume_db = -6.0
	music_player.bus = &"Music"
	if not music_player.finished.is_connected(_on_music_finished):
		music_player.finished.connect(_on_music_finished)
	if not music_player.playing:
		music_player.play()

func _on_music_finished() -> void:
	if is_instance_valid(music_player) and is_inside_tree():
		music_player.play()

func _on_pause_requested() -> void:
	super._on_pause_requested()
	if is_instance_valid(music_player) and music_player.playing:
		music_player.stream_paused = true

func _on_resume_requested() -> void:
	super._on_resume_requested()
	if is_instance_valid(music_player) and music_player.stream_paused:
		music_player.stream_paused = false

func _on_restart_from_pause() -> void:
	super._on_restart_from_pause()
	if is_instance_valid(music_player):
		music_player.stream_paused = false
		if not music_player.playing:
			music_player.play()

func _on_main_menu_from_pause() -> void:
	if is_instance_valid(music_player):
		music_player.stop()
	super._on_main_menu_from_pause()

func _on_map_requested() -> void:
	super._on_map_requested()
	if is_instance_valid(music_player) and music_player.playing:
		music_player.stream_paused = true

func _on_map_closed() -> void:
	super._on_map_closed()
	if is_instance_valid(music_player) and music_player.stream_paused:
		music_player.stream_paused = false

func start_route(route: RouteData) -> void:
	super.start_route(route)
	if is_instance_valid(music_player):
		music_player.stream_paused = false
		if not music_player.playing:
			music_player.play()

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

var _goa_env_zone: String = ""

func _setup_parallax_textures() -> void:
	if active_route == null or not is_instance_valid(parallax_bg):
		return

	var state_id := active_route.state_id
	var sky_path := ""
	var bg_path := ""
	var mid_path := ""
	var cloud_path := ""
	_goa_env_zone = ""

	match state_id:
		"tamil_nadu":
			sky_path = "res://assets/indian_locations/tamil_nadu/backgrounds/sky/kanyakumari_sky_coastal.png"
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_01_cape_comorin.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_01_coastal_groves.png"
			cloud_path = "res://assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png"
			_tn_env_zone = "kanyakumari"
		"goa":
			sky_path = "res://assets/indian_locations/goa/backgrounds/sky/goa_tropical_sky.png"
			bg_path = "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png"
			mid_path = "res://assets/indian_locations/goa/backgrounds/village/goa_portuguese_village_row.png"
			cloud_path = "res://assets/indian_locations/common/clouds/cloud_cumulus_soft_02.png"
			_goa_env_zone = "heritage"
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
		plains_layer.motion_scale = Vector2(0.10, 0) if state_id == "goa" else Vector2(0.12, 0)
	if is_instance_valid(parallax_plains_sprite) and ResourceLoader.exists(bg_path):
		var bg_tex: Texture2D = load(bg_path)
		parallax_plains_sprite.texture = bg_tex
		var w: float = float(bg_tex.get_width())
		var h: float = float(bg_tex.get_height())
		if state_id in ["goa", "tamil_nadu"]:
			# Keep sky open: place distant hills/sea lower, not as full-screen wall.
			parallax_plains_sprite.scale = Vector2(1.0, 0.78)
			parallax_plains_sprite.position = Vector2(w * 0.5, 520.0 - (h * 0.78) * 0.5)
		else:
			parallax_plains_sprite.scale = Vector2.ONE
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

func _process(delta: float) -> void:
	super._process(delta)
	_update_goa_environment_zones()
	_update_tamil_nadu_environment_zones()

var _tn_env_zone: String = ""

func _update_tamil_nadu_environment_zones() -> void:
	if active_route == null or active_route.state_id != "tamil_nadu" or not is_instance_valid(parallax_bg):
		return

	var d: float = session_distance_m
	var zone := "kanyakumari"
	if d < 60.0:
		zone = "kanyakumari"
	elif d < 150.0:
		zone = "nagercoil"
	elif d < 250.0:
		zone = "tirunelveli"
	elif d < 350.0:
		zone = "kovilpatti"
	elif d < 450.0:
		zone = "virudhunagar"
	elif d < 550.0:
		zone = "madurai"
	elif d < 650.0:
		zone = "melur"
	elif d < 750.0:
		zone = "tiruchirappalli"
	elif d < 850.0:
		zone = "perambalur"
	elif d < 950.0:
		zone = "villupuram"
	elif d < 1050.0:
		zone = "tindivanam"
	elif d < 1150.0:
		zone = "chengalpattu"
	else:
		zone = "chennai"

	if zone == _tn_env_zone:
		return
	_tn_env_zone = zone

	var bg_path := "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_01_cape_comorin.png"
	var mid_path := "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_01_coastal_groves.png"
	var target_shoulder := Color(0.85, 0.72, 0.50, 1.0) # Coastal golden sand

	match zone:
		"kanyakumari":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_01_cape_comorin.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_01_coastal_groves.png"
			target_shoulder = Color(0.85, 0.72, 0.50, 1.0)
		"nagercoil":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_02_nagercoil.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_02_countryside_green.png"
			target_shoulder = Color(0.48, 0.58, 0.28, 1.0)
		"tirunelveli":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_03_tirunelveli.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_02_countryside_green.png"
			target_shoulder = Color(0.72, 0.32, 0.18, 1.0)
		"kovilpatti":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_04_kovilpatti.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_03_palmyra_scrub.png"
			target_shoulder = Color(0.75, 0.45, 0.22, 1.0)
		"virudhunagar":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_05_virudhunagar.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_03_palmyra_scrub.png"
			target_shoulder = Color(0.68, 0.48, 0.28, 1.0)
		"madurai":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_06_madurai.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_04_granite_boulders.png"
			target_shoulder = Color(0.62, 0.44, 0.34, 1.0)
		"melur":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_07_melur.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_04_granite_boulders.png"
			target_shoulder = Color(0.55, 0.52, 0.48, 1.0)
		"tiruchirappalli":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_08_tiruchirappalli.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_04_granite_boulders.png"
			target_shoulder = Color(0.46, 0.42, 0.35, 1.0)
		"perambalur":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_09_perambalur.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_05_paddy_terraces.png"
			target_shoulder = Color(0.58, 0.54, 0.36, 1.0)
		"villupuram":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_10_villupuram.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_05_paddy_terraces.png"
			target_shoulder = Color(0.52, 0.46, 0.38, 1.0)
		"tindivanam":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_11_tindivanam.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_05_paddy_terraces.png"
			target_shoulder = Color(0.60, 0.48, 0.32, 1.0)
		"chengalpattu":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_12_chengalpattu.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_05_paddy_terraces.png"
			target_shoulder = Color(0.42, 0.48, 0.42, 1.0)
		"chennai":
			bg_path = "res://assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_nadu_bg_13_chennai.png"
			mid_path = "res://assets/indian_locations/tamil_nadu/backgrounds/midground/tamil_nadu_mid_06_urban_corridor.png"
			target_shoulder = Color(0.38, 0.38, 0.40, 1.0)

	# Update distant horizon (PlainsLayer) with smooth crossfade
	if is_instance_valid(parallax_plains_sprite) and ResourceLoader.exists(bg_path):
		var bg_tex: Texture2D = load(bg_path)
		if bg_tex and parallax_plains_sprite.texture != bg_tex:
			var old_mod := parallax_plains_sprite.modulate
			var twp := create_tween()
			if is_instance_valid(twp):
				twp.tween_property(parallax_plains_sprite, "modulate:a", 0.35, 0.30)
				twp.tween_callback(func():
					if not is_instance_valid(parallax_plains_sprite): return
					parallax_plains_sprite.texture = bg_tex
					var w := float(bg_tex.get_width())
					var h := float(bg_tex.get_height())
					parallax_plains_sprite.scale = Vector2(1.0, 0.78)
					parallax_plains_sprite.position = Vector2(w * 0.5, 520.0 - (h * 0.78) * 0.5)
					var plains_layer: ParallaxLayer = parallax_bg.get_node_or_null("PlainsLayer")
					if is_instance_valid(plains_layer):
						plains_layer.motion_mirroring = Vector2(w, 0)
				)
				twp.tween_property(parallax_plains_sprite, "modulate:a", old_mod.a, 0.40)
			else:
				parallax_plains_sprite.texture = bg_tex
				var w := float(bg_tex.get_width())
				var h := float(bg_tex.get_height())
				parallax_plains_sprite.scale = Vector2(1.0, 0.78)
				parallax_plains_sprite.position = Vector2(w * 0.5, 520.0 - (h * 0.78) * 0.5)

	# Update midground layer with gentle fade
	var mid_layer: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer")
	if is_instance_valid(mid_layer):
		var twm := create_tween()
		if is_instance_valid(twm):
			twm.tween_property(mid_layer, "modulate:a", 0.25, 0.25)
			twm.tween_callback(func():
				if not is_instance_valid(self): return
				_setup_midground_layer(mid_path)
				var ml: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer") if is_instance_valid(parallax_bg) else null
				if is_instance_valid(ml):
					ml.modulate.a = 0.25
					var tw2 := create_tween()
					if is_instance_valid(tw2):
						tw2.tween_property(ml, "modulate:a", 1.0, 0.40)
			)
		else:
			_setup_midground_layer(mid_path)
	else:
		_setup_midground_layer(mid_path)

	# Update road shoulder soil color dynamically
	if is_instance_valid(active_terrain):
		var tw_col := create_tween()
		if is_instance_valid(tw_col):
			tw_col.tween_property(active_terrain, "shoulder_color", target_shoulder, 1.2)
			tw_col.tween_callback(func():
				if is_instance_valid(active_terrain):
					active_terrain.queue_redraw()
			)
		else:
			active_terrain.shoulder_color = target_shoulder
			active_terrain.queue_redraw()

func _update_goa_environment_zones() -> void:
	if active_route == null or active_route.state_id != "goa" or not is_instance_valid(parallax_bg):
		return
	# Goa route zones (950m): Heritage 0-200, Coastal 200-430, Green/Forest 430-620, Old Goa Heritage 620-820, South Goa Beach 820-950
	var d: float = session_distance_m
	var zone := "heritage"
	if d < 200.0:
		zone = "heritage"
	elif d < 430.0:
		zone = "coastal"
	elif d < 620.0:
		zone = "green"
	elif d < 820.0:
		zone = "old_goa"
	else:
		zone = "south_beach"
	if zone == _goa_env_zone:
		return
	_goa_env_zone = zone

	var bg_path := "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png"
	var mid_path := "res://assets/indian_locations/goa/backgrounds/village/goa_portuguese_village_row.png"
	match zone:
		"heritage":
			bg_path = "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png"
			mid_path = "res://assets/indian_locations/goa/backgrounds/village/goa_portuguese_village_row.png"
		"coastal":
			bg_path = "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_coastal_midground.png"
			mid_path = "res://assets/indian_locations/goa/backgrounds/village/goa_portuguese_village_row.png"
		"green":
			bg_path = "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png"
			mid_path = "res://assets/indian_locations/goa/inland_goa/mollem_forest_environment.png"
		"old_goa":
			bg_path = "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png"
			mid_path = "res://assets/indian_locations/goa/backgrounds/village/goa_portuguese_village_row.png"
		"south_beach":
			bg_path = "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_coastal_midground.png"
			mid_path = "res://assets/indian_locations/goa/backgrounds/distant_landscape/goa_coastal_midground.png"

	# Update distant horizon (PlainsLayer) - gradual Goa-only transition
	if is_instance_valid(parallax_plains_sprite) and ResourceLoader.exists(bg_path):
		var bg_tex: Texture2D = load(bg_path)
		if bg_tex and parallax_plains_sprite.texture != bg_tex:
			var old_mod := parallax_plains_sprite.modulate
			var twp := create_tween()
			if is_instance_valid(twp):
				twp.tween_property(parallax_plains_sprite, "modulate:a", 0.35, 0.25)
				twp.tween_callback(func():
					if not is_instance_valid(parallax_plains_sprite): return
					parallax_plains_sprite.texture = bg_tex
					var w := float(bg_tex.get_width())
					var h := float(bg_tex.get_height())
					parallax_plains_sprite.scale = Vector2(1.0, 0.78)
					parallax_plains_sprite.position = Vector2(w * 0.5, 520.0 - (h * 0.78) * 0.5)
					var plains_layer: ParallaxLayer = parallax_bg.get_node_or_null("PlainsLayer")
					if is_instance_valid(plains_layer):
						plains_layer.motion_mirroring = Vector2(w, 0)
				)
				twp.tween_property(parallax_plains_sprite, "modulate:a", old_mod.a, 0.35)
			else:
				parallax_plains_sprite.texture = bg_tex
				var w := float(bg_tex.get_width())
				var h := float(bg_tex.get_height())
				parallax_plains_sprite.scale = Vector2(1.0, 0.78)
				parallax_plains_sprite.position = Vector2(w * 0.5, 520.0 - (h * 0.78) * 0.5)

	# Update midground layer with a gentle fade
	var mid_layer: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer")
	if is_instance_valid(mid_layer):
		var twm := create_tween()
		if is_instance_valid(twm):
			twm.tween_property(mid_layer, "modulate:a", 0.25, 0.20)
			twm.tween_callback(func():
				if not is_instance_valid(self): return
				_setup_midground_layer(mid_path)
				var ml: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer") if is_instance_valid(parallax_bg) else null
				if is_instance_valid(ml):
					ml.modulate.a = 0.25
					var tw2 := create_tween()
					if is_instance_valid(tw2):
						tw2.tween_property(ml, "modulate:a", 1.0, 0.35)
			)
		else:
			_setup_midground_layer(mid_path)
	else:
		_setup_midground_layer(mid_path)

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

	var is_goa := active_route != null and active_route.state_id == "goa"
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

		# Clear any previous Goa cluster sprites when rebuilding
		for c in mid_layer.get_children():
			if c is Sprite2D and c.name != "MidgroundSprite":
				c.queue_free()

		var spr: Sprite2D = mid_layer.get_node_or_null("MidgroundSprite")
		if is_goa:
			_apply_goa_midground_layout(mid_layer, spr, tex, mid_path)
		else:
			mid_layer.motion_scale = Vector2(0.25, 0)
			mid_layer.motion_mirroring = Vector2(w, 0)
			if is_instance_valid(spr):
				spr.visible = true
				spr.texture = tex
				spr.scale = Vector2.ONE
				spr.modulate = Color(1, 1, 1, 1)
				spr.position = Vector2(w * 0.5, h * 0.5)
		mid_layer.visible = true
	else:
		if is_instance_valid(mid_layer):
			mid_layer.visible = false

func _apply_goa_midground_layout(mid_layer: ParallaxLayer, spr: Sprite2D, tex: Texture2D, mid_path: String) -> void:
	# Goa-only: fix oversized/repeating background composition. Keep vehicle/road/camera/shared systems unchanged.
	var w: float = float(tex.get_width())
	var h: float = float(tex.get_height())
	var is_village := "portuguese_village_row" in mid_path
	var is_forest := "mollem_forest_environment" in mid_path
	var is_coastal := "goa_coastal_midground" in mid_path

	if is_village:
		# Small distant village clusters: scaled down, spaced out, varied depth - no continuous wallpaper row.
		mid_layer.motion_scale = Vector2(0.16, 0)
		mid_layer.motion_mirroring = Vector2(w * 4.0, 0)
		if is_instance_valid(spr):
			spr.visible = true
			spr.texture = tex
			spr.scale = Vector2(0.34, 0.34)
			spr.modulate = Color(0.93, 0.95, 0.91, 0.88)
			var scaled_h := h * 0.34
			spr.position = Vector2(w * 0.55, 432.0 - scaled_h * 0.5)
			spr.flip_h = false
		var configs := [
			{"name":"MidgroundSprite2","x":w * 1.55,"s":0.26,"a":0.72,"y":424.0,"flip":true},
			{"name":"MidgroundSprite3","x":w * 2.45,"s":0.38,"a":0.84,"y":436.0,"flip":false},
			{"name":"MidgroundSprite4","x":w * 3.35,"s":0.24,"a":0.66,"y":420.0,"flip":true},
		]
		for cfg in configs:
			var cs := mid_layer.get_node_or_null(cfg["name"]) as Sprite2D
			if cs == null:
				cs = Sprite2D.new()
				cs.name = cfg["name"]
				mid_layer.add_child(cs)
			cs.texture = tex
			var sc: float = float(cfg["s"])
			cs.scale = Vector2(sc, sc)
			cs.modulate = Color(0.92, 0.94, 0.90, float(cfg["a"]))
			cs.position = Vector2(float(cfg["x"]), float(cfg["y"]) - h * sc * 0.5)
			cs.flip_h = bool(cfg["flip"])
			cs.visible = true
	elif is_forest:
		# Western Ghats/forest: lower, layered, not a flat wall.
		mid_layer.motion_scale = Vector2(0.20, 0)
		mid_layer.motion_mirroring = Vector2(w, 0)
		if is_instance_valid(spr):
			spr.visible = true
			spr.texture = tex
			spr.scale = Vector2(1.0, 0.72)
			spr.modulate = Color(0.92, 0.98, 0.90, 0.95)
			var scaled_h := h * 0.72
			spr.position = Vector2(w * 0.5, 470.0 - scaled_h * 0.5)
	elif is_coastal:
		# Coastal midground: keep low and airy so sky/sea feel open.
		mid_layer.motion_scale = Vector2(0.16, 0)
		mid_layer.motion_mirroring = Vector2(w, 0)
		if is_instance_valid(spr):
			spr.visible = true
			spr.texture = tex
			spr.scale = Vector2(1.0, 0.82)
			spr.modulate = Color(1.0, 1.0, 1.0, 0.95)
			var scaled_h := h * 0.82
			spr.position = Vector2(w * 0.5, 455.0 - scaled_h * 0.5)
	else:
		mid_layer.motion_scale = Vector2(0.22, 0)
		mid_layer.motion_mirroring = Vector2(w, 0)
		if is_instance_valid(spr):
			spr.visible = true
			spr.texture = tex
			spr.scale = Vector2(1.0, 0.75)
			spr.modulate = Color(1, 1, 1, 0.95)
			var scaled_h := h * 0.75
			spr.position = Vector2(w * 0.5, 450.0 - scaled_h * 0.5)
