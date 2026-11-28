#!/usr/bin/env python3
"""
generate_all_state_monuments.py
Author: Joel
Renders authentic cultural landmarks for Kerala, Rajasthan, Gujarat, and Telangana.
Eliminates placeholder dhaba/banyan/coconut/milestone landmarks across all states.
"""

import cairo
import math
import os

for st in ["kerala", "rajasthan", "gujarat", "telangana"]:
    os.makedirs(f"assets/indian_locations/{st}", exist_ok=True)

def create_surface(w, h):
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgba(0, 0, 0, 0)
    ctx.paint()
    return surface, ctx

# 1. KERALA
def render_kerala_houseboat(path):
    surf, ctx = create_surface(520, 350)
    # Traditional Kettuvallam thatched houseboat on palm-fringed backwaters
    ctx.set_source_rgb(0.12, 0.45, 0.62) # Backwater canal
    ctx.rectangle(0, 240, 520, 110)
    ctx.fill()
    # Dark wooden hull
    ctx.set_source_rgb(0.25, 0.16, 0.10)
    ctx.move_to(80, 270)
    ctx.line_to(440, 270)
    ctx.line_to(410, 310)
    ctx.line_to(110, 310)
    ctx.close_path()
    ctx.fill()
    # Curved thatched woven bamboo roof canopy
    ctx.set_source_rgb(0.72, 0.52, 0.28) # Bamboo thatch
    ctx.arc(260, 270, 150, math.pi, 2*math.pi)
    ctx.fill()
    # Wooden ribs
    ctx.set_source_rgb(0.42, 0.28, 0.15)
    ctx.set_line_width(4)
    for rx in range(130, 400, 25):
        t = (rx - 110) / 300.0
        h = math.sin(t * math.pi) * 150
        ctx.move_to(rx, 270)
        ctx.line_to(rx, 270 - h)
        ctx.stroke()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_munnar_tea(path):
    surf, ctx = create_surface(520, 360)
    # Rolling manicured green tea hills with silver oak shade trees
    ctx.set_source_rgb(0.18, 0.62, 0.28) # Vibrant tea bushes
    ctx.arc(160, 360, 200, math.pi, 2*math.pi)
    ctx.fill()
    ctx.set_source_rgb(0.14, 0.52, 0.22)
    ctx.arc(380, 360, 220, math.pi, 2*math.pi)
    ctx.fill()
    # Tea contour planting ridges
    ctx.set_source_rgb(0.10, 0.42, 0.18)
    ctx.set_line_width(6)
    for cy in range(220, 340, 30):
        ctx.arc(160, 360, 360 - cy, math.pi * 1.1, math.pi * 1.9)
        ctx.stroke()
        ctx.arc(380, 360, 360 - cy, math.pi * 1.1, math.pi * 1.9)
        ctx.stroke()
    # Colonial Tea Factory building
    ctx.set_source_rgb(0.88, 0.85, 0.80)
    ctx.rectangle(210, 140, 100, 60)
    ctx.fill()
    # Red roof
    ctx.set_source_rgb(0.75, 0.22, 0.15)
    ctx.move_to(200, 140)
    ctx.line_to(260, 100)
    ctx.line_to(320, 140)
    ctx.close_path()
    ctx.fill()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

# 2. RAJASTHAN
def render_amber_fort(path):
    surf, ctx = create_surface(540, 420)
    # Hilltop yellow-ochre Amer Fort ramparts, jharokhas and Maota Lake reflection
    ctx.set_source_rgb(0.88, 0.68, 0.32) # Amer yellow sandstone
    # Massive bastion base
    ctx.rectangle(60, 200, 420, 180)
    ctx.fill()
    # Jharokhas (cantilevered enclosed balconies)
    ctx.set_source_rgb(0.75, 0.55, 0.25)
    for jx in [120, 220, 320]:
        ctx.rectangle(jx, 230, 60, 70)
        ctx.fill()
        ctx.arc(jx + 30, 230, 30, math.pi, 2*math.pi)
        ctx.fill()
    # Domed Chhatris on ramparts
    ctx.set_source_rgb(0.92, 0.72, 0.35)
    for cx in [90, 430]:
        ctx.rectangle(cx - 20, 160, 40, 40)
        ctx.fill()
        ctx.arc(cx, 160, 25, math.pi, 2*math.pi)
        ctx.fill()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_mehrangarh_fort(path):
    surf, ctx = create_surface(560, 440)
    # Colossal impregnable cliff fort of Jodhpur rising sheer from basalt rock
    # Basalt rock cliff
    ctx.set_source_rgb(0.32, 0.26, 0.24)
    ctx.move_to(40, 440)
    ctx.line_to(80, 240)
    ctx.line_to(480, 220)
    ctx.line_to(520, 440)
    ctx.close_path()
    ctx.fill()
    # Towering red/brown sandstone battlements (120 ft tall)
    ctx.set_source_rgb(0.65, 0.38, 0.28)
    ctx.rectangle(100, 120, 360, 120)
    ctx.fill()
    # Ornate palace facade & filigree stone screens
    ctx.set_source_rgb(0.55, 0.30, 0.22)
    for wx in range(120, 440, 35):
        ctx.rectangle(wx, 140, 18, 35)
        ctx.fill()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_jaisalmer_fort(path):
    surf, ctx = create_surface(540, 420)
    # Sonar Qila - Golden Fort rising like a mirage from Thar desert sands
    ctx.set_source_rgb(0.92, 0.75, 0.28) # Golden yellow Jurassic sandstone
    ctx.rectangle(80, 210, 380, 170)
    ctx.fill()
    # 99 bastions / circular towers
    for bx in [110, 210, 310, 410]:
        ctx.rectangle(bx - 30, 160, 60, 90)
        ctx.fill()
        ctx.arc(bx, 160, 30, math.pi, 2*math.pi)
        ctx.fill()
    # Golden desert dune base
    ctx.set_source_rgb(0.88, 0.70, 0.38)
    ctx.arc(270, 440, 280, math.pi, 2*math.pi)
    ctx.fill()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

# 3. GUJARAT
def render_rann_stepwell(path):
    surf, ctx = create_surface(520, 380)
    # Intricate multi-storey subterranean carved stepwell (Rani ki Vav / Adalaj)
    ctx.set_source_rgb(0.78, 0.68, 0.58) # Sandstone pavilions
    ctx.rectangle(60, 140, 400, 200)
    ctx.fill()
    # Multi-tiered pillared corridors descending
    ctx.set_source_rgb(0.62, 0.52, 0.44)
    for floor_y in [180, 240, 300]:
        ctx.rectangle(80, floor_y, 360, 14)
        ctx.fill()
        for px in range(100, 420, 45):
            ctx.rectangle(px, floor_y - 35, 16, 35)
            ctx.fill()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_rann_flamingos(path):
    surf, ctx = create_surface(520, 360)
    # Endless glistening white salt desert with pink flamingo flocks
    # White salt plain
    ctx.set_source_rgb(0.94, 0.95, 0.96)
    ctx.rectangle(0, 220, 520, 140)
    ctx.fill()
    # Salt crust crystals
    ctx.set_source_rgb(0.85, 0.88, 0.92)
    for sx in range(20, 500, 50):
        ctx.rectangle(sx, 260 + (sx%20), 30, 6)
        ctx.fill()
    # Elegant flamingos
    ctx.set_source_rgb(0.98, 0.45, 0.58) # Flamingo coral pink
    for fx, fy in [(140, 230), (220, 215), (320, 225), (410, 220)]:
        ctx.arc(fx, fy, 16, 0, 2*math.pi) # Body
        ctx.fill()
        ctx.set_line_width(3)
        ctx.move_to(fx - 4, fy) # Neck
        ctx.curve_to(fx - 15, fy - 25, fx - 10, fy - 45, fx - 4, fy - 50)
        ctx.stroke()
        ctx.arc(fx - 4, fy - 52, 7, 0, 2*math.pi) # Head
        ctx.fill()
        # Slender stilt legs
        ctx.move_to(fx - 4, fy + 12)
        ctx.line_to(fx - 4, fy + 55)
        ctx.move_to(fx + 4, fy + 12)
        ctx.line_to(fx + 4, fy + 55)
        ctx.stroke()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_white_desert_rann(path):
    surf, ctx = create_surface(540, 380)
    # White Rann of Kutch finish: Traditional Bhunga mud huts & glistening salt expanse
    ctx.set_source_rgb(0.95, 0.96, 0.98) # Glistening white salt desert
    ctx.rectangle(0, 220, 540, 160)
    ctx.fill()
    # Traditional circular Kutch Bhunga hut with mirror work & conical thatched roof
    ctx.set_source_rgb(0.88, 0.82, 0.74) # Mud/lipan wall
    ctx.arc(270, 280, 80, 0, math.pi)
    ctx.fill()
    ctx.rectangle(190, 230, 160, 50)
    ctx.fill()
    # Conical thatched roof
    ctx.set_source_rgb(0.68, 0.52, 0.32)
    ctx.move_to(170, 230)
    ctx.line_to(270, 110)
    ctx.line_to(370, 230)
    ctx.close_path()
    ctx.fill()
    # Colorful Lippan mirror art on walls
    ctx.set_source_rgb(0.95, 0.85, 0.25)
    for mx in range(210, 330, 24):
        ctx.arc(mx, 260, 5, 0, 2*math.pi)
        ctx.fill()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

# 4. TELANGANA
def render_golconda_fort(path):
    surf, ctx = create_surface(540, 420)
    # Golconda Fort: Diamond fort perched on 400-ft granite hill with acoustic archways
    ctx.set_source_rgb(0.35, 0.33, 0.32) # Deccan dark granite
    ctx.rectangle(70, 200, 400, 180)
    ctx.fill()
    # Balahisar Gate & arches
    ctx.set_source_rgb(0.25, 0.23, 0.22)
    ctx.rectangle(220, 260, 100, 120)
    ctx.fill()
    ctx.arc(270, 260, 50, math.pi, 2*math.pi)
    ctx.fill()
    # Crenellated battlements
    ctx.set_source_rgb(0.42, 0.40, 0.38)
    for bx in range(80, 460, 36):
        ctx.rectangle(bx, 175, 20, 25)
        ctx.fill()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_kakatiya_torana(path):
    surf, ctx = create_surface(500, 460)
    # Emblem of Telangana: The magnificent ornate 12th-century Warangal Gate (Kirti Torana)
    ctx.set_source_rgb(0.30, 0.28, 0.27) # Black basalt stone
    # Two massive carved stone monolith pillars
    ctx.rectangle(110, 140, 55, 270)
    ctx.fill()
    ctx.rectangle(335, 140, 55, 270)
    ctx.fill()
    # Ornate lintel beam with mythical Yali/Makara arch
    ctx.rectangle(70, 110, 360, 45)
    ctx.fill()
    # Arch crest
    ctx.arc(250, 110, 110, math.pi, 2*math.pi)
    ctx.fill()
    # Centre opening
    ctx.set_source_rgba(0, 0, 0, 0)
    ctx.set_operator(cairo.OPERATOR_CLEAR)
    ctx.arc(250, 130, 80, math.pi, 2*math.pi)
    ctx.fill()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_thousand_pillar_temple(path):
    surf, ctx = create_surface(540, 400)
    # Historic Kakatiya star-shaped 1000-pillar rock-cut Shiva/Vishnu temple in Hanamkonda
    ctx.set_source_rgb(0.36, 0.34, 0.32) # Granite plinth
    ctx.rectangle(60, 300, 420, 60)
    ctx.fill()
    # Intricate monolithic polished basalt pillars
    ctx.set_source_rgb(0.24, 0.22, 0.21)
    for px in range(80, 450, 35):
        ctx.rectangle(px, 170, 18, 130)
        ctx.fill()
        # Carved circular bell rings on pillars
        ctx.set_source_rgb(0.45, 0.42, 0.40)
        ctx.rectangle(px - 3, 220, 24, 8)
        ctx.fill()
        ctx.set_source_rgb(0.24, 0.22, 0.21)
    # Stepped Dravidian shikhara roof
    ctx.set_source_rgb(0.38, 0.36, 0.34)
    w = 380
    y = 170
    for level in range(4):
        w -= 50
        y -= 25
        ctx.rectangle(270 - w/2, y, w, 25)
        ctx.fill()
    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

# Execute
render_kerala_houseboat("assets/indian_locations/kerala/alleppey_houseboat_backwaters.png")
render_munnar_tea("assets/indian_locations/kerala/munnar_tea_plantations.png")
render_amber_fort("assets/indian_locations/rajasthan/amber_fort_gateway.png")
render_mehrangarh_fort("assets/indian_locations/rajasthan/mehrangarh_fort_vista.png")
render_jaisalmer_fort("assets/indian_locations/rajasthan/jaisalmer_golden_fort.png")
render_rann_stepwell("assets/indian_locations/gujarat/saurashtra_rann_oasis.png")
render_rann_flamingos("assets/indian_locations/gujarat/flamingo_sanctuary_pass.png")
render_white_desert_rann("assets/indian_locations/gujarat/white_desert_rann_kutch.png")
render_golconda_fort("assets/indian_locations/telangana/golconda_fort_bastion.png")
render_kakatiya_torana("assets/indian_locations/telangana/kakatiya_dynasty_torana.png")
render_thousand_pillar_temple("assets/indian_locations/telangana/thousand_pillar_temple.png")
print("=== ALL REMAINING STATE MONUMENTS GENERATED ===")
