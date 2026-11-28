#!/usr/bin/env python3
"""
gen_rajasthan.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates high-fidelity stylized 2D assets for Rajasthan Indian Roads:
  - 6 Architectural Buildings (Pink Haveli, Blue Jodhpur cubic, Thar Bhunga, Yellow stone, etc.)
  - 4 Roadside Shops / Stalls (Puppets, Kulhad Chai, Blue Pottery, Mojari leather)
  - 6 Regional Tree / Vegetation Variants (Khejri, Rohida, Thor Cactus, Date Palm, etc.)
  - 3 Roadside Props (Camel cart, Sandstone Jharokha, Heritage Milestone)
  - 4 Vector Landmarks (Hawa Mahal, Amber Fort, Mehrangarh Fort, Jaisalmer Golden Fort)
  - 3 Parallax Background Layers (Desert Dawn Sky, Thar Sand Dunes, Aravalli Midground)
"""

import cairo
import math
import os

BASE_DIR = "assets/indian_locations/rajasthan"

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
    print(f"  ✓ Rajasthan Asset: {rel_path} ({surf.get_width()}x{surf.get_height()})")

# ==============================================================================
# 1. BUILDINGS
# ==============================================================================

def generate_buildings():
    print("\n--- Generating Rajasthan Buildings ---")
    
    # B1: Jaipur Pink Sandstone Haveli (Jharokha balconies, Rajput scalloped arches)
    surf, ctx = create_surface(300, 240)
    # Pink terracotta walls
    ctx.set_source_rgb(0.92, 0.58, 0.52)
    ctx.rectangle(30, 80, 240, 145)
    ctx.fill()
    # Scalloped parapet
    ctx.set_source_rgb(0.85, 0.48, 0.42)
    ctx.rectangle(25, 68, 250, 14)
    ctx.fill()
    for jx in range(40, 260, 35):
        ctx.arc(jx, 68, 12, math.pi, 2*math.pi)
        ctx.fill()
    # Overhanging Jharokha Balconies
    for bx in [60, 150, 220]:
        ctx.set_source_rgb(0.82, 0.45, 0.38)
        ctx.rectangle(bx, 105, 36, 45)
        ctx.arc(bx + 18, 105, 18, math.pi, 2*math.pi)
        ctx.fill()
        # Stone lattice jali screen
        ctx.set_source_rgb(0.95, 0.82, 0.78)
        ctx.rectangle(bx + 5, 115, 26, 30)
        ctx.fill()
    # Grand scalloped gateway
    ctx.set_source_rgb(0.38, 0.18, 0.14)
    ctx.rectangle(130, 160, 40, 65)
    ctx.arc(150, 160, 20, math.pi, 2*math.pi)
    ctx.fill()
    save_surface(surf, "buildings/house_rajasthan_jaipur_haveli.png")

    # B2: Jodhpur Blue Cubic House (Indigo blue walls, flat terrace, small arched windows)
    surf, ctx = create_surface(260, 200)
    ctx.set_source_rgb(0.25, 0.55, 0.88) # Jodhpur indigo blue
    ctx.rectangle(30, 75, 200, 115)
    ctx.fill()
    # White lime trim on terrace
    ctx.set_source_rgb(0.96, 0.96, 0.98)
    ctx.rectangle(25, 65, 210, 12)
    ctx.fill()
    # Small deep-set arched windows to keep out desert heat
    ctx.set_source_rgb(0.12, 0.22, 0.45)
    for wx in [60, 120, 180]:
        ctx.rectangle(wx, 100, 22, 28)
        ctx.arc(wx + 11, 100, 11, math.pi, 2*math.pi)
        ctx.fill()
    # Wooden door with brass studs
    ctx.set_source_rgb(0.35, 0.20, 0.12)
    ctx.rectangle(110, 140, 32, 50)
    ctx.fill()
    save_surface(surf, "buildings/house_rajasthan_jodhpur_blue.png")

    # B3: Thar Desert Round Bhunga Hut (Mud walls, conical thatch, folk white patterns)
    surf, ctx = create_surface(250, 180)
    # Circular mud wall
    ctx.set_source_rgb(0.72, 0.52, 0.36)
    ctx.rectangle(45, 95, 160, 75)
    ctx.fill()
    # White clay folk art circles
    ctx.set_source_rgba(1.0, 1.0, 1.0, 0.85)
    ctx.set_line_width(2)
    for px in [70, 95, 155, 180]:
        ctx.arc(px, 130, 8, 0, 2*math.pi)
        ctx.stroke()
    # Conical dry grass thatch roof
    ctx.set_source_rgb(0.78, 0.68, 0.42)
    ctx.move_to(25, 95)
    ctx.line_to(125, 20)
    ctx.line_to(225, 95)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "buildings/house_rajasthan_thar_bhunga.png")

    # B4: Jaisalmer Yellow Sandstone Block House
    surf, ctx = create_surface(270, 210)
    ctx.set_source_rgb(0.92, 0.78, 0.38) # Honey-yellow sandstone
    ctx.rectangle(30, 80, 210, 120)
    ctx.fill()
    # Stone block grid
    ctx.set_source_rgba(0.72, 0.58, 0.25, 0.5)
    ctx.set_line_width(1.5)
    for gy in range(95, 190, 20):
        ctx.move_to(30, gy)
        ctx.line_to(240, gy)
        ctx.stroke()
    save_surface(surf, "buildings/house_rajasthan_desert_stone.png")

    # B5: Shekhawati Painted Fresco Haveli
    surf, ctx = create_surface(320, 250)
    ctx.set_source_rgb(0.94, 0.86, 0.75)
    ctx.rectangle(30, 90, 260, 145)
    ctx.fill()
    # Fresco colored frieze band
    for i, fcol in enumerate([(0.8, 0.2, 0.2), (0.2, 0.5, 0.3), (0.2, 0.3, 0.7)] * 3):
        ctx.set_source_rgb(*fcol)
        ctx.rectangle(40 + i * 26, 95, 22, 28)
        ctx.fill()
    save_surface(surf, "buildings/house_rajasthan_marwari_mansion.png")

    # B6: Desert Fortress Watchtower
    surf, ctx = create_surface(240, 260)
    ctx.set_source_rgb(0.85, 0.72, 0.42)
    ctx.rectangle(70, 70, 100, 180)
    ctx.fill()
    # Battlements
    for bx in range(65, 175, 20):
        ctx.set_source_rgba(0, 0, 0, 0)
        ctx.rectangle(bx, 58, 8, 14)
        ctx.fill()
    save_surface(surf, "buildings/house_rajasthan_outpost_watchtower.png")

# ==============================================================================
# 2. SHOPS
# ==============================================================================

def generate_shops():
    print("\n--- Generating Rajasthan Shops ---")
    
    # S1: Kathputli Puppet Stall
    surf, ctx = create_surface(180, 140)
    ctx.set_source_rgb(0.65, 0.45, 0.28)
    ctx.rectangle(20, 60, 140, 65)
    ctx.fill()
    # Hanging colorful string puppets
    for px, pcol in [(45, (0.95, 0.2, 0.2)), (75, (0.2, 0.6, 0.8)), (105, (0.95, 0.85, 0.15)), (135, (0.85, 0.2, 0.6))]:
        ctx.set_source_rgb(*pcol)
        ctx.arc(px, 75, 7, 0, 2*math.pi)
        ctx.rectangle(px - 6, 82, 12, 22)
        ctx.fill()
    save_surface(surf, "shops/shop_rajasthan_handicraft_puppets.png")

    # S2: Spiced Kulhad Chai & Samosa Stall
    surf, ctx = create_surface(180, 130)
    ctx.set_source_rgb(0.55, 0.38, 0.25)
    ctx.rectangle(20, 55, 140, 65)
    ctx.fill()
    # Clay kulhad cups
    ctx.set_source_rgb(0.78, 0.42, 0.28)
    for kx in [40, 55, 70, 85]:
        ctx.rectangle(kx, 65, 8, 12)
        ctx.fill()
    # Copper boiling kettle
    ctx.set_source_rgb(0.85, 0.52, 0.30)
    ctx.arc(125, 65, 16, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "shops/shop_rajasthan_chai_samosa.png")

    # S3: Blue Pottery & Matka Stall
    surf, ctx = create_surface(170, 120)
    ctx.set_source_rgb(0.48, 0.35, 0.24)
    ctx.rectangle(20, 60, 130, 50)
    ctx.fill()
    # Blue pottery plates
    ctx.set_source_rgb(0.18, 0.42, 0.82)
    for bx in [45, 75, 105]:
        ctx.arc(bx, 60, 14, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "shops/shop_rajasthan_pottery_stall.png")

    # S4: Mojari Leather Stall
    surf, ctx = create_surface(160, 120)
    ctx.set_source_rgb(0.58, 0.42, 0.28)
    ctx.rectangle(20, 55, 120, 55)
    ctx.fill()
    # Curved embroidered mojari shoes
    ctx.set_source_rgb(0.78, 0.25, 0.20)
    for mx in [45, 75, 105]:
        ctx.arc(mx, 60, 10, math.pi, 2*math.pi)
        ctx.fill()
    save_surface(surf, "shops/shop_rajasthan_mojari_stall.png")

# ==============================================================================
# 3. VEGETATION
# ==============================================================================

def generate_vegetation():
    print("\n--- Generating Rajasthan Vegetation ---")
    
    # V1: Desert Khejri Tree
    surf, ctx = create_surface(220, 240)
    ctx.set_source_rgb(0.42, 0.32, 0.24)
    ctx.rectangle(100, 120, 18, 110)
    ctx.fill()
    # Sparse feathery desert canopy
    ctx.set_source_rgb(0.35, 0.52, 0.30)
    for cx, cy, rad in [(110, 80, 55), (70, 100, 40), (150, 100, 40)]:
        ctx.arc(cx, cy, rad, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_rajasthan_khejri.png")

    # V2: Rohida Desert Teak with Vermilion Flowers
    surf, ctx = create_surface(200, 220)
    ctx.set_source_rgb(0.40, 0.30, 0.22)
    ctx.rectangle(90, 110, 16, 100)
    ctx.fill()
    ctx.set_source_rgb(0.28, 0.45, 0.25)
    ctx.arc(100, 75, 50, 0, 2*math.pi)
    ctx.fill()
    # Vermilion-orange blossoms
    ctx.set_source_rgb(0.95, 0.42, 0.15)
    for fx, fy in [(75, 65), (100, 55), (125, 70), (90, 90), (115, 85)]:
        ctx.arc(fx, fy, 7, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/tree_rajasthan_rohida_blossom.png")

    # V3: Multi-Armed Thor Cactus
    surf, ctx = create_surface(150, 130)
    ctx.set_source_rgb(0.25, 0.55, 0.28)
    ctx.rectangle(68, 45, 14, 75) # Central trunk
    ctx.fill()
    # Side branches
    ctx.rectangle(45, 65, 23, 10)
    ctx.rectangle(45, 45, 10, 25)
    ctx.rectangle(82, 55, 23, 10)
    ctx.rectangle(95, 35, 10, 25)
    ctx.fill()
    save_surface(surf, "vegetation/shrub_rajasthan_thor_cactus.png")

    # V4: Oasis Date Palm
    surf, ctx = create_surface(190, 280)
    ctx.set_source_rgb(0.50, 0.38, 0.28)
    ctx.rectangle(88, 70, 14, 200)
    ctx.fill()
    ctx.set_source_rgb(0.22, 0.55, 0.26)
    for angle in [-2.5, -2.0, -1.5, -1.0, -0.5, 0.0, 0.5]:
        ctx.move_to(95, 70)
        ctx.line_to(95 + 75 * math.cos(angle), 70 + 60 * math.sin(angle))
        ctx.set_line_width(6)
        ctx.stroke()
    save_surface(surf, "vegetation/tree_rajasthan_date_palm.png")

    # V5: Ker Desert Caper Berry Bush
    surf, ctx = create_surface(140, 110)
    ctx.set_source_rgb(0.35, 0.58, 0.32)
    ctx.arc(70, 75, 40, 0, 2*math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.92, 0.20, 0.18)
    for rx, ry in [(55, 65), (75, 55), (85, 75), (65, 85)]:
        ctx.arc(rx, ry, 5, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "vegetation/shrub_rajasthan_ker_desert_berry.png")

    # V6: Arid Golden Tussock Grass
    surf, ctx = create_surface(130, 80)
    ctx.set_source_rgb(0.85, 0.75, 0.38)
    for angle in [-2.4, -2.0, -1.6, -1.2, -0.8]:
        ctx.move_to(65, 75)
        ctx.line_to(65 + 35 * math.cos(angle), 75 + 30 * math.sin(angle))
        ctx.set_line_width(4)
        ctx.stroke()
    save_surface(surf, "vegetation/shrub_rajasthan_dry_tussock_grass.png")

# ==============================================================================
# 4. PROPS
# ==============================================================================

def generate_props():
    print("\n--- Generating Rajasthan Props ---")
    
    # P1: Desert Camel Cart
    surf, ctx = create_surface(180, 110)
    ctx.set_source_rgb(0.55, 0.38, 0.22)
    ctx.rectangle(25, 55, 120, 12)
    ctx.fill()
    ctx.set_source_rgb(0.40, 0.24, 0.14)
    ctx.arc(85, 75, 22, 0, 2*math.pi)
    ctx.set_line_width(4)
    ctx.stroke()
    save_surface(surf, "roadside_props/prop_rajasthan_camel_cart.png")

    # P2: Sandstone Jharokha Screen
    surf, ctx = create_surface(130, 120)
    ctx.set_source_rgb(0.92, 0.78, 0.40)
    ctx.rectangle(20, 25, 90, 80)
    ctx.fill()
    ctx.set_source_rgb(0.35, 0.22, 0.14)
    ctx.arc(65, 55, 25, math.pi, 2*math.pi)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_rajasthan_stone_jharokha.png")

    # P3: Painted Heritage Highway Milestone
    surf, ctx = create_surface(110, 80)
    ctx.set_source_rgb(0.95, 0.95, 0.95)
    ctx.rectangle(35, 30, 40, 45)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.78, 0.18) # Yellow top
    ctx.arc(55, 30, 20, math.pi, 2*math.pi)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_rajasthan_painted_milestone.png")

# ==============================================================================
# 5. LANDMARKS
# ==============================================================================

def generate_landmarks():
    print("\n--- Generating Rajasthan Landmarks ---")
    
    # L1: Hawa Mahal (Pink honeycomb facade with 953 jharokhas)
    surf, ctx = create_surface(380, 360)
    ctx.set_source_rgb(0.92, 0.55, 0.48) # Pink terracotta
    # Stepped pyramid palace facade
    for i in range(5):
        pw = 320 - i * 50
        ph = 55
        px = 190 - pw / 2
        py = 280 - i * 55
        ctx.rectangle(px, py, pw, ph)
        ctx.fill()
        # Miniature fluted dome roofs along tier
        for dx in range(int(px) + 15, int(px + pw) - 15, 30):
            ctx.set_source_rgb(0.85, 0.42, 0.38)
            ctx.arc(dx, py, 10, math.pi, 2*math.pi)
            ctx.fill()
            ctx.set_source_rgb(0.92, 0.55, 0.48)
    save_surface(surf, "landmarks/hawa_mahal_vector.png")

    # L2: Amber Fort Ramparts (Hilltop Rajput fort)
    surf, ctx = create_surface(400, 260)
    ctx.set_source_rgb(0.88, 0.72, 0.42)
    ctx.move_to(30, 230)
    ctx.line_to(90, 160)
    ctx.line_to(220, 130)
    ctx.line_to(360, 180)
    ctx.line_to(380, 230)
    ctx.close_path()
    ctx.fill()
    # Battlements
    for bx in range(40, 370, 24):
        ctx.set_source_rgba(0, 0, 0, 0)
        ctx.rectangle(bx, 150, 10, 12)
        ctx.fill()
    save_surface(surf, "landmarks/amber_fort_ramparts_vector.png")

# ==============================================================================
# 6. PARALLAX BACKGROUND LAYERS
# ==============================================================================

def generate_backgrounds():
    print("\n--- Generating Rajasthan Parallax Backgrounds ---")
    
    # Sky
    surf, ctx = create_surface(1920, 600)
    pat = cairo.LinearGradient(0, 0, 0, 600)
    pat.add_color_stop_rgb(0.0, 0.95, 0.62, 0.35)
    pat.add_color_stop_rgb(0.5, 0.98, 0.82, 0.55)
    pat.add_color_stop_rgb(1.0, 0.98, 0.92, 0.75)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 600)
    ctx.fill()
    save_surface(surf, "backgrounds/sky/rajasthan_sky_desert_dawn.png")

    # Dunes
    surf, ctx = create_surface(1920, 450)
    pat = cairo.LinearGradient(0, 120, 0, 450)
    pat.add_color_stop_rgb(0.0, 0.88, 0.62, 0.28)
    pat.add_color_stop_rgb(1.0, 0.75, 0.48, 0.20)
    ctx.set_source(pat)
    ctx.move_to(0, 240)
    ctx.curve_to(450, 140, 900, 230, 1350, 150)
    ctx.curve_to(1650, 220, 1820, 160, 1920, 210)
    ctx.line_to(1920, 450)
    ctx.line_to(0, 450)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "backgrounds/distant_landscape/rajasthan_thar_sand_dunes.png")

def main():
    generate_buildings()
    generate_shops()
    generate_vegetation()
    generate_props()
    generate_landmarks()
    generate_backgrounds()
    print("=== RAJASTHAN ASSET GENERATION COMPLETE ===")

if __name__ == "__main__":
    main()
