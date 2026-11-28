class_name IndianRoadsControllerV2
extends IndianRoadsController

## IndianRoadsControllerV2: Enhanced lifecycle coordinator for Indian Roads Mode (Visual Upgrade v2).
## Instantiates IndianRoadTerrainV2 with advanced 4-plane parallax layers (Sky, Clouds, Distant, Midground)
## and organic, zone-based roadside scenery without repetitive looped textures.

const IndianRoadTerrainV2Scene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
const KeralaLocationManager = preload("res://scripts/modes/indian_roads/KeralaLocationManager.gd")
const KeralaTerrainHelper = preload("res://scripts/modes/indian_roads/KeralaTerrainHelper.gd")
const RajasthanLocationManager = preload("res://scripts/modes/indian_roads/RajasthanLocationManager.gd")
const RajasthanTerrainHelper = preload("res://scripts/modes/indian_roads/RajasthanTerrainHelper.gd")
const TelanganaLocationManager = preload("res://scripts/modes/indian_roads/TelanganaLocationManager.gd")
const TelanganaTerrainHelper = preload("res://scripts/modes/indian_roads/TelanganaTerrainHelper.gd")
const TamilNaduLocationManager = preload("res://scripts/modes/indian_roads/TamilNaduLocationManager.gd")
const TamilNaduTerrainHelper = preload("res://scripts/modes/indian_roads/TamilNaduTerrainHelper.gd")

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
var _kerala_env_zone: String = ""
var _kerala_announced_zones: Dictionary = {}
var _kerala_loc_mgr: KeralaLocationManager = KeralaLocationManager.new()
var _rj_env_zone: String = ""
var _rj_announced_zones: Dictionary = {}
var _rj_loc_mgr: RajasthanLocationManager = RajasthanLocationManager.new()
var _tg_env_zone: String = ""
var _tg_announced_zones: Dictionary = {}
var _tg_loc_mgr: TelanganaLocationManager = TelanganaLocationManager.new()
var _tn_announced_zones: Dictionary = {}
var _tn_loc_mgr: TamilNaduLocationManager = TamilNaduLocationManager.new()

# PERF: Goa parallax texture cache — all 9 Goa parallax PNGs loaded once at route start
# so _update_goa_environment_zones() never calls synchronous load() during gameplay.
var _goa_tex_cache: Dictionary = {}

func _setup_parallax_textures() -> void:
	if active_route == null or not is_instance_valid(parallax_bg):
		return

	var state_id := active_route.state_id
	var sky_path := ""
	var bg_path := ""
	var mid_path := ""
	var cloud_path := ""
	_goa_env_zone = ""
	_kerala_env_zone = ""
	_kerala_announced_zones.clear()
	_rj_env_zone = ""
	_rj_announced_zones.clear()
	_tg_env_zone = ""
	_tg_announced_zones.clear()
	_tn_env_zone = ""
	_tn_announced_zones.clear()

	match state_id:
		"tamil_nadu":
			_tn_loc_mgr.reset(0.0)
			var tn_cfg := _tn_loc_mgr.get_zone_config(0)
			sky_path = tn_cfg["sky"]
			bg_path = tn_cfg["dist"]
			mid_path = tn_cfg["mid"]
			cloud_path = "res://assets/indian_locations/tamil_nadu/v3/parallax/clouds_tn_natural.png"
			_tn_env_zone = tn_cfg["id"]
			_tn_announced_zones[_tn_env_zone] = true
		"goa":
			sky_path = "res://assets/indian_locations/goa/v3/parallax/sky_goa_tropical.png"
			bg_path = "res://assets/indian_locations/goa/v3/parallax/dist_north_goa.png"
			mid_path = "res://assets/indian_locations/goa/v3/parallax/mid_north_goa.png"
			cloud_path = "res://assets/indian_locations/goa/v3/parallax/clouds_goa_natural.png"
			_goa_env_zone = "north_goa"
			# PERF: preload all Goa parallax textures NOW (at route start, not during gameplay)
			_goa_tex_cache.clear()
			var _goa_all_paths: Array[String] = [
				"res://assets/indian_locations/goa/v3/parallax/sky_goa_tropical.png",
				"res://assets/indian_locations/goa/v3/parallax/dist_north_goa.png",
				"res://assets/indian_locations/goa/v3/parallax/dist_central_goa.png",
				"res://assets/indian_locations/goa/v3/parallax/dist_east_goa.png",
				"res://assets/indian_locations/goa/v3/parallax/dist_south_goa.png",
				"res://assets/indian_locations/goa/v3/parallax/mid_north_goa.png",
				"res://assets/indian_locations/goa/v3/parallax/mid_central_goa.png",
				"res://assets/indian_locations/goa/v3/parallax/mid_east_goa.png",
				"res://assets/indian_locations/goa/v3/parallax/mid_south_goa.png",
				"res://assets/indian_locations/goa/v3/parallax/clouds_goa_natural.png",
			]
			for _p in _goa_all_paths:
				if ResourceLoader.exists(_p):
					_goa_tex_cache[_p] = load(_p) as Texture2D
		"kerala":
			_kerala_loc_mgr.reset(0.0)
			var k_cfg := _kerala_loc_mgr.get_zone_config(0)
			sky_path = k_cfg["sky"]
			bg_path = k_cfg["dist"]
			mid_path = k_cfg["mid"]
			cloud_path = "res://assets/indian_locations/kerala/v3/parallax/clouds_kerala.png"
			_kerala_env_zone = k_cfg["id"]
			_kerala_announced_zones[_kerala_env_zone] = true
		"rajasthan":
			_rj_loc_mgr.reset(0.0)
			var r_cfg := _rj_loc_mgr.get_zone_config(0)
			sky_path = r_cfg["sky"]
			bg_path = r_cfg["dist"]
			mid_path = r_cfg["mid"]
			cloud_path = "res://assets/indian_locations/rajasthan/v3/parallax/clouds_rj_natural.png"
			_rj_env_zone = r_cfg["id"]
			_rj_announced_zones[_rj_env_zone] = true
		"gujarat":
			sky_path = "res://assets/indian_locations/gujarat/backgrounds/sky/gujarat_sky_pale_azure.png"
			bg_path = "res://assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_great_rann_white_salt.png"
			mid_path = "res://assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_saurashtra_savanna_midground.png"
			cloud_path = "res://assets/indian_locations/common/clouds/cloud_stratus_horizon.png"
		"telangana":
			_tg_loc_mgr.reset(0.0)
			var t_cfg := _tg_loc_mgr.get_zone_config(0)
			sky_path = t_cfg["sky"]
			bg_path = t_cfg["dist"]
			mid_path = t_cfg["mid"]
			cloud_path = "res://assets/indian_locations/telangana/v3/parallax/clouds_hyd_natural.png"
			_tg_env_zone = t_cfg["id"]
			_tg_announced_zones[_tg_env_zone] = true
		_:
			sky_path = active_route.sky_texture_path
			bg_path = active_route.parallax_bg_path

	var is_scenic_v3 := (state_id in ["goa", "kerala", "rajasthan", "telangana", "tamil_nadu"])

	# 1. Sky Plane (motion_scale 0.01 for Goa/Kerala, 0.02 for others, centered at w * 0.5, h * 0.5)
	var sky_layer: ParallaxLayer = parallax_bg.get_node_or_null("SkyLayer")
	if is_instance_valid(sky_layer):
		sky_layer.motion_scale = Vector2(0.01, 0) if is_scenic_v3 else Vector2(0.02, 0)
	if is_instance_valid(parallax_sky_sprite) and ResourceLoader.exists(sky_path):
		var sky_tex: Texture2D = load(sky_path)
		parallax_sky_sprite.texture = sky_tex
		var w: float = float(sky_tex.get_width())
		var h: float = float(sky_tex.get_height())
		parallax_sky_sprite.scale = Vector2.ONE
		parallax_sky_sprite.position = Vector2(w * 0.5, h * 0.5)
		if is_instance_valid(sky_layer):
			sky_layer.motion_mirroring = Vector2(w, 0)

	# 2. Distant Horizon Plane
	var plains_layer: ParallaxLayer = parallax_bg.get_node_or_null("PlainsLayer")
	if is_instance_valid(plains_layer):
		plains_layer.motion_scale = Vector2(0.11, 0) if is_scenic_v3 else Vector2(0.12, 0)
	if is_instance_valid(parallax_plains_sprite) and ResourceLoader.exists(bg_path):
		var bg_tex: Texture2D = load(bg_path)
		parallax_plains_sprite.texture = bg_tex
		var w: float = float(bg_tex.get_width())
		var h: float = float(bg_tex.get_height())
		if is_scenic_v3:
			# Natural 1:1 ratio, baseline extends to y=600 (540px after 0.9 zoom) so zero gap ever appears on road dips
			parallax_plains_sprite.scale = Vector2.ONE
			parallax_plains_sprite.position = Vector2(w * 0.5, 595.0 - h * 0.5)
		elif state_id == "tamil_nadu":
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

func _setup_ui() -> void:
	super._setup_ui()
	if is_instance_valid(hud) and active_route != null:
		if active_route.state_id == "goa" and hud.has_method("set_section_badge"):
			hud.set_section_badge("North Goa • Coastal Forts")
		elif active_route.state_id == "kerala" and hud.has_method("set_section_badge"):
			hud.set_section_badge("1. Kochi • Arabian Sea Coast")
		elif active_route.state_id == "rajasthan" and hud.has_method("set_section_badge"):
			hud.set_section_badge("1. Jaipur • Pink City Heritage")
		elif active_route.state_id == "telangana" and hud.has_method("set_section_badge"):
			hud.set_section_badge("OLD HYDERABAD")
			if hud.has_method("show_announcement_toast"):
				hud.show_announcement_toast("ROUTE STARTED: HYDERABAD", "Old Hyderabad • Charminar to Golconda Fort")
		elif active_route.state_id == "tamil_nadu" and hud.has_method("set_section_badge"):
			hud.set_section_badge("1. Kanyakumari Coast")
		elif hud.has_method("set_section_badge"):
			hud.set_section_badge("")

func _process(delta: float) -> void:
	super._process(delta)
	if current_state == ModeState.PLAYING and active_route != null and active_route.state_id in ["goa", "kerala", "rajasthan"]:
		if is_instance_valid(active_vehicle) and active_vehicle.is_active:
			var accel := Input.get_action_strength("accelerate")
			if accel > 0.1:
				var rate := 1.45 if active_route.state_id == "goa" else (1.25 if active_route.state_id == "kerala" else 1.20)
				active_vehicle.consume_fuel(rate * accel * delta)
	if active_route != null and active_route.state_id == "kerala":
		_kerala_loc_mgr.update_streaming(session_distance_m)
		if is_instance_valid(active_terrain) and is_instance_valid(active_vehicle):
			KeralaTerrainHelper.update_visible_chunks(active_terrain as IndianRoadTerrainV2, active_vehicle.global_position.x)
	elif active_route != null and active_route.state_id == "rajasthan":
		_rj_loc_mgr.update_streaming(session_distance_m)
		if is_instance_valid(active_terrain) and is_instance_valid(active_vehicle):
			RajasthanTerrainHelper.update_visible_chunks(active_terrain as IndianRoadTerrainV2, active_vehicle.global_position.x)
	elif active_route != null and active_route.state_id == "telangana":
		_tg_loc_mgr.update_streaming(session_distance_m)
		if is_instance_valid(active_terrain) and is_instance_valid(active_vehicle):
			TelanganaTerrainHelper.update_visible_chunks(active_terrain as IndianRoadTerrainV2, active_vehicle.global_position.x)
	elif active_route != null and active_route.state_id == "tamil_nadu":
		_tn_loc_mgr.update_streaming(session_distance_m)
		if is_instance_valid(active_terrain) and is_instance_valid(active_vehicle):
			TamilNaduTerrainHelper.update_visible_chunks(active_terrain as IndianRoadTerrainV2, active_vehicle.global_position.x)
	_update_goa_environment_zones()
	_update_kerala_environment_zones()
	_update_rajasthan_environment_zones()
	_update_telangana_environment_zones()
	_update_tamil_nadu_environment_zones()

var _tn_env_zone: String = ""

func _update_tamil_nadu_environment_zones() -> void:
	if current_state != ModeState.PLAYING or active_route == null or active_route.state_id != "tamil_nadu" or not is_instance_valid(parallax_bg):
		return

	var zone_idx := _tn_loc_mgr.get_zone_index(session_distance_m)
	var cfg := _tn_loc_mgr.get_zone_config(zone_idx)
	var zone: String = cfg["id"]
	if zone == _tn_env_zone:
		return
	_tn_env_zone = zone

	if is_instance_valid(hud):
		if hud.has_method("set_section_badge"):
			hud.set_section_badge(cfg["badge"])
		if not _tn_announced_zones.has(zone):
			_tn_announced_zones[zone] = true
			if hud.has_method("show_announcement_toast"):
				hud.show_announcement_toast(cfg["title"], cfg["sub"])

	_apply_v3_zone_visuals(
		_tn_loc_mgr.get_texture(cfg["sky"]),
		_tn_loc_mgr.get_texture(cfg["dist"]),
		cfg["mid"],
		"tamil_nadu"
	)

func _update_goa_environment_zones() -> void:
	if current_state != ModeState.PLAYING or active_route == null or active_route.state_id != "goa" or not is_instance_valid(parallax_bg):
		return
	# Goa 4-Section Route (1200m): North (0-310), Central (310-620), East (620-900), South (900-1200)
	var d: float = session_distance_m
	var zone := "north_goa"
	if d < 310.0:
		zone = "north_goa"
	elif d < 620.0:
		zone = "central_goa"
	elif d < 900.0:
		zone = "east_goa"
	else:
		zone = "south_goa"
	if zone == _goa_env_zone:
		return
	_goa_env_zone = zone

	var bg_path := "res://assets/indian_locations/goa/v3/parallax/dist_north_goa.png"
	var mid_path := "res://assets/indian_locations/goa/v3/parallax/mid_north_goa.png"
	var target_shoulder := Color(0.87, 0.76, 0.51, 1.0)
	var badge_text := "North Goa • Coastal Forts"

	match zone:
		"north_goa":
			bg_path = "res://assets/indian_locations/goa/v3/parallax/dist_north_goa.png"
			mid_path = "res://assets/indian_locations/goa/v3/parallax/mid_north_goa.png"
			target_shoulder = Color(0.87, 0.76, 0.51, 1.0)
			badge_text = "North Goa • Coastal Forts"
		"central_goa":
			bg_path = "res://assets/indian_locations/goa/v3/parallax/dist_central_goa.png"
			mid_path = "res://assets/indian_locations/goa/v3/parallax/mid_central_goa.png"
			target_shoulder = Color(0.68, 0.36, 0.24, 1.0)
			badge_text = "Central Goa • Panaji & Old Goa"
		"east_goa":
			bg_path = "res://assets/indian_locations/goa/v3/parallax/dist_east_goa.png"
			mid_path = "res://assets/indian_locations/goa/v3/parallax/mid_east_goa.png"
			target_shoulder = Color(0.56, 0.31, 0.20, 1.0)
			badge_text = "East Goa • Western Ghats"
		"south_goa":
			bg_path = "res://assets/indian_locations/goa/v3/parallax/dist_south_goa.png"
			mid_path = "res://assets/indian_locations/goa/v3/parallax/mid_south_goa.png"
			target_shoulder = Color(0.90, 0.78, 0.54, 1.0)
			badge_text = "South Goa • Palolem Coast"

	if is_instance_valid(hud) and hud.has_method("set_section_badge"):
		hud.set_section_badge(badge_text)

	# Update distant horizon (PlainsLayer) with smooth crossfade
	# PERF: use preloaded cache — zero synchronous load() stall during gameplay
	if is_instance_valid(parallax_plains_sprite) and ResourceLoader.exists(bg_path):
		var bg_tex: Texture2D = _goa_tex_cache.get(bg_path, null)
		if bg_tex == null and ResourceLoader.exists(bg_path):
			bg_tex = load(bg_path)
			_goa_tex_cache[bg_path] = bg_tex
		if bg_tex and parallax_plains_sprite.texture != bg_tex:
			var old_mod := parallax_plains_sprite.modulate
			var twp := create_tween()
			if is_instance_valid(twp):
				twp.tween_property(parallax_plains_sprite, "modulate:a", 0.30, 0.25)
				twp.tween_callback(func():
					if not is_instance_valid(parallax_plains_sprite): return
					parallax_plains_sprite.texture = bg_tex
					var w := float(bg_tex.get_width())
					var h := float(bg_tex.get_height())
					parallax_plains_sprite.scale = Vector2.ONE
					parallax_plains_sprite.position = Vector2(w * 0.5, 595.0 - h * 0.5)
					var plains_layer: ParallaxLayer = parallax_bg.get_node_or_null("PlainsLayer")
					if is_instance_valid(plains_layer):
						plains_layer.motion_mirroring = Vector2(w, 0)
				)
				twp.tween_property(parallax_plains_sprite, "modulate:a", old_mod.a, 0.35)
			else:
				parallax_plains_sprite.texture = bg_tex
				var w := float(bg_tex.get_width())
				var h := float(bg_tex.get_height())
				parallax_plains_sprite.scale = Vector2.ONE
				parallax_plains_sprite.position = Vector2(w * 0.5, 595.0 - h * 0.5)

	# Update midground layer with a gentle fade
	var mid_layer: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer")
	if is_instance_valid(mid_layer):
		var twm := create_tween()
		if is_instance_valid(twm):
			twm.tween_property(mid_layer, "modulate:a", 0.25, 0.20)
			twm.tween_callback(func():
				if not is_instance_valid(self) or active_route == null or active_route.state_id != "goa": return
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

	# Smoothly transition Goa road shoulder soil tone across coastal/inland sections
	if is_instance_valid(active_terrain):
		var tw_col := create_tween()
		if is_instance_valid(tw_col):
			tw_col.tween_property(active_terrain, "shoulder_color", target_shoulder, 1.0)
			tw_col.tween_callback(func():
				if is_instance_valid(active_terrain):
					active_terrain.queue_redraw()
			)
		else:
			active_terrain.shoulder_color = target_shoulder
			active_terrain.queue_redraw()

func _update_kerala_environment_zones() -> void:
	if current_state != ModeState.PLAYING or active_route == null or active_route.state_id != "kerala" or not is_instance_valid(parallax_bg):
		return

	var zone_idx := _kerala_loc_mgr.get_zone_index(session_distance_m)
	var cfg := _kerala_loc_mgr.get_zone_config(zone_idx)
	var zone: String = cfg["id"]

	if zone == _kerala_env_zone:
		return
	_kerala_env_zone = zone

	var sky_path: String = cfg["sky"]
	var bg_path: String = cfg["dist"]
	var mid_path: String = cfg["mid"]

	if is_instance_valid(hud):
		if hud.has_method("set_section_badge"):
			hud.set_section_badge(cfg["badge"])
		if not _kerala_announced_zones.has(zone):
			_kerala_announced_zones[zone] = true
			if hud.has_method("show_announcement_toast"):
				hud.show_announcement_toast(cfg["title"], cfg["sub"])

	# Crossfade Sky from async preloaded cache only when switching coastal <-> highland atmosphere
	var sky_tex: Texture2D = _kerala_loc_mgr.get_texture(sky_path)
	if is_instance_valid(parallax_sky_sprite) and sky_tex and parallax_sky_sprite.texture != sky_tex:
		var tws := create_tween()
		if is_instance_valid(tws):
			tws.tween_property(parallax_sky_sprite, "modulate:a", 0.55, 0.30)
			tws.tween_callback(func():
				if active_route == null or active_route.state_id != "kerala": return
				if not is_instance_valid(parallax_sky_sprite): return
				parallax_sky_sprite.texture = sky_tex
				var w := float(sky_tex.get_width())
				var h := float(sky_tex.get_height())
				parallax_sky_sprite.scale = Vector2.ONE
				parallax_sky_sprite.position = Vector2(w * 0.5, h * 0.5)
				var sky_layer: ParallaxLayer = parallax_bg.get_node_or_null("SkyLayer")
				if is_instance_valid(sky_layer):
					sky_layer.motion_mirroring = Vector2(w, 0)
			)
			tws.tween_property(parallax_sky_sprite, "modulate:a", 1.0, 0.45)

	# Crossfade Distant Mountains / Waterfall / Tea Slopes from preloaded cache
	var bg_tex: Texture2D = _kerala_loc_mgr.get_texture(bg_path)
	if is_instance_valid(parallax_plains_sprite) and bg_tex and parallax_plains_sprite.texture != bg_tex:
		var old_mod := parallax_plains_sprite.modulate
		var twp := create_tween()
		if is_instance_valid(twp):
			twp.tween_property(parallax_plains_sprite, "modulate:a", 0.25, 0.28)
			twp.tween_callback(func():
				if active_route == null or active_route.state_id != "kerala": return
				if not is_instance_valid(parallax_plains_sprite): return
				parallax_plains_sprite.texture = bg_tex
				var w := float(bg_tex.get_width())
				var h := float(bg_tex.get_height())
				parallax_plains_sprite.scale = Vector2.ONE
				parallax_plains_sprite.position = Vector2(w * 0.5, 595.0 - h * 0.5)
				var plains_layer: ParallaxLayer = parallax_bg.get_node_or_null("PlainsLayer")
				if is_instance_valid(plains_layer):
					plains_layer.motion_mirroring = Vector2(w, 0)
			)
			twp.tween_property(parallax_plains_sprite, "modulate:a", old_mod.a, 0.40)
		else:
			parallax_plains_sprite.texture = bg_tex
			var w := float(bg_tex.get_width())
			var h := float(bg_tex.get_height())
			parallax_plains_sprite.scale = Vector2.ONE
			parallax_plains_sprite.position = Vector2(w * 0.5, 595.0 - h * 0.5)

	# Crossfade Midground Layer smoothly (cached texture -> 0ms stall, zero terrain re-tessellation!)
	var mid_layer: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer")
	if is_instance_valid(mid_layer):
		var twm := create_tween()
		if is_instance_valid(twm):
			twm.tween_property(mid_layer, "modulate:a", 0.22, 0.24)
			twm.tween_callback(func():
				if not is_instance_valid(self) or active_route == null or active_route.state_id != "kerala": return
				_setup_midground_layer(mid_path)
				var ml: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer") if is_instance_valid(parallax_bg) else null
				if is_instance_valid(ml):
					ml.modulate.a = 0.22
					var tw2 := create_tween()
					if is_instance_valid(tw2):
						tw2.tween_property(ml, "modulate:a", 1.0, 0.42)
			)
		else:
			_setup_midground_layer(mid_path)
	else:
		_setup_midground_layer(mid_path)

func _update_rajasthan_environment_zones() -> void:
	if current_state != ModeState.PLAYING or active_route == null or active_route.state_id != "rajasthan" or not is_instance_valid(parallax_bg):
		return

	var zone_idx := _rj_loc_mgr.get_zone_index(session_distance_m)
	var cfg := _rj_loc_mgr.get_zone_config(zone_idx)
	var zone: String = cfg["id"]
	if zone == _rj_env_zone:
		return
	_rj_env_zone = zone

	if is_instance_valid(hud):
		if hud.has_method("set_section_badge"):
			hud.set_section_badge(cfg["badge"])
		if not _rj_announced_zones.has(zone):
			_rj_announced_zones[zone] = true
			if hud.has_method("show_announcement_toast"):
				hud.show_announcement_toast(cfg["title"], cfg["sub"])

	_apply_v3_zone_visuals(
		_rj_loc_mgr.get_texture(cfg["sky"]),
		_rj_loc_mgr.get_texture(cfg["dist"]),
		cfg["mid"],
		"rajasthan"
	)

func _update_telangana_environment_zones() -> void:
	if current_state != ModeState.PLAYING or active_route == null or active_route.state_id != "telangana" or not is_instance_valid(parallax_bg):
		return

	var zone_idx := _tg_loc_mgr.get_zone_index(session_distance_m)
	var cfg := _tg_loc_mgr.get_zone_config(zone_idx)
	var zone: String = cfg["id"]
	if zone == _tg_env_zone:
		return
	_tg_env_zone = zone

	if is_instance_valid(hud):
		if hud.has_method("set_section_badge"):
			hud.set_section_badge(cfg["badge"])
		if not _tg_announced_zones.has(zone):
			_tg_announced_zones[zone] = true
			if hud.has_method("show_announcement_toast"):
				hud.show_announcement_toast(cfg["title"], cfg["sub"])

	_apply_v3_zone_visuals(
		_tg_loc_mgr.get_texture(cfg["sky"]),
		_tg_loc_mgr.get_texture(cfg["dist"]),
		cfg["mid"],
		"telangana"
	)

func _apply_v3_zone_visuals(sky_tex: Texture2D, bg_tex: Texture2D, mid_path: String, expected_state_id: String = "rajasthan") -> void:
	if is_instance_valid(parallax_sky_sprite) and sky_tex and parallax_sky_sprite.texture != sky_tex:
		var tws := create_tween()
		if is_instance_valid(tws):
			tws.tween_property(parallax_sky_sprite, "modulate:a", 0.55, 0.30)
			tws.tween_callback(func():
				if active_route == null or active_route.state_id != expected_state_id: return
				if not is_instance_valid(parallax_sky_sprite): return
				parallax_sky_sprite.texture = sky_tex
				var w := float(sky_tex.get_width())
				var h := float(sky_tex.get_height())
				parallax_sky_sprite.scale = Vector2.ONE
				parallax_sky_sprite.position = Vector2(w * 0.5, h * 0.5)
				var sky_layer: ParallaxLayer = parallax_bg.get_node_or_null("SkyLayer")
				if is_instance_valid(sky_layer):
					sky_layer.motion_mirroring = Vector2(w, 0)
			)
			tws.tween_property(parallax_sky_sprite, "modulate:a", 1.0, 0.45)

	if is_instance_valid(parallax_plains_sprite) and bg_tex and parallax_plains_sprite.texture != bg_tex:
		var old_mod := parallax_plains_sprite.modulate
		var twp := create_tween()
		if is_instance_valid(twp):
			twp.tween_property(parallax_plains_sprite, "modulate:a", 0.25, 0.28)
			twp.tween_callback(func():
				if active_route == null or active_route.state_id != expected_state_id: return
				if not is_instance_valid(parallax_plains_sprite): return
				parallax_plains_sprite.texture = bg_tex
				var w := float(bg_tex.get_width())
				var h := float(bg_tex.get_height())
				parallax_plains_sprite.scale = Vector2.ONE
				parallax_plains_sprite.position = Vector2(w * 0.5, 595.0 - h * 0.5)
				var plains_layer: ParallaxLayer = parallax_bg.get_node_or_null("PlainsLayer")
				if is_instance_valid(plains_layer):
					plains_layer.motion_mirroring = Vector2(w, 0)
			)
			twp.tween_property(parallax_plains_sprite, "modulate:a", old_mod.a, 0.40)
		else:
			parallax_plains_sprite.texture = bg_tex
			var w := float(bg_tex.get_width())
			var h := float(bg_tex.get_height())
			parallax_plains_sprite.scale = Vector2.ONE
			parallax_plains_sprite.position = Vector2(w * 0.5, 595.0 - h * 0.5)

	var mid_layer: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer")
	if is_instance_valid(mid_layer):
		var twm := create_tween()
		if is_instance_valid(twm):
			twm.tween_property(mid_layer, "modulate:a", 0.22, 0.24)
			twm.tween_callback(func():
				if not is_instance_valid(self) or active_route == null or active_route.state_id != expected_state_id: return
				_setup_midground_layer(mid_path)
				var ml: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer") if is_instance_valid(parallax_bg) else null
				if is_instance_valid(ml):
					ml.modulate.a = 0.22
					var tw2 := create_tween()
					if is_instance_valid(tw2):
						tw2.tween_property(ml, "modulate:a", 1.0, 0.42)
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

		var is_scenic_v3 := (active_route != null and active_route.state_id in ["goa", "kerala", "rajasthan", "telangana", "tamil_nadu"])
		cloud_layer.motion_scale = Vector2(0.05, 0) if is_scenic_v3 else Vector2(0.06, 0)
		cloud_layer.motion_mirroring = Vector2(w, 0)
		var spr: Sprite2D = cloud_layer.get_node_or_null("CloudsSprite")
		if is_instance_valid(spr):
			spr.texture = tex
			if is_scenic_v3:
				spr.position = Vector2(w * 0.5, 88.0 + h * 0.5)
				spr.modulate = Color(1.0, 1.0, 1.0, 0.96)
			else:
				spr.position = Vector2(w * 0.5, h * 0.5)
				spr.modulate = Color(1.0, 1.0, 1.0, 0.85)
		cloud_layer.visible = true
	else:
		if is_instance_valid(cloud_layer):
			cloud_layer.visible = false

func _setup_midground_layer(mid_path: String) -> void:
	if not is_instance_valid(parallax_bg):
		return

	var is_scenic_v3 := (active_route != null and active_route.state_id in ["goa", "kerala", "rajasthan", "telangana", "tamil_nadu"])
	var is_kerala := (active_route != null and active_route.state_id == "kerala")
	var is_rajasthan := (active_route != null and active_route.state_id == "rajasthan")
	var is_telangana := (active_route != null and active_route.state_id == "telangana")
	var is_tamil_nadu := (active_route != null and active_route.state_id == "tamil_nadu")
	var mid_layer: ParallaxLayer = parallax_bg.get_node_or_null("MidgroundLayer")
	if mid_path != "" and ResourceLoader.exists(mid_path):
		# PERF: use state-specific preloaded cache; Goa uses _goa_tex_cache to avoid sync load()
		var is_goa := (active_route != null and active_route.state_id == "goa")
		var tex: Texture2D = _kerala_loc_mgr.get_texture(mid_path) if is_kerala else (_rj_loc_mgr.get_texture(mid_path) if is_rajasthan else (_tg_loc_mgr.get_texture(mid_path) if is_telangana else (_tn_loc_mgr.get_texture(mid_path) if is_tamil_nadu else (_goa_tex_cache.get(mid_path, null) if is_goa else null))))
		if tex == null:
			tex = load(mid_path) as Texture2D
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
		if is_scenic_v3:
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

func _apply_goa_midground_layout(mid_layer: ParallaxLayer, spr: Sprite2D, tex: Texture2D, _mid_path: String) -> void:
	# Goa-only: crisp 1:1 natural midground aligned to road horizon, no repeated house boxes.
	var w: float = float(tex.get_width())
	var h: float = float(tex.get_height())
	mid_layer.motion_scale = Vector2(0.24, 0)
	mid_layer.motion_mirroring = Vector2(w, 0)
	if is_instance_valid(spr):
		spr.visible = true
		spr.texture = tex
		spr.scale = Vector2.ONE
		spr.flip_h = false
		spr.modulate = Color(1.0, 1.0, 1.0, 0.98)
		spr.position = Vector2(w * 0.5, 610.0 - h * 0.5)
