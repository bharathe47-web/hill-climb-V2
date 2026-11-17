#!/usr/bin/env python3
"""
build_heaven_phase2_rebuild_assets.py
Generates polished, production-grade visual assets for the Heaven Environment Rebuild:
1. heaven_stone_bridge_arch.png (Modular bridge arch with pale stone masonry, voussoirs, keystone, cloud aperture)
2. heaven_marble_roadway.png & heaven_marble_floor.png (Ivory marble paving, gold inlaid lines, panel divisions, specular edge)
3. heaven_palace_column.png (Zoeluci fluted column master)
4. heaven_palace_column_paired.png (Twin coupled columns with gold entablature)
5. heaven_palace_colonnade_arch.png (Columns joined by an ornate marble & gold semicircular arch)
6. heaven_palace_grand_door.png (Grand celestial double entrance door with marble frame, gold filigree, star medallions)
7. heaven_palace_fountain.png (Ceremonial pedestal fountain with carved marble basin, gold trim, shimmering water)
8. heaven_palace_vaulted_ceiling.png (Repeating architectural ceiling with vaulted arches and gold mouldings)
9. puffy_sky_blue_01.png (Rich turquoise-blue celestial sky gradient)
10. heaven_distant_palace_silhouette.png (Floating islands, classical temple silhouettes, pantheons, waterfalls)
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
# 1. P0 REQUIREMENT: Modular Stone Bridge Arch (heaven_stone_bridge_arch.png)
# -------------------------------------------------------------------------
def create_stone_bridge_arch():
    width = 320
    height = 200
    im = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # Base stone colors
    stone_base = (228, 224, 216, 255)       # Pale cream ashlar stone
    stone_light = (242, 239, 233, 255)      # Sunlit top of blocks
    stone_shadow = (195, 189, 178, 255)     # Under-edge / shadow of blocks
    mortar_line = (168, 162, 150, 255)      # Ashlar block mortar joints
    corbel_gold = (212, 182, 102, 255)      # Gold trim under cornice

    # Arch geometry
    arch_cx = width // 2
    arch_radius = 88
    arch_spring_y = 100
    arch_top_y = arch_spring_y - arch_radius  # 12

    # Draw solid bridge masonry body
    for y in range(height):
        for x in range(width):
            # Check if inside the rounded arch opening
            dx = x - arch_cx
            is_inside_arch = False
            if y >= arch_spring_y and abs(dx) < arch_radius:
                is_inside_arch = True
            elif y < arch_spring_y and y >= arch_top_y:
                dy = y - arch_spring_y
                if dx * dx + dy * dy < arch_radius * arch_radius:
                    is_inside_arch = True

            if is_inside_arch:
                # Inside the arch: soft atmospheric depth & cloud vista
                # Gradient from subtle sky turquoise-blue/cloud mist
                depth_ratio = (y - arch_top_y) / float(height - arch_top_y)
                # Soft cloud aperture with gradient
                alpha = int(40 + 70 * depth_ratio)
                c_r = int(220 + 20 * math.sin(x * 0.05))
                c_g = int(230 + 15 * math.cos(y * 0.05))
                c_b = int(245)
                im.putpixel((x, y), (c_r, c_g, c_b, alpha))
            else:
                # Solid stone masonry block texture
                # Determine ashlar block grid: course height ~24px, block width ~64px
                course = (y - 10) // 24
                offset_x = (course % 2) * 32
                block_col = (x + offset_x) // 64
                local_y = (y - 10) % 24
                local_x = (x + offset_x) % 64

                # Block shading: subtle bevel on top/left, shadow on bottom/right
                is_edge = (local_x == 0 or local_y == 0)
                is_highlight = (local_y == 1 or local_x == 1)
                is_shade = (local_y == 23 or local_x == 63)

                # Stone subtle noise/grain
                grain = int((math.sin(x * 0.3) + math.cos(y * 0.4)) * 4)

                if is_edge:
                    col = mortar_line
                elif is_highlight:
                    col = (min(255, stone_light[0] + grain), min(255, stone_light[1] + grain), min(255, stone_light[2] + grain), 255)
                elif is_shade:
                    col = (max(0, stone_shadow[0] + grain), max(0, stone_shadow[1] + grain), max(0, stone_shadow[2] + grain), 255)
                else:
                    col = (max(0, min(255, stone_base[0] + grain)), max(0, min(255, stone_base[1] + grain)), max(0, min(255, stone_base[2] + grain)), 255)

                im.putpixel((x, y), col)

    # Now draw voussoirs (carved arch stones radiating around the curve)
    num_voussoirs = 17
    outer_radius = arch_radius + 20
    for i in range(num_voussoirs):
        angle_start = math.pi * i / float(num_voussoirs)
        angle_end = math.pi * (i + 1) / float(num_voussoirs)
        angle_mid = (angle_start + angle_end) * 0.5

        is_keystone = (i == num_voussoirs // 2)
        keystone_extra = 6 if is_keystone else 0

        # Draw radiating wedge lines
        x0 = arch_cx - math.cos(angle_start) * arch_radius
        y0 = arch_spring_y - math.sin(angle_start) * arch_radius
        x1 = arch_cx - math.cos(angle_start) * (outer_radius + keystone_extra)
        y1 = arch_spring_y - math.sin(angle_start) * (outer_radius + keystone_extra)
        draw.line([(x0, y0), (x1, y1)], fill=mortar_line, width=2)

        # Highlight on keystone
        if is_keystone:
            kx = arch_cx
            ky = arch_spring_y - (outer_radius + keystone_extra)
            draw.rectangle([kx - 8, ky - 4, kx + 8, ky + 12], fill=(245, 235, 210, 255), outline=corbel_gold, width=1)

    # Vertical arch pilaster jambs (edges of opening)
    draw.line([(arch_cx - arch_radius, arch_spring_y), (arch_cx - arch_radius, height)], fill=corbel_gold, width=2)
    draw.line([(arch_cx + arch_radius, arch_spring_y), (arch_cx + arch_radius, height)], fill=corbel_gold, width=2)

    # Upper bridge cornice moulding & gold trim
    draw.rectangle([0, 0, width, 8], fill=(235, 230, 220, 255))
    draw.line([(0, 0), (width, 0)], fill=(255, 252, 245, 255), width=2)
    draw.line([(0, 7), (width, 7)], fill=corbel_gold, width=2)
    draw.line([(0, 9), (width, 9)], fill=mortar_line, width=1)

    # Left and right pier vertical pilaster accents
    draw.rectangle([0, 10, 28, height], fill=None, outline=mortar_line, width=1)
    draw.line([(28, 10), (28, height)], fill=(210, 202, 190, 255), width=2)
    draw.rectangle([width - 29, 10, width - 1, height], fill=None, outline=mortar_line, width=1)
    draw.line([(width - 29, 10), (width - 29, height)], fill=(210, 202, 190, 255), width=2)

    # Save asset
    out_path = os.path.join(TARGET_DIR, "heaven_stone_bridge_arch.png")
    im.save(out_path)
    print("✓ Created modular stone bridge arch:", out_path)

# -------------------------------------------------------------------------
# 2. Polished Royal Ivory Marble Roadway (heaven_marble_roadway.png)
# -------------------------------------------------------------------------
def create_marble_roadway():
    width = 1920
    height = 90
    im = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    c_marble_light = (252, 250, 246, 255)
    c_marble_mid = (244, 240, 232, 255)
    c_marble_shadow = (222, 216, 204, 255)
    c_gold_rim = (220, 186, 96, 255)
    c_gold_hl = (255, 238, 160, 255)
    c_joint = (195, 185, 170, 255)

    # Draw marble slab layers
    for y in range(height):
        t = y / float(height)
        r = int(c_marble_light[0] * (1.0 - t * 0.35) + c_marble_shadow[0] * (t * 0.35))
        g = int(c_marble_light[1] * (1.0 - t * 0.35) + c_marble_shadow[1] * (t * 0.35))
        b = int(c_marble_light[2] * (1.0 - t * 0.35) + c_marble_shadow[2] * (t * 0.35))
        draw.line([(0, y), (width, y)], fill=(r, g, b, 255))

    # Driving surface crest specular highlight (y=0..4)
    draw.line([(0, 0), (width, 0)], fill=(255, 255, 255, 255), width=2)
    draw.line([(0, 2), (width, 2)], fill=c_gold_hl, width=1)
    draw.line([(0, 4), (width, 4)], fill=c_gold_rim, width=2)

    # Inlaid gold banding (y=16 and y=22)
    draw.line([(0, 16), (width, 16)], fill=c_gold_rim, width=2)
    draw.line([(0, 22), (width, 22)], fill=c_gold_hl, width=1)

    # Repeating marble slab joints and diamond rosettes
    slab_w = 120
    for sx in range(0, width, slab_w):
        # Vertical joint
        draw.line([(sx, 0), (sx, height)], fill=c_joint, width=1)
        draw.line([(sx + 1, 0), (sx + 1, height)], fill=(255, 255, 255, 160), width=1)

        # Inlaid champagne gold diamond rosette at center of each slab
        cx = sx + slab_w // 2
        cy = 19
        d_rad = 5
        diamond = [(cx, cy - d_rad), (cx + d_rad, cy), (cx, cy + d_rad), (cx - d_rad, cy)]
        draw.polygon(diamond, fill=c_gold_hl, outline=c_gold_rim)

    # Lower bridge bevel & underside shadow
    draw.line([(0, height - 6), (width, height - 6)], fill=c_gold_rim, width=1)
    draw.rectangle([0, height - 4, width, height], fill=(185, 178, 165, 255))

    # Save to both roadway and floor
    p1 = os.path.join(TARGET_DIR, "heaven_marble_roadway.png")
    p2 = os.path.join(TARGET_DIR, "heaven_marble_floor.png")
    im.save(p1)
    im.save(p2)
    print("✓ Created marble roadway & floor:", p1)

# -------------------------------------------------------------------------
# 3. Fluted Columns & Variations (Single, Paired, Colonnade Arch)
# -------------------------------------------------------------------------
def create_column_variations():
    # Load Zoeluci's master Column
    zoe_col_path = os.path.join(ZOELUCI_DIR, "Column.png")
    col_master = Image.open(zoe_col_path).convert("RGBA")
    cw, ch = col_master.size # (210, 938)

    # Save primary column
    col_out = os.path.join(TARGET_DIR, "heaven_palace_column.png")
    col_master.save(col_out)
    print("✓ Saved master Zoeluci fluted column (210x938):", col_out)

    # Variation 2: Paired Colonnade (twin coupled columns with gold entablature)
    pair_w = 420
    pair_h = ch
    pair_im = Image.new("RGBA", (pair_w, pair_h), (0, 0, 0, 0))
    # Place left column at x=15, right column at x=195
    pair_im.paste(col_master, (15, 0), col_master)
    pair_im.paste(col_master, (195, 0), col_master)

    p_draw = ImageDraw.Draw(pair_im)
    # Connecting ornamental gold entablature beam across capitals
    ent_y = 60
    p_draw.rectangle([15, ent_y - 20, 405, ent_y + 10], fill=(235, 225, 205, 255), outline=(215, 185, 95, 255), width=2)
    p_draw.line([(15, ent_y - 20), (405, ent_y - 20)], fill=(255, 245, 180, 255), width=3)
    p_draw.line([(15, ent_y + 10), (405, ent_y + 10)], fill=(190, 160, 75, 255), width=2)
    # Connecting base plinth
    base_y = ch - 50
    p_draw.rectangle([5, base_y, 415, ch - 5], fill=(225, 218, 205, 255), outline=(180, 170, 155, 255), width=2)

    pair_out = os.path.join(TARGET_DIR, "heaven_palace_column_paired.png")
    pair_im.save(pair_out)
    print("✓ Created paired colonnade variation (420x938):", pair_out)

    # Variation 3: Arched Colonnade (two columns connected by a vaulted arch span)
    arch_col_w = 640
    arch_col_h = ch
    arch_col_im = Image.new("RGBA", (arch_col_w, arch_col_h), (0, 0, 0, 0))
    # Place columns on flanks: x=0 and x=430
    arch_col_im.paste(col_master, (0, 0), col_master)
    arch_col_im.paste(col_master, (430, 0), col_master)

    ac_draw = ImageDraw.Draw(arch_col_im)
    # Semicircular arch span connecting them at capital height
    arc_cx = arch_col_w // 2 # 320
    arc_cy = 140
    arc_r = 175
    # Outer arch
    ac_draw.arc([arc_cx - arc_r, arc_cy - arc_r, arc_cx + arc_r, arc_cy + arc_r], start=180, end=360, fill=(215, 185, 95, 255), width=18)
    # Inner arch
    ac_draw.arc([arc_cx - (arc_r - 18), arc_cy - (arc_r - 18), arc_cx + (arc_r - 18), arc_cy + (arc_r - 18)], start=180, end=360, fill=(245, 238, 222, 255), width=14)
    # Arch keystone
    ac_draw.rectangle([arc_cx - 16, arc_cy - arc_r - 12, arc_cx + 16, arc_cy - arc_r + 14], fill=(255, 245, 180, 255), outline=(215, 185, 95, 255), width=2)

    arch_out = os.path.join(TARGET_DIR, "heaven_palace_colonnade_arch.png")
    arch_col_im.save(arch_out)
    print("✓ Created arched colonnade variation (640x938):", arch_out)

# -------------------------------------------------------------------------
# 4. Grand Celestial Double Entrance Door (heaven_palace_grand_door.png)
# -------------------------------------------------------------------------
def create_grand_entrance_door():
    w = 512
    h = 720
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    c_marble_frame = (245, 242, 235, 255)
    c_marble_shade = (215, 208, 195, 255)
    c_door_wood = (235, 228, 215, 255)       # Ivory cream lacquered wood
    c_panel_shade = (195, 185, 170, 255)
    c_gold_rim = (218, 186, 96, 255)
    c_gold_hl = (255, 240, 165, 255)

    # 1. Outer Marble Portal Surround / Pilasters
    draw.rectangle([30, 60, w - 30, h - 20], fill=c_marble_frame, outline=c_marble_shade, width=4)
    # Stepped pediment at top
    pediment = [(20, 60), (w // 2, 8), (w - 20, 60)]
    draw.polygon(pediment, fill=c_marble_frame, outline=c_gold_rim)
    # Golden crest on pediment apex
    draw.ellipse([w // 2 - 20, 18, w // 2 + 20, 58], fill=c_gold_hl, outline=c_gold_rim, width=2)

    # 2. Arched Portal Opening
    door_left = 65
    door_top = 110
    door_right = w - 65
    door_bottom = h - 25
    door_w = door_right - door_left
    door_h = door_bottom - door_top

    # Semicircular arch top of door
    arch_box = [door_left, door_top, door_right, door_top + door_w]
    draw.pieslice(arch_box, start=180, end=360, fill=(35, 45, 60, 255), outline=c_gold_rim, width=3)
    # Tympanum sunburst inside arch
    tcx = w // 2
    tcy = door_top + door_w // 2
    for ray in range(13):
        ang = math.pi + math.pi * ray / 12.0
        rx = tcx + math.cos(ang) * (door_w // 2 - 8)
        ry = tcy + math.sin(ang) * (door_w // 2 - 8)
        draw.line([(tcx, tcy), (rx, ry)], fill=c_gold_hl, width=2)
    draw.ellipse([tcx - 22, tcy - 22, tcx + 22, tcy + 22], fill=c_gold_hl, outline=c_gold_rim, width=2)

    # Rectangular dual doors
    d_rect_top = door_top + door_w // 2
    draw.rectangle([door_left, d_rect_top, door_right, door_bottom], fill=c_door_wood, outline=c_gold_rim, width=3)

    # Central door division (seam between left and right door leaf)
    mid_x = w // 2
    draw.line([(mid_x, d_rect_top), (mid_x, door_bottom)], fill=c_panel_shade, width=4)
    draw.line([(mid_x - 1, d_rect_top), (mid_x - 1, door_bottom)], fill=c_gold_rim, width=2)

    # Decorative panels on each door leaf (3 per side)
    leaf_w = (door_right - door_left - 10) // 2
    panel_h = (door_bottom - d_rect_top - 40) // 3
    for side, lx in [(0, door_left + 5), (1, mid_x + 5)]:
        for p in range(3):
            py = d_rect_top + 15 + p * (panel_h + 8)
            # Panel outer bevel
            draw.rectangle([lx, py, lx + leaf_w - 6, py + panel_h], fill=(248, 245, 238, 255), outline=c_gold_rim, width=2)
            # Inset panel
            draw.rectangle([lx + 6, py + 6, lx + leaf_w - 12, py + panel_h - 6], fill=(238, 230, 218, 255), outline=c_panel_shade, width=1)
            # Central celestial star medallion in each panel
            pcx = lx + leaf_w // 2 - 3
            pcy = py + panel_h // 2
            draw.ellipse([pcx - 12, pcy - 12, pcx + 12, pcy + 12], fill=c_gold_hl, outline=c_gold_rim, width=2)
            for s_ang in [0, 45, 90, 135]:
                rad = math.radians(s_ang)
                dx = math.cos(rad) * 16
                dy = math.sin(rad) * 16
                draw.line([(pcx - dx, pcy - dy), (pcx + dx, pcy + dy)], fill=c_gold_hl, width=2)

    # Golden Door Handles at waist height
    handle_y = d_rect_top + panel_h + 20
    draw.ellipse([mid_x - 22, handle_y - 8, mid_x - 10, handle_y + 24], fill=c_gold_hl, outline=c_gold_rim, width=2)
    draw.ellipse([mid_x + 10, handle_y - 8, mid_x + 22, handle_y + 24], fill=c_gold_hl, outline=c_gold_rim, width=2)

    # Save
    out_path = os.path.join(TARGET_DIR, "heaven_palace_grand_door.png")
    im.save(out_path)
    print("✓ Created grand celestial double door:", out_path)

# -------------------------------------------------------------------------
# 5. Ceremonial Fountain / Pedestal (heaven_palace_fountain.png)
# -------------------------------------------------------------------------
def create_ceremonial_fountain():
    w = 360
    h = 460
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    c_marble = (248, 244, 236, 255)
    c_marble_shade = (210, 202, 188, 255)
    c_gold = (220, 188, 96, 255)
    c_gold_hl = (255, 242, 170, 255)
    c_water = (160, 225, 245, 200)
    c_water_deep = (90, 175, 215, 230)

    cx = w // 2

    # 1. Stepped Pedestal Base (Bottom)
    draw.rectangle([cx - 150, h - 30, cx + 150, h - 5], fill=c_marble, outline=c_gold, width=2)
    draw.rectangle([cx - 120, h - 55, cx + 120, h - 30], fill=c_marble, outline=c_marble_shade, width=2)
    draw.rectangle([cx - 90, h - 75, cx + 90, h - 55], fill=c_marble, outline=c_gold, width=2)

    # 2. Lower Fluted Stem / Column
    stem_top = h - 190
    stem_bottom = h - 75
    draw.rectangle([cx - 40, stem_top, cx + 40, stem_bottom], fill=c_marble, outline=c_marble_shade, width=2)
    # Fluting
    for fx in range(cx - 32, cx + 33, 16):
        draw.line([(fx, stem_top), (fx, stem_bottom)], fill=c_marble_shade, width=2)
        draw.line([(fx + 1, stem_top), (fx + 1, stem_bottom)], fill=(255, 255, 255, 180), width=1)
    # Acanthus leaf gold ring on stem
    draw.rectangle([cx - 48, stem_bottom - 20, cx + 48, stem_bottom], fill=c_gold_hl, outline=c_gold, width=2)
    draw.rectangle([cx - 48, stem_top, cx + 48, stem_top + 18], fill=c_gold_hl, outline=c_gold, width=2)

    # 3. Main Carved Marble Basin (Wide Bowl)
    basin_y = stem_top
    basin_rx = 160
    basin_ry = 38
    # Lower bowl curve
    draw.pieslice([cx - basin_rx, basin_y - basin_ry, cx + basin_rx, basin_y + basin_ry + 45], start=0, end=180, fill=c_marble, outline=c_marble_shade, width=3)
    # Basin rim gold filigree
    draw.ellipse([cx - basin_rx, basin_y - basin_ry, cx + basin_rx, basin_y + basin_ry], fill=c_marble, outline=c_gold, width=4)
    # Shimmering celestial water in lower bowl
    draw.ellipse([cx - basin_rx + 10, basin_y - basin_ry + 6, cx + basin_rx - 10, basin_y + basin_ry - 6], fill=c_water_deep, outline=c_water, width=2)

    # 4. Upper Tier / Stem
    tier2_bottom = basin_y - 15
    tier2_top = tier2_bottom - 95
    draw.rectangle([cx - 24, tier2_top, cx + 24, tier2_bottom], fill=c_marble, outline=c_gold, width=2)

    # 5. Upper Small Basin
    u_rx = 85
    u_ry = 22
    u_y = tier2_top
    draw.pieslice([cx - u_rx, u_y - u_ry, cx + u_rx, u_y + u_ry + 28], start=0, end=180, fill=c_marble, outline=c_marble_shade, width=2)
    draw.ellipse([cx - u_rx, u_y - u_ry, cx + u_rx, u_y + u_ry], fill=c_water_deep, outline=c_gold, width=3)

    # 6. Central Spout Finial & Water Jet
    finial_top = u_y - 50
    draw.ellipse([cx - 14, finial_top, cx + 14, finial_top + 28], fill=c_gold_hl, outline=c_gold, width=2)
    # Water jet spray
    draw.line([(cx, finial_top), (cx, finial_top - 35)], fill=(220, 245, 255, 240), width=4)
    # Cascading water droplets / streams
    for dx, dy in [(-25, 25), (-45, 60), (-75, 110), (25, 25), (45, 60), (75, 110)]:
        draw.ellipse([cx + dx - 3, finial_top + dy - 3, cx + dx + 3, finial_top + dy + 3], fill=(225, 250, 255, 220))

    out_path = os.path.join(TARGET_DIR, "heaven_palace_fountain.png")
    im.save(out_path)
    print("✓ Created ceremonial fountain / pedestal:", out_path)

# -------------------------------------------------------------------------
# 6. Repeating Vaulted Palace Ceiling (heaven_palace_vaulted_ceiling.png)
# -------------------------------------------------------------------------
def create_vaulted_ceiling():
    w = 1920
    h = 130
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    c_cornice_top = (252, 250, 246, 255)
    c_moulding = (235, 228, 215, 255)
    c_shade = (195, 185, 170, 255)
    c_gold = (218, 186, 96, 255)
    c_gold_hl = (255, 242, 170, 255)

    # Upper horizontal cornice beam
    draw.rectangle([0, 0, w, 24], fill=c_cornice_top)
    draw.line([(0, 0), (w, 0)], fill=(255, 255, 255, 255), width=3)
    draw.line([(0, 14), (w, 14)], fill=c_gold_hl, width=2)
    draw.line([(0, 24), (w, 24)], fill=c_gold, width=3)

    # Repeating groin vault arches (arch span = 320px)
    span = 320
    for ax in range(0, w, span):
        acx = ax + span // 2
        acy = 24
        ar = span // 2
        # Arch moulding
        draw.arc([acx - ar, acy - ar, acx + ar, acy + ar], start=0, end=180, fill=c_moulding, width=12)
        draw.arc([acx - (ar - 6), acy - (ar - 6), acx + (ar - 6), acy + (ar - 6)], start=0, end=180, fill=c_gold, width=4)
        # Gold pendant drop at center of arch
        draw.ellipse([acx - 8, acy + ar - 6, acx + 8, acy + ar + 14], fill=c_gold_hl, outline=c_gold, width=2)
        # Spandrel panel between arches
        draw.polygon([(ax, 24), (ax + 40, 24), (ax, 75)], fill=c_shade)
        draw.polygon([(ax + span, 24), (ax + span - 40, 24), (ax + span, 75)], fill=c_shade)

    out_path = os.path.join(TARGET_DIR, "heaven_palace_vaulted_ceiling.png")
    im.save(out_path)
    print("✓ Created vaulted palace ceiling:", out_path)

# -------------------------------------------------------------------------
# 7. Rich Turquoise Celestial Sky (puffy_sky_blue_01.png)
# -------------------------------------------------------------------------
def create_turquoise_celestial_sky():
    w = 1920
    h = 1080
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))

    # Vibrant turquoise-blue celestial sky gradient:
    # Top: Deep royal cyan / azure (27, 93, 138)
    # Mid-Upper: Radiant celestial azure (48, 145, 192)
    # Mid: Luminous turquoise-blue (78, 185, 215)
    # Horizon: Warm sunlit morning cyan-gold (165, 222, 235)
    top_c = (27, 93, 138)
    mid_upper_c = (48, 145, 192)
    mid_c = (78, 185, 215)
    horizon_c = (175, 225, 235)

    pixels = []
    for y in range(h):
        t = y / float(h)
        if t < 0.35:
            # top to mid-upper
            st = t / 0.35
            r = int(top_c[0] * (1.0 - st) + mid_upper_c[0] * st)
            g = int(top_c[1] * (1.0 - st) + mid_upper_c[1] * st)
            b = int(top_c[2] * (1.0 - st) + mid_upper_c[2] * st)
        elif t < 0.70:
            # mid-upper to mid
            st = (t - 0.35) / 0.35
            r = int(mid_upper_c[0] * (1.0 - st) + mid_c[0] * st)
            g = int(mid_upper_c[1] * (1.0 - st) + mid_c[1] * st)
            b = int(mid_upper_c[2] * (1.0 - st) + mid_c[2] * st)
        else:
            # mid to horizon
            st = (t - 0.70) / 0.30
            r = int(mid_c[0] * (1.0 - st) + horizon_c[0] * st)
            g = int(mid_c[1] * (1.0 - st) + horizon_c[1] * st)
            b = int(mid_c[2] * (1.0 - st) + horizon_c[2] * st)
        # Fill row
        for x in range(w):
            pixels.append((r, g, b, 255))

    im.putdata(pixels)
    out_path = os.path.join(SKY_DIR, "puffy_sky_blue_01.png")
    im.save(out_path)
    print("✓ Created rich turquoise-blue celestial sky gradient:", out_path)

# -------------------------------------------------------------------------
# 8. Floating Islands, Temple Pantheons & Waterfalls (heaven_distant_palace_silhouette.png)
# -------------------------------------------------------------------------
def create_floating_island_temples():
    w = 1920
    h = 420
    im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)

    # Distant atmospheric tint: soft celestial turquoise-white
    temple_c = (235, 242, 248, 200)
    temple_shade = (185, 205, 225, 180)
    island_rock = (175, 192, 208, 190)
    island_grass = (195, 225, 210, 210)
    gold_dome = (245, 225, 140, 220)
    waterfall_c = (230, 248, 255, 180)

    # 3 Floating Island complexes across 1920px width
    islands = [
        {"cx": 320, "cy": 240, "rx": 220, "ry": 60, "dome": True, "waterfall": True},
        {"cx": 960, "cy": 200, "rx": 280, "ry": 75, "dome": True, "waterfall": True},
        {"cx": 1600, "cy": 230, "rx": 240, "ry": 65, "dome": True, "waterfall": False},
    ]

    for isl in islands:
        cx = isl["cx"]
        cy = isl["cy"]
        rx = isl["rx"]
        ry = isl["ry"]

        # Island underside rocky cone
        rock_pts = [
            (cx - rx, cy),
            (cx - rx * 0.5, cy + ry * 1.8),
            (cx, cy + ry * 2.6),
            (cx + rx * 0.5, cy + ry * 1.6),
            (cx + rx, cy)
        ]
        draw.polygon(rock_pts, fill=island_rock)

        # Island top lush terrace
        draw.ellipse([cx - rx, cy - ry // 2, cx + rx, cy + ry // 2], fill=island_grass, outline=temple_c, width=1)

        # Classical Temple Architecture on top of Island
        ty = cy - ry // 2
        # Temple stepped plinth
        tw = rx * 0.75
        draw.rectangle([cx - tw // 2, ty - 12, cx + tw // 2, ty], fill=temple_c)
        # Colonnade
        num_cols = 8
        col_spacing = tw / float(num_cols - 1)
        for ci in range(num_cols):
            clx = cx - tw // 2 + ci * col_spacing
            draw.line([(clx, ty - 12), (clx, ty - 65)], fill=temple_c, width=4)
        # Entablature / Architrave
        draw.rectangle([cx - tw // 2 - 8, ty - 78, cx + tw // 2 + 8, ty - 65], fill=temple_c)
        # Classical Dome or Pediment
        if isl["dome"]:
            dome_r = tw * 0.35
            draw.pieslice([cx - dome_r, ty - 78 - dome_r, cx + dome_r, ty - 78 + dome_r], start=180, end=360, fill=gold_dome, outline=temple_c, width=2)
            # Dome finial
            draw.line([(cx, ty - 78 - dome_r), (cx, ty - 78 - dome_r - 16)], fill=gold_dome, width=3)
        else:
            ped = [(cx - tw // 2 - 8, ty - 78), (cx, ty - 110), (cx + tw // 2 + 8, ty - 78)]
            draw.polygon(ped, fill=temple_c, outline=gold_dome)

        # Cascading Waterfall spilling from island edge into clouds
        if isl["waterfall"]:
            wfx = cx + rx * 0.4
            wfy = cy
            draw.line([(wfx, wfy), (wfx, wfy + 140)], fill=waterfall_c, width=6)
            draw.line([(wfx - 2, wfy + 20), (wfx - 2, wfy + 120)], fill=(255, 255, 255, 210), width=2)

    out_path = os.path.join(TARGET_DIR, "heaven_distant_palace_silhouette.png")
    im.save(out_path)
    print("✓ Created distant floating islands & temple pantheons:", out_path)

if __name__ == "__main__":
    print("=== BUILDING HEAVEN PHASE 2 REBUILD ASSETS ===")
    create_stone_bridge_arch()
    create_marble_roadway()
    create_column_variations()
    create_grand_entrance_door()
    create_ceremonial_fountain()
    create_vaulted_ceiling()
    create_turquoise_celestial_sky()
    create_floating_island_temples()
    print("=== ALL ASSETS GENERATED SUCCESSFULLY ===")
