#!/usr/bin/env python3
"""
build_seamless_heaven_corridor.py
Generates the master 3200x720 seamless architectural corridor texture
for the Heaven Environment in Endless Hill Climb.
Integrates authentic Zoeluci assets into 5 distinct architectural bays.
Eliminates all flat unshaded geometry boxes and crude PIL arcs.
"""

import os, math
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance

BASE_DIR = "/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/Endless-Hillclimb-Fixed"
TARGET_DIR = os.path.join(BASE_DIR, "assets/environments/heaven/architecture")
DECOR_DIR = os.path.join(BASE_DIR, "assets/environments/heaven/decorations")
ZOELUCI_DIR = "/home/danny/DUMB-SPOT/full_assets/Heaven/Architecture_01/extracted/golden_palace_interior"
ANGEL_SRC = "/home/danny/DUMB-SPOT/full_assets/Heaven/Remaining_Batch/Angels/angel_cutout_ivory_gold.png"

# Load source assets
col_master = Image.open(os.path.join(ZOELUCI_DIR, "Column.png")).convert("RGBA")
win_master = Image.open(os.path.join(ZOELUCI_DIR, "Window.png")).convert("RGBA")
ceil_master = Image.open(os.path.join(ZOELUCI_DIR, "Ceiling.png")).convert("RGBA")
floor_master = Image.open(os.path.join(ZOELUCI_DIR, "Floor.png")).convert("RGBA")
wall_master = Image.open(os.path.join(ZOELUCI_DIR, "Wall.png")).convert("RGBA")

rose_module = Image.open(os.path.join(TARGET_DIR, "heaven_palace_module_rose_window.png")).convert("RGBA")
door_master = Image.open(os.path.join(TARGET_DIR, "heaven_palace_grand_door.png")).convert("RGBA")
fountain_master = Image.open(os.path.join(TARGET_DIR, "heaven_palace_fountain.png")).convert("RGBA")
angel_master = Image.open(ANGEL_SRC).convert("RGBA")
urn_master = Image.open(os.path.join(DECOR_DIR, "celestial_planter_urn.png")).convert("RGBA")
bed_master = Image.open(os.path.join(DECOR_DIR, "celestial_garden_bed.png")).convert("RGBA")
arch_master = Image.open(os.path.join(TARGET_DIR, "heaven_palace_arch_gateway.png")).convert("RGBA")
pedestal_master = Image.open(os.path.join(DECOR_DIR, "heaven_angel_monument_pedestal.png")).convert("RGBA")

total_w = 3200
total_h = 720
corridor = Image.new("RGBA", (total_w, total_h), (0, 0, 0, 0))

# 1. Base Wall across 3200px (from Y = 25 to Y = 560)
wall_cropped = wall_master.crop((0, 80, 1920, 620)).resize((1920, 535), Image.Resampling.LANCZOS)
for wx in range(0, total_w, 1920):
    corridor.paste(wall_cropped, (wx, 25))

# 2. Continuous Ceiling Beam across 3200px (Y = 0 to 45)
for cx in range(0, total_w, 1920):
    corridor.paste(ceil_master, (cx, 0), ceil_master)

draw = ImageDraw.Draw(corridor)
draw.line([(0, 36), (total_w, 36)], fill=(225, 190, 85, 255), width=3)
draw.line([(0, 42), (total_w, 42)], fill=(255, 245, 175, 255), width=2)

# 3. Continuous Floor Stylobate / Plinth across 3200px (Y = 530 to 720)
for fx in range(0, total_w, 1920):
    corridor.paste(floor_master, (fx, 530), floor_master)
# Tiled marble base tone with gold rim
draw.rectangle([0, 560, total_w, 720], fill=(235, 229, 218, 255))
draw.line([(0, 560), (total_w, 560)], fill=(225, 190, 85, 255), width=3)
draw.line([(0, 564), (total_w, 564)], fill=(185, 175, 158, 255), width=2)

target_col_h = 525
target_col_w = int(col_master.width * (target_col_h / float(col_master.height))) # ~118 px
col_scaled = col_master.resize((target_col_w, target_col_h), Image.Resampling.LANCZOS)

# -------------------------------------------------------------
# Bay 0: Section A — Gateway Colonnade with Window (X = 0 to 640)
# -------------------------------------------------------------
win_h = 360
win_w = int(win_master.width * (win_h / float(win_master.height))) # ~172 px
win_scaled = win_master.resize((win_w, win_h), Image.Resampling.LANCZOS)
corridor.paste(win_scaled, (320 - win_w // 2, 160), win_scaled)

# Scaled real arch framing window
arch_b0_w = 400
arch_b0_h = int(arch_master.height * (arch_b0_w / float(arch_master.width)))
arch_b0_scaled = arch_master.resize((arch_b0_w, arch_b0_h), Image.Resampling.LANCZOS)
corridor.paste(arch_b0_scaled, (320 - arch_b0_w // 2, 45), arch_b0_scaled)

corridor.paste(col_scaled, (130 - target_col_w // 2, 28), col_scaled)
corridor.paste(col_scaled, (510 - target_col_w // 2, 28), col_scaled)

urn_scaled = urn_master.resize((50, 68), Image.Resampling.LANCZOS)
corridor.paste(urn_scaled, (130 - 25, 500), urn_scaled)
corridor.paste(urn_scaled, (510 - 25, 500), urn_scaled)

# -------------------------------------------------------------
# Bay 1: Section B — Rose Window Architectural Module (X = 640 to 1280)
# -------------------------------------------------------------
rose_h = 510
rose_w = int(rose_module.width * (rose_h / float(rose_module.height))) # ~348 px
rose_scaled = rose_module.resize((rose_w, rose_h), Image.Resampling.LANCZOS)
corridor.paste(rose_scaled, (960 - rose_w // 2, 38), rose_scaled)

corridor.paste(col_scaled, (730 - target_col_w // 2, 28), col_scaled)
corridor.paste(col_scaled, (1190 - target_col_w // 2, 28), col_scaled)

bed_scaled = bed_master.resize((140, 44), Image.Resampling.LANCZOS)
corridor.paste(bed_scaled, (960 - 70, 520), bed_scaled)

# -------------------------------------------------------------
# Bay 2: Section C — Ceremonial Fountain Plaza (X = 1280 to 1920)
# -------------------------------------------------------------
side_win_h = 280
side_win_w = int(win_master.width * (side_win_h / float(win_master.height)))
side_win_scaled = win_master.resize((side_win_w, side_win_h), Image.Resampling.LANCZOS)
corridor.paste(side_win_scaled, (1420 - side_win_w // 2, 190), side_win_scaled)
corridor.paste(side_win_scaled, (1780 - side_win_w // 2, 190), side_win_scaled)

# Grand archway framing fountain
arch_b2_w = 460
arch_b2_h = int(arch_master.height * (arch_b2_w / float(arch_master.width)))
arch_b2_scaled = arch_master.resize((arch_b2_w, arch_b2_h), Image.Resampling.LANCZOS)
corridor.paste(arch_b2_scaled, (1600 - arch_b2_w // 2, 45), arch_b2_scaled)

fount_h = 290
fount_w = int(fountain_master.width * (fount_h / float(fountain_master.height)))
fount_scaled = fountain_master.resize((fount_w, fount_h), Image.Resampling.LANCZOS)
corridor.paste(fount_scaled, (1600 - fount_w // 2, 270), fount_scaled)

corridor.paste(col_scaled, (1370 - target_col_w // 2, 28), col_scaled)
corridor.paste(col_scaled, (1830 - target_col_w // 2, 28), col_scaled)
corridor.paste(urn_scaled, (1370 - 25, 500), urn_scaled)
corridor.paste(urn_scaled, (1830 - 25, 500), urn_scaled)

# -------------------------------------------------------------
# Bay 3: Section D — Grand Entrance Portal (X = 1920 to 2560)
# NO FLAT WHITE RECTANGLE. Authentic archway and grand portal door.
# -------------------------------------------------------------
door_h = 420
door_w = int(door_master.width * (door_h / float(door_master.height)))
door_scaled = door_master.resize((door_w, door_h), Image.Resampling.LANCZOS)

# Frame the grand portal with the high-res golden arch
arch_b3_w = 480
arch_b3_h = int(arch_master.height * (arch_b3_w / float(arch_master.width)))
arch_b3_scaled = arch_master.resize((arch_b3_w, arch_b3_h), Image.Resampling.LANCZOS)
corridor.paste(arch_b3_scaled, (2240 - arch_b3_w // 2, 42), arch_b3_scaled)
corridor.paste(door_scaled, (2240 - door_w // 2, 135), door_scaled)

corridor.paste(col_scaled, (2000 - target_col_w // 2, 28), col_scaled)
corridor.paste(col_scaled, (2480 - target_col_w // 2, 28), col_scaled)
corridor.paste(urn_scaled, (2000 - 25, 500), urn_scaled)
corridor.paste(urn_scaled, (2480 - 25, 500), urn_scaled)

# -------------------------------------------------------------
# Bay 4: Section E — Angel Monument Terrace (X = 2560 to 3200)
# Deep architectural niche with rich contrast, authentic ivory-gold angel, zero doves.
# -------------------------------------------------------------
arch_b4_w = 440
arch_b4_h = int(arch_master.height * (arch_b4_w / float(arch_master.width)))
arch_b4_scaled = arch_master.resize((arch_b4_w, arch_b4_h), Image.Resampling.LANCZOS)

# Soft shadow inside the alcove behind the angel to provide rich contrast
niche_shadow = Image.new("RGBA", (280, 420), (0, 0, 0, 0))
niche_draw = ImageDraw.Draw(niche_shadow)
niche_draw.rounded_rectangle([0, 0, 280, 420], radius=140, fill=(30, 25, 20, 60))
niche_shadow = niche_shadow.filter(ImageFilter.GaussianBlur(16))
corridor.paste(niche_shadow, (2880 - 140, 80), niche_shadow)

corridor.paste(arch_b4_scaled, (2880 - arch_b4_w // 2, 45), arch_b4_scaled)

# Classical Pedestal for the Angel Monument
ped_w = 160
ped_h = int(pedestal_master.height * (ped_w / float(pedestal_master.width)))
ped_scaled = pedestal_master.resize((ped_w, ped_h), Image.Resampling.LANCZOS)
corridor.paste(ped_scaled, (2880 - ped_w // 2, 460), ped_scaled)

# Ivory and Gold Angel Statue standing proudly on pedestal
angel_h = 280
angel_w = int(angel_master.width * (angel_h / float(angel_master.height)))
angel_scaled = angel_master.resize((angel_w, angel_h), Image.Resampling.LANCZOS)
corridor.paste(angel_scaled, (2880 - angel_w // 2, 460 - angel_h + 10), angel_scaled)

corridor.paste(col_scaled, (2660 - target_col_w // 2, 28), col_scaled)
corridor.paste(col_scaled, (3100 - target_col_w // 2, 28), col_scaled)
corridor.paste(bed_scaled, (2880 - 70, 520), bed_scaled)

# Boundary columns at 0 and 3200 for seamless looping
for bx in [0, 3200]:
    corridor.paste(col_scaled, (bx - target_col_w // 2, 28), col_scaled)

out_master = os.path.join(TARGET_DIR, "heaven_palace_corridor_seamless.png")
corridor.save(out_master)
print("✓ Successfully generated master seamless corridor:", out_master)
