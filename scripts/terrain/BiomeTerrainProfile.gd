class_name BiomeTerrainProfile
extends Resource

## BiomeTerrainProfile: Data-driven visual and physical profile for terrain segments.
## Defines ground textures, subsoil strata, colors, surface friction, and decoration palettes
## for Normal Land, Heaven, and Hell biomes.

@export var profile_name: String = "Normal Land"
@export var biome_type: int = 0 # WorldCycleSchedule.BiomeType.NORMAL_LAND

var biome_name: String:
	get:
		return profile_name

@export_group("Textures & Materials")
@export var ground_texture: Texture2D
@export var subsoil_texture: Texture2D
@export var ground_color: Color = Color.WHITE
@export var subsoil_color: Color = Color(0.9, 0.9, 0.9, 1.0)
@export var ground_texture_scale: Vector2 = Vector2.ONE

@export_group("Physics")
@export var surface_friction: float = 1.0

@export_group("Decoration Palettes")
@export var decorations_enabled: bool = true
@export var props_textures: Array[Texture2D] = []
@export var rocks_textures: Array[Texture2D] = []
@export var flora_textures: Array[Texture2D] = []

## Factory method creating the default Normal Land countryside profile.
static func create_normal_land_profile() -> Resource:
	var prof := Resource.new()
	prof.set_script(load("res://scripts/terrain/BiomeTerrainProfile.gd"))
	prof.set("profile_name", "Normal Land")
	prof.set("biome_type", 0) # NORMAL_LAND
	prof.set("ground_texture", load("res://assets/terrain/surfaces/countryside_grass_top.png"))
	prof.set("subsoil_texture", load("res://assets/terrain/surfaces/countryside_earth_strata.png"))
	prof.set("ground_color", Color(1.0, 1.0, 1.0, 1.0))
	prof.set("subsoil_color", Color(1.0, 1.0, 1.0, 1.0))
	prof.set("surface_friction", 1.0)
	prof.set("decorations_enabled", true)

	prof.set("props_textures", [
		load("res://assets/environment/countryside/fences/wooden_fence_01.png"),
		load("res://assets/environment/countryside/fences/wooden_fence_broken.png"),
		load("res://assets/environment/countryside/props/fallen_log_01.png"),
		load("res://assets/environment/countryside/props/tree_stump_mossy.png"),
		load("res://assets/environment/countryside/props/stone_cluster_small.png"),
		load("res://assets/environment/countryside/props/hay_bale_round.png"),
		load("res://assets/environment/countryside/signs/wooden_signpost.png")
	])
	prof.set("rocks_textures", [
		load("res://assets/terrain/rocks/small_stones_pebbles.png"),
		load("res://assets/terrain/rocks/large_rock_boulder_01.png"),
		load("res://assets/terrain/rocks/rock_hill_slope_left.png"),
		load("res://assets/terrain/rocks/rock_hill_slope_right.png")
	])
	prof.set("flora_textures", [
		load("res://assets/environment/countryside/bushes/bush_cozy_green.png"),
		load("res://assets/environment/countryside/bushes/bush_berry.png"),
		load("res://assets/environment/countryside/bushes/bush_lavender.png"),
		load("res://assets/environment/countryside/bushes/bush_round_green.png"),
		load("res://assets/environment/countryside/plants/fern_wild.png"),
		load("res://assets/environment/countryside/plants/grass_clump_dense.png"),
		load("res://assets/environment/countryside/plants/flower_yellow.png"),
		load("res://assets/environment/countryside/plants/flower_purple.png"),
		load("res://assets/environment/countryside/plants/grass_tuft_01.png")
	])
	return prof

## Factory method creating the celestial Heaven marble profile.
static func create_heaven_profile() -> Resource:
	var prof := Resource.new()
	prof.set_script(load("res://scripts/terrain/BiomeTerrainProfile.gd"))
	prof.set("profile_name", "Heaven")
	prof.set("biome_type", 1) # HEAVEN
	prof.set("ground_texture", load("res://assets/environments/heaven/architecture/heaven_marble_floor.png"))
	prof.set("subsoil_texture", load("res://assets/environments/heaven/vfx/clouds/white_puff_06.png"))
	prof.set("ground_color", Color(1.35, 1.25, 1.05, 1.0))
	prof.set("subsoil_color", Color(0.98, 0.96, 0.92, 0.90))
	prof.set("surface_friction", 1.05)
	prof.set("decorations_enabled", true)

	prof.set("props_textures", [
		load("res://assets/environments/heaven/architecture/heaven_palace_column.png"),
		load("res://assets/environments/heaven/architecture/heaven_golden_archway_front.png"),
		load("res://assets/environments/heaven/architecture/heaven_golden_archway.png")
	])
	prof.set("rocks_textures", [
		load("res://assets/environments/heaven/decorations/heaven_angel_statue.png"),
		load("res://assets/environments/heaven/vfx/clouds/white_puff_06.png"),
		load("res://assets/environments/heaven/vfx/clouds/white_puff_18.png")
	])
	prof.set("flora_textures", [
		load("res://assets/environments/heaven/decorations/flowers/flower_01.png"),
		load("res://assets/environments/heaven/decorations/flowers/flower_02.png"),
		load("res://assets/environments/heaven/decorations/flowers/flower_03.png"),
		load("res://assets/environments/heaven/decorations/flowers/flower_04.png"),
		load("res://assets/environments/heaven/decorations/flowers/flower_05.png"),
		load("res://assets/environments/heaven/decorations/flowers/flower_06.png"),
		load("res://assets/environments/heaven/decorations/flowers/flower_07.png"),
		load("res://assets/environments/heaven/decorations/flowers/flower_08.png")
	])
	return prof

## Factory method creating the infernal volcanic Hell basalt profile.
static func create_hell_profile() -> Resource:
	var prof := Resource.new()
	prof.set_script(load("res://scripts/terrain/BiomeTerrainProfile.gd"))
	prof.set("profile_name", "Hell")
	prof.set("biome_type", 2) # HELL
	prof.set("ground_texture", load("res://assets/environments/hell/terrain/hell_basalt_platform.png"))
	prof.set("subsoil_texture", load("res://assets/environments/hell/vfx/lava/lava_tiles.png"))
	prof.set("ground_color", Color(0.88, 0.82, 0.82, 1.0))
	prof.set("subsoil_color", Color(0.85, 0.35, 0.15, 0.9))
	prof.set("surface_friction", 0.95)
	prof.set("decorations_enabled", true)

	prof.set("props_textures", [
		load("res://assets/environments/hell/terrain/hell_basalt_column.png"),
		load("res://assets/environments/hell/decorations/giant_dragon_skull_decal.png"),
		load("res://assets/environments/hell/decorations/catacomb_skull_pile_decal.png"),
		load("res://assets/environments/hell/terrain/magma_vent_fissure_prop.png")
	])
	prof.set("rocks_textures", [
		load("res://assets/environments/hell/terrain/hell_volcanic_rock_a.png"),
		load("res://assets/environments/hell/terrain/hell_volcanic_rock_b.png"),
		load("res://assets/environments/hell/terrain/hell_volcanic_rock_c.png"),
		load("res://assets/environments/hell/terrain/volcanic_obsidian_spike_single.png"),
		load("res://assets/environments/hell/terrain/volcanic_obsidian_spikes_cluster.png")
	])
	prof.set("flora_textures", [
		load("res://assets/environments/hell/decorations/skulls/skull_01.png"),
		load("res://assets/environments/hell/decorations/skulls/skull_02.png"),
		load("res://assets/environments/hell/decorations/skulls/skull_03.png"),
		load("res://assets/environments/hell/decorations/skulls/skull_05.png"),
		load("res://assets/environments/hell/decorations/skulls/skull_07.png")
	])
	return prof
