#!/usr/bin/env python3
"""
generate_heaven_rebuild_contact_sheet.py
Creates the master asset contact sheet for the Heaven Environment Rebuild.
"""

import os
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = "/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/Endless-Hillclimb-Fixed"
BRAIN_DIR = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"

assets = [
    {
        "title": "Stone Bridge Modular Arch (P0)",
        "path": "assets/environments/heaven/architecture/heaven_stone_bridge_arch.png",
        "role": "Modular bridge masonry with voussoirs & cloud openings",
        "w": 280, "h": 160
    },
    {
        "title": "Marble Roadway Paving",
        "path": "assets/environments/heaven/architecture/heaven_marble_roadway.png",
        "role": "Polished ivory marble deck with gold rosettes & specular edge",
        "w": 380, "h": 70
    },
    {
        "title": "Fluted Marble Column (Zoeluci)",
        "path": "assets/environments/heaven/architecture/heaven_palace_column.png",
        "role": "Tall fluted pillar with gold Corinthian capital & plinth",
        "w": 120, "h": 320
    },
    {
        "title": "Paired Colonnade",
        "path": "assets/environments/heaven/architecture/heaven_palace_column_paired.png",
        "role": "Twin coupled columns with connecting gold entablature",
        "w": 180, "h": 320
    },
    {
        "title": "Arched Colonnade",
        "path": "assets/environments/heaven/architecture/heaven_palace_colonnade_arch.png",
        "role": "Pillars joined by classical semicircular marble/gold arch",
        "w": 240, "h": 320
    },
    {
        "title": "Grand Double Entrance Door",
        "path": "assets/environments/heaven/architecture/heaven_palace_grand_door.png",
        "role": "Celestial double door with gold filigree & sunburst medallions",
        "w": 220, "h": 300
    },
    {
        "title": "Ceremonial Pedestal Fountain",
        "path": "assets/environments/heaven/architecture/heaven_palace_fountain.png",
        "role": "Carved ivory marble basin with gold trim & crystal water",
        "w": 200, "h": 260
    },
    {
        "title": "Vaulted Ceiling Arches",
        "path": "assets/environments/heaven/architecture/heaven_palace_vaulted_ceiling.png",
        "role": "Overhead architectural cornice with repeating vaulted arches",
        "w": 380, "h": 80
    },
    {
        "title": "Stained-Glass Rose Window",
        "path": "assets/environments/heaven/architecture/heaven_rose_window.png",
        "role": "12-petaled Gothic stained glass with turquoise/sapphire facets",
        "w": 200, "h": 200
    },
    {
        "title": "Arched Golden Window (Zoeluci)",
        "path": "assets/environments/heaven/architecture/heaven_palace_window.png",
        "role": "Arched golden window with glowing stained-glass panels",
        "w": 150, "h": 260
    },
    {
        "title": "Palace Gateway Archway",
        "path": "assets/environments/heaven/architecture/heaven_palace_arch_gateway.png",
        "role": "Triumphal palace entrance gateway with Corinthian piers",
        "w": 260, "h": 240
    },
    {
        "title": "Turquoise Celestial Sky",
        "path": "assets/environments/heaven/sky/puffy_sky_blue_01.png",
        "role": "Vibrant royal cyan to morning cyan-gold gradient",
        "w": 300, "h": 170
    },
    {
        "title": "Floating Islands & Temples",
        "path": "assets/environments/heaven/architecture/heaven_distant_palace_silhouette.png",
        "role": "Distant floating islands, temple pantheons, cascading waterfalls",
        "w": 340, "h": 120
    },
    {
        "title": "Billowing Cloud Underside",
        "path": "assets/environments/heaven/architecture/heaven_cloud_underside.png",
        "role": "Multi-scale billowing cumulus cloud masses, 0% chevrons",
        "w": 280, "h": 140
    },
    {
        "title": "Palace Garden Urns & Beds",
        "path": "assets/environments/heaven/decorations/celestial_planter_urn.png",
        "role": "Marble urn planters & white lily garden beds",
        "w": 140, "h": 180
    },
    {
        "title": "Animated White Doves",
        "path": "assets/environments/heaven/wildlife/dove_atlas.png",
        "role": "60-frame flight animation with feather shading & rim lighting",
        "w": 200, "h": 200
    }
]

# Create 1920x1080 master contact sheet
sheet = Image.new("RGBA", (1920, 1080), (22, 28, 38, 255))
draw = ImageDraw.Draw(sheet)

# Header
draw.rectangle([0, 0, 1920, 70], fill=(15, 20, 28, 255))
draw.line([(0, 69), (1920, 69)], fill=(218, 186, 96, 255), width=2)

try:
    font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 26)
    font_sub = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 14)
    font_card_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 15)
    font_card_desc = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 11)
except:
    font_title = font_sub = font_card_title = font_card_desc = None

draw.text((30, 18), "ENDLESS HILL CLIMB — HEAVEN ENVIRONMENT REBUILD ASSET AUDIT", fill=(255, 245, 210, 255), font=font_title)
draw.text((1280, 26), "Phase 2: Golden Celestial Kingdom | Zoeluci & Custom Masters", fill=(200, 215, 230, 255), font=font_sub)

# 4x4 Grid Layout
cols = 4
rows = 4
grid_x0 = 30
grid_y0 = 85
cell_w = 450
cell_h = 240

for idx, item in enumerate(assets):
    c = idx % cols
    r = idx // cols
    x = grid_x0 + c * (cell_w + 16)
    y = grid_y0 + r * (cell_h + 12)

    # Card background
    draw.rectangle([x, y, x + cell_w, y + cell_h], fill=(30, 38, 50, 255), outline=(55, 68, 88, 255), width=1)
    draw.rectangle([x, y, x + cell_w, y + 28], fill=(38, 48, 64, 255))
    draw.line([(x, y + 28), (x + cell_w, y + 28)], fill=(218, 186, 96, 200), width=1)

    # Title & Role
    draw.text((x + 10, y + 6), item["title"], fill=(255, 240, 180, 255), font=font_card_title)
    draw.text((x + 10, y + cell_h - 22), item["role"][:55], fill=(180, 195, 215, 255), font=font_card_desc)

    # Preview Image box
    box_x = x + 10
    box_y = y + 36
    box_w = cell_w - 20
    box_h = cell_h - 64

    # Checkerboard background for transparency
    draw.rectangle([box_x, box_y, box_x + box_w, box_y + box_h], fill=(42, 52, 68, 255))

    full_p = os.path.join(BASE_DIR, item["path"])
    if os.path.exists(full_p):
        src_im = Image.open(full_p).convert("RGBA")
        # Aspect fit into preview box
        aspect = src_im.width / float(src_im.height)
        box_aspect = box_w / float(box_h)
        if aspect > box_aspect:
            nw = box_w - 12
            nh = int(nw / aspect)
        else:
            nh = box_h - 12
            nw = int(nh * aspect)

        res_im = src_im.resize((nw, nh), Image.Resampling.LANCZOS)
        paste_x = box_x + (box_w - nw) // 2
        paste_y = box_y + (box_h - nh) // 2
        sheet.paste(res_im, (paste_x, paste_y), res_im)

# Save contact sheet
out_p1 = os.path.join(BASE_DIR, "docs/previews/heaven_asset_contact_sheet.png")
out_p2 = os.path.join(BRAIN_DIR, "heaven_asset_contact_sheet.png")
sheet.save(out_p1)
sheet.save(out_p2)
print("✓ Master Heaven Rebuild Contact Sheet saved to:")
print("  -", out_p1)
print("  -", out_p2)
