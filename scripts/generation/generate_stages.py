#!/usr/bin/env python3
"""
Generate the 7 South Indian Stage Resources (.tres)
Kanyakumari -> Nagercoil -> Tirunelveli -> Madurai -> Trichy -> Villupuram -> Chennai
"""
import os

stages = [
    {
        "id": "stage_01_kanyakumari",
        "name_en": "Kanyakumari Coast",
        "name_ta": "கன்னியாகுமரி கடற்கரை",
        "subtitle_en": "The Land's End & Ocean Highway",
        "length": 1200.0,
        "biome": "coastal",
        "difficulty": 1.0,
        "seed": 1001,
        "amp": 140.0,
        "freq": 0.0016,
        "bump_amp": 18.0,
        "checkpoints": [
            {"dist": 300.0, "en": "Vivekananda Viewpoint", "ta": "விவேகானந்தர் பார்வை மையம்"},
            {"dist": 600.0, "en": "Vattakottai Coastal Fort", "ta": "வட்டக்கோட்டை கடற்கரை அரண்"},
            {"dist": 900.0, "en": "Chothavilai Beach Curve", "ta": "சொத்தவிளை கடற்கரை வளைவு"},
            {"dist": 1200.0, "en": "Nagercoil District Entry", "ta": "நாகர்கோவில் எல்லை"}
        ],
        "props": [
            {"dist": 160.0, "prop": "tea_shop"},
            {"dist": 320.0, "prop": "sign_kanyakumari"},
            {"dist": 580.0, "prop": "stone_wall"},
            {"dist": 880.0, "prop": "tea_shop"}
        ]
    },
    {
        "id": "stage_02_nagercoil",
        "name_en": "Nagercoil Foothills",
        "name_ta": "நாகர்கோவில் அடிவாரம்",
        "subtitle_en": "Lush Ghats & Rubber Plantations",
        "length": 1500.0,
        "biome": "foothills",
        "difficulty": 1.3,
        "seed": 2002,
        "amp": 175.0,
        "freq": 0.0020,
        "bump_amp": 24.0,
        "checkpoints": [
            {"dist": 400.0, "en": "Aralvaimozhi Pass", "ta": "ஆரல்வாய்மொழி கணவாய்"},
            {"dist": 800.0, "en": "Muppandal Wind Farm", "ta": "முப்பந்தல் காற்றாலை பண்ணை"},
            {"dist": 1200.0, "en": "Valliyur Junction", "ta": "வள்ளியூர் சந்திப்பு"},
            {"dist": 1500.0, "en": "Tirunelveli Gateway", "ta": "திருநெல்வேலி நுழைவு"}
        ],
        "props": [
            {"dist": 200.0, "prop": "tea_shop"},
            {"dist": 450.0, "prop": "sign_kanyakumari"},
            {"dist": 780.0, "prop": "bollard"},
            {"dist": 1150.0, "prop": "lamp_post"}
        ]
    },
    {
        "id": "stage_03_tirunelveli",
        "name_en": "Tirunelveli Plains",
        "name_ta": "திருநெல்வேலி சமவெளி",
        "subtitle_en": "Halwa Town & Thamirabarani Valley",
        "length": 1800.0,
        "biome": "plains",
        "difficulty": 1.6,
        "seed": 3003,
        "amp": 150.0,
        "freq": 0.0017,
        "bump_amp": 20.0,
        "checkpoints": [
            {"dist": 450.0, "en": "Thamirabarani Bridge", "ta": "தாமிரபரணி பாலம்"},
            {"dist": 900.0, "en": "Gangaikondan Sanctuary", "ta": "கங்கைகொண்டான் காப்பகம்"},
            {"dist": 1350.0, "en": "Kovilpatti Highway", "ta": "கோவில்பட்டி நெடுஞ்சாலை"},
            {"dist": 1800.0, "en": "Sattur Toll Gate", "ta": "சாத்தூர் சுங்கச்சாவடி"}
        ],
        "props": [
            {"dist": 220.0, "prop": "tea_shop"},
            {"dist": 500.0, "prop": "stone_wall"},
            {"dist": 920.0, "prop": "sign_kanyakumari"},
            {"dist": 1400.0, "prop": "bollard"}
        ]
    },
    {
        "id": "stage_04_madurai",
        "name_en": "Madurai Temple City",
        "name_ta": "மதுரை கோயில் நகரம்",
        "subtitle_en": "The Ancient City of Meenakshi",
        "length": 2100.0,
        "biome": "temple_city",
        "difficulty": 1.9,
        "seed": 4004,
        "amp": 185.0,
        "freq": 0.0021,
        "bump_amp": 26.0,
        "checkpoints": [
            {"dist": 500.0, "en": "Tirupparankunram Hill", "ta": "திருப்பரங்குன்றம் மலை"},
            {"dist": 1050.0, "en": "Vaigai River Crossing", "ta": "வைகை ஆற்றுப் பாலம்"},
            {"dist": 1600.0, "en": "Meenakshi Skyline View", "ta": "மீனாட்சி கோபுரப் பார்வை"},
            {"dist": 2100.0, "en": "Dindigul Boundary", "ta": "திண்டுக்கல் எல்லை"}
        ],
        "props": [
            {"dist": 250.0, "prop": "sign_kanyakumari"},
            {"dist": 600.0, "prop": "tea_shop"},
            {"dist": 1100.0, "prop": "lamp_post"},
            {"dist": 1650.0, "prop": "stone_wall"}
        ]
    },
    {
        "id": "stage_05_trichy",
        "name_en": "Trichy Rockfort",
        "name_ta": "திருச்சி மலைக்கோட்டை",
        "subtitle_en": "Cauvery Riverbed & Historic Fort",
        "length": 2400.0,
        "biome": "river_valley",
        "difficulty": 2.2,
        "seed": 5005,
        "amp": 200.0,
        "freq": 0.0022,
        "bump_amp": 28.0,
        "checkpoints": [
            {"dist": 600.0, "en": "Manapparai Murukku Way", "ta": "மணப்பாறை வழி"},
            {"dist": 1200.0, "en": "Grand Anicut Canal", "ta": "கல்லணை வாய்க்கால்"},
            {"dist": 1800.0, "en": "Rockfort Vista", "ta": "மலைக்கோட்டை காட்சி"},
            {"dist": 2400.0, "en": "Samayapuram Gate", "ta": "சமயபுரம் நுழைவு"}
        ],
        "props": [
            {"dist": 300.0, "prop": "tea_shop"},
            {"dist": 700.0, "prop": "stone_wall"},
            {"dist": 1250.0, "prop": "sign_kanyakumari"},
            {"dist": 1850.0, "prop": "lamp_post"}
        ]
    },
    {
        "id": "stage_06_villupuram",
        "name_en": "Villupuram NH44",
        "name_ta": "விழுப்புரம் தேசிய நெடுஞ்சாலை",
        "subtitle_en": "Grand South Trunk Expressway",
        "length": 2700.0,
        "biome": "highway",
        "difficulty": 2.5,
        "seed": 6006,
        "amp": 160.0,
        "freq": 0.0015,
        "bump_amp": 22.0,
        "checkpoints": [
            {"dist": 650.0, "en": "Ulundurpet Junction", "ta": "உளுந்தூர்பேட்டை சந்திப்பு"},
            {"dist": 1350.0, "en": "Villupuram Toll Plaza", "ta": "விழுப்புரம் சுங்கச்சாவடி"},
            {"dist": 2000.0, "en": "Tindivanam Interchange", "ta": "திண்டிவனம் இணைப்பு"},
            {"dist": 2700.0, "en": "Chengalpattu Border", "ta": "செங்கல்பட்டு எல்லை"}
        ],
        "props": [
            {"dist": 350.0, "prop": "sign_kanyakumari"},
            {"dist": 800.0, "prop": "tea_shop"},
            {"dist": 1400.0, "prop": "bollard"},
            {"dist": 2100.0, "prop": "lamp_post"}
        ]
    },
    {
        "id": "stage_07_chennai",
        "name_en": "Chennai Marina",
        "name_ta": "சென்னை மெரினா கடற்கரை",
        "subtitle_en": "The Finish Line at Marina Promenade",
        "length": 3000.0,
        "biome": "marina",
        "difficulty": 2.8,
        "seed": 7007,
        "amp": 190.0,
        "freq": 0.0019,
        "bump_amp": 25.0,
        "checkpoints": [
            {"dist": 750.0, "en": "Tambaram Outer Ring", "ta": "தாம்பரம் வெளிச்சுற்று"},
            {"dist": 1500.0, "en": "Guindy Kathipara Flyover", "ta": "கிண்டி கத்திப்பாரா மேம்பாலம்"},
            {"dist": 2250.0, "en": "Santhome Cathedral", "ta": "சாந்தோம் பேராலயம்"},
            {"dist": 3000.0, "en": "Marina Beach Victory Gate", "ta": "மெரினா கடற்கரை வெற்றி வாயில்"}
        ],
        "props": [
            {"dist": 400.0, "prop": "tea_shop"},
            {"dist": 900.0, "prop": "sign_kanyakumari"},
            {"dist": 1600.0, "prop": "lamp_post"},
            {"dist": 2300.0, "prop": "stone_wall"}
        ]
    }
]

os.makedirs("data/stages", exist_ok=True)

for st in stages:
    path = f"data/stages/{st['id']}.tres"
    
    # Format checkpoints array
    cp_lines = []
    for cp in st["checkpoints"]:
        cp_lines.append(f'{{"distance": {cp["dist"]}, "name_en": "{cp["en"]}", "name_ta": "{cp["ta"]}"}}')
    checkpoints_str = "[\n\t" + ",\n\t".join(cp_lines) + "\n]"
    
    # Format props array
    pr_lines = []
    for pr in st["props"]:
        pr_lines.append(f'{{"distance": {pr["dist"]}, "prop_type": "{pr["prop"]}"}}')
    props_str = "[\n\t" + ",\n\t".join(pr_lines) + "\n]"
    
    content = f'''[gd_resource type="Resource" script_class="StageData" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/data/StageData.gd" id="1_stage"]

[resource]
script = ExtResource("1_stage")
id = "{st['id']}"
stage_name_en = "{st['name_en']}"
stage_name_ta = "{st['name_ta']}"
subtitle_en = "{st['subtitle_en']}"
length_meters = {st['length']}
biome = "{st['biome']}"
difficulty = {st['difficulty']}
terrain_seed = {st['seed']}
hill_amplitude = {st['amp']}
hill_frequency = {st['freq']}
bump_amplitude = {st['bump_amp']}
coin_density = 120.0
fuel_interval_meters = 320.0
checkpoints = {checkpoints_str}
landmark_props = {props_str}
'''
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated {path}")

print("All 7 stage resources generated successfully!")
