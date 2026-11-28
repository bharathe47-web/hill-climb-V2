extends Node2D
class_name KanyakumariTerrainGenerator

@export var chunk_width: float = 1000.0
@export var point_step: float = 25.0
@export var view_ahead: float = 3200.0
@export var view_behind: float = 1600.0
@export var base_y: float = 680.0

var chunk_scene: PackedScene = preload("res://scenes/terrain/TerrainChunk.tscn")
var cliff_texture: Texture2D = preload("res://art/terrain/cliff_rock_tile.png")
var road_texture: Texture2D = preload("res://art/terrain/road_asphalt_pattern.png")
var grass_texture: Texture2D = preload("res://art/terrain/grass_tuft.png")

# Props textures
var tea_shop_tex: Texture2D = preload("res://art/props/tea_shop.png")
var bollard_tex: Texture2D = preload("res://art/props/bollard.png")
var lamp_post_tex: Texture2D = preload("res://art/props/lamp_post.png")
var coconut_palm_tex: Texture2D = preload("res://art/props/coconut_palm.png")
var stone_wall_tex: Texture2D = preload("res://art/props/stone_wall.png")
var sign_tex: Texture2D = preload("res://art/props/sign_kanyakumari.png")

# Pickups (loaded dynamically if scenes exist)
var coin_scene: PackedScene = null
var fuel_scene: PackedScene = null

var noise: FastNoiseLite
var active_chunks: Dictionary = {} # chunk_index -> TerrainChunk
var target_node: Node2D = null
var stage_data: Resource = null
var last_coin_x: float = -999.0
var last_fuel_x: float = -999.0

func _ready() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_octaves = 2
	
	if ResourceLoader.exists("res://scenes/pickups/StarCoin.tscn"):
		coin_scene = load("res://scenes/pickups/StarCoin.tscn")
	if ResourceLoader.exists("res://scenes/pickups/FuelCan.tscn"):
		fuel_scene = load("res://scenes/pickups/FuelCan.tscn")
		
	if StageManager and StageManager.current_stage:
		setup_for_stage(StageManager.current_stage)

func setup_for_stage(stage: Resource) -> void:
	stage_data = stage
	var s_seed: int = stage.get("terrain_seed") if stage and "terrain_seed" in stage else 1337
	noise.seed = s_seed
	
	for idx in active_chunks.keys():
		if is_instance_valid(active_chunks[idx]):
			active_chunks[idx].queue_free()
	active_chunks.clear()

func set_target(node: Node2D) -> void:
	target_node = node

func _process(_delta: float) -> void:
	var target_x: float = target_node.global_position.x if target_node else 0.0
	update_chunks(target_x)

func update_chunks(camera_x: float) -> void:
	var min_x := camera_x - view_behind
	var max_x := camera_x + view_ahead
	
	var min_chunk := int(floor(min_x / chunk_width))
	var max_chunk := int(floor(max_x / chunk_width))
	
	# Free out-of-range chunks
	var to_remove := []
	for idx in active_chunks.keys():
		if idx < min_chunk - 1 or idx > max_chunk + 1:
			to_remove.append(idx)
			
	for idx in to_remove:
		if is_instance_valid(active_chunks[idx]):
			active_chunks[idx].queue_free()
		active_chunks.erase(idx)
		
	# Generate required chunks
	for idx in range(min_chunk, max_chunk + 1):
		if not active_chunks.has(idx):
			_spawn_chunk(idx)

func get_elevation_at(x: float) -> float:
	# Flat starter zone so car lands safely
	if x < 350.0:
		return base_y
		
	var amp: float = 140.0
	var freq: float = 0.0016
	var bump_amp: float = 20.0
	
	if stage_data:
		amp = stage_data.get("hill_amplitude") if "hill_amplitude" in stage_data else amp
		freq = stage_data.get("hill_frequency") if "hill_frequency" in stage_data else freq
		bump_amp = stage_data.get("bump_amplitude") if "bump_amplitude" in stage_data else bump_amp
		
	# Smooth blend-in from starter zone
	var blend: float = clampf((x - 350.0) / 300.0, 0.0, 1.0)
	
	# Low-frequency rolling sinusoidal hills & crests
	var roll: float = sin(x * freq) * amp * 0.7 + sin(x * freq * 2.3 + 1.1) * amp * 0.35
	# FastNoise micro bumps
	var bump: float = noise.get_noise_1d(x * 0.6) * bump_amp
	
	var elev := base_y - (roll + bump) * blend
	return elev

func _spawn_chunk(chunk_idx: int) -> void:
	var c_start_x := float(chunk_idx) * chunk_width
	var c_end_x := c_start_x + chunk_width
	
	var pts := PackedVector2Array()
	var current_x := c_start_x
	
	while current_x <= c_end_x + 0.1:
		var y := get_elevation_at(current_x)
		pts.append(Vector2(current_x, y))
		current_x += point_step
		
	var chunk: TerrainChunk = chunk_scene.instantiate()
	add_child(chunk)
	chunk.setup_chunk(chunk_idx, c_start_x, c_end_x, pts, cliff_texture, road_texture)
	
	# Populate grass tufts along the road edge
	_scatter_grass_tufts(chunk, pts)
	
	# Populate roadside props
	_scatter_props(chunk, pts, c_start_x, c_end_x)
	
	# Populate collectibles (coins and fuel)
	_scatter_pickups(chunk, c_start_x, c_end_x)
	
	active_chunks[chunk_idx] = chunk

func _scatter_grass_tufts(chunk: TerrainChunk, pts: PackedVector2Array) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(chunk.chunk_index * 7919)
	
	for i in range(1, pts.size() - 1, 3):
		if rng.randf() < 0.65:
			var pt := pts[i]
			var prev_pt := pts[i - 1]
			var next_pt := pts[i + 1]
			var tangent := (next_pt - prev_pt).normalized()
			var normal := Vector2(-tangent.y, tangent.x)
			
			var sprite := Sprite2D.new()
			sprite.texture = grass_texture
			sprite.position = pt + normal * 4.0
			sprite.rotation = tangent.angle()
			sprite.scale = Vector2.ONE * rng.randf_range(0.65, 0.95)
			sprite.z_index = 2
			chunk.add_prop(sprite)

func _scatter_props(chunk: TerrainChunk, _pts: PackedVector2Array, c_start: float, c_end: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(chunk.chunk_index * 31337)
	
	# Don't place roadside props directly on top of the starter pad
	if c_end < 400.0:
		return
		
	# Check landmark props defined in current stage
	if stage_data and "landmark_props" in stage_data:
		var l_props: Array = stage_data.get("landmark_props")
		for item in l_props:
			var dist: float = item.get("distance", -1.0)
			if dist >= c_start and dist < c_end:
				var p_type: String = item.get("prop_type", "")
				_spawn_named_prop(chunk, dist, p_type)
				
	# Random decorative props along highway with varied spacing
	if rng.randf() < 0.6:
		var sample_x := c_start + rng.randf_range(150.0, 850.0)
		var prop_choices: Array[String] = ["coconut_palm", "lamp_post", "bollard", "stone_wall"]
		var choice: String = prop_choices[rng.randi() % prop_choices.size()]
		_spawn_named_prop(chunk, sample_x, choice)

func _spawn_named_prop(chunk: TerrainChunk, x: float, p_type: String) -> void:
	var y := get_elevation_at(x)
	var sprite := Sprite2D.new()
	
	match p_type:
		"tea_shop":
			sprite.texture = tea_shop_tex
			sprite.offset = Vector2(0, -110)
			sprite.scale = Vector2(0.9, 0.9)
			sprite.z_index = 1
		"bollard":
			sprite.texture = bollard_tex
			sprite.offset = Vector2(0, -60)
			sprite.scale = Vector2(0.8, 0.8)
			sprite.z_index = 2
		"lamp_post":
			sprite.texture = lamp_post_tex
			sprite.offset = Vector2(30, -170)
			sprite.scale = Vector2(0.85, 0.85)
			sprite.z_index = 1
		"coconut_palm":
			sprite.texture = coconut_palm_tex
			sprite.offset = Vector2(50, -190)
			sprite.scale = Vector2(0.95, 0.95)
			sprite.z_index = 1
		"stone_wall":
			sprite.texture = stone_wall_tex
			sprite.offset = Vector2(0, -50)
			sprite.scale = Vector2(0.85, 0.85)
			sprite.z_index = 1
		"sign_kanyakumari":
			sprite.texture = sign_tex
			sprite.offset = Vector2(0, -100)
			sprite.scale = Vector2(0.9, 0.9)
			sprite.z_index = 2
		_:
			return
			
	sprite.position = Vector2(x, y - 10.0)
	chunk.add_prop(sprite)

func _scatter_pickups(chunk: TerrainChunk, c_start: float, c_end: float) -> void:
	if c_start < 400.0:
		return # No pickups on starter flat
		
	# Spawn star coins in smooth arcs of 5 coins along the road contour
	var coin_step: float = 380.0
	var cur_x := c_start + 120.0
	while cur_x < c_end - 150.0:
		if coin_scene and cur_x - last_coin_x >= 280.0:
			last_coin_x = cur_x
			for i in range(5):
				var cx := cur_x + i * 35.0
				var cy := get_elevation_at(cx) - 45.0 - sin(i * PI / 4.0) * 25.0
				var coin: Node2D = coin_scene.instantiate()
				coin.position = Vector2(cx, cy)
				chunk.add_prop(coin)
		cur_x += coin_step
		
	# Spawn fuel cans
	if fuel_scene and c_start > 500.0:
		var fuel_interval: float = 750.0
		if c_start - last_fuel_x >= fuel_interval:
			last_fuel_x = c_start
			var fx := c_start + chunk_width * 0.5
			var fy := get_elevation_at(fx) - 35.0
			var fuel: Node2D = fuel_scene.instantiate()
			fuel.position = Vector2(fx, fy)
			chunk.add_prop(fuel)
