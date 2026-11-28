#!/usr/bin/env python3
"""
gen_v2_telangana.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates the complete Telangana asset collection in asset_collection_v2/telangana/:
  - Hyderabad (Landmarks, Buildings, Vegetation, Props, Backgrounds)
  - Warangal (Landmarks, Buildings, Vegetation, Backgrounds)
  - Ramappa & North (Landmarks, Buildings, Vegetation, Backgrounds)
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
# 1. HYDERABAD LANDMARKS
# ==============================================================================

def generate_hyderabad_landmarks():
    print("\n--- Generating Hyderabad Landmarks ---")

    # 1. Charminar (LOC-TS-04) - 1591 CE Monumental Four-Minaret Archway
    surf, ctx = create_surface(460, 560)
    draw_ground_shadow(ctx, 230, 545, 420, 26)
    # Square granite base structure with 4 colossal pointed arches
    ctx.set_source_rgb(0.72, 0.68, 0.62) # Weathered Deccan granite and lime mortar
    ctx.rectangle(90, 220, 280, 310)
    ctx.fill()
    # 4 Grand Pointed Arches (facing the cardinal directions)
    draw_archway(ctx, 140, 270, 180, 260, (0.85, 0.82, 0.76), (0.18, 0.16, 0.15))
    # Double balcony galleries on upper storeys with stucco clock faces
    ctx.set_source_rgb(0.80, 0.76, 0.70)
    ctx.rectangle(80, 160, 300, 60)
    ctx.fill()
    # Clock face medallion
    ctx.set_source_rgb(0.95, 0.95, 0.95)
    ctx.arc(230, 190, 18, 0, 2 * math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.20, 0.20, 0.20)
    ctx.set_line_width(2)
    ctx.arc(230, 190, 18, 0, 2 * math.pi)
    ctx.stroke()
    # 4 Monumental Fluted Minarets (48.7 meters high with 3 carved gallery rings)
    for mx in [90, 370]: # Left and right minarets visible in 2D projection
        ctx.set_source_rgb(0.75, 0.72, 0.65)
        ctx.rectangle(mx - 20, 60, 40, 470)
        ctx.fill()
        # Gallery balconies (3 rings)
        for gy in [110, 180, 260]:
            ctx.set_source_rgb(0.88, 0.85, 0.78)
            ctx.rectangle(mx - 25, gy, 50, 12)
            ctx.fill()
        # Bulbous dome cupola with brass finial on minaret apex
        draw_chhatri_dome(ctx, mx, 60, 22, 28, (0.82, 0.78, 0.70), (0.95, 0.85, 0.20))
    save_surface(surf, "telangana/hyderabad/landmarks/hyderabad_charminar.png")

    # 2. Golconda Fort Bastion & Balahissar (LOC-TS-01)
    surf, ctx = create_surface(520, 380)
    draw_ground_shadow(ctx, 260, 365, 480, 26)
    # Natural Deccan granite boulder bedrock
    ctx.set_source_rgb(0.38, 0.36, 0.34)
    ctx.move_to(30, 365)
    ctx.line_to(90, 240)
    ctx.line_to(200, 210)
    ctx.line_to(360, 225)
    ctx.line_to(470, 365)
    ctx.close_path()
    ctx.fill()
    # Cyclopean granite ramparts and crenellations
    ctx.set_source_rgb(0.48, 0.46, 0.42)
    ctx.rectangle(70, 110, 380, 130)
    ctx.fill()
    # Acoustic Balahissar entrance gateway with teak spikes
    draw_archway(ctx, 200, 160, 120, 180, (0.60, 0.58, 0.52), (0.15, 0.14, 0.12))
    # Balahissar royal durbar pavilion at the summit
    ctx.set_source_rgb(0.65, 0.62, 0.55)
    ctx.rectangle(180, 60, 160, 50)
    ctx.fill()
    draw_chhatri_dome(ctx, 260, 60, 30, 35, (0.70, 0.66, 0.58), (0.95, 0.85, 0.20))
    save_surface(surf, "telangana/hyderabad/landmarks/golconda_fort_bastion.png")

    # 3. Hussain Sagar Monolithic Buddha Statue (LOC-TS-08)
    surf, ctx = create_surface(360, 540)
    draw_ground_shadow(ctx, 180, 525, 320, 24)
    # Gibraltar Rock island plinth in Hussain Sagar Lake
    ctx.set_source_rgb(0.32, 0.33, 0.36)
    ctx.rectangle(80, 430, 200, 95)
    ctx.fill()
    # Lotus pedestal (Padmasana)
    ctx.set_source_rgb(0.85, 0.45, 0.55) # Pink lotus petals
    for lx in range(95, 270, 28):
        ctx.arc(lx, 430, 16, math.pi, 2 * math.pi)
        ctx.fill()
    # 58-ft 350-tonne monolithic white granite standing Buddha
    ctx.set_source_rgb(0.92, 0.94, 0.96) # White granite
    # Flowing monastic robe drapery (Sanghati)
    ctx.rectangle(130, 200, 100, 220)
    ctx.fill()
    # Abhaya Mudra (Right hand raised granting protection & peace)
    ctx.set_source_rgb(0.88, 0.90, 0.92)
    ctx.rectangle(110, 230, 22, 60)
    ctx.fill()
    # Serene face with elongated earlobes and curly topknot ushnisha
    ctx.set_source_rgb(0.94, 0.95, 0.98)
    ctx.arc(180, 140, 30, 0, 2 * math.pi)
    ctx.fill()
    ctx.arc(180, 105, 14, 0, 2 * math.pi) # Ushnisha
    ctx.fill()
    save_surface(surf, "telangana/hyderabad/landmarks/hussain_sagar_buddha.png")

# ==============================================================================
# 2. WARANGAL LANDMARKS
# ==============================================================================

def generate_warangal_landmarks():
    print("\n--- Generating Warangal Landmarks ---")

    # 1. Kakatiya Kala Thoranam (Warangal Gate - LOC-TS-02) - Monolithic Black Granite Arch
    surf, ctx = create_surface(450, 380)
    draw_ground_shadow(ctx, 225, 365, 410, 24)
    # Monolithic chiseled black dolerite granite pillars
    ctx.set_source_rgb(0.20, 0.22, 0.24) # Black dolerite stone
    ctx.rectangle(90, 90, 35, 260)
    ctx.rectangle(325, 90, 35, 260)
    ctx.fill()
    # Intricate pillar capitals with crouching yalis and lotus garlands
    ctx.set_source_rgb(0.28, 0.30, 0.34)
    ctx.rectangle(80, 80, 55, 16)
    ctx.rectangle(315, 80, 55, 16)
    ctx.fill()
    # Iconic multi-tiered decorative arch lintel with mythical Hamsa swans & Makara gargoyles
    ctx.set_source_rgb(0.22, 0.24, 0.26)
    ctx.rectangle(70, 45, 310, 35)
    ctx.fill()
    # Central swan (Hamsa) and lotus crest (State Emblem of Telangana)
    ctx.set_source_rgb(0.35, 0.38, 0.42)
    ctx.arc(225, 55, 20, 0, 2 * math.pi)
    ctx.fill()
    # Hanging stone bells and festoons
    for bx in range(120, 340, 35):
        ctx.arc(bx, 88, 8, 0, math.pi)
        ctx.fill()
    save_surface(surf, "telangana/warangal/landmarks/kakatiya_kala_thoranam.png")

    # 2. Thousand Pillar Temple (Rudreswara Swamy - LOC-TS-03)
    surf, ctx = create_surface(480, 340)
    draw_ground_shadow(ctx, 240, 325, 440, 24)
    # Star-shaped trikuta stone plinth plinth
    draw_stone_steps(ctx, 50, 320, 380, 30, 3, (0.42, 0.40, 0.38), (0.28, 0.26, 0.25))
    # Low-profile stepped stone sanctum
    ctx.set_source_rgb(0.38, 0.36, 0.35)
    ctx.rectangle(80, 160, 320, 130)
    ctx.fill()
    # Closely spaced chiseled black acoustic stone pillars (1,000 pillars)
    draw_pillared_veranda(ctx, 95, 175, 290, 115, 10, 8, (0.22, 0.24, 0.26), (0.18, 0.19, 0.20))
    # Monolithic carved black basalt Nandi bull pavilion in foreground
    ctx.set_source_rgb(0.18, 0.19, 0.22) # Polished black basalt Nandi
    ctx.arc(380, 270, 24, 0, 2 * math.pi)
    ctx.fill()
    ctx.arc(360, 260, 14, 0, 2 * math.pi) # Nandi head
    ctx.fill()
    save_surface(surf, "telangana/warangal/landmarks/thousand_pillar_temple.png")

# ==============================================================================
# 3. RAMAPPA & NORTH TELANGANA LANDMARKS
# ==============================================================================

def generate_ramappa_landmarks():
    print("\n--- Generating Ramappa Landmarks ---")

    # 1. Ramappa Temple (Rudreswara - UNESCO World Heritage - LOC-TS-15)
    surf, ctx = create_surface(480, 360)
    draw_ground_shadow(ctx, 240, 345, 440, 24)
    # 6-foot high star-shaped cruciform sandstone platform (Upapitha)
    draw_stone_steps(ctx, 50, 340, 380, 35, 4, (0.75, 0.55, 0.38), (0.55, 0.38, 0.25))
    # Reddish sandstone sanctum walls with carved bracket figures (Madanikas)
    ctx.set_source_rgb(0.70, 0.48, 0.32)
    ctx.rectangle(100, 170, 280, 135)
    ctx.fill()
    # Fluted black dolerite pillars
    draw_pillared_veranda(ctx, 115, 185, 250, 120, 7, 10, (0.22, 0.24, 0.26), (0.18, 0.19, 0.20))
    # Lightweight sponge porous floating brick shikhara pyramid roof
    for s in range(6):
        sw = 220 - s * 28
        sy = 170 - (s + 1) * 18
        sx = 240 - sw / 2
        ctx.set_source_rgb(0.78 - s * 0.02, 0.42 - s * 0.02, 0.28 - s * 0.02) # Porous terracotta brick
        ctx.rectangle(sx, sy, sw, 18)
        ctx.fill()
    # Golden Kalasam summit
    ctx.set_source_rgb(0.98, 0.82, 0.15)
    ctx.arc(240, 52, 9, 0, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "telangana/ramappa/landmarks/ramappa_temple_rudreswara.png")

    # 2. Laknavaram Lake Suspension Bridge (LOC-TS-18)
    surf, ctx = create_surface(500, 240)
    draw_ground_shadow(ctx, 250, 225, 460, 20)
    # Emerald lake waters surrounding green islands
    ctx.set_source_rgb(0.20, 0.52, 0.45)
    ctx.rectangle(20, 180, 460, 45)
    ctx.fill()
    # Steel suspension bridge A-frame pylons
    ctx.set_source_rgb(0.85, 0.25, 0.20) # Bright red steel suspension towers
    ctx.rectangle(80, 60, 14, 140)
    ctx.rectangle(400, 60, 14, 140)
    ctx.fill()
    # Main catenary suspension cable
    ctx.set_source_rgb(0.25, 0.28, 0.32)
    ctx.set_line_width(3)
    ctx.move_to(30, 160)
    ctx.line_to(87, 65)
    ctx.curve_to(180, 160, 300, 160, 407, 65)
    ctx.line_to(470, 160)
    ctx.stroke()
    # Wooden pedestrian walkway deck
    ctx.set_source_rgb(0.55, 0.40, 0.25)
    ctx.rectangle(30, 155, 440, 14)
    ctx.fill()
    save_surface(surf, "telangana/ramappa/landmarks/laknavaram_suspension_bridge.png")

# ==============================================================================
# 4. TELANGANA SUPPORTING SCENERY
# ==============================================================================

def generate_telangana_scenery():
    print("\n--- Generating Telangana Supporting Scenery ---")

    # Buildings (Deccan Granite Stone Home, Nizam Arch Villa, Warangal Tiled House)
    bldgs = [
        ("house_telangana_deccan_granite.png", 240, 170, (0.55, 0.52, 0.48)),
        ("house_telangana_nizam_courtyard.png", 260, 180, (0.92, 0.88, 0.80)),
        ("house_telangana_warangal_tiled.png", 230, 165, (0.85, 0.65, 0.45)),
        ("house_telangana_hyderabadi_arch.png", 250, 175, (0.90, 0.85, 0.78)),
        ("house_telangana_rural_hut.png", 200, 140, (0.72, 0.55, 0.38)),
        ("house_telangana_plateau_masonry.png", 220, 155, (0.62, 0.58, 0.52))
    ]
    for bname, w, h, col in bldgs:
        surf, ctx = create_surface(w, h)
        draw_ground_shadow(ctx, w/2, h - 8, w - 20, 14)
        ctx.set_source_rgb(*col)
        ctx.rectangle(20, h - 95, w - 40, 85)
        ctx.fill()
        draw_sloping_roof(ctx, 15, h - 145, w - 30, 50, 10, (0.68, 0.32, 0.20), (0.42, 0.16, 0.10))
        save_surface(surf, f"telangana/hyderabad/buildings/{bname}")
        save_surface(surf, f"telangana/warangal/buildings/{bname}")
        save_surface(surf, f"telangana/ramappa/buildings/{bname}")

    # Vegetation (Sitaphal Custard Apple, Flame of the Forest Palash, Red Sanders)
    # 1. Flame of the Forest (Moduga / Palash - Butea monosperma)
    surf, ctx = create_surface(180, 220)
    draw_ground_shadow(ctx, 90, 210, 120, 14)
    ctx.set_source_rgb(0.42, 0.36, 0.30)
    ctx.rectangle(85, 90, 12, 120)
    ctx.fill()
    # Fiery orange-red blossoms covering tree
    ctx.set_source_rgb(0.95, 0.35, 0.12)
    for cx in [60, 90, 120]:
        ctx.arc(cx, 75, 32, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "telangana/hyderabad/vegetation/tree_telangana_flame_of_forest.png")

    # Props (Irani Chai Cafe, Biryani Handi, Granite Boulder)
    surf, ctx = create_surface(160, 130)
    draw_ground_shadow(ctx, 80, 122, 140, 12)
    ctx.set_source_rgb(0.85, 0.78, 0.65) # Irani Chai cafe
    ctx.rectangle(25, 45, 110, 75)
    ctx.fill()
    ctx.set_source_rgb(0.18, 0.45, 0.25) # Green cafe awning
    ctx.rectangle(15, 35, 130, 16)
    ctx.fill()
    # Chai glass and Osmania biscuits
    ctx.set_source_rgb(0.92, 0.85, 0.75)
    ctx.arc(60, 75, 8, 0, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "telangana/hyderabad/roadside_props/shop_telangana_irani_chai.png")

    # Textures (Deccan Granite Rock - Seamless 1024x1024)
    surf, ctx = create_surface(1024, 1024)
    ctx.set_source_rgb(0.42, 0.40, 0.38)
    ctx.paint()
    random.seed(303)
    for _ in range(7000):
        gx = random.randint(0, 1024)
        gy = random.randint(0, 1024)
        c = random.uniform(0.32, 0.55)
        ctx.set_source_rgb(c, c * 0.96, c * 0.92)
        ctx.rectangle(gx, gy, 3, 3)
        ctx.fill()
    save_surface(surf, "telangana/hyderabad/textures/texture_deccan_granite_rock.png")

def main():
    print("==================================================")
    print("STARTING TELANGANA ASSET COLLECTION V2 GENERATION")
    print("==================================================")
    generate_hyderabad_landmarks()
    generate_warangal_landmarks()
    generate_ramappa_landmarks()
    generate_telangana_scenery()
    print("==================================================")
    print("TELANGANA V2 ASSETS GENERATED SUCCESSFULLY!")
    print("==================================================")

if __name__ == "__main__":
    main()
