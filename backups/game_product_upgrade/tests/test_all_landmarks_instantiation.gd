extends SceneTree

const RoadsideLandmarkRegistry = preload("res://scripts/modes/indian_roads/RoadsideLandmarkRegistry.gd")
const RoadsideLandmarkScene = preload("res://scenes/modes/indian_roads/visual_upgrade_v2/RoadsideLandmark.tscn")

func _init() -> void:
	print("=================================================================")
	print("--- TESTING ALL ROADSIDE LANDMARKS INSTANTIATION & ASSETS ---")
	print("=================================================================")
	var states: Array[String] = ["tamil_nadu", "goa", "kerala", "rajasthan", "gujarat", "telangana"]
	var total_lms := 0
	var errors := 0

	for st in states:
		var lms: Array[Dictionary] = RoadsideLandmarkRegistry.get_landmarks_for_state(st)
		print(">>> State: %s (%d landmarks) <<<" % [st, lms.size()])
		for d in lms:
			total_lms += 1
			var asset_p: String = d.get("asset", "")
			if not ResourceLoader.exists(asset_p):
				print("  ❌ ERROR: Missing asset for %s (%s): %s" % [d.get("name"), d.get("id"), asset_p])
				errors += 1
			else:
				var tex := load(asset_p) as Texture2D
				if not tex:
					print("  ❌ ERROR: Failed loading texture %s" % asset_p)
					errors += 1
				else:
					var lm := RoadsideLandmarkScene.instantiate()
					lm.landmark_id = d.get("id", "")
					lm.place_name = d.get("name", "")
					lm.location_district = d.get("district", "")
					lm.visual_asset_path = asset_p
					lm.target_height = d.get("target_height", 240.0)

					var root := Node2D.new()
					root.add_child(lm)
					root.free()
					print("  ✓ %s [%s] loaded! Res: %s, Height: %.1f" % [d.get("name"), d.get("id"), tex.get_size(), d.get("target_height")])

	print("=================================================================")
	print("TOTAL LANDMARKS CHECKED: %d | ERRORS: %d" % [total_lms, errors])
	print("=================================================================")
	quit(0 if errors == 0 else 1)
