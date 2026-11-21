extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("/home/daniel/Pictures/Screenshots/Screenshot From 2026-11-21 13-37-08.png")
	
	# Let's inspect the exact pixels in X=[240, 460], Y=[400, 530]
	# What sprites or shapes are in this box?
	# Let's save slices of 13-37-08:
	var crop := img.get_region(Rect2i(230, 390, 240, 150))
	crop.save_png("res://references/cluster2_clean.png")
	print("Saved cluster2_clean.png (240x150)")
	
	# Let's compare cluster2_clean.png against MonsterTruck sprites:
	var truck_body := Image.load_from_file("res://assets/vehicles/player/body/vehicle_body_truck_side.png")
	var wheel_rear := Image.load_from_file("res://assets/vehicles/wheels/wheel_rear.png")
	var wheel_front := Image.load_from_file("res://assets/vehicles/wheels/wheel_front.png")
	
	print("Truck body size: ", truck_body.get_size() if truck_body else Vector2i.ZERO)
	print("Wheel rear size: ", wheel_rear.get_size() if wheel_rear else Vector2i.ZERO)
	print("Wheel front size: ", wheel_front.get_size() if wheel_front else Vector2i.ZERO)
	
	# Where is the truck body in cluster2_clean?
	# Sample a distinct pixel from truck_body: e.g. blue/orange/red
	var p_body := truck_body.get_pixel(truck_body.get_width() / 2, truck_body.get_height() / 2)
	print("Truck body center pixel: ", p_body)
	
	# Now what else is in cluster2_clean that is NOT the truck?
	# Let's check non-truck pixels:
	quit(0)
