#!/usr/bin/env python3
"""
gen_gujarat.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates high-fidelity stylized 2D assets for Gujarat Indian Roads:
  - 6 Architectural Buildings (Kutch Bhunga, Ahmedabad Pol house, Saurashtra cottage, etc.)
  - 4 Roadside Shops / Stalls (Kathiyawadi Dhaba, Fafda-Jalebi, Bandhani textile, Matka pots)
  - 6 Regional Tree / Vegetation Variants (Babul Acacia, Neem, Palash, Mangrove, etc.)
  - 3 Roadside Props (Sanedo farming vehicle, Water pot stand, White salt heap)
  - 4 Vector Landmarks (Statue of Unity, Rani ki Vav, Modhera Sun Temple, Great Rann Flamingos)
  - 3 Parallax Background Layers (Pale Azure Sky, Great Rann White Desert, Savanna Midground)
"""

import cairo
import math
import os

BASE_DIR = "assets/indian_locations/gujarat"

def create_surface(w, h):
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, int(w), int(h))
    ctx = cairo.Context(surface)
    ctx.set_source_rgba(0, 0, 0, 0)
    ctx.paint()
    return surface, ctx

def ensure_dir(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)

def save_surface(surf, rel_path):
    full_path = os.path.join(BASE_DIR, rel_path)
    ensure_dir(full_path)
    surf.write_to_png(full_path)
    print(f"  ✓ Gujarat Asset: {rel_path} ({surf.get_width()}x{surf.get_height()})")

# ==============================================================================
# 1. BUILDINGS
# ==============================================================================

def generate_buildings():
    print("\n--- Generating Gujarat Buildings ---")
    
    # B1: Kutch Round Bhunga Hut (White circular mud dwelling with Lippan mirror-clay art)
    surf, ctx = create_surface(250, 180)
    # White lime mud wall
    ctx.set_source_rgb(0.95, 0.94, 0.92)
    ctx.rectangle(45, 95, 160, 75)
    ctx.fill()
    # Geometric Lippan mirror relief art
    ctx.set_source_rgb(0.85, 0.45, 0.25)
    for px in [65, 90, 160, 185]:
        ctx.arc(px, 130, 8, 0, 2*math.pi)
        ctx.stroke()
        # Mirror center
        ctx.set_source_rgb(0.85, 0.95, 1.0)
        ctx.arc(px, 130, 3, 0, 2*math.pi)
        ctx.fill()
        ctx.set_source_rgb(0.85, 0.45, 0.25)
    # Conical dried grass thatch roof
    ctx.set_source_rgb(0.72, 0.60, 0.38)
    ctx.move_to(25, 95)
    ctx.line_to(125, 20)
    ctx.line_to(225, 95)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "buildings/house_gujarat_kutch_bhunga.png")

    # B2: Ahmedabad Pol House (Multi-level wooden bracket architecture with carved peacocks)
    surf, ctx = create_surface(280, 250)
    ctx.set_source_rgb(0.88, 0.80, 0.70)
    ctx.rectangle(35, 75, 210, 165)
    ctx.fill()
    # Carved wooden bracket balconies (Todla)
    ctx.set_source_rgb(0.42, 0.24, 0.14)
    for by in [135, 195]:
        ctx.rectangle(30, by, 220, 8)
        ctx.fill()
    # Ornate wooden window shutters
    for wx in [60, 120, 180]:
        ctx.rectangle(wx, 95, 28, 35)
        ctx.rectangle(wx, 155, 28, 35)
        ctx.fill()
    save_surface(surf, "buildings/house_gujarat_ahmedabad_pol.png")

    # B3: Saurashtra Limestone Cottage
    surf, ctx = create_surface(260, 190)
    ctx.set_source_rgb(0.92, 0.92, 0.88)
    ctx.rectangle(30, 80, 200, 100)
    ctx.fill()
    ctx.set_source_rgb(0.78, 0.28, 0.18)
    ctx.move_to(15, 80)
    ctx.line_to(130, 25)
    ctx.line_to(245, 80)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "buildings/house_gujarat_saurashtra_cottage.png")

    # B4: Rann Salt Worker Shelter
    surf, ctx = create_surface(240, 160)
    ctx.set_source_rgb(0.75, 0.72, 0.65)
    ctx.rectangle(35, 75, 170, 75)
    ctx.fill()
    ctx.set_source_rgb(0.62, 0.55, 0.40)
    ctx.move_to(20, 75)
    ctx.line_to(120, 30)
    ctx.line_to(220, 75)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "buildings/house_gujarat_rann_salt_worker.png")

    # B5: Traditional Delo Courtyard Entrance House
    surf, ctx = create_surface(300, 220)
    ctx.set_source_rgb(0.85, 0.78, 0.65)
    ctx.rectangle(30, 80, 240, 130)
    ctx.fill()
    # Massive carved wooden doorway (Delo)
    ctx.set_source_rgb(0.35, 0.18, 0.10)
    ctx.rectangle(115, 110, 70, 100)
    ctx.fill()
    # Brass studs
    ctx.set_source_rgb(0.95, 0.82, 0.20)
    for bx in [130, 170]:
        for by in [130, 160, 190]:
            ctx.arc(bx, by, 3, 0, 2*math.pi)
            ctx.fill()
    save_surface(surf, "buildings/house_gujarat_traditional_delo.png")

    # B6: Carved Stone Stepwell Pavilion
    surf, ctx = create_surface(280, 240)
    ctx.set_source_rgb(0.82, 0.75, 0.60)
    ctx.rectangle(40, 90, 200, 140)
    ctx.fill()
    # Multi-pillared opening
    for px in [60, 105, 150, 195]:
        ctx.set_source_rgb(0.65, 0.55, 0.42)
        ctx.rectangle(px, 110, 14, 110)
        ctx.fill()
    save_surface(surf, "buildings/house_gujarat_stepwell_pavilion.png")

# ==============================================================================
# 2. SHOPS
# ==============================================================================

def generate_shops():
    print("\n--- Generating Gujarat Shops ---")
    
    # S1: Kathiyawadi Highway Dhaba
    surf, ctx = create_surface(190, 130)
    ctx.set_source_rgb(0.55, 0.38, 0.24)
    ctx.rectangle(20, 55, 150, 65)
    ctx.fill()
    # Woven charpai cot
    ctx.set_source_rgb(0.85, 0.35, 0.20)
    ctx.rectangle(35, 80, 55, 12)
    ctx.fill()
    # Brass thali plate
    ctx.set_source_rgb(0.95, 0.82, 0.22)
    ctx.arc(120, 75, 14, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "shops/shop_gujarat_kathiyawadi_dhaba.png")

    # S2: Fafda-Jalebi Stall
    surf, ctx = create_surface(180, 130)
    ctx.set_source_rgb(0.48, 0.35, 0.22)
    ctx.rectangle(20, 55, 140, 65)
    ctx.fill()
    # Golden fafda strips
    ctx.set_source_rgb(0.95, 0.85, 0.22)
    for fx in range(35, 85, 8):
        ctx.rectangle(fx, 65, 6, 25)
        ctx.fill()
    # Saffron jalebi spirals
    ctx.set_source_rgb(0.98, 0.58, 0.12)
    for jx in [105, 125]:
        ctx.arc(jx, 75, 9, 0, 2*math.pi)
        ctx.set_line_width(2.5)
        ctx.stroke()
    save_surface(surf, "shops/shop_gujarat_fafda_jalebi.png")

    # S3: Bandhani Textile Stall
    surf, ctx = create_surface(170, 130)
    ctx.set_source_rgb(0.55, 0.40, 0.28)
    ctx.rectangle(20, 55, 130, 65)
    ctx.fill()
    # Bandhani tie-dye cloths
    for bx, bcol in [(35, (0.85, 0.15, 0.2)), (70, (0.95, 0.8, 0.1)), (105, (0.15, 0.6, 0.3))]:
        ctx.set_source_rgb(*bcol)
        ctx.rectangle(bx, 65, 25, 45)
        ctx.fill()
    save_surface(surf, "shops/shop_gujarat_bandhani_textile.png")

    # S4: Terracotta Matka Pot Stall
    surf, ctx = create_surface(160, 120)
    ctx.set_source_rgb(0.48, 0.35, 0.24)
    ctx.rectangle(20, 60, 120, 50)
    ctx.fill()
    ctx.set_source_rgb(0.78, 0.38, 0.22)
    for px, py in [(40, 55), (60, 52), (80, 54), (100, 53), (50, 42), (70, 40), (90, 41)]:
        ctx.arc(px, py, 9, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "shops/shop_gujarat_clay_matka_pot.png")

# ==============================================================================
# 3. VEGETATION
# ==============================================================================

def generate_vegetation():
    print("\n--- Generating Gujarat Vegetation ---")
    
    # V1: Spiny Babul Acacia
    surf, ctx = create_surface(210, 230)
    ctx.set_source_rgb(0.42, 0.32, 0.24)
    ctx.rectangle(98, 110, 14, 110)
    ctx.fill()
    ctx.set_source_rgb(0.32, 0.52, 0.28)
    for cx, cy, rad in [(105, 75, 50), (65, 95, 38), (145, 95, 38)]:
        ctx.arc(cx, cy, rad, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_gujarat_babul_acacia.png")

    # V2: Sprawling Neem Tree
    surf, ctx = create_surface(240, 220)
    ctx.set_source_rgb(0.38, 0.26, 0.18)
    ctx.rectangle(110, 130, 20, 80)
    ctx.fill()
    ctx.set_source_rgb(0.22, 0.58, 0.26)
    ctx.arc(120, 85, 65, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/tree_gujarat_neem_sprawling.png")

    # V3: Palash Flame of the Forest
    surf, ctx = create_surface(200, 220)
    ctx.set_source_rgb(0.40, 0.30, 0.20)
    ctx.rectangle(92, 110, 16, 100)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.35, 0.12) # Blazing orange flowers
    for cx, cy in [(75, 70), (100, 55), (125, 70), (90, 95), (115, 90)]:
        ctx.arc(cx, cy, 14, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_gujarat_flame_of_forest.png")

    # V4: Kutch Salt Mangrove Scrub
    surf, ctx = create_surface(150, 110)
    ctx.set_source_rgb(0.45, 0.38, 0.30)
    for sx in [45, 75, 105]:
        ctx.arc(sx, 90, 20, math.pi, 2*math.pi)
        ctx.set_line_width(4)
        ctx.stroke()
    ctx.set_source_rgb(0.25, 0.55, 0.35)
    ctx.arc(75, 60, 35, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/shrub_gujarat_kutch_mangrove.png")

    # V5: Date Palm
    surf, ctx = create_surface(180, 270)
    ctx.set_source_rgb(0.48, 0.38, 0.28)
    ctx.rectangle(84, 70, 12, 190)
    ctx.fill()
    ctx.set_source_rgb(0.24, 0.56, 0.28)
    for angle in [-2.4, -1.8, -1.2, -0.6, 0.0, 0.6]:
        ctx.move_to(90, 70)
        ctx.line_to(90 + 65 * math.cos(angle), 70 + 55 * math.sin(angle))
        ctx.set_line_width(6)
        ctx.stroke()
    save_surface(surf, "vegetation/tree_gujarat_date_palm.png")

    # V6: White Salt Grass
    surf, ctx = create_surface(130, 80)
    ctx.set_source_rgb(0.75, 0.82, 0.78)
    for angle in [-2.4, -2.0, -1.6, -1.2, -0.8]:
        ctx.move_to(65, 75)
        ctx.line_to(65 + 35 * math.cos(angle), 75 + 30 * math.sin(angle))
        ctx.set_line_width(3.5)
        ctx.stroke()
    save_surface(surf, "vegetation/shrub_gujarat_white_salt_grass.png")

# ==============================================================================
# 4. PROPS
# ==============================================================================

def generate_props():
    print("\n--- Generating Gujarat Props ---")
    
    # P1: Sanedo Local Motorized Farm Cart
    surf, ctx = create_surface(170, 100)
    ctx.set_source_rgb(0.85, 0.25, 0.20) # Bright red chassis
    ctx.rectangle(30, 45, 110, 25)
    ctx.fill()
    ctx.set_source_rgb(0.20, 0.22, 0.25)
    ctx.arc(50, 75, 16, 0, 2*math.pi)
    ctx.arc(115, 75, 16, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_gujarat_sanedo_cart.png")

    # P2: Water Pot Stand
    surf, ctx = create_surface(120, 90)
    ctx.set_source_rgb(0.55, 0.40, 0.25)
    ctx.rectangle(25, 40, 70, 8)
    ctx.rectangle(35, 40, 6, 45)
    ctx.rectangle(79, 40, 6, 45)
    ctx.fill()
    ctx.set_source_rgb(0.78, 0.38, 0.22)
    ctx.arc(45, 32, 10, 0, 2*math.pi)
    ctx.arc(75, 32, 10, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_gujarat_water_pot_stand.png")

    # P3: White Salt Harvest Pile
    surf, ctx = create_surface(150, 80)
    ctx.set_source_rgb(0.96, 0.98, 1.0)
    ctx.move_to(20, 75)
    ctx.line_to(75, 25)
    ctx.line_to(130, 75)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "roadside_props/prop_gujarat_salt_harvest_pile.png")

# ==============================================================================
# 5. LANDMARKS
# ==============================================================================

def generate_landmarks():
    print("\n--- Generating Gujarat Landmarks ---")
    
    # L1: Statue of Unity (Monumental 182-meter bronze statue on river base)
    surf, ctx = create_surface(260, 440)
    # Pier river base
    ctx.set_source_rgb(0.45, 0.46, 0.48)
    ctx.rectangle(40, 360, 180, 65)
    ctx.fill()
    # Patinated bronze statue body (Sardar Patel in dhoti and shawl)
    ctx.set_source_rgb(0.58, 0.45, 0.28) # Warm bronze
    # Robe legs and torso
    ctx.rectangle(85, 140, 90, 220)
    ctx.fill()
    # Draped shawl across shoulders
    ctx.set_source_rgb(0.65, 0.52, 0.32)
    ctx.move_to(80, 140)
    ctx.curve_to(130, 180, 170, 160, 180, 140)
    ctx.line_to(180, 220)
    ctx.line_to(80, 220)
    ctx.close_path()
    ctx.fill()
    # Head and determined profile
    ctx.arc(130, 105, 26, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "landmarks/statue_of_unity_vector.png")

    # L2: Great Rann White Desert with Flamingos
    surf, ctx = create_surface(360, 220)
    # Shimmering white salt plain
    ctx.set_source_rgb(0.95, 0.96, 0.98)
    ctx.rectangle(20, 140, 320, 65)
    ctx.fill()
    # Pink greater flamingos
    ctx.set_source_rgb(0.96, 0.55, 0.65)
    for fx in [80, 140, 200, 260]:
        ctx.arc(fx, 110, 12, 0, 2*math.pi)
        ctx.fill()
        # Slender S-curved neck
        ctx.move_to(fx + 6, 110)
        ctx.curve_to(fx + 15, 95, fx + 5, 80, fx + 15, 75)
        ctx.set_line_width(3)
        ctx.stroke()
        # Legs
        ctx.move_to(fx - 2, 120)
        ctx.line_to(fx - 2, 150)
        ctx.move_to(fx + 4, 120)
        ctx.line_to(fx + 4, 150)
        ctx.stroke()
    save_surface(surf, "landmarks/great_rann_flamingos_vector.png")

# ==============================================================================
# 6. PARALLAX BACKGROUND LAYERS
# ==============================================================================

def generate_backgrounds():
    print("\n--- Generating Gujarat Parallax Backgrounds ---")
    
    # Sky
    surf, ctx = create_surface(1920, 600)
    pat = cairo.LinearGradient(0, 0, 0, 600)
    pat.add_color_stop_rgb(0.0, 0.35, 0.65, 0.90)
    pat.add_color_stop_rgb(0.6, 0.70, 0.85, 0.95)
    pat.add_color_stop_rgb(1.0, 0.95, 0.96, 0.98)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 600)
    ctx.fill()
    save_surface(surf, "backgrounds/sky/gujarat_sky_pale_azure.png")

    # Salt flats
    surf, ctx = create_surface(1920, 450)
    ctx.set_source_rgb(0.92, 0.94, 0.96)
    ctx.rectangle(0, 180, 1920, 270)
    ctx.fill()
    save_surface(surf, "backgrounds/distant_landscape/gujarat_great_rann_white_salt.png")

def main():
    generate_buildings()
    generate_shops()
    generate_vegetation()
    generate_props()
    generate_landmarks()
    generate_backgrounds()
    print("=== GUJARAT ASSET GENERATION COMPLETE ===")

if __name__ == "__main__":
    main()
