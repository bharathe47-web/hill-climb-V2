extends SceneTree

func _init() -> void:
	var img := Image.load_from_file("res://references/cluster2_clean.png")
	# Sample a 30x30 patch from x=80..110, y=40..70
	var p := img.get_region(Rect2i(80, 40, 30, 30))
	p.save_png("res://references/crate_sample_30x30.png")
	print("Saved crate_sample_30x30.png")
	
	# Sample colors
	var c_mid := p.get_pixel(15, 15)
	print("Center pixel of crate block: R=%.4f G=%.4f B=%.4f" % [c_mid.r, c_mid.g, c_mid.b])
	
	# Check where this exact color / texture comes from
	var paths = [
		"res://assets/environments/hell/architecture/hell_bridge/hell_stone_bridge_causeway.png",
		"res://assets/environments/hell/architecture/hell_bridge/hell_volcanic_bridge_arch.png",
		"res://assets/environments/hell/architecture/hell_bridge/stone_bridge_masonry.png",
		"res://assets/environments/hell/architecture/stone_terrain/hell_volcanic_brick_surface.png",
		"res://assets/environments/hell/terrain/hell_basalt_column.png",
		"res://assets/environments/hell/terrain/magma_vent_fissure_prop.png",
		"res://assets/environments/hell/terrain/volcanic_obsidian_spikes_cluster.png",
		"res://assets/environments/hell/terrain/volcanic_obsidian_spike_single.png",
		"res://assets/environments/hell/foreground/decorations/hell_foreground_skulls_rocks.png",
		"res://assets/environments/hell/foreground/skeletons/skeleton_remains_prop.png",
		"res://assets/environments/hell/foreground/skulls/skulls_cluster_prop.png",
		"res://assets/environments/hell/decorations/catacomb_skull_pile_decal.png",
		"res://assets/environments/hell/background/fortress/hell_giant_demon_fortress.png",
		"res://assets/environment/countryside/fences/wooden_fence_01.png",
		"res://assets/environment/countryside/fences/wooden_fence_broken.png",
		"res://assets/environment/countryside/props/tree_stump_mossy.png",
		"res://assets/environment/countryside/props/fallen_log_01.png",
		"res://quarantine/old_hell_assets_20261120/terrain/hell_basalt_platform.png",
		"res://quarantine/old_hell_assets_20261120/terrain/broken_basalt_platform_hazard.png",
		"res://quarantine/old_hell_assets_20261120/terrain/hell_volcanic_rock_a.png",
		"res://quarantine/old_hell_assets_20261120/terrain/hell_volcanic_rock_b.png",
		"res://quarantine/old_hell_assets_20261120/terrain/hell_volcanic_rock_c.png"
	]
	
	for path in paths:
		var tex := Image.load_from_file(path)
		if not tex: continue
		tex.convert(Image.FORMAT_RGBA8)
		# Check if tex has c_mid
		var found := 0
		for ty in range(tex.get_height()):
			for tx in range(tex.get_width()):
				var tp := tex.get_pixel(tx, ty)
				if abs(tp.r - c_mid.r) < 0.02 and abs(tp.g - c_mid.g) < 0.02 and abs(tp.b - c_mid.b) < 0.02:
					found += 1
		if found > 0:
			print("MATCH in %s: %d pixels match c_mid" % [path, found])
			
	quit(0)
