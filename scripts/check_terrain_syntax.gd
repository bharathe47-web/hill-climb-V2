extends SceneTree

func _init() -> void:
	print("Checking IndianRoadTerrainV2 syntax...")
	var scr = load("res://scripts/modes/indian_roads/IndianRoadTerrainV2.gd")
	if scr:
		print("Loaded script successfully: ", scr)
		var scn = load("res://scenes/modes/indian_roads/visual_upgrade_v2/IndianRoadTerrainV2.tscn")
		if scn:
			print("Loaded scene successfully: ", scn)
			var inst = scn.instantiate()
			print("Instantiated scene: ", inst)
		else:
			print("Failed to load scene!")
	else:
		print("Failed to load script!")
	quit()
