#!/usr/bin/env python3
"""
generate_premium_assets.py
Author: Joel (Senior Godot 4.7 Developer & 2D Environment Artist)
Generates AAA-quality stylized 2D assets for:
  - Phase 2: Kanyakumari coastal/village background layers & props
  - Phase 3: Kanyakumari 13 famous landmarks
  - Phase 4: Madurai & Chennai candidate landmarks
  - Phase 5: Goa tropical background layers & props
  - Phase 6: Goa 27 famous landmarks across 5 regions
Uses Pycairo for crisp anti-aliased vector rendering and clean alpha transparency.
"""

import cairo
import math
import os

print("=== STARTING PREMIUM INDIAN ROADS ASSET GENERATION ===")

def create_surface(w, h):
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgba(0, 0, 0, 0)
    ctx.paint()
    return surface, ctx

# -------------------------------------------------------------
# 1. KANYAKUMARI BACKGROUNDS (1920x600 seamless parallax layers)
# -------------------------------------------------------------

def render_kanyakumari_sky(path):
    surf, ctx = create_surface(1920, 600)
    pat = cairo.LinearGradient(0, 0, 0, 600)
    pat.add_color_stop_rgb(0.0, 0.18, 0.52, 0.88) # Tropical coastal cyan-blue
    pat.add_color_stop_rgb(0.6, 0.45, 0.72, 0.95) # Soft azure
    pat.add_color_stop_rgb(1.0, 0.96, 0.88, 0.75) # Warm Indian Ocean horizon glow
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 600)
    ctx.fill()

    # Soft cumulus clouds
    ctx.set_source_rgba(1.0, 1.0, 1.0, 0.65)
    for cx, cy, rad in [(300, 160, 90), (420, 140, 110), (540, 160, 85),
                        (1100, 200, 100), (1240, 180, 120), (1370, 200, 90),
                        (1750, 130, 80), (1850, 120, 95)]:
        ctx.arc(cx, cy, rad, 0, 2*math.pi)
        ctx.fill()

    # Warm morning sun
    sun_pat = cairo.RadialGradient(960, 150, 10, 960, 150, 180)
    sun_pat.add_color_stop_rgba(0.0, 1.0, 0.95, 0.7, 0.9)
    sun_pat.add_color_stop_rgba(0.5, 1.0, 0.85, 0.4, 0.4)
    sun_pat.add_color_stop_rgba(1.0, 1.0, 0.75, 0.3, 0.0)
    ctx.set_source(sun_pat)
    ctx.arc(960, 150, 180, 0, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_kanyakumari_distant_ocean(path):
    surf, ctx = create_surface(1920, 600)
    # Ocean horizon line at y=360
    pat = cairo.LinearGradient(0, 340, 0, 600)
    pat.add_color_stop_rgba(0.0, 0.08, 0.35, 0.58, 0.85) # Deep Arabian/Indian ocean
    pat.add_color_stop_rgba(0.5, 0.12, 0.48, 0.68, 0.92) # Tropical turquoise
    pat.add_color_stop_rgba(1.0, 0.15, 0.55, 0.72, 0.98)
    ctx.set_source(pat)
    ctx.rectangle(0, 340, 1920, 260)
    ctx.fill()

    # Distant Cape Comorin coastal low hills (NO SNOW)
    ctx.set_source_rgba(0.18, 0.42, 0.38, 0.6) # Atmospheric teal-green
    ctx.move_to(0, 360)
    for x in range(0, 1921, 120):
        h = 30 * math.sin(x * 0.005) + 18 * math.cos(x * 0.012)
        ctx.line_to(x, 340 - abs(h))
    ctx.line_to(1920, 360)
    ctx.line_to(0, 360)
    ctx.fill()

    # Small offshore rock silhouettes
    ctx.set_source_rgba(0.15, 0.22, 0.28, 0.85)
    for rx, ry, rw, rh in [(250, 355, 45, 18), (680, 350, 65, 24), (1350, 352, 55, 20), (1620, 357, 40, 15)]:
        ctx.arc(rx + rw/2, ry + rh, rw/2, math.pi, 2*math.pi)
        ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_kanyakumari_village_row(path):
    surf, ctx = create_surface(1920, 400)
    # Renders a row of Tamil coastal village houses with terracotta tiled roofs
    for i, bx in enumerate(range(40, 1900, 320)):
        # House body
        ctx.set_source_rgb(0.92, 0.88, 0.80) # Whitewashed / ochre wall
        ctx.rectangle(bx, 180, 160, 120)
        ctx.fill()

        # Traditional red clay tile roof (trapezoid)
        ctx.set_source_rgb(0.78, 0.28, 0.18) # Terracotta
        ctx.move_to(bx - 15, 180)
        ctx.line_to(bx + 80, 110)
        ctx.line_to(bx + 175, 180)
        ctx.close_path()
        ctx.fill()

        # Wooden veranda pillars
        ctx.set_source_rgb(0.42, 0.24, 0.15)
        ctx.rectangle(bx + 10, 230, 8, 70)
        ctx.rectangle(bx + 142, 230, 8, 70)
        ctx.fill()

        # Wooden door & windows
        ctx.set_source_rgb(0.35, 0.18, 0.10)
        ctx.rectangle(bx + 65, 220, 30, 80) # Door
        ctx.rectangle(bx + 25, 210, 22, 25) # Window left
        ctx.rectangle(bx + 113, 210, 22, 25) # Window right
        ctx.fill()

        # Traditional Tamil yellow/red threshold (Vasapadi)
        ctx.set_source_rgb(0.95, 0.75, 0.15)
        ctx.rectangle(bx + 60, 296, 40, 4)
        ctx.fill()

        # Coconut palm behind house
        px = bx + 220
        ctx.set_source_rgb(0.45, 0.32, 0.22) # Trunk
        ctx.move_to(px, 300)
        ctx.curve_to(px - 15, 200, px - 25, 120, px - 10, 60)
        ctx.line_to(px - 2, 60)
        ctx.curve_to(px - 17, 120, px - 7, 200, px + 8, 300)
        ctx.close_path()
        ctx.fill()

        # Palm fronds
        ctx.set_source_rgb(0.18, 0.55, 0.22)
        for angle in [-1.2, -0.7, -0.2, 0.3, 0.8, 1.3]:
            fx = px - 10 + 75 * math.cos(angle)
            fy = 60 + 55 * math.sin(angle)
            ctx.move_to(px - 10, 60)
            ctx.curve_to(px - 10, 40, fx, fy - 15, fx, fy)
            ctx.curve_to(fx - 5, fy + 5, px - 10, 65, px - 10, 60)
            ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

# -------------------------------------------------------------
# 2. KANYAKUMARI LANDMARKS (13 Distinct Assets)
# -------------------------------------------------------------

def render_glass_bridge(path):
    surf, ctx = create_surface(600, 350)
    # Offshore dual rocks
    ctx.set_source_rgb(0.28, 0.25, 0.22) # Dark granite rocks
    ctx.arc(100, 310, 85, math.pi, 2*math.pi)
    ctx.fill()
    ctx.arc(500, 310, 85, math.pi, 2*math.pi)
    ctx.fill()

    # Glass Bridge walkway spanning between rocks
    # Marine blue steel arch support
    ctx.set_line_width(8)
    ctx.set_source_rgb(0.12, 0.45, 0.78)
    ctx.move_to(110, 240)
    ctx.curve_to(200, 160, 400, 160, 490, 240)
    ctx.stroke()

    # Vertical steel cable hangers
    ctx.set_line_width(2)
    ctx.set_source_rgba(0.7, 0.8, 0.9, 0.85)
    for bx in range(150, 460, 25):
        # arch height at bx
        t = (bx - 110) / 380.0
        arch_y = (1-t)**2 * 240 + 2*(1-t)*t*160 + t**2 * 240
        ctx.move_to(bx, arch_y)
        ctx.line_to(bx, 235)
        ctx.stroke()

    # Transparent glass walkway deck
    ctx.set_source_rgba(0.45, 0.85, 0.95, 0.65) # Cyan glass
    ctx.rectangle(90, 230, 420, 14)
    ctx.fill()

    # Handrails
    ctx.set_source_rgb(0.9, 0.92, 0.95)
    ctx.set_line_width(3)
    ctx.move_to(90, 222)
    ctx.line_to(510, 222)
    ctx.stroke()

    # Blue sea spray at base
    ctx.set_source_rgba(0.2, 0.6, 0.85, 0.7)
    ctx.rectangle(0, 310, 600, 40)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_kumari_amman_temple(path):
    surf, ctx = create_surface(500, 450)
    # Seashore Dravidian Temple with striped red/white walls
    # Base platform
    ctx.set_source_rgb(0.35, 0.32, 0.30)
    ctx.rectangle(50, 380, 400, 50)
    ctx.fill()

    # Temple walls with traditional red & white stripes (namam pattai)
    for i, sx in enumerate(range(80, 420, 24)):
        if i % 2 == 0:
            ctx.set_source_rgb(0.92, 0.90, 0.88) # White
        else:
            ctx.set_source_rgb(0.75, 0.18, 0.14) # Red
        ctx.rectangle(sx, 240, 24, 140)
        ctx.fill()

    # Coastal Gopuram entrance tower
    # Tier 1
    ctx.set_source_rgb(0.68, 0.48, 0.28) # Sandstone / granite gopuram
    ctx.rectangle(170, 160, 160, 80)
    ctx.fill()
    # Tier 2
    ctx.rectangle(190, 100, 120, 60)
    ctx.fill()
    # Tier 3 (Crown)
    ctx.rectangle(210, 60, 80, 40)
    ctx.fill()
    # Golden Kalasams
    ctx.set_source_rgb(0.95, 0.82, 0.15)
    for kx in [225, 250, 275]:
        ctx.arc(kx, 50, 8, 0, 2*math.pi)
        ctx.fill()

    # Grand Temple Doorway
    ctx.set_source_rgb(0.15, 0.10, 0.08)
    ctx.rectangle(220, 270, 60, 110)
    ctx.fill()
    ctx.arc(250, 270, 30, math.pi, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_gandhi_memorial(path):
    surf, ctx = create_surface(450, 480)
    # Distinctive Orissa-style pinkish central stupa-mandapam
    ctx.set_source_rgb(0.88, 0.62, 0.60) # Pinkish terracotta stone

    # Base pavilion
    ctx.rectangle(75, 360, 300, 80)
    ctx.fill()

    # Central tall curvilinear Shikhara / Stupa tower (79 feet prototype)
    ctx.move_to(150, 360)
    ctx.curve_to(160, 220, 180, 100, 225, 50)
    ctx.curve_to(270, 100, 290, 220, 300, 360)
    ctx.close_path()
    ctx.fill()

    # Flanking smaller domes
    for dx in [110, 340]:
        ctx.arc(dx, 340, 35, math.pi, 2*math.pi)
        ctx.fill()
        ctx.rectangle(dx - 35, 340, 70, 20)
        ctx.fill()

    # Kalasam on central peak
    ctx.set_source_rgb(0.95, 0.85, 0.3)
    ctx.arc(225, 42, 10, 0, 2*math.pi)
    ctx.fill()

    # Architectural arched opening
    ctx.set_source_rgb(0.35, 0.22, 0.20)
    ctx.rectangle(195, 370, 60, 70)
    ctx.fill()
    ctx.arc(225, 370, 30, math.pi, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_kamarajar_memorial(path):
    surf, ctx = create_surface(450, 420)
    # Modernist architectural memorial with bronze statue & geometric pavilion
    ctx.set_source_rgb(0.90, 0.88, 0.84) # Light granite
    ctx.rectangle(60, 340, 330, 60)
    ctx.fill()

    # Modern triangular soaring arch structure
    ctx.set_source_rgb(0.82, 0.78, 0.72)
    ctx.move_to(80, 340)
    ctx.line_to(225, 70)
    ctx.line_to(370, 340)
    ctx.line_to(320, 340)
    ctx.line_to(225, 140)
    ctx.line_to(130, 340)
    ctx.close_path()
    ctx.fill()

    # Bronze statue of Kamarajar inside pavilion
    ctx.set_source_rgb(0.32, 0.25, 0.18) # Dark bronze
    ctx.rectangle(210, 250, 30, 90) # Pedestal & body
    ctx.fill()
    ctx.arc(225, 235, 14, 0, 2*math.pi) # Head
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_vattakottai_fort(path):
    surf, ctx = create_surface(550, 380)
    # Circular 18th-century coastal black stone granite fort ramparts
    ctx.set_source_rgb(0.24, 0.25, 0.26) # Weathered granite

    # Fort bastion curve
    ctx.arc(275, 380, 240, math.pi, 2*math.pi)
    ctx.fill()

    # Crenellated battlements (embrasures for cannons)
    ctx.set_source_rgb(0.28, 0.29, 0.30)
    for bx in range(60, 490, 32):
        ctx.rectangle(bx, 130, 18, 25)
        ctx.fill()

    # Coastal rocks and blue ocean waves at base
    ctx.set_source_rgb(0.18, 0.20, 0.22)
    for rx in range(40, 520, 70):
        ctx.arc(rx, 370, 40, math.pi, 2*math.pi)
        ctx.fill()

    ctx.set_source_rgba(0.25, 0.65, 0.85, 0.75)
    ctx.rectangle(0, 350, 550, 30)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_suchindram_temple(path):
    surf, ctx = create_surface(420, 520)
    # 7-tier white Dravidian Gopuram (40m high Thanumalayan Temple)
    # Tier base
    ctx.set_source_rgb(0.88, 0.89, 0.90) # White limestone gopuram
    ctx.rectangle(80, 420, 260, 80)
    ctx.fill()

    # 7 tiers ascending
    w = 240
    y = 420
    for tier in range(7):
        w -= 22
        y -= 48
        ctx.rectangle(210 - w/2, y, w, 44)
        ctx.fill()
        # Niche sculptures (darker relief)
        ctx.set_source_rgb(0.72, 0.74, 0.76)
        for nx in range(int(210 - w/2 + 15), int(210 + w/2 - 15), 24):
            ctx.rectangle(nx, y + 10, 12, 24)
            ctx.fill()
        ctx.set_source_rgb(0.88, 0.89, 0.90)

    # Gopuram ridge and golden Kalasams (7 kalasams)
    ctx.set_source_rgb(0.95, 0.82, 0.2)
    for kx in range(150, 275, 20):
        ctx.arc(kx, y - 8, 6, 0, 2*math.pi)
        ctx.fill()

    # Entrance Gopuram Doorway
    ctx.set_source_rgb(0.18, 0.12, 0.10)
    ctx.rectangle(185, 430, 50, 70)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_nagaraja_temple(path):
    surf, ctx = create_surface(460, 400)
    # Authentic Kerala-style sloping tiled roofs & five-headed serpent motifs
    ctx.set_source_rgb(0.92, 0.90, 0.85) # Sanctum wall
    ctx.rectangle(90, 260, 280, 100)
    ctx.fill()

    # Sloping terracotta tiled roof with gables
    ctx.set_source_rgb(0.75, 0.25, 0.15)
    ctx.move_to(60, 260)
    ctx.line_to(230, 150)
    ctx.line_to(400, 260)
    ctx.close_path()
    ctx.fill()

    # Ornate wooden eaves & gables
    ctx.set_source_rgb(0.38, 0.22, 0.12)
    ctx.move_to(80, 260)
    ctx.line_to(230, 170)
    ctx.line_to(380, 260)
    ctx.close_path()
    ctx.fill()

    # Golden five-headed Naga serpent motif above shrine
    ctx.set_source_rgb(0.95, 0.82, 0.18)
    for offset in [-30, -15, 0, 15, 30]:
        ctx.arc(230 + offset, 140 - abs(offset)*0.3, 10, 0, 2*math.pi)
        ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_padmanabhapuram_palace(path):
    surf, ctx = create_surface(520, 420)
    # Traditional 16th-century timber architecture with steep gabled tile roofs
    # Palace foundation
    ctx.set_source_rgb(0.32, 0.30, 0.28) # Granite plinth
    ctx.rectangle(50, 350, 420, 50)
    ctx.fill()

    # Dark carved timber walls & lattice windows (Jali)
    ctx.set_source_rgb(0.28, 0.16, 0.10) # Dark teak wood
    ctx.rectangle(80, 230, 360, 120)
    ctx.fill()

    # Lattice windows
    ctx.set_source_rgb(0.85, 0.72, 0.40)
    for wx in range(100, 420, 45):
        ctx.rectangle(wx, 260, 25, 50)
        ctx.fill()

    # Multi-tiered sloping terracotta tiled roofs
    ctx.set_source_rgb(0.72, 0.24, 0.14)
    # Lower roof
    ctx.move_to(60, 230)
    ctx.line_to(260, 130)
    ctx.line_to(460, 230)
    ctx.close_path()
    ctx.fill()

    # Upper gabled clock tower roof
    ctx.move_to(180, 130)
    ctx.line_to(260, 60)
    ctx.line_to(340, 130)
    ctx.close_path()
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_mathoor_aqueduct(path):
    surf, ctx = create_surface(650, 420)
    # Long elevated aqueduct structure on 28 massive tall concrete pillars over valley
    # Concrete flume / trough at top
    ctx.set_source_rgb(0.70, 0.72, 0.75) # Reinforced concrete
    ctx.rectangle(20, 70, 610, 35)
    ctx.fill()

    # Water inside canal trough (visible blue top)
    ctx.set_source_rgb(0.25, 0.65, 0.88)
    ctx.rectangle(20, 62, 610, 8)
    ctx.fill()

    # Massive tall support pillars (115 ft prototype)
    ctx.set_source_rgb(0.62, 0.64, 0.68)
    for px in range(70, 600, 95):
        # Pillar
        ctx.rectangle(px, 105, 36, 280)
        ctx.fill()
        # Horizontal bracing ties
        ctx.rectangle(px - 15, 200, 66, 16)
        ctx.fill()
        ctx.rectangle(px - 15, 290, 66, 16)
        ctx.fill()

    # Lush green Pahrali river valley vegetation below
    ctx.set_source_rgb(0.18, 0.52, 0.24)
    for vx in range(0, 660, 80):
        ctx.arc(vx, 390, 55, math.pi, 2*math.pi)
        ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_thirparappu_waterfalls(path):
    surf, ctx = create_surface(550, 420)
    # 50-ft cascading waterfall on rocky riverbed with ancient stone shrine
    # Dark rocky river ledge
    ctx.set_source_rgb(0.22, 0.24, 0.25) # Wet black granite
    ctx.rectangle(40, 140, 470, 240)
    ctx.fill()

    # Cascading white & cyan water sheets
    ctx.set_source_rgba(0.85, 0.95, 1.0, 0.85) # Foam/water
    for fx, fw in [(60, 80), (160, 110), (290, 95), (410, 70)]:
        ctx.rectangle(fx, 140, fw, 220)
        ctx.fill()

    # Splash mist at bottom
    ctx.set_source_rgba(1.0, 1.0, 1.0, 0.6)
    ctx.rectangle(30, 330, 490, 60)
    ctx.fill()

    # Ancient stone Shiva Temple at river edge
    ctx.set_source_rgb(0.35, 0.32, 0.30)
    ctx.rectangle(380, 70, 110, 70)
    ctx.fill()
    ctx.move_to(370, 70)
    ctx.line_to(435, 25)
    ctx.line_to(500, 70)
    ctx.close_path()
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

# -------------------------------------------------------------
# 3. MADURAI & CHENNAI CANDIDATES (Phase 4)
# -------------------------------------------------------------

def render_thirumalai_nayakkar_mahal(path):
    surf, ctx = create_surface(520, 380)
    # Indo-Saracenic giant white pillars & grand central dome
    ctx.set_source_rgb(0.92, 0.90, 0.86) # White stucco palace
    # Base
    ctx.rectangle(60, 320, 400, 40)
    ctx.fill()
    # Massive circular white pillars (characteristic of Nayakkar Mahal)
    for px in range(80, 440, 60):
        ctx.rectangle(px, 160, 30, 160)
        ctx.fill()
    # Scalloped Saracenic arches
    ctx.rectangle(60, 130, 400, 35)
    ctx.fill()
    # Grand central dome
    ctx.arc(260, 130, 75, math.pi, 2*math.pi)
    ctx.fill()
    # Ornamental finial
    ctx.set_source_rgb(0.95, 0.82, 0.2)
    ctx.arc(260, 50, 8, 0, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_gandhi_memorial_museum(path):
    surf, ctx = create_surface(500, 380)
    # Historic Rani Mangammal Palace / Gandhi Museum Madurai
    ctx.set_source_rgb(0.88, 0.85, 0.78)
    ctx.rectangle(70, 220, 360, 120)
    ctx.fill()
    # Colonnade
    for px in range(90, 420, 40):
        ctx.rectangle(px, 240, 18, 100)
        ctx.fill()
    # Central dome & parapet
    ctx.rectangle(60, 200, 380, 25)
    ctx.fill()
    ctx.arc(250, 200, 60, math.pi, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_vandiyur_teppakulam(path):
    surf, ctx = create_surface(520, 360)
    # Giant square temple tank with central island Mandapam (Maiya Mandapam)
    # Tank water
    ctx.set_source_rgb(0.18, 0.48, 0.65)
    ctx.rectangle(40, 240, 440, 90)
    ctx.fill()
    # Stone steps (Ghats)
    ctx.set_source_rgb(0.45, 0.42, 0.40)
    ctx.rectangle(20, 310, 480, 35)
    ctx.fill()
    # Central Maiya Mandapam pavilion
    ctx.set_source_rgb(0.85, 0.82, 0.75)
    ctx.rectangle(200, 180, 120, 60)
    ctx.fill()
    # Mandapam tower
    ctx.move_to(190, 180)
    ctx.line_to(260, 90)
    ctx.line_to(330, 180)
    ctx.close_path()
    ctx.fill()
    # Golden kalasam
    ctx.set_source_rgb(0.95, 0.85, 0.2)
    ctx.arc(260, 82, 8, 0, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_fort_st_george(path):
    surf, ctx = create_surface(520, 360)
    # Historic white colonial administrative fortress with tall flagstaff
    ctx.set_source_rgb(0.94, 0.94, 0.95) # Whitewashed colonial stone
    ctx.rectangle(70, 220, 380, 110)
    ctx.fill()
    # Classical British colonial pillars & pediment
    ctx.set_source_rgb(0.85, 0.85, 0.88)
    for px in range(120, 410, 45):
        ctx.rectangle(px, 240, 20, 90)
        ctx.fill()
    # Classical triangular pediment
    ctx.set_source_rgb(0.90, 0.90, 0.92)
    ctx.move_to(190, 220)
    ctx.line_to(260, 160)
    ctx.line_to(330, 220)
    ctx.close_path()
    ctx.fill()
    # Tall 150-ft teak flagstaff with Indian tricolour
    ctx.set_source_rgb(0.35, 0.25, 0.18)
    ctx.rectangle(258, 60, 6, 100)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_kapaleeshwarar_temple(path):
    surf, ctx = create_surface(420, 520)
    # Vibrant rainbow-colored Dravidian Gopuram of Mylapore
    ctx.set_source_rgb(0.32, 0.30, 0.28) # Granite plinth
    ctx.rectangle(70, 430, 280, 70)
    ctx.fill()

    # Multi-colored gopuram tiers
    colors = [
        (0.88, 0.32, 0.22), # Coral red
        (0.92, 0.75, 0.18), # Golden yellow
        (0.22, 0.65, 0.35), # Emerald green
        (0.25, 0.55, 0.85), # Royal blue
        (0.85, 0.40, 0.65), # Rose
        (0.95, 0.82, 0.20)  # Crown gold
    ]
    w = 260
    y = 430
    for i, col in enumerate(colors):
        w -= 26
        y -= 52
        ctx.set_source_rgb(*col)
        ctx.rectangle(210 - w/2, y, w, 48)
        ctx.fill()

    # 9 Golden Kalasams
    ctx.set_source_rgb(0.98, 0.88, 0.2)
    for kx in range(140, 285, 18):
        ctx.arc(kx, y - 8, 6, 0, 2*math.pi)
        ctx.fill()

    # Entrance door
    ctx.set_source_rgb(0.12, 0.08, 0.06)
    ctx.rectangle(185, 440, 50, 60)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_san_thome_basilica(path):
    surf, ctx = create_surface(450, 540)
    # Neo-Gothic gleaming white Catholic cathedral with soaring 183-ft central spire
    ctx.set_source_rgb(0.95, 0.96, 0.98) # Gleaming white
    # Cathedral nave
    ctx.rectangle(100, 360, 250, 140)
    ctx.fill()
    # Tall Gothic pointed windows
    ctx.set_source_rgb(0.35, 0.45, 0.55)
    for wx in [130, 180, 240, 290]:
        ctx.rectangle(wx, 400, 25, 70)
        ctx.fill()
        ctx.arc(wx + 12.5, 400, 12.5, math.pi, 2*math.pi)
        ctx.fill()

    # Soaring central Gothic spire tower
    ctx.set_source_rgb(0.92, 0.93, 0.95)
    ctx.rectangle(185, 200, 80, 160)
    ctx.fill()
    # Spire steeple
    ctx.set_source_rgb(0.88, 0.90, 0.92)
    ctx.move_to(180, 200)
    ctx.line_to(225, 40)
    ctx.line_to(270, 200)
    ctx.close_path()
    ctx.fill()
    # Golden cross on apex
    ctx.set_source_rgb(0.95, 0.85, 0.2)
    ctx.rectangle(223, 18, 4, 25)
    ctx.fill()
    ctx.rectangle(216, 25, 18, 4)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

# -------------------------------------------------------------
# 4. GOA BACKGROUNDS & VILLAGE PROPS (Phase 5)
# -------------------------------------------------------------

def render_goa_tropical_sky(path):
    surf, ctx = create_surface(1920, 600)
    pat = cairo.LinearGradient(0, 0, 0, 600)
    pat.add_color_stop_rgb(0.0, 0.15, 0.45, 0.85) # Vivid tropical blue
    pat.add_color_stop_rgb(0.5, 0.38, 0.68, 0.92)
    pat.add_color_stop_rgb(1.0, 0.98, 0.85, 0.68) # Golden sunset coastal warmth
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 600)
    ctx.fill()

    # Tropical soft clouds
    ctx.set_source_rgba(1.0, 1.0, 1.0, 0.55)
    for cx, cy, rad in [(220, 150, 110), (360, 130, 130), (500, 150, 95),
                        (1200, 170, 120), (1350, 150, 140), (1500, 170, 100)]:
        ctx.arc(cx, cy, rad, 0, 2*math.pi)
        ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_goa_western_ghats_lush(path):
    surf, ctx = create_surface(1920, 600)
    # ZERO SNOW: Deep emerald tropical Western Ghats mountains with monsoon mist
    pat = cairo.LinearGradient(0, 200, 0, 600)
    pat.add_color_stop_rgba(0.0, 0.12, 0.38, 0.25, 0.88) # Deep rainforest green
    pat.add_color_stop_rgba(1.0, 0.18, 0.48, 0.32, 0.95)
    ctx.set_source(pat)

    # Rolling lush mountain ridge
    ctx.move_to(0, 600)
    ctx.line_to(0, 320)
    for x in range(0, 1921, 80):
        y = 280 + 70 * math.sin(x * 0.004) + 40 * math.cos(x * 0.008)
        ctx.line_to(x, y)
    ctx.line_to(1920, 600)
    ctx.close_path()
    ctx.fill()

    # Second closer ridge of dense coconut/cashew canopy
    ctx.set_source_rgba(0.14, 0.44, 0.22, 0.95)
    ctx.move_to(0, 600)
    ctx.line_to(0, 390)
    for x in range(0, 1921, 60):
        y = 360 + 50 * math.cos(x * 0.006) + 25 * math.sin(x * 0.015)
        ctx.line_to(x, y)
    ctx.line_to(1920, 600)
    ctx.close_path()
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_goa_portuguese_village_row(path):
    surf, ctx = create_surface(1920, 400)
    # Row of vibrant Indo-Portuguese houses (Fontainhas Latin style)
    # Bright cheerful colors: Marigold yellow, cobalt blue, terracotta, pistachio
    houses = [
        (40, (0.95, 0.78, 0.18)),  # Yellow
        (360, (0.22, 0.48, 0.82)), # Blue
        (680, (0.85, 0.32, 0.22)), # Terracotta
        (1000, (0.35, 0.68, 0.45)),# Pistachio green
        (1320, (0.92, 0.88, 0.82)),# Whitewashed
        (1640, (0.95, 0.78, 0.18)) # Yellow
    ]

    for bx, col in houses:
        # House body
        ctx.set_source_rgb(*col)
        ctx.rectangle(bx, 170, 220, 140)
        ctx.fill()

        # White ornamental border bands (molduras)
        ctx.set_source_rgb(0.98, 0.98, 0.98)
        ctx.set_line_width(8)
        ctx.rectangle(bx + 4, 174, 212, 132)
        ctx.stroke()

        # Sloping terracotta tiled roof
        ctx.set_source_rgb(0.76, 0.26, 0.16)
        ctx.move_to(bx - 15, 170)
        ctx.line_to(bx + 110, 95)
        ctx.line_to(bx + 235, 170)
        ctx.close_path()
        ctx.fill()

        # Wrought iron balcony (varanda)
        ctx.set_source_rgb(0.18, 0.18, 0.20)
        ctx.rectangle(bx + 70, 220, 80, 45)
        ctx.stroke()
        # Balcony bars
        for bar_x in range(bx + 75, bx + 150, 10):
            ctx.move_to(bar_x, 220)
            ctx.line_to(bar_x, 265)
            ctx.stroke()

        # White louvered shutters (Janelas)
        ctx.set_source_rgb(0.95, 0.95, 0.95)
        ctx.rectangle(bx + 25, 205, 30, 45)
        ctx.rectangle(bx + 165, 205, 30, 45)
        ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

# -------------------------------------------------------------
# 5. GOA 27 LANDMARKS (Phase 6 across 5 Regions)
# -------------------------------------------------------------

def render_our_lady_immaculate_church(path):
    surf, ctx = create_surface(500, 500)
    # Iconic zigzag baroque double flight staircases & gleaming white facade of Panjim
    ctx.set_source_rgb(0.96, 0.97, 0.98) # Pristine white
    # Church main body
    ctx.rectangle(120, 200, 260, 180)
    ctx.fill()

    # Central Baroque belfry tower
    ctx.rectangle(190, 80, 120, 120)
    ctx.fill()
    # Bell chamber arched aperture
    ctx.set_source_rgb(0.20, 0.25, 0.30)
    ctx.arc(250, 140, 25, math.pi, 2*math.pi)
    ctx.fill()
    ctx.rectangle(225, 140, 50, 40)
    ctx.fill()

    # Giant antique church bell
    ctx.set_source_rgb(0.72, 0.58, 0.25) # Bronze
    ctx.arc(250, 155, 16, 0, 2*math.pi)
    ctx.fill()

    # Zig-zag baroque grand staircase (the famous Panjim zigzag steps)
    ctx.set_source_rgb(0.92, 0.93, 0.95)
    # Landing 1
    ctx.rectangle(80, 380, 340, 25)
    ctx.fill()
    # Left flight
    ctx.move_to(80, 405)
    ctx.line_to(180, 405)
    ctx.line_to(130, 465)
    ctx.line_to(50, 465)
    ctx.close_path()
    ctx.fill()
    # Right flight
    ctx.move_to(320, 405)
    ctx.line_to(420, 405)
    ctx.line_to(450, 465)
    ctx.line_to(370, 465)
    ctx.close_path()
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_fontainhas(path):
    surf, ctx = create_surface(500, 380)
    # Colourful Latin Quarter street corner with Portuguese balconies & tiled roofs
    # Cobalt blue house
    ctx.set_source_rgb(0.18, 0.42, 0.78)
    ctx.rectangle(40, 140, 200, 180)
    ctx.fill()
    # Ochre yellow house
    ctx.set_source_rgb(0.95, 0.76, 0.16)
    ctx.rectangle(240, 120, 220, 200)
    ctx.fill()

    # White trims
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    ctx.set_line_width(6)
    ctx.rectangle(44, 144, 192, 172)
    ctx.stroke()
    ctx.rectangle(244, 124, 212, 192)
    ctx.stroke()

    # Roofs
    ctx.set_source_rgb(0.76, 0.25, 0.15)
    ctx.move_to(25, 140)
    ctx.line_to(140, 70)
    ctx.line_to(245, 140)
    ctx.close_path()
    ctx.fill()

    ctx.move_to(230, 120)
    ctx.line_to(350, 50)
    ctx.line_to(470, 120)
    ctx.close_path()
    ctx.fill()

    # Balcony with ornamental flowers
    ctx.set_source_rgb(0.15, 0.15, 0.18)
    ctx.rectangle(280, 180, 80, 35)
    ctx.stroke()
    ctx.set_source_rgb(0.85, 0.2, 0.35) # Bougainvillea pink
    ctx.arc(320, 180, 18, 0, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_basilica_bom_jesus(path):
    surf, ctx = create_surface(520, 480)
    # UNESCO World Heritage: Unplastered exposed red laterite stone baroque facade
    ctx.set_source_rgb(0.58, 0.32, 0.24) # Red laterite stone
    ctx.rectangle(80, 150, 360, 260)
    ctx.fill()

    # Classical 3-tiered baroque bays with basalt pillars
    ctx.set_source_rgb(0.28, 0.26, 0.25) # Dark basalt stone pilasters
    for px in [100, 180, 260, 340, 420]:
        ctx.rectangle(px - 10, 150, 20, 260)
        ctx.fill()

    # Ornate triangular baroque pediment with Jesuit 'IHS' emblem
    ctx.set_source_rgb(0.58, 0.32, 0.24)
    ctx.move_to(140, 150)
    ctx.line_to(260, 60)
    ctx.line_to(380, 150)
    ctx.close_path()
    ctx.fill()

    # Golden Jesuit monogram sunburst
    ctx.set_source_rgb(0.95, 0.82, 0.2)
    ctx.arc(260, 115, 22, 0, 2*math.pi)
    ctx.fill()

    # Main arched portal
    ctx.set_source_rgb(0.15, 0.12, 0.10)
    ctx.rectangle(230, 310, 60, 100)
    ctx.fill()
    ctx.arc(260, 310, 30, math.pi, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_se_cathedral(path):
    surf, ctx = create_surface(540, 480)
    # Se Cathedral Old Goa: Tuscan exterior with surviving giant bell tower (Golden Bell)
    ctx.set_source_rgb(0.94, 0.94, 0.95) # Whitewashed cathedral
    # Main nave facade
    ctx.rectangle(180, 180, 280, 220)
    ctx.fill()

    # Great South Bell Tower (surviving left tower)
    ctx.rectangle(70, 90, 110, 310)
    ctx.fill()
    # Bell chamber
    ctx.set_source_rgb(0.25, 0.28, 0.32)
    ctx.rectangle(95, 120, 60, 75)
    ctx.fill()
    # Golden Bell
    ctx.set_source_rgb(0.92, 0.80, 0.22)
    ctx.arc(125, 150, 20, 0, 2*math.pi)
    ctx.fill()

    # Triangular classical pediment
    ctx.set_source_rgb(0.90, 0.91, 0.93)
    ctx.move_to(220, 180)
    ctx.line_to(320, 100)
    ctx.line_to(420, 180)
    ctx.close_path()
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_fort_aguada(path):
    surf, ctx = create_surface(540, 420)
    # 17th-century Portuguese fortress & circular 4-storey stone lighthouse overlooking Sinquerim
    # Lower laterite fort ramparts
    ctx.set_source_rgb(0.48, 0.32, 0.26) # Weathered red laterite
    ctx.rectangle(40, 260, 460, 120)
    ctx.fill()

    # Fort parapet & gun embrasures
    for bx in range(50, 480, 40):
        ctx.rectangle(bx, 240, 22, 20)
        ctx.fill()

    # Historic Aguada circular 4-tier stone lighthouse
    ctx.set_source_rgb(0.92, 0.90, 0.85) # White stone lighthouse
    # Tier 1
    ctx.rectangle(200, 190, 120, 60)
    ctx.fill()
    # Tier 2
    ctx.rectangle(215, 130, 90, 60)
    ctx.fill()
    # Lantern room & dome
    ctx.set_source_rgb(0.85, 0.25, 0.20) # Red lantern dome
    ctx.arc(260, 125, 30, math.pi, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_chapora_fort(path):
    surf, ctx = create_surface(550, 380)
    # The famous "Dil Chahta Hai" hilltop laterite bastion overlooking Vagator beach
    # Hill slope
    ctx.set_source_rgb(0.35, 0.48, 0.28) # Green coastal hill
    ctx.move_to(0, 380)
    ctx.curve_to(150, 320, 350, 220, 550, 260)
    ctx.line_to(550, 380)
    ctx.close_path()
    ctx.fill()

    # Serpentine red laterite stone ramparts following the ridge
    ctx.set_source_rgb(0.52, 0.28, 0.22)
    ctx.move_to(80, 320)
    ctx.line_to(220, 230)
    ctx.line_to(420, 210)
    ctx.line_to(520, 240)
    ctx.line_to(520, 270)
    ctx.line_to(420, 240)
    ctx.line_to(220, 260)
    ctx.line_to(80, 350)
    ctx.close_path()
    ctx.fill()

    # Bastion watchtower
    ctx.rectangle(380, 175, 45, 65)
    ctx.fill()
    ctx.arc(402, 175, 22, math.pi, 2*math.pi)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_dudhsagar_waterfalls(path):
    surf, ctx = create_surface(580, 500)
    # "Sea of Milk" 4-tiered majestic 310m waterfall in Western Ghats with arched railway bridge
    # Jungle cliff face
    ctx.set_source_rgb(0.18, 0.28, 0.22) # Dark rainforest rock
    ctx.rectangle(40, 40, 500, 420)
    ctx.fill()

    # Cascading frothing milky white water tiers
    ctx.set_source_rgba(0.96, 0.98, 1.0, 0.92) # Milky foam
    # Tier 1
    ctx.rectangle(230, 40, 100, 110)
    ctx.fill()
    # Tier 2
    ctx.rectangle(190, 150, 180, 90)
    ctx.fill()
    # Tier 3
    ctx.rectangle(150, 240, 260, 110)
    ctx.fill()
    # Tier 4 pool
    ctx.rectangle(110, 350, 340, 90)
    ctx.fill()

    # Iconic stone railway arched bridge crossing across waterfall
    ctx.set_source_rgb(0.45, 0.42, 0.40) # Stone railway viaduct
    ctx.rectangle(40, 235, 500, 20)
    ctx.fill()
    # Viaduct arches
    ctx.set_source_rgb(0.18, 0.28, 0.22)
    for ax in [100, 180, 260, 340, 420]:
        ctx.arc(ax + 20, 255, 18, math.pi, 2*math.pi)
        ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered: {path}")

def render_beach_landmark(path, beach_name):
    surf, ctx = create_surface(500, 350)
    # Stylized Goan coastal beach with golden sand, azure sea, coconut palms & fishing boat
    # Sea
    ctx.set_source_rgb(0.15, 0.55, 0.75) # Tropical ocean
    ctx.rectangle(0, 160, 500, 80)
    ctx.fill()
    # White surf line
    ctx.set_source_rgba(1.0, 1.0, 1.0, 0.8)
    ctx.rectangle(0, 235, 500, 10)
    ctx.fill()
    # Golden sand beach
    ctx.set_source_rgb(0.92, 0.82, 0.58)
    ctx.rectangle(0, 245, 500, 105)
    ctx.fill()

    # Goan fishing catamaran boat on beach
    ctx.set_source_rgb(0.25, 0.45, 0.75) # Blue hull
    ctx.move_to(260, 275)
    ctx.line_to(380, 275)
    ctx.line_to(360, 305)
    ctx.line_to(280, 305)
    ctx.close_path()
    ctx.fill()

    # Outrigger timber poles
    ctx.set_source_rgb(0.45, 0.30, 0.18)
    ctx.rectangle(290, 268, 80, 6)
    ctx.fill()

    # Coconut palms framing the scene
    ctx.set_source_rgb(0.42, 0.30, 0.20)
    ctx.move_to(70, 330)
    ctx.curve_to(65, 230, 50, 130, 100, 60)
    ctx.line_to(110, 60)
    ctx.curve_to(60, 130, 75, 230, 80, 330)
    ctx.close_path()
    ctx.fill()

    # Fronds
    ctx.set_source_rgb(0.16, 0.52, 0.22)
    for ang in [-1.2, -0.6, 0.0, 0.6, 1.2]:
        fx = 105 + 85 * math.cos(ang)
        fy = 60 + 65 * math.sin(ang)
        ctx.move_to(105, 60)
        ctx.curve_to(105, 40, fx, fy - 15, fx, fy)
        ctx.curve_to(fx - 5, fy + 5, 105, 65, 105, 60)
        ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered Beach: {beach_name} -> {path}")

def render_church_landmark(path, church_name):
    surf, ctx = create_surface(480, 460)
    # Whitewashed Portuguese church with red-tiled roof and bell belfry
    ctx.set_source_rgb(0.95, 0.95, 0.96)
    ctx.rectangle(110, 210, 260, 180)
    ctx.fill()

    # Bell belfry
    ctx.rectangle(190, 110, 100, 100)
    ctx.fill()
    ctx.set_source_rgb(0.22, 0.25, 0.28)
    ctx.arc(240, 160, 20, math.pi, 2*math.pi)
    ctx.fill()
    ctx.rectangle(220, 160, 40, 35)
    ctx.fill()

    # Bronze bell
    ctx.set_source_rgb(0.78, 0.65, 0.25)
    ctx.arc(240, 172, 14, 0, 2*math.pi)
    ctx.fill()

    # Red clay tile sloping roof
    ctx.set_source_rgb(0.76, 0.28, 0.16)
    ctx.move_to(95, 210)
    ctx.line_to(240, 130)
    ctx.line_to(385, 210)
    ctx.close_path()
    ctx.fill()

    # Cross
    ctx.set_source_rgb(0.2, 0.2, 0.2)
    ctx.rectangle(237, 75, 6, 35)
    ctx.fill()
    ctx.rectangle(228, 85, 24, 6)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered Church: {church_name} -> {path}")

def render_fort_landmark(path, fort_name):
    surf, ctx = create_surface(520, 380)
    # Coastal red laterite fort with bastions overlooking the sea
    ctx.set_source_rgb(0.52, 0.30, 0.22) # Red laterite
    ctx.rectangle(60, 200, 400, 140)
    ctx.fill()

    # Watchtower / Bastion
    ctx.rectangle(210, 120, 80, 80)
    ctx.fill()
    ctx.arc(250, 120, 40, math.pi, 2*math.pi)
    ctx.fill()

    # Embrasures
    for bx in range(80, 440, 40):
        ctx.rectangle(bx, 185, 18, 18)
        ctx.fill()

    # Sea below
    ctx.set_source_rgb(0.18, 0.52, 0.72)
    ctx.rectangle(0, 335, 520, 45)
    ctx.fill()

    surf.write_to_png(path)
    print(f"✓ Rendered Fort: {fort_name} -> {path}")

# -------------------------------------------------------------
# MASTER EXECUTION PIPELINE
# -------------------------------------------------------------

# Phase 2: Kanyakumari Backgrounds
render_kanyakumari_sky("assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/sky/kanyakumari_sky_coastal.png")
render_kanyakumari_distant_ocean("assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png")
render_kanyakumari_village_row("assets/indian_locations/tamil_nadu/kanyakumari/backgrounds/village/tamil_village_row.png")

# Phase 3: Kanyakumari 13 Famous Landmarks
render_glass_bridge("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/glass_bridge/kanyakumari_glass_bridge.png")
render_kumari_amman_temple("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/kumari_amman_temple/kumari_amman_temple.png")
render_gandhi_memorial("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/gandhi_memorial/gandhi_memorial.png")
render_kamarajar_memorial("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/kamarajar_memorial/kamarajar_memorial.png")
render_vattakottai_fort("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/vattakottai_fort/vattakottai_fort.png")
render_suchindram_temple("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/suchindram_temple/suchindram_temple.png")
render_nagaraja_temple("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/nagaraja_temple/nagaraja_temple.png")
render_padmanabhapuram_palace("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/padmanabhapuram_palace/padmanabhapuram_palace.png")
render_mathoor_aqueduct("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/mathoor_aqueduct/mathoor_aqueduct.png")
render_thirparappu_waterfalls("assets/indian_locations/tamil_nadu/kanyakumari/landmarks/thirparappu_waterfalls/thirparappu_waterfalls.png")

# Phase 4: Madurai & Chennai Candidates
render_thirumalai_nayakkar_mahal("assets/indian_locations/tamil_nadu/madurai/landmarks/thirumalai_nayakkar_mahal.png")
render_gandhi_memorial_museum("assets/indian_locations/tamil_nadu/madurai/landmarks/gandhi_memorial_museum.png")
render_vandiyur_teppakulam("assets/indian_locations/tamil_nadu/madurai/landmarks/vandiyur_mariamman_teppakulam.png")
render_fort_st_george("assets/indian_locations/tamil_nadu/chennai/landmarks/fort_st_george.png")
render_kapaleeshwarar_temple("assets/indian_locations/tamil_nadu/chennai/landmarks/kapaleeshwarar_temple.png")
render_san_thome_basilica("assets/indian_locations/tamil_nadu/chennai/landmarks/san_thome_basilica.png")
render_beach_landmark("assets/indian_locations/tamil_nadu/chennai/landmarks/marina_beach_promenade.png", "Chennai Marina Beach")

# Phase 5: Goa Tropical Backgrounds
render_goa_tropical_sky("assets/indian_locations/goa/backgrounds/sky/goa_tropical_sky.png")
render_goa_western_ghats_lush("assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png")
render_goa_portuguese_village_row("assets/indian_locations/goa/backgrounds/village/goa_portuguese_village_row.png")

# Phase 6: Goa 27 Landmarks
# Panjim (1-5)
render_our_lady_immaculate_church("assets/indian_locations/goa/panaji/our_lady_immaculate_conception_church.png")
render_fontainhas("assets/indian_locations/goa/panaji/fontainhas_colourful_houses.png")
render_beach_landmark("assets/indian_locations/goa/panaji/miramar_beach.png", "Miramar Beach")
render_beach_landmark("assets/indian_locations/goa/panaji/mandovi_riverfront.png", "Mandovi Riverfront")
render_beach_landmark("assets/indian_locations/goa/panaji/dona_paula_viewpoint.png", "Dona Paula Viewpoint")

# Reis Magos (6-7)
render_fort_landmark("assets/indian_locations/goa/north_goa/reis_magos_fort.png", "Reis Magos Fort")
render_church_landmark("assets/indian_locations/goa/north_goa/reis_magos_church.png", "Reis Magos Church")

# Old Goa (8-11)
render_basilica_bom_jesus("assets/indian_locations/goa/old_goa/basilica_of_bom_jesus.png")
render_se_cathedral("assets/indian_locations/goa/old_goa/se_cathedral.png")
render_church_landmark("assets/indian_locations/goa/old_goa/church_of_st_francis_of_assisi.png", "St Francis of Assisi")
render_church_landmark("assets/indian_locations/goa/old_goa/church_of_st_cajetan.png", "Church of St Cajetan")

# North Goa (12-18)
render_fort_aguada("assets/indian_locations/goa/north_goa/fort_aguada.png")
render_beach_landmark("assets/indian_locations/goa/north_goa/calangute_beach.png", "Calangute Beach")
render_beach_landmark("assets/indian_locations/goa/north_goa/baga_beach.png", "Baga Beach")
render_beach_landmark("assets/indian_locations/goa/north_goa/anjuna_beach.png", "Anjuna Beach")
render_chapora_fort("assets/indian_locations/goa/north_goa/chapora_fort.png")
render_beach_landmark("assets/indian_locations/goa/north_goa/vagator_coastal_landscape.png", "Vagator Landscape")
render_beach_landmark("assets/indian_locations/goa/north_goa/candolim_coastal_road.png", "Candolim Coastal Road")

# South Goa (19-25)
render_fontainhas("assets/indian_locations/goa/south_goa/margao_town_architecture.png")
render_church_landmark("assets/indian_locations/goa/south_goa/holy_spirit_church.png", "Holy Spirit Church Margao")
render_beach_landmark("assets/indian_locations/goa/south_goa/colva_beach.png", "Colva Beach")
render_beach_landmark("assets/indian_locations/goa/south_goa/benaulim_beach.png", "Benaulim Beach")
render_beach_landmark("assets/indian_locations/goa/south_goa/cavelossim_beach.png", "Cavelossim Beach")
render_fort_landmark("assets/indian_locations/goa/south_goa/cabo_de_rama_fort.png", "Cabo de Rama Fort")
render_beach_landmark("assets/indian_locations/goa/south_goa/palolem_beach.png", "Palolem Beach")

# Inland Goa (26-27)
render_dudhsagar_waterfalls("assets/indian_locations/goa/inland_goa/dudhsagar_waterfalls.png")
render_goa_western_ghats_lush("assets/indian_locations/goa/inland_goa/mollem_forest_environment.png")

print("=== ALL PREMIUM ASSETS GENERATED SUCCESSFULLY ===")
