@tool
extends SceneTree

func _init() -> void:
	print("Building SpriteFrames and refined Hell assets...")
	_create_sprite_frames(
		"res://assets/environments/hell/architecture/torches/torch_burn_strip26.png",
		"res://assets/environments/hell/architecture/torches/torch_burn.tres",
		"burn", 26, 39, 173, 12.0
	)
	_create_sprite_frames(
		"res://assets/environments/hell/architecture/braziers/brazier_fire_strip26.png",
		"res://assets/environments/hell/architecture/braziers/brazier_fire.tres",
		"burn", 26, 137, 147, 12.0
	)
	_create_sprite_frames(
		"res://assets/environments/hell/architecture/banners/banner_wave_strip35.png",
		"res://assets/environments/hell/architecture/banners/banner_wave.tres",
		"wave", 35, 97, 189, 14.0
	)
	print("SpriteFrames generated successfully.")
	quit(0)

func _create_sprite_frames(tex_path: String, out_tres_path: String, anim_name: String, frame_count: int, fw: int, fh: int, fps: float) -> void:
	var tex := load(tex_path) as Texture2D
	if not tex:
		printerr("Cannot load texture:", tex_path)
		return

	var sf := SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")
	sf.add_animation(anim_name)
	sf.set_animation_speed(anim_name, fps)
	sf.set_animation_loop(anim_name, true)

	for i in range(frame_count):
		var atlas := AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(float(i * fw), 0.0, float(fw), float(fh))
		sf.add_frame(anim_name, atlas)

	var err := ResourceSaver.save(sf, out_tres_path)
	if err == OK:
		print("  [✓] Created SpriteFrames: %s (%d frames at %.1f fps)" % [out_tres_path, frame_count, fps])
	else:
		printerr("Failed to save SpriteFrames:", out_tres_path, " err=", err)
