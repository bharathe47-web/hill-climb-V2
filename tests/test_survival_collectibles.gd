extends SceneTree

## Survival coin & fuel collectibles: spawning, collection, fuel clamp, HUD, cleanup, non-solid.
## Run: godot --headless --path . -s tests/test_survival_collectibles.gd

var failures: int = 0

func check(cond: bool, msg: String) -> void:
	if cond:
		print("  ✓ ", msg)
	else:
		failures += 1
		print("  ✗ FAIL: ", msg)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var main = load("res://scenes/main/Main.tscn").instantiate()
	root.add_child(main)
	for i in 5:
		await process_frame
	main.load_survival(0)
	for i in 10:
		await physics_frame
	var surv = main.current_scene_node
	var sp: SurvivalCollectibleSpawner = surv.collectible_spawner
	var veh = surv.vehicle

	print("-> Setup")
	check(is_instance_valid(sp), "Survival creates a collectible spawner")
	check(veh != null, "Survival vehicle present")

	print("-> Non-solid / layers")
	var coin_scene: PackedScene = load("res://scenes/modes/survival/collectibles/survival_coin.tscn")
	var probe := coin_scene.instantiate() as Area2D
	check(probe is Area2D, "Coin is an Area2D (not a physics body)")
	check(probe.collision_layer == 4 and probe.collision_mask == 2, "Coin: layer 4 (pickup), mask 2 (vehicle only)")
	probe.free()
	check((veh.collision_mask & 4) == 0, "Vehicle collision mask does not include pickup layer")

	print("-> Spawning")
	# advance the vehicle so schedule produces content
	for i in 60:
		await physics_frame
	var coins := _count(sp, SurvivalCollectible.Kind.COIN)
	check(coins >= 3, "Coins spawned ahead (%d active)" % coins)
	for p in sp._active:
		if is_instance_valid(p) and p.kind == SurvivalCollectible.Kind.COIN:
			var ground: float = surv.get_terrain_surface_y(p.global_position.x)
			check(p.global_position.y < ground, "Coin sits above terrain surface")
			check(p.global_position.x > veh.global_position.x, "Coin spawned ahead of vehicle")
			break
	# spacing within the active set
	var xs: Array[float] = []
	for p in sp._active:
		if is_instance_valid(p) and p.kind == SurvivalCollectible.Kind.COIN:
			xs.append(p.global_position.x)
	xs.sort()
	var min_gap := 99999.0
	for i in range(1, xs.size()):
		min_gap = minf(min_gap, xs[i] - xs[i - 1])
	check(min_gap >= sp.coin_spacing - 1.0, "Coins never closer than coin_spacing (min gap %.0f)" % min_gap)
	check(coins <= sp.max_active_coins, "Active coins capped")

	print("-> Coin collection (once, counter, HUD)")
	var target: SurvivalCollectible = null
	for p in sp._active:
		if is_instance_valid(p) and p.kind == SurvivalCollectible.Kind.COIN:
			target = p
			break
	var before := sp.coins_collected
	var snapshot: Array[SurvivalCollectible] = []
	for p in sp._active:
		if is_instance_valid(p) and p.kind == SurvivalCollectible.Kind.COIN:
			snapshot.append(p)
	veh.global_position = target.global_position
	for i in 6:
		await physics_frame
	var touched := 0
	for p in snapshot:
		if is_instance_valid(p) and p.is_collected:
			touched += 1
	var after_first := sp.coins_collected
	check(touched >= 1 and after_first == before + touched, "Counter rises exactly once per touched coin (%d coins: %d -> %d)" % [touched, before, after_first])
	check(target.is_collected, "Coin flagged collected")
	# teleport away and back over the same coin: must not count twice
	veh.global_position = target.global_position + Vector2(0, -300)
	for i in 3:
		await physics_frame
	veh.global_position = target.global_position
	for i in 6:
		await physics_frame
	check(sp.coins_collected == after_first, "Already-collected coins cannot be collected twice")
	var hud = surv.hud
	var coins_label: Label = hud.get_node("%CoinsLabel")
	check(coins_label.text == str(sp.coins_collected), "HUD coin label shows %s" % coins_label.text)
	check(hud.get_node("%CoinsPanel").visible, "HUD coins panel visible in Survival")
	check(hud.get_node("%FuelSection").visible, "HUD fuel gauge visible in Survival")
	await create_timer(1.0).timeout
	check(not is_instance_valid(target), "Collected coin removed after pop animation")

	print("-> Fuel")
	veh.current_fuel = 20.0
	sp._make_pickup(load("res://scenes/modes/survival/collectibles/survival_fuel_can.tscn"), veh.global_position, sp.fuel_amount)
	for i in 6:
		await physics_frame
	check(is_equal_approx(veh.current_fuel, 55.0), "Fuel can restores %.0f (20 -> %.0f)" % [sp.fuel_amount, veh.current_fuel])
	veh.current_fuel = veh.max_fuel - 5.0
	sp._make_pickup(load("res://scenes/modes/survival/collectibles/survival_fuel_can.tscn"), veh.global_position, sp.fuel_amount)
	for i in 6:
		await physics_frame
	check(is_equal_approx(veh.current_fuel, veh.max_fuel), "Fuel never exceeds max (%.1f / %.1f)" % [veh.current_fuel, veh.max_fuel])

	print("-> Fuel scheduling")
	veh.global_position = Vector2(veh.global_position.x + 8000.0, veh.global_position.y - 100.0)
	for i in 40:
		await physics_frame
	var fuel_n := _count(sp, SurvivalCollectible.Kind.FUEL)
	check(fuel_n <= sp.max_active_fuel, "Fuel cans capped (%d active)" % fuel_n)
	check(sp._next_fuel_x > veh.global_position.x, "Fuel schedule advanced with the vehicle")

	print("-> Obstacle avoidance")
	var fake := Node2D.new()
	surv.obstacle_container.add_child(fake)
	fake.global_position = Vector2(50000.0, 0.0)
	check(sp._is_blocked(50000.0 + 50.0), "Spawner treats x near a falling obstacle as blocked")
	check(not sp._is_blocked(50000.0 + 900.0), "Spawner allows x clear of obstacles")
	fake.queue_free()

	print("-> Cleanup of pickups left behind")
	veh.global_position = Vector2(veh.global_position.x + 6000.0, veh.global_position.y - 100.0)
	for i in 30:
		await physics_frame
	var stale := 0
	for p in sp._active:
		if is_instance_valid(p) and p.global_position.x < veh.global_position.x - sp.despawn_behind_distance - 50.0:
			stale += 1
	check(stale == 0, "No stale pickups far behind the vehicle")
	check(sp._active.size() < 40, "Active pickup list stays small (%d)" % sp._active.size())

	print("-> Restart resets collectibles")
	surv.start_run()
	for i in 4:
		await physics_frame
	check(sp.coins_collected == 0, "Run restart resets coin count")
	check(coins_label.text == "0", "HUD coin count reset on restart")

	print("")
	if failures == 0:
		print("✓ ALL SURVIVAL COLLECTIBLE TESTS PASSED")
	else:
		print("✗ %d FAILURE(S)" % failures)
	quit(1 if failures > 0 else 0)

func _count(sp: SurvivalCollectibleSpawner, k: int) -> int:
	var n := 0
	for p in sp._active:
		if is_instance_valid(p) and p.kind == k and not p.is_collected:
			n += 1
	return n
