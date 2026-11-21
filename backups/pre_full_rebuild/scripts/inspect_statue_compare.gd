extends SceneTree

func _init():
	print("Inspecting captured fix screenshots...")
	var img1 = Image.new()
	img1.load("res://docs/screenshots/tamil_nadu_statue_map_fix/tn_fix_1_restored_statue_approach.png")
	print("Shot 1: size=", img1.get_size(), " format=", img1.get_format())
	
	var img2 = Image.new()
	img2.load("res://docs/screenshots/tamil_nadu_statue_map_fix/tn_fix_2_restored_statue_at_pedestal.png")
	print("Shot 2: size=", img2.get_size(), " format=", img2.get_format())
	
	var img4 = Image.new()
	img4.load("res://docs/screenshots/tamil_nadu_statue_map_fix/tn_fix_4_route_map_overlay_fixed.png")
	print("Shot 4: size=", img4.get_size(), " format=", img4.get_format())

	quit(0)
