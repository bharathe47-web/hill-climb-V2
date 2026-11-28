class_name RajasthanLocationManager
extends RefCounted

## RajasthanLocationManager: Reusable 5-zone configuration and asynchronous lookahead preloader
## for the 1,200m Jaipur-to-Jaisalmer highway. Eliminates synchronous decode stutters and bounds VRAM.

const PARALLAX_DIR := "res://assets/indian_locations/rajasthan/v3/parallax/"
const PRELOAD_LOOKAHEAD_M := 80.0

const ZONES: Array[Dictionary] = [
	{
		"id": "jaipur",
		"min_m": 0.0,
		"max_m": 240.0,
		"sky": PARALLAX_DIR + "sky_rj_01_sunrise.png",
		"dist": PARALLAX_DIR + "dist_01_jaipur.png",
		"mid": PARALLAX_DIR + "mid_01_jaipur.png",
		"badge": "1. Jaipur • Pink City Heritage",
		"title": "JAIPUR HERITAGE",
		"sub": "Pink City Sandstone, Hawa Mahal & Amber Valley",
	},
	{
		"id": "aravalli",
		"min_m": 240.0,
		"max_m": 480.0,
		"sky": PARALLAX_DIR + "sky_rj_02_daylight.png",
		"dist": PARALLAX_DIR + "dist_02_aravalli.png",
		"mid": PARALLAX_DIR + "mid_02_aravalli.png",
		"badge": "2. Aravalli • Rocky Foothills",
		"title": "ARAVALLI OUTSKIRTS",
		"sub": "Rugged Desert Hills, Sacred Lakes & Thorn Scrub",
	},
	{
		"id": "desert",
		"min_m": 480.0,
		"max_m": 720.0,
		"sky": PARALLAX_DIR + "sky_rj_02_daylight.png",
		"dist": PARALLAX_DIR + "dist_03_desert.png",
		"mid": PARALLAX_DIR + "mid_03_desert.png",
		"badge": "3. Thar Desert • Heritage Plains",
		"title": "DESERT HERITAGE",
		"sub": "Golden Sand Dunes, Bhunga Villages & Camels",
	},
	{
		"id": "jodhpur",
		"min_m": 720.0,
		"max_m": 960.0,
		"sky": PARALLAX_DIR + "sky_rj_03_afternoon.png",
		"dist": PARALLAX_DIR + "dist_04_jodhpur.png",
		"mid": PARALLAX_DIR + "mid_04_jodhpur.png",
		"badge": "4. Jodhpur • Sun & Blue City",
		"title": "JODHPUR BLUE CITY",
		"sub": "Mehrangarh Citadel Skyline & Blue Houses",
	},
	{
		"id": "jaisalmer",
		"min_m": 960.0,
		"max_m": 1400.0,
		"sky": PARALLAX_DIR + "sky_rj_04_sunset.png",
		"dist": PARALLAX_DIR + "dist_05_jaisalmer.png",
		"mid": PARALLAX_DIR + "mid_05_jaisalmer.png",
		"badge": "5. Jaisalmer • Golden City Sunset",
		"title": "JAISALMER GOLDEN CITY",
		"sub": "Golden Forts, Havelis & Sam Sunset Dunes",
	},
]

var _tex_cache: Dictionary = {}
var _pending_paths: Dictionary = {}
var _active_index: int = 0

func reset(start_m: float = 0.0) -> void:
	_tex_cache.clear()
	_pending_paths.clear()
	_active_index = get_zone_index(start_m)
	var cur := ZONES[_active_index]
	get_texture(cur["sky"])
	get_texture(cur["dist"])
	get_texture(cur["mid"])
	if _active_index + 1 < ZONES.size():
		_request_zone_async(_active_index + 1)

func get_zone_index(distance_m: float) -> int:
	for i in range(ZONES.size()):
		if distance_m < float(ZONES[i]["max_m"]):
			return i
	return ZONES.size() - 1

func get_zone_config(index: int) -> Dictionary:
	return ZONES[clampi(index, 0, ZONES.size() - 1)]

func get_texture(path: String) -> Texture2D:
	if path == "":
		return null
	if _tex_cache.has(path):
		return _tex_cache[path] as Texture2D

	if _pending_paths.has(path):
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var loaded := ResourceLoader.load_threaded_get(path) as Texture2D
			_pending_paths.erase(path)
			if loaded:
				_tex_cache[path] = loaded
				return loaded

	if ResourceLoader.exists(path):
		var tex := ResourceLoader.load(path) as Texture2D
		_pending_paths.erase(path)
		if tex:
			_tex_cache[path] = tex
		return tex
	return null

func update_streaming(distance_m: float) -> void:
	if not _pending_paths.is_empty():
		var finished: Array[String] = []
		for path in _pending_paths.keys():
			var st := ResourceLoader.load_threaded_get_status(path)
			if st == ResourceLoader.THREAD_LOAD_LOADED:
				var tex := ResourceLoader.load_threaded_get(path) as Texture2D
				if tex:
					_tex_cache[path] = tex
				finished.append(path)
			elif st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				finished.append(path)
		for f_path in finished:
			_pending_paths.erase(f_path)

	var idx := get_zone_index(distance_m)
	var cur := ZONES[idx]
	if idx + 1 < ZONES.size() and distance_m >= float(cur["max_m"]) - PRELOAD_LOOKAHEAD_M:
		_request_zone_async(idx + 1)
	if idx - 1 >= 0 and distance_m <= float(cur["min_m"]) + 45.0:
		_request_zone_async(idx - 1)

	if idx != _active_index:
		_active_index = idx
		_evict_distant_zones(idx)

func _request_zone_async(zone_idx: int) -> void:
	if zone_idx < 0 or zone_idx >= ZONES.size():
		return
	var z := ZONES[zone_idx]
	for key in ["sky", "dist", "mid"]:
		var p: String = z[key]
		if p != "" and not _tex_cache.has(p) and not _pending_paths.has(p) and ResourceLoader.exists(p):
			var err := ResourceLoader.load_threaded_request(p, "Texture2D")
			if err == OK:
				_pending_paths[p] = true

func _evict_distant_zones(center_idx: int) -> void:
	var keep_paths: Dictionary = {}
	for offset: int in [-1, 0, 1]:
		var zi: int = center_idx + offset
		if zi >= 0 and zi < ZONES.size():
			keep_paths[ZONES[zi]["sky"]] = true
			keep_paths[ZONES[zi]["dist"]] = true
			keep_paths[ZONES[zi]["mid"]] = true
	var to_erase: Array[String] = []
	for cached_path in _tex_cache.keys():
		if not keep_paths.has(cached_path):
			to_erase.append(cached_path)
	for ep in to_erase:
		_tex_cache.erase(ep)
