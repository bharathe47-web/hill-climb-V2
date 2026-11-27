class_name HomeCloudSystem
extends Node2D

## HomeCloudSystem: Lightweight cartoon cloud & atmospheric sky animation for the Home Menu only.
## Manages distant, middle (large), and foreground (midground) cloud layers with smooth
## frame-independent horizontal movement, seamless off-screen wrapping, gentle sinusoidal
## vertical floating, and subtle atmospheric glow/haze/sun rays.

const DESIGN_WIDTH := 1920.0
const WRAP_MARGIN := 120.0
const FADE_EDGE_WIDTH := 80.0
const MAX_DELTA_STEP := 0.1

enum CloudLayer {
	DISTANT = 0,
	MIDDLE = 1,
	FOREGROUND = 2,
}

# Cloud sprite textures (preloaded once; zero runtime load calls)
const TEX_CLOUD_DISTANT_01: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/clouds/home_cloud_distant_01.png")
const TEX_CLOUD_SMALL_01: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/clouds/home_cloud_small_01.png")
const TEX_CLOUD_MEDIUM_01: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/clouds/home_cloud_medium_01.png")
const TEX_CLOUD_MEDIUM_02: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/clouds/home_cloud_medium_02.png")
const TEX_CLOUD_LARGE_01: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/clouds/home_cloud_large_01.png")
const TEX_CLOUD_LARGE_02: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/clouds/home_cloud_large_02.png")
const TEX_CLOUD_CLUSTER_01: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/clouds/home_cloud_cluster_01.png")

# Atmospheric effects
const TEX_CLOUD_GLOW: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/effects/home_cloud_glow.png")
const TEX_CLOUD_HIGHLIGHT: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/effects/cloud_highlight.png")
const TEX_SKY_HAZE: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/effects/home_sky_haze.png")
const TEX_SUN_RAYS: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/effects/home_sun_rays.png")
const TEX_HORIZON_GLOW: Texture2D = preload("res://assets/ui/home_screen/cloud_animations/effects/home_horizon_glow.png")

## Optional Node2D placed between DistantMountains and MidgroundHillsForest for depth-layered medium clouds.
@export var midground_layer_path: NodePath

@export_group("Cloud Speeds (Design Space px/s)")
## Distant clouds behind mountains (~6 screen px/s at 1280px viewport width).
@export var distant_cloud_speed: float = 9.0
## Middle large clouds behind mountain peaks (~10 screen px/s at 1280px viewport width).
@export var middle_cloud_speed: float = 15.0
## Foreground midground clouds in front of distant mountains (~14 screen px/s at 1280px viewport width).
@export var foreground_cloud_speed: float = 21.0

@export_group("Vertical Float")
@export var enable_vertical_bob: bool = true
@export_range(0.0, 2.0, 0.05) var bob_amplitude_scale: float = 1.0

var _midground_layer: Node2D = null
var _sun_rays_sprite: Sprite2D = null
var _sky_haze_sprite: Sprite2D = null

var _clouds: Array[Dictionary] = []
var _layer_bounds: Dictionary = {}
var _time: float = 0.0
var _intro_alpha: float = 0.0

func _ready() -> void:
	_midground_layer = get_node_or_null(midground_layer_path) as Node2D
	_build_atmospheric_backdrop()
	_build_distant_clouds()
	_build_large_clouds()
	_build_midground_clouds()
	_compute_all_layer_bounds()
	_animate_intro_fade()

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	var dt := minf(delta, MAX_DELTA_STEP)
	_time += dt

	# Subtle breathing on sun rays & horizon haze so the sky feels alive without distracting.
	if is_instance_valid(_sun_rays_sprite):
		_sun_rays_sprite.modulate.a = (0.09 + 0.03 * sin(_time * 0.45)) * _intro_alpha
	if is_instance_valid(_sky_haze_sprite):
		_sky_haze_sprite.modulate.a = (0.20 + 0.03 * sin(_time * 0.32 + 1.2)) * _intro_alpha

	for entry in _clouds:
		var node: Node2D = entry["node"]
		if not is_instance_valid(node):
			continue

		var layer: int = entry["layer"]
		var bounds: Dictionary = _layer_bounds[layer]
		var min_x: float = bounds["min_x"]
		var max_x: float = bounds["max_x"]
		var span: float = bounds["span"]

		var speed := _get_layer_speed(layer)
		var x: float = entry["x"] + speed * dt
		if x > max_x:
			x -= span
		elif x < min_x:
			x += span
		entry["x"] = x

		var y: float = entry["base_y"]
		if enable_vertical_bob and bob_amplitude_scale > 0.0:
			y += sin(_time * entry["bob_speed"] + entry["phase"]) * entry["bob_amp"] * bob_amplitude_scale
		node.position = Vector2(x, y)

		var edge_fade := _compute_edge_fade(x, min_x, max_x)
		var base_color: Color = entry["tint"]
		node.modulate = Color(base_color.r, base_color.g, base_color.b, entry["alpha"] * edge_fade * _intro_alpha)

func _get_layer_speed(layer: int) -> float:
	match layer:
		CloudLayer.DISTANT:
			return distant_cloud_speed
		CloudLayer.MIDDLE:
			return middle_cloud_speed
		CloudLayer.FOREGROUND:
			return foreground_cloud_speed
	return distant_cloud_speed

func _animate_intro_fade() -> void:
	_intro_alpha = 0.0
	var tw := create_tween()
	tw.tween_property(self, "_intro_alpha", 1.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _compute_edge_fade(x: float, min_x: float, max_x: float) -> float:
	var left_in := clampf((x - min_x) / FADE_EDGE_WIDTH, 0.0, 1.0)
	var right_out := clampf((max_x - x) / FADE_EDGE_WIDTH, 0.0, 1.0)
	return smoothstep(0.0, 1.0, minf(left_in, right_out))

func _compute_all_layer_bounds() -> void:
	var max_left := {
		CloudLayer.DISTANT: 0.0,
		CloudLayer.MIDDLE: 0.0,
		CloudLayer.FOREGROUND: 0.0,
	}
	var max_right := {
		CloudLayer.DISTANT: 0.0,
		CloudLayer.MIDDLE: 0.0,
		CloudLayer.FOREGROUND: 0.0,
	}
	for entry in _clouds:
		var layer: int = entry["layer"]
		max_left[layer] = maxf(max_left[layer], entry["left_extent"])
		max_right[layer] = maxf(max_right[layer], entry["right_extent"])

	for layer in [CloudLayer.DISTANT, CloudLayer.MIDDLE, CloudLayer.FOREGROUND]:
		# Guarantee every cloud in the layer is completely outside [0, DESIGN_WIDTH] before wrapping,
		# while keeping a uniform span per layer so cloud spacing never drifts or creates gaps.
		var min_x: float = -max_right[layer] - WRAP_MARGIN
		var max_x: float = DESIGN_WIDTH + max_left[layer] + WRAP_MARGIN
		_layer_bounds[layer] = {
			"min_x": min_x,
			"max_x": max_x,
			"span": max_x - min_x,
		}

func _build_atmospheric_backdrop() -> void:
	# Soft warm horizon glow sitting subtly behind mountains.
	var horizon := Sprite2D.new()
	horizon.name = "HorizonGlow"
	horizon.texture = TEX_HORIZON_GLOW
	horizon.centered = false
	horizon.scale = Vector2(1.5, 1.5)
	horizon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	horizon.modulate = Color(1.0, 0.96, 0.88, 0.14)
	add_child(horizon)

	# Gentle crepuscular sun rays radiating from high off-screen (kept above 4:3 top edge too).
	_sun_rays_sprite = Sprite2D.new()
	_sun_rays_sprite.name = "SunRays"
	_sun_rays_sprite.texture = TEX_SUN_RAYS
	_sun_rays_sprite.centered = false
	_sun_rays_sprite.position = Vector2(-40.0, -430.0)
	_sun_rays_sprite.scale = Vector2(1.6, 2.2)
	_sun_rays_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sun_rays_sprite.modulate = Color(1.0, 0.96, 0.84, 0.09)
	add_child(_sun_rays_sprite)

func _build_distant_clouds() -> void:
	var container := Node2D.new()
	container.name = "DistantClouds"
	add_child(container)

	var distant_tint := Color(0.88, 0.93, 0.94, 1.0)
	var specs := [
		{"name": "DistantGroupA", "layer": CloudLayer.DISTANT, "tex": TEX_CLOUD_DISTANT_01, "x": 210.0, "y": 248.0, "scale": 0.78, "alpha": 0.34, "bob_amp": 2.0, "bob_speed": 0.34, "phase": 0.3, "flip_h": false},
		{"name": "DistantAnimSmallA", "layer": CloudLayer.DISTANT, "tex": TEX_CLOUD_SMALL_01, "x": 790.0, "y": 268.0, "scale": 0.56, "alpha": 0.44, "bob_amp": 2.2, "bob_speed": 0.40, "phase": 1.8, "flip_h": false},
		{"name": "DistantGroupB", "layer": CloudLayer.DISTANT, "tex": TEX_CLOUD_DISTANT_01, "x": 1370.0, "y": 252.0, "scale": 0.74, "alpha": 0.32, "bob_amp": 1.8, "bob_speed": 0.31, "phase": 3.1, "flip_h": true},
		{"name": "DistantSmallB", "layer": CloudLayer.DISTANT, "tex": TEX_CLOUD_SMALL_01, "x": 1950.0, "y": 202.0, "scale": 0.52, "alpha": 0.46, "bob_amp": 2.4, "bob_speed": 0.42, "phase": 4.6, "flip_h": false},
		# High-altitude distant accents visible on taller 4:3/16:10 viewports (spaced evenly by half-span).
		{"name": "DistantHighA", "layer": CloudLayer.DISTANT, "tex": TEX_CLOUD_SMALL_01, "x": 420.0, "y": -110.0, "scale": 0.58, "alpha": 0.38, "bob_amp": 2.0, "bob_speed": 0.37, "phase": 2.4, "flip_h": true},
		{"name": "DistantHighB", "layer": CloudLayer.DISTANT, "tex": TEX_CLOUD_MEDIUM_02, "x": 1650.0, "y": -130.0, "scale": 0.55, "alpha": 0.36, "bob_amp": 2.2, "bob_speed": 0.35, "phase": 0.9, "flip_h": false},
	]
	for spec in specs:
		spec["tint"] = distant_tint
		_spawn_cloud(container, spec)

func _build_large_clouds() -> void:
	var container := Node2D.new()
	container.name = "LargeClouds"
	add_child(container)

	var warm_ivory := Color(0.97, 0.96, 0.91, 1.0)
	var specs := [
		{"name": "LargeCloudA", "layer": CloudLayer.MIDDLE, "tex": TEX_CLOUD_LARGE_01, "x": 360.0, "y": 138.0, "scale": 0.72, "alpha": 0.88, "bob_amp": 3.5, "bob_speed": 0.44, "phase": 0.0, "glow": true, "highlight": true},
		{"name": "CloudClusterGroup", "layer": CloudLayer.MIDDLE, "tex": TEX_CLOUD_CLUSTER_01, "cluster_accent": true, "x": 1280.0, "y": 124.0, "scale": 0.68, "alpha": 0.86, "bob_amp": 3.2, "bob_speed": 0.39, "phase": 2.1, "glow": true, "highlight": true},
		{"name": "LargeCloudB", "layer": CloudLayer.MIDDLE, "tex": TEX_CLOUD_LARGE_02, "x": 2120.0, "y": 146.0, "scale": 0.72, "alpha": 0.86, "bob_amp": 3.8, "bob_speed": 0.47, "phase": 4.0, "glow": true, "highlight": true},
	]
	for spec in specs:
		spec["tint"] = warm_ivory
		_spawn_cloud(container, spec)

func _build_midground_clouds() -> void:
	var target: Node2D = _midground_layer if is_instance_valid(_midground_layer) else self

	# Atmospheric depth haze band softly separating distant mountains and midground forest.
	_sky_haze_sprite = Sprite2D.new()
	_sky_haze_sprite.name = "AtmosphericSkyHaze"
	_sky_haze_sprite.texture = TEX_SKY_HAZE
	_sky_haze_sprite.centered = false
	_sky_haze_sprite.position = Vector2(0.0, 265.0)
	_sky_haze_sprite.scale = Vector2(1.5, 0.85)
	_sky_haze_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_sky_haze_sprite.modulate = Color(0.92, 0.97, 0.97, 0.22)
	target.add_child(_sky_haze_sprite)

	var container := Node2D.new()
	container.name = "MediumClouds"
	target.add_child(container)

	# Kept in Y=318..356 so snow-capped mountain peaks (Y=219..275) and forest/signboards remain clear.
	var mid_tint := Color(0.96, 0.97, 0.95, 1.0)
	var specs := [
		{"name": "MediumCloudA", "layer": CloudLayer.FOREGROUND, "tex": TEX_CLOUD_MEDIUM_01, "x": 190.0, "y": 328.0, "scale": 0.58, "alpha": 0.72, "bob_amp": 2.8, "bob_speed": 0.48, "phase": 0.8, "glow": true},
		{"name": "MediumDriftAnim", "layer": CloudLayer.FOREGROUND, "tex": TEX_CLOUD_MEDIUM_02, "x": 815.0, "y": 346.0, "scale": 0.54, "alpha": 0.70, "bob_amp": 2.6, "bob_speed": 0.45, "phase": 2.7, "flip_h": true},
		{"name": "MediumFloatAnim", "layer": CloudLayer.FOREGROUND, "tex": TEX_CLOUD_MEDIUM_01, "x": 1440.0, "y": 320.0, "scale": 0.55, "alpha": 0.74, "bob_amp": 2.4, "bob_speed": 0.42, "phase": 4.2, "glow": true, "flip_h": true},
		{"name": "MediumCloudB", "layer": CloudLayer.FOREGROUND, "tex": TEX_CLOUD_MEDIUM_02, "x": 2065.0, "y": 342.0, "scale": 0.56, "alpha": 0.68, "bob_amp": 3.0, "bob_speed": 0.50, "phase": 5.3},
	]
	for spec in specs:
		spec["tint"] = mid_tint
		_spawn_cloud(container, spec)

func _spawn_cloud(parent: Node2D, spec: Dictionary) -> void:
	var root_node := Node2D.new()
	root_node.name = spec["name"]
	root_node.position = Vector2(spec["x"], spec["y"])
	var sc: float = spec.get("scale", 1.0)
	root_node.scale = Vector2(sc, sc)
	parent.add_child(root_node)

	var tex: Texture2D = spec["tex"]
	var half_w := float(tex.get_width()) * 0.5
	var left_local := half_w
	var right_local := half_w

	if spec.get("glow", false):
		var glow := Sprite2D.new()
		glow.name = "Glow"
		glow.texture = TEX_CLOUD_GLOW
		glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		glow.scale = Vector2(1.45, 0.82)
		glow.modulate = Color(1.0, 0.98, 0.92, 0.22)
		root_node.add_child(glow)
		var glow_half := float(TEX_CLOUD_GLOW.get_width()) * 0.5 * glow.scale.x
		left_local = maxf(left_local, glow_half)
		right_local = maxf(right_local, glow_half)

	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = tex
	sprite.flip_h = spec.get("flip_h", false)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	root_node.add_child(sprite)

	if spec.get("cluster_accent", false):
		var companion := Sprite2D.new()
		companion.name = "CompanionCloud"
		companion.texture = TEX_CLOUD_SMALL_01
		companion.position = Vector2(395.0, 68.0)
		companion.scale = Vector2(0.58, 0.58)
		companion.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		companion.modulate = Color(1.0, 1.0, 1.0, 0.85)
		root_node.add_child(companion)
		var comp_right := companion.position.x + float(TEX_CLOUD_SMALL_01.get_width()) * 0.5 * companion.scale.x
		right_local = maxf(right_local, comp_right)

	if spec.get("highlight", false):
		var rim := Sprite2D.new()
		rim.name = "TopHighlight"
		rim.texture = TEX_CLOUD_HIGHLIGHT
		rim.position = Vector2(-12.0, -58.0)
		rim.scale = Vector2(1.15, 0.72)
		rim.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		rim.modulate = Color(1.0, 1.0, 0.97, 0.26)
		root_node.add_child(rim)

	_clouds.append({
		"node": root_node,
		"layer": spec["layer"],
		"x": spec["x"],
		"base_y": spec["y"],
		"left_extent": left_local * sc,
		"right_extent": right_local * sc,
		"bob_amp": spec.get("bob_amp", 3.0),
		"bob_speed": spec.get("bob_speed", 0.45),
		"phase": spec.get("phase", 0.0),
		"alpha": spec.get("alpha", 0.85),
		"tint": spec.get("tint", Color.WHITE),
	})
