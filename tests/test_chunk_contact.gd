extends Node2D

var car: RigidBody2D
var chunk: Node2D
var frames: int = 0

func _ready() -> void:
	# Create chunk
	var chunk_scene := load("res://scenes/terrain/TerrainChunk.tscn") as PackedScene
	chunk = chunk_scene.instantiate()
	add_child(chunk)
	
	var pts := PackedVector2Array([
		Vector2(-500, 680),
		Vector2(0, 680),
		Vector2(500, 680),
		Vector2(1000, 680)
	])
	
	var cliff_tex := load("res://art/terrain/cliff_rock_tile.png") as Texture2D
	var road_tex := load("res://art/terrain/road_asphalt_pattern.png") as Texture2D
	chunk.setup_chunk(0, -500, 1000, pts, cliff_tex, road_tex)
	
	print("Chunk setup done. Col poly pts count: ", chunk.get_node("CollisionPolygon2D").polygon.size())
	print("Chunk col layer: ", chunk.collision_layer, " mask: ", chunk.collision_mask)
	
	# Create car
	car = RigidBody2D.new()
	car.position = Vector2(200, 500)
	var col := CollisionShape2D.new()
	var s := CircleShape2D.new()
	s.radius = 25.0
	col.shape = s
	car.add_child(col)
	car.collision_layer = 1
	car.collision_mask = 1
	add_child(car)
	print("Car created at: ", car.position, " layer: ", car.collision_layer, " mask: ", car.collision_mask)

func _physics_process(_delta: float) -> void:
	frames += 1
	if frames <= 30 or frames % 10 == 0:
		print("Frame ", frames, " Car pos: ", car.position, " vel: ", car.linear_velocity)
	if frames == 50:
		print("Test complete. Final car pos: ", car.position)
		get_tree().quit(0)
