extends Node2D

var jeep: RigidBody2D
var terrain: Node2D
var frame_count: int = 0
var initial_spring_dist: float = 0.0

func _ready() -> void:
	print("--- Running Test: Red Jeep Physics & Suspension ---")
	
	# Instantiate terrain
	var terrain_scene := load("res://scenes/terrain/KanyakumariTerrain.tscn") as PackedScene
	terrain = terrain_scene.instantiate()
	add_child(terrain)
	
	# Instantiate Red Jeep
	var jeep_scene := load("res://scenes/vehicles/RedJeep.tscn") as PackedScene
	jeep = jeep_scene.instantiate()
	jeep.position = Vector2(100.0, 520.0) # Spawn above road at 680
	add_child(jeep)
	terrain.call("set_target", jeep)
	terrain.call("update_chunks", jeep.global_position.x)
	
	var rear_wheel := jeep.get_node("RearWheel") as RigidBody2D
	initial_spring_dist = abs(jeep.position.y - rear_wheel.global_position.y)
	print("Jeep spawned. Initial vertical offset to wheel: ", initial_spring_dist)

func _physics_process(_delta: float) -> void:
	frame_count += 1
	
	# Apply gas
	if frame_count > 30:
		Input.action_press("gas")
		
	if frame_count == 40:
		var rear_wheel := jeep.get_node("RearWheel") as RigidBody2D
		var current_dist: float = abs(jeep.global_position.y - rear_wheel.global_position.y)
		print("Frame 40: Jeep pos: ", jeep.global_position, " Rear wheel pos: ", rear_wheel.global_position)
		print("Vertical offset under load: ", current_dist)
		# Suspension must visibly support the car
		assert(jeep.global_position.y < 680.0, "Jeep must rest on top of terrain!")
		
	if frame_count == 90:
		Input.action_release("gas")
		var rear_wheel := jeep.get_node("RearWheel") as RigidBody2D
		print("Frame 90: Jeep X: ", jeep.global_position.x, " Wheel angular velocity: ", rear_wheel.angular_velocity)
		assert(jeep.global_position.x > 120.0, "Jeep must drive forward under gas torque!")
		assert(rear_wheel.angular_velocity > 1.0, "Wheel must rotate forward under gas torque!")
		print("--- Red Jeep Physics & Suspension Test PASSED ---")
		get_tree().quit(0)
