#!/usr/bin/env python3
"""
gen_telangana.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates high-fidelity stylized 2D assets for Telangana Indian Roads:
  - 6 Architectural Buildings (Deccan stone house, Manduva logili, Nizam bungalow, etc.)
  - 4 Roadside Shops / Stalls (Irani chai cafe, Biryani deg point, Laad Bazaar bangles, Sitaphal fruit)
  - 6 Regional Tree / Vegetation Variants (Tamarind, Banyan on boulders, Gulmohar, Teak, etc.)
  - 3 Roadside Props (Granite boulder tor, Nandi shrine, Copper deg hearth)
  - 4 Vector Landmarks (Charminar, Golconda Fort, Kakatiya Kala Thoranam, Ramappa Temple)
  - 3 Parallax Background Layers (Deccan Twilight Sky, Granite Boulder Ridges, Plateau Midground)
"""

import cairo
import math
import os

BASE_DIR = "assets/indian_locations/telangana"

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
    print(f"  ✓ Telangana Asset: {rel_path} ({surf.get_width()}x{surf.get_height()})")

# ==============================================================================
# 1. BUILDINGS
# ==============================================================================

def generate_buildings():
    print("\n--- Generating Telangana Buildings ---")
    
    # B1: Deccan Granite Stone House
    surf, ctx = create_surface(270, 200)
    ctx.set_source_rgb(0.55, 0.52, 0.50) # Gray granite blocks
    ctx.rectangle(30, 80, 210, 110)
    ctx.fill()
    # Stone block lines
    ctx.set_source_rgba(0.35, 0.32, 0.30, 0.5)
    ctx.set_line_width(2)
    for gy in range(95, 185, 20):
        ctx.move_to(30, gy)
        ctx.line_to(240, gy)
        ctx.stroke()
    # Heavy carved teak door
    ctx.set_source_rgb(0.35, 0.20, 0.12)
    ctx.rectangle(115, 120, 38, 70)
    ctx.fill()
    save_surface(surf, "buildings/house_telangana_deccan_stone.png")

    # B2: Rural Telugu Manduva Logili House
    surf, ctx = create_surface(290, 210)
    ctx.set_source_rgb(0.88, 0.82, 0.70)
    ctx.rectangle(30, 90, 230, 105)
    ctx.fill()
    ctx.set_source_rgb(0.75, 0.28, 0.16)
    ctx.move_to(15, 90)
    ctx.line_to(145, 25)
    ctx.line_to(275, 90)
    ctx.close_path()
    ctx.fill()
    # Pillars
    ctx.set_source_rgb(0.42, 0.24, 0.14)
    for px in [45, 95, 185, 235]:
        ctx.rectangle(px, 115, 8, 80)
        ctx.fill()
    save_surface(surf, "buildings/house_telangana_rural_manduva.png")

    # B3: Hyderabad Nizam Indo-Saracenic City Bungalow
    surf, ctx = create_surface(300, 230)
    ctx.set_source_rgb(0.95, 0.92, 0.85) # Cream stucco
    ctx.rectangle(30, 80, 240, 135)
    ctx.fill()
    # Scalloped cusped arches
    for ax in [65, 150, 235]:
        ctx.set_source_rgb(0.85, 0.78, 0.65)
        ctx.arc(ax, 120, 24, math.pi, 2*math.pi)
        ctx.fill()
    save_surface(surf, "buildings/house_telangana_nizam_bungalow.png")

    # B4: Striped Earthen Village Cottage
    surf, ctx = create_surface(250, 170)
    ctx.set_source_rgb(0.72, 0.45, 0.32) # Red earth
    ctx.rectangle(30, 75, 190, 85)
    ctx.fill()
    # White vertical lime stripes
    ctx.set_source_rgb(0.96, 0.96, 0.96)
    for sx in range(45, 215, 25):
        ctx.rectangle(sx, 75, 8, 85)
        ctx.fill()
    save_surface(surf, "buildings/house_telangana_village_mud_house.png")

    # B5: Rock-Cut Boulder Terrace House
    surf, ctx = create_surface(280, 230)
    # Granite boulder base
    ctx.set_source_rgb(0.45, 0.44, 0.42)
    ctx.arc(140, 160, 95, 0, math.pi)
    ctx.fill()
    # House built on top of rock
    ctx.set_source_rgb(0.85, 0.78, 0.65)
    ctx.rectangle(65, 65, 150, 80)
    ctx.fill()
    save_surface(surf, "buildings/house_telangana_rock_cut_terrace.png")

    # B6: Artisan Weaver Quarter Workshop
    surf, ctx = create_surface(260, 190)
    ctx.set_source_rgb(0.82, 0.75, 0.62)
    ctx.rectangle(30, 80, 200, 95)
    ctx.fill()
    # Open front workshop with clay tiles
    ctx.set_source_rgb(0.72, 0.25, 0.15)
    ctx.move_to(15, 80)
    ctx.line_to(130, 30)
    ctx.line_to(245, 80)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "buildings/house_telangana_artisan_quarter.png")

# ==============================================================================
# 2. SHOPS
# ==============================================================================

def generate_shops():
    print("\n--- Generating Telangana Shops ---")
    
    # S1: Hyderabadi Irani Chai & Osmania Biscuit Cafe
    surf, ctx = create_surface(180, 130)
    ctx.set_source_rgb(0.20, 0.35, 0.60)
    ctx.rectangle(20, 55, 140, 65)
    ctx.fill()
    # Brass boiling tea urn
    ctx.set_source_rgb(0.92, 0.78, 0.22)
    ctx.arc(50, 55, 16, math.pi, 2*math.pi)
    ctx.rectangle(34, 55, 32, 25)
    ctx.fill()
    # Glass jar with Osmania biscuits
    ctx.set_source_rgba(0.9, 0.95, 1.0, 0.65)
    ctx.rectangle(110, 52, 22, 26)
    ctx.fill()
    save_surface(surf, "shops/shop_telangana_irani_chai.png")

    # S2: Sealed Copper Biryani Deg Point
    surf, ctx = create_surface(170, 120)
    ctx.set_source_rgb(0.48, 0.35, 0.24)
    ctx.rectangle(20, 60, 130, 50)
    ctx.fill()
    # Sealed copper handi/deg
    ctx.set_source_rgb(0.85, 0.48, 0.28)
    ctx.arc(85, 60, 24, 0, 2*math.pi)
    ctx.fill()
    # Dough seal on rim
    ctx.set_source_rgb(0.92, 0.88, 0.75)
    ctx.arc(85, 48, 20, math.pi, 2*math.pi)
    ctx.set_line_width(4)
    ctx.stroke()
    save_surface(surf, "shops/shop_telangana_biryani_deg.png")

    # S3: Laad Bazaar Lac Bangles Stall
    surf, ctx = create_surface(180, 130)
    ctx.set_source_rgb(0.55, 0.15, 0.30)
    ctx.rectangle(20, 55, 140, 65)
    ctx.fill()
    # Sparkly lac bangles
    for bx, bcol in [(45, (0.95, 0.8, 0.2)), (75, (0.9, 0.2, 0.3)), (105, (0.2, 0.7, 0.4)), (135, (0.2, 0.4, 0.9))]:
        ctx.set_source_rgb(*bcol)
        ctx.arc(bx, 75, 10, 0, 2*math.pi)
        ctx.set_line_width(3)
        ctx.stroke()
    save_surface(surf, "shops/shop_telangana_laad_bazaar_bangles.png")

    # S4: Custard Apple & Pomegranate Fruit Stall
    surf, ctx = create_surface(160, 120)
    ctx.set_source_rgb(0.50, 0.36, 0.24)
    ctx.rectangle(20, 60, 120, 50)
    ctx.fill()
    # Green sitaphal (custard apples)
    ctx.set_source_rgb(0.35, 0.65, 0.28)
    for fx in [45, 65, 85]:
        ctx.arc(fx, 55, 9, 0, 2*math.pi)
        ctx.fill()
    # Red pomegranates
    ctx.set_source_rgb(0.85, 0.18, 0.22)
    for fx in [105, 125]:
        ctx.arc(fx, 55, 9, 0, 2*math.pi)
        ctx.fill()
    save_surface(surf, "shops/shop_telangana_custard_apple_fruit.png")

# ==============================================================================
# 3. VEGETATION
# ==============================================================================

def generate_vegetation():
    print("\n--- Generating Telangana Vegetation ---")
    
    # V1: Spreading Tamarind Tree
    surf, ctx = create_surface(240, 230)
    ctx.set_source_rgb(0.38, 0.28, 0.20)
    ctx.rectangle(110, 120, 20, 95)
    ctx.fill()
    ctx.set_source_rgb(0.24, 0.52, 0.26)
    ctx.arc(120, 80, 70, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/tree_telangana_tamarind_shade.png")

    # V2: Banyan Tree on Granite Boulders
    surf, ctx = create_surface(280, 250)
    # Granite rock
    ctx.set_source_rgb(0.48, 0.46, 0.44)
    ctx.arc(140, 195, 60, math.pi, 2*math.pi)
    ctx.fill()
    # Banyan roots wrapping around rock
    ctx.set_source_rgb(0.38, 0.26, 0.18)
    ctx.rectangle(125, 120, 30, 95)
    ctx.fill()
    ctx.set_source_rgb(0.18, 0.48, 0.22)
    ctx.arc(140, 85, 75, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/tree_telangana_banyan_boulder.png")

    # V3: Wild Custard Apple Shrub
    surf, ctx = create_surface(180, 190)
    ctx.set_source_rgb(0.42, 0.32, 0.22)
    ctx.rectangle(85, 110, 10, 65)
    ctx.fill()
    ctx.set_source_rgb(0.28, 0.58, 0.30)
    ctx.arc(90, 75, 50, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/tree_telangana_custard_apple.png")

    # V4: Red Gulmohar Tree
    surf, ctx = create_surface(230, 220)
    ctx.set_source_rgb(0.38, 0.26, 0.18)
    ctx.rectangle(105, 115, 18, 90)
    ctx.fill()
    ctx.set_source_rgb(0.92, 0.20, 0.16) # Blazing scarlet flowers
    ctx.arc(115, 75, 65, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/tree_telangana_gulmohar_red.png")

    # V5: Deccan Teak Tree
    surf, ctx = create_surface(190, 260)
    ctx.set_source_rgb(0.45, 0.36, 0.28)
    ctx.rectangle(88, 80, 14, 165)
    ctx.fill()
    ctx.set_source_rgb(0.24, 0.54, 0.26)
    ctx.arc(95, 60, 55, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/tree_telangana_teak_forest.png")

    # V6: Granite Thorn Scrub
    surf, ctx = create_surface(140, 100)
    ctx.set_source_rgb(0.35, 0.50, 0.30)
    ctx.arc(70, 70, 35, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "vegetation/shrub_telangana_granite_scrub.png")

# ==============================================================================
# 4. PROPS
# ==============================================================================

def generate_props():
    print("\n--- Generating Telangana Props ---")
    
    # P1: Granite Boulder Tor
    surf, ctx = create_surface(170, 120)
    ctx.set_source_rgb(0.48, 0.46, 0.44)
    ctx.arc(85, 95, 45, 0, 2*math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.55, 0.52, 0.50) # Balancing top rock
    ctx.arc(85, 50, 32, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_telangana_granite_boulder_tor.png")

    # P2: Nandi Stone Shrine
    surf, ctx = create_surface(130, 90)
    ctx.set_source_rgb(0.35, 0.36, 0.38)
    ctx.rectangle(25, 40, 80, 40)
    ctx.fill()
    # Nandi bull carving silhouette
    ctx.set_source_rgb(0.20, 0.22, 0.24)
    ctx.arc(65, 38, 12, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_telangana_nandi_shrine.png")

    # P3: Copper Deg Hearth
    surf, ctx = create_surface(120, 80)
    ctx.set_source_rgb(0.85, 0.48, 0.28)
    ctx.arc(60, 45, 20, 0, 2*math.pi)
    ctx.fill()
    save_surface(surf, "roadside_props/prop_telangana_copper_deg_hearth.png")

# ==============================================================================
# 5. LANDMARKS
# ==============================================================================

def generate_landmarks():
    print("\n--- Generating Telangana Landmarks ---")
    
    # L1: Charminar Monument (Four 48.7m minarets, central grand arches, stucco work)
    surf, ctx = create_surface(360, 420)
    # Granite central structure
    ctx.set_source_rgb(0.85, 0.78, 0.65)
    ctx.rectangle(80, 150, 200, 220)
    ctx.fill()
    # Four grand open arches
    ctx.set_source_rgb(0.18, 0.20, 0.24)
    ctx.rectangle(130, 250, 100, 120)
    ctx.arc(180, 250, 50, math.pi, 2*math.pi)
    ctx.fill()
    # Four corner minarets with fluted domes
    minaret_x = [70, 270]
    for mx in minaret_x:
        ctx.set_source_rgb(0.80, 0.72, 0.60)
        ctx.rectangle(mx, 50, 30, 320)
        ctx.fill()
        # Minaret dome cap
        ctx.set_source_rgb(0.92, 0.82, 0.68)
        ctx.arc(mx + 15, 50, 16, math.pi, 2*math.pi)
        ctx.fill()
    save_surface(surf, "landmarks/charminar_monument_vector.png")

    # L2: Kakatiya Kala Thoranam (Warangal ornate stone arch gateway)
    surf, ctx = create_surface(320, 280)
    ctx.set_source_rgb(0.50, 0.48, 0.46) # Black basalt/granite
    # Twin massive pillars
    ctx.rectangle(60, 80, 30, 180)
    ctx.rectangle(230, 80, 30, 180)
    ctx.fill()
    # Intricate cross beam arch with Makara motifs
    ctx.rectangle(40, 70, 240, 22)
    ctx.fill()
    ctx.arc(160, 70, 45, math.pi, 2*math.pi)
    ctx.set_line_width(8)
    ctx.stroke()
    save_surface(surf, "landmarks/kakatiya_kala_thoranam_vector.png")

# ==============================================================================
# 6. PARALLAX BACKGROUND LAYERS
# ==============================================================================

def generate_backgrounds():
    print("\n--- Generating Telangana Parallax Backgrounds ---")
    
    # Sky
    surf, ctx = create_surface(1920, 600)
    pat = cairo.LinearGradient(0, 0, 0, 600)
    pat.add_color_stop_rgb(0.0, 0.15, 0.35, 0.65)
    pat.add_color_stop_rgb(0.6, 0.65, 0.55, 0.75)
    pat.add_color_stop_rgb(1.0, 0.95, 0.82, 0.65)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 600)
    ctx.fill()
    save_surface(surf, "backgrounds/sky/telangana_sky_deccan_twilight.png")

    # Ridges
    surf, ctx = create_surface(1920, 450)
    ctx.set_source_rgb(0.42, 0.40, 0.38)
    ctx.move_to(0, 260)
    ctx.curve_to(350, 160, 700, 250, 1100, 170)
    ctx.curve_to(1450, 230, 1750, 150, 1920, 240)
    ctx.line_to(1920, 450)
    ctx.line_to(0, 450)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "backgrounds/distant_landscape/telangana_granite_boulder_ridges.png")

def main():
    generate_buildings()
    generate_shops()
    generate_vegetation()
    generate_props()
    generate_landmarks()
    generate_backgrounds()
    print("=== TELANGANA ASSET GENERATION COMPLETE ===")

if __name__ == "__main__":
    main()
