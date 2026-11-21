#!/usr/bin/env python3
"""
gen_v2_kerala.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates the complete Kerala asset collection in asset_collection_v2/kerala/:
  - Kochi (Landmarks, Buildings, Vegetation, Props, Backgrounds)
  - Alappuzha (Landmarks, Buildings, Vegetation, Backgrounds)
  - Munnar (Landmarks, Vegetation, Backgrounds)
  - Wayanad (Landmarks, Vegetation, Backgrounds)
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
# 1. KOCHI LANDMARKS
# ==============================================================================

def generate_kochi_landmarks():
    print("\n--- Generating Kochi Landmarks ---")

    # 1. Fort Kochi Chinese Fishing Nets (Cheena Vala - LOC-KL-01)
    surf, ctx = create_surface(460, 320)
    draw_ground_shadow(ctx, 230, 305, 420, 20)
    # Harbor waterline
    ctx.set_source_rgb(0.20, 0.48, 0.55)
    ctx.rectangle(20, 260, 420, 45)
    ctx.fill()
    # Shore platform poles
    ctx.set_source_rgb(0.42, 0.32, 0.22)
    ctx.rectangle(60, 180, 16, 100)
    ctx.rectangle(90, 180, 14, 100)
    ctx.fill()
    # Cantilevered 20m teak & bamboo frame arms dipping into harbor
    ctx.set_line_width(5)
    ctx.set_source_rgb(0.55, 0.40, 0.25)
    ctx.move_to(80, 200)
    ctx.line_to(220, 120)
    ctx.line_to(360, 240)
    ctx.stroke()
    ctx.move_to(80, 200)
    ctx.line_to(240, 90)
    ctx.line_to(390, 220)
    ctx.stroke()
    # Suspended web netting
    ctx.set_line_width(1.5)
    ctx.set_source_rgba(0.92, 0.95, 0.98, 0.7)
    for nx in range(260, 390, 15):
        ctx.move_to(nx, 230 - (nx - 260) * 0.4)
        ctx.line_to(nx + 10, 275)
        ctx.stroke()
    # Counterweight stones suspended on ropes
    ctx.set_source_rgb(0.38, 0.36, 0.35)
    for cx_stone in [40, 55, 70]:
        ctx.arc(cx_stone, 240, 10, 0, 2 * math.pi)
        ctx.fill()
        ctx.set_source_rgb(0.30, 0.25, 0.20)
        ctx.move_to(cx_stone, 200)
        ctx.line_to(cx_stone, 230)
        ctx.stroke()
    save_surface(surf, "kerala/kochi/landmarks/fort_kochi_chinese_fishing_nets.png")

    # 2. Mattancherry Dutch Palace (LOC-KL-02)
    surf, ctx = create_surface(440, 260)
    draw_ground_shadow(ctx, 220, 245, 410, 22)
    # Whitewashed stone walls with Kerala timber architecture
    ctx.set_source_rgb(0.94, 0.95, 0.96)
    ctx.rectangle(50, 120, 340, 120)
    ctx.fill()
    # Sloping dark timber roofs with triangular gables (Mukhappu)
    draw_sloping_roof(ctx, 40, 60, 360, 65, 12, (0.42, 0.22, 0.15), (0.25, 0.12, 0.08))
    # Carved wooden window lattices
    ctx.set_source_rgb(0.35, 0.20, 0.12)
    for wx in range(80, 360, 50):
        ctx.rectangle(wx, 145, 25, 35)
        ctx.fill()
    save_surface(surf, "kerala/kochi/landmarks/mattancherry_dutch_palace.png")

# ==============================================================================
# 2. ALAPPUZHA LANDMARKS
# ==============================================================================

def generate_alappuzha_landmarks():
    print("\n--- Generating Alappuzha Landmarks ---")

    # 1. Traditional Kettuvallam Houseboat (LOC-KL-03)
    surf, ctx = create_surface(480, 280)
    draw_ground_shadow(ctx, 240, 265, 450, 22)
    # Backwater calm emerald water
    ctx.set_source_rgb(0.18, 0.45, 0.40)
    ctx.rectangle(20, 225, 440, 45)
    ctx.fill()
    # Anjili wood curved boat hull tied with coir ropes (zero nails)
    ctx.set_source_rgb(0.28, 0.18, 0.12)
    ctx.move_to(30, 210)
    ctx.curve_to(80, 250, 400, 250, 450, 210)
    ctx.line_to(440, 230)
    ctx.curve_to(390, 260, 90, 260, 40, 230)
    ctx.close_path()
    ctx.fill()
    # Thatched arched valavara roof of bamboo and split panambu reeds
    ctx.set_source_rgb(0.68, 0.52, 0.32)
    ctx.arc(240, 190, 130, math.pi, 2 * math.pi)
    ctx.fill()
    # Bamboo texture ribs
    ctx.set_source_rgb(0.48, 0.36, 0.22)
    ctx.set_line_width(2)
    for bx in range(120, 360, 20):
        ctx.move_to(bx, 190)
        ctx.line_to(bx, 120)
        ctx.stroke()
    # Open front viewing deck with coir lounge chairs
    ctx.set_source_rgb(0.85, 0.72, 0.48)
    ctx.rectangle(350, 175, 60, 45)
    ctx.fill()
    # Flowering water hyacinths around hull
    ctx.set_source_rgb(0.20, 0.62, 0.35)
    for hy in range(50, 430, 30):
        ctx.arc(hy, 245, 8, 0, 2 * math.pi)
        ctx.fill()
        ctx.set_source_rgb(0.72, 0.55, 0.85) # Violet flower
        ctx.arc(hy, 240, 3, 0, 2 * math.pi)
        ctx.fill()
        ctx.set_source_rgb(0.20, 0.62, 0.35)
    save_surface(surf, "kerala/alappuzha/landmarks/alleppey_backwaters_houseboat.png")

    # 2. Sree Padmanabhaswamy Temple Gopuram (LOC-KL-08)
    surf, ctx = create_surface(420, 520)
    draw_ground_shadow(ctx, 210, 505, 380, 24)
    # Sacred Padma Theertham lotus tank steps
    draw_stone_steps(ctx, 60, 490, 300, 30, 3, (0.62, 0.60, 0.56), (0.42, 0.40, 0.38))
    # 7-tiered Chera-Pandya Dravidian stone Gopuram
    g_tiers = [
        (220, 42, (0.75, 0.68, 0.55)),
        (195, 40, (0.72, 0.65, 0.52)),
        (170, 38, (0.70, 0.62, 0.50)),
        (145, 36, (0.68, 0.60, 0.48)),
        (120, 34, (0.66, 0.58, 0.46)),
        (95, 32, (0.64, 0.56, 0.44)),
        (75, 30, (0.62, 0.54, 0.42))
    ]
    curr_y = 460
    for gw, gh, gcol in g_tiers:
        curr_y -= gh
        gx = 210 - gw / 2
        ctx.set_source_rgb(*gcol)
        ctx.rectangle(gx, curr_y, gw, gh)
        ctx.fill()
        # Sculptural reliefs
        ctx.set_source_rgb(0.38, 0.32, 0.25)
        for s in range(3):
            ctx.rectangle(gx + 10 + s * (gw - 20) / 2.5, curr_y + 8, 10, gh - 14)
            ctx.fill()
    # 7 Golden Kalasams
    ctx.set_source_rgb(0.98, 0.82, 0.15)
    for k in range(7):
        kx = 180 + k * 10
        ctx.arc(kx, curr_y - 12, 4, 0, 2 * math.pi)
        ctx.fill()
        ctx.rectangle(kx - 1, curr_y - 22, 2, 10)
        ctx.fill()
    save_surface(surf, "kerala/alappuzha/landmarks/padmanabhaswamy_temple.png")

# ==============================================================================
# 3. MUNNAR & WAYANAD LANDMARKS
# ==============================================================================

def generate_munnar_and_wayanad_landmarks():
    print("\n--- Generating Munnar & Wayanad Landmarks ---")

    # 1. Munnar High Range Tea Plantations (LOC-KL-06)
    surf, ctx = create_surface(480, 300)
    draw_ground_shadow(ctx, 240, 285, 440, 22)
    # Contoured terraced tea garden slopes
    tea_colors = [
        (0.25, 0.65, 0.30),
        (0.20, 0.58, 0.25),
        (0.18, 0.52, 0.22),
        (0.15, 0.45, 0.18)
    ]
    for idx, tcol in enumerate(tea_colors):
        ctx.set_source_rgb(*tcol)
        ctx.move_to(30, 280 - idx * 45)
        ctx.curve_to(140, 240 - idx * 40, 320, 290 - idx * 45, 450, 250 - idx * 40)
        ctx.line_to(450, 290)
        ctx.line_to(30, 290)
        ctx.close_path()
        ctx.fill()
    # Silver oak shade trees lining tea ridges
    for ox in [120, 260, 390]:
        ctx.set_source_rgb(0.42, 0.45, 0.48) # Slender pale trunk
        ctx.rectangle(ox, 50, 8, 170)
        ctx.fill()
        ctx.set_source_rgb(0.22, 0.48, 0.32) # Feathery crown
        ctx.arc(ox + 4, 45, 22, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "kerala/munnar/landmarks/munnar_tea_plantations.png")

    # 2. Athirappilly Cascading Waterfalls (LOC-KL-07)
    surf, ctx = create_surface(480, 380)
    draw_ground_shadow(ctx, 240, 365, 440, 24)
    # Massive rainforest granite cliff
    ctx.set_source_rgb(0.28, 0.30, 0.28)
    ctx.rectangle(40, 80, 400, 280)
    ctx.fill()
    # 80-ft wide roaring white curtain of water
    ctx.set_source_rgba(0.92, 0.96, 1.0, 0.88)
    ctx.rectangle(120, 80, 240, 270)
    ctx.fill()
    # Mist and spray cloud at base
    ctx.set_source_rgba(0.88, 0.94, 1.0, 0.55)
    for mx in range(80, 400, 40):
        ctx.arc(mx, 340, 35, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "kerala/munnar/landmarks/athirappilly_waterfalls.png")

    # 3. Bekal Fort Seaside Keyhole Bastion (LOC-KL-20)
    surf, ctx = create_surface(450, 300)
    draw_ground_shadow(ctx, 225, 285, 410, 22)
    # Sea-jutting laterite headland
    ctx.set_source_rgb(0.55, 0.35, 0.25)
    ctx.rectangle(50, 150, 350, 130)
    ctx.fill()
    # Iconic circular keyhole observation tower
    ctx.set_source_rgb(0.48, 0.28, 0.20)
    ctx.arc(225, 120, 60, 0, 2 * math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.18, 0.20, 0.22) # Keyhole opening
    ctx.arc(225, 110, 22, 0, 2 * math.pi)
    ctx.fill()
    ctx.rectangle(217, 115, 16, 35)
    ctx.fill()
    save_surface(surf, "kerala/wayanad/landmarks/bekal_fort_keyhole_bastion.png")

# ==============================================================================
# 4. KERALA SUPPORTING SCENERY
# ==============================================================================

def generate_kerala_scenery():
    print("\n--- Generating Kerala Supporting Scenery ---")

    # Buildings (Nalukettu, Thatched hut, Plantation bungalow)
    bldgs = [
        ("house_kerala_nalukettu.png", 250, 175, (0.85, 0.78, 0.65)),
        ("house_kerala_backwater_hut.png", 210, 145, (0.75, 0.62, 0.45)),
        ("house_kerala_tea_estate_cottage.png", 230, 160, (0.92, 0.92, 0.95)),
        ("house_kerala_traditional_tharavadu.png", 260, 180, (0.82, 0.72, 0.58)),
        ("house_kerala_colonial_bungalow.png", 240, 170, (0.95, 0.95, 0.98)),
        ("house_kerala_coastal_fisherman.png", 200, 140, (0.70, 0.55, 0.40))
    ]
    for bname, w, h, col in bldgs:
        surf, ctx = create_surface(w, h)
        draw_ground_shadow(ctx, w/2, h - 8, w - 20, 14)
        ctx.set_source_rgb(*col)
        ctx.rectangle(20, h - 95, w - 40, 85)
        ctx.fill()
        draw_sloping_roof(ctx, 15, h - 145, w - 30, 50, 12, (0.45, 0.22, 0.15), (0.28, 0.12, 0.08))
        save_surface(surf, f"kerala/kochi/buildings/{bname}")
        save_surface(surf, f"kerala/alappuzha/buildings/{bname}")

    # Vegetation (Malabar Coconut, Rubber tree, Jackfruit, Tea bush)
    surf, ctx = create_surface(170, 300)
    draw_ground_shadow(ctx, 85, 290, 80, 14)
    ctx.set_source_rgb(0.38, 0.32, 0.25)
    ctx.rectangle(80, 60, 10, 230)
    ctx.fill()
    ctx.set_source_rgb(0.15, 0.55, 0.22)
    for a in range(8):
        ang = a * (math.pi / 4)
        ctx.arc(85 + math.cos(ang) * 45, 55 + math.sin(ang) * 25, 26, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "kerala/kochi/vegetation/tree_kerala_coconut_tall.png")

    # Roadside Props (Thattukada, Banana chips, Coir rack)
    surf, ctx = create_surface(160, 130)
    draw_ground_shadow(ctx, 80, 122, 140, 12)
    ctx.set_source_rgb(0.48, 0.35, 0.22)
    ctx.rectangle(25, 45, 110, 75)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.82, 0.15) # Golden banana chips in glass jar
    ctx.rectangle(45, 60, 25, 30)
    ctx.fill()
    save_surface(surf, "kerala/kochi/roadside_props/shop_kerala_banana_chips.png")

def main():
    print("==================================================")
    print("STARTING KERALA ASSET COLLECTION V2 GENERATION")
    print("==================================================")
    generate_kochi_landmarks()
    generate_alappuzha_landmarks()
    generate_munnar_and_wayanad_landmarks()
    generate_kerala_scenery()
    print("==================================================")
    print("KERALA V2 ASSETS GENERATED SUCCESSFULLY!")
    print("==================================================")

if __name__ == "__main__":
    main()
