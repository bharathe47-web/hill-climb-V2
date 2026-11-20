class_name SurvivalCollectibleSpawner
extends Node

## SurvivalCollectibleSpawner: Distance-based coin / fuel-can spawning for Survival Mode.
## Spawns just beyond the right edge of the view as the vehicle advances, lays coins
## along the terrain surface, avoids falling obstacles / warnings / potholes, caps
## active pickups, and frees pickups left behind. Driven by SurvivalController._process
## (only while PLAYING), so it never runs while paused or after game over.

signal coins_changed(total: int)
signal fuel_collected(amount: float)

const COIN_SCENE: PackedScene = preload("res://scenes/modes/survival/collectibles/survival_coin.tscn")
const FUEL_SCENE: PackedScene = preload("res://scenes/modes/survival/collectibles/survival_fuel_can.tscn")

@export_group("Coins")
## Distance gap between coin groups (px). Coins are the frequent collectible.
@export var coin_group_gap_min: float = 500.0
@export var coin_group_gap_max: float = 1000.0
@export var coins_per_group_min: int = 3
@export var coins_per_group_max: int = 5
## Horizontal spacing between coins in a group (px) - keeps coins from crowding.
@export var coin_spacing: float = 85.0
## Height above the terrain surface (px). Reachable by the chassis.
@export var coin_surface_clearance: float = 46.0
@export var coin_value: int = 1
@export var max_active_coins: int = 24

@export_group("Fuel")
## Distance gap between fuel cans (px). Rare, valuable.
@export var fuel_gap_min: float = 4200.0
@export var fuel_gap_max: float = 6200.0
## Fuel can restores this many fuel units (never above the tank maximum).
@export var fuel_amount: float = 35.0
@export var fuel_surface_clearance: float = 54.0
@export var max_active_fuel: int = 2
## When fuel is below this fraction, the next can comes sooner.
@export_range(0.0, 1.0) var low_fuel_fraction: float = 0.3
@export var low_fuel_gap: float = 1500.0

@export_group("Placement")
## Spawn this far ahead of the vehicle (px) - just beyond the visible area.
@export var spawn_ahead_distance: float = 1000.0
## Free pickups this far behind the vehicle (px).
@export var despawn_behind_distance: float = 900.0
## Do not place pickups this close (x) to a falling obstacle / warning / pothole.
@export var obstacle_clearance_x: float = 170.0
@export var fuel_coin_separation: float = 260.0

var coins_collected: int = 0

var vehicle: Node = null
var terrain: Node = null
var obstacle_container: Node = null
var avoid_nodes_parent: Node = null   # parent that holds warnings / shadows / potholes
var container: Node2D = null

var _next_coin_x: float = 0.0
var _next_fuel_x: float = 0.0
var _last_coin_end_x: float = -INF
var _active: Array[SurvivalCollectible] = []

func setup(p_vehicle: Node, p_terrain: Node, p_obstacles: Node, p_world: Node, p_container: Node2D) -> void:
	vehicle = p_vehicle
	terrain = p_terrain
	obstacle_container = p_obstacles
	avoid_nodes_parent = p_world
	container = p_container

## Clears all pickups and restarts the spawn schedule from the vehicle's current x.
func reset() -> void:
	clear_all()
	coins_collected = 0
	coins_changed.emit(0)
	var start_x: float = (vehicle as Node2D).global_position.x if is_instance_valid(vehicle) else 0.0
	_next_coin_x = start_x + 700.0
	_next_fuel_x = start_x + 2400.0
	_last_coin_end_x = -INF

func clear_all() -> void:
	for p in _active:
		if is_instance_valid(p):
			p.queue_free()
	_active.clear()

func tick(_delta: float) -> void:
	if not is_instance_valid(vehicle) or not is_instance_valid(container):
		return
	var vx: float = (vehicle as Node2D).global_position.x
	var horizon: float = vx + spawn_ahead_distance
	_cleanup(vx)
	var guard := 0
	while _next_coin_x <= horizon and guard < 3:
		guard += 1
		_spawn_coin_group(_next_coin_x)
		_next_coin_x += randf_range(coin_group_gap_min, coin_group_gap_max)
	if _next_fuel_x <= horizon:
		if _count_kind(SurvivalCollectible.Kind.FUEL) < max_active_fuel:
			_spawn_fuel(_next_fuel_x)
		_next_fuel_x += _fuel_gap(vehicle)

func _fuel_gap(veh: Node) -> float:
	var gap := randf_range(fuel_gap_min, fuel_gap_max)
	if "current_fuel" in veh and "max_fuel" in veh and float(veh.max_fuel) > 0.0:
		if float(veh.current_fuel) / float(veh.max_fuel) < low_fuel_fraction:
			gap = minf(gap, low_fuel_gap)
	return gap

func _surface_y(x: float) -> float:
	if is_instance_valid(terrain) and terrain.has_method("get_surface_y_at_world_x"):
		return terrain.get_surface_y_at_world_x(x)
	return 410.0

## True when a falling obstacle, its warning/shadow, or a pothole is near this x.
func _is_blocked(x: float) -> bool:
	if is_instance_valid(obstacle_container):
		for o in obstacle_container.get_children():
			if o is Node2D and absf(o.global_position.x - x) < obstacle_clearance_x:
				return true
	if is_instance_valid(avoid_nodes_parent):
		for n in avoid_nodes_parent.get_children():
			if n is Node2D and (n.has_method("start_warning") or n.has_method("update_landing_state") or n is PotholeHazard):
				if absf(n.global_position.x - x) < obstacle_clearance_x:
					return true
	return false

func _spawn_coin_group(start_x: float) -> void:
	if _count_kind(SurvivalCollectible.Kind.COIN) + coins_per_group_max > max_active_coins:
		return
	var x := start_x
	for attempt in 4:
		if not _is_blocked(x) and not _is_blocked(x + coin_spacing * coins_per_group_max):
			break
		x += obstacle_clearance_x
		if attempt == 3:
			return
	x = maxf(x, _last_coin_end_x + coin_spacing * 2.0)
	var count := randi_range(coins_per_group_min, coins_per_group_max)
	for i in count:
		var cx := x + i * coin_spacing
		var y := _surface_y(cx) - coin_surface_clearance
		_make_pickup(COIN_SCENE, Vector2(cx, y), coin_value)
	_last_coin_end_x = x + (count - 1) * coin_spacing

func _spawn_fuel(start_x: float) -> void:
	var x := start_x
	# keep fuel clear of coin groups and falling hazards
	if absf(x - _last_coin_end_x) < fuel_coin_separation:
		x = _last_coin_end_x + fuel_coin_separation
	for attempt in 4:
		if not _is_blocked(x):
			break
		x += obstacle_clearance_x
		if attempt == 3:
			return
	var y := _surface_y(x) - fuel_surface_clearance
	_make_pickup(FUEL_SCENE, Vector2(x, y), fuel_amount)

func _make_pickup(scene: PackedScene, pos: Vector2, value: float) -> void:
	var p := scene.instantiate() as SurvivalCollectible
	p.value = value
	p.position = pos
	p.collected.connect(_on_collected)
	container.add_child(p)
	_active.append(p)

func _on_collected(kind: int, value: float, pickup: SurvivalCollectible) -> void:
	_active.erase(pickup)
	if kind == SurvivalCollectible.Kind.COIN:
		coins_collected += int(value)
		coins_changed.emit(coins_collected)
	else:
		if is_instance_valid(vehicle) and vehicle.has_method("refuel"):
			vehicle.refuel(value)   # VehicleController clamps to max_fuel
		fuel_collected.emit(value)

func _count_kind(k: int) -> int:
	var n := 0
	for p in _active:
		if is_instance_valid(p) and p.kind == k and not p.is_collected:
			n += 1
	return n

func _cleanup(vx: float) -> void:
	var i := _active.size() - 1
	while i >= 0:
		var p := _active[i]
		if not is_instance_valid(p):
			_active.remove_at(i)
		elif p.global_position.x < vx - despawn_behind_distance:
			_active.remove_at(i)
			p.queue_free()
		i -= 1
