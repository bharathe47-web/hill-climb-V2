#!/usr/bin/env python3
"""
Art Asset Generation Pipeline for KANYAKUMARI HILL CLIMB.
Generates all high-quality 2D transparent PNGs and seamless textures
matching the painted, saturated visual style of the reference image.
"""
import os
import math
import random
import cairo

ART_DIR = "art"
os.makedirs(f"{ART_DIR}/parallax", exist_ok=True)
os.makedirs(f"{ART_DIR}/terrain", exist_ok=True)
os.makedirs(f"{ART_DIR}/props", exist_ok=True)
os.makedirs(f"{ART_DIR}/vehicles", exist_ok=True)
os.makedirs(f"{ART_DIR}/pickups", exist_ok=True)
os.makedirs(f"{ART_DIR}/ui", exist_ok=True)
os.makedirs(f"{ART_DIR}/fx", exist_ok=True)

# -------------------------------------------------------------
# 1. PARALLAX ASSETS
# -------------------------------------------------------------

def generate_sky_seamless():
    w, h = 2048, 1080
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Painted bright cyan-to-azure sky gradient
    pat = cairo.LinearGradient(0, 0, 0, h)
    pat.add_color_stop_rgb(0.0, 0.22, 0.55, 0.88)   # Rich deep cyan-blue
    pat.add_color_stop_rgb(0.45, 0.38, 0.72, 0.94)  # Vibrant cerulean
    pat.add_color_stop_rgb(0.85, 0.65, 0.85, 0.98)  # Soft horizon haze
    pat.add_color_stop_rgb(1.0, 0.80, 0.90, 0.99)   # Warm near-horizon glow
    ctx.set_source(pat)
    ctx.rectangle(0, 0, w, h)
    ctx.fill()
    
    surface.write_to_png(f"{ART_DIR}/parallax/sky_seamless.png")
    print("Generated sky_seamless.png")

def generate_clouds_seamless():
    w, h = 2048, 1080
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Draw soft cumulus clouds that wrap seamlessly around x=0 and x=w
    random.seed(42)
    cloud_clusters = [
        (150, 220, 180), (550, 160, 240), (950, 250, 190),
        (1400, 180, 260), (1800, 230, 210)
    ]
    
    for cx, cy, r in cloud_clusters:
        for offset_x in [0, w, -w]:
            actual_x = cx + offset_x
            if -300 <= actual_x <= w + 300:
                # Cloud puff cluster
                puffs = [
                    (0, 0, r * 0.65),
                    (-r * 0.45, r * 0.1, r * 0.5),
                    (r * 0.45, r * 0.1, r * 0.5),
                    (-r * 0.25, -r * 0.25, r * 0.45),
                    (r * 0.25, -r * 0.25, r * 0.45),
                    (0, -r * 0.35, r * 0.5)
                ]
                
                # Soft base shadow
                for px, py, pr in puffs:
                    pat = cairo.RadialGradient(actual_x + px, cy + py + pr * 0.2, pr * 0.1,
                                               actual_x + px, cy + py + pr * 0.2, pr)
                    pat.add_color_stop_rgba(0.0, 0.82, 0.88, 0.94, 0.75)
                    pat.add_color_stop_rgba(1.0, 0.82, 0.88, 0.94, 0.0)
                    ctx.set_source(pat)
                    ctx.arc(actual_x + px, cy + py + pr * 0.2, pr, 0, math.tau)
                    ctx.fill()
                    
                # White fluffy highlights
                for px, py, pr in puffs:
                    pat = cairo.RadialGradient(actual_x + px - pr * 0.2, cy + py - pr * 0.2, pr * 0.05,
                                               actual_x + px, cy + py, pr)
                    pat.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.95)
                    pat.add_color_stop_rgba(0.8, 0.96, 0.98, 1.0, 0.85)
                    pat.add_color_stop_rgba(1.0, 0.90, 0.94, 0.98, 0.0)
                    ctx.set_source(pat)
                    ctx.arc(actual_x + px, cy + py, pr, 0, math.tau)
                    ctx.fill()
                    
    surface.write_to_png(f"{ART_DIR}/parallax/clouds_seamless.png")
    print("Generated clouds_seamless.png")

def generate_sea_seamless():
    w, h = 2048, 1080
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Sea horizon begins at y=480, extends to y=1080
    horizon_y = 480
    pat = cairo.LinearGradient(0, horizon_y, 0, h)
    pat.add_color_stop_rgb(0.0, 0.08, 0.28, 0.58)   # Deep distant blue
    pat.add_color_stop_rgb(0.3, 0.10, 0.38, 0.70)   # Rich royal blue
    pat.add_color_stop_rgb(0.7, 0.12, 0.50, 0.78)   # Turquoise coast
    pat.add_color_stop_rgb(1.0, 0.14, 0.58, 0.82)
    ctx.set_source(pat)
    ctx.rectangle(0, horizon_y, w, h - horizon_y)
    ctx.fill()
    
    # Sparkling water ripples across the sea
    random.seed(99)
    ctx.set_line_width(2.0)
    for row in range(horizon_y + 10, h, 18):
        progress = (row - horizon_y) / (h - horizon_y)
        alpha = 0.25 + 0.35 * progress
        streak_len = 30 + 70 * progress
        ctx.set_source_rgba(0.9, 0.98, 1.0, alpha)
        
        # Ensure ripples wrap horizontally
        num_streaks = int(w / (streak_len * 2.2))
        for s in range(num_streaks):
            sx = (s * (w / num_streaks) + random.uniform(-10, 10)) % w
            ctx.move_to(sx, row)
            ctx.curve_to(sx + streak_len * 0.3, row - 2,
                         sx + streak_len * 0.7, row + 2,
                         sx + streak_len, row)
            ctx.stroke()
            
    surface.write_to_png(f"{ART_DIR}/parallax/sea_seamless.png")
    print("Generated sea_seamless.png")

def generate_islands_seamless():
    w, h = 2048, 1080
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Distant sea islands with Vivekananda Rock Memorial & Thiruvalluvar Statue
    # Vivekananda Rock: located at x=520, horizon_y=480
    # Thiruvalluvar Statue: located at x=1480, horizon_y=480
    
    def draw_vivekananda_rock(cx, cy):
        # Rocky island base
        ctx.set_source_rgb(0.42, 0.38, 0.35)
        ctx.move_to(cx - 160, cy + 20)
        ctx.curve_to(cx - 120, cy - 25, cx - 40, cy - 35, cx, cy - 30)
        ctx.curve_to(cx + 60, cy - 38, cx + 130, cy - 20, cx + 170, cy + 20)
        ctx.line_to(cx - 160, cy + 20)
        ctx.fill()
        
        # Temple Mandapam walls & base
        ctx.set_source_rgb(0.78, 0.62, 0.52)
        ctx.rectangle(cx - 70, cy - 75, 140, 45)
        ctx.fill()
        
        # Dravidian / Memorial Dome
        ctx.set_source_rgb(0.85, 0.68, 0.55)
        ctx.arc(cx, cy - 75, 45, math.pi, 0)
        ctx.fill()
        
        # Kalasam / Pinnacle
        ctx.set_source_rgb(0.95, 0.80, 0.30)
        ctx.move_to(cx - 4, cy - 120)
        ctx.line_to(cx + 4, cy - 120)
        ctx.line_to(cx, cy - 145)
        ctx.close_path()
        ctx.fill()
        
        # Temple columns
        ctx.set_source_rgb(0.55, 0.42, 0.35)
        for col_x in range(int(cx - 60), int(cx + 60), 20):
            ctx.rectangle(col_x, cy - 72, 6, 40)
            ctx.fill()

    def draw_thiruvalluvar_monument(cx, cy):
        # Massive rock pedestal
        ctx.set_source_rgb(0.38, 0.36, 0.34)
        ctx.rectangle(cx - 70, cy - 45, 140, 65)
        ctx.fill()
        
        # Pedestal architectural details
        ctx.set_source_rgb(0.50, 0.48, 0.45)
        ctx.rectangle(cx - 80, cy - 50, 160, 10)
        ctx.fill()
        
        # Statue body (flowing robes, noble standing posture)
        ctx.set_source_rgb(0.44, 0.42, 0.40)
        # Robe lower
        ctx.move_to(cx - 32, cy - 50)
        ctx.line_to(cx + 32, cy - 50)
        ctx.line_to(cx + 26, cy - 170)
        ctx.line_to(cx - 26, cy - 170)
        ctx.close_path()
        ctx.fill()
        
        # Torso & right hand gesture
        ctx.rectangle(cx - 24, cy - 225, 48, 60)
        ctx.fill()
        # Raised right blessing hand
        ctx.move_to(cx + 20, cy - 195)
        ctx.line_to(cx + 38, cy - 235)
        ctx.line_to(cx + 46, cy - 230)
        ctx.line_to(cx + 26, cy - 190)
        ctx.fill()
        # Head with topknot / bun
        ctx.arc(cx, cy - 245, 20, 0, math.tau)
        ctx.fill()
        ctx.arc(cx, cy - 270, 12, 0, math.tau)
        ctx.fill()
        
        # Highlights
        ctx.set_source_rgba(0.70, 0.68, 0.65, 0.6)
        ctx.move_to(cx - 20, cy - 50)
        ctx.line_to(cx - 15, cy - 220)
        ctx.stroke()
        
    draw_vivekananda_rock(520, 480)
    draw_thiruvalluvar_monument(1480, 480)
    
    # Also draw small distant fishing boats on the sea
    ctx.set_source_rgb(0.85, 0.25, 0.20)
    for bx, by in [(220, 500), (980, 515), (1850, 495)]:
        ctx.move_to(bx - 18, by)
        ctx.line_to(bx + 18, by)
        ctx.line_to(bx + 12, by + 8)
        ctx.line_to(bx - 12, by + 8)
        ctx.close_path()
        ctx.fill()
        # White sail
        ctx.set_source_rgb(0.95, 0.95, 0.95)
        ctx.move_to(bx - 2, by)
        ctx.line_to(bx - 2, by - 24)
        ctx.line_to(bx + 14, by - 4)
        ctx.close_path()
        ctx.fill()
        
    surface.write_to_png(f"{ART_DIR}/parallax/islands_vivekananda.png")
    print("Generated islands_vivekananda.png")

def generate_town_coastal_seamless():
    w, h = 2048, 512
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Colourful coastal houses with palm trees along the coastline
    random.seed(77)
    base_y = 380
    
    colors = [
        (0.92, 0.35, 0.28), # Terracotta Red
        (0.95, 0.80, 0.25), # Bright Sunshine Yellow
        (0.28, 0.72, 0.85), # Sky Blue
        (0.88, 0.92, 0.94), # White Lime
        (0.40, 0.80, 0.45)  # Pastel Mint Green
    ]
    
    # Draw buildings in repeating sequence
    house_w = 90
    num_houses = int(w / house_w) + 1
    for i in range(num_houses):
        hx = i * house_w
        hh = random.randint(70, 130)
        c = colors[i % len(colors)]
        
        # House body
        ctx.set_source_rgb(c[0], c[1], c[2])
        ctx.rectangle(hx + 10, base_y - hh, house_w - 20, hh)
        ctx.fill()
        
        # Roof (pitched or flat parapet)
        ctx.set_source_rgb(0.75, 0.22, 0.18)
        if i % 2 == 0:
            ctx.move_to(hx + 5, base_y - hh)
            ctx.line_to(hx + house_w * 0.5, base_y - hh - 28)
            ctx.line_to(hx + house_w - 5, base_y - hh)
            ctx.close_path()
            ctx.fill()
        else:
            ctx.rectangle(hx + 8, base_y - hh - 8, house_w - 16, 8)
            ctx.fill()
            
        # Windows
        ctx.set_source_rgb(0.20, 0.30, 0.45)
        for wx in [hx + 24, hx + house_w - 36]:
            ctx.rectangle(wx, base_y - hh + 20, 16, 20)
            ctx.fill()
            
    # Add lush coconut palms interspersed along the town
    for px in range(40, w, 160):
        # Slanted trunk
        ctx.set_source_rgb(0.48, 0.34, 0.22)
        ctx.set_line_width(8.0)
        ctx.move_to(px, base_y)
        ctx.curve_to(px + 15, base_y - 70, px - 10, base_y - 140, px + 10, base_y - 200)
        ctx.stroke()
        
        # Green palm fronds
        top_x, top_y = px + 10, base_y - 200
        ctx.set_source_rgb(0.18, 0.65, 0.25)
        for angle in [-120, -80, -40, 0, 40, 80, 120]:
            rad = math.radians(angle - 90)
            fx = top_x + math.cos(rad) * 65
            fy = top_y + math.sin(rad) * 45
            ctx.set_line_width(4.0)
            ctx.move_to(top_x, top_y)
            ctx.curve_to(top_x + math.cos(rad) * 35, top_y + math.sin(rad) * 20 - 15,
                         fx, fy - 10, fx, fy)
            ctx.stroke()
            
    surface.write_to_png(f"{ART_DIR}/parallax/town_coastal.png")
    print("Generated town_coastal.png")

def generate_lighthouse():
    w, h = 512, 512
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Red-and-white banded lighthouse
    cx, base_y = 256, 460
    
    # Rocky base mound
    ctx.set_source_rgb(0.40, 0.38, 0.36)
    ctx.arc(cx, base_y + 40, 140, math.pi, 0)
    ctx.fill()
    
    # Tapered tower bands: 5 alternating red and white bands
    tower_h = 320
    band_h = tower_h / 5
    bottom_w = 110
    top_w = 60
    
    for i in range(5):
        y_bot = base_y - i * band_h
        y_top = y_bot - band_h
        w_bot = bottom_w - (bottom_w - top_w) * (i / 5.0)
        w_top = bottom_w - (bottom_w - top_w) * ((i + 1) / 5.0)
        
        # Red or White band
        if i % 2 == 0:
            ctx.set_source_rgb(0.88, 0.20, 0.18) # Bright Red
        else:
            ctx.set_source_rgb(0.96, 0.96, 0.96) # Clean White
            
        ctx.move_to(cx - w_bot / 2, y_bot)
        ctx.line_to(cx - w_top / 2, y_top)
        ctx.line_to(cx + w_top / 2, y_top)
        ctx.line_to(cx + w_bot / 2, y_bot)
        ctx.close_path()
        ctx.fill()
        
    # Lantern gallery / balcony
    ctx.set_source_rgb(0.20, 0.20, 0.22)
    ctx.rectangle(cx - top_w / 2 - 12, base_y - tower_h - 10, top_w + 24, 10)
    ctx.fill()
    
    # Glass lantern room with golden light
    ctx.set_source_rgb(0.98, 0.88, 0.35)
    ctx.rectangle(cx - top_w / 2 + 5, base_y - tower_h - 45, top_w - 10, 35)
    ctx.fill()
    
    # Domed red roof with spire
    ctx.set_source_rgb(0.88, 0.20, 0.18)
    ctx.arc(cx, base_y - tower_h - 45, (top_w - 6) / 2, math.pi, 0)
    ctx.fill()
    ctx.set_line_width(4.0)
    ctx.move_to(cx, base_y - tower_h - 45 - (top_w - 6) / 2)
    ctx.line_to(cx, base_y - tower_h - 80)
    ctx.stroke()
    
    surface.write_to_png(f"{ART_DIR}/parallax/lighthouse.png")
    print("Generated lighthouse.png")


# -------------------------------------------------------------
# 2. TERRAIN & CLIFF ASSETS
# -------------------------------------------------------------

def generate_cliff_rock_tile():
    w, h = 512, 512
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Layered brown, ochre, slate-grey sedimentary rock cross-section
    # Gradient darker toward bottom
    pat = cairo.LinearGradient(0, 0, 0, h)
    pat.add_color_stop_rgb(0.0, 0.62, 0.48, 0.36)  # Warm sandy ochre top
    pat.add_color_stop_rgb(0.4, 0.48, 0.38, 0.30)  # Earth brown
    pat.add_color_stop_rgb(0.75, 0.36, 0.28, 0.24) # Dark stone
    pat.add_color_stop_rgb(1.0, 0.22, 0.18, 0.16)  # Deep shadowy base
    ctx.set_source(pat)
    ctx.rectangle(0, 0, w, h)
    ctx.fill()
    
    # Horizontal rock strata strata lines (seamless wrap across x)
    random.seed(1234)
    for stratum in range(15, h, 32):
        ctx.set_line_width(random.uniform(3, 7))
        # Dark crevice
        ctx.set_source_rgba(0.18, 0.14, 0.12, 0.7)
        ctx.move_to(0, stratum)
        ctx.curve_to(128, stratum + random.uniform(-6, 6),
                     384, stratum + random.uniform(-6, 6),
                     512, stratum)
        ctx.stroke()
        # Light highlight ridge
        ctx.set_line_width(2.0)
        ctx.set_source_rgba(0.75, 0.65, 0.52, 0.5)
        ctx.move_to(0, stratum - 4)
        ctx.curve_to(128, stratum - 4 + random.uniform(-5, 5),
                     384, stratum - 4 + random.uniform(-5, 5),
                     512, stratum - 4)
        ctx.stroke()
        
    # Small embedded rocks and pebbles
    for _ in range(80):
        rx = random.uniform(20, w - 20)
        ry = random.uniform(20, h - 20)
        rw = random.uniform(6, 18)
        rh = random.uniform(4, 12)
        ctx.set_source_rgba(0.28, 0.24, 0.22, 0.8)
        ctx.save()
        ctx.translate(rx, ry)
        ctx.rotate(random.uniform(0, math.pi))
        ctx.scale(rw / 2, rh / 2)
        ctx.arc(0, 0, 1, 0, math.tau)
        ctx.fill()
        ctx.restore()
        
    surface.write_to_png(f"{ART_DIR}/terrain/cliff_rock_tile.png")
    print("Generated cliff_rock_tile.png")

def generate_road_asphalt_pattern():
    w, h = 256, 64
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Dark asphalt roadway
    ctx.set_source_rgb(0.18, 0.19, 0.21)
    ctx.rectangle(0, 0, w, h)
    ctx.fill()
    
    # Asphalt fine texture speckles
    random.seed(555)
    for _ in range(300):
        bx = random.uniform(0, w)
        by = random.uniform(0, h)
        c = random.uniform(0.12, 0.26)
        ctx.set_source_rgb(c, c, c)
        ctx.rectangle(bx, by, 2, 2)
        ctx.fill()
        
    # Crisp white top edge line (guard boundary)
    ctx.set_source_rgb(0.96, 0.96, 0.96)
    ctx.rectangle(0, 3, w, 5)
    ctx.fill()
    
    # Yellow dashed center stripe
    ctx.set_source_rgb(0.98, 0.78, 0.12) # Golden amber road paint
    dash_len = 50
    gap_len = 35
    total_cycle = dash_len + gap_len
    num_dashes = int(w / total_cycle) + 1
    for d in range(num_dashes):
        dx = d * total_cycle + 10
        ctx.rectangle(dx, 28, dash_len, 7)
        ctx.fill()
        
    # White lower road edge
    ctx.set_source_rgb(0.85, 0.85, 0.85)
    ctx.rectangle(0, h - 6, w, 4)
    ctx.fill()
    
    surface.write_to_png(f"{ART_DIR}/terrain/road_asphalt_pattern.png")
    print("Generated road_asphalt_pattern.png")

def generate_grass_tuft():
    w, h = 128, 64
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Vibrant coastal grass tuft with blades
    blades = [
        (64, 55, -25, 45), (60, 56, -15, 52), (68, 56, 12, 50),
        (52, 58, -35, 38), (76, 58, 30, 40), (45, 60, -45, 28),
        (83, 60, 42, 30), (64, 54, 0, 55)
    ]
    
    for bx, by, angle, length in blades:
        rad = math.radians(angle - 90)
        ex = bx + math.cos(rad) * length
        ey = by + math.sin(rad) * length
        
        # Blade gradient: dark forest green base to sunny yellow-green tip
        pat = cairo.LinearGradient(bx, by, ex, ey)
        pat.add_color_stop_rgb(0.0, 0.15, 0.45, 0.18)
        pat.add_color_stop_rgb(0.7, 0.35, 0.75, 0.22)
        pat.add_color_stop_rgb(1.0, 0.65, 0.88, 0.25)
        
        ctx.set_source(pat)
        ctx.set_line_width(4.5)
        ctx.move_to(bx, by)
        ctx.curve_to(bx + math.cos(rad) * length * 0.4, by + math.sin(rad) * length * 0.4,
                     ex - 3, ey + 4, ex, ey)
        ctx.stroke()
        
    surface.write_to_png(f"{ART_DIR}/terrain/grass_tuft.png")
    print("Generated grass_tuft.png")


# -------------------------------------------------------------
# 3. ROADSIDE PROPS
# -------------------------------------------------------------

def generate_tea_shop():
    w, h = 320, 240
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Authentic South Indian "Chai Stall" / Kada
    base_y = 220
    
    # Wooden counter & stall structure
    ctx.set_source_rgb(0.48, 0.32, 0.18) # Dark wood
    ctx.rectangle(60, base_y - 90, 200, 90)
    ctx.fill()
    
    # Stall wooden panels
    ctx.set_source_rgb(0.62, 0.44, 0.26)
    for px in range(70, 250, 22):
        ctx.rectangle(px, base_y - 85, 18, 80)
        ctx.fill()
        
    # Blue corrugated sheet roof
    ctx.set_source_rgb(0.18, 0.45, 0.82) # Vibrant cobalt blue roof
    ctx.move_to(40, base_y - 145)
    ctx.line_to(280, base_y - 145)
    ctx.line_to(295, base_y - 110)
    ctx.line_to(25, base_y - 110)
    ctx.close_path()
    ctx.fill()
    
    # Corrugation ridges
    ctx.set_source_rgb(0.10, 0.30, 0.62)
    ctx.set_line_width(2.5)
    for rx in range(35, 290, 14):
        ctx.move_to(rx + 10, base_y - 145)
        ctx.line_to(rx, base_y - 110)
        ctx.stroke()
        
    # Roof support poles
    ctx.set_source_rgb(0.35, 0.22, 0.12)
    ctx.rectangle(55, base_y - 110, 8, 110)
    ctx.rectangle(255, base_y - 110, 8, 110)
    ctx.fill()
    
    # Indian tricolor flag fluttering on pole above roof
    ctx.set_source_rgb(0.70, 0.70, 0.70)
    ctx.rectangle(158, base_y - 210, 4, 65)
    ctx.fill()
    
    # Saffron, White, Green flag bands
    ctx.set_source_rgb(1.0, 0.45, 0.10) # Saffron
    ctx.rectangle(162, base_y - 210, 40, 10)
    ctx.fill()
    ctx.set_source_rgb(0.98, 0.98, 0.98) # White
    ctx.rectangle(162, base_y - 200, 40, 10)
    ctx.fill()
    # Ashoka chakra dot
    ctx.set_source_rgb(0.05, 0.10, 0.50)
    ctx.arc(182, base_y - 195, 3.5, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(0.10, 0.55, 0.20) # Green
    ctx.rectangle(162, base_y - 190, 40, 10)
    ctx.fill()
    
    # Shiny brass tea kettle (Samovar) on counter
    ctx.set_source_rgb(0.92, 0.76, 0.22)
    ctx.arc(110, base_y - 105, 14, 0, math.tau)
    ctx.fill()
    ctx.rectangle(102, base_y - 124, 16, 8)
    ctx.fill()
    
    # Signboard "TEA / காபி"
    ctx.set_source_rgb(0.95, 0.92, 0.85)
    ctx.rectangle(135, base_y - 138, 90, 22)
    ctx.fill()
    ctx.set_source_rgb(0.80, 0.15, 0.15)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(13)
    ctx.move_to(145, base_y - 122)
    ctx.show_text("CHAI / TEA")
    
    surface.write_to_png(f"{ART_DIR}/props/tea_shop.png")
    print("Generated tea_shop.png")

def generate_bollard():
    w, h = 60, 140
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Concrete roadside milestone/bollard with yellow and black stripes
    cx, base_y = 30, 130
    bw, bh = 34, 105
    
    # Rounded top milestone
    ctx.save()
    ctx.move_to(cx - bw / 2, base_y)
    ctx.line_to(cx - bw / 2, base_y - bh + 16)
    ctx.arc(cx, base_y - bh + 16, bw / 2, math.pi, 0)
    ctx.line_to(cx + bw / 2, base_y)
    ctx.close_path()
    ctx.clip()
    
    # Alternating yellow and black stripes
    stripe_h = 20
    for i in range(7):
        sy = base_y - i * stripe_h
        if i % 2 == 0:
            ctx.set_source_rgb(0.98, 0.82, 0.12) # Warning Yellow
        else:
            ctx.set_source_rgb(0.18, 0.18, 0.18) # Jet Black
        ctx.rectangle(cx - bw / 2, sy - stripe_h, bw, stripe_h)
        ctx.fill()
    ctx.restore()
    
    # Outline & 3D bevel
    ctx.set_line_width(2.0)
    ctx.set_source_rgb(0.12, 0.12, 0.12)
    ctx.move_to(cx - bw / 2, base_y)
    ctx.line_to(cx - bw / 2, base_y - bh + 16)
    ctx.arc(cx, base_y - bh + 16, bw / 2, math.pi, 0)
    ctx.line_to(cx + bw / 2, base_y)
    ctx.stroke()
    
    surface.write_to_png(f"{ART_DIR}/props/bollard.png")
    print("Generated bollard.png")

def generate_lamp_post():
    w, h = 120, 360
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Curved metal highway street lamp post
    pole_x = 40
    base_y = 350
    
    # Concrete base
    ctx.set_source_rgb(0.55, 0.55, 0.58)
    ctx.rectangle(pole_x - 14, base_y - 25, 28, 25)
    ctx.fill()
    
    # Metal pole
    ctx.set_source_rgb(0.35, 0.38, 0.42)
    ctx.rectangle(pole_x - 4, 80, 8, base_y - 105)
    ctx.fill()
    
    # Curved neck
    ctx.set_line_width(7.0)
    ctx.move_to(pole_x, 80)
    ctx.curve_to(pole_x, 30, pole_x + 50, 20, pole_x + 65, 38)
    ctx.stroke()
    
    # Lamp head luminaire
    ctx.set_source_rgb(0.28, 0.30, 0.34)
    ctx.rectangle(pole_x + 50, 38, 30, 12)
    ctx.fill()
    
    # Glowing lens
    ctx.set_source_rgb(1.0, 0.95, 0.70)
    ctx.rectangle(pole_x + 52, 50, 26, 4)
    ctx.fill()
    
    surface.write_to_png(f"{ART_DIR}/props/lamp_post.png")
    print("Generated lamp_post.png")

def generate_coconut_palm():
    w, h = 260, 420
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Natural curving South Indian coconut palm tree
    base_x, base_y = 70, 410
    top_x, top_y = 150, 110
    
    # Trunk with textured ring segments
    ctx.set_line_width(18.0)
    ctx.set_source_rgb(0.48, 0.36, 0.24)
    ctx.move_to(base_x, base_y)
    ctx.curve_to(base_x + 60, base_y - 120, base_x + 10, base_y - 240, top_x, top_y)
    ctx.stroke()
    
    # Trunk horizontal ridges
    ctx.set_line_width(2.5)
    ctx.set_source_rgb(0.32, 0.24, 0.16)
    for t in [0.15, 0.3, 0.45, 0.6, 0.75, 0.9]:
        tx = (1 - t)**2 * base_x + 2 * (1 - t) * t * (base_x + 40) + t**2 * top_x
        ty = (1 - t)**2 * base_y + 2 * (1 - t) * t * (base_y - 180) + t**2 * top_y
        ctx.arc(tx, ty, 10, 0, math.tau)
        ctx.stroke()
        
    # Coconuts bunch
    ctx.set_source_rgb(0.40, 0.52, 0.20)
    for c_off_x, c_off_y in [(-6, 8), (8, 6), (2, 14)]:
        ctx.arc(top_x + c_off_x, top_y + c_off_y, 8, 0, math.tau)
        ctx.fill()
        
    # Palm fronds spreading outward
    fronds = [
        (-140, 95), (-110, 115), (-75, 125), (-35, 120),
        (10, 125), (45, 115), (80, 95), (115, 80)
    ]
    
    for angle, length in fronds:
        rad = math.radians(angle)
        fx = top_x + math.cos(rad) * length
        fy = top_y + math.sin(rad) * (length * 0.7)
        
        # Arching frond stalk
        ctx.set_source_rgb(0.20, 0.58, 0.22)
        ctx.set_line_width(5.0)
        ctx.move_to(top_x, top_y)
        mid_x = (top_x + fx) / 2 + math.cos(rad) * 15
        mid_y = (top_y + fy) / 2 - 25
        ctx.curve_to(mid_x, mid_y, fx, fy - 10, fx, fy)
        ctx.stroke()
        
        # Leaflets
        ctx.set_source_rgb(0.28, 0.68, 0.25)
        ctx.set_line_width(2.0)
        for step in range(5, 10):
            frac = step / 10.0
            lx = (1 - frac) * top_x + frac * fx
            ly = (1 - frac) * top_y + frac * fy - 10 * math.sin(frac * math.pi)
            ctx.move_to(lx, ly)
            ctx.line_to(lx + math.cos(rad + 1.2) * 20, ly + math.sin(rad + 1.2) * 20 + 8)
            ctx.stroke()
            
    surface.write_to_png(f"{ART_DIR}/props/coconut_palm.png")
    print("Generated coconut_palm.png")

def generate_stone_wall():
    w, h = 320, 120
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Heavy rustic stone barrier wall
    ctx.set_source_rgb(0.38, 0.38, 0.40)
    ctx.rectangle(0, 20, w, 95)
    ctx.fill()
    
    # Stone cap coping
    ctx.set_source_rgb(0.55, 0.55, 0.58)
    ctx.rectangle(0, 10, w, 15)
    ctx.fill()
    
    # Individual masonry stones and mortar joints
    random.seed(888)
    ctx.set_line_width(2.5)
    ctx.set_source_rgb(0.22, 0.22, 0.24)
    for row in range(25, 110, 28):
        ctx.move_to(0, row)
        ctx.line_to(w, row)
        ctx.stroke()
        
        # Vertical joints
        offset = 25 if (row // 28) % 2 == 1 else 0
        for col in range(offset, w, 55):
            ctx.move_to(col, row)
            ctx.line_to(col, row + 28)
            ctx.stroke()
            
    surface.write_to_png(f"{ART_DIR}/props/stone_wall.png")
    print("Generated stone_wall.png")

def generate_sign_kanyakumari():
    w, h = 360, 220
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Steel mounting poles
    ctx.set_source_rgb(0.55, 0.58, 0.62)
    ctx.rectangle(60, 110, 10, 105)
    ctx.rectangle(290, 110, 10, 105)
    ctx.fill()
    
    # Green highway signboard
    ctx.set_source_rgb(0.08, 0.52, 0.24) # Indian National Highway Green
    ctx.rectangle(20, 20, 320, 115)
    ctx.fill()
    
    # White border
    ctx.set_source_rgb(0.96, 0.96, 0.96)
    ctx.set_line_width(4.0)
    ctx.rectangle(26, 26, 308, 103)
    ctx.stroke()
    
    # Text: "KANYAKUMARI / கன்னியாகுமரி"
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(24)
    ctx.move_to(65, 62)
    ctx.show_text("KANYAKUMARI")
    
    # Tamil script rendered via Noto Sans Tamil or system fallback
    # In cairo we can select font family
    ctx.select_font_face("Noto Sans Tamil", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(20)
    ctx.move_to(95, 96)
    ctx.show_text("கன்னியாகுமரி")
    
    # NH 44 emblem badge
    ctx.set_source_rgb(0.95, 0.85, 0.15)
    ctx.arc(285, 60, 16, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(0.1, 0.1, 0.1)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(11)
    ctx.move_to(272, 64)
    ctx.show_text("NH44")
    
    surface.write_to_png(f"{ART_DIR}/props/sign_kanyakumari.png")
    print("Generated sign_kanyakumari.png")


# -------------------------------------------------------------
# 4. VEHICLES (Red Jeep, Rickshaw, Tractor, Mini Truck, Rally)
# -------------------------------------------------------------

def generate_jeep_assets():
    # 1. Red Jeep Body
    w, h = 320, 160
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Open-top red 4x4 Jeep chassis
    # Hood & front grille
    ctx.set_source_rgb(0.88, 0.14, 0.14) # Saturated scarlet red
    
    # Hood
    ctx.move_to(190, 75)
    ctx.line_to(295, 85)
    ctx.line_to(305, 125)
    ctx.line_to(180, 125)
    ctx.close_path()
    ctx.fill()
    
    # Main passenger tub
    ctx.rectangle(40, 85, 160, 42)
    ctx.fill()
    
    # Wheel wells (wheel arches)
    ctx.set_source_rgba(0.12, 0.12, 0.14, 1.0)
    # Rear arch
    ctx.arc(85, 125, 42, math.pi, 0)
    ctx.fill()
    # Front arch
    ctx.arc(245, 125, 42, math.pi, 0)
    ctx.fill()
    
    # Black tubular roll cage / roll bar
    ctx.set_source_rgb(0.18, 0.18, 0.20)
    ctx.set_line_width(8.0)
    ctx.move_to(65, 85)
    ctx.line_to(75, 25)
    ctx.line_to(155, 25)
    ctx.line_to(165, 85)
    ctx.stroke()
    # Diagonal brace
    ctx.move_to(155, 25)
    ctx.line_to(65, 85)
    ctx.stroke()
    
    # Windshield frame & glass
    ctx.set_source_rgb(0.18, 0.18, 0.20)
    ctx.set_line_width(6.0)
    ctx.move_to(188, 85)
    ctx.line_to(165, 30)
    ctx.stroke()
    
    # Tinted glass
    ctx.set_source_rgba(0.65, 0.88, 0.98, 0.6)
    ctx.move_to(185, 82)
    ctx.line_to(166, 34)
    ctx.line_to(160, 34)
    ctx.line_to(160, 82)
    ctx.close_path()
    ctx.fill()
    
    # Headlight & amber turn signal
    ctx.set_source_rgb(0.98, 0.98, 0.90) # Glowing round headlight
    ctx.arc(302, 98, 11, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(1.0, 0.65, 0.10) # Amber signal
    ctx.arc(302, 115, 6, 0, math.tau)
    ctx.fill()
    
    # Front bumper with tow hooks
    ctx.set_source_rgb(0.22, 0.22, 0.25)
    ctx.rectangle(295, 120, 22, 14)
    ctx.fill()
    
    # Rear mounted spare tire
    ctx.set_source_rgb(0.15, 0.15, 0.16)
    ctx.arc(32, 95, 28, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(0.70, 0.70, 0.72) # Rim
    ctx.arc(32, 95, 14, 0, math.tau)
    ctx.fill()
    
    # Steering wheel
    ctx.set_source_rgb(0.15, 0.15, 0.15)
    ctx.set_line_width(5.0)
    ctx.move_to(165, 68)
    ctx.line_to(148, 52)
    ctx.stroke()
    
    surface.write_to_png(f"{ART_DIR}/vehicles/jeep_body.png")
    print("Generated jeep_body.png")
    
    # 2. Jeep Wheel (Spoked alloy + rugged off-road tire)
    w, h = 96, 96
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    cx, cy = 48, 48
    
    # Outer rubber tire
    ctx.set_source_rgb(0.18, 0.18, 0.20)
    ctx.arc(cx, cy, 45, 0, math.tau)
    ctx.fill()
    
    # Deep tread notches around perimeter
    ctx.set_source_rgb(0.10, 0.10, 0.12)
    for a in range(0, 360, 20):
        rad = math.radians(a)
        tx = cx + math.cos(rad) * 44
        ty = cy + math.sin(rad) * 44
        ctx.arc(tx, ty, 5, 0, math.tau)
        ctx.fill()
        
    # Inner rim bead
    ctx.set_source_rgb(0.12, 0.12, 0.14)
    ctx.arc(cx, cy, 32, 0, math.tau)
    ctx.fill()
    
    # Silver alloy wheel rim
    ctx.set_source_rgb(0.82, 0.84, 0.88)
    ctx.arc(cx, cy, 26, 0, math.tau)
    ctx.fill()
    
    # 5-Spoke star pattern
    ctx.set_source_rgb(0.35, 0.38, 0.42)
    for a in range(0, 360, 72):
        rad = math.radians(a)
        sx = cx + math.cos(rad) * 16
        sy = cy + math.sin(rad) * 16
        ctx.arc(sx, sy, 7, 0, math.tau)
        ctx.fill()
        
    # Center hub nut
    ctx.set_source_rgb(0.95, 0.30, 0.25)
    ctx.arc(cx, cy, 6, 0, math.tau)
    ctx.fill()
    
    surface.write_to_png(f"{ART_DIR}/vehicles/jeep_wheel.png")
    print("Generated jeep_wheel.png")
    
    # 3. Driver Sprite
    w, h = 90, 110
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Driver torso in blue shirt
    ctx.set_source_rgb(0.20, 0.50, 0.85)
    ctx.rectangle(20, 50, 48, 55)
    ctx.fill()
    
    # Driver arms extending to steer
    ctx.set_source_rgb(0.20, 0.50, 0.85)
    ctx.set_line_width(12.0)
    ctx.move_to(35, 62)
    ctx.line_to(68, 75)
    ctx.stroke()
    # Hands
    ctx.set_source_rgb(0.82, 0.60, 0.45)
    ctx.arc(68, 75, 7, 0, math.tau)
    ctx.fill()
    
    # Head & face
    ctx.set_source_rgb(0.82, 0.60, 0.45)
    ctx.arc(44, 34, 18, 0, math.tau)
    ctx.fill()
    
    # Red driving cap / helmet
    ctx.set_source_rgb(0.88, 0.18, 0.18)
    ctx.arc(44, 28, 19, math.pi, 0)
    ctx.fill()
    # Cap visor / peak
    ctx.rectangle(44, 26, 22, 6)
    ctx.fill()
    
    # Sunglasses
    ctx.set_source_rgb(0.12, 0.12, 0.12)
    ctx.rectangle(42, 30, 14, 7)
    ctx.fill()
    
    surface.write_to_png(f"{ART_DIR}/vehicles/driver.png")
    print("Generated driver.png")

def generate_other_vehicles():
    # 1. Auto Rickshaw
    w, h = 300, 180
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    # Yellow upper & Green lower classic Indian Auto
    ctx.set_source_rgb(0.98, 0.82, 0.10) # Bright Yellow Top
    ctx.rectangle(50, 30, 200, 60)
    ctx.fill()
    ctx.arc(220, 75, 45, -math.pi/2, 0)
    ctx.fill()
    ctx.set_source_rgb(0.10, 0.55, 0.22) # Emerald Green Bottom
    ctx.rectangle(50, 90, 210, 50)
    ctx.fill()
    # Open cabin window
    ctx.set_source_rgba(0.65, 0.88, 0.98, 0.5)
    ctx.rectangle(90, 40, 80, 45)
    ctx.fill()
    ctx.rectangle(190, 40, 40, 45)
    ctx.fill()
    # Wheel wells
    ctx.set_source_rgb(0.12, 0.12, 0.12)
    ctx.arc(90, 140, 36, math.pi, 0)
    ctx.fill()
    ctx.arc(230, 140, 36, math.pi, 0)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/vehicles/rickshaw_body.png")
    
    # Rickshaw wheel
    w, h = 80, 80
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgb(0.2, 0.2, 0.2)
    ctx.arc(40, 40, 36, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.85, 0.85)
    ctx.arc(40, 40, 20, 0, math.tau)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/vehicles/rickshaw_wheel.png")
    
    # 2. Tractor
    w, h = 340, 200
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    # Farm green chassis
    ctx.set_source_rgb(0.18, 0.62, 0.25)
    ctx.rectangle(120, 70, 180, 65) # Hood
    ctx.fill()
    # Driver seat & fenders
    ctx.rectangle(40, 60, 80, 75)
    ctx.fill()
    # Exhaust chimney pipe
    ctx.set_source_rgb(0.2, 0.2, 0.2)
    ctx.rectangle(230, 20, 10, 50)
    ctx.fill()
    # Engine block details
    ctx.set_source_rgb(0.3, 0.3, 0.35)
    ctx.rectangle(170, 105, 70, 30)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/vehicles/tractor_body.png")
    
    # Big rear tractor wheel
    w, h = 130, 130
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgb(0.16, 0.16, 0.18)
    ctx.arc(65, 65, 62, 0, math.tau)
    ctx.fill()
    # Deep mud lugs
    ctx.set_source_rgb(0.1, 0.1, 0.1)
    for a in range(0, 360, 24):
        rad = math.radians(a)
        ctx.arc(65 + math.cos(rad) * 60, 65 + math.sin(rad) * 60, 8, 0, math.tau)
        ctx.fill()
    ctx.set_source_rgb(0.95, 0.80, 0.10) # Yellow tractor rim
    ctx.arc(65, 65, 38, 0, math.tau)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/vehicles/tractor_wheel_rear.png")
    
    # Front tractor wheel
    w, h = 75, 75
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgb(0.16, 0.16, 0.18)
    ctx.arc(37, 37, 35, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.80, 0.10)
    ctx.arc(37, 37, 20, 0, math.tau)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/vehicles/tractor_wheel_front.png")
    
    # 3. Mini Truck
    w, h = 360, 170
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgb(0.92, 0.94, 0.96) # White commercial cabin
    ctx.rectangle(210, 45, 120, 80)
    ctx.fill()
    ctx.set_source_rgb(0.20, 0.45, 0.78) # Blue cargo flatbed
    ctx.rectangle(40, 75, 170, 50)
    ctx.fill()
    # Windshield
    ctx.set_source_rgba(0.65, 0.85, 0.95, 0.7)
    ctx.rectangle(265, 55, 55, 35)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/vehicles/mini_truck_body.png")
    
    # Mini truck wheel
    w, h = 90, 90
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgb(0.18, 0.18, 0.20)
    ctx.arc(45, 45, 42, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(0.65, 0.68, 0.72)
    ctx.arc(45, 45, 24, 0, math.tau)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/vehicles/truck_wheel.png")
    
    # 4. Rally Jeep
    w, h = 330, 150
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgb(0.95, 0.45, 0.10) # Racing Orange
    ctx.move_to(40, 80)
    ctx.line_to(180, 70)
    ctx.line_to(310, 90)
    ctx.line_to(300, 120)
    ctx.line_to(40, 120)
    ctx.close_path()
    ctx.fill()
    # Rally decals & spoiler
    ctx.set_source_rgb(0.15, 0.15, 0.15)
    ctx.rectangle(30, 40, 35, 10) # Spoiler
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/vehicles/rally_jeep_body.png")
    
    # Rally wheel
    w, h = 96, 96
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgb(0.15, 0.15, 0.17)
    ctx.arc(48, 48, 45, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.85, 0.15) # Gold rally rim
    ctx.arc(48, 48, 25, 0, math.tau)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/vehicles/rally_wheel.png")
    print("Generated additional vehicle art")


# -------------------------------------------------------------
# 5. PICKUPS & COLLECTIBLES (Star Coin & Fuel Can)
# -------------------------------------------------------------

def generate_pickups():
    # 1. Star Coin
    w, h = 80, 80
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    cx, cy = 40, 40
    
    # Outer gold coin disc
    pat = cairo.RadialGradient(cx - 10, cy - 10, 5, cx, cy, 38)
    pat.add_color_stop_rgb(0.0, 1.0, 0.95, 0.50)
    pat.add_color_stop_rgb(0.6, 0.98, 0.78, 0.12)
    pat.add_color_stop_rgb(1.0, 0.85, 0.55, 0.05)
    ctx.set_source(pat)
    ctx.arc(cx, cy, 36, 0, math.tau)
    ctx.fill()
    
    # 5-pointed star emblem
    ctx.set_source_rgb(1.0, 0.98, 0.75)
    ctx.save()
    ctx.translate(cx, cy)
    ctx.rotate(-math.pi / 2)
    ctx.move_to(22, 0)
    for i in range(1, 10):
        r = 22 if i % 2 == 0 else 9
        ang = i * math.pi / 5
        ctx.line_to(r * math.cos(ang), r * math.sin(ang))
    ctx.close_path()
    ctx.fill()
    ctx.restore()
    
    # Shiny glint
    ctx.set_source_rgba(1.0, 1.0, 1.0, 0.85)
    ctx.arc(cx - 14, cy - 14, 5, 0, math.tau)
    ctx.fill()
    
    surface.write_to_png(f"{ART_DIR}/pickups/coin_star.png")
    print("Generated coin_star.png")
    
    # 2. Fuel Can (Red Jerrycan)
    w, h = 90, 110
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Jerrycan red body
    ctx.set_source_rgb(0.88, 0.15, 0.15)
    ctx.rectangle(15, 30, 60, 70)
    ctx.fill()
    
    # Top carry handles (classic 3-bar handle)
    ctx.set_line_width(6.0)
    ctx.set_source_rgb(0.75, 0.12, 0.12)
    ctx.move_to(25, 30)
    ctx.line_to(25, 14)
    ctx.line_to(65, 14)
    ctx.line_to(65, 30)
    ctx.stroke()
    
    # Center embossed cross
    ctx.set_line_width(4.0)
    ctx.set_source_rgb(0.70, 0.10, 0.10)
    ctx.move_to(25, 45)
    ctx.line_to(65, 85)
    ctx.move_to(65, 45)
    ctx.line_to(25, 85)
    ctx.stroke()
    
    # Yellow "FUEL" banner
    ctx.set_source_rgb(0.98, 0.85, 0.10)
    ctx.rectangle(20, 60, 50, 16)
    ctx.fill()
    ctx.set_source_rgb(0.1, 0.1, 0.1)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(10)
    ctx.move_to(26, 72)
    ctx.show_text("FUEL")
    
    # Cap spout
    ctx.set_source_rgb(0.95, 0.85, 0.15)
    ctx.rectangle(18, 18, 12, 12)
    ctx.fill()
    
    surface.write_to_png(f"{ART_DIR}/pickups/fuel_can.png")
    print("Generated fuel_can.png")


# -------------------------------------------------------------
# 6. UI CONTROLS & GAUGES (Matching Reference Exactly)
# -------------------------------------------------------------

def generate_ui_controls():
    # 1. Brake Pedal (Grey rubber with horizontal ribs, no text labels)
    w, h = 160, 200
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Pedal pivot metal arm
    ctx.set_source_rgb(0.35, 0.36, 0.38)
    ctx.rectangle(70, 0, 20, 50)
    ctx.fill()
    
    # Heavy rubber pad
    ctx.set_source_rgb(0.24, 0.25, 0.27)
    ctx.rectangle(20, 40, 120, 145)
    ctx.fill()
    
    # Metal bevel frame
    ctx.set_source_rgb(0.55, 0.58, 0.62)
    ctx.set_line_width(4.0)
    ctx.rectangle(22, 42, 116, 141)
    ctx.stroke()
    
    # Horizontal anti-slip rubber treads
    ctx.set_source_rgb(0.14, 0.15, 0.16)
    for ry in range(60, 175, 20):
        ctx.rectangle(32, ry, 96, 10)
        ctx.fill()
        
    surface.write_to_png(f"{ART_DIR}/ui/pedal_brake.png")
    print("Generated pedal_brake.png")
    
    # 2. Gas Pedal (Longer ergonomic rubber accelerator, no text labels)
    w, h = 140, 260
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    
    # Pedal arm
    ctx.set_source_rgb(0.35, 0.36, 0.38)
    ctx.rectangle(60, 0, 20, 45)
    ctx.fill()
    
    # Curved long rubber footplate
    ctx.set_source_rgb(0.24, 0.25, 0.27)
    ctx.move_to(25, 45)
    ctx.line_to(115, 45)
    ctx.line_to(110, 245)
    ctx.line_to(30, 245)
    ctx.close_path()
    ctx.fill()
    
    # Bevel
    ctx.set_source_rgb(0.55, 0.58, 0.62)
    ctx.set_line_width(4.0)
    ctx.move_to(27, 47)
    ctx.line_to(113, 47)
    ctx.line_to(108, 243)
    ctx.line_to(32, 243)
    ctx.close_path()
    ctx.stroke()
    
    # Vertical grip slats
    ctx.set_source_rgb(0.14, 0.15, 0.16)
    for vx in [44, 62, 80, 98]:
        ctx.rectangle(vx, 65, 8, 160)
        ctx.fill()
        
    surface.write_to_png(f"{ART_DIR}/ui/pedal_gas.png")
    print("Generated pedal_gas.png")
    
    # 3. Analog Gauge Dial Face (Bottom-center)
    w, h = 200, 200
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    cx, cy = 100, 100
    
    # Outer chrome bezel
    ctx.set_source_rgb(0.70, 0.72, 0.76)
    ctx.arc(cx, cy, 96, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.88, 0.92)
    ctx.arc(cx, cy, 92, 0, math.tau)
    ctx.fill()
    
    # Dark meter face
    ctx.set_source_rgb(0.14, 0.15, 0.18)
    ctx.arc(cx, cy, 84, 0, math.tau)
    ctx.fill()
    
    # Gauge arc ticks (from -140 deg to -40 deg)
    ctx.set_line_width(3.0)
    ctx.set_source_rgb(0.85, 0.85, 0.85)
    for ang_deg in range(-140, -39, 10):
        rad = math.radians(ang_deg)
        r1 = 76
        r2 = 66 if ang_deg % 20 == 0 else 70
        ctx.move_to(cx + math.cos(rad) * r1, cy + math.sin(rad) * r1)
        ctx.line_to(cx + math.cos(rad) * r2, cy + math.sin(rad) * r2)
        ctx.stroke()
        
    # "E" (Empty in red) and "F" (Full in green)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(20)
    ctx.set_source_rgb(0.95, 0.25, 0.20)
    ctx.move_to(40, 85)
    ctx.show_text("E")
    ctx.set_source_rgb(0.25, 0.85, 0.35)
    ctx.move_to(145, 85)
    ctx.show_text("F")
    
    # Little fuel pump symbol in center
    ctx.set_source_rgb(0.65, 0.65, 0.70)
    ctx.rectangle(92, 115, 16, 20)
    ctx.fill()
    ctx.arc(104, 125, 4, 0, math.tau)
    ctx.fill()
    
    surface.write_to_png(f"{ART_DIR}/ui/gauge_dial.png")
    print("Generated gauge_dial.png")
    
    # 4. Gauge Needle
    w, h = 30, 110
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    # Needle pointing UP, pivot at bottom (15, 95)
    ctx.set_source_rgb(0.95, 0.22, 0.15) # Glowing orange-red needle
    ctx.move_to(15, 10)
    ctx.line_to(19, 95)
    ctx.line_to(11, 95)
    ctx.close_path()
    ctx.fill()
    # Black center pivot cap
    ctx.set_source_rgb(0.12, 0.12, 0.14)
    ctx.arc(15, 95, 10, 0, math.tau)
    ctx.fill()
    
    surface.write_to_png(f"{ART_DIR}/ui/gauge_needle.png")
    print("Generated gauge_needle.png")
    
    # 5. Nitro Button
    w, h = 120, 120
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    cx, cy = 60, 60
    
    # Outer ring
    ctx.set_source_rgb(0.15, 0.25, 0.40)
    ctx.arc(cx, cy, 56, 0, math.tau)
    ctx.fill()
    
    # Cyan gradient button core
    pat = cairo.RadialGradient(cx - 10, cy - 10, 5, cx, cy, 50)
    pat.add_color_stop_rgb(0.0, 0.25, 0.85, 1.0)
    pat.add_color_stop_rgb(0.8, 0.08, 0.45, 0.85)
    pat.add_color_stop_rgb(1.0, 0.05, 0.30, 0.65)
    ctx.set_source(pat)
    ctx.arc(cx, cy, 50, 0, math.tau)
    ctx.fill()
    
    # Flame/Lightning icon
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.move_to(cx, cy - 30)
    ctx.curve_to(cx + 20, cy - 10, cx + 22, cy + 15, cx, cy + 30)
    ctx.curve_to(cx - 12, cy + 18, cx - 18, cy + 5, cx - 5, cy - 10)
    ctx.close_path()
    ctx.fill()
    
    # "NITRO" text
    ctx.set_font_size(14)
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.move_to(38, cy + 42)
    ctx.show_text("NITRO")
    
    surface.write_to_png(f"{ART_DIR}/ui/nitro_button.png")
    print("Generated nitro_button.png")
    
    # 6. Pause Button
    w, h = 90, 90
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    cx, cy = 45, 45
    ctx.set_source_rgba(0.15, 0.18, 0.22, 0.85)
    ctx.arc(cx, cy, 40, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.88, 0.92)
    ctx.set_line_width(3.0)
    ctx.arc(cx, cy, 40, 0, math.tau)
    ctx.stroke()
    # Two vertical pause bars
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.rectangle(cx - 14, cy - 16, 9, 32)
    ctx.rectangle(cx + 5, cy - 16, 9, 32)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/ui/pause_button.png")
    print("Generated pause_button.png")
    
    # 7. Fuel Icon (for top-left HUD)
    w, h = 64, 64
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgb(0.88, 0.18, 0.18)
    ctx.rectangle(12, 18, 40, 42)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.85, 0.15)
    ctx.rectangle(14, 10, 8, 8)
    ctx.fill()
    ctx.set_line_width(4.0)
    ctx.set_source_rgb(0.70, 0.12, 0.12)
    ctx.move_to(22, 18)
    ctx.line_to(22, 8)
    ctx.line_to(44, 8)
    ctx.line_to(44, 18)
    ctx.stroke()
    surface.write_to_png(f"{ART_DIR}/ui/fuel_icon.png")
    print("Generated fuel_icon.png")
    
    # 8. Coin Pill Background
    w, h = 220, 70
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgba(0.12, 0.15, 0.18, 0.85)
    r = 30
    ctx.arc(r + 5, h / 2, r, math.pi/2, 3*math.pi/2)
    ctx.line_to(w - r - 5, h / 2 - r)
    ctx.arc(w - r - 5, h / 2, r, -math.pi/2, math.pi/2)
    ctx.line_to(r + 5, h / 2 + r)
    ctx.close_path()
    ctx.fill()
    ctx.set_source_rgb(0.85, 0.70, 0.20)
    ctx.set_line_width(2.5)
    ctx.stroke()
    surface.write_to_png(f"{ART_DIR}/ui/coin_pill.png")
    print("Generated coin_pill.png")


# -------------------------------------------------------------
# 7. FX ASSETS (Dust, Nitro Flame, Sparks)
# -------------------------------------------------------------

def generate_fx():
    # 1. Dust puff
    w, h = 64, 64
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    pat = cairo.RadialGradient(32, 32, 4, 32, 32, 28)
    pat.add_color_stop_rgba(0.0, 0.75, 0.68, 0.60, 0.8)
    pat.add_color_stop_rgba(0.7, 0.65, 0.58, 0.50, 0.4)
    pat.add_color_stop_rgba(1.0, 0.60, 0.55, 0.48, 0.0)
    ctx.set_source(pat)
    ctx.arc(32, 32, 28, 0, math.tau)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/fx/dust_puff.png")
    
    # 2. Nitro flame
    w, h = 96, 96
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    pat = cairo.RadialGradient(48, 48, 6, 48, 48, 44)
    pat.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 1.0)
    pat.add_color_stop_rgba(0.3, 0.25, 0.85, 1.0, 0.9)
    pat.add_color_stop_rgba(0.7, 0.05, 0.40, 0.95, 0.5)
    pat.add_color_stop_rgba(1.0, 0.05, 0.20, 0.80, 0.0)
    ctx.set_source(pat)
    ctx.arc(48, 48, 44, 0, math.tau)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/fx/nitro_flame.png")
    
    # 3. Spark
    w, h = 48, 48
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    pat = cairo.RadialGradient(24, 24, 2, 24, 24, 22)
    pat.add_color_stop_rgba(0.0, 1.0, 1.0, 0.8, 1.0)
    pat.add_color_stop_rgba(0.5, 1.0, 0.6, 0.1, 0.8)
    pat.add_color_stop_rgba(1.0, 0.9, 0.2, 0.0, 0.0)
    ctx.set_source(pat)
    ctx.arc(24, 24, 22, 0, math.tau)
    ctx.fill()
    surface.write_to_png(f"{ART_DIR}/fx/spark.png")
    print("Generated fx assets")


if __name__ == "__main__":
    generate_sky_seamless()
    generate_clouds_seamless()
    generate_sea_seamless()
    generate_islands_seamless()
    generate_town_coastal_seamless()
    generate_lighthouse()
    generate_cliff_rock_tile()
    generate_road_asphalt_pattern()
    generate_grass_tuft()
    generate_tea_shop()
    generate_bollard()
    generate_lamp_post()
    generate_coconut_palm()
    generate_stone_wall()
    generate_sign_kanyakumari()
    generate_jeep_assets()
    generate_other_vehicles()
    generate_pickups()
    generate_ui_controls()
    generate_fx()
    print("All art assets generated successfully!")
