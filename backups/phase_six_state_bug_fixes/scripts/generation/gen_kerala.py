#!/usr/bin/env python3
"""
gen_kerala.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates high-fidelity stylized 2D assets for Kerala Indian Roads:
  - 6 Architectural Buildings (Nalukettu, backwater stilt hut, tea cottage, etc.)
  - 4 Roadside Shops / Stalls (Thattukada, Toddy shop, Spice trading, Banana chips)
  - 6 Regional Tree / Vegetation Variants (Arecanut palm, Rubber, Tea bush, Fern, etc.)
  - 3 Roadside Props (Coir drying, Brass Uruli, Snake boat prow)
  - 4 Vector Landmarks (Chinese Fishing Nets, Houseboat, Munnar Tea Gardens, Padmanabhaswamy Temple)
  - 3 Parallax Background Layers (Monsoon Sky, Sahyadri Ghats, Backwater Midground)
"""

import cairo
import math
import os

BASE_DIR = "assets/indian_locations/kerala"

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
    print(f"  ✓ Kerala Asset: {rel_path} ({surf.get_width()}x{surf.get_height()})")

# ==============================================================================
# 1. BUILDINGS
# ==============================================================================

def generate_buildings():
    print("\n--- Generating Kerala Buildings ---")
    
    # B1: Nalukettu Traditional House (Timber gables, Charupady veranda, Mangalore tiles)
    surf, ctx = create_surface(280, 210)
    ctx.set_source_rgb(0.85, 0.78, 0.65) # Warm wooden plaster
    ctx.rectangle(35, 95, 210, 100)
    ctx.fill()
    # Steeply pitched gable terracotta roof
    ctx.set_source_rgb(0.72, 0.24, 0.14)
    ctx.move_to(20, 95)
    ctx.line_to(140, 25)
    ctx.line_to(260, 95)
    ctx.close_path()
    ctx.fill()
    # Carved wooden gable ornament (Mukhavaram)
    ctx.set_source_rgb(0.38, 0.20, 0.10)
    ctx.move_to(110, 60)
    ctx.line_to(140, 35)
    ctx.line_to(170, 60)
    ctx.close_path()
    ctx.fill()
    # Charupady (curved wooden bench railing)
    for bx in [45, 80, 175, 210]:
        ctx.rectangle(bx, 130, 25, 40)
        ctx.stroke()
    # Heavy carved teak door
    ctx.rectangle(120, 125, 38, 70)
    ctx.fill()
    save_surface(surf, "buildings/house_kerala_nalukettu.png")

    # B2: Backwater Stilt Hut (Elevated bamboo and thatched hut on canalside)
    surf, ctx = create_surface(250, 170)
    # Stilt poles over water
    ctx.set_source_rgb(0.48, 0.36, 0.24)
    for sx in [45, 95, 155, 205]:
        ctx.rectangle(sx, 110, 8, 50)
        ctx.fill()
    # Coir woven hut body
    ctx.set_source_rgb(0.70, 0.58, 0.38)
    ctx.rectangle(35, 65, 180, 55)
    ctx.fill()
    # Coconut palm thatched roof
    ctx.set_source_rgb(0.58, 0.48, 0.28)
    ctx.move_to(20, 65)
    ctx.line_to(125, 18)
    ctx.line_to(230, 65)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "buildings/house_kerala_backwater_hut.png")

    # B3: Colonial Tea Estate Cottage (Stone walls, green roof, brick chimney)
    surf, ctx = create_surface(260, 190)
    ctx.set_source_rgb(0.72, 0.70, 0.68) # Mountain granite stone
    ctx.rectangle(30, 85, 200, 95)
    ctx.fill()
    # English green cottage roof
    ctx.set_source_rgb(0.18, 0.42, 0.28)
    ctx.move_to(15, 85)
    ctx.line_to(130, 30)
    ctx.line_to(245, 85)
    ctx.close_path()
    ctx.fill()
    # Brick chimney
    ctx.set_source_rgb(0.68, 0.28, 0.18)
    ctx.rectangle(180, 20, 22, 45)
    ctx.fill()
    save_surface(surf, "buildings/house_kerala_tea_estate_cottage.png")

    # B4: Coastal Fisherman Cottage (Turquoise lime wash, tiled porch)
    surf, ctx = create_surface(240, 170)
    ctx.set_source_rgb(0.28, 0.75, 0.78)
    ctx.rectangle(30, 75, 180, 85)
    ctx.fill()
    ctx.set_source_rgb(0.78, 0.28, 0.16)
    ctx.move_to(15, 75)
    ctx.line_to(120, 25)
    ctx.line_to(225, 75)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "buildings/house_kerala_coastal_fisherman.png")

    # B5: Dutch-Colonial Bungalow (Wrap-around veranda, white walls)
    surf, ctx = create_surface(290, 200)
    ctx.set_source_rgb(0.95, 0.95, 0.92)
    ctx.rectangle(35, 85, 220, 105)
    ctx.fill()
    ctx.set_source_rgb(0.75, 0.25, 0.15)
    ctx.move_to(15, 85)
    ctx.line_to(145, 25)
    ctx.line_to(275, 85)
    ctx.close_path()
    ctx.fill()
    # White veranda pillars
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    for px in [45, 95, 145, 195, 245]:
        ctx.rectangle(px, 115, 8, 75)
        ctx.fill()
    save_surface(surf, "buildings/house_kerala_colonial_bungalow.png")

    # B6: Ancestral Tharavadu Mansion (Two-story wooden mansion with multiple gables)
    surf, ctx = create_surface(320, 240)
    ctx.set_source_rgb(0.82, 0.72, 0.58)
    ctx.rectangle(30, 110, 260, 120)
    ctx.rectangle(60, 60, 200, 50)
    ctx.fill()
    ctx.set_source_rgb(0.72, 0.24, 0.14)
    ctx.move_to(45, 60)
    ctx.line_to(160, 15)
    ctx.line_to(275, 60)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "buildings/house_kerala_traditional_tharavadu.png")

# ==============================================================================
# 2. SHOPS
# ==============================================================================

def generate_shops():
    print("\n--- Generating Kerala Shops ---")
    
    # S1: Thattukada (Night street food cart with parotta stack & blackboard)
    surf, ctx = create_surface(180, 130)
    ctx.set_source_rgb(0.25, 0.45, 0.75)
    ctx.rectangle(20, 55, 140, 65)
    ctx.fill()
    # Steaming griddle
    ctx.set_source_rgb(0.20, 0.22, 0.24)
    ctx.arc(60, 55, 18, math.pi, 2*math.pi)
    ctx.fill()
    # Blackboard menu
    ctx.set_source_rgb(0.12, 0.14, 0.16)
    ctx.rectangle(100, 65, 45, 30)
    ctx.fill()
    save_surface(surf, "shops/shop_kerala_thattukada.png")

    # S2: Toddy Shop / Kallu Shappu (Iconic thatched toddy shack with green board)
    surf, ctx = create_surface(200, 140)
    ctx.set_source_rgb(0.85, 0.82, 0.75)
    ctx.rectangle(25, 55, 150, 75)
    ctx.fill()
    # Thatched canopy
    ctx.set_source_rgb(0.58, 0.48, 0.28)
    ctx.move_to(15, 55)
    ctx.line_to(100, 20)
    ctx.line_to(185, 55)
    ctx.close_path()
    ctx.fill()
    # Green signboard 'KALLU SHAPPU'
    ctx.set_source_rgb(0.12, 0.52, 0.22)
    ctx.rectangle(45, 65, 110, 24)
    ctx.fill()
    # Clay toddy pots
    ctx.set_source_rgb(0.68, 0.38, 0.24)
    for cx in [45, 65, 85]:
        ctx.arc(cx, 105, 10, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "shops/shop_kerala_toddy_shappu.png")

    # S3: Spice Trading Kiosk (Burlap sacks of cardamom, black pepper, cloves)
    surf, ctx = create_surface(170, 120)
    ctx.set_source_rgb(0.55, 0.40, 0.24)
    ctx.rectangle(20, 55, 130, 55)
    ctx.fill()
    # Burlap spice sacks
    for sx, scol in [(35, (0.2, 0.5, 0.2)), (65, (0.1, 0.1, 0.1)), (95, (0.5, 0.2, 0.1)), (125, (0.8, 0.7, 0.2))]:
        ctx.set_source_rgb(0.72, 0.62, 0.45) # sack
        ctx.arc(sx, 70, 14, 0, 2*math.pi)
        ctx.fill()
        ctx.set_source_rgb(*scol) # spice inside
        ctx.arc(sx, 65, 9, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "shops/shop_kerala_spice_trading.png")

    # S4: Banana Chips Fryer Stall (Cauldron frying golden raw banana chips)
    surf, ctx = create_surface(160, 130)
    ctx.set_source_rgb(0.48, 0.35, 0.22)
    ctx.rectangle(20, 60, 120, 60)
    ctx.fill()
    # Brass frying kadai
    ctx.set_source_rgb(0.92, 0.78, 0.20)
    ctx.arc(80, 60, 28, 0, math.pi)
    ctx.fill()
    # Golden banana chips
    ctx.set_source_rgb(0.98, 0.85, 0.18)
    for bx, by in [(70, 65), (80, 63), (90, 66), (75, 70), (85, 69)]:
        ctx.arc(bx, by, 4, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "shops/shop_kerala_banana_chips.png")

# ==============================================================================
# 3. VEGETATION
# ==============================================================================

def generate_vegetation():
    print("\n--- Generating Kerala Vegetation ---")
    
    # V1: Tall Arecanut Betel Palm
    surf, ctx = create_surface(140, 310)
    ctx.set_source_rgb(0.42, 0.38, 0.32)
    ctx.rectangle(66, 70, 8, 235)
    ctx.fill()
    # Feathery crown
    ctx.set_source_rgb(0.18, 0.58, 0.22)
    for angle in [-2.4, -1.8, -1.2, -0.6, 0.0, 0.6]:
        ctx.move_to(70, 70)
        ctx.line_to(70 + 55 * math.cos(angle), 70 + 45 * math.sin(angle))
        ctx.set_line_width(5)
        ctx.stroke()
    save_surface(surf, "vegetation/tree_kerala_arecanut_palm.png")

    # V2: Rubber Plantation Tree (Straight trunk with diagonal cut and latex cup)
    surf, ctx = create_surface(180, 270)
    ctx.set_source_rgb(0.45, 0.36, 0.28)
    ctx.rectangle(82, 90, 16, 175)
    ctx.fill()
    # Diagonal tapping groove
    ctx.set_source_rgb(0.28, 0.20, 0.14)
    ctx.set_line_width(3)
    ctx.move_to(82, 170)
    ctx.line_to(98, 190)
    ctx.stroke()
    # Black latex collection cup
    ctx.set_source_rgb(0.15, 0.15, 0.18)
    ctx.arc(98, 195, 6, 0, 2*math.pi)
    ctx.fill()
    # High leaf canopy
    ctx.set_source_rgb(0.20, 0.52, 0.25)
    ctx.arc(90, 60, 50, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/tree_kerala_rubber_tree.png")

    # V3: Monsoon Coconut Cluster
    surf, ctx = create_surface(220, 280)
    ctx.set_source_rgb(0.46, 0.35, 0.25)
    ctx.move_to(80, 275)
    ctx.curve_to(95, 180, 110, 110, 110, 65)
    ctx.stroke()
    ctx.set_source_rgb(0.15, 0.62, 0.22)
    for angle in [-2.6, -2.0, -1.4, -0.8, -0.2, 0.4]:
        ctx.move_to(110, 65)
        ctx.curve_to(110 + 30 * math.cos(angle), 65 - 20, 110 + 75 * math.cos(angle), 65 + 60 * math.sin(angle), 110 + 80 * math.cos(angle), 65 + 65 * math.sin(angle))
        ctx.set_line_width(6)
        ctx.stroke()
    save_surface(surf, "vegetation/tree_kerala_coconut_cluster.png")

    # V4: Emerald Tea Bush Row
    surf, ctx = create_surface(160, 90)
    ctx.set_source_rgb(0.12, 0.58, 0.22)
    ctx.arc(80, 65, 55, math.pi, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/shrub_kerala_tea_bush.png")

    # V5: Fruiting Jackfruit Tree
    surf, ctx = create_surface(220, 230)
    ctx.set_source_rgb(0.40, 0.28, 0.18)
    ctx.rectangle(100, 110, 20, 115)
    ctx.fill()
    ctx.set_source_rgb(0.16, 0.48, 0.20)
    ctx.arc(110, 80, 65, 0, 2*math.pi)
    ctx.fill()
    # Large green jackfruits hanging from trunk
    ctx.set_source_rgb(0.38, 0.58, 0.22)
    for jx, jy in [(95, 140), (122, 155), (102, 175)]:
        ctx.arc(jx, jy, 9, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_kerala_jackfruit.png")

    # V6: Tropical Wild Monsoon Fern
    surf, ctx = create_surface(130, 100)
    ctx.set_source_rgb(0.20, 0.65, 0.28)
    for angle in [-2.4, -1.8, -1.2, -0.6, 0.0]:
        ctx.move_to(65, 95)
        ctx.curve_to(65 + 25 * math.cos(angle), 95 - 20, 65 + 45 * math.cos(angle), 95 + 30 * math.sin(angle), 65 + 50 * math.cos(angle), 95 + 35 * math.sin(angle))
        ctx.set_line_width(5)
        ctx.stroke()
    save_surface(surf, "vegetation/shrub_kerala_monsoon_fern.png")

# ==============================================================================
# 4. PROPS
# ==============================================================================

def generate_props():
    print("\n--- Generating Kerala Props ---")
    
    # P1: Coir Rope Drying Rack
    surf, ctx = create_surface(160, 90)
    ctx.set_source_rgb(0.55, 0.42, 0.28)
    ctx.rectangle(20, 30, 6, 55)
    ctx.rectangle(134, 30, 6, 55)
    ctx.rectangle(20, 35, 120, 4)
    ctx.fill()
    # Hanging golden coir rope bundles
    ctx.set_source_rgb(0.85, 0.72, 0.45)
    for rx in range(35, 130, 16):
        ctx.rectangle(rx, 39, 8, 38)
        ctx.fill()
    save_surface(surf, "roadside_props/prop_kerala_coir_drying.png")

    # P2: Brass Uruli with Water Lilies
    surf, ctx = create_surface(120, 80)
    ctx.set_source_rgb(0.92, 0.78, 0.22)
    ctx.arc(60, 50, 40, 0, math.pi)
    ctx.fill()
    # Floating lilies
    ctx.set_source_rgb(0.95, 0.35, 0.55)
    for lx in [45, 60, 75]:
        ctx.arc(lx, 48, 6, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "roadside_props/prop_kerala_uruli_flowers.png")

    # P3: Snake Boat (Chundan Vallam) Prow
    surf, ctx = create_surface(180, 120)
    ctx.set_source_rgb(0.35, 0.20, 0.12)
    ctx.move_to(20, 105)
    ctx.curve_to(80, 105, 130, 85, 155, 25)
    ctx.line_to(165, 25)
    ctx.curve_to(140, 95, 90, 115, 20, 115)
    ctx.close_path()
    ctx.fill()
    # Golden ornaments on prow
    ctx.set_source_rgb(0.95, 0.82, 0.20)
    ctx.arc(160, 25, 7, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_kerala_snake_boat_prow.png")

# ==============================================================================
# 5. LANDMARKS
# ==============================================================================

def generate_landmarks():
    print("\n--- Generating Kerala Landmarks ---")
    
    # L1: Chinese Fishing Nets (Cheena Vala - cantilevered timber beams & net)
    surf, ctx = create_surface(360, 320)
    # Timber cantilever beams
    ctx.set_source_rgb(0.48, 0.32, 0.18)
    ctx.set_line_width(8)
    ctx.move_to(80, 280)
    ctx.line_to(260, 120)
    ctx.stroke()
    ctx.move_to(180, 280)
    ctx.line_to(260, 120)
    ctx.stroke()
    # Hanging stone counterweights
    ctx.set_source_rgb(0.35, 0.36, 0.38)
    for wx in [100, 120, 140]:
        ctx.arc(wx, 260, 8, 0, 2*math.pi)
        ctx.fill()
    # Suspended net frame dipping toward water
    ctx.set_source_rgba(0.25, 0.55, 0.75, 0.6)
    ctx.move_to(260, 120)
    ctx.curve_to(310, 180, 330, 250, 320, 300)
    ctx.line_to(240, 300)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "landmarks/chinese_fishing_nets_vector.png")

    # L2: Alleppey Houseboat (Kettuvallam with curved hull and thatched roof)
    surf, ctx = create_surface(380, 240)
    # Wooden kettuvallam hull
    ctx.set_source_rgb(0.42, 0.25, 0.15)
    ctx.move_to(40, 170)
    ctx.curve_to(90, 215, 290, 215, 340, 170)
    ctx.close_path()
    ctx.fill()
    # Curved thatched roof canopy
    ctx.set_source_rgb(0.68, 0.55, 0.32)
    ctx.move_to(55, 170)
    ctx.curve_to(110, 80, 270, 80, 325, 170)
    ctx.close_path()
    ctx.fill()
    # Open observation bow deck with wooden railings
    ctx.set_source_rgb(0.95, 0.95, 0.95)
    ctx.rectangle(290, 140, 45, 30)
    ctx.fill()
    save_surface(surf, "landmarks/alleppey_houseboat_vector.png")

    # L3: Munnar Tea Estates (Tiered green hills with mist)
    surf, ctx = create_surface(360, 220)
    for i, tcol in enumerate([(0.14, 0.45, 0.20), (0.18, 0.55, 0.24), (0.22, 0.65, 0.28)]):
        ctx.set_source_rgb(*tcol)
        ctx.arc(180, 160 + i * 25, 140 - i * 20, math.pi, 2*math.pi)
        ctx.fill()
    save_surface(surf, "landmarks/munnar_tea_estates_vector.png")

# ==============================================================================
# 6. PARALLAX BACKGROUND LAYERS
# ==============================================================================

def generate_backgrounds():
    print("\n--- Generating Kerala Parallax Backgrounds ---")
    
    # Sky
    surf, ctx = create_surface(1920, 600)
    pat = cairo.LinearGradient(0, 0, 0, 600)
    pat.add_color_stop_rgb(0.0, 0.10, 0.42, 0.75)
    pat.add_color_stop_rgb(0.6, 0.35, 0.65, 0.88)
    pat.add_color_stop_rgb(1.0, 0.85, 0.92, 0.95)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 600)
    ctx.fill()
    save_surface(surf, "backgrounds/sky/kerala_sky_monsoon.png")

    # Peaks
    surf, ctx = create_surface(1920, 450)
    pat = cairo.LinearGradient(0, 120, 0, 450)
    pat.add_color_stop_rgb(0.0, 0.12, 0.38, 0.24)
    pat.add_color_stop_rgb(1.0, 0.08, 0.25, 0.16)
    ctx.set_source(pat)
    ctx.move_to(0, 250)
    ctx.curve_to(400, 120, 800, 240, 1200, 130)
    ctx.curve_to(1500, 210, 1750, 140, 1920, 230)
    ctx.line_to(1920, 450)
    ctx.line_to(0, 450)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "backgrounds/distant_landscape/kerala_western_ghats_peaks.png")

    # Backwater midground
    surf, ctx = create_surface(1920, 350)
    ctx.set_source_rgb(0.15, 0.48, 0.25)
    ctx.rectangle(0, 190, 1920, 160)
    ctx.fill()
    save_surface(surf, "backgrounds/distant_landscape/kerala_backwater_canal_midground.png")

def main():
    generate_buildings()
    generate_shops()
    generate_vegetation()
    generate_props()
    generate_landmarks()
    generate_backgrounds()
    print("=== KERALA ASSET GENERATION COMPLETE ===")

if __name__ == "__main__":
    main()
