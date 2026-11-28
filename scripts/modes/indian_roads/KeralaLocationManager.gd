class_name KeralaLocationManager
extends RefCounted

## KeralaLocationManager: Reusable configuration + asynchronous lookahead background preloader
## for all 9 Kochi-to-Munnar zones. Eliminates main-thread PNG decode stalls and bounds VRAM cache.

const PARALLAX_DIR := "res://assets/indian_locations/kerala/v3/parallax/"
const PRELOAD_LOOKAHEAD_M := 95.0

const ZONES: Array[Dictionary] = [
	{
		"id": "kochi",
		"min_m": 0.0,
		"max_m": 200.0,
		"sky": PARALLAX_DIR + "sky_kerala_coastal.png",
		"dist": PARALLAX_DIR + "dist_01_kochi.png",
		"mid": PARALLAX_DIR + "mid_01_kochi.png",
		"shoulder": Color(0.84, 0.72, 0.48, 1.0),
		"badge": "1. Kochi • Arabian Sea Coast",
		"title": "WELCOME TO KOCHI",
		"sub": "Arabian Sea Harbour & Chinese Fishing Nets",
	},
	{
		"id": "muvattupuzha",
		"min_m": 200.0,
		"max_m": 400.0,
		"sky": PARALLAX_DIR + "sky_kerala_coastal.png",
		"dist": PARALLAX_DIR + "dist_02_muvattupuzha.png",
		"mid": PARALLAX_DIR + "mid_02_muvattupuzha.png",
		"shoulder": Color(0.54, 0.34, 0.19, 1.0),
		"badge": "2. Muvattupuzha • Midlands",
		"title": "MUVATTUPUZHA",
		"sub": "Rubber Estates, Banana Groves & Paddy Valleys",
	},
	{
		"id": "kothamangalam",
		"min_m": 400.0,
		"max_m": 600.0,
		"sky": PARALLAX_DIR + "sky_kerala_coastal.png",
		"dist": PARALLAX_DIR + "dist_03_kothamangalam.png",
		"mid": PARALLAX_DIR + "mid_03_kothamangalam.png",
		"shoulder": Color(0.45, 0.29, 0.16, 1.0),
		"badge": "3. Kothamangalam • Tropical Forest",
		"title": "KOTHAMANGALAM",
		"sub": "Dense Bamboo Clusters & River Foothills",
	},
	{
		"id": "neriamangalam",
		"min_m": 600.0,
		"max_m": 800.0,
		"sky": PARALLAX_DIR + "sky_kerala_highlands.png",
		"dist": PARALLAX_DIR + "dist_04_neriamangalam.png",
		"mid": PARALLAX_DIR + "mid_04_neriamangalam.png",
		"shoulder": Color(0.41, 0.27, 0.15, 1.0),
		"badge": "4. Neriamangalam • Periyar Arch Bridge",
		"title": "NERIAMANGALAM",
		"sub": "Historic Periyar Arch Bridge & Rainforest Gorge",
	},
	{
		"id": "valara",
		"min_m": 800.0,
		"max_m": 1000.0,
		"sky": PARALLAX_DIR + "sky_kerala_highlands.png",
		"dist": PARALLAX_DIR + "dist_05_valara.png",
		"mid": PARALLAX_DIR + "mid_05_valara.png",
		"shoulder": Color(0.36, 0.25, 0.16, 1.0),
		"badge": "5. Valara Waterfalls • Ghats Gorge",
		"title": "VALARA WATERFALLS",
		"sub": "Cascading Forest Cliffs & Mountain Spray",
	},
	{
		"id": "cheeyappara",
		"min_m": 1000.0,
		"max_m": 1200.0,
		"sky": PARALLAX_DIR + "sky_kerala_highlands.png",
		"dist": PARALLAX_DIR + "dist_06_cheeyappara.png",
		"mid": PARALLAX_DIR + "mid_06_cheeyappara.png",
		"shoulder": Color(0.35, 0.24, 0.16, 1.0),
		"badge": "6. Cheeyappara Waterfalls • 7-Tier Falls",
		"title": "CHEEYAPPARA WATERFALLS",
		"sub": "Multi-Level Stepped Waterfall in Dense Forest",
	},
	{
		"id": "adimali",
		"min_m": 1200.0,
		"max_m": 1400.0,
		"sky": PARALLAX_DIR + "sky_kerala_highlands.png",
		"dist": PARALLAX_DIR + "dist_07_adimali.png",
		"mid": PARALLAX_DIR + "mid_07_adimali.png",
		"shoulder": Color(0.48, 0.30, 0.16, 1.0),
		"badge": "7. Adimali • Spice Gardens",
		"title": "ADIMALI HIGHLANDS",
		"sub": "Cardamom Hills, Pepper Vines & Spice Estates",
	},
	{
		"id": "pallivasal",
		"min_m": 1400.0,
		"max_m": 1600.0,
		"sky": PARALLAX_DIR + "sky_kerala_highlands.png",
		"dist": PARALLAX_DIR + "dist_08_pallivasal.png",
		"mid": PARALLAX_DIR + "mid_08_pallivasal.png",
		"shoulder": Color(0.43, 0.29, 0.17, 1.0),
		"badge": "8. Pallivasal • Rolling Tea Slopes",
		"title": "PALLIVASAL TEA HILLS",
		"sub": "Curved Tea Plantation Rows & Misty Slopes",
	},
	{
		"id": "munnar",
		"min_m": 1600.0,
		"max_m": 2000.0,
		"sky": PARALLAX_DIR + "sky_kerala_highlands.png",
		"dist": PARALLAX_DIR + "dist_09_munnar.png",
		"mid": PARALLAX_DIR + "mid_09_munnar.png",
		"shoulder": Color(0.38, 0.27, 0.17, 1.0),
		"badge": "9. Munnar • Western Ghats Peaks",
		"title": "WELCOME TO MUNNAR!",
		"sub": "Endless Green Tea Gardens & Misty Peaks",
	},
]

var _tex_cache: Dictionary = {}
var _pending_paths: Dictionary = {}
var _active_index: int = 0

func reset(start_m: float = 0.0) -> void:
	_tex_cache.clear()
	_pending_paths.clear()
	_active_index = get_zone_index(start_m)
	# Immediately warm starting zone + kick async load for zone 1
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
			# Fall through to direct load if needed

	if ResourceLoader.exists(path):
		var tex := ResourceLoader.load(path) as Texture2D
		_pending_paths.erase(path)
		if tex:
			_tex_cache[path] = tex
		return tex
	return null

func update_streaming(distance_m: float) -> void:
	# Poll completed async loads without blocking main thread
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
	# Preload upcoming zone when within lookahead distance
	if idx + 1 < ZONES.size() and distance_m >= float(cur["max_m"]) - PRELOAD_LOOKAHEAD_M:
		_request_zone_async(idx + 1)
	# Also ensure previous zone stays ready if player reverses near a border
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
