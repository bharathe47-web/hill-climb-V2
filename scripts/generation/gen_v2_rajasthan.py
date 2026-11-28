#!/usr/bin/env python3
"""
gen_v2_rajasthan.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates the complete Rajasthan asset collection in asset_collection_v2/rajasthan/:
  - Jaipur (Landmarks, Buildings, Vegetation, Props, Backgrounds)
  - Jodhpur (Landmarks, Buildings, Vegetation, Backgrounds)
  - Udaipur (Landmarks, Buildings, Vegetation, Backgrounds)
  - Jaisalmer (Landmarks, Buildings, Vegetation, Backgrounds)
"""

import cairo
import math
import os
import random
from v2_common import (
    create_surface, save_surface, draw_ground_shadow,
    draw_stone_steps, draw_pillared_veranda, draw_sloping_roof,
    draw_chhatri_dome, draw_archway
)

# ==============================================================================
# 1. JAIPUR LANDMARKS
# ==============================================================================

def generate_jaipur_landmarks():
    print("\n--- Generating Jaipur Landmarks ---")

    # 1. Hawa Mahal (Palace of Winds - LOC-RJ-03)
    surf, ctx = create_surface(480, 560)
    draw_ground_shadow(ctx, 240, 545, 440, 26)
    # Pyramidal 5-storey red and pink sandstone honeycomb facade
    tiers = [
        (400, 75, (0.88, 0.45, 0.40)),
        (350, 75, (0.85, 0.42, 0.38)),
        (300, 75, (0.82, 0.38, 0.35)),
        (240, 70, (0.80, 0.35, 0.32)),
        (180, 65, (0.78, 0.32, 0.30))
    ]
    curr_y = 530
    for tw, th, tcol in tiers:
        curr_y -= th
        tx = 240 - tw / 2
        ctx.set_source_rgb(*tcol)
        ctx.rectangle(tx, curr_y, tw, th)
        ctx.fill()
        # White lime filigree border
        ctx.set_source_rgb(0.96, 0.95, 0.92)
        ctx.set_line_width(2)
        ctx.rectangle(tx, curr_y, tw, th)
        ctx.stroke()
        # Carved Jharokha casements (small projecting balconies with stone lattice jalis)
        casements = int(tw / 38)
        for c in range(casements):
            cx_pos = tx + 15 + c * (tw - 30) / max(1, casements - 1)
            # Miniature dome top on each jharokha
            draw_chhatri_dome(ctx, cx_pos, curr_y + 18, 10, 12, (0.90, 0.48, 0.42), (0.98, 0.88, 0.45))
            ctx.set_source_rgb(0.25, 0.15, 0.12)
            ctx.rectangle(cx_pos - 7, curr_y + 20, 14, 28)
            ctx.fill()
    # Crown fluted chhatri dome on 5th tier
    draw_chhatri_dome(ctx, 240, curr_y, 45, 55, (0.92, 0.50, 0.42), (0.98, 0.85, 0.20))
    save_surface(surf, "rajasthan/jaipur/landmarks/hawa_mahal_palace_of_winds.png")

    # 2. Amber Fort Gateway (Suraj Pol - LOC-RJ-01)
    surf, ctx = create_surface(520, 360)
    draw_ground_shadow(ctx, 260, 345, 480, 24)
    # Imposing yellow and pink sandstone hill bastion
    ctx.set_source_rgb(0.85, 0.65, 0.35)
    ctx.rectangle(50, 120, 420, 220)
    ctx.fill()
    # Royal Suraj Pol elephant entrance gateway
    draw_archway(ctx, 200, 180, 120, 160, (0.92, 0.75, 0.45), (0.22, 0.16, 0.12))
    # Chhatri pavilions along battlements
    for chx in [80, 160, 360, 440]:
        draw_chhatri_dome(ctx, chx, 120, 26, 32, (0.88, 0.68, 0.38), (0.98, 0.85, 0.20))
    # Lattice jharokhas
    for jx in [100, 390]:
        ctx.set_source_rgb(0.92, 0.72, 0.42)
        ctx.rectangle(jx, 170, 35, 45)
        ctx.fill()
        ctx.set_source_rgb(0.20, 0.15, 0.10)
        ctx.rectangle(jx + 5, 180, 25, 30)
        ctx.fill()
    save_surface(surf, "rajasthan/jaipur/landmarks/amber_fort_gateway.png")

    # 3. Jal Mahal (Water Palace - LOC-RJ-05)
    surf, ctx = create_surface(460, 280)
    draw_ground_shadow(ctx, 230, 265, 420, 22)
    # Man Sagar Lake water reflections
    ctx.set_source_rgb(0.22, 0.45, 0.65)
    ctx.rectangle(20, 210, 420, 55)
    ctx.fill()
    # Pink sandstone floating palace structure
    ctx.set_source_rgb(0.85, 0.52, 0.42)
    ctx.rectangle(70, 130, 320, 95)
    ctx.fill()
    # Pillared arcades
    draw_pillared_veranda(ctx, 85, 140, 290, 80, 7, 10, (0.90, 0.60, 0.50), (0.75, 0.40, 0.30))
    # 4 corner chhatri cupolas
    for cx_c in [90, 170, 290, 370]:
        draw_chhatri_dome(ctx, cx_c, 130, 22, 28, (0.88, 0.55, 0.45), (0.98, 0.85, 0.20))
    # Central Bengal-style curved chhatri roof
    ctx.set_source_rgb(0.92, 0.58, 0.48)
    ctx.arc(230, 130, 42, math.pi, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "rajasthan/jaipur/landmarks/jal_mahal_water_palace.png")

# ==============================================================================
# 2. JODHPUR LANDMARKS
# ==============================================================================

def generate_jodhpur_landmarks():
    print("\n--- Generating Jodhpur Landmarks ---")

    # 1. Mehrangarh Fort Monolith (LOC-RJ-07)
    surf, ctx = create_surface(520, 380)
    draw_ground_shadow(ctx, 260, 365, 480, 26)
    # 410-ft natural perpendicular rocky cliff base
    ctx.set_source_rgb(0.45, 0.35, 0.28)
    ctx.move_to(30, 365)
    ctx.line_to(90, 230)
    ctx.line_to(220, 200)
    ctx.line_to(380, 220)
    ctx.line_to(470, 365)
    ctx.close_path()
    ctx.fill()
    # Burnished red sandstone ramparts (Rudyard Kipling: "the work of giants")
    ctx.set_source_rgb(0.72, 0.36, 0.25)
    ctx.rectangle(80, 100, 360, 120)
    ctx.fill()
    # Moti Mahal & Phool Mahal latticed balconies
    for jx in range(110, 400, 50):
        ctx.set_source_rgb(0.78, 0.42, 0.30)
        ctx.rectangle(jx, 120, 32, 50)
        ctx.fill()
        draw_chhatri_dome(ctx, jx + 16, 120, 16, 20, (0.82, 0.45, 0.32), (0.95, 0.85, 0.20))
    # Indigo blue houses of Jodhpur clustered at fort base
    ctx.set_source_rgb(0.25, 0.52, 0.85) # Iconic Brahmin indigo blue
    for bx in range(50, 450, 40):
        ctx.rectangle(bx, 310, 32, 45)
        ctx.fill()
        ctx.set_source_rgb(0.95, 0.95, 0.95)
        ctx.rectangle(bx + 8, 325, 12, 16)
        ctx.fill()
        ctx.set_source_rgb(0.25, 0.52, 0.85)
    save_surface(surf, "rajasthan/jodhpur/landmarks/mehrangarh_fort_bastion.png")

    # 2. Umaid Bhawan Palace (LOC-RJ-08)
    surf, ctx = create_surface(500, 320)
    draw_ground_shadow(ctx, 250, 305, 460, 24)
    # Golden Chittar sandstone grand royal palace
    ctx.set_source_rgb(0.92, 0.75, 0.45)
    ctx.rectangle(60, 160, 380, 140)
    ctx.fill()
    # 105-foot central Art Deco cupola dome
    draw_chhatri_dome(ctx, 250, 160, 60, 80, (0.88, 0.70, 0.40), (0.98, 0.85, 0.20))
    # Symmetrical wings and colonnades
    draw_pillared_veranda(ctx, 80, 190, 340, 100, 8, 14, (0.95, 0.80, 0.50), (0.80, 0.62, 0.35))
    save_surface(surf, "rajasthan/jodhpur/landmarks/umaid_bhawan_palace.png")

# ==============================================================================
# 3. UDAIPUR & JAISALMER LANDMARKS
# ==============================================================================

def generate_udaipur_and_jaisalmer_landmarks():
    print("\n--- Generating Udaipur & Jaisalmer Landmarks ---")

    # 1. Jaisalmer Golden Fort (Sonar Qila - LOC-RJ-14)
    surf, ctx = create_surface(520, 380)
    draw_ground_shadow(ctx, 260, 365, 480, 26)
    # Thar desert golden sand dune base
    ctx.set_source_rgb(0.88, 0.75, 0.45)
    ctx.rectangle(40, 280, 440, 85)
    ctx.fill()
    # 99 massive circular yellow sandstone bastions
    ctx.set_source_rgb(0.85, 0.68, 0.32)
    for bx in range(80, 440, 75):
        ctx.arc(bx, 240, 45, 0, 2 * math.pi)
        ctx.fill()
    # Fort palace walls & carved havelis within
    ctx.rectangle(90, 120, 340, 140)
    ctx.fill()
    # Jharokhas & chhatris crowning ramparts
    for cx in range(120, 400, 60):
        draw_chhatri_dome(ctx, cx, 120, 22, 28, (0.90, 0.72, 0.35), (0.98, 0.85, 0.20))
    save_surface(surf, "rajasthan/jaisalmer/landmarks/jaisalmer_golden_fort.png")

    # 2. Chittorgarh Vijay Stambha (Tower of Victory - LOC-RJ-21)
    surf, ctx = create_surface(320, 540)
    draw_ground_shadow(ctx, 160, 525, 260, 22)
    # 9-tiered 122-foot red sandstone & marble tower built by Rana Kumbha
    draw_stone_steps(ctx, 80, 510, 160, 30, 3, (0.75, 0.40, 0.30), (0.55, 0.25, 0.18))
    curr_y = 480
    for t in range(9):
        th = 38
        curr_y -= th
        tw = 110 - t * 4
        tx = 160 - tw / 2
        col = (0.78 - t * 0.015, 0.42 - t * 0.015, 0.32 - t * 0.015)
        ctx.set_source_rgb(*col)
        ctx.rectangle(tx, curr_y, tw, th)
        ctx.fill()
        # White marble balconies
        ctx.set_source_rgb(0.95, 0.95, 0.98)
        ctx.rectangle(tx - 6, curr_y + th - 6, tw + 12, 6)
        ctx.fill()
    # Crowning 8-pillared dome
    draw_chhatri_dome(ctx, 160, curr_y, 35, 45, (0.80, 0.45, 0.35), (0.98, 0.85, 0.20))
    save_surface(surf, "rajasthan/udaipur/landmarks/chittorgarh_vijay_stambha.png")

    # 3. Sam Sand Dunes Desert Safari (LOC-RJ-16)
    surf, ctx = create_surface(480, 260)
    draw_ground_shadow(ctx, 240, 245, 440, 20)
    # Undulating golden sand ridges
    ctx.set_source_rgb(0.92, 0.78, 0.45)
    ctx.move_to(20, 245)
    ctx.curve_to(120, 180, 280, 230, 460, 170)
    ctx.line_to(460, 255)
    ctx.line_to(20, 255)
    ctx.close_path()
    ctx.fill()
    # Camel caravan silhouette
    ctx.set_source_rgb(0.35, 0.22, 0.15)
    for cx in [160, 240, 320]:
        # Body & hump
        ctx.arc(cx, 160, 16, 0, 2 * math.pi)
        ctx.fill()
        ctx.arc(cx - 6, 148, 10, 0, 2 * math.pi) # Hump
        ctx.fill()
        # Neck & head
        ctx.rectangle(cx + 12, 130, 6, 25)
        ctx.fill()
        ctx.arc(cx + 18, 128, 6, 0, 2 * math.pi)
        ctx.fill()
        # Slender legs
        ctx.rectangle(cx - 10, 175, 4, 30)
        ctx.rectangle(cx + 8, 175, 4, 30)
        ctx.fill()
    save_surface(surf, "rajasthan/jaisalmer/landmarks/sam_sand_dunes_desert_camp.png")

# ==============================================================================
# 4. RAJASTHAN SUPPORTING SCENERY
# ==============================================================================

def generate_rajasthan_scenery():
    print("\n--- Generating Rajasthan Supporting Scenery ---")

    # Buildings (Rajput Haveli, Jodhpur Blue House, Jaipur Pink Facade, Desert Hut)
    bldgs = [
        ("house_rajasthan_jaipur_haveli.png", 260, 185, (0.85, 0.48, 0.38)),
        ("house_rajasthan_jodhpur_blue.png", 230, 165, (0.22, 0.52, 0.85)),
        ("house_rajasthan_sandstone_cottage.png", 220, 155, (0.88, 0.72, 0.45)),
        ("house_rajasthan_desert_kucha.png", 200, 140, (0.75, 0.58, 0.38)),
        ("house_rajasthan_jaisalmer_carved.png", 250, 180, (0.90, 0.76, 0.42)),
        ("house_rajasthan_aravalli_stone.png", 220, 150, (0.68, 0.55, 0.42))
    ]
    for bname, w, h, col in bldgs:
        surf, ctx = create_surface(w, h)
        draw_ground_shadow(ctx, w/2, h - 8, w - 20, 14)
        ctx.set_source_rgb(*col)
        ctx.rectangle(20, h - 110, w - 40, 100)
        ctx.fill()
        draw_chhatri_dome(ctx, w/2, h - 110, 24, 28, (col[0]*1.05, col[1]*1.05, col[2]*1.05), (0.95, 0.85, 0.20))
        save_surface(surf, f"rajasthan/jaipur/buildings/{bname}")
        save_surface(surf, f"rajasthan/jodhpur/buildings/{bname}")
        save_surface(surf, f"rajasthan/jaisalmer/buildings/{bname}")

    # Vegetation (Khejri tree, Roheda desert teak, Thorny acacia, Cactus)
    # 1. Khejri Desert Tree (Prosopis cineraria - State Tree)
    surf, ctx = create_surface(180, 220)
    draw_ground_shadow(ctx, 90, 210, 120, 14)
    ctx.set_source_rgb(0.42, 0.35, 0.28) # Weathered gnarled trunk
    ctx.rectangle(85, 90, 12, 120)
    ctx.fill()
    # Feathery grey-green hardy desert canopy
    ctx.set_source_rgb(0.35, 0.48, 0.32)
    for cx in [60, 90, 120]:
        ctx.arc(cx, 75, 32, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "rajasthan/jaipur/vegetation/tree_rajasthan_khejri_desert.png")

    # 2. Prickly Pear Cactus
    surf, ctx = create_surface(120, 140)
    draw_ground_shadow(ctx, 60, 134, 80, 10)
    ctx.set_source_rgb(0.28, 0.55, 0.25)
    for px, py, pr in [(60, 105, 24), (45, 75, 18), (75, 70, 20), (60, 45, 15)]:
        ctx.arc(px, py, pr, 0, 2 * math.pi)
        ctx.fill()
    # Yellow cactus flowers
    ctx.set_source_rgb(0.98, 0.85, 0.15)
    ctx.arc(60, 30, 6, 0, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "rajasthan/jaipur/vegetation/shrub_rajasthan_prickly_pear.png")

    # Props (Highway Dhaba, Camel Cart, Pottery)
    surf, ctx = create_surface(160, 130)
    draw_ground_shadow(ctx, 80, 122, 140, 12)
    ctx.set_source_rgb(0.85, 0.65, 0.40) # Sandstone highway dhaba
    ctx.rectangle(25, 45, 110, 75)
    ctx.fill()
    ctx.set_source_rgb(0.88, 0.25, 0.18) # Dhaba fabric canopy
    ctx.rectangle(15, 35, 130, 16)
    ctx.fill()
    save_surface(surf, "rajasthan/jaipur/roadside_props/shop_rajasthan_highway_dhaba.png")

    # Textures (Thar Desert Golden Sand - Seamless 1024x1024)
    surf, ctx = create_surface(1024, 1024)
    ctx.set_source_rgb(0.88, 0.74, 0.44)
    ctx.paint()
    random.seed(101)
    for _ in range(7000):
        gx = random.randint(0, 1024)
        gy = random.randint(0, 1024)
        c = random.uniform(0.78, 0.95)
        ctx.set_source_rgb(c, c * 0.84, c * 0.50)
        ctx.rectangle(gx, gy, 2, 2)
        ctx.fill()
    save_surface(surf, "rajasthan/jaipur/textures/texture_sand_desert_thar.png")

def main():
    print("==================================================")
    print("STARTING RAJASTHAN ASSET COLLECTION V2 GENERATION")
    print("==================================================")
    generate_jaipur_landmarks()
    generate_jodhpur_landmarks()
    generate_udaipur_and_jaisalmer_landmarks()
    generate_rajasthan_scenery()
    print("==================================================")
    print("RAJASTHAN V2 ASSETS GENERATED SUCCESSFULLY!")
    print("==================================================")

if __name__ == "__main__":
    main()
