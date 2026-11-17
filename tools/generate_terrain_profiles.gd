@tool
extends SceneTree

func _init() -> void:
	print("=================================================================")
	print("--- GENERATING BIOME TERRAIN PROFILES (GODOT 4.7.2) ---")
	print("=================================================================")

	var prof_class: GDScript = load("res://scripts/terrain/BiomeTerrainProfile.gd")

	var normal: Resource = prof_class.create_normal_land_profile()
	var err1 := ResourceSaver.save(normal, "res://assets/terrain/profiles/normal_land_profile.tres")
	if err1 == OK:
		print("  ✓ Saved res://assets/terrain/profiles/normal_land_profile.tres")

	var heaven: Resource = prof_class.create_heaven_profile()
	var err2 := ResourceSaver.save(heaven, "res://assets/terrain/profiles/heaven_terrain_profile.tres")
	if err2 == OK:
		print("  ✓ Saved res://assets/terrain/profiles/heaven_terrain_profile.tres")

	var hell: Resource = prof_class.create_hell_profile()
	var err3 := ResourceSaver.save(hell, "res://assets/terrain/profiles/hell_terrain_profile.tres")
	if err3 == OK:
		print("  ✓ Saved res://assets/terrain/profiles/hell_terrain_profile.tres")

	quit(0 if (err1 == OK and err2 == OK and err3 == OK) else 1)
