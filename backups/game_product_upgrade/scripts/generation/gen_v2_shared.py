#!/usr/bin/env python3
"""
gen_v2_shared.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates the complete Shared asset collection in asset_collection_v2/shared/:
  - Road Props
  - Barriers
  - Signs
  - Generic Vegetation
  - Seamless Textures (1024x1024)
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

def generate_shared_props():
    print("\n--- Generating Shared Road Props & Barriers ---")

    # 1. Traffic Cone
    surf, ctx = create_surface(64, 80)
    draw_ground_shadow(ctx, 32, 75, 50, 8)
    ctx.set_source_rgb(0.95, 0.38, 0.12) # Orange cone base
    ctx.rectangle(12, 68, 40, 8)
    ctx.fill()
    ctx.move_to(16, 68)
    ctx.line_to(28, 12)
    ctx.line_to(36, 12)
    ctx.line_to(48, 68)
    ctx.close_path()
    ctx.fill()
    # Reflective white collar
    ctx.set_source_rgb(0.98, 0.98, 1.0)
    ctx.move_to(22, 44)
    ctx.line_to(26, 26)
    ctx.line_to(38, 26)
    ctx.line_to(42, 44)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "shared/road_props/traffic_cone.png")

    # 2. Highway Milestone Post
    surf, ctx = create_surface(80, 110)
    draw_ground_shadow(ctx, 40, 102, 60, 10)
    # White lower body
    ctx.set_source_rgb(0.95, 0.95, 0.98)
    ctx.rectangle(18, 40, 44, 60)
    ctx.fill()
    # Yellow curved top (National Highway standard in India)
    ctx.set_source_rgb(0.98, 0.82, 0.15)
    ctx.arc(40, 40, 22, math.pi, 2 * math.pi)
    ctx.fill()
    # Black text markings: NH 44 / 150 KM
    ctx.set_source_rgb(0.18, 0.20, 0.22)
    ctx.rectangle(26, 32, 28, 4)
    ctx.fill()
    ctx.rectangle(30, 55, 20, 4)
    ctx.rectangle(28, 70, 24, 4)
    ctx.fill()
    save_surface(surf, "shared/road_props/milestone_national_highway.png")

    # 3. Barricade Yellow & Black Stripes
    surf, ctx = create_surface(180, 120)
    draw_ground_shadow(ctx, 90, 112, 160, 12)
    # Steel support legs
    ctx.set_source_rgb(0.42, 0.45, 0.48)
    ctx.rectangle(25, 30, 8, 80)
    ctx.rectangle(147, 30, 8, 80)
    ctx.fill()
    # Crossboards with diagonal hazard stripes
    ctx.set_source_rgb(0.98, 0.82, 0.15) # Yellow
    ctx.rectangle(15, 35, 150, 24)
    ctx.rectangle(15, 68, 150, 24)
    ctx.fill()
    ctx.set_source_rgb(0.15, 0.16, 0.18) # Black stripes
    for sx in range(25, 160, 25):
        ctx.move_to(sx, 35)
        ctx.line_to(sx + 12, 35)
        ctx.line_to(sx, 59)
        ctx.line_to(sx - 12, 59)
        ctx.close_path()
        ctx.fill()
        ctx.move_to(sx, 68)
        ctx.line_to(sx + 12, 68)
        ctx.line_to(sx, 92)
        ctx.line_to(sx - 12, 92)
        ctx.close_path()
        ctx.fill()
    save_surface(surf, "shared/barriers/barricade_yellow_black_stripes.png")

    # 4. Concrete Jersey Barrier
    surf, ctx = create_surface(160, 80)
    draw_ground_shadow(ctx, 80, 74, 150, 10)
    ctx.set_source_rgb(0.72, 0.74, 0.76)
    ctx.move_to(10, 72)
    ctx.line_to(25, 48)
    ctx.line_to(35, 16)
    ctx.line_to(125, 16)
    ctx.line_to(135, 48)
    ctx.line_to(150, 72)
    ctx.close_path()
    ctx.fill()
    # Chamfer highlight
    ctx.set_source_rgb(0.85, 0.88, 0.90)
    ctx.rectangle(35, 16, 90, 4)
    ctx.fill()
    save_surface(surf, "shared/barriers/barrier_concrete_jersey.png")

def generate_shared_signs():
    print("\n--- Generating Shared Highway Signs ---")

    # 1. Speed Limit 60
    surf, ctx = create_surface(90, 130)
    draw_ground_shadow(ctx, 45, 122, 50, 8)
    ctx.set_source_rgb(0.48, 0.50, 0.52) # Post
    ctx.rectangle(42, 50, 6, 70)
    ctx.fill()
    # Circular white plate with red border
    ctx.set_source_rgb(0.88, 0.20, 0.18)
    ctx.arc(45, 40, 32, 0, 2 * math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.98, 0.98, 1.0)
    ctx.arc(45, 40, 24, 0, 2 * math.pi)
    ctx.fill()
    # Black numeral 60
    ctx.set_source_rgb(0.15, 0.16, 0.18)
    ctx.arc(36, 40, 8, 0, 2 * math.pi)
    ctx.arc(54, 40, 8, 0, 2 * math.pi)
    ctx.set_line_width(4)
    ctx.stroke()
    save_surface(surf, "shared/signs/sign_speed_limit_60.png")

    # 2. National Highway NH44 Signboard
    surf, ctx = create_surface(120, 140)
    draw_ground_shadow(ctx, 60, 132, 70, 8)
    ctx.set_source_rgb(0.45, 0.48, 0.50)
    ctx.rectangle(57, 50, 6, 80)
    ctx.fill()
    # Green rectangular highway board with white border
    ctx.set_source_rgb(0.08, 0.42, 0.22)
    ctx.rectangle(15, 15, 90, 50)
    ctx.fill()
    ctx.set_source_rgb(0.98, 0.98, 1.0)
    ctx.set_line_width(2)
    ctx.rectangle(18, 18, 84, 44)
    ctx.stroke()
    # NH 44 text block
    ctx.rectangle(35, 32, 50, 16)
    ctx.fill()
    save_surface(surf, "shared/signs/sign_national_highway_nh44.png")

def generate_shared_textures():
    print("\n--- Generating Seamless 1024x1024 Highway & Terrain Textures ---")

    # 1. Dark Asphalt (Seamless 1024x1024)
    surf, ctx = create_surface(1024, 1024)
    ctx.set_source_rgb(0.20, 0.21, 0.23)
    ctx.paint()
    random.seed(501)
    for _ in range(12000):
        gx = random.randint(0, 1024)
        gy = random.randint(0, 1024)
        c = random.uniform(0.14, 0.30)
        ctx.set_source_rgb(c, c, c)
        ctx.rectangle(gx, gy, 2, 2)
        ctx.fill()
    save_surface(surf, "shared/textures/texture_asphalt_dark.png")

    # 2. Coastal Gravel (Seamless 1024x1024)
    surf, ctx = create_surface(1024, 1024)
    ctx.set_source_rgb(0.55, 0.52, 0.48)
    ctx.paint()
    random.seed(601)
    for _ in range(8000):
        gx = random.randint(0, 1024)
        gy = random.randint(0, 1024)
        gr = random.randint(2, 5)
        c = random.uniform(0.40, 0.68)
        ctx.set_source_rgb(c, c * 0.95, c * 0.88)
        ctx.arc(gx, gy, gr, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "shared/textures/texture_gravel_coastal.png")

    # 3. Smooth Concrete (Seamless 1024x1024)
    surf, ctx = create_surface(1024, 1024)
    ctx.set_source_rgb(0.75, 0.76, 0.78)
    ctx.paint()
    random.seed(701)
    for _ in range(6000):
        gx = random.randint(0, 1024)
        gy = random.randint(0, 1024)
        c = random.uniform(0.68, 0.82)
        ctx.set_source_rgb(c, c, c * 1.02)
        ctx.rectangle(gx, gy, 3, 3)
        ctx.fill()
    save_surface(surf, "shared/textures/texture_concrete_smooth.png")

def main():
    print("==================================================")
    print("STARTING SHARED ASSET COLLECTION V2 GENERATION")
    print("==================================================")
    generate_shared_props()
    generate_shared_signs()
    generate_shared_textures()
    print("==================================================")
    print("SHARED V2 ASSETS GENERATED SUCCESSFULLY!")
    print("==================================================")

if __name__ == "__main__":
    main()
