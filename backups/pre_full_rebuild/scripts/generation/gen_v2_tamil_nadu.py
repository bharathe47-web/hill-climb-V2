#!/usr/bin/env python3
"""
gen_v2_tamil_nadu.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates the complete Tamil Nadu asset collection in asset_collection_v2/tamil_nadu/:
  - Kanyakumari (Landmarks, Buildings, Vegetation, Props, Backgrounds, Textures)
  - Madurai (Landmarks, Buildings, Vegetation, Backgrounds)
  - Chennai & Delta (Landmarks, Buildings, Vegetation, Backgrounds)
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
# 1. KANYAKUMARI LANDMARKS
# ==============================================================================

def generate_kanyakumari_landmarks():
    print("\n--- Generating Kanyakumari Landmarks ---")

    # 1. Thiruvalluvar Statue (LOC-TN-01) - 133-ft monolithic granite statue
    surf, ctx = create_surface(400, 600)
    # Sea rock pedestal (38-ft base representing 38 chapters of Aram/Virtue)
    draw_ground_shadow(ctx, 200, 580, 360, 24)
    ctx.set_source_rgb(0.35, 0.36, 0.40) # Granite dark plinth
    ctx.rectangle(90, 480, 220, 100)
    ctx.fill()
    # Plinth architectural relief mouldings
    ctx.set_source_rgb(0.48, 0.50, 0.55)
    ctx.rectangle(75, 470, 250, 14)
    ctx.fill()
    ctx.set_source_rgb(0.28, 0.30, 0.34)
    ctx.rectangle(105, 495, 190, 70)
    ctx.fill()
    # Statue Body (95-ft representing 95 chapters of Porul & Inbam)
    ctx.set_source_rgb(0.42, 0.44, 0.48) # Chiseled granite stone
    # Robe / Dhoti flow
    ctx.move_to(140, 470)
    ctx.line_to(125, 300)
    ctx.line_to(155, 230)
    ctx.line_to(245, 230)
    ctx.line_to(275, 300)
    ctx.line_to(260, 470)
    ctx.close_path()
    ctx.fill()
    # Torso & Shoulders
    ctx.rectangle(150, 180, 100, 110)
    ctx.fill()
    # Left Arm holding palm-leaf manuscript (Olai chuvadi)
    ctx.set_source_rgb(0.38, 0.40, 0.44)
    ctx.rectangle(125, 230, 30, 85)
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.80, 0.65) # Manuscript scroll
    ctx.rectangle(120, 305, 38, 14)
    ctx.fill()
    # Right Arm raised upwards with 3 fingers pointing to heavens
    ctx.set_source_rgb(0.38, 0.40, 0.44)
    ctx.move_to(245, 220)
    ctx.line_to(275, 170)
    ctx.line_to(290, 175)
    ctx.line_to(265, 240)
    ctx.close_path()
    ctx.fill()
    # Forearm & Hand pointing up
    ctx.rectangle(270, 110, 22, 65)
    ctx.fill()
    # Head & Ancient Beard
    ctx.set_source_rgb(0.45, 0.47, 0.52)
    ctx.arc(200, 145, 32, 0, 2 * math.pi)
    ctx.fill()
    # Ascetic topknot hair (Kudumi)
    ctx.arc(200, 108, 18, 0, 2 * math.pi)
    ctx.fill()
    # Flowing sage beard
    ctx.set_source_rgb(0.36, 0.38, 0.42)
    ctx.move_to(182, 155)
    ctx.line_to(200, 205)
    ctx.line_to(218, 155)
    ctx.close_path()
    ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/landmarks/thiruvalluvar_statue.png")

    # 2. Vivekananda Rock Memorial (LOC-TN-02)
    surf, ctx = create_surface(500, 350)
    draw_ground_shadow(ctx, 250, 335, 460, 26)
    # Natural offshore granite rocky reef
    ctx.set_source_rgb(0.32, 0.30, 0.28)
    ctx.move_to(30, 335)
    ctx.line_to(80, 270)
    ctx.line_to(160, 280)
    ctx.line_to(250, 250)
    ctx.line_to(350, 270)
    ctx.line_to(440, 260)
    ctx.line_to(470, 335)
    ctx.close_path()
    ctx.fill()
    # Shripada Mandapam & Vivekananda Sabha Mandapam
    # Red laterite stone plinth
    draw_stone_steps(ctx, 110, 255, 280, 35, 3, (0.82, 0.36, 0.28), (0.62, 0.22, 0.16))
    # Cream stone sanctum hall
    ctx.set_source_rgb(0.92, 0.88, 0.78)
    ctx.rectangle(130, 150, 240, 75)
    ctx.fill()
    # Pillared colonnade
    draw_pillared_veranda(ctx, 140, 155, 220, 65, 7, 8, (0.78, 0.72, 0.62), (0.65, 0.25, 0.18))
    # Orissan & Dravidian blended central tower dome
    ctx.set_source_rgb(0.76, 0.30, 0.22) # Terracotta red shikhara
    ctx.move_to(210, 150)
    ctx.line_to(250, 70)
    ctx.line_to(290, 150)
    ctx.close_path()
    ctx.fill()
    # Kalasam on peak
    ctx.set_source_rgb(0.98, 0.82, 0.18)
    ctx.arc(250, 62, 8, 0, 2 * math.pi)
    ctx.fill()
    ctx.rectangle(248, 48, 4, 14)
    ctx.fill()
    # Surrounding crashing sea spray foam
    ctx.set_source_rgba(0.90, 0.96, 1.0, 0.75)
    for fx in range(40, 460, 35):
        ctx.arc(fx, 328, 14, math.pi, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/landmarks/vivekananda_rock_memorial.png")

    # 3. Kanyakumari Glass Bridge (LOC-TN-10)
    surf, ctx = create_surface(450, 260)
    draw_ground_shadow(ctx, 225, 245, 420, 20)
    # Cantilevered steel pylons
    ctx.set_source_rgb(0.20, 0.45, 0.85) # Maritime blue steel
    ctx.rectangle(50, 60, 25, 185)
    ctx.fill()
    ctx.rectangle(375, 60, 25, 185)
    ctx.fill()
    # Cable stays
    ctx.set_line_width(2)
    ctx.set_source_rgba(0.85, 0.90, 0.95, 0.8)
    for c in range(5):
        ctx.move_to(62, 75)
        ctx.line_to(110 + c * 50, 160)
        ctx.stroke()
        ctx.move_to(387, 75)
        ctx.line_to(340 - c * 50, 160)
        ctx.stroke()
    # Transparent laminated cyan glass deck
    ctx.set_source_rgba(0.30, 0.85, 0.95, 0.65)
    ctx.rectangle(40, 160, 370, 18)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.98, 1.0)
    ctx.set_line_width(3)
    ctx.rectangle(40, 160, 370, 18)
    ctx.stroke()
    # Safety glass balustrade railing
    ctx.set_source_rgba(0.70, 0.92, 1.0, 0.45)
    ctx.rectangle(40, 132, 370, 28)
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.88, 0.92)
    ctx.set_line_width(2)
    ctx.move_to(40, 132)
    ctx.line_to(410, 132)
    ctx.stroke()
    save_surface(surf, "tamil_nadu/kanyakumari/landmarks/kanyakumari_glass_bridge.png")

    # 4. Kumari Amman Temple (LOC-TN-04)
    surf, ctx = create_surface(380, 420)
    draw_ground_shadow(ctx, 190, 405, 340, 22)
    # Granite stone perimeter temple wall with red and white namam stripes
    for stripe in range(12):
        col = (0.85, 0.22, 0.18) if stripe % 2 == 0 else (0.95, 0.95, 0.95)
        ctx.set_source_rgb(*col)
        ctx.rectangle(40 + stripe * 25, 290, 25, 115)
        ctx.fill()
    # Dravidian Shore Gopuram
    draw_stone_steps(ctx, 80, 290, 220, 25, 2, (0.75, 0.72, 0.68), (0.55, 0.52, 0.48))
    # 5-tier Gopuram tower
    g_widths = [200, 175, 150, 125, 100]
    g_colors = [(0.88, 0.78, 0.58), (0.85, 0.42, 0.32), (0.82, 0.75, 0.52), (0.78, 0.38, 0.28), (0.85, 0.80, 0.60)]
    for idx, gw in enumerate(g_widths):
        gx = 190 - gw / 2
        gy = 265 - idx * 38
        ctx.set_source_rgb(*g_colors[idx])
        ctx.rectangle(gx, gy, gw, 36)
        ctx.fill()
        # Miniature sculptured niches
        ctx.set_source_rgb(0.35, 0.18, 0.12)
        for n in range(3):
            ctx.rectangle(gx + 15 + n * (gw - 30) / 2.5, gy + 10, 14, 18)
            ctx.fill()
    # Golden Kalasam finials (3 pot crests)
    ctx.set_source_rgb(0.98, 0.82, 0.15)
    for k in [-20, 0, 20]:
        ctx.arc(190 + k, 70, 7, 0, 2 * math.pi)
        ctx.fill()
        ctx.rectangle(190 + k - 2, 58, 4, 12)
        ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/landmarks/kumari_amman_temple.png")

    # 5. Gandhi Memorial Mandapam (LOC-TN-05)
    surf, ctx = create_surface(360, 440)
    draw_ground_shadow(ctx, 180, 425, 320, 22)
    # Pink Orissan stone base
    ctx.set_source_rgb(0.88, 0.58, 0.55)
    ctx.rectangle(60, 300, 240, 125)
    ctx.fill()
    # Colonnaded portico
    draw_pillared_veranda(ctx, 80, 310, 200, 110, 5, 12, (0.95, 0.78, 0.75), (0.75, 0.45, 0.42))
    # 79-foot Central Pink Shikhara Tower (memorializing Gandhi's 79 years)
    ctx.set_source_rgb(0.90, 0.62, 0.58)
    ctx.move_to(110, 300)
    ctx.curve_to(140, 180, 150, 100, 180, 70)
    ctx.curve_to(210, 100, 220, 180, 250, 300)
    ctx.close_path()
    ctx.fill()
    # Sun aperture dome on peak
    ctx.set_source_rgb(0.98, 0.92, 0.75)
    ctx.arc(180, 65, 14, 0, 2 * math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.45, 0.40)
    ctx.rectangle(177, 42, 6, 20)
    ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/landmarks/gandhi_memorial_mandapam.png")

    # 6. Vattakottai Fort (LOC-TN-07) - Circular 18th century seaside granite fort
    surf, ctx = create_surface(480, 280)
    draw_ground_shadow(ctx, 240, 265, 440, 24)
    # Weathered coastal granite blocks
    ctx.set_source_rgb(0.38, 0.40, 0.42)
    ctx.rectangle(50, 140, 380, 125)
    ctx.fill()
    # Circular watchtower bastions
    ctx.arc(70, 180, 45, 0, 2 * math.pi)
    ctx.fill()
    ctx.arc(410, 180, 45, 0, 2 * math.pi)
    ctx.fill()
    # Crenellated battlements & cannon ports
    ctx.set_source_rgb(0.48, 0.50, 0.52)
    for bx in range(50, 430, 28):
        ctx.rectangle(bx, 120, 16, 22)
        ctx.fill()
        # Cannon embrasure
        ctx.set_source_rgb(0.20, 0.22, 0.24)
        ctx.rectangle(bx + 4, 165, 8, 12)
        ctx.fill()
        ctx.set_source_rgb(0.48, 0.50, 0.52)
    # Coconut palm rising from fort courtyard
    ctx.set_source_rgb(0.45, 0.32, 0.22)
    ctx.rectangle(235, 60, 10, 80)
    ctx.fill()
    ctx.set_source_rgb(0.18, 0.55, 0.22)
    for a in range(6):
        ang = a * (math.pi / 3)
        ctx.arc(240 + math.cos(ang) * 35, 55 + math.sin(ang) * 20, 25, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/landmarks/vattakottai_fort.png")

    # 7. Mathoor Aqueduct (LOC-TN-11)
    surf, ctx = create_surface(520, 280)
    draw_ground_shadow(ctx, 260, 265, 480, 22)
    # Concrete flume trough carrying water across Pahrali river valley
    ctx.set_source_rgb(0.55, 0.56, 0.58)
    ctx.rectangle(30, 70, 460, 32)
    ctx.fill()
    # Water stream glimpse
    ctx.set_source_rgb(0.35, 0.65, 0.85)
    ctx.rectangle(35, 74, 450, 10)
    ctx.fill()
    # 28 monumental supporting tall concrete pillars
    ctx.set_source_rgb(0.45, 0.46, 0.48)
    for px in range(70, 480, 70):
        ctx.rectangle(px, 102, 22, 160)
        ctx.fill()
        # Strut braces
        ctx.set_source_rgb(0.40, 0.42, 0.44)
        ctx.rectangle(px - 6, 140, 34, 10)
        ctx.fill()
        ctx.set_source_rgb(0.45, 0.46, 0.48)
    save_surface(surf, "tamil_nadu/kanyakumari/landmarks/mathoor_aqueduct.png")

    # 8. Dhanushkodi Ghost Town Church Ruins (LOC-TN-15)
    surf, ctx = create_surface(420, 260)
    draw_ground_shadow(ctx, 210, 245, 380, 20)
    # Sand dune base
    ctx.set_source_rgb(0.85, 0.76, 0.55)
    ctx.move_to(30, 245)
    ctx.curve_to(120, 225, 280, 235, 390, 245)
    ctx.line_to(390, 255)
    ctx.line_to(30, 255)
    ctx.close_path()
    ctx.fill()
    # Weathered brick church gable facade
    ctx.set_source_rgb(0.68, 0.52, 0.44) # Coral and lime mortar
    ctx.move_to(130, 230)
    ctx.line_to(130, 130)
    ctx.line_to(210, 80)
    ctx.line_to(290, 130)
    ctx.line_to(290, 230)
    ctx.close_path()
    ctx.fill()
    # Ruined pointed arch openings
    ctx.set_source_rgb(0.25, 0.22, 0.20)
    draw_archway(ctx, 185, 140, 50, 90, (0.60, 0.45, 0.38), (0.22, 0.20, 0.18))
    # Stone cross on roof peak
    ctx.set_source_rgb(0.58, 0.48, 0.42)
    ctx.rectangle(207, 60, 6, 24)
    ctx.fill()
    ctx.rectangle(198, 68, 24, 6)
    ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/landmarks/dhanushkodi_ruins.png")

# ==============================================================================
# 2. MADURAI LANDMARKS
# ==============================================================================

def generate_madurai_landmarks():
    print("\n--- Generating Madurai Landmarks ---")

    # 1. Meenakshi Amman Temple South Gopuram (LOC-TN-11)
    surf, ctx = create_surface(480, 640)
    draw_ground_shadow(ctx, 240, 620, 440, 28)
    # Massive granite gateway entrance (Kallezhuthu Nilayam)
    ctx.set_source_rgb(0.32, 0.33, 0.36)
    ctx.rectangle(120, 500, 240, 120)
    ctx.fill()
    # Central entrance void doorway
    ctx.set_source_rgb(0.12, 0.13, 0.15)
    ctx.rectangle(195, 520, 90, 100)
    ctx.fill()
    # Brass studded wooden doors
    ctx.set_source_rgb(0.55, 0.42, 0.22)
    ctx.rectangle(200, 525, 40, 95)
    ctx.rectangle(245, 525, 40, 95)
    ctx.fill()
    # 9-tiered pyramidal Gopuram adorned with thousands of polychromatic stucco sculptures
    tiers = [
        (260, 48, (0.85, 0.30, 0.22)), # Tier 1: Ruby red
        (240, 46, (0.25, 0.65, 0.45)), # Tier 2: Emerald green
        (220, 44, (0.90, 0.72, 0.20)), # Tier 3: Golden ochre
        (200, 42, (0.28, 0.52, 0.82)), # Tier 4: Indigo blue
        (180, 40, (0.82, 0.35, 0.55)), # Tier 5: Rose pink
        (160, 38, (0.92, 0.58, 0.22)), # Tier 6: Saffron orange
        (140, 36, (0.35, 0.72, 0.62)), # Tier 7: Turquoise
        (120, 34, (0.88, 0.82, 0.30)), # Tier 8: Yellow
        (100, 32, (0.75, 0.28, 0.20))  # Tier 9: Deep crimson
    ]
    curr_y = 500
    for tw, th, tcol in tiers:
        curr_y -= th
        tx = 240 - tw / 2
        ctx.set_source_rgb(*tcol)
        ctx.rectangle(tx, curr_y, tw, th)
        ctx.fill()
        # Sculpted figure niches & Kalasam cornices
        ctx.set_source_rgb(0.95, 0.95, 0.95)
        for s in range(4):
            ctx.rectangle(tx + 12 + s * (tw - 24) / 3.5, curr_y + 8, 12, th - 14)
            ctx.fill()
    # Barrel vaulted Shikhara roof crest (Sala)
    ctx.set_source_rgb(0.85, 0.78, 0.35)
    ctx.arc(240, curr_y - 8, 52, math.pi, 2 * math.pi)
    ctx.fill()
    # 9 Polished Golden Kalasams
    ctx.set_source_rgb(0.98, 0.84, 0.12)
    for k in range(9):
        kx = 200 + k * 10
        ctx.arc(kx, curr_y - 20, 5, 0, 2 * math.pi)
        ctx.fill()
        ctx.rectangle(kx - 1, curr_y - 32, 3, 13)
        ctx.fill()
    save_surface(surf, "tamil_nadu/madurai/landmarks/meenakshi_amman_temple.png")

    # 2. Thirumalai Nayakkar Mahal (LOC-TN-12)
    surf, ctx = create_surface(520, 360)
    draw_ground_shadow(ctx, 260, 345, 480, 24)
    # White stucco Italian-Dravidian grand arcade
    ctx.set_source_rgb(0.94, 0.95, 0.96)
    ctx.rectangle(60, 160, 400, 185)
    ctx.fill()
    # Colossal 82-ft cylindrical pillars
    draw_pillared_veranda(ctx, 80, 170, 360, 170, 6, 24, (0.88, 0.90, 0.92), (0.78, 0.80, 0.84))
    # Massive central octagonal Swarga Vilasam dome
    draw_chhatri_dome(ctx, 260, 160, 75, 95, (0.92, 0.94, 0.95), (0.98, 0.85, 0.20))
    # Flanking cupolas
    draw_chhatri_dome(ctx, 130, 160, 35, 45, (0.92, 0.94, 0.95), (0.98, 0.85, 0.20))
    draw_chhatri_dome(ctx, 390, 160, 35, 45, (0.92, 0.94, 0.95), (0.98, 0.85, 0.20))
    # Intricate Islamic foliated arches
    for ax in range(95, 380, 70):
        draw_archway(ctx, ax, 210, 45, 120, (0.80, 0.82, 0.86), (0.25, 0.28, 0.32))
    save_surface(surf, "tamil_nadu/madurai/landmarks/thirumalai_nayakkar_mahal.png")

# ==============================================================================
# 3. CHENNAI & DELTA LANDMARKS
# ==============================================================================

def generate_chennai_landmarks():
    print("\n--- Generating Chennai & Delta Landmarks ---")

    # 1. Chennai Marina Lighthouse (LOC-TN-21)
    surf, ctx = create_surface(320, 580)
    draw_ground_shadow(ctx, 160, 560, 260, 22)
    # Triangular elevator base building
    ctx.set_source_rgb(0.85, 0.88, 0.92)
    ctx.rectangle(90, 470, 140, 90)
    ctx.fill()
    # Cylindrical reinforced concrete tower with red and white bands
    bands = [
        (400, 70, (0.88, 0.20, 0.18)), # Red
        (330, 70, (0.96, 0.96, 0.98)), # White
        (260, 70, (0.88, 0.20, 0.18)), # Red
        (190, 70, (0.96, 0.96, 0.98)), # White
        (120, 70, (0.88, 0.20, 0.18))  # Red
    ]
    for by, bh, bcol in bands:
        ctx.set_source_rgb(*bcol)
        ctx.rectangle(125, by, 70, bh)
        ctx.fill()
    # Circular 360-degree observation deck
    ctx.set_source_rgb(0.35, 0.38, 0.42)
    ctx.rectangle(105, 95, 110, 25)
    ctx.fill()
    # Glass lantern room & rotating beacon
    ctx.set_source_rgba(0.75, 0.92, 1.0, 0.85)
    ctx.rectangle(120, 55, 80, 40)
    ctx.fill()
    # Radar dish and maritime dome on roof
    ctx.set_source_rgb(0.92, 0.94, 0.96)
    ctx.arc(160, 45, 24, math.pi, 2 * math.pi)
    ctx.fill()
    ctx.rectangle(158, 12, 4, 34)
    ctx.fill()
    save_surface(surf, "tamil_nadu/chennai/landmarks/chennai_marina_lighthouse.png")

    # 2. Brihadeeswarar Temple Great Chola Vimana (LOC-TN-15)
    surf, ctx = create_surface(480, 620)
    draw_ground_shadow(ctx, 240, 600, 440, 26)
    # Granitic monolithic sanctuary base (Garbhagriha)
    ctx.set_source_rgb(0.42, 0.40, 0.38)
    ctx.rectangle(110, 470, 260, 130)
    ctx.fill()
    # 13-tiered monolithic granite pyramid vimana
    curr_w = 240
    curr_y = 470
    for tier in range(13):
        th = 28
        curr_y -= th
        curr_w -= 14
        tx = 240 - curr_w / 2
        col = (0.52 - tier * 0.015, 0.48 - tier * 0.015, 0.42 - tier * 0.015)
        ctx.set_source_rgb(*col)
        ctx.rectangle(tx, curr_y, curr_w, th)
        ctx.fill()
        # Carved Chola ganas and niches
        ctx.set_source_rgb(0.28, 0.25, 0.22)
        ctx.rectangle(tx + 6, curr_y + 6, 8, th - 10)
        ctx.rectangle(tx + curr_w - 14, curr_y + 6, 8, th - 10)
        ctx.fill()
    # 80-tonne Single Monolithic Granite Kumbam Cupola
    ctx.set_source_rgb(0.55, 0.48, 0.38)
    ctx.arc(240, curr_y - 12, 34, 0, 2 * math.pi)
    ctx.fill()
    # Golden Kalasam on summit
    ctx.set_source_rgb(0.98, 0.84, 0.15)
    ctx.arc(240, curr_y - 50, 10, 0, 2 * math.pi)
    ctx.fill()
    ctx.rectangle(238, curr_y - 68, 4, 20)
    ctx.fill()
    save_surface(surf, "tamil_nadu/chennai/landmarks/brihadeeswarar_temple_vimana.png")

    # 3. Mahabalipuram Shore Temple (LOC-TN-18)
    surf, ctx = create_surface(460, 340)
    draw_ground_shadow(ctx, 230, 325, 420, 22)
    # Weathered coastal granite stone plinth with Nandi bull sculptures
    ctx.set_source_rgb(0.52, 0.48, 0.42)
    ctx.rectangle(50, 240, 360, 85)
    ctx.fill()
    # Carved Nandi bulls lining perimeter wall
    ctx.set_source_rgb(0.42, 0.38, 0.34)
    for nx in range(60, 400, 45):
        ctx.arc(nx, 235, 12, 0, 2 * math.pi)
        ctx.fill()
    # East-facing principal pyramidal shrine
    for s in range(5):
        sw = 120 - s * 18
        sy = 240 - (s + 1) * 26
        sx = 250 - sw / 2
        ctx.set_source_rgb(0.58 - s * 0.02, 0.52 - s * 0.02, 0.45 - s * 0.02)
        ctx.rectangle(sx, sy, sw, 26)
        ctx.fill()
    # Western smaller shrine
    for s in range(4):
        sw = 80 - s * 14
        sy = 240 - (s + 1) * 22
        sx = 140 - sw / 2
        ctx.set_source_rgb(0.56 - s * 0.02, 0.50 - s * 0.02, 0.43 - s * 0.02)
        ctx.rectangle(sx, sy, sw, 22)
        ctx.fill()
    save_surface(surf, "tamil_nadu/chennai/landmarks/mahabalipuram_shore_temple.png")

    # 4. Pamban Rail Sea Bridge (LOC-TN-17)
    surf, ctx = create_surface(560, 240)
    draw_ground_shadow(ctx, 280, 225, 520, 20)
    # Ocean water surface
    ctx.set_source_rgb(0.18, 0.48, 0.72)
    ctx.rectangle(20, 190, 520, 35)
    ctx.fill()
    # 143 concrete bridge piers resting on Palk Strait coral reef
    ctx.set_source_rgb(0.42, 0.44, 0.46)
    for px in range(50, 520, 75):
        ctx.rectangle(px, 150, 20, 55)
        ctx.fill()
    # Steel truss railway bridge spans
    ctx.set_source_rgb(0.68, 0.28, 0.20) # Indian Railway rust red steel
    ctx.rectangle(30, 140, 500, 12)
    ctx.fill()
    # Scherzer Rolling Lift double-leaf bascule center span
    ctx.set_line_width(3)
    ctx.move_to(220, 140)
    ctx.line_to(250, 70)
    ctx.line_to(280, 140)
    ctx.stroke()
    ctx.move_to(280, 140)
    ctx.line_to(310, 70)
    ctx.line_to(340, 140)
    ctx.stroke()
    save_surface(surf, "tamil_nadu/chennai/landmarks/pamban_rail_bridge.png")

# ==============================================================================
# 4. BUILDINGS, VEGETATION, PROPS & TEXTURES
# ==============================================================================

def generate_tamil_nadu_scenery():
    print("\n--- Generating Tamil Nadu Supporting Scenery ---")

    # Buildings
    bldgs = [
        ("house_tamil_chettinad_mansion.png", 260, 180, (0.85, 0.45, 0.25), (0.78, 0.28, 0.18)),
        ("house_tamil_agraharam.png", 240, 160, (0.92, 0.86, 0.72), (0.75, 0.25, 0.15)),
        ("house_tamil_coastal_cottage.png", 200, 140, (0.88, 0.82, 0.75), (0.65, 0.35, 0.22)),
        ("house_tamil_thatched_hut.png", 180, 130, (0.72, 0.58, 0.42), (0.62, 0.52, 0.32)),
        ("house_tamil_temple_residence.png", 220, 170, (0.90, 0.84, 0.76), (0.72, 0.26, 0.18)),
        ("house_tamil_modern_terrace.png", 210, 150, (0.95, 0.95, 0.98), (0.28, 0.45, 0.65))
    ]
    for bname, w, h, wcol, rcol in bldgs:
        surf, ctx = create_surface(w, h)
        draw_ground_shadow(ctx, w/2, h - 8, w - 20, 14)
        ctx.set_source_rgb(*wcol)
        ctx.rectangle(20, h - 90, w - 40, 80)
        ctx.fill()
        draw_sloping_roof(ctx, 15, h - 145, w - 30, 55, 12, rcol, (0.4, 0.15, 0.1))
        save_surface(surf, f"tamil_nadu/kanyakumari/buildings/{bname}")
        save_surface(surf, f"tamil_nadu/madurai/buildings/{bname}")
        save_surface(surf, f"tamil_nadu/chennai/buildings/{bname}")

    # Vegetation (Palmyra, Banyan, Neem, Tamarind, Coastal Coconut, Bougainvillea)
    # 1. Palmyra tall palm (State Tree of Tamil Nadu)
    surf, ctx = create_surface(160, 320)
    draw_ground_shadow(ctx, 80, 310, 80, 14)
    ctx.set_source_rgb(0.22, 0.20, 0.18) # Dark black-grey ringed trunk
    ctx.rectangle(74, 70, 12, 240)
    ctx.fill()
    # Fan-shaped palmate leaves
    ctx.set_source_rgb(0.12, 0.42, 0.18)
    for a in range(14):
        ang = a * (math.pi / 7)
        ctx.arc(80 + math.cos(ang) * 45, 70 + math.sin(ang) * 35, 24, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/vegetation/tree_tamil_palmyra_tall.png")

    # 2. Sprawling Banyan with aerial roots
    surf, ctx = create_surface(260, 220)
    draw_ground_shadow(ctx, 130, 210, 220, 18)
    ctx.set_source_rgb(0.35, 0.28, 0.22) # Massive trunk
    ctx.rectangle(110, 80, 40, 130)
    ctx.fill()
    # Aerial roots
    for rx in [70, 95, 165, 190]:
        ctx.rectangle(rx, 110, 6, 100)
        ctx.fill()
    # Dense broad leaf canopy
    ctx.set_source_rgb(0.15, 0.48, 0.22)
    for cx in range(50, 220, 35):
        ctx.arc(cx, 60, 40, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/vegetation/tree_tamil_banyan_sprawling.png")

    # Roadside Props
    # 1. Roadside Tea Kadai
    surf, ctx = create_surface(160, 130)
    draw_ground_shadow(ctx, 80, 122, 140, 12)
    ctx.set_source_rgb(0.48, 0.35, 0.22) # Wood stall
    ctx.rectangle(25, 45, 110, 75)
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.25, 0.18) # Blue/red tarp awning
    ctx.rectangle(15, 30, 130, 18)
    ctx.fill()
    # Brass tea boiler
    ctx.set_source_rgb(0.88, 0.72, 0.22)
    ctx.rectangle(45, 55, 22, 35)
    ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/roadside_props/shop_tamil_tea_kadai.png")

    # 2. Poo Kadai (Madurai Flower Stall)
    surf, ctx = create_surface(150, 120)
    draw_ground_shadow(ctx, 75, 114, 130, 12)
    ctx.set_source_rgb(0.52, 0.38, 0.25)
    ctx.rectangle(20, 45, 110, 65)
    ctx.fill()
    # Jasmine (Malli) and marigold flower garlands
    for gx in range(30, 120, 15):
        ctx.set_source_rgb(0.98, 0.98, 0.95) # White jasmine
        ctx.rectangle(gx, 55, 8, 45)
        ctx.fill()
        ctx.set_source_rgb(0.98, 0.65, 0.12) # Orange marigold
        ctx.rectangle(gx, 80, 8, 15)
        ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/roadside_props/shop_tamil_flower_poo_kadai.png")

    # Textures (Seamless 1024x1024)
    # 1. Laterite Red Soil
    surf, ctx = create_surface(1024, 1024)
    ctx.set_source_rgb(0.65, 0.32, 0.20)
    ctx.paint()
    random.seed(42)
    for _ in range(5000):
        gx = random.randint(0, 1024)
        gy = random.randint(0, 1024)
        gr = random.randint(2, 6)
        c = random.uniform(0.55, 0.75)
        ctx.set_source_rgb(c, c * 0.45, c * 0.28)
        ctx.arc(gx, gy, gr, 0, 2 * math.pi)
        ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/textures/texture_laterite_red.png")

    # 2. Asphalt Dark Highway
    surf, ctx = create_surface(1024, 1024)
    ctx.set_source_rgb(0.18, 0.20, 0.22)
    ctx.paint()
    for _ in range(8000):
        gx = random.randint(0, 1024)
        gy = random.randint(0, 1024)
        c = random.uniform(0.12, 0.28)
        ctx.set_source_rgb(c, c, c)
        ctx.rectangle(gx, gy, 2, 2)
        ctx.fill()
    save_surface(surf, "tamil_nadu/kanyakumari/textures/texture_asphalt_highway.png")

def main():
    print("==================================================")
    print("STARTING TAMIL NADU ASSET COLLECTION V2 GENERATION")
    print("==================================================")
    generate_kanyakumari_landmarks()
    generate_madurai_landmarks()
    generate_chennai_landmarks()
    generate_tamil_nadu_scenery()
    print("==================================================")
    print("TAMIL NADU V2 ASSETS GENERATED SUCCESSFULLY!")
    print("==================================================")

if __name__ == "__main__":
    main()
