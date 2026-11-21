extends SceneTree

func _init() -> void:
	print("--- Running Test: Kanyakumari Terrain & Collision Proof ---")
	var root := Node2D.new()
	get_root().add_child(root)
	
	# Instantiate terrain
	var terrain_scene := load("res://scenes/terrain/KanyakumariTerrain.tscn") as PackedScene
	var terrain: KanyakumariTerrainGenerator = terrain_scene.instantiate()
	root.add_child(terrain)
	
	# Create a debug rolling car (RigidBody2D with CircleShape2D)
	var car := RigidBody2D.new()
	car.position = Vector2(100.0, 500.0) # Spawn above road at 680
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 24.0
	col.shape = shape
	car.add_child(col)
	root.add_child(car)
	terrain.set_target(car)
	
	# Trigger terrain generation
	terrain.update_chunks(car.global_position.x)
	print("Spawned chunks count: ", terrain.active_chunks.size())
	assert(terrain.active_chunks.size() >= 3, "Chunks must be active around car")
	
	# Check starting elevation at x=100
	var road_y := terrain.get_elevation_at(100.0)
	print("Road elevation at x=100: ", road_y)
	
	# Step physics for 60 frames (1 second)
	var landed := false
	for frame in range(90):
		# Manual step physics simulation
		PhysicsServer2D.set_active(true)
		root.get_tree().root.propagate_notification(Node.NOTIFICATION_PHYSICS_PROCESS)
		# Give a slight forward push to prove rolling
		if frame > 25:
			car.apply_central_force(Vector2(250.0, 0))
		
		# Check car position
		if abs(car.position.y - (road_y - shape.radius)) < 15.0:
			landed = true
			
	print("Final car position after physics steps: ", car.position)
	print("Landed on road surface without clipping: ", landed)
	assert(car.position.y < road_y + 10.0, "Car must NOT clip through collision surface!")
	assert(car.position.x > 100.0, "Car must be rolling forward!")
	
	print("--- Kanyakumari Terrain Test PASSED ---")
	quit(0)
