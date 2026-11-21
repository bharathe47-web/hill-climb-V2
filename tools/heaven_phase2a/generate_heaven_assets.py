#!/usr/bin/env python3
"""
tools/heaven_phase2a/generate_heaven_assets.py

Endless Hill Climb — Phase 2A Asset Production Script
Generates the four required Heaven architectural and terrain PNG assets
using existing project source materials, classical architectural geometry,
genuine alpha transparency, and seamless horizontal tiling.

Outputs:
1. assets/environments/heaven/architecture/heaven_marble_deck_inlaid.png (1920x120)
2. assets/environments/heaven/architecture/heaven_viaduct_arch_cutout.png (640x360)
3. assets/environments/heaven/architecture/heaven_marble_balustrade.png (640x96)
4. assets/environments/heaven/architecture/heaven_palace_entablature.png (1280x80)
"""

import os
import sys
import math
from PIL import Image, ImageDraw, ImageFilter

# Base directories
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
HEAVEN_ARCH_DIR = os.path.join(PROJECT_ROOT, "assets/environments/heaven/architecture")

# Source files
SRC_ROADWAY = os.path.join(HEAVEN_ARCH_DIR, "heaven_marble_roadway.png")
SRC_BRIDGE_ARCH = os.path.join(HEAVEN_ARCH_DIR, "heaven_stone_bridge_arch.png")
SRC_COLUMN = os.path.join(HEAVEN_ARCH_DIR, "heaven_palace_column.png")
SRC_CEILING = os.path.join(HEAVEN_ARCH_DIR, "heaven_palace_ceiling.png")

# Target outputs
OUT_DECK = os.path.join(HEAVEN_ARCH_DIR, "heaven_marble_deck_inlaid.png")
OUT_VIADUCT = os.path.join(HEAVEN_ARCH_DIR, "heaven_viaduct_arch_cutout.png")
OUT_BALUSTRADE = os.path.join(HEAVEN_ARCH_DIR, "heaven_marble_balustrade.png")
OUT_ENTABLATURE = os.path.join(HEAVEN_ARCH_DIR, "heaven_palace_entablature.png")


def check_sources():
    """Verify all required source textures exist before generation."""
    print("=== [1/6] VERIFYING SOURCE TEXTURES ===")
    sources = [
        ("Roadway Surface", SRC_ROADWAY),
        ("Bridge Arch Primitive", SRC_BRIDGE_ARCH),
        ("Palace Column", SRC_COLUMN),
        ("Palace Ceiling Cornice", SRC_CEILING),
    ]
    all_ok = True
    for label, path in sources:
        if not os.path.exists(path):
            print(f"ERROR: Missing source texture: {path} ({label})")
            all_ok = False
        else:
            sz = os.path.getsize(path) / 1024.0
            with Image.open(path) as im:
                print(f"  OK: {os.path.basename(path)} [{label}] - {im.size[0]}x{im.size[1]} {im.mode} ({sz:.1f} KB)")
    if not all_ok:
        raise FileNotFoundError("One or more required source textures are missing. Aborting.")
    print("All source textures verified successfully.\n")


def sample_palette():
    """Sample authentic color palettes from existing project textures."""
    with Image.open(SRC_ROADWAY) as im_road:
        # Sample ivory marble tones from the clean roadway body
        marble_highlight = im_road.getpixel((100, 10))[:3]
        marble_mid = im_road.getpixel((100, 45))[:3]
        marble_shadow = im_road.getpixel((100, 75))[:3]
        gold_trim_src = im_road.getpixel((100, 90))[:3]

    with Image.open(SRC_CEILING) as im_ceil:
        ceil_ivory = im_ceil.getpixel((100, 10))[:3]
        ceil_shadow = im_ceil.getpixel((100, 36))[:3]

    with Image.open(SRC_BRIDGE_ARCH) as im_arch:
        stone_base = im_arch.getpixel((36, 100))[:3]
        stone_shadow = im_arch.getpixel((36, 40))[:3]

    palette = {
        "marble_light": marble_highlight,       # ~ (252, 250, 246)
        "marble_mid": marble_mid,               # ~ (249, 247, 242)
        "marble_shadow": marble_shadow,         # ~ (246, 243, 237)
        "gold_bright": (250, 215, 75),          # High-key imperial gold highlight
        "gold_mid": (225, 175, 45),             # Rich imperial gold body
        "gold_shadow": (160, 115, 30),          # Warm gold shadow/bevel
        "gold_deep": (115, 80, 20),             # Inlaid gold recess shadow
        "stone_light": stone_base,              # ~ (212, 206, 196)
        "stone_shadow": stone_shadow,           # ~ (135, 126, 110)
        "ceil_ivory": ceil_ivory,               # ~ (247, 239, 214)
        "ceil_shadow": ceil_shadow,             # ~ (218, 210, 188)
        "joint_shadow": (195, 185, 175),        # Subtle paver joint line
        "joint_highlight": (255, 255, 252),     # Subtle paver chamfer highlight
    }
    return palette


def generate_marble_deck(palette):
    """
    Asset 1: Inlaid Marble Road Deck (1920x120 px, RGBA)
    - Polished ivory marble deck with source marble grain.
    - Imperial gold bullnose curb (y=0..14).
    - Inlaid gold Greek key / fretwork mosaic band (y=15..40).
    - Polished marble pavers with transverse joints every 160 px (y=41..112).
    - Lower transition band (y=113..120).
    - Seamless horizontal tiling across 1920 px.
    """
    print("=== [2/6] GENERATING ASSET 1: Inlaid Marble Road Deck ===")
    width, height = 1920, 120
    deck = Image.new("RGBA", (width, height), (0, 0, 0, 0))

    # 1. Base marble background sampled from source roadway
    with Image.open(SRC_ROADWAY) as im_road:
        road_crop = im_road.crop((0, 5, 1920, 95)).resize((1920, 120), Image.Resampling.LANCZOS)
        deck.paste(road_crop, (0, 0))

    draw = ImageDraw.Draw(deck)

    # 2. Prominent Gold Bullnose Curb along upper edge (y = 0..14)
    for y in range(15):
        if y == 0:
            col = (255, 255, 255, 255) # Specular glint
        elif y <= 2:
            col = (255, 235, 130, 255) # Bright gold highlight
        elif y <= 8:
            t = (y - 3) / 5.0
            r = int(250 * (1 - t) + 225 * t)
            g = int(215 * (1 - t) + 175 * t)
            b = int(75 * (1 - t) + 45 * t)
            col = (r, g, b, 255)
        elif y <= 11:
            col = palette["gold_mid"] + (255,)
        else:
            col = palette["gold_shadow"] + (255,)
        draw.line([(0, y), (width - 1, y)], fill=col)

    # 3. Inlaid Greek Key / Geometric Fretwork Band (y = 15..40)
    # Background for mosaic channel: slightly polished ivory field
    for y in range(15, 41):
        draw.line([(0, y), (width - 1, y)], fill=(247, 244, 238, 255))

    # Upper and lower gold fillet borders
    draw.line([(0, 15), (width - 1, 15)], fill=palette["gold_shadow"] + (255,))
    draw.line([(0, 16), (width - 1, 16)], fill=palette["gold_mid"] + (255,))
    draw.line([(0, 39), (width - 1, 39)], fill=palette["gold_mid"] + (255,))
    draw.line([(0, 40), (width - 1, 40)], fill=palette["gold_shadow"] + (255,))

    # Greek Key Meander Pattern repeating every 32 px (1920 / 32 = exactly 60 periods)
    period = 32
    for p in range(width // period):
        ox = p * period
        # Subtle 1px drop shadow for inlaid look
        shadow_pts = [
            (ox + 0, 31),
            (ox + 26, 31),
            (ox + 26, 21),
            (ox + 6, 21),
            (ox + 6, 27),
            (ox + 20, 27),
            (ox + 20, 24),
            (ox + 13, 24)
        ]
        draw.line(shadow_pts, fill=palette["gold_deep"] + (180,), width=3, joint="miter")
        draw.line([(ox + 26, 31), (ox + 32, 31)], fill=palette["gold_deep"] + (180,), width=3)

        # Main Imperial Gold Fret line
        gold_pts = [
            (ox + 0, 30),
            (ox + 26, 30),
            (ox + 26, 20),
            (ox + 6, 20),
            (ox + 6, 26),
            (ox + 20, 26),
            (ox + 20, 23),
            (ox + 13, 23)
        ]
        draw.line(gold_pts, fill=palette["gold_bright"] + (255,), width=2, joint="miter")
        draw.line([(ox + 26, 30), (ox + 32, 30)], fill=palette["gold_bright"] + (255,), width=2)

    # 4. Transverse Stone Paver Joints (y = 41..112, spaced every 160 px -> 12 pavers)
    paver_w = 160
    for p in range(width // paver_w):
        jx = p * paver_w
        # Subtle recessed joint shadow line + highlight line
        draw.line([(jx, 41), (jx, 112)], fill=palette["joint_shadow"] + (255,), width=1)
        draw.line([(jx + 1, 41), (jx + 1, 112)], fill=palette["joint_highlight"] + (255,), width=1)

    # 5. Bottom subtle ambient occlusion shadow (y = 113..119)
    for y in range(113, 120):
        alpha_t = (y - 113) / 7.0
        sh_col = int(240 * (1 - alpha_t) + 200 * alpha_t)
        draw.line([(0, y), (width - 1, y)], fill=(sh_col, sh_col - 5, sh_col - 12, 255))

    deck.save(OUT_DECK, "PNG")
    print(f"  Generated: {os.path.basename(OUT_DECK)} ({width}x{height}, {os.path.getsize(OUT_DECK)/1024:.1f} KB)")


def generate_viaduct_arch(palette):
    """
    Asset 2: Transparent Viaduct Bridge Arch (640x360 px, RGBA)
    - Monumental semicircular Roman bridge arch with classical ashlar masonry.
    - Sourced from heaven_stone_bridge_arch.png.
    - Center opening has GENUINE 100% transparency (alpha = 0).
    - Semicircular radius R = 170 px, center (320, 200).
    - Ashlar stone piers from x=0..150 and x=490..640.
    - Top molded classical cornice (y=0..35) with gold dentil trim.
    - Keystone at arch apex in imperial gold.
    - Seamless horizontal tiling across 640 px width.
    """
    print("=== [3/6] GENERATING ASSET 2: Transparent Viaduct Bridge Arch ===")
    width, height = 640, 360
    arch = Image.new("RGBA", (width, height), (0, 0, 0, 0))

    # Arch mathematical geometry
    cx = 320.0
    cy = 200.0
    r_in = 170.0    # Arch opening inner radius
    r_out = 220.0   # Arch voussoirs outer radius
    spring_y = 200.0 # Springing line

    # 1. Base Ashlar Masonry Background for piers and spandrels
    # Sample authentic pale stone texture from source
    with Image.open(SRC_BRIDGE_ARCH) as im_src:
        src_stone = im_src.crop((0, 40, 73, 230)).resize((150, 360), Image.Resampling.LANCZOS)
        # Left pier
        arch.paste(src_stone, (0, 0))
        # Right pier (mirrored for perfect balance)
        arch.paste(src_stone.transpose(Image.FLIP_LEFT_RIGHT), (490, 0))

        # Fill central spandrel area above arch
        spandrel_tile = im_src.crop((10, 40, 60, 100)).resize((340, 150), Image.Resampling.LANCZOS)
        arch.paste(spandrel_tile, (150, 0))

    draw = ImageDraw.Draw(arch)

    # 2. Ashlar Stone Block Courses and Mortar Joints
    # Horizontal stone courses every 32 px
    for y in range(40, height, 32):
        draw.line([(0, y), (150, y)], fill=palette["stone_shadow"] + (255,), width=1)
        draw.line([(490, y), (width - 1, y)], fill=palette["stone_shadow"] + (255,), width=1)
        draw.line([(0, y + 1), (150, y + 1)], fill=(240, 235, 225, 255), width=1)
        draw.line([(490, y + 1), (width - 1, y + 1)], fill=(240, 235, 225, 255), width=1)

    # Staggered vertical mortar joints
    for idx, y in enumerate(range(40, height - 32, 32)):
        offset = 0 if (idx % 2 == 0) else 75
        # Left pier joints
        for jx in [offset, offset + 75]:
            if 0 < jx < 150:
                draw.line([(jx, y), (jx, y + 32)], fill=palette["stone_shadow"] + (255,), width=1)
        # Right pier joints
        for jx in [490 + offset, 490 + offset + 75]:
            if 490 < jx < width - 1:
                draw.line([(jx, y), (jx, y + 32)], fill=palette["stone_shadow"] + (255,), width=1)

    # 3. Radial Arch Voussoirs (Wedge stones forming the semicircular arch ring)
    num_voussoirs = 27
    for i in range(num_voussoirs + 1):
        ang = math.pi * (float(i) / float(num_voussoirs))
        x1 = cx - r_in * math.cos(ang)
        y1 = cy - r_in * math.sin(ang)
        x2 = cx - r_out * math.cos(ang)
        y2 = cy - r_out * math.sin(ang)
        if y1 >= 32 and y2 >= 32:
            draw.line([(int(x1), int(y1)), (int(x2), int(y2))], fill=palette["stone_shadow"] + (255,), width=1)

    # Outer Arch Ring Molding (fillet)
    draw.arc([cx - r_out, cy - r_out, cx + r_out, cy + r_out], start=180, end=360, fill=palette["gold_mid"] + (255,), width=2)
    # Inner Arch Ring Molding (intrados rim)
    draw.arc([cx - r_in, cy - r_in, cx + r_in, cy + r_in], start=180, end=360, fill=palette["gold_mid"] + (255,), width=2)

    # 4. Ornate Gold Keystone at Arch Apex (x = 295..345, y = 20..68)
    keystone_pts = [
        (292, 22), (348, 22),   # Wide top cornice
        (338, 68), (302, 68)    # Tapered bottom
    ]
    draw.polygon(keystone_pts, fill=palette["gold_bright"] + (255,))
    draw.polygon(keystone_pts, outline=palette["gold_deep"] + (255,))
    # Inner relief scroll on keystone
    draw.line([(320, 26), (320, 62)], fill=palette["gold_deep"] + (255,), width=2)
    draw.ellipse([312, 34, 328, 50], outline=palette["gold_shadow"] + (255,), width=2)

    # 5. Impost Molding at Springing Line (y = 194..204)
    # Left pier impost
    draw.rectangle([0, 194, 154, 204], fill=palette["ceil_ivory"] + (255,), outline=palette["gold_mid"] + (255,))
    draw.line([(0, 198), (154, 198)], fill=palette["gold_bright"] + (255,), width=2)
    # Right pier impost
    draw.rectangle([486, 194, width, 204], fill=palette["ceil_ivory"] + (255,), outline=palette["gold_mid"] + (255,))
    draw.line([(486, 198), (width, 198)], fill=palette["gold_bright"] + (255,), width=2)

    # 6. Top Classical Molded Cornice (y = 0..35)
    # Gold coping rail
    draw.rectangle([0, 0, width, 5], fill=palette["gold_bright"] + (255,))
    # Molded ivory fascia
    for y in range(5, 22):
        t = (y - 5) / 17.0
        shade = int(245 * (1 - t) + 215 * t)
        draw.line([(0, y), (width, y)], fill=(shade, shade - 5, shade - 15, 255))
    # Gold Dentil Molding (teeth every 20 px)
    draw.line([(0, 22), (width, 22)], fill=palette["gold_shadow"] + (255,), width=1)
    for dx in range(0, width, 20):
        draw.rectangle([dx, 23, dx + 12, 31], fill=(250, 246, 238, 255), outline=palette["gold_shadow"] + (255,))
    # Cornice bed fillet & drip shadow
    draw.line([(0, 32), (width, 32)], fill=palette["gold_mid"] + (255,), width=2)
    draw.line([(0, 34), (width, 34)], fill=palette["gold_deep"] + (180,), width=1)

    # 7. CRITICAL ALPHA CUTOUT: The Arch Opening MUST BE 100% GENUINE TRANSPARENT
    # We iterate over pixels and set alpha=0 inside the exact semicircular and vertical cutout
    pix = arch.load()
    for y in range(height):
        for x in range(width):
            # Check if (x, y) is inside the opening
            is_inside = False
            dist_to_edge = 999.0

            if y < spring_y:
                # Semicircular upper arch
                dx = x - cx
                dy = cy - y
                r = math.sqrt(dx * dx + dy * dy)
                if r < r_in:
                    is_inside = True
                    dist_to_edge = r_in - r
            else:
                # Vertical rectangular drop below springing line
                if (cx - r_in) < x < (cx + r_in):
                    is_inside = True
                    dist_to_edge = min(x - (cx - r_in), (cx + r_in) - x)

            if is_inside:
                if dist_to_edge < 1.5:
                    # Antialiased boundary (0 < alpha < 255)
                    alpha_val = int(255.0 * (1.5 - dist_to_edge) / 1.5)
                    r, g, b, _ = pix[x, y]
                    pix[x, y] = (r, g, b, min(255, max(0, 255 - alpha_val)))
                else:
                    # Deep interior: ABSOLUTE ZERO ALPHA
                    pix[x, y] = (0, 0, 0, 0)

    arch.save(OUT_VIADUCT, "PNG")
    print(f"  Generated: {os.path.basename(OUT_VIADUCT)} ({width}x{height}, {os.path.getsize(OUT_VIADUCT)/1024:.1f} KB)")


def generate_marble_balustrade(palette):
    """
    Asset 3: Classical Marble Balustrade (640x96 px, RGBA)
    - 16 turned ivory marble balusters with gold waist rings.
    - Spaced every 40 px across 640 px width (cx = 20, 60, 100, ...).
    - Gold-trimmed upper handrail (y = 0..18).
    - Continuous ivory marble base plinth (y = 76..96).
    - GENUINE TRANSPARENCY between balusters (alpha = 0).
    - Seamless horizontal tiling across 640 px width.
    """
    print("=== [4/6] GENERATING ASSET 3: Classical Marble Balustrade ===")
    width, height = 640, 96
    bal = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(bal)

    # 1. Continuous Top Handrail (y = 0..18)
    # Gold coping cap
    draw.line([(0, 0), (width, 0)], fill=(255, 255, 255, 255)) # highlight
    draw.line([(0, 1), (width, 1)], fill=palette["gold_bright"] + (255,))
    draw.line([(0, 2), (width, 2)], fill=palette["gold_mid"] + (255,))
    draw.line([(0, 3), (width, 3)], fill=palette["gold_shadow"] + (255,))

    # Molded Ivory Handrail body
    for y in range(4, 15):
        t = (y - 4) / 11.0
        sh = int(246 * (1 - t) + 225 * t)
        draw.line([(0, y), (width, y)], fill=(sh, sh - 3, sh - 8, 255))

    # Gold lower handrail fillet
    draw.line([(0, 15), (width, 15)], fill=palette["gold_bright"] + (255,))
    draw.line([(0, 16), (width, 16)], fill=palette["gold_mid"] + (255,))
    draw.line([(0, 17), (width, 17)], fill=palette["gold_shadow"] + (255,))

    # 2. Continuous Bottom Marble Base / Plinth (y = 76..96)
    # Upper gold fillet molding
    draw.line([(0, 76), (width, 76)], fill=palette["gold_bright"] + (255,))
    draw.line([(0, 77), (width, 77)], fill=palette["gold_mid"] + (255,))
    draw.line([(0, 78), (width, 78)], fill=palette["gold_shadow"] + (255,))

    # Polished ivory plinth body
    for y in range(79, 94):
        t = (y - 79) / 15.0
        sh = int(242 * (1 - t) + 218 * t)
        draw.line([(0, y), (width, y)], fill=(sh, sh - 4, sh - 10, 255))

    # Bottom shadow edge
    draw.line([(0, 94), (width, 94)], fill=palette["stone_shadow"] + (255,))
    draw.line([(0, 95), (width, 95)], fill=(120, 105, 90, 255))

    # 3. Classical Turned Balusters (y = 18..76, height 58 px)
    # 16 balusters spaced every 40 px: centers at 20, 60, 100, ..., 620
    def baluster_half_width(y):
        """Analytical silhouette profile of classical turned baluster."""
        if y < 24: # Upper abacus square block
            return 7.0
        elif y < 30: # Concave throat / neck
            t = (y - 24) / 6.0
            return 7.0 - 2.0 * math.sin(t * math.pi * 0.5)
        elif y < 42: # Upper swelling bulb
            t = (y - 30) / 12.0
            return 5.0 + 4.0 * math.sin(t * math.pi * 0.5)
        elif y < 46: # Gold waist ring
            return 8.0
        elif y < 58: # Grand lower swelling belly
            t = (y - 46) / 12.0
            return 8.0 + 4.5 * math.sin(t * math.pi)
        elif y < 66: # Turned foot / torus
            t = (y - 58) / 8.0
            return 8.5 + 1.5 * math.sin(t * math.pi)
        else: # Lower square plinth
            return 10.0

    pix = bal.load()
    num_balusters = 16
    spacing = 40
    for bi in range(num_balusters):
        bcx = spacing // 2 + bi * spacing # 20, 60, 100, ...
        for y in range(18, 76):
            hw = baluster_half_width(y)
            is_gold_ring = (42 <= y <= 45)
            for x in range(int(bcx - hw - 2), int(bcx + hw + 3)):
                if 0 <= x < width:
                    dx = x - bcx
                    dist = abs(dx)
                    if dist <= hw:
                        # Inside baluster: render 3D cylindrical lighting
                        nx = dx / hw # -1.0 to +1.0
                        # Light from upper-right (+0.4)
                        intensity = 0.55 + 0.45 * (0.35 + 0.65 * (-nx * 0.7 + 0.3))
                        specular = 0.0
                        if -0.4 < nx < 0.1:
                            specular = math.exp(-((nx + 0.15) ** 2) / 0.04) * 0.35

                        if is_gold_ring:
                            gr = min(255, int(palette["gold_mid"][0] * intensity + 255 * specular))
                            gg = min(255, int(palette["gold_mid"][1] * intensity + 255 * specular))
                            gb = min(255, int(palette["gold_mid"][2] * intensity + 150 * specular))
                            pix[x, y] = (gr, gg, gb, 255)
                        else:
                            mr = min(255, int(248 * intensity + 255 * specular))
                            mg = min(255, int(244 * intensity + 255 * specular))
                            mb = min(255, int(236 * intensity + 255 * specular))
                            pix[x, y] = (mr, mg, mb, 255)
                    elif dist < hw + 1.2:
                        # Antialiased silhouette boundary
                        edge_alpha = int(255.0 * (1.0 - (dist - hw) / 1.2))
                        if is_gold_ring:
                            pix[x, y] = palette["gold_mid"] + (edge_alpha,)
                        else:
                            pix[x, y] = (235, 230, 222, edge_alpha)

    bal.save(OUT_BALUSTRADE, "PNG")
    print(f"  Generated: {os.path.basename(OUT_BALUSTRADE)} ({width}x{height}, {os.path.getsize(OUT_BALUSTRADE)/1024:.1f} KB)")


def generate_palace_entablature(palette):
    """
    Asset 4: Palace Entablature / Architrave Beam (1280x80 px, RGBA)
    - Classical three-part entablature: Cornice (0..24), Frieze (24..54), Architrave (54..80).
    - Sourced from heaven_palace_ceiling.png tones and classical orders.
    - Classical dentil band with teeth every 16 px (80 teeth across 1280 px).
    - Gold-leaf frieze ornament band.
    - Molded stepped architrave fasciae.
    - Seamless horizontal tiling across 1280 px width.
    """
    print("=== [5/6] GENERATING ASSET 4: Palace Entablature Beam ===")
    width, height = 1280, 80
    ent = Image.new("RGBA", (width, height), (0, 0, 0, 0))

    # Base ivory marble texture sampled from palace ceiling
    with Image.open(SRC_CEILING) as im_ceil:
        ceil_tile = im_ceil.crop((0, 0, 1280, 38)).resize((1280, 80), Image.Resampling.LANCZOS)
        ent.paste(ceil_tile, (0, 0))

    draw = ImageDraw.Draw(ent)

    # 1. Cornice Division (y = 0..24)
    # Top gold lip
    draw.line([(0, 0), (width, 0)], fill=(255, 255, 255, 255)) # highlight
    draw.line([(0, 1), (width, 1)], fill=palette["gold_bright"] + (255,))
    draw.line([(0, 2), (width, 2)], fill=palette["gold_mid"] + (255,))
    draw.line([(0, 3), (width, 3)], fill=palette["gold_shadow"] + (255,))

    # Cyma recta molded ivory band
    for y in range(4, 11):
        t = (y - 4) / 7.0
        sh = int(248 * (1 - t) + 230 * t)
        draw.line([(0, y), (width, y)], fill=(sh, sh - 4, sh - 10, 255))

    # Dentil Band: classical rectangular teeth spaced every 16 px (1280 / 16 = 80 teeth)
    dentil_w = 10
    dentil_gap = 6
    dentil_period = dentil_w + dentil_gap # 16 px
    for dx in range(0, width, dentil_period):
        # Recessed shadow between teeth
        draw.rectangle([dx + dentil_w, 11, dx + dentil_period, 21], fill=palette["gold_deep"] + (255,))
        # Ivory dentil tooth with 3D bevel
        draw.rectangle([dx, 11, dx + dentil_w - 1, 21], fill=(250, 247, 240, 255))
        # Highlight top/left
        draw.line([(dx, 11), (dx + dentil_w - 1, 11)], fill=(255, 255, 255, 255))
        draw.line([(dx, 11), (dx, 21)], fill=(255, 255, 255, 255))
        # Shadow bottom/right
        draw.line([(dx + dentil_w - 1, 11), (dx + dentil_w - 1, 21)], fill=palette["gold_shadow"] + (255,))
        draw.line([(dx, 21), (dx + dentil_w - 1, 21)], fill=palette["gold_shadow"] + (255,))

    # Bed molding gold fillet
    draw.line([(0, 22), (width, 22)], fill=palette["gold_bright"] + (255,))
    draw.line([(0, 23), (width, 23)], fill=palette["gold_mid"] + (255,))
    draw.line([(0, 24), (width, 24)], fill=palette["gold_shadow"] + (255,))

    # 2. Frieze Division (y = 25..53)
    # Polished ivory marble field
    for y in range(25, 51):
        t = (y - 25) / 26.0
        sh = int(246 * (1 - t) + 236 * t)
        draw.line([(0, y), (width, y)], fill=(sh, sh - 4, sh - 10, 255))

    # Continuous Inlaid Imperial Gold Wave / Frieze Ribbon (repeating every 32 px)
    wave_period = 32
    for wp in range(width // wave_period):
        ox = wp * wave_period
        wave_pts = []
        for sx in range(wave_period + 1):
            wx = ox + sx
            wy = 38.0 + 5.0 * math.sin(float(sx) / float(wave_period) * math.pi * 2.0)
            wave_pts.append((wx, int(wy)))
        draw.line(wave_pts, fill=palette["gold_bright"] + (255,), width=2)
        # Gold rosette dot at wave apex
        draw.ellipse([ox + 8 - 2, 33 - 2, ox + 8 + 2, 33 + 2], fill=palette["gold_bright"] + (255,))
        draw.ellipse([ox + 24 - 2, 43 - 2, ox + 24 + 2, 43 + 2], fill=palette["gold_mid"] + (255,))

    # Gold astragal bead molding
    draw.line([(0, 51), (width, 51)], fill=palette["gold_bright"] + (255,))
    draw.line([(0, 52), (width, 52)], fill=palette["gold_mid"] + (255,))
    draw.line([(0, 53), (width, 53)], fill=palette["gold_shadow"] + (255,))

    # 3. Architrave Division (y = 54..80)
    # Upper fascia band (y = 54..66)
    for y in range(54, 66):
        t = (y - 54) / 12.0
        sh = int(242 * (1 - t) + 232 * t)
        draw.line([(0, y), (width, y)], fill=(sh, sh - 5, sh - 12, 255))

    # Gold step fillet between fasciae
    draw.line([(0, 66), (width, 66)], fill=palette["gold_mid"] + (255,))

    # Lower fascia band (y = 67..77)
    for y in range(67, 78):
        t = (y - 67) / 11.0
        sh = int(238 * (1 - t) + 224 * t)
        draw.line([(0, y), (width, y)], fill=(sh, sh - 5, sh - 12, 255))

    # Soffit underside shadow where beam rests atop columns (y = 78..79)
    draw.line([(0, 78), (width, 78)], fill=palette["stone_shadow"] + (255,))
    draw.line([(0, 79), (width, 79)], fill=(120, 105, 90, 255))

    ent.save(OUT_ENTABLATURE, "PNG")
    print(f"  Generated: {os.path.basename(OUT_ENTABLATURE)} ({width}x{height}, {os.path.getsize(OUT_ENTABLATURE)/1024:.1f} KB)")


def verify_outputs():
    """Verify all four generated outputs meet exact technical specifications."""
    print("\n=== [6/6] VERIFYING OUTPUT ASSETS ===")
    specs = [
        (OUT_DECK, 1920, 120, "Inlaid Marble Road Deck"),
        (OUT_VIADUCT, 640, 360, "Transparent Viaduct Bridge Arch"),
        (OUT_BALUSTRADE, 640, 96, "Classical Marble Balustrade"),
        (OUT_ENTABLATURE, 1280, 80, "Palace Entablature Beam")
    ]
    all_ok = True
    for path, exp_w, exp_h, name in specs:
        if not os.path.exists(path):
            print(f"FAILED: {name} was not created!")
            all_ok = False
            continue
        with Image.open(path) as im:
            w, h = im.size
            mode = im.mode
            sz_kb = os.path.getsize(path) / 1024.0
            dim_match = (w == exp_w and h == exp_h)
            mode_match = (mode == "RGBA")
            has_alpha = False
            alpha_zeros = 0
            alpha_opaque = 0
            if "A" in mode:
                alpha_data = list(im.split()[-1].getdata())
                alpha_zeros = sum(1 for a in alpha_data if a == 0)
                alpha_opaque = sum(1 for a in alpha_data if a == 255)
                has_alpha = alpha_zeros > 0

            status = "PASS" if (dim_match and mode_match) else "FAIL"
            print(f"  [{status}] {os.path.basename(path)}: {w}x{h} (expected {exp_w}x{exp_h}), Mode={mode}, Size={sz_kb:.1f} KB, ZeroAlpha={alpha_zeros} px, OpaqueAlpha={alpha_opaque} px")
            if not (dim_match and mode_match):
                all_ok = False
    if all_ok:
        print("\nAll four assets successfully generated and verified against specifications!")
    else:
        print("\nOne or more verification checks failed.")
        sys.exit(1)


def main():
    print("==================================================")
    print("ENDLESS HILL CLIMB — PHASE 2A ASSET GENERATOR")
    print("==================================================")
    check_sources()
    palette = sample_palette()
    generate_marble_deck(palette)
    generate_viaduct_arch(palette)
    generate_marble_balustrade(palette)
    generate_palace_entablature(palette)
    verify_outputs()
    print("==================================================")


if __name__ == "__main__":
    main()
