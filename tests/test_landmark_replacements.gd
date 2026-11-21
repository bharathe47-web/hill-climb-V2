extends SceneTree

func _init():
	print("==================================================")
	print("TESTING LANDMARK REPLACEMENTS IN ENGINE")
	print("==================================================")
	
	var landmark_scene = load("res://scenes/modes/indian_roads/Landmark.tscn")
	assert(landmark_scene != null, "Failed to load Landmark.tscn")
	
	# Test Meenakshi Temple
	var lm_meenakshi = landmark_scene.instantiate()
	var tex_meenakshi = load("res://assets/indian_roads_replacements/replacement_tamil_nadu_madurai_meenakshi_temple.png")
	assert(tex_meenakshi != null, "Failed to load replacement Meenakshi texture")
	print("✅ Replacement Meenakshi loaded! Dimensions: ", tex_meenakshi.get_size())
	
	# Test Thiruvalluvar Statue
	var lm_thiru = landmark_scene.instantiate()
	var tex_thiru = load("res://assets/indian_roads_replacements/replacement_tamil_nadu_thiruvalluvar_statue.png")
	assert(tex_thiru != null, "Failed to load replacement Thiruvalluvar texture")
	print("✅ Replacement Thiruvalluvar loaded! Dimensions: ", tex_thiru.get_size())
	
	# Test Vivekananda Rock
	var tex_vr = load("res://assets/indian_roads_replacements/replacement_tamil_nadu_vivekananda_rock_memorial.png")
	assert(tex_vr != null, "Failed to load replacement Vivekananda Rock texture")
	print("✅ Replacement Vivekananda Rock loaded! Dimensions: ", tex_vr.get_size())
	
	# Test Chennai Lighthouse
	var tex_lh = load("res://assets/indian_roads_replacements/replacement_tamil_nadu_chennai_marina_lighthouse.png")
	assert(tex_lh != null, "Failed to load replacement Chennai Lighthouse texture")
	print("✅ Replacement Chennai Lighthouse loaded! Dimensions: ", tex_lh.get_size())
	
	# Clean up instances
	lm_meenakshi.free()
	lm_thiru.free()
	
	print("==================================================")
	print("ALL LANDMARK REPLACEMENTS VERIFIED SUCCESSFULLY!")
	print("==================================================")
	quit(0)
