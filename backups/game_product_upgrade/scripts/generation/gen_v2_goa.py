#!/usr/bin/env python3
"""
gen_v2_goa.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates the complete Goa asset collection in asset_collection_v2/goa/:
  - Panaji (Landmarks, Buildings, Vegetation, Props, Backgrounds)
  - Old Goa (Landmarks, Buildings, Vegetation, Backgrounds)
  - North Goa (Landmarks, Buildings, Vegetation, Props, Backgrounds)
  - South Goa (Landmarks, Buildings, Vegetation, Backgrounds)
  - Inland Goa (Landmarks, Vegetation, Backgrounds)
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
# 1. PANAJI LANDMARKS
# ==============================================================================

def generate_panaji_landmarks():
    print("\n--- Generating Panaji Landmarks ---")

    # 1. Our Lady of the Immaculate Conception Church (LOC-GA-01)
    surf, ctx = create_surface(440, 480)
    draw_ground_shadow(ctx, 220, 465, 420, 26)
    # Iconic zigzag symmetrical baroque staircase
    ctx.set_source_rgb(0.92, 0.94, 0.96) # White stucco steps
    for step in range(5):
        sw = 380 - step * 50
        sy = 450 - step * 22
        sx = 220 - sw / 2
        ctx.rectangle(sx, sy, sw, 20)
        ctx.fill()
        # Balustrade railing
        ctx.set_source_rgb(0.35, 0.38, 0.42)
        ctx.rectangle(sx, sy, sw, 3)
        ctx.fill()
        ctx.set_source_rgb(0.92, 0.94, 0.96)
    # Church main facade
    ctx.rectangle(120, 200, 200, 150)
    ctx.fill()
    # Central bell tower & pediment
    ctx.rectangle(170, 90, 100, 110)
    ctx.fill()
    # Baroque curved pediments
    ctx.arc(220, 90, 50, math.pi, 2 * math.pi)
    ctx.fill()
    # Augustinian Great Bell cavity
    ctx.set_source_rgb(0.20, 0.22, 0.25)
    draw_archway(ctx, 195, 110, 50, 60, (0.75, 0.78, 0.82), (0.15, 0.16, 0.18))
    # Bronze church bell
    ctx.set_source_rgb(0.72, 0.58, 0.25)
    ctx.arc(220, 140, 14, math.pi, 2 * math.pi)
    ctx.fill()
    # Flanking twin belfries
    ctx.set_source_rgb(0.90, 0.92, 0.95)
    ctx.rectangle(80, 150, 40, 180)
    ctx.rectangle(320, 150, 40, 180)
    ctx.fill()
    # Pyramidal spire caps
    ctx.move_to(80, 150)
    ctx.line_to(100, 90)
    ctx.line_to(120, 150)
    ctx.close_path()
    ctx.fill()
    ctx.move_to(320, 150)
    ctx.line_to(340, 90)
    ctx.line_to(360, 150)
    ctx.close_path()
    ctx.fill()
    # Iron crosses on spires
    ctx.set_source_rgb(0.25, 0.26, 0.28)
    for cx_pos in [100, 220, 340]:
        cy_pos = 75 if cx_pos != 220 else 25
        ctx.rectangle(cx_pos - 2, cy_pos, 4, 20)
        ctx.rectangle(cx_pos - 8, cy_pos + 6, 16, 4)
        ctx.fill()
    save_surface(surf, "goa/panaji/landmarks/our_lady_immaculate_conception.png")

    # 2. Fontainhas Latin Quarter Streetscape (LOC-GA-02)
    surf, ctx = create_surface(460, 280)
    draw_ground_shadow(ctx, 230, 265, 430, 22)
    # Three colorful contiguous Portuguese heritage houses
    # House 1: Vibrant Ochre Yellow
    ctx.set_source_rgb(0.92, 0.76, 0.18)
    ctx.rectangle(30, 100, 130, 160)
    ctx.fill()
    draw_sloping_roof(ctx, 20, 50, 150, 50, 10, (0.75, 0.25, 0.15), (0.45, 0.15, 0.10))
    # Wrought iron balcão balcony
    ctx.set_source_rgb(0.18, 0.20, 0.22)
    ctx.rectangle(55, 150, 70, 30)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.95, 0.98) # White window borders
    ctx.rectangle(65, 115, 50, 35)
    ctx.fill()
    ctx.set_source_rgb(0.25, 0.35, 0.55) # Indigo shutters
    ctx.rectangle(68, 118, 20, 29)
    ctx.rectangle(92, 118, 20, 29)
    ctx.fill()

    # House 2: Cobalt Indigo Blue
    ctx.set_source_rgb(0.22, 0.42, 0.72)
    ctx.rectangle(165, 80, 140, 180)
    ctx.fill()
    draw_sloping_roof(ctx, 155, 30, 160, 50, 10, (0.78, 0.28, 0.18), (0.45, 0.15, 0.10))
    # White stucco balcão with arches
    ctx.set_source_rgb(0.95, 0.95, 0.98)
    ctx.rectangle(185, 175, 100, 85)
    ctx.fill()
    draw_archway(ctx, 210, 195, 50, 65, (0.80, 0.82, 0.85), (0.15, 0.20, 0.30))

    # House 3: Terracotta Coral Red
    ctx.set_source_rgb(0.85, 0.38, 0.25)
    ctx.rectangle(310, 110, 120, 150)
    ctx.fill()
    draw_sloping_roof(ctx, 300, 60, 140, 50, 10, (0.72, 0.22, 0.12), (0.40, 0.12, 0.08))
    # Azulejo tiled nameplate
    ctx.set_source_rgb(0.20, 0.45, 0.85)
    ctx.rectangle(340, 140, 25, 15)
    ctx.fill()
    save_surface(surf, "goa/panaji/landmarks/fontainhas_heritage_quarter.png")

# ==============================================================================
# 2. OLD GOA LANDMARKS
# ==============================================================================

def generate_old_goa_landmarks():
    print("\n--- Generating Old Goa Landmarks ---")

    # 1. Basilica of Bom Jesus (LOC-GA-04) - Baroque unplastered red laterite facade
    surf, ctx = create_surface(460, 420)
    draw_ground_shadow(ctx, 230, 405, 430, 24)
    # Porous reddish-brown laterite stone walling
    ctx.set_source_rgb(0.68, 0.32, 0.22)
    ctx.rectangle(70, 150, 320, 250)
    ctx.fill()
    # Basalt black stone entrance columns and Doric pilasters
    draw_pillared_veranda(ctx, 90, 280, 280, 120, 5, 16, (0.28, 0.29, 0.32), (0.22, 0.23, 0.25))
    # 3-tiered baroque facade orders (Doric, Ionic, Corinthian)
    ctx.set_source_rgb(0.72, 0.35, 0.25)
    ctx.rectangle(110, 80, 240, 70)
    ctx.fill()
    # Jesuit Emblem (IHS with radiating sunburst crest)
    ctx.set_source_rgb(0.25, 0.26, 0.28) # Basalt medallion
    ctx.arc(230, 115, 25, 0, 2 * math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.82, 0.20) # Golden IHS rays
    for a in range(12):
        ang = a * (math.pi / 6)
        ctx.move_to(230, 115)
        ctx.line_to(230 + math.cos(ang) * 32, 115 + math.sin(ang) * 32)
        ctx.stroke()
    # Tri-lobed baroque apex pediment
    ctx.set_source_rgb(0.65, 0.30, 0.20)
    ctx.arc(230, 80, 50, math.pi, 2 * math.pi)
    ctx.fill()
    # Stone cross atop pediment
    ctx.set_source_rgb(0.25, 0.26, 0.28)
    ctx.rectangle(228, 12, 4, 24)
    ctx.rectangle(220, 20, 20, 4)
    ctx.fill()
    save_surface(surf, "goa/old_goa/landmarks/basilica_of_bom_jesus.png")

    # 2. Se Cathedral (LOC-GA-05) - Tuscan Portuguese colonial cathedral with Golden Bell
    surf, ctx = create_surface(480, 420)
    draw_ground_shadow(ctx, 240, 405, 450, 24)
    # Bright whitewashed grand facade
    ctx.set_source_rgb(0.94, 0.95, 0.97)
    ctx.rectangle(110, 160, 260, 240)
    ctx.fill()
    # Tuscan classical pilasters
    draw_pillared_veranda(ctx, 130, 250, 220, 150, 4, 18, (0.85, 0.88, 0.90), (0.75, 0.78, 0.82))
    # Surviving Northern Bell Tower (Golden Bell / Sino de Ouro)
    ctx.set_source_rgb(0.92, 0.93, 0.95)
    ctx.rectangle(60, 80, 60, 320)
    ctx.fill()
    # Belfry arch cavity
    draw_archway(ctx, 72, 100, 36, 50, (0.75, 0.78, 0.82), (0.18, 0.20, 0.22))
    # Giant Golden Bell
    ctx.set_source_rgb(0.95, 0.78, 0.18)
    ctx.arc(90, 125, 12, math.pi, 2 * math.pi)
    ctx.fill()
    # Classical triangular pediment over main hall
    ctx.set_source_rgb(0.90, 0.92, 0.94)
    ctx.move_to(110, 160)
    ctx.line_to(240, 85)
    ctx.line_to(370, 160)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "goa/old_goa/landmarks/se_cathedral.png")

# ==============================================================================
# 3. NORTH GOA LANDMARKS
# ==============================================================================

def generate_north_goa_landmarks():
    print("\n--- Generating North Goa Landmarks ---")

    # 1. Fort Aguada & 1864 Lighthouse (LOC-GA-10)
    surf, ctx = create_surface(450, 380)
    draw_ground_shadow(ctx, 225, 365, 420, 24)
    # Weathered laterite ramparts
    ctx.set_source_rgb(0.55, 0.32, 0.25)
    ctx.rectangle(40, 220, 370, 140)
    ctx.fill()
    # Gun embrasures
    ctx.set_source_rgb(0.22, 0.15, 0.12)
    for gx in range(60, 380, 40):
        ctx.rectangle(gx, 250, 16, 20)
        ctx.fill()
    # 4-tiered circular stone lighthouse
    ctx.set_source_rgb(0.92, 0.94, 0.96) # Whitewashed cylindrical tower
    ctx.rectangle(175, 100, 100, 140)
    ctx.fill()
    # Tower narrowing tiers
    ctx.rectangle(185, 60, 80, 40)
    ctx.fill()
    # Black iron lantern room
    ctx.set_source_rgb(0.22, 0.25, 0.28)
    ctx.rectangle(195, 25, 60, 35)
    ctx.fill()
    # Glass lantern beacon
    ctx.set_source_rgba(0.98, 0.95, 0.70, 0.9)
    ctx.rectangle(200, 30, 50, 25)
    ctx.fill()
    # Weather vane
    ctx.set_source_rgb(0.20, 0.22, 0.25)
    ctx.rectangle(223, 5, 4, 20)
    ctx.fill()
    save_surface(surf, "goa/north_goa/landmarks/fort_aguada_lighthouse.png")

    # 2. Chapora Fort Ramparts (LOC-GA-11)
    surf, ctx = create_surface(460, 280)
    draw_ground_shadow(ctx, 230, 265, 430, 22)
    # Hilltop rocky red laterite ground
    ctx.set_source_rgb(0.62, 0.35, 0.25)
    ctx.move_to(30, 265)
    ctx.line_to(90, 180)
    ctx.line_to(220, 160)
    ctx.line_to(380, 190)
    ctx.line_to(430, 265)
    ctx.close_path()
    ctx.fill()
    # Jagged stone crenellations (Dil Chahta Hai viewpoint)
    ctx.set_source_rgb(0.48, 0.26, 0.18)
    for bx in range(100, 370, 25):
        ctx.rectangle(bx, 140, 15, 25)
        ctx.fill()
    save_surface(surf, "goa/north_goa/landmarks/chapora_fort.png")

    # 3. Calangute Beach Road & Shacks (LOC-GA-07)
    surf, ctx = create_surface(440, 260)
    draw_ground_shadow(ctx, 220, 245, 410, 20)
    # Golden sand shoreline
    ctx.set_source_rgb(0.92, 0.82, 0.55)
    ctx.rectangle(30, 180, 380, 65)
    ctx.fill()
    # Thatched beach shack
    ctx.set_source_rgb(0.55, 0.40, 0.25) # Bamboo poles
    ctx.rectangle(80, 110, 140, 90)
    ctx.fill()
    draw_sloping_roof(ctx, 65, 65, 170, 45, 10, (0.68, 0.58, 0.35), (0.45, 0.35, 0.20))
    # Colorful beach umbrellas
    ctx.set_source_rgb(0.85, 0.22, 0.25)
    ctx.arc(280, 140, 30, math.pi, 2 * math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.22, 0.55, 0.85)
    ctx.arc(350, 145, 25, math.pi, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "goa/north_goa/landmarks/calangute_beach_promenade.png")

# ==============================================================================
# 4. SOUTH & INLAND GOA LANDMARKS
# ==============================================================================

def generate_south_and_inland_goa_landmarks():
    print("\n--- Generating South & Inland Goa Landmarks ---")

    # 1. Margao Municipal Celebratory Arch (LOC-GA-21)
    surf, ctx = create_surface(420, 320)
    draw_ground_shadow(ctx, 210, 305, 380, 22)
    # Whitewashed Portuguese Manueline ceremonial arch
    ctx.set_source_rgb(0.95, 0.95, 0.98)
    ctx.rectangle(80, 90, 260, 210)
    ctx.fill()
    # Main roadway arch portal
    draw_archway(ctx, 130, 130, 160, 170, (0.82, 0.85, 0.88), (0.18, 0.20, 0.25))
    # Blue and white azulejo border tiles
    for az in range(90, 330, 20):
        ctx.set_source_rgb(0.18, 0.42, 0.82)
        ctx.rectangle(az, 95, 12, 12)
        ctx.fill()
    # Celebratory checkered flag banner & garlands
    ctx.set_source_rgb(0.98, 0.75, 0.15) # Marigold garland
    for g in range(110, 310, 14):
        ctx.arc(g, 125, 6, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "goa/south_goa/landmarks/margao_municipal_arch.png")

    # 2. Dudhsagar Waterfalls (LOC-GA-27) - 4-tiered milky cascade with railway viaduct
    surf, ctx = create_surface(460, 420)
    draw_ground_shadow(ctx, 230, 405, 430, 24)
    # Dense Western Ghats granite cliff
    ctx.set_source_rgb(0.35, 0.38, 0.35)
    ctx.rectangle(40, 50, 380, 350)
    ctx.fill()
    # Milky white torrent of water cascading down
    ctx.set_source_rgba(0.95, 0.98, 1.0, 0.92)
    ctx.move_to(210, 50)
    ctx.line_to(180, 180)
    ctx.line_to(150, 320)
    ctx.line_to(120, 400)
    ctx.line_to(340, 400)
    ctx.line_to(300, 320)
    ctx.line_to(280, 180)
    ctx.line_to(250, 50)
    ctx.close_path()
    ctx.fill()
    # Stone railway viaduct spanning across falls
    ctx.set_source_rgb(0.48, 0.45, 0.42)
    ctx.rectangle(40, 210, 380, 24)
    ctx.fill()
    # Viaduct arches
    for ax in range(70, 380, 65):
        draw_archway(ctx, ax, 215, 35, 30, (0.38, 0.35, 0.32), (0.95, 0.98, 1.0))
    save_surface(surf, "goa/inland_goa/landmarks/dudhsagar_waterfalls.png")

# ==============================================================================
# 5. GOA SUPPORTING SCENERY
# ==============================================================================

def generate_goa_scenery():
    print("\n--- Generating Goa Supporting Scenery ---")

    # Buildings (Fontainhas Yellow, Fontainhas Blue, Coastal Pink, Balcão Villa)
    bldgs = [
        ("house_goa_fontainhas_yellow.png", 240, 170, (0.92, 0.76, 0.18)),
        ("house_goa_fontainhas_blue.png", 230, 165, (0.22, 0.45, 0.75)),
        ("house_goa_coastal_pink.png", 220, 160, (0.88, 0.45, 0.42)),
        ("house_goa_modern_tropical_villa.png", 250, 180, (0.95, 0.95, 0.98)),
        ("house_goa_laterite_cottage.png", 210, 150, (0.65, 0.32, 0.22)),
        ("house_goa_white_chapel_residence.png", 220, 165, (0.92, 0.94, 0.96))
    ]
    for bname, w, h, col in bldgs:
        surf, ctx = create_surface(w, h)
        draw_ground_shadow(ctx, w/2, h - 8, w - 20, 14)
        ctx.set_source_rgb(*col)
        ctx.rectangle(20, h - 95, w - 40, 85)
        ctx.fill()
        draw_sloping_roof(ctx, 15, h - 145, w - 30, 50, 10, (0.78, 0.28, 0.18), (0.45, 0.15, 0.10))
        save_surface(surf, f"goa/panaji/buildings/{bname}")
        save_surface(surf, f"goa/north_goa/buildings/{bname}")
        save_surface(surf, f"goa/south_goa/buildings/{bname}")

    # Vegetation (Curved coconut palm, Rain tree, Fruiting Cashew, Frangipani)
    # 1. Leaning coastal coconut palm
    surf, ctx = create_surface(180, 280)
    draw_ground_shadow(ctx, 90, 270, 90, 14)
    ctx.set_source_rgb(0.48, 0.38, 0.28)
    ctx.move_to(80, 270)
    ctx.curve_to(110, 180, 125, 110, 105, 60)
    ctx.line_to(95, 60)
    ctx.curve_to(115, 110, 100, 180, 70, 270)
    ctx.close_path()
    ctx.fill()
    # Palm fronds radiating
    ctx.set_source_rgb(0.18, 0.58, 0.22)
    for a in range(8):
        ang = a * (math.pi / 4)
        ctx.arc(100 + math.cos(ang) * 45, 60 + math.sin(ang) * 25, 26, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "goa/panaji/vegetation/tree_goa_coconut_beach.png")

    # 2. Flowering Frangipani (Champa)
    surf, ctx = create_surface(180, 180)
    draw_ground_shadow(ctx, 90, 172, 120, 14)
    ctx.set_source_rgb(0.42, 0.38, 0.32) # Smooth grey branches
    ctx.rectangle(85, 80, 10, 90)
    ctx.fill()
    # White & yellow fragrant flowers amidst fleshy leaves
    ctx.set_source_rgb(0.22, 0.52, 0.25)
    for fx in [60, 90, 120]:
        ctx.arc(fx, 65, 25, 0, 2 * math.pi)
        ctx.fill()
    ctx.set_source_rgb(0.98, 0.98, 0.95)
    for fx in [55, 75, 95, 115]:
        ctx.arc(fx, 60, 6, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "goa/panaji/vegetation/tree_goa_frangipani_champa.png")

    # Roadside Props (Pao bakery, Beach shack, Surfboard rack, Canoe)
    surf, ctx = create_surface(160, 130)
    draw_ground_shadow(ctx, 80, 122, 140, 12)
    ctx.set_source_rgb(0.92, 0.88, 0.82) # Bakery kiosk
    ctx.rectangle(25, 45, 110, 75)
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.42, 0.18) # Portuguese pao loaves
    for px in range(35, 120, 20):
        ctx.arc(px, 75, 8, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "goa/panaji/roadside_props/shop_goa_pao_bakery.png")

    # Surfboard rack
    surf, ctx = create_surface(140, 110)
    draw_ground_shadow(ctx, 70, 104, 120, 10)
    ctx.set_source_rgb(0.45, 0.32, 0.22) # Wooden frame
    ctx.rectangle(20, 30, 8, 75)
    ctx.rectangle(110, 30, 8, 75)
    ctx.fill()
    # Surfboards leaning
    s_colors = [(0.92, 0.25, 0.25), (0.25, 0.65, 0.92), (0.95, 0.85, 0.15)]
    for idx, scol in enumerate(s_colors):
        ctx.set_source_rgb(*scol)
        ctx.rectangle(35 + idx * 25, 20, 16, 80)
        ctx.fill()
    save_surface(surf, "goa/north_goa/roadside_props/prop_goa_surfboard_rack.png")

def main():
    print("==================================================")
    print("STARTING GOA ASSET COLLECTION V2 GENERATION")
    print("==================================================")
    generate_panaji_landmarks()
    generate_old_goa_landmarks()
    generate_north_goa_landmarks()
    generate_south_and_inland_goa_landmarks()
    generate_goa_scenery()
    print("==================================================")
    print("GOA V2 ASSETS GENERATED SUCCESSFULLY!")
    print("==================================================")

if __name__ == "__main__":
    main()
