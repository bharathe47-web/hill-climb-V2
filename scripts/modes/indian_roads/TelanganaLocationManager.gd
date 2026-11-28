class_name TelanganaLocationManager
extends RefCounted

## TelanganaLocationManager: 5-zone configuration and asynchronous lookahead preloader
## for the 1,000m Hyderabad City Explorer route (State: Telangana).

const PARALLAX_DIR := "res://assets/indian_locations/telangana/v3/parallax/"
const PRELOAD_LOOKAHEAD_M := 80.0

const ZONES: Array[Dictionary] = [
	{
		"id": "old_hyderabad",
		"min_m": 0.0,
		"max_m": 225.0,
		"sky": PARALLAX_DIR + "sky_hyd_01_morning.png",
		"dist": PARALLAX_DIR + "dist_01_old_hyderabad.png",
		"mid": PARALLAX_DIR + "mid_01_old_hyderabad.png",
		"badge": "OLD HYDERABAD",
		"title": "OLD HYDERABAD",
		"sub": "Charminar, Mecca Masjid, Laad Bazaar & Chowmahalla",
	},
	{
		"id": "city_heritage",
		"min_m": 225.0,
		"max_m": 430.0,
		"sky": PARALLAX_DIR + "sky_hyd_01_morning.png",
		"dist": PARALLAX_DIR + "dist_02_city_heritage.png",
		"mid": PARALLAX_DIR + "mid_02_city_heritage.png",
		"badge": "CITY HERITAGE",
		"title": "CITY HERITAGE",
		"sub": "Salar Jung Museum, State Museum & Osmania Campus",
	},
	{
		"id": "hussain_sagar",
		"min_m": 430.0,
		"max_m": 685.0,
		"sky": PARALLAX_DIR + "sky_hyd_02_lake_afternoon.png",
		"dist": PARALLAX_DIR + "dist_03_hussain_sagar.png",
		"mid": PARALLAX_DIR + "mid_03_hussain_sagar.png",
		"badge": "HUSSAIN SAGAR",
		"title": "HUSSAIN SAGAR",
		"sub": "Buddha Statue, Necklace Road & Birla Mandir",
	},
	{
		"id": "golconda_heritage",
		"min_m": 685.0,
		"max_m": 900.0,
		"sky": PARALLAX_DIR + "sky_hyd_03_golconda_sunset.png",
		"dist": PARALLAX_DIR + "dist_04_golconda.png",
		"mid": PARALLAX_DIR + "mid_04_golconda.png",
		"badge": "GOLCONDA",
		"title": "GOLCONDA HERITAGE",
		"sub": "Qutb Shahi Tombs, Taramati Baradari & Falaknuma",
	},
	{
		"id": "golconda_destination",
		"min_m": 900.0,
		"max_m": 1200.0,
		"sky": PARALLAX_DIR + "sky_hyd_03_golconda_sunset.png",
		"dist": PARALLAX_DIR + "dist_05_golconda_dest.png",
		"mid": PARALLAX_DIR + "mid_05_golconda_dest.png",
		"badge": "GOLCONDA",
		"title": "HYDERABAD DESTINATION",
		"sub": "Approaching Golconda Fort Citadel",
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
