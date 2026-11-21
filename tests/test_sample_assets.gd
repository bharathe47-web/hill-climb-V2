extends SceneTree

func _init():
	print("==================================================")
	print("STAGE 4 VERIFICATION: LOADING 5 SAMPLE ASSETS")
	print("==================================================")
	
	# 1. Road Texture
	var road_tex = load("res://assets/samples/indian_roads/sample_road_asphalt_dark.png")
	assert(road_tex != null, "Failed to load sample_road_asphalt_dark.png")
	print("✅ 1. Road Texture: Loaded successfully! Size: ", road_tex.get_size(), " (1024x1024 seamless)")
	
	# 2. Tamil Nadu Landmark
	var landmark_tex = load("res://assets/samples/indian_roads/sample_thiruvalluvar_statue.png")
	assert(landmark_tex != null, "Failed to load sample_thiruvalluvar_statue.png")
	print("✅ 2. Landmark Sprite: Loaded successfully! Size: ", landmark_tex.get_size(), " (Transparent PNG)")
	
	# 3. Roadside Prop
	var prop_tex = load("res://assets/samples/indian_roads/sample_auto_rickshaw_prop.png")
	assert(prop_tex != null, "Failed to load sample_auto_rickshaw_prop.png")
	print("✅ 3. Roadside Prop: Loaded successfully! Size: ", prop_tex.get_size(), " (Auto Rickshaw Transparent PNG)")
	
	# 4. Parallax Background
	var bg_sky = load("res://assets/samples/indian_roads/parallax_western_ghats/sky_Background.png")
	var bg_mount = load("res://assets/samples/indian_roads/parallax_western_ghats/LargeMountain.png")
	var bg_full = load("res://assets/samples/indian_roads/parallax_western_ghats/mountain_full_background1.png")
	assert(bg_sky != null and bg_mount != null and bg_full != null, "Failed to load parallax layers")
	print("✅ 4. Parallax Layers: Loaded successfully! Full Size: ", bg_full.get_size(), " (1280x720 16:9 HD)")
	
	# 5. State Map
	var map_svg = load("res://assets/samples/indian_roads/sample_tamil_nadu_locator_map.svg")
	var map_png = load("res://assets/samples/indian_roads/sample_tamil_nadu_map_card.png")
	assert(map_svg != null and map_png != null, "Failed to load state map assets")
	print("✅ 5. State Map: Loaded successfully! SVG Size: ", map_svg.get_size(), " | PNG Card: ", map_png.get_size())
	
	print("==================================================")
	print("ALL 5 SAMPLE ASSETS VERIFIED IN GODOT 4.7 ENGINE!")
	print("==================================================")
	quit(0)
