#!/usr/bin/env python3
"""
generate_heaven_rebuild_comparison.py
Generates the side-by-side Before/After comparison for the Phase 2 Heaven Rebuild.
"""

import os
from PIL import Image, ImageDraw, ImageFont

BASE_DIR = "/home/danny/DUMB-SPOT/Endless-Hillclimb-Repaired/Endless-Hillclimb-Fixed"
BRAIN_DIR = "/home/danny/.gemini/antigravity-cli/brain/d9f98545-c20d-4126-ade2-ec8c8495335b/previews"

old_path = os.path.join(BASE_DIR, "docs/NO improvement/screenshot_heaven.png")
new_path = os.path.join(BASE_DIR, "docs/previews/heaven_10_vehicle_driving_inside_heaven.png")

im_old = Image.open(old_path).convert("RGB")
im_new = Image.open(new_path).convert("RGB")

w, h = 1280, 720
im_old = im_old.resize((w, h), Image.Resampling.LANCZOS)
im_new = im_new.resize((w, h), Image.Resampling.LANCZOS)

# Create 2560 x 780 side-by-side image with header
comp = Image.new("RGB", (2560, 780), (18, 22, 30))
draw = ImageDraw.Draw(comp)

# Paste old on left, new on right
comp.paste(im_old, (0, 60))
comp.paste(im_new, (1280, 60))

# Header bar
draw.rectangle([0, 0, 2560, 60], fill=(12, 16, 22))
draw.line([(0, 59), (2560, 59)], fill=(218, 186, 96), width=2)
draw.line([(1280, 0), (1280, 780)], fill=(218, 186, 96), width=2)

try:
    font_head = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 22)
    font_badge = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 18)
    font_desc = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 13)
except:
    font_head = font_badge = font_desc = None

# Left Header (Before)
draw.text((30, 16), "BEFORE: OLD HEAVEN BASELINE", fill=(240, 100, 100), font=font_head)
draw.text((450, 22), "Repetitive blue chevrons, isolated rectangular blocks, flat yellow roadway", fill=(180, 190, 205), font=font_desc)

# Right Header (After)
draw.text((1310, 16), "AFTER: THE GOLDEN CELESTIAL KINGDOM (PHASE 2 REBUILD)", fill=(255, 220, 100), font=font_head)
draw.text((2050, 22), "Modular stone bridge, ivory/gold marble, turquoise sky & 5 palace corridor sections", fill=(200, 225, 245), font=font_desc)

# Badges on images
draw.rectangle([20, 80, 180, 120], fill=(180, 40, 40, 220))
draw.text((35, 90), "BEFORE", fill=(255, 255, 255), font=font_badge)

draw.rectangle([1300, 80, 1450, 120], fill=(30, 140, 80, 220))
draw.text((1320, 90), "AFTER", fill=(255, 255, 255), font=font_badge)

out1 = os.path.join(BASE_DIR, "docs/previews/heaven_before_after_comparison.png")
out2 = os.path.join(BRAIN_DIR, "heaven_before_after_comparison.png")

comp.save(out1)
comp.save(out2)
print("✓ Saved comparison to:")
print("  -", out1)
print("  -", out2)
