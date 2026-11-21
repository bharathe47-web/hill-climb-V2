class_name StageData
extends Resource

@export var id: String = "stage_01_kanyakumari"
@export var stage_name_en: String = "Kanyakumari Coast"
@export var stage_name_ta: String = "கன்னியாகுமரி கடற்கரை"
@export var subtitle_en: String = "The Land's End & Ocean Highway"
@export var length_meters: float = 1200.0
@export var biome: String = "coastal"
@export var difficulty: float = 1.0

# Terrain Generation
@export var terrain_seed: int = 1337
@export var hill_amplitude: float = 160.0 # Height of big rolling dips and crests
@export var hill_frequency: float = 0.0018 # Frequency of major rolls
@export var bump_amplitude: float = 24.0 # Micro terrain bumps
@export var bump_frequency: float = 0.012

# Pickups & Distribution
@export var coin_density: float = 120.0 # Distance between coin arcs
@export var fuel_interval_meters: float = 300.0 # Distance between fuel cans

# Checkpoints: Array of Dicts { "distance": float, "name_en": String, "name_ta": String }
@export var checkpoints: Array[Dictionary] = [
	{"distance": 300.0, "name_en": "Vivekananda Viewpoint", "name_ta": "விவேகானந்தர் பார்வை மையம்"},
	{"distance": 600.0, "name_en": "Vattakottai Fort Way", "name_ta": "வட்டக்கோட்டை வழி"},
	{"distance": 900.0, "name_en": "Chothavilai Beach", "name_ta": "சொத்தவிளை கடற்கரை"},
	{"distance": 1200.0, "name_en": "Nagercoil Border", "name_ta": "நாகர்கோவில் எல்லை"}
]

# Landmark props to spawn at certain distances
@export var landmark_props: Array[Dictionary] = [
	{"distance": 150.0, "prop_type": "tea_shop"},
	{"distance": 320.0, "prop_type": "sign_kanyakumari"},
	{"distance": 700.0, "prop_type": "tea_shop"},
	{"distance": 950.0, "prop_type": "sign_kanyakumari"}
]
