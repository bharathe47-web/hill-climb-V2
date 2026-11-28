extends SceneTree

func _init():
	print("--- INSPECTING EXISTING PRODUCTION ASSETS ---")
	var targets = [
		"res://assets/indian_locations/tamil_nadu_madurai_meenakshi_temple.png",
		"res://assets/indian_locations/tamil_nadu_thiruvalluvar_statue.png",
		"res://assets/indian_locations/tamil_nadu_vivekananda_rock_memorial.png",
		"res://assets/indian_locations/tamil_nadu_chennai_marina_lighthouse.png",
		"res://assets/indian_locations/tamil_nadu_kanyakumari_coastline.png",
		"res://assets/indian_roads/indian_roadside_coconut_tree.png",
		"res://assets/indian_roads/indian_roadside_dhaba_stall.png",
		"res://assets/indian_roads/indian_roadside_tea_stall.png",
		"res://assets/indian_roads/indian_roadside_auto_rickshaw.png",
		"res://assets/indian_roads/indian_road_sign_nh44.png",
		"res://assets/indian_roads/indian_parallax_western_ghats.png"
	]
	
	for path in targets:
		var img = Image.new()
		var err = img.load(path)
		if err == OK:
			var non_transparent = 0
			var avg_color = Color(0,0,0,0)
			var w = img.get_width()
			var h = img.get_height()
			for y in range(0, h, max(1, h / 20)):
				for x in range(0, w, max(1, w / 20)):
					var p = img.get_pixel(x, y)
					if p.a > 0.1:
						non_transparent += 1
						avg_color += p
			if non_transparent > 0:
				avg_color /= float(non_transparent)
			print(path.get_file(), " -> Dims: ", w, "x", h, " | Samples: ", non_transparent, " | Avg Color (RGBA): ", avg_color)
		else:
			print("Could not load: ", path)
			
	quit(0)
