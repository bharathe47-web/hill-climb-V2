#!/usr/bin/env python3
"""
gen_v2_gujarat.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates the complete Gujarat asset collection in asset_collection_v2/gujarat/:
  - Ahmedabad (Landmarks, Buildings, Vegetation, Props, Backgrounds)
  - Modhera & Patan (Landmarks, Buildings, Vegetation, Backgrounds)
  - Kutch (Landmarks, Buildings, Vegetation, Backgrounds)
  - Dwarka & Saurashtra (Landmarks, Buildings, Vegetation, Backgrounds)
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
# 1. AHMEDABAD LANDMARKS
# ==============================================================================

def generate_ahmedabad_landmarks():
    print("\n--- Generating Ahmedabad Landmarks ---")

    # 1. Teen Darwaza (LOC-GJ-00) - 1415 CE Triple Arched Stone Gateway
    surf, ctx = create_surface(460, 320)
    draw_ground_shadow(ctx, 230, 305, 420, 22)
    # Monumental sandstone gateway mass
    ctx.set_source_rgb(0.78, 0.62, 0.42)
    ctx.rectangle(40, 80, 380, 220)
    ctx.fill()
    # 3 grand central semi-circular arched portals
    for idx, ax in enumerate([65, 175, 285]):
        aw = 95
        draw_archway(ctx, ax, 130, aw, 170, (0.88, 0.72, 0.50), (0.22, 0.18, 0.14))
    # Ornate jali stone screen work above arches
    for jx in range(60, 390, 40):
        ctx.set_source_rgb(0.85, 0.70, 0.48)
        ctx.rectangle(jx, 95, 25, 25)
        ctx.fill()
        ctx.set_source_rgb(0.25, 0.20, 0.15)
        ctx.rectangle(jx + 4, 99, 17, 17)
        ctx.fill()
    save_surface(surf, "gujarat/ahmedabad/landmarks/ahmedabad_teen_darwaza.png")

    # 2. Sabarmati Ashram Hridaya Kunj (LOC-GJ-15)
    surf, ctx = create_surface(420, 240)
    draw_ground_shadow(ctx, 210, 225, 380, 20)
    # Peaceful whitewashed cottage with tiled veranda
    ctx.set_source_rgb(0.95, 0.95, 0.96)
    ctx.rectangle(50, 110, 320, 110)
    ctx.fill()
    # Sloping terracotta tiled roof
    draw_sloping_roof(ctx, 35, 60, 350, 55, 12, (0.75, 0.32, 0.20), (0.45, 0.18, 0.10))
    # Wooden spinning wheel (Charkha) on veranda
    ctx.set_source_rgb(0.42, 0.28, 0.18)
    ctx.arc(100, 175, 22, 0, 2 * math.pi)
    ctx.set_line_width(3)
    ctx.stroke()
    ctx.rectangle(100, 195, 45, 6)
    ctx.fill()
    save_surface(surf, "gujarat/ahmedabad/landmarks/sabarmati_ashram_hridaya_kunj.png")

# ==============================================================================
# 2. MODHERA & PATAN LANDMARKS
# ==============================================================================

def generate_modhera_and_patan_landmarks():
    print("\n--- Generating Modhera & Patan Landmarks ---")

    # 1. Modhera Sun Temple & Surya Kund (LOC-GJ-05)
    surf, ctx = create_surface(480, 360)
    draw_ground_shadow(ctx, 240, 345, 440, 24)
    # Surya Kund stepped water reservoir plinths (108 miniature shrines)
    draw_stone_steps(ctx, 40, 340, 400, 50, 5, (0.85, 0.68, 0.42), (0.62, 0.48, 0.28))
    # Solanki style carved sandstone Sabha Mandapam assembly hall
    ctx.set_source_rgb(0.80, 0.65, 0.40)
    ctx.rectangle(110, 160, 260, 130)
    ctx.fill()
    # 52 intricately sculpted pillars (representing 52 weeks of the year)
    draw_pillared_veranda(ctx, 125, 175, 230, 115, 6, 14, (0.90, 0.75, 0.48), (0.70, 0.52, 0.32))
    # Stepped pyramidal roof shikhara
    for r in range(6):
        rw = 240 - r * 30
        ry = 160 - (r + 1) * 16
        rx = 240 - rw / 2
        ctx.set_source_rgb(0.85 - r * 0.02, 0.70 - r * 0.02, 0.45 - r * 0.02)
        ctx.rectangle(rx, ry, rw, 16)
        ctx.fill()
    # Equinox solar kalasam
    ctx.set_source_rgb(0.98, 0.85, 0.20)
    ctx.arc(240, 55, 10, 0, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "gujarat/modhera/landmarks/modhera_sun_temple.png")

    # 2. Rani ki Vav Stepwell (LOC-GJ-08) - UNESCO Subterranean Masterpiece
    surf, ctx = create_surface(500, 380)
    draw_ground_shadow(ctx, 250, 365, 460, 24)
    # Inverted subterranean temple stepped levels
    levels = [
        (420, 45, (0.75, 0.60, 0.38)),
        (360, 45, (0.70, 0.55, 0.35)),
        (300, 45, (0.65, 0.50, 0.32)),
        (240, 45, (0.60, 0.45, 0.28)),
        (180, 45, (0.55, 0.40, 0.25))
    ]
    curr_y = 140
    for lw, lh, lcol in levels:
        lx = 250 - lw / 2
        ctx.set_source_rgb(*lcol)
        ctx.rectangle(lx, curr_y, lw, lh)
        ctx.fill()
        # Sculpted pillared galleries (500+ principal sculptures of Dashavatara)
        draw_pillared_veranda(ctx, lx + 10, curr_y + 8, lw - 20, lh - 12, int(lw / 45), 8, (0.85, 0.70, 0.45), (0.50, 0.38, 0.22))
        curr_y += lh
    save_surface(surf, "gujarat/modhera/landmarks/rani_ki_vav_stepwell.png")

# ==============================================================================
# 3. KUTCH & DWARKA LANDMARKS
# ==============================================================================

def generate_kutch_and_dwarka_landmarks():
    print("\n--- Generating Kutch & Dwarka Landmarks ---")

    # 1. Great Rann of Kutch White Salt Desert (LOC-GJ-15)
    surf, ctx = create_surface(520, 280)
    draw_ground_shadow(ctx, 260, 265, 480, 20)
    # Pure white crystalline salt flat stretching to horizon
    ctx.set_source_rgb(0.96, 0.97, 0.99)
    ctx.rectangle(20, 180, 480, 85)
    ctx.fill()
    # Crystalline geometric salt hexagons
    ctx.set_source_rgba(0.85, 0.88, 0.94, 0.6)
    ctx.set_line_width(1.5)
    for hx in range(40, 480, 45):
        for hy in [200, 230]:
            ctx.arc(hx, hy, 16, 0, 2 * math.pi)
            ctx.stroke()
    # Circular mud Bhunga hut with mirrorwork & conical thatched roof
    ctx.set_source_rgb(0.88, 0.78, 0.65) # White/mud washed circular base
    ctx.rectangle(90, 160, 110, 75)
    ctx.fill()
    draw_sloping_roof(ctx, 75, 105, 140, 60, 10, (0.68, 0.55, 0.35), (0.42, 0.32, 0.18))
    # Traditional Rann Festival torana gate
    ctx.set_source_rgb(0.88, 0.25, 0.20)
    ctx.rectangle(260, 140, 14, 100)
    ctx.rectangle(370, 140, 14, 100)
    ctx.rectangle(250, 130, 148, 16)
    ctx.fill()
    save_surface(surf, "gujarat/kutch/landmarks/great_rann_white_desert.png")

    # 2. Statue of Unity (Colossal 182m Monument - LOC-GJ-01)
    surf, ctx = create_surface(360, 640)
    draw_ground_shadow(ctx, 180, 620, 320, 26)
    # Sadhu Bet Island concrete star plinth on Narmada River
    ctx.set_source_rgb(0.48, 0.50, 0.52)
    ctx.rectangle(90, 500, 180, 115)
    ctx.fill()
    # Two concrete core towers (Legs with traditional dhoti folds)
    ctx.set_source_rgb(0.72, 0.55, 0.35) # Weathered bronze patina alloy
    ctx.rectangle(125, 340, 45, 165) # Left leg
    ctx.rectangle(190, 340, 45, 165) # Right leg
    ctx.fill()
    # Kurta & Waistcoat (Sadri)
    ctx.set_source_rgb(0.68, 0.50, 0.32)
    ctx.rectangle(115, 190, 130, 155)
    ctx.fill()
    # Shoulders and Shawl drapery
    ctx.set_source_rgb(0.65, 0.48, 0.30)
    ctx.move_to(100, 240)
    ctx.line_to(180, 160)
    ctx.line_to(260, 240)
    ctx.line_to(240, 320)
    ctx.line_to(120, 320)
    ctx.close_path()
    ctx.fill()
    # Strong portrait head of Sardar Vallabhbhai Patel
    ctx.set_source_rgb(0.75, 0.58, 0.38)
    ctx.arc(180, 125, 32, 0, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "gujarat/dwarka/landmarks/statue_of_unity.png")

    # 3. Dwarkadhish Temple (Jagat Mandir - LOC-GJ-07)
    surf, ctx = create_surface(460, 520)
    draw_ground_shadow(ctx, 230, 505, 420, 24)
    # 5-storey 72-pillar Chalukyan limestone sanctum
    ctx.set_source_rgb(0.85, 0.72, 0.52)
    ctx.rectangle(110, 320, 240, 180)
    ctx.fill()
    # Stepped shikhara spire (78 meters tall)
    curr_w = 220
    curr_y = 320
    for s in range(10):
        th = 22
        curr_y -= th
        curr_w -= 16
        sx = 230 - curr_w / 2
        ctx.set_source_rgb(0.88 - s * 0.015, 0.75 - s * 0.015, 0.55 - s * 0.015)
        ctx.rectangle(sx, curr_y, curr_w, th)
        ctx.fill()
    # 52-yard triangular sacred flag (Dhwaja) fluttering in sea breeze
    ctx.set_source_rgb(0.95, 0.85, 0.15) # Golden yellow flag with sun/moon
    ctx.move_to(230, curr_y - 10)
    ctx.line_to(310, curr_y - 25)
    ctx.line_to(230, curr_y - 40)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "gujarat/dwarka/landmarks/dwarkadhish_temple.png")

# ==============================================================================
# 4. GUJARAT SUPPORTING SCENERY
# ==============================================================================

def generate_gujarat_scenery():
    print("\n--- Generating Gujarat Supporting Scenery ---")

    # Buildings (Kutch Round Bhunga, Ahmedabad Pol House, Saurashtra Cottage)
    bldgs = [
        ("house_gujarat_kutch_bhunga.png", 220, 160, (0.90, 0.85, 0.78)),
        ("house_gujarat_ahmedabad_pol.png", 240, 175, (0.85, 0.68, 0.45)),
        ("house_gujarat_saurashtra_cottage.png", 230, 165, (0.88, 0.82, 0.65)),
        ("house_gujarat_traditional_delo.png", 250, 180, (0.78, 0.58, 0.40)),
        ("house_gujarat_stepwell_pavilion.png", 220, 155, (0.82, 0.70, 0.50)),
        ("house_gujarat_rann_salt_worker.png", 200, 140, (0.92, 0.92, 0.95))
    ]
    for bname, w, h, col in bldgs:
        surf, ctx = create_surface(w, h)
        draw_ground_shadow(ctx, w/2, h - 8, w - 20, 14)
        ctx.set_source_rgb(*col)
        ctx.rectangle(20, h - 95, w - 40, 85)
        ctx.fill()
        draw_sloping_roof(ctx, 15, h - 145, w - 30, 50, 10, (0.70, 0.35, 0.20), (0.45, 0.18, 0.10))
        save_surface(surf, f"gujarat/ahmedabad/buildings/{bname}")
        save_surface(surf, f"gujarat/modhera/buildings/{bname}")
        save_surface(surf, f"gujarat/kutch/buildings/{bname}")

    # Vegetation (Babul acacia, Saltbush pilu, Mangrove)
    surf, ctx = create_surface(180, 220)
    draw_ground_shadow(ctx, 90, 210, 120, 14)
    ctx.set_source_rgb(0.40, 0.35, 0.30)
    ctx.rectangle(85, 90, 10, 120)
    ctx.fill()
    ctx.set_source_rgb(0.30, 0.52, 0.32)
    for cx in [60, 90, 120]:
        ctx.arc(cx, 75, 30, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "gujarat/ahmedabad/vegetation/tree_gujarat_babul_acacia.png")

    # Props (Kathiyawadi Dhaba, Farsan kiosk, Clay matka)
    surf, ctx = create_surface(160, 130)
    draw_ground_shadow(ctx, 80, 122, 140, 12)
    ctx.set_source_rgb(0.85, 0.68, 0.45)
    ctx.rectangle(25, 45, 110, 75)
    ctx.fill()
    ctx.set_source_rgb(0.20, 0.45, 0.85) # Blue textile banner
    ctx.rectangle(15, 35, 130, 16)
    ctx.fill()
    save_surface(surf, "gujarat/ahmedabad/roadside_props/shop_gujarat_kathiyawadi_dhaba.png")

    # Textures (Great Rann Salt Crust - Seamless 1024x1024)
    surf, ctx = create_surface(1024, 1024)
    ctx.set_source_rgb(0.95, 0.96, 0.98)
    ctx.paint()
    random.seed(202)
    for _ in range(8000):
        gx = random.randint(0, 1024)
        gy = random.randint(0, 1024)
        c = random.uniform(0.88, 1.0)
        ctx.set_source_rgb(c, c, c)
        ctx.rectangle(gx, gy, 2, 2)
        ctx.fill()
    save_surface(surf, "gujarat/kutch/textures/texture_salt_crust_white.png")

def main():
    print("==================================================")
    print("STARTING GUJARAT ASSET COLLECTION V2 GENERATION")
    print("==================================================")
    generate_ahmedabad_landmarks()
    generate_modhera_and_patan_landmarks()
    generate_kutch_and_dwarka_landmarks()
    generate_gujarat_scenery()
    print("==================================================")
    print("GUJARAT V2 ASSETS GENERATED SUCCESSFULLY!")
    print("==================================================")

if __name__ == "__main__":
    main()
