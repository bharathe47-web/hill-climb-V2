#!/usr/bin/env python3
"""
build_heaven_phase2_rebuild_assets.py
Phase 2.2 Final Composition Rebuild — Production Asset Generator

Generates high-contrast, richly detailed, cohesive visual assets for Heaven:
1. heaven_stone_bridge_arch.png (Substantial ashlar stone masonry bridge with rounded arch, voussoirs, keystone, cloud aperture)
2. heaven_marble_roadway.png & heaven_marble_floor.png (Substantial ivory marble roadway deck with gold inlays & panel divisions)
3. heaven_palace_column.png (Zoeluci fluted marble column master)
4. heaven_palace_column_paired.png (Coupled columns with gold entablature and shared plinth)
5. heaven_palace_colonnade_arch.png (Interconnected arch module with columns, arch, ivory wall panel & stained glass window)
6. heaven_palace_grand_door.png (Dominant landmark: ornate ivory-and-gold double entrance door)
7. heaven_palace_fountain.png (Secondary landmark: carved ceremonial pedestal fountain)
8. heaven_palace_vaulted_ceiling.png (Continuous coffered ceiling with gold mouldings and pendant drops)
9. puffy_sky_blue_01.png (Clear turquoise-blue celestial sky gradient)
10. heaven_distant_palace_silhouette.png (Solid, richly rendered floating islands with classical pantheon temples and waterfalls)
11. heaven_golden_archway.png & heaven_golden_archway_front.png (Dominant triumphal gateway arch)
12. heaven_rose_window.png (12-petaled stained-glass rose window)
"""

import os
import math
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance

TARGET_DIR = "/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/Endless-Hillclimb-Fixed/assets/environments/heaven/architecture"
SKY_DIR = "/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/Endless-Hillclimb-Fixed/assets/environments/heaven/sky"
DECOR_DIR = "/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/Endless-Hillclimb-Fixed/assets/environments/heaven/decorations"
ZOELUCI_DIR = "/home/danny/DUMB-SPOT/full_assets/Heaven/Architecture_01/extracted/golden_palace_interior"

os.makedirs(TARGET_DIR, exist_ok=True)
os.makedirs(SKY_DIR, exist_ok=True)
os.makedirs(DECOR_DIR, exist_ok=True)

# -------------------------------------------------------------------------
# 1. Substantial Stone Bridge Arch (heaven_stone_bridge_arch.png)
# -------------------------------------------------------------------------
def create_stone_bridge_arch():
    width = 320
    height = 240
    im = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    stone_base = (235, 230, 222, 255)
    stone_light = (248, 245, 240, 255)
    stone_shadow = (200, 194, 182, 255)
    mortar_line = (165, 158, 146, 255)
    corbel_gold = (218, 188, 105, 255)
    gold_highlight = (255, 242, 175, 255)

    arch_cx = width // 2
    arch_radius = 88
    arch_spring_y = 115
    arch_top_y = arch_spring_y - arch_radius

    for y in range(height):
        for x in range(width):
            dx = x - arch_cx
            is_inside_arch = False
            if y >= arch_spring_y and abs(dx) < arch_radius:
                is_inside_arch = True
            elif y < arch_spring_y and y >= arch_top_y:
                dy = y - arch_spring_y
                if dx * dx + dy * dy < arch_radius * arch_radius:
                    is_inside_arch = True

            if is_inside_arch:
                # Soft cloud aperture with clear turquoise sky showing through
                depth_ratio = (y - arch_top_y) / float(height - arch_top_y)
                alpha = int(45 + 75 * depth_ratio)
                c_r = int(210 + 20 * math.sin(x * 0.04))
                c_g = int(235 + 15 * math.cos(y * 0.04))
                c_b = int(250)
                im.putpixel((x, y), (c_r, c_g, c_b, alpha))
            else:
                # Solid ashlar stone masonry block texture
                course = (y - 14) // 26
                offset_x = (course % 2) * 32
                local_y = (y - 14) % 26
                local_x = (x + offset_x) % 64

                is_edge = (local_x == 0 or local_y == 0)
                is_highlight = (local_y == 1 or local_x == 1)
                is_shade = (local_y == 25 or local_x == 63)
                grain = int((math.sin(x * 0.25) + math.cos(y * 0.35)) * 4)

                if is_edge:
                    col = mortar_line
                elif is_highlight:
                    col = (min(255, stone_light[0] + grain), min(255, stone_light[1] + grain), min(255, stone_light[2] + grain), 255)
                elif is_shade:
                    col = (max(0, stone_shadow[0] + grain), max(0, stone_shadow[1] + grain), max(0, stone_shadow[2] + grain), 255)
                else:
                    col = (max(0, min(255, stone_base[0] + grain)), max(0, min(255, stone_base[1] + grain)), max(0, min(255, stone_base[2] + grain)), 255)

                im.putpixel((x, y), col)

    # Radiating voussoirs
    num_voussoirs = 19
    outer_radius = arch_radius + 22
    for i in range(num_voussoirs):
        angle_start = math.pi * i / float(num_voussoirs)
        angle_end = math.pi * (i + 1) / float(num_voussoirs)
        is_keystone = (i == num_voussoirs // 2)
        keystone_extra = 8 if is_keystone else 0

        x0 = arch_cx - math.cos(angle_start) * arch_radius
        y0 = arch_spring_y - math.sin(angle_start) * arch_radius
        x1 = arch_cx - math.cos(angle_start) * (outer_radius + keystone_extra)
        y1 = arch_spring_y - math.sin(angle_start) * (outer_radius + keystone_extra)
        draw.line([(x0, y0), (x1, y1)], fill=mortar_line, width=2)

        if is_keystone:
            kx = arch_cx
            ky = arch_spring_y - (outer_radius + keystone_extra)
            draw.rectangle([kx - 10, ky - 6, kx + 10, ky + 14], fill=(255, 245, 220, 255), outline=corbel_gold, width=2)

    # Pilaster impost mouldings at arch spring line
    draw.rectangle([arch_cx - arch_radius - 8, arch_spring_y - 4, arch_cx - arch_radius + 4, arch_spring_y + 4], fill=corbel_gold)
    draw.rectangle([arch_cx + arch_radius - 4, arch_spring_y - 4, arch_cx + arch_radius + 8, arch_spring_y + 4], fill=corbel_gold)

    # Vertical arch jamb borders
    draw.line([(arch_cx - arch_radius, arch_spring_y), (arch_cx - arch_radius, height)], fill=corbel_gold, width=3)
    draw.line([(arch_cx + arch_radius, arch_spring_y), (arch_cx + arch_radius, height)], fill=corbel_gold, width=3)

    # Upper bridge cornice moulding & gold trim
    draw.rectangle([0, 0, width, 12], fill=(245, 240, 230, 255))
    draw.line([(0, 0), (width, 0)], fill=(255, 255, 255, 255), width=2)
    draw.line([(0, 6), (width, 6)], fill=gold_highlight, width=1)
    draw.line([(0, 10), (width, 10)], fill=corbel_gold, width=2)
    draw.line([(0, 13), (width, 13)], fill=mortar_line, width=1)

    # Left and right pier pilaster accents
    draw.rectangle([0, 14, 28, height], fill=None, outline=mortar_line, width=1)
    draw.line([(28, 14), (28, height)], fill=(215, 206, 194, 255), width=2)
    draw.rectangle([width - 29, 14, width - 1, height], fill=None, outline=mortar_line, width=1)
    draw.line([(width - 29, 14), (width - 29, height)], fill=(215, 206, 194, 255), width=2)

    out_path = os.path.join(TARGET_DIR, "heaven_stone_bridge_arch.png")
    im.save(out_path)
    print("✓ Created substantial stone bridge arch (320x240):", out_path)

# -------------------------------------------------------------------------
# 2. Substantial Royal Ivory Marble Roadway Deck (heaven_marble_roadway.png)
# -------------------------------------------------------------------------
def create_marble_roadway():
    width = 1920
    height = 100
    im = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    c_marble_light = (254, 252, 248, 255)
    c_marble_mid = (246, 242, 234, 255)
    c_marble_shadow = (222, 215, 202, 255)
    c_gold_rim = (222, 190, 98, 255)
    c_gold_hl = (255, 242, 168, 255)
    c_joint = (195, 185, 170, 255)

    for y in range(height):
        t = y / float(height)
        r = int(c_marble_light[0] * (1.0 - t * 0.32) + c_marble_shadow[0] * (t * 0.32))
        g = int(c_marble_light[1] * (1.0 - t * 0.32) + c_marble_shadow[1] * (t * 0.32))
        b = int(c_marble_light[2] * (1.0 - t * 0.32) + c_marble_shadow[2] * (t * 0.32))
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))

    # Polished road crest specular highlight
    draw.line([(0, 0), (width, 0)], fill=(255, 255, 255, 255), width=3)
    draw.line([(0, 3), (width, 3)], fill=c_gold_hl, width=1)
    draw.line([(0, 5), (width, 5)], fill=c_gold_rim, width=2)

    # Inlaid champagne gold lines
    draw.line([(0, 18), (width, 18)], fill=c_gold_rim, width=2)
    draw.line([(0, 24), (width, 24)], fill=c_gold_hl, width=1)
    draw.line([(0, 32), (width, 32)], fill=c_gold_rim, width=1)

    # Repeating marble slab joints and diamond rosettes
    slab_w = 120
    for sx in range(0, width, slab_w):
        draw.line([(sx, 0), (sx, height)], fill=c_joint, width=1)
        draw.line([(sx + 1, 0), (sx + 1, height)], fill=(255, 255, 255, 180), width=1)

        # Inlaid champagne gold diamond rosette at center of each slab
        cx = sx + slab_w // 2
        cy = 21
        d_rad = 6
        diamond = [(cx, cy - d_rad), (cx + d_rad, cy), (cx, cy + d_rad), (cx - d_rad, cy)]
        draw.polygon(diamond, fill=c_gold_hl, outline=c_gold_rim)

    # Lower bridge bevel & curb shadow
    draw.line([(0, height - 10), (width, height - 10)], fill=c_gold_rim, width=2)
    draw.rectangle([0, height - 8, width, height], fill=(188, 180, 166, 255))

    p1 = os.path.join(TARGET_DIR, "heaven_marble_roadway.png")
    p2 = os.path.join(TARGET_DIR, "heaven_marble_floor.png")
    im.save(p1)
    im.save(p2)
    print("✓ Created substantial marble roadway & floor (1920x100):", p1)

# -------------------------------------------------------------------------
# 3. Fluted Columns & Variations
# -------------------------------------------------------------------------
def create_column_variations():
    zoe_col_path = os.path.join(ZOELUCI_DIR, "Column.png")
    col_master = Image.open(zoe_col_path).convert("RGBA")
    cw, ch = col_master.size

    col_out = os.path.join(TARGET_DIR, "heaven_palace_column.png")
    col_master.save(col_out)
    print("✓ Saved master Zoeluci fluted column (210x938):", col_out)

    # Variation 2: Paired Colonnade
    pair_w = 420
    pair_h = ch
    pair_im = Image.new("RGBA", (pair_w, pair_h), (0, 0, 0, 0))
    pair_im.paste(col_master, (15, 0), col_master)
    pair_im.paste(col_master, (195, 0), col_master)

    p_draw = ImageDraw.Draw(pair_im)
    ent_y = 60
    p_draw.rectangle([15, ent_y - 20, 405, ent_y + 10], fill=(238, 230, 212, 255), outline=(218, 188, 98, 255), width=2)
    p_draw.line([(15, ent_y - 20), (405, ent_y - 20)], fill=(255, 245, 180, 255), width=3)
    p_draw.line([(15, ent_y + 10), (405, ent_y + 10)], fill=(195, 165, 80, 255), width=2)

    base_y = ch - 50
    p_draw.rectangle([5, base_y, 415, ch - 5], fill=(228, 220, 206, 255), outline=(185, 175, 160, 255), width=2)

    pair_out = os.path.join(TARGET_DIR, "heaven_palace_column_paired.png")
    pair_im.save(pair_out)
    print("✓ Created paired colonnade (420x938):", pair_out)

    # Variation 3: Interconnected Arched Colonnade Bay (Columns + Semicircular Arch + Wall + Stained-Glass Window)
    arch_col_w = 640
    arch_col_h = ch
    arch_col_im = Image.new("RGBA", (arch_col_w, arch_col_h), (0, 0, 0, 0))
    ac_draw = ImageDraw.Draw(arch_col_im)

    # 1. Backing Ivory Marble Wall Panel with Gold Moulding
    c_wall = (248, 244, 236, 255)
    c_wall_shade = (225, 218, 204, 255)
    c_gold = (218, 186, 96, 255)
    c_gold_hl = (255, 242, 170, 255)

    ac_draw.rectangle([40, 60, arch_col_w - 40, ch - 40], fill=c_wall, outline=c_wall_shade, width=2)
    ac_draw.rectangle([70, 90, arch_col_w - 70, ch - 70], fill=None, outline=c_gold, width=2)

    # 2. Central Arched Stained-Glass Window
    zoe_win_path = os.path.join(ZOELUCI_DIR, "Window.png")
    if os.path.exists(zoe_win_path):
        win_master = Image.open(zoe_win_path).convert("RGBA")
        win_scaled = win_master.resize((int(win_master.width * 0.85), int(win_master.height * 0.85)), Image.Resampling.LANCZOS)
        win_x = (arch_col_w - win_scaled.width) // 2
        win_y = 130
        arch_col_im.paste(win_scaled, (win_x, win_y), win_scaled)

    # 3. Flanking Fluted Columns
    arch_col_im.paste(col_master, (0, 0), col_master)
    arch_col_im.paste(col_master, (arch_col_w - cw, 0), col_master)

    # 4. Classical Semicircular Arch Spanning Between Columns
    arc_cx = arch_col_w // 2
    arc_cy = 150
    arc_r = 185
    ac_draw.arc([arc_cx - arc_r, arc_cy - arc_r, arc_cx + arc_r, arc_cy + arc_r], start=180, end=360, fill=c_gold, width=20)
    ac_draw.arc([arc_cx - (arc_r - 18), arc_cy - (arc_r - 18), arc_cx + (arc_r - 18), arc_cy + (arc_r - 18)], start=180, end=360, fill=(255, 248, 235, 255), width=14)
    # Keystone
    ac_draw.rectangle([arc_cx - 18, arc_cy - arc_r - 14, arc_cx + 18, arc_cy - arc_r + 16], fill=c_gold_hl, outline=c_gold, width=2)

    # Entablature beam across capitals
    ac_draw.rectangle([0, 40, arch_col_w, 75], fill=(244, 238, 225, 255), outline=c_gold, width=2)
    ac_draw.line([(0, 40), (arch_col_w, 40)], fill=(255, 255, 255, 255), width=3)
    ac_draw.line([(0, 56), (arch_col_w, 56)], fill=c_gold_hl, width=2)

    # Shared base plinth connecting column bases
    ac_draw.rectangle([0, ch - 55, arch_col_w, ch - 5], fill=(232, 224, 210, 255), outline=(185, 175, 160, 255), width=3)

    arch_out = os.path.join(TARGET_DIR, "heaven_palace_colonnade_arch.png")
    arch_col_im.save(arch_out)
    print("✓ Created interconnected arched colonnade bay (640x938):", arch_out)

# -------------------------------------------------------------------------
# 4. Grand Celestial Double Entrance Door (heaven_palace_grand_door.png)
# -------------------------------------------------------------------------
def create_grand_entrance_door():
    w = 512
    h = 720
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    c_marble_frame = (248, 245, 238, 255)
    c_marble_shade = (218, 210, 196, 255)
    c_door_wood = (238, 232, 220, 255)
    c_panel_shade = (198, 188, 172, 255)
    c_gold_rim = (220, 188, 96, 255)
    c_gold_hl = (255, 242, 170, 255)

    # Outer marble portal surround
    draw.rectangle([25, 55, w - 25, h - 20], fill=c_marble_frame, outline=c_marble_shade, width=5)
    pediment = [(15, 55), (w // 2, 6), (w - 15, 55)]
    draw.polygon(pediment, fill=c_marble_frame, outline=c_gold_rim)
    draw.ellipse([w // 2 - 24, 16, w // 2 + 24, 56], fill=c_gold_hl, outline=c_gold_rim, width=2)

    door_left = 60
    door_top = 105
    door_right = w - 60
    door_bottom = h - 25
    door_w = door_right - door_left

    # Semicircular arch top of door
    arch_box = [door_left, door_top, door_right, door_top + door_w]
    draw.pieslice(arch_box, start=180, end=360, fill=(30, 42, 58, 255), outline=c_gold_rim, width=4)

    # Tympanum sunburst rays
    tcx = w // 2
    tcy = door_top + door_w // 2
    for ray in range(15):
        ang = math.pi + math.pi * ray / 14.0
        rx = tcx + math.cos(ang) * (door_w // 2 - 8)
        ry = tcy + math.sin(ang) * (door_w // 2 - 8)
        draw.line([(tcx, tcy), (rx, ry)], fill=c_gold_hl, width=2)
    draw.ellipse([tcx - 24, tcy - 24, tcx + 24, tcy + 24], fill=c_gold_hl, outline=c_gold_rim, width=2)

    # Dual door leaves
    d_rect_top = door_top + door_w // 2
    draw.rectangle([door_left, d_rect_top, door_right, door_bottom], fill=c_door_wood, outline=c_gold_rim, width=3)

    mid_x = w // 2
    draw.line([(mid_x, d_rect_top), (mid_x, door_bottom)], fill=c_panel_shade, width=4)
    draw.line([(mid_x - 1, d_rect_top), (mid_x - 1, door_bottom)], fill=c_gold_rim, width=2)

    leaf_w = (door_right - door_left - 10) // 2
    panel_h = (door_bottom - d_rect_top - 40) // 3
    for lx in [door_left + 5, mid_x + 5]:
        for p in range(3):
            py = d_rect_top + 15 + p * (panel_h + 8)
            draw.rectangle([lx, py, lx + leaf_w - 6, py + panel_h], fill=(250, 246, 240, 255), outline=c_gold_rim, width=2)
            draw.rectangle([lx + 6, py + 6, lx + leaf_w - 12, py + panel_h - 6], fill=(240, 232, 220, 255), outline=c_panel_shade, width=1)

            pcx = lx + leaf_w // 2 - 3
            pcy = py + panel_h // 2
            draw.ellipse([pcx - 14, pcy - 14, pcx + 14, pcy + 14], fill=c_gold_hl, outline=c_gold_rim, width=2)
            for s_ang in [0, 45, 90, 135]:
                rad = math.radians(s_ang)
                dx = math.cos(rad) * 18
                dy = math.sin(rad) * 18
                draw.line([(pcx - dx, pcy - dy), (pcx + dx, pcy + dy)], fill=c_gold_hl, width=2)

    handle_y = d_rect_top + panel_h + 20
    draw.ellipse([mid_x - 24, handle_y - 8, mid_x - 10, handle_y + 26], fill=c_gold_hl, outline=c_gold_rim, width=2)
    draw.ellipse([mid_x + 10, handle_y - 8, mid_x + 24, handle_y + 26], fill=c_gold_hl, outline=c_gold_rim, width=2)

    out_path = os.path.join(TARGET_DIR, "heaven_palace_grand_door.png")
    im.save(out_path)
    print("✓ Created grand celestial double door:", out_path)

# -------------------------------------------------------------------------
# 5. Ceremonial Fountain (heaven_palace_fountain.png)
# -------------------------------------------------------------------------
def create_ceremonial_fountain():
    w = 360
    h = 460
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    c_marble = (250, 246, 238, 255)
    c_marble_shade = (212, 204, 190, 255)
    c_gold = (222, 190, 98, 255)
    c_gold_hl = (255, 244, 172, 255)
    c_water = (165, 230, 250, 210)
    c_water_deep = (85, 175, 220, 235)

    cx = w // 2

    draw.rectangle([cx - 150, h - 30, cx + 150, h - 5], fill=c_marble, outline=c_gold, width=2)
    draw.rectangle([cx - 120, h - 55, cx + 120, h - 30], fill=c_marble, outline=c_marble_shade, width=2)
    draw.rectangle([cx - 90, h - 75, cx + 90, h - 55], fill=c_marble, outline=c_gold, width=2)

    stem_top = h - 190
    stem_bottom = h - 75
    draw.rectangle([cx - 40, stem_top, cx + 40, stem_bottom], fill=c_marble, outline=c_marble_shade, width=2)
    for fx in range(cx - 32, cx + 33, 16):
        draw.line([(fx, stem_top), (fx, stem_bottom)], fill=c_marble_shade, width=2)
        draw.line([(fx + 1, stem_top), (fx + 1, stem_bottom)], fill=(255, 255, 255, 180), width=1)
    draw.rectangle([cx - 48, stem_bottom - 20, cx + 48, stem_bottom], fill=c_gold_hl, outline=c_gold, width=2)
    draw.rectangle([cx - 48, stem_top, cx + 48, stem_top + 18], fill=c_gold_hl, outline=c_gold, width=2)

    basin_y = stem_top
    basin_rx = 160
    basin_ry = 38
    draw.pieslice([cx - basin_rx, basin_y - basin_ry, cx + basin_rx, basin_y + basin_ry + 45], start=0, end=180, fill=c_marble, outline=c_marble_shade, width=3)
    draw.ellipse([cx - basin_rx, basin_y - basin_ry, cx + basin_rx, basin_y + basin_ry], fill=c_marble, outline=c_gold, width=4)
    draw.ellipse([cx - basin_rx + 10, basin_y - basin_ry + 6, cx + basin_rx - 10, basin_y + basin_ry - 6], fill=c_water_deep, outline=c_water, width=2)

    tier2_bottom = basin_y - 15
    tier2_top = tier2_bottom - 95
    draw.rectangle([cx - 24, tier2_top, cx + 24, tier2_bottom], fill=c_marble, outline=c_gold, width=2)

    u_rx = 85
    u_ry = 22
    u_y = tier2_top
    draw.pieslice([cx - u_rx, u_y - u_ry, cx + u_rx, u_y + u_ry + 28], start=0, end=180, fill=c_marble, outline=c_marble_shade, width=2)
    draw.ellipse([cx - u_rx, u_y - u_ry, cx + u_rx, u_y + u_ry], fill=c_water_deep, outline=c_gold, width=3)

    finial_top = u_y - 50
    draw.ellipse([cx - 14, finial_top, cx + 14, finial_top + 28], fill=c_gold_hl, outline=c_gold, width=2)
    draw.line([(cx, finial_top), (cx, finial_top - 35)], fill=(225, 248, 255, 240), width=4)
    for dx, dy in [(-25, 25), (-45, 60), (-75, 110), (25, 25), (45, 60), (75, 110)]:
        draw.ellipse([cx + dx - 3, finial_top + dy - 3, cx + dx + 3, finial_top + dy + 3], fill=(230, 252, 255, 220))

    out_path = os.path.join(TARGET_DIR, "heaven_palace_fountain.png")
    im.save(out_path)
    print("✓ Created ceremonial fountain:", out_path)

# -------------------------------------------------------------------------
# 6. Continuous Vaulted Ceiling (heaven_palace_vaulted_ceiling.png)
# -------------------------------------------------------------------------
def create_vaulted_ceiling():
    w = 1920
    h = 130
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    c_cornice_top = (254, 252, 248, 255)
    c_moulding = (238, 230, 218, 255)
    c_shade = (198, 188, 172, 255)
    c_gold = (220, 188, 98, 255)
    c_gold_hl = (255, 244, 172, 255)

    draw.rectangle([0, 0, w, 26], fill=c_cornice_top)
    draw.line([(0, 0), (w, 0)], fill=(255, 255, 255, 255), width=3)
    draw.line([(0, 14), (w, 14)], fill=c_gold_hl, width=2)
    draw.line([(0, 25), (w, 25)], fill=c_gold, width=3)

    span = 320
    for ax in range(0, w, span):
        acx = ax + span // 2
        acy = 26
        ar = span // 2
        draw.arc([acx - ar, acy - ar, acx + ar, acy + ar], start=0, end=180, fill=c_moulding, width=14)
        draw.arc([acx - (ar - 6), acy - (ar - 6), acx + (ar - 6), acy + (ar - 6)], start=0, end=180, fill=c_gold, width=4)
        draw.ellipse([acx - 8, acy + ar - 6, acx + 8, acy + ar + 16], fill=c_gold_hl, outline=c_gold, width=2)
        draw.polygon([(ax, 26), (ax + 42, 26), (ax, 80)], fill=c_shade)
        draw.polygon([(ax + span, 26), (ax + span - 42, 26), (ax + span, 80)], fill=c_shade)

    out_path = os.path.join(TARGET_DIR, "heaven_palace_vaulted_ceiling.png")
    im.save(out_path)
    print("✓ Created vaulted palace ceiling (1920x130):", out_path)

# -------------------------------------------------------------------------
# 7. Clear Turquoise Celestial Sky (puffy_sky_blue_01.png)
# -------------------------------------------------------------------------
def create_turquoise_celestial_sky():
    w = 1920
    h = 1080
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    # Vibrant celestial turquoise-blue:
    # Zenith: Deep royal cyan-blue (24, 88, 136)
    # Mid-Upper: Radiant azure cyan (46, 142, 192)
    # Mid: Luminous turquoise (72, 180, 212)
    # Horizon: Warm morning cyan-gold (160, 220, 232)
    top_c = (24, 88, 136)
    mid_upper_c = (46, 142, 192)
    mid_c = (72, 180, 212)
    horizon_c = (168, 224, 234)

    pixels = []
    for y in range(h):
        t = y / float(h)
        if t < 0.35:
            st = t / 0.35
            r = int(top_c[0] * (1.0 - st) + mid_upper_c[0] * st)
            g = int(top_c[1] * (1.0 - st) + mid_upper_c[1] * st)
            b = int(top_c[2] * (1.0 - st) + mid_upper_c[2] * st)
        elif t < 0.70:
            st = (t - 0.35) / 0.35
            r = int(mid_upper_c[0] * (1.0 - st) + mid_c[0] * st)
            g = int(mid_upper_c[1] * (1.0 - st) + mid_c[1] * st)
            b = int(mid_upper_c[2] * (1.0 - st) + mid_c[2] * st)
        else:
            st = (t - 0.70) / 0.30
            r = int(mid_c[0] * (1.0 - st) + horizon_c[0] * st)
            g = int(mid_c[1] * (1.0 - st) + horizon_c[1] * st)
            b = int(mid_c[2] * (1.0 - st) + horizon_c[2] * st)
        for x in range(w):
            pixels.append((r, g, b, 255))

    im.putdata(pixels)
    out_path = os.path.join(SKY_DIR, "puffy_sky_blue_01.png")
    im.save(out_path)
    print("✓ Created clear turquoise celestial sky gradient:", out_path)

# -------------------------------------------------------------------------
# 8. Solid Floating Islands & Classical Pantheon Temples (heaven_distant_palace_silhouette.png)
# -------------------------------------------------------------------------
def create_floating_island_temples():
    w = 1920
    h = 420
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # Solid, opaque classical temple colors (NO transparent stick outlines!)
    temple_marble = (248, 245, 238, 255)
    temple_shade = (205, 215, 226, 255)
    gold_dome = (248, 222, 125, 255)
    gold_trim = (218, 186, 96, 255)
    island_rock = (165, 182, 198, 255)
    island_shade = (135, 152, 170, 255)
    terrace_grass = (175, 218, 190, 255)
    waterfall_c = (215, 245, 255, 230)

    # 3 Monumental Floating Island complexes
    islands = [
        {"cx": 340, "cy": 240, "rx": 240, "ry": 65, "dome": True, "waterfall": True},
        {"cx": 980, "cy": 195, "rx": 300, "ry": 80, "dome": True, "waterfall": True},
        {"cx": 1620, "cy": 235, "rx": 260, "ry": 70, "dome": False, "waterfall": True},
    ]

    for isl in islands:
        cx = isl["cx"]
        cy = isl["cy"]
        rx = isl["rx"]
        ry = isl["ry"]

        # Solid rocky island underside cone
        rock_pts = [
            (cx - rx, cy),
            (cx - rx * 0.65, cy + ry * 1.5),
            (cx - rx * 0.2, cy + ry * 2.5),
            (cx + rx * 0.2, cy + ry * 2.3),
            (cx + rx * 0.6, cy + ry * 1.4),
            (cx + rx, cy)
        ]
        draw.polygon(rock_pts, fill=island_rock, outline=island_shade)

        # Rock strata shadow lines
        draw.line([(cx - rx * 0.5, cy + ry * 0.8), (cx + rx * 0.5, cy + ry * 0.8)], fill=island_shade, width=3)
        draw.line([(cx - rx * 0.3, cy + ry * 1.6), (cx + rx * 0.3, cy + ry * 1.5)], fill=island_shade, width=3)

        # Lush green terrace
        draw.ellipse([cx - rx, cy - ry // 2, cx + rx, cy + ry // 2], fill=terrace_grass, outline=(220, 235, 220, 255), width=2)

        # Classical Temple Architecture on Island
        ty = cy - ry // 2
        tw = int(rx * 0.75)
        # Stepped marble plinth
        draw.rectangle([cx - tw // 2 - 8, ty - 18, cx + tw // 2 + 8, ty], fill=temple_marble, outline=temple_shade, width=2)
        draw.rectangle([cx - tw // 2, ty - 12, cx + tw // 2, ty], fill=temple_marble)

        # Solid fluted columns (solid filled rectangles!)
        num_cols = 8
        col_w = 9
        col_spacing = (tw - col_w) / float(num_cols - 1)
        for ci in range(num_cols):
            clx = int(cx - tw // 2 + ci * col_spacing)
            # Column shaft
            draw.rectangle([clx, ty - 80, clx + col_w, ty - 12], fill=temple_marble, outline=temple_shade, width=1)
            # Gold capital
            draw.rectangle([clx - 2, ty - 86, clx + col_w + 2, ty - 80], fill=gold_trim)
            # Base plinth
            draw.rectangle([clx - 2, ty - 16, clx + col_w + 2, ty - 12], fill=gold_trim)

        # Entablature / Architrave
        draw.rectangle([cx - tw // 2 - 12, ty - 102, cx + tw // 2 + 12, ty - 86], fill=temple_marble, outline=gold_trim, width=2)
        draw.line([(cx - tw // 2 - 12, ty - 94), (cx + tw // 2 + 12, ty - 94)], fill=gold_trim, width=2)

        if isl["dome"]:
            # Grand Gold Dome Rotunda
            dome_r = int(tw * 0.36)
            draw.pieslice([cx - dome_r, ty - 102 - dome_r, cx + dome_r, ty - 102 + dome_r], start=180, end=360, fill=gold_dome, outline=temple_marble, width=3)
            # Dome ribs
            for rib_deg in [210, 240, 270, 300, 330]:
                rad = math.radians(rib_deg)
                rx_pt = cx + math.cos(rad) * dome_r
                ry_pt = ty - 102 + math.sin(rad) * dome_r
                draw.line([(cx, ty - 102 - dome_r), (rx_pt, ry_pt)], fill=gold_trim, width=2)
            # Gold finial
            draw.line([(cx, ty - 102 - dome_r), (cx, ty - 102 - dome_r - 22)], fill=gold_trim, width=4)
            draw.ellipse([cx - 5, ty - 102 - dome_r - 28, cx + 5, ty - 102 - dome_r - 18], fill=gold_dome, outline=gold_trim)
        else:
            # Classical Triangular Pediment with Gold Relief
            ped = [(cx - tw // 2 - 12, ty - 102), (cx, ty - 145), (cx + tw // 2 + 12, ty - 102)]
            draw.polygon(ped, fill=temple_marble, outline=gold_trim)
            draw.ellipse([cx - 12, ty - 122, cx + 12, ty - 102], fill=gold_dome, outline=gold_trim)

        # Cascading Waterfall
        if isl["waterfall"]:
            wfx = cx + int(rx * 0.45)
            wfy = cy + 4
            draw.line([(wfx, wfy), (wfx, wfy + 160)], fill=waterfall_c, width=8)
            draw.line([(wfx - 2, wfy + 25), (wfx - 2, wfy + 140)], fill=(255, 255, 255, 240), width=3)
            draw.ellipse([wfx - 14, wfy + 145, wfx + 14, wfy + 175], fill=(240, 250, 255, 180))

    out_path = os.path.join(TARGET_DIR, "heaven_distant_palace_silhouette.png")
    im.save(out_path)
    print("✓ Created solid floating island temples (1920x420):", out_path)

# -------------------------------------------------------------------------
# 9. Integrated Rose Window Module (heaven_palace_module_rose_window.png)
# -------------------------------------------------------------------------
def create_integrated_rose_window():
    # Build complete module where Rose Window is physically built into an arch pediment
    w = 640
    h = 938
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    col_master = Image.open(os.path.join(TARGET_DIR, "heaven_palace_column.png")).convert("RGBA")
    rose_master = Image.open(os.path.join(TARGET_DIR, "heaven_rose_window.png")).convert("RGBA")

    # 1. Backing Solid Ivory Marble Wall
    c_wall = (248, 245, 238, 255)
    c_wall_shade = (222, 215, 202, 255)
    c_gold = (220, 188, 98, 255)
    c_gold_hl = (255, 244, 172, 255)

    draw.rectangle([40, 60, w - 40, h - 40], fill=c_wall, outline=c_wall_shade, width=3)

    # 2. Integrate Rose Window into wall at upper center
    rose_scaled = rose_master.resize((360, 360), Image.Resampling.LANCZOS)
    rx = (w - 360) // 2
    ry = 90
    # Carved circular marble frame around rose window
    rcx = w // 2
    rcy = ry + 180
    draw.ellipse([rcx - 195, rcy - 195, rcx + 195, rcy + 195], fill=c_wall, outline=c_gold, width=6)
    draw.ellipse([rcx - 185, rcy - 185, rcx + 185, rcy + 185], fill=None, outline=c_gold_hl, width=3)
    im.paste(rose_scaled, (rx, ry), rose_scaled)

    # 3. Flanking Fluted Columns
    im.paste(col_master, (0, 0), col_master)
    im.paste(col_master, (w - col_master.width, 0), col_master)

    # 4. Lower Semicircular Colonnade Arch Opening below Rose Window
    arc_cx = w // 2
    arc_cy = rcy + 220
    arc_r = 185
    draw.arc([arc_cx - arc_r, arc_cy - arc_r, arc_cx + arc_r, arc_cy + arc_r], start=180, end=360, fill=c_gold, width=18)
    draw.arc([arc_cx - (arc_r - 16), arc_cy - (arc_r - 16), arc_cx + (arc_r - 16), arc_cy + (arc_r - 16)], start=180, end=360, fill=(255, 248, 235, 255), width=12)

    # Entablature
    draw.rectangle([0, 40, w, 75], fill=(244, 238, 225, 255), outline=c_gold, width=2)
    draw.line([(0, 40), (w, 40)], fill=(255, 255, 255, 255), width=3)
    # Shared base
    draw.rectangle([0, h - 55, w, h - 5], fill=(232, 224, 210, 255), outline=(185, 175, 160, 255), width=3)

    out_path = os.path.join(TARGET_DIR, "heaven_palace_module_rose_window.png")
    im.save(out_path)
    print("✓ Created integrated rose window architectural module (640x938):", out_path)

# -------------------------------------------------------------------------
# Main Execution
# -------------------------------------------------------------------------
if __name__ == "__main__":
    print("=== GENERATING PHASE 2.2 HEAVEN REBUILD ASSETS ===")
    create_stone_bridge_arch()
    create_marble_roadway()
    create_column_variations()
    create_grand_entrance_door()
    create_ceremonial_fountain()
    create_vaulted_ceiling()
    create_turquoise_celestial_sky()
    create_floating_island_temples()
    create_integrated_rose_window()
    print("=== ALL HEAVEN ASSETS GENERATED SUCCESSFULLY ===")
