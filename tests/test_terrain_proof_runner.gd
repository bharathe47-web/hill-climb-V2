extends Node2D

var terrain: Node2D
var car: RigidBody2D
var frame_count: int = 0
var road_y: float = 680.0

func _ready() -> void:
	print("--- Running Test: Kanyakumari Terrain & Collision Proof ---")
	
	# Instantiate terrain
	var terrain_scene := load("res://scenes/terrain/KanyakumariTerrain.tscn") as PackedScene
	terrain = terrain_scene.instantiate()
	add_child(terrain)
	
	# Create a debug rolling car (RigidBody2D with CircleShape2D)
	car = RigidBody2D.new()
	car.position = Vector2(100.0, 500.0) # Spawn above road at 680
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 25.0
	col.shape = shape
	car.add_child(col)
	add_child(car)
	terrain.call("set_target", car)
	
	# Trigger terrain generation
	terrain.call("update_chunks", car.global_position.x)
	var active_chunks: Dictionary = terrain.get("active_chunks")
	print("Spawned chunks count: ", active_chunks.size())
	assert(active_chunks.size() >= 3, "Chunks must be active around car")
	
	road_y = float(terrain.call("get_elevation_at", 100.0))
	print("Road elevation at x=100: ", road_y)

func _physics_process(_delta: float) -> void:
	frame_count += 1
	if frame_count == 40:
		print("Car pos at frame 40: ", car.position)
		assert(car.position.y > 600.0, "Car must fall toward road surface!")
		assert(car.position.y <= road_y + 10.0, "Car must NOT clip through road surface!")
		print("--- Kanyakumari Terrain Test PASSED ---")
		get_tree().quit(0)
