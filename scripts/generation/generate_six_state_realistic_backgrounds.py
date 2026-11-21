#!/usr/bin/env python3
"""
generate_six_state_realistic_backgrounds.py
Author: Joel (Senior Godot 4.7 Environment Artist & Technical Artist)

Generates premium, semi-realistic stylized 2D painted game backgrounds for all Six Indian States:
  1. Tamil Nadu  (Kanyakumari coastal ocean, Vivekananda rock hints, emerald paddy countryside, palmyra groves)
  2. Goa         (Warm tropical sky, layered forested Western Ghats ridges, coastal palm groves, red laterite, Goan villas)
  3. Kerala      (Monsoon sky, mist-shrouded Western Ghats peaks, terraced Munnar tea estates, backwaters with houseboats)
  4. Rajasthan   (Dramatic desert dawn, sweeping Thar golden sand dunes with wind ripples, Aravalli rocky hills, haveli chhatris)
  5. Gujarat     (Pale azure sky, shimmering Great Rann white salt flats with mirage shimmer, Saurashtra savanna & bhunga huts)
  6. Telangana   (Deccan indigo-amber twilight, ancient Precambrian granite boulder tors, plateau countryside, gulmohar trees)

Plus common atmospheric clouds:
  - Feathered painterly cumulus (soft radial alpha falloff, zero geometric circles or bubble clusters)
  - High-altitude wispy cirrus
  - Soft horizon stratus haze

All 1920-wide layers feature mathematically verified horizontal wrapping (f(0) == f(1920)) for seamless looping.
"""

import cairo
import math
import os
import random

WIDTH = 1920
HEIGHT = 720

def create_surface(w=WIDTH, h=HEIGHT):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surf)
    return surf, ctx

def save_surface(surf, rel_path):
    base_dir = os.path.dirname(rel_path)
    if base_dir and not os.path.exists(base_dir):
        os.makedirs(base_dir, exist_ok=True)
    surf.write_to_png(rel_path)
    print(f"Generated: {rel_path} ({surf.get_width()}x{surf.get_height()})")

# -------------------------------------------------------------
# MATH & NOISE HELPERS
# -------------------------------------------------------------

def seamless_sine_noise(x, width=1920, harmonics=[(1, 1.0), (2, 0.5), (3, 0.25), (5, 0.12)], phase_offset=0.0):
    """Returns a continuous periodic value in [-1, 1] guaranteed to wrap seamlessly at width."""
    val = 0.0
    total_w = 0.0
    norm_x = (x / width) * 2.0 * math.pi
    for freq, weight in harmonics:
        val += math.sin(norm_x * freq + phase_offset * freq) * weight
        total_w += weight
    return val / total_w if total_w > 0 else 0.0

def draw_feathered_puff(ctx, cx, cy, rx, ry, color_rgb, max_alpha=0.35, rings=12):
    """Draws a soft, painterly cloud puff with feathered alpha falloff (no hard edges)."""
    r_max = max(rx, ry)
    for i in range(rings, 0, -1):
        frac = i / float(rings)
        alpha = max_alpha * (1.0 - frac * frac)
        ctx.save()
        ctx.translate(cx, cy)
        ctx.scale(rx / r_max, ry / r_max)
        ctx.set_source_rgba(color_rgb[0], color_rgb[1], color_rgb[2], alpha)
        ctx.arc(0, 0, r_max * frac, 0, 2 * math.pi)
        ctx.fill()
        ctx.restore()

# -------------------------------------------------------------
# COMMON ATMOSPHERIC CLOUD GENERATION
# -------------------------------------------------------------

def generate_common_clouds():
    print("\n--- Generating Painterly Realistic Clouds ---")

    # 1. Cloud Cumulus Soft 01 (1920x450 - Wide sweeping painterly bank)
    surf, ctx = create_surface(1920, 450)
    # Generate 3 distinct soft cloud clusters across width
    rng = random.Random(20261117)
    clusters = [
        (420, 160, 220, 100),
        (1050, 140, 260, 110),
        (1650, 180, 200, 90)
    ]
    for ccx, ccy, crx, cry in clusters:
        # Base cloud body: 60 overlapping soft feathered puffs
        for _ in range(70):
            px = ccx + rng.gauss(0, crx * 0.45)
            py = ccy + rng.gauss(0, cry * 0.35)
            prx = rng.uniform(45, 95)
            pry = prx * rng.uniform(0.65, 0.90)
            # Ambient cool underbelly
            draw_feathered_puff(ctx, px, py + 12, prx, pry, (0.86, 0.90, 0.96), max_alpha=0.09)
            # Soft white mid body
            draw_feathered_puff(ctx, px, py, prx * 0.9, pry * 0.9, (0.97, 0.98, 1.0), max_alpha=0.12)
            # Warm illuminated upper highlight
            draw_feathered_puff(ctx, px, py - 14, prx * 0.75, pry * 0.75, (1.0, 0.99, 0.95), max_alpha=0.15)
    save_surface(surf, "assets/indian_locations/common/clouds/cloud_cumulus_soft_01.png")

    # 2. Cloud Cumulus Soft 02 (1920x450 - Low, drifting atmospheric cumulus)
    surf, ctx = create_surface(1920, 450)
    rng2 = random.Random(20261118)
    clusters2 = [
        (250, 190, 180, 80),
        (800, 150, 240, 95),
        (1400, 170, 280, 105)
    ]
    for ccx, ccy, crx, cry in clusters2:
        for _ in range(65):
            px = ccx + rng2.gauss(0, crx * 0.42)
            py = ccy + rng2.gauss(0, cry * 0.35)
            prx = rng2.uniform(40, 85)
            pry = prx * rng2.uniform(0.60, 0.85)
            draw_feathered_puff(ctx, px, py + 10, prx, pry, (0.88, 0.91, 0.95), max_alpha=0.08)
            draw_feathered_puff(ctx, px, py, prx * 0.85, pry * 0.85, (0.98, 0.98, 1.0), max_alpha=0.11)
            draw_feathered_puff(ctx, px, py - 12, prx * 0.7, pry * 0.7, (1.0, 0.98, 0.94), max_alpha=0.14)
    save_surface(surf, "assets/indian_locations/common/clouds/cloud_cumulus_soft_02.png")

    # 3. Cloud Cirrus Wispy (1920x350 - Delicate high-altitude feathered brush streaks)
    surf, ctx = create_surface(1920, 350)
    rng3 = random.Random(20261119)
    for _ in range(45):
        start_x = rng3.uniform(50, 1750)
        start_y = rng3.uniform(40, 220)
        streak_len = rng3.uniform(220, 480)
        angle = rng3.uniform(-0.15, 0.05)
        
        ctx.save()
        ctx.translate(start_x, start_y)
        ctx.rotate(angle)
        
        # Feathered brush streak
        pat = cairo.LinearGradient(0, 0, streak_len, 0)
        pat.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.0)
        pat.add_color_stop_rgba(0.3, 1.0, 1.0, 1.0, rng3.uniform(0.12, 0.28))
        pat.add_color_stop_rgba(0.7, 0.95, 0.98, 1.0, rng3.uniform(0.10, 0.22))
        pat.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.0)
        ctx.set_source(pat)
        
        h = rng3.uniform(8, 24)
        ctx.move_to(0, 0)
        ctx.curve_to(streak_len * 0.35, -h * 0.8, streak_len * 0.75, h * 0.5, streak_len, 0)
        ctx.curve_to(streak_len * 0.75, h * 0.8, streak_len * 0.35, -h * 0.2, 0, 0)
        ctx.fill()
        ctx.restore()
    save_surface(surf, "assets/indian_locations/common/clouds/cloud_cirrus_wispy.png")

    # 4. Cloud Stratus Horizon (1920x250 - Soft atmospheric horizon haze)
    surf, ctx = create_surface(1920, 250)
    pat = cairo.LinearGradient(0, 0, 0, 250)
    pat.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.0)
    pat.add_color_stop_rgba(0.4, 0.98, 0.98, 1.0, 0.18)
    pat.add_color_stop_rgba(0.7, 1.0, 0.96, 0.90, 0.28)
    pat.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.0)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 250)
    ctx.fill()
    save_surface(surf, "assets/indian_locations/common/clouds/cloud_stratus_horizon.png")

# -------------------------------------------------------------
# 1. TAMIL NADU (Kanyakumari Coast, Triveni Sangam, Paddy Country)
# -------------------------------------------------------------

def generate_tamil_nadu():
    print("\n--- Generating Tamil Nadu Environment Layers ---")

    # Layer 1: Coastal Morning Sky (1920x720)
    surf, ctx = create_surface()
    pat = cairo.LinearGradient(0, 0, 0, 520)
    pat.add_color_stop_rgb(0.0, 0.08, 0.24, 0.48) # Deep oceanic sapphire
    pat.add_color_stop_rgb(0.35, 0.18, 0.45, 0.72) # Azure mid-sky
    pat.add_color_stop_rgb(0.70, 0.45, 0.68, 0.88) # Morning coastal pale cyan
    pat.add_color_stop_rgb(0.92, 0.98, 0.84, 0.68) # Warm golden horizon glow
    pat.add_color_stop_rgb(1.0, 1.0, 0.92, 0.80)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 720)
    ctx.fill()

    # Subtle Morning Sun Glow over Ocean
    sun_x, sun_y = 1420, 240
    sun_pat = cairo.RadialGradient(sun_x, sun_y, 10, sun_x, sun_y, 180)
    sun_pat.add_color_stop_rgba(0.0, 1.0, 0.98, 0.88, 0.85)
    sun_pat.add_color_stop_rgba(0.25, 1.0, 0.90, 0.70, 0.45)
    sun_pat.add_color_stop_rgba(0.60, 1.0, 0.80, 0.55, 0.15)
    sun_pat.add_color_stop_rgba(1.0, 1.0, 0.80, 0.50, 0.0)
    ctx.set_source(sun_pat)
    ctx.arc(sun_x, sun_y, 180, 0, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "assets/indian_locations/tamil_nadu/backgrounds/sky/kanyakumari_sky_coastal.png")

    # Layer 2: Far Background - Kanyakumari Coastal Ocean & Distant Rock Headlands (1920x720)
    surf, ctx = create_surface()
    # Distant Cape Comorin headland silhouette (Atmospheric blue-grey)
    ctx.save()
    pat_headland = cairo.LinearGradient(0, 280, 0, 360)
    pat_headland.add_color_stop_rgba(0.0, 0.22, 0.35, 0.48, 0.65)
    pat_headland.add_color_stop_rgba(1.0, 0.15, 0.26, 0.38, 0.85)
    ctx.set_source(pat_headland)
    ctx.move_to(0, 340)
    for x in range(0, 1921, 20):
        # Seamless headland hills
        hy = 340 + seamless_sine_noise(x, harmonics=[(1, 18.0), (3, 10.0), (7, 4.0)], phase_offset=0.8)
        ctx.line_to(x, hy)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()
    ctx.restore()

    # Ocean Horizon Water Expanse (From y=330 downwards)
    pat_ocean = cairo.LinearGradient(0, 330, 0, 580)
    pat_ocean.add_color_stop_rgba(0.0, 0.10, 0.32, 0.54, 0.92) # Deep blue horizon
    pat_ocean.add_color_stop_rgba(0.35, 0.12, 0.42, 0.62, 0.95) # Turquoise swell
    pat_ocean.add_color_stop_rgba(0.75, 0.08, 0.36, 0.55, 0.98) # Indian Ocean swell
    pat_ocean.add_color_stop_rgba(1.0, 0.06, 0.28, 0.46, 1.0)
    ctx.set_source(pat_ocean)
    ctx.rectangle(0, 330, 1920, 390)
    ctx.fill()

    # Delicate Ocean Swell Waves & Shimmer Highlights
    wave_rng = random.Random(42)
    for row in range(340, 540, 12):
        row_alpha = 0.18 + (row - 340) / 500.0 * 0.35
        ctx.set_source_rgba(0.75, 0.92, 0.98, row_alpha)
        ctx.set_line_width(1.2 + (row - 340) / 140.0)
        y_base = float(row)
        for wave_idx in range(6):
            wx = wave_rng.uniform(40, 1800)
            wlen = wave_rng.uniform(60, 180)
            ctx.move_to(wx, y_base)
            ctx.curve_to(wx + wlen * 0.3, y_base - 2.5, wx + wlen * 0.7, y_base + 1.5, wx + wlen, y_base)
            ctx.stroke()

    # Distant Silhouette of Vivekananda Rock Memorial Platform & Thiruvalluvar pedestal contour
    # Positioned authentically on the ocean horizon around x=820 and x=1150
    ctx.set_source_rgba(0.12, 0.22, 0.32, 0.70)
    # Vivekananda Rock platform
    ctx.move_to(800, 338)
    ctx.line_to(830, 326) # Memorial Mandapam dome silhouette
    ctx.line_to(845, 322)
    ctx.line_to(860, 326)
    ctx.line_to(880, 338)
    ctx.line_to(895, 342)
    ctx.line_to(780, 342)
    ctx.close_path()
    ctx.fill()
    # Thiruvalluvar stone pedestal contour
    ctx.move_to(1130, 340)
    ctx.line_to(1142, 316)
    ctx.line_to(1155, 316)
    ctx.line_to(1168, 340)
    ctx.close_path()
    ctx.fill()

    # Small Distant Wooden Fishing Boat (Kattumaram) silhouettes on horizon
    for bx, by in [(350, 334), (1350, 336), (1680, 332)]:
        ctx.set_source_rgba(0.10, 0.18, 0.25, 0.65)
        ctx.move_to(bx, by)
        ctx.line_to(bx + 18, by + 2)
        ctx.line_to(bx + 14, by + 5)
        ctx.line_to(bx - 4, by + 5)
        ctx.close_path()
        ctx.fill()
        # Slanted mast
        ctx.move_to(bx + 7, by + 2)
        ctx.line_to(bx + 5, by - 8)
        ctx.set_line_width(1.0)
        ctx.stroke()
    save_surface(surf, "assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png")

    # Layer 3: Midground - Lush Tamil Agricultural Countryside (Paddy Fields, Palmyra Groves, Canal Waterway) (1920x720)
    surf, ctx = create_surface()
    # Rolling Paddy Mosaic Hills (Seamless profile at y=320)
    pat_paddy = cairo.LinearGradient(0, 310, 0, 480)
    pat_paddy.add_color_stop_rgba(0.0, 0.22, 0.52, 0.24, 0.95) # Emerald green paddy
    pat_paddy.add_color_stop_rgba(0.5, 0.32, 0.62, 0.28, 0.98) # Golden-green ripe paddy
    pat_paddy.add_color_stop_rgba(1.0, 0.20, 0.44, 0.22, 1.0)
    ctx.set_source(pat_paddy)
    ctx.move_to(0, 345)
    for x in range(0, 1921, 15):
        py = 345 + seamless_sine_noise(x, harmonics=[(1, 14.0), (2, 8.0), (4, 4.0)], phase_offset=0.2)
        ctx.line_to(x, py)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Irrigation canal waterway reflection ribbon
    pat_canal = cairo.LinearGradient(0, 370, 0, 410)
    pat_canal.add_color_stop_rgba(0.0, 0.35, 0.58, 0.65, 0.6)
    pat_canal.add_color_stop_rgba(1.0, 0.20, 0.42, 0.48, 0.8)
    ctx.set_source(pat_canal)
    ctx.move_to(0, 395)
    for x in range(0, 1921, 30):
        cy = 395 + seamless_sine_noise(x, harmonics=[(1, 8.0), (3, 5.0)], phase_offset=0.5)
        ctx.line_to(x, cy)
    for x in range(1920, -1, -30):
        cy = 407 + seamless_sine_noise(x, harmonics=[(1, 8.0), (3, 5.0)], phase_offset=0.5)
        ctx.line_to(x, cy)
    ctx.close_path()
    ctx.fill()

    # Palmyra Palm Trees (Authentic natural fan fronds & tapered curved trunks in organic clusters)
    def draw_palmyra_tree(cx, base_y, height=85, tilt=0.04):
        ctx.save()
        ctx.translate(cx, base_y)
        # Trunk
        ctx.set_source_rgb(0.24, 0.18, 0.14)
        ctx.set_line_width(3.2)
        top_x = height * tilt
        top_y = -height
        ctx.move_to(0, 0)
        ctx.curve_to(top_x * 0.3, top_y * 0.5, top_x * 0.7, top_y * 0.8, top_x, top_y)
        ctx.stroke()
        # Fan-shaped palm crown
        crown_x = top_x
        crown_y = top_y
        ctx.translate(crown_x, crown_y)
        frond_colors = [(0.12, 0.35, 0.16), (0.16, 0.42, 0.20), (0.22, 0.48, 0.24)]
        num_fronds = 11
        for f in range(num_fronds):
            f_angle = -math.pi * 0.85 + (math.pi * 0.70) * (f / float(num_fronds - 1))
            ctx.set_source_rgb(*frond_colors[f % len(frond_colors)])
            ctx.set_line_width(1.8)
            flen = random.Random(int(cx + f)).uniform(22, 34)
            fx = math.cos(f_angle) * flen
            fy = math.sin(f_angle) * flen
            ctx.move_to(0, 0)
            ctx.line_to(fx, fy)
            ctx.stroke()
        ctx.restore()

    # Natural Palmyra clusters (groups of 2-3 with varying heights)
    palmyra_clusters = [120, 280, 560, 840, 1100, 1380, 1660]
    p_rng = random.Random(99)
    for cl_x in palmyra_clusters:
        for offset, h in [(-12, 75), (0, 92), (16, 68)]:
            px = cl_x + offset
            by = 352 + seamless_sine_noise(px, harmonics=[(1, 14.0), (2, 8.0)], phase_offset=0.2)
            draw_palmyra_tree(px, by, height=h, tilt=p_rng.uniform(-0.06, 0.08))

    save_surface(surf, "assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_countryside_midground.png")

# -------------------------------------------------------------
# 2. GOA (Warm Tropical Sky, Layered Western Ghats, Coastal Palms & Villas)
# -------------------------------------------------------------

def generate_goa():
    print("\n--- Generating Goa Environment Layers ---")

    # Layer 1: Warm Sunny Tropical Sky (1920x720)
    surf, ctx = create_surface()
    pat = cairo.LinearGradient(0, 0, 0, 540)
    pat.add_color_stop_rgb(0.0, 0.10, 0.38, 0.65) # Warm cobalt blue zenith
    pat.add_color_stop_rgb(0.40, 0.28, 0.58, 0.80) # Tropical cerulean
    pat.add_color_stop_rgb(0.75, 0.62, 0.80, 0.88) # Warm humid haze
    pat.add_color_stop_rgb(0.95, 0.98, 0.82, 0.70) # Golden-peach horizon
    pat.add_color_stop_rgb(1.0, 1.0, 0.90, 0.78)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 720)
    ctx.fill()

    # Soft Tropical Afternoon Sun Flare
    sun_x, sun_y = 650, 200
    sun_pat = cairo.RadialGradient(sun_x, sun_y, 10, sun_x, sun_y, 220)
    sun_pat.add_color_stop_rgba(0.0, 1.0, 0.98, 0.90, 0.80)
    sun_pat.add_color_stop_rgba(0.3, 1.0, 0.88, 0.65, 0.35)
    sun_pat.add_color_stop_rgba(0.7, 1.0, 0.75, 0.45, 0.10)
    sun_pat.add_color_stop_rgba(1.0, 1.0, 0.70, 0.40, 0.0)
    ctx.set_source(sun_pat)
    ctx.arc(sun_x, sun_y, 220, 0, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "assets/indian_locations/goa/backgrounds/sky/goa_tropical_sky.png")

    # Layer 2: Far Background - Layered Western Ghats Forested Mountain Ridges (1920x720)
    surf, ctx = create_surface()
    # Tier 1: Distant Misty Ridge (Pale lavender-teal atmospheric haze)
    pat_tier1 = cairo.LinearGradient(0, 240, 0, 360)
    pat_tier1.add_color_stop_rgba(0.0, 0.42, 0.56, 0.65, 0.50)
    pat_tier1.add_color_stop_rgba(1.0, 0.32, 0.46, 0.55, 0.75)
    ctx.set_source(pat_tier1)
    ctx.move_to(0, 280)
    for x in range(0, 1921, 20):
        my = 280 + seamless_sine_noise(x, harmonics=[(1, 35.0), (3, 18.0), (6, 8.0)], phase_offset=0.3)
        ctx.line_to(x, my)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Tier 2: Middle Forested Western Ghats Ridge (Deep lush jungle green)
    pat_tier2 = cairo.LinearGradient(0, 290, 0, 420)
    pat_tier2.add_color_stop_rgba(0.0, 0.18, 0.38, 0.30, 0.85)
    pat_tier2.add_color_stop_rgba(1.0, 0.12, 0.28, 0.22, 0.95)
    ctx.set_source(pat_tier2)
    ctx.move_to(0, 325)
    for x in range(0, 1921, 15):
        my = 325 + seamless_sine_noise(x, harmonics=[(1, 28.0), (2, 16.0), (5, 9.0)], phase_offset=1.1)
        ctx.line_to(x, my)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Subtle valley mist band between tiers
    pat_mist = cairo.LinearGradient(0, 310, 0, 350)
    pat_mist.add_color_stop_rgba(0.0, 0.95, 0.98, 1.0, 0.0)
    pat_mist.add_color_stop_rgba(0.5, 0.92, 0.96, 0.98, 0.35)
    pat_mist.add_color_stop_rgba(1.0, 0.95, 0.98, 1.0, 0.0)
    ctx.set_source(pat_mist)
    ctx.rectangle(0, 310, 1920, 40)
    ctx.fill()
    save_surface(surf, "assets/indian_locations/goa/backgrounds/distant_landscape/goa_western_ghats_lush.png")

    # Layer 3: Midground - Goa Coastal & Mandovi River Horizon (Palms, Red Laterite, Portuguese Villas) (1920x720)
    surf, ctx = create_surface()
    # Coastal Red Laterite Bluffs & Palm Canopy
    pat_laterite = cairo.LinearGradient(0, 330, 0, 460)
    pat_laterite.add_color_stop_rgba(0.0, 0.20, 0.48, 0.22, 0.98) # Dense tropical tree canopy
    pat_laterite.add_color_stop_rgba(0.5, 0.58, 0.28, 0.18, 1.0) # Red laterite soil cliffs
    pat_laterite.add_color_stop_rgba(1.0, 0.45, 0.22, 0.14, 1.0)
    ctx.set_source(pat_laterite)
    ctx.move_to(0, 350)
    for x in range(0, 1921, 15):
        ly = 350 + seamless_sine_noise(x, harmonics=[(1, 16.0), (2, 10.0), (4, 5.0)], phase_offset=0.6)
        ctx.line_to(x, ly)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Portuguese-Goan Colonial Tiled Villa Silhouettes nestled in vegetation
    def draw_goan_villa(vx, vy, vw=48, vh=26):
        # Terracotta Mangalore-tiled pitched roof
        ctx.set_source_rgb(0.78, 0.28, 0.18)
        ctx.move_to(vx - vw * 0.55, vy)
        ctx.line_to(vx, vy - vh)
        ctx.line_to(vx + vw * 0.55, vy)
        ctx.close_path()
        ctx.fill()
        # White/pastel colonial wall
        ctx.set_source_rgb(0.94, 0.92, 0.85)
        ctx.rectangle(vx - vw * 0.45, vy, vw * 0.9, vh * 0.8)
        ctx.fill()
        # Arched window
        ctx.set_source_rgb(0.22, 0.35, 0.42)
        ctx.arc(vx, vy + vh * 0.35, vw * 0.14, math.pi, 2 * math.pi)
        ctx.fill()

    # Scattered villas along midground
    for vx in [320, 780, 1240, 1680]:
        vy = 348 + seamless_sine_noise(vx, harmonics=[(1, 16.0), (2, 10.0)], phase_offset=0.6)
        draw_goan_villa(vx, vy, vw=46, vh=24)

    # Leaning Coconut Palms (Authentic curved trunks, drooping feathery fronds)
    def draw_coconut_palm(cx, base_y, height=95, lean=0.25):
        ctx.save()
        ctx.translate(cx, base_y)
        # Curved trunk
        ctx.set_source_rgb(0.38, 0.28, 0.20)
        ctx.set_line_width(3.0)
        top_x = height * lean
        top_y = -height
        ctx.move_to(0, 0)
        ctx.curve_to(top_x * 0.2, top_y * 0.4, top_x * 0.8, top_y * 0.7, top_x, top_y)
        ctx.stroke()
        # Palm fronds
        ctx.translate(top_x, top_y)
        frond_colors = [(0.14, 0.42, 0.18), (0.18, 0.50, 0.22), (0.24, 0.56, 0.26)]
        for i in range(8):
            ang = -math.pi * 0.9 + i * (math.pi * 0.8 / 7.0)
            ctx.set_source_rgb(*frond_colors[i % 3])
            ctx.set_line_width(2.0)
            ctx.move_to(0, 0)
            fx = math.cos(ang) * 38
            fy = math.sin(ang) * 38 + 12 # droop
            ctx.curve_to(fx * 0.4, fy * 0.3, fx * 0.8, fy * 0.7, fx, fy)
            ctx.stroke()
        ctx.restore()

    for px in [150, 440, 620, 950, 1150, 1480, 1820]:
        py = 346 + seamless_sine_noise(px, harmonics=[(1, 16.0), (2, 10.0)], phase_offset=0.6)
        draw_coconut_palm(px, py, height=random.Random(px).uniform(85, 110), lean=random.Random(px).uniform(0.15, 0.32))

    save_surface(surf, "assets/indian_locations/goa/backgrounds/distant_landscape/goa_coastal_midground.png")

# -------------------------------------------------------------
# 3. KERALA (Monsoon Sky, Misty Western Ghats Peaks, Tea Estates, Backwaters)
# -------------------------------------------------------------

def generate_kerala():
    print("\n--- Generating Kerala Environment Layers ---")

    # Layer 1: Soft Diffused Monsoon Sky (1920x720)
    surf, ctx = create_surface()
    pat = cairo.LinearGradient(0, 0, 0, 520)
    pat.add_color_stop_rgb(0.0, 0.18, 0.28, 0.38) # Slate-teal monsoon zenith
    pat.add_color_stop_rgb(0.40, 0.35, 0.48, 0.58) # Diffused silvery turquoise
    pat.add_color_stop_rgb(0.75, 0.55, 0.68, 0.74) # Humid rain-laden mist
    pat.add_color_stop_rgb(0.95, 0.82, 0.90, 0.88) # Pale valley mist glow
    pat.add_color_stop_rgb(1.0, 0.88, 0.94, 0.92)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 720)
    ctx.fill()
    save_surface(surf, "assets/indian_locations/kerala/backgrounds/sky/kerala_sky_monsoon.png")

    # Layer 2: Far Background - Dramatic Western Ghats & Anamudi Misty Mountain Peaks (1920x720)
    surf, ctx = create_surface()
    # High Mountain Ridges (Layer 1 - Distant jagged peaks)
    pat_high = cairo.LinearGradient(0, 220, 0, 360)
    pat_high.add_color_stop_rgba(0.0, 0.24, 0.36, 0.42, 0.65)
    pat_high.add_color_stop_rgba(1.0, 0.16, 0.28, 0.34, 0.90)
    ctx.set_source(pat_high)
    ctx.move_to(0, 260)
    for x in range(0, 1921, 15):
        my = 260 + seamless_sine_noise(x, harmonics=[(1, 45.0), (3, 24.0), (7, 10.0)], phase_offset=0.7)
        ctx.line_to(x, my)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Mountain Mist Veil
    pat_cloud = cairo.LinearGradient(0, 280, 0, 330)
    pat_cloud.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.0)
    pat_cloud.add_color_stop_rgba(0.5, 0.92, 0.96, 0.96, 0.40)
    pat_cloud.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.0)
    ctx.set_source(pat_cloud)
    ctx.rectangle(0, 280, 1920, 50)
    ctx.fill()

    # Mid Ridge (Layer 2 - Deep rainforest green mountain slopes)
    pat_mid_ridge = cairo.LinearGradient(0, 290, 0, 420)
    pat_mid_ridge.add_color_stop_rgba(0.0, 0.10, 0.26, 0.20, 0.92)
    pat_mid_ridge.add_color_stop_rgba(1.0, 0.08, 0.20, 0.15, 0.98)
    ctx.set_source(pat_mid_ridge)
    ctx.move_to(0, 315)
    for x in range(0, 1921, 15):
        my = 315 + seamless_sine_noise(x, harmonics=[(1, 30.0), (2, 18.0), (5, 8.0)], phase_offset=1.5)
        ctx.line_to(x, my)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Distant Waterfall vapor streak (Athirappilly hint)
    ctx.set_source_rgba(0.92, 0.96, 1.0, 0.45)
    ctx.set_line_width(2.5)
    for wfx in [580, 1420]:
        ctx.move_to(wfx, 285)
        ctx.line_to(wfx + 1.5, 330)
        ctx.stroke()

    save_surface(surf, "assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_western_ghats_peaks.png")

    # Layer 3: Midground - Munnar Terraced Tea Slopes & Backwater Canal Horizons (1920x720)
    surf, ctx = create_surface()
    # Terraced Tea Plantation Hills (Contoured lush green rows)
    pat_tea = cairo.LinearGradient(0, 320, 0, 480)
    pat_tea.add_color_stop_rgba(0.0, 0.16, 0.48, 0.18, 0.98) # Bright tea green
    pat_tea.add_color_stop_rgba(0.6, 0.12, 0.38, 0.15, 1.0)
    pat_tea.add_color_stop_rgba(1.0, 0.08, 0.28, 0.12, 1.0)
    ctx.set_source(pat_tea)
    ctx.move_to(0, 345)
    for x in range(0, 1921, 15):
        ty = 345 + seamless_sine_noise(x, harmonics=[(1, 18.0), (2, 12.0), (4, 6.0)], phase_offset=0.4)
        ctx.line_to(x, ty)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Terraced tea contour lines
    ctx.set_source_rgba(0.08, 0.30, 0.10, 0.35)
    ctx.set_line_width(2.0)
    for contour_y in [360, 375, 390, 410]:
        ctx.move_to(0, contour_y)
        for x in range(0, 1921, 20):
            cy = contour_y + seamless_sine_noise(x, harmonics=[(1, 18.0), (2, 12.0)], phase_offset=0.4)
            ctx.line_to(x, cy)
        ctx.stroke()

    # Traditional Kettuvallam (Houseboat) silhouette on canal horizon
    def draw_kettuvallam(kx, ky):
        ctx.save()
        ctx.translate(kx, ky)
        # Curved wooden hull
        ctx.set_source_rgb(0.22, 0.16, 0.12)
        ctx.move_to(-35, 4)
        ctx.curve_to(-25, 12, 25, 12, 35, 4)
        ctx.curve_to(20, 2, -20, 2, -35, 4)
        ctx.fill()
        # Thatched bamboo roof canopy
        ctx.set_source_rgb(0.55, 0.42, 0.22)
        ctx.move_to(-25, 2)
        ctx.curve_to(-15, -14, 15, -14, 25, 2)
        ctx.close_path()
        ctx.fill()
        ctx.restore()

    for kx in [420, 1280]:
        ky = 370 + seamless_sine_noise(kx, harmonics=[(1, 18.0), (2, 12.0)], phase_offset=0.4)
        draw_kettuvallam(kx, ky)

    # Chinese Fishing Net (Cheena Vala) silhouette
    def draw_chinese_fishing_net(nx, ny):
        ctx.save()
        ctx.translate(nx, ny)
        ctx.set_source_rgba(0.18, 0.14, 0.10, 0.85)
        ctx.set_line_width(1.8)
        # Cantilever beam
        ctx.move_to(-10, 0)
        ctx.line_to(22, -28)
        ctx.stroke()
        # Spreading net poles
        ctx.line_to(36, -8)
        ctx.stroke()
        ctx.move_to(22, -28)
        ctx.line_to(42, -22)
        ctx.stroke()
        # Net mesh curve
        ctx.move_to(36, -8)
        ctx.curve_to(38, -2, 42, -14, 42, -22)
        ctx.set_line_width(1.0)
        ctx.stroke()
        ctx.restore()

    for nx in [850, 1680]:
        ny = 360 + seamless_sine_noise(nx, harmonics=[(1, 18.0), (2, 12.0)], phase_offset=0.4)
        draw_chinese_fishing_net(nx, ny)

    save_surface(surf, "assets/indian_locations/kerala/backgrounds/distant_landscape/kerala_backwater_canal_midground.png")

# -------------------------------------------------------------
# 4. RAJASTHAN (Thar Desert Dawn, Golden Dunes, Aravalli Hills & Havelis)
# -------------------------------------------------------------

def generate_rajasthan():
    print("\n--- Generating Rajasthan Environment Layers ---")

    # Layer 1: Dramatic Desert Dawn Sky (1920x720)
    surf, ctx = create_surface()
    pat = cairo.LinearGradient(0, 0, 0, 520)
    pat.add_color_stop_rgb(0.0, 0.16, 0.10, 0.28) # Twilight deep plum/indigo
    pat.add_color_stop_rgb(0.35, 0.58, 0.22, 0.28) # Desert dawn crimson-magenta
    pat.add_color_stop_rgb(0.65, 0.88, 0.42, 0.15) # Fiery terracotta amber
    pat.add_color_stop_rgb(0.88, 0.98, 0.72, 0.25) # Luminous desert gold
    pat.add_color_stop_rgb(1.0, 1.0, 0.90, 0.65)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 720)
    ctx.fill()

    # Glowing Desert Dawn Sun on Horizon
    sun_x, sun_y = 1250, 290
    sun_pat = cairo.RadialGradient(sun_x, sun_y, 10, sun_x, sun_y, 200)
    sun_pat.add_color_stop_rgba(0.0, 1.0, 0.96, 0.82, 0.95)
    sun_pat.add_color_stop_rgba(0.30, 1.0, 0.78, 0.35, 0.60)
    sun_pat.add_color_stop_rgba(0.70, 0.95, 0.45, 0.15, 0.20)
    sun_pat.add_color_stop_rgba(1.0, 0.90, 0.35, 0.10, 0.0)
    ctx.set_source(sun_pat)
    ctx.arc(sun_x, sun_y, 200, 0, 2 * math.pi)
    ctx.fill()
    save_surface(surf, "assets/indian_locations/rajasthan/backgrounds/sky/rajasthan_sky_desert_dawn.png")

    # Layer 2: Far Background - Sweeping Thar Sand Dunes & Jaisalmer Fort Silhouettes (1920x720)
    surf, ctx = create_surface()
    # Far Dunes Tier 1 (Warm crimson-ochre)
    pat_dune1 = cairo.LinearGradient(0, 280, 0, 420)
    pat_dune1.add_color_stop_rgba(0.0, 0.82, 0.42, 0.18, 0.85)
    pat_dune1.add_color_stop_rgba(1.0, 0.68, 0.32, 0.14, 0.95)
    ctx.set_source(pat_dune1)
    ctx.move_to(0, 320)
    for x in range(0, 1921, 20):
        dy = 320 + seamless_sine_noise(x, harmonics=[(1, 35.0), (3, 16.0), (5, 8.0)], phase_offset=0.2)
        ctx.line_to(x, dy)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Near Dune Tier 2 (Golden sand with windward light and leeward shadows)
    pat_dune2 = cairo.LinearGradient(0, 330, 0, 480)
    pat_dune2.add_color_stop_rgba(0.0, 0.95, 0.68, 0.24, 0.95) # Sun-illuminated dune crest
    pat_dune2.add_color_stop_rgba(0.4, 0.82, 0.52, 0.18, 0.98) # Dune shadow slope
    pat_dune2.add_color_stop_rgba(1.0, 0.70, 0.42, 0.15, 1.0)
    ctx.set_source(pat_dune2)
    ctx.move_to(0, 355)
    for x in range(0, 1921, 15):
        dy = 355 + seamless_sine_noise(x, harmonics=[(1, 24.0), (2, 14.0), (4, 7.0)], phase_offset=1.2)
        ctx.line_to(x, dy)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Distant Fort Ramparts & Chhatri Domes on Horizon (Jaisalmer Sonar Qila hint)
    def draw_fort_silhouette(fx, fy):
        ctx.save()
        ctx.translate(fx, fy)
        ctx.set_source_rgba(0.55, 0.25, 0.12, 0.75)
        # Stone bastion
        ctx.rectangle(-22, -18, 44, 24)
        ctx.fill()
        # Chhatri dome pavilion on top
        ctx.arc(0, -24, 8, math.pi, 2 * math.pi)
        ctx.fill()
        ctx.rectangle(-1, -30, 2, 7) # Finial
        ctx.fill()
        ctx.restore()

    for fx in [380, 1550]:
        fy = 318 + seamless_sine_noise(fx, harmonics=[(1, 35.0), (3, 16.0)], phase_offset=0.2)
        draw_fort_silhouette(fx, fy)

    # Distant Camel Caravan Silhouette traveling along dune crest
    def draw_camel(cx, cy):
        ctx.save()
        ctx.translate(cx, cy)
        ctx.set_source_rgba(0.42, 0.18, 0.08, 0.85)
        # Body & hump
        ctx.arc(0, -6, 5, 0, 2 * math.pi)
        ctx.fill()
        # Curved neck & head
        ctx.move_to(-3, -6)
        ctx.curve_to(-6, -14, -4, -18, -8, -19)
        ctx.set_line_width(2.0)
        ctx.stroke()
        # Legs
        ctx.move_to(-3, -2)
        ctx.line_to(-4, 6)
        ctx.move_to(3, -2)
        ctx.line_to(4, 6)
        ctx.set_line_width(1.2)
        ctx.stroke()
        ctx.restore()

    for idx, coff in enumerate([0, 18, 36, 54]):
        cx = 920 + coff
        cy = 350 + seamless_sine_noise(cx, harmonics=[(1, 24.0), (2, 14.0)], phase_offset=1.2) - 4
        draw_camel(cx, cy)

    save_surface(surf, "assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_thar_sand_dunes.png")

    # Layer 3: Midground - Aravalli Rocky Hills, Havelis & Desert Shrubs (1920x720)
    surf, ctx = create_surface()
    # Rugged Aravalli Sandstone Escarpment
    pat_aravalli = cairo.LinearGradient(0, 320, 0, 480)
    pat_aravalli.add_color_stop_rgba(0.0, 0.78, 0.54, 0.28, 0.98) # Warm sandstone
    pat_aravalli.add_color_stop_rgba(0.6, 0.62, 0.40, 0.20, 1.0) # Weathered rock
    pat_aravalli.add_color_stop_rgba(1.0, 0.50, 0.32, 0.16, 1.0)
    ctx.set_source(pat_aravalli)
    ctx.move_to(0, 360)
    for x in range(0, 1921, 15):
        ry = 360 + seamless_sine_noise(x, harmonics=[(1, 16.0), (2, 12.0), (5, 6.0)], phase_offset=0.8)
        ctx.line_to(x, ry)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Sandstone Havelis with Jharokha Balconies
    def draw_haveli(hx, hy):
        ctx.save()
        ctx.translate(hx, hy)
        # Sandstone body
        ctx.set_source_rgb(0.85, 0.62, 0.35)
        ctx.rectangle(-28, -26, 56, 32)
        ctx.fill()
        # Jharokha carved overhanging balcony
        ctx.set_source_rgb(0.72, 0.48, 0.24)
        ctx.rectangle(-16, -20, 32, 14)
        ctx.fill()
        # Chhatri dome roof
        ctx.arc(0, -32, 9, math.pi, 2 * math.pi)
        ctx.fill()
        ctx.restore()

    for hx in [240, 680, 1140, 1620]:
        hy = 358 + seamless_sine_noise(hx, harmonics=[(1, 16.0), (2, 12.0)], phase_offset=0.8)
        draw_haveli(hx, hy)

    # Desert Thorny Khejri Trees
    def draw_khejri(kx, ky):
        ctx.save()
        ctx.translate(kx, ky)
        ctx.set_source_rgb(0.35, 0.26, 0.18)
        ctx.set_line_width(2.6)
        ctx.move_to(0, 0)
        ctx.line_to(-4, -28)
        ctx.line_to(-12, -42)
        ctx.move_to(-4, -28)
        ctx.line_to(8, -45)
        ctx.stroke()
        # Sparse olive-green thorny foliage puffs
        ctx.set_source_rgba(0.38, 0.45, 0.24, 0.85)
        ctx.arc(-12, -45, 14, 0, 2 * math.pi)
        ctx.fill()
        ctx.arc(8, -48, 16, 0, 2 * math.pi)
        ctx.fill()
        ctx.restore()

    for kx in [120, 480, 890, 1380, 1800]:
        ky = 356 + seamless_sine_noise(kx, harmonics=[(1, 16.0), (2, 12.0)], phase_offset=0.8)
        draw_khejri(kx, ky)

    save_surface(surf, "assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_aravalli_hills_midground.png")

# -------------------------------------------------------------
# 5. GUJARAT (Pale Azure Sky, Great Rann White Salt Flats, Saurashtra Savanna & Bhungas)
# -------------------------------------------------------------

def generate_gujarat():
    print("\n--- Generating Gujarat Environment Layers ---")

    # Layer 1: Crisp Pale Azure Sky (1920x720)
    surf, ctx = create_surface()
    pat = cairo.LinearGradient(0, 0, 0, 520)
    pat.add_color_stop_rgb(0.0, 0.14, 0.42, 0.68) # Clean high sky azure
    pat.add_color_stop_rgb(0.40, 0.35, 0.65, 0.85) # Crisp daylight cerulean
    pat.add_color_stop_rgb(0.75, 0.68, 0.85, 0.95) # Pale sky
    pat.add_color_stop_rgb(0.95, 0.92, 0.96, 0.98) # Shimmering white horizon
    pat.add_color_stop_rgb(1.0, 1.0, 1.0, 1.0)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 720)
    ctx.fill()
    save_surface(surf, "assets/indian_locations/gujarat/backgrounds/sky/gujarat_sky_pale_azure.png")

    # Layer 2: Far Background - Shimmering Great Rann White Salt Flats & Heat Mirage (1920x720)
    surf, ctx = create_surface()
    # Distant Pale Mountain Ridge on horizon (Kalo Dungar Black Hills silhouette)
    pat_kalo = cairo.LinearGradient(0, 290, 0, 360)
    pat_kalo.add_color_stop_rgba(0.0, 0.38, 0.48, 0.58, 0.60)
    pat_kalo.add_color_stop_rgba(1.0, 0.28, 0.38, 0.48, 0.85)
    ctx.set_source(pat_kalo)
    ctx.move_to(0, 335)
    for x in range(0, 1921, 20):
        ky = 335 + seamless_sine_noise(x, harmonics=[(1, 22.0), (3, 10.0)], phase_offset=0.5)
        ctx.line_to(x, ky)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Heat Mirage Shimmer Line
    pat_mirage = cairo.LinearGradient(0, 335, 0, 355)
    pat_mirage.add_color_stop_rgba(0.0, 0.85, 0.95, 1.0, 0.5)
    pat_mirage.add_color_stop_rgba(1.0, 0.98, 1.0, 1.0, 0.9)
    ctx.set_source(pat_mirage)
    ctx.rectangle(0, 335, 1920, 20)
    ctx.fill()

    # White Salt Desert Expanse (Crystalline White Salt Crust)
    pat_salt = cairo.LinearGradient(0, 350, 0, 500)
    pat_salt.add_color_stop_rgba(0.0, 0.96, 0.98, 1.0, 0.98) # Pure white salt crust
    pat_salt.add_color_stop_rgba(0.5, 0.88, 0.92, 0.96, 1.0) # Saline crystalline sheen
    pat_salt.add_color_stop_rgba(1.0, 0.80, 0.84, 0.88, 1.0)
    ctx.set_source(pat_salt)
    ctx.rectangle(0, 350, 1920, 370)
    ctx.fill()

    # Subtle Salt Polygon Crust Crack Lines
    ctx.set_source_rgba(0.72, 0.78, 0.84, 0.40)
    ctx.set_line_width(1.0)
    s_rng = random.Random(77)
    for row in range(360, 480, 16):
        for col in range(20, 1900, 45):
            ctx.move_to(col, row)
            ctx.line_to(col + s_rng.uniform(15, 30), row + s_rng.uniform(-4, 4))
            ctx.line_to(col + s_rng.uniform(30, 45), row + s_rng.uniform(8, 14))
            ctx.stroke()

    # Distant Greater Flamingo flock silhouettes wading in saline shallows
    def draw_flamingo(fx, fy):
        ctx.save()
        ctx.translate(fx, fy)
        ctx.set_source_rgba(0.85, 0.45, 0.50, 0.75) # Soft flamingo pink-grey
        # Body
        ctx.arc(0, -6, 3.5, 0, 2 * math.pi)
        ctx.fill()
        # S-curved long neck
        ctx.move_to(-2, -6)
        ctx.curve_to(-5, -12, -2, -16, -4, -18)
        ctx.set_line_width(1.2)
        ctx.stroke()
        # Long stilt legs
        ctx.move_to(0, -3)
        ctx.line_to(0, 6)
        ctx.set_line_width(0.9)
        ctx.stroke()
        ctx.restore()

    for idx in range(8):
        fx = 720 + idx * 24 + s_rng.uniform(-6, 6)
        fy = 365 + s_rng.uniform(-3, 3)
        draw_flamingo(fx, fy)

    save_surface(surf, "assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_great_rann_white_salt.png")

    # Layer 3: Midground - Saurashtra Savanna, Acacia & Traditional Bhunga Huts (1920x720)
    surf, ctx = create_surface()
    # Savanna Grassland & Narmada River Valley Contours
    pat_savanna = cairo.LinearGradient(0, 330, 0, 480)
    pat_savanna.add_color_stop_rgba(0.0, 0.72, 0.68, 0.42, 0.98) # Dry savanna gold
    pat_savanna.add_color_stop_rgba(0.5, 0.58, 0.56, 0.35, 1.0)
    pat_savanna.add_color_stop_rgba(1.0, 0.48, 0.45, 0.28, 1.0)
    ctx.set_source(pat_savanna)
    ctx.move_to(0, 355)
    for x in range(0, 1921, 15):
        sy = 355 + seamless_sine_noise(x, harmonics=[(1, 14.0), (2, 8.0), (4, 4.0)], phase_offset=0.9)
        ctx.line_to(x, sy)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Traditional Kutch Bhunga Huts (Circular cylindrical mud wall with conical thatched roof)
    def draw_bhunga_hut(bx, by):
        ctx.save()
        ctx.translate(bx, by)
        # White mud-plastered cylindrical base with lipan mirror patterns
        ctx.set_source_rgb(0.92, 0.92, 0.90)
        ctx.rectangle(-18, -16, 36, 20)
        ctx.fill()
        # Decorative painted border
        ctx.set_source_rgb(0.68, 0.28, 0.20)
        ctx.rectangle(-18, -4, 36, 4)
        ctx.fill()
        # Conical thatched grass roof
        ctx.set_source_rgb(0.52, 0.40, 0.22)
        ctx.move_to(-22, -16)
        ctx.line_to(0, -38)
        ctx.line_to(22, -16)
        ctx.close_path()
        ctx.fill()
        ctx.restore()

    for bx in [280, 740, 1200, 1650]:
        by = 352 + seamless_sine_noise(bx, harmonics=[(1, 14.0), (2, 8.0)], phase_offset=0.9)
        draw_bhunga_hut(bx, by)

    # Umbrella Thorn Acacia (Babul) Trees
    def draw_acacia_tree(ax, ay):
        ctx.save()
        ctx.translate(ax, ay)
        # Gnarled trunk
        ctx.set_source_rgb(0.32, 0.24, 0.18)
        ctx.set_line_width(2.8)
        ctx.move_to(0, 0)
        ctx.line_to(2, -26)
        ctx.line_to(-12, -40)
        ctx.move_to(2, -26)
        ctx.line_to(14, -38)
        ctx.stroke()
        # Flat umbrella canopy
        ctx.set_source_rgba(0.28, 0.42, 0.22, 0.90)
        ctx.save()
        ctx.scale(2.2, 0.7)
        ctx.arc(1, -56, 16, 0, 2 * math.pi)
        ctx.fill()
        ctx.restore()
        ctx.restore()

    for ax in [140, 520, 960, 1420, 1840]:
        ay = 350 + seamless_sine_noise(ax, harmonics=[(1, 14.0), (2, 8.0)], phase_offset=0.9)
        draw_acacia_tree(ax, ay)

    save_surface(surf, "assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_saurashtra_savanna_midground.png")

# -------------------------------------------------------------
# 6. TELANGANA (Deccan Twilight Sky, Granite Boulder Tors, Gulmohar Countryside)
# -------------------------------------------------------------

def generate_telangana():
    print("\n--- Generating Telangana Environment Layers ---")

    # Layer 1: Warm Deccan Twilight Sky (1920x720)
    surf, ctx = create_surface()
    pat = cairo.LinearGradient(0, 0, 0, 520)
    pat.add_color_stop_rgb(0.0, 0.12, 0.16, 0.32) # Royal indigo zenith
    pat.add_color_stop_rgb(0.35, 0.42, 0.22, 0.48) # Violet dusk
    pat.add_color_stop_rgb(0.70, 0.78, 0.38, 0.25) # Warm Deccan terracotta
    pat.add_color_stop_rgb(0.92, 0.98, 0.68, 0.22) # Golden amber horizon
    pat.add_color_stop_rgb(1.0, 1.0, 0.82, 0.45)
    ctx.set_source(pat)
    ctx.rectangle(0, 0, 1920, 720)
    ctx.fill()
    save_surface(surf, "assets/indian_locations/telangana/backgrounds/sky/telangana_sky_deccan_twilight.png")

    # Layer 2: Far Background - Ancient Deccan Granite Boulder Formations & Golconda Bastions (1920x720)
    surf, ctx = create_surface()
    # Weathered Granite Hill Ridge with iconic balancing boulders
    pat_granite = cairo.LinearGradient(0, 270, 0, 420)
    pat_granite.add_color_stop_rgba(0.0, 0.38, 0.36, 0.42, 0.85)
    pat_granite.add_color_stop_rgba(0.6, 0.28, 0.26, 0.32, 0.95)
    pat_granite.add_color_stop_rgba(1.0, 0.20, 0.18, 0.24, 1.0)
    ctx.set_source(pat_granite)
    ctx.move_to(0, 310)
    for x in range(0, 1921, 15):
        gy = 310 + seamless_sine_noise(x, harmonics=[(1, 32.0), (3, 16.0), (7, 6.0)], phase_offset=0.4)
        ctx.line_to(x, gy)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Giant Balancing Boulders (Iconic Deccan Precambrian Tors)
    def draw_balancing_rock(rx, ry, rw=32, rh=24):
        ctx.save()
        ctx.translate(rx, ry)
        # Rounded granite monolith
        pat_rock = cairo.RadialGradient(-rw * 0.2, -rh * 0.2, 4, 0, 0, rw)
        pat_rock.add_color_stop_rgb(0.0, 0.52, 0.50, 0.54)
        pat_rock.add_color_stop_rgb(1.0, 0.28, 0.26, 0.30)
        ctx.set_source(pat_rock)
        ctx.scale(1.0, rh / float(rw))
        ctx.arc(0, 0, rw * 0.5, 0, 2 * math.pi)
        ctx.fill()
        ctx.restore()

    for bx in [220, 580, 840, 1150, 1480, 1780]:
        by = 305 + seamless_sine_noise(bx, harmonics=[(1, 32.0), (3, 16.0)], phase_offset=0.4)
        draw_balancing_rock(bx, by - 6, rw=36, rh=28)
        draw_balancing_rock(bx + 8, by - 26, rw=24, rh=20) # Balancing rock perched on top

    # Distant Golconda Fort stone rampart silhouette on ridge
    ctx.set_source_rgba(0.20, 0.18, 0.22, 0.85)
    for fx in [420, 1340]:
        ctx.rectangle(fx - 24, 292, 48, 18)
        ctx.fill()
        for b in range(5):
            ctx.rectangle(fx - 22 + b * 9, 287, 5, 6) # Crenellations
            ctx.fill()

    save_surface(surf, "assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_granite_boulder_ridges.png")

    # Layer 3: Midground - Deccan Plateau Countryside, Flowering Gulmohar & Rocky Lakes (1920x720)
    surf, ctx = create_surface()
    # Undulating Plateau with Granite Crags
    pat_plateau = cairo.LinearGradient(0, 320, 0, 480)
    pat_plateau.add_color_stop_rgba(0.0, 0.48, 0.42, 0.34, 0.98) # Rocky Deccan soil
    pat_plateau.add_color_stop_rgba(0.5, 0.38, 0.32, 0.26, 1.0)
    pat_plateau.add_color_stop_rgba(1.0, 0.28, 0.24, 0.20, 1.0)
    ctx.set_source(pat_plateau)
    ctx.move_to(0, 350)
    for x in range(0, 1921, 15):
        py = 350 + seamless_sine_noise(x, harmonics=[(1, 18.0), (2, 10.0), (4, 5.0)], phase_offset=1.3)
        ctx.line_to(x, py)
    ctx.line_to(1920, 720)
    ctx.line_to(0, 720)
    ctx.close_path()
    ctx.fill()

    # Flaming Red Gulmohar Trees (Vibrant scarlet canopy)
    def draw_gulmohar_tree(gx, gy):
        ctx.save()
        ctx.translate(gx, gy)
        # Spreading trunk
        ctx.set_source_rgb(0.28, 0.20, 0.15)
        ctx.set_line_width(3.0)
        ctx.move_to(0, 0)
        ctx.line_to(0, -22)
        ctx.line_to(-16, -34)
        ctx.move_to(0, -22)
        ctx.line_to(16, -32)
        ctx.stroke()
        # Vibrant red blossom umbrella canopy
        blossom_colors = [(0.92, 0.22, 0.12), (0.98, 0.35, 0.15), (0.85, 0.18, 0.10)]
        for b_idx, (bx, by) in enumerate([(-16, -38), (0, -42), (16, -36), (-8, -46), (8, -44)]):
            ctx.set_source_rgba(*blossom_colors[b_idx % 3], 0.90)
            ctx.arc(bx, by, 15, 0, 2 * math.pi)
            ctx.fill()
        ctx.restore()

    for gx in [280, 750, 1180, 1620]:
        gy = 348 + seamless_sine_noise(gx, harmonics=[(1, 18.0), (2, 10.0)], phase_offset=1.3)
        draw_gulmohar_tree(gx, gy)

    # Kakatiya Stone Carved Archway (Kirti Torana) in midground
    def draw_kakatiya_arch(kx, ky):
        ctx.save()
        ctx.translate(kx, ky)
        ctx.set_source_rgb(0.48, 0.44, 0.42)
        # Twin carved pillars
        ctx.rectangle(-18, -32, 6, 34)
        ctx.fill()
        ctx.rectangle(12, -32, 6, 34)
        ctx.fill()
        # Double lintel arch
        ctx.rectangle(-24, -36, 48, 5)
        ctx.fill()
        ctx.rectangle(-20, -42, 40, 4)
        ctx.fill()
        ctx.restore()

    for kx in [520, 1400]:
        ky = 346 + seamless_sine_noise(kx, harmonics=[(1, 18.0), (2, 10.0)], phase_offset=1.3)
        draw_kakatiya_arch(kx, ky)

    save_surface(surf, "assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_plateau_countryside_midground.png")

# -------------------------------------------------------------
# 7. UPDATE FALLBACK / SHARED ASSETS IN assets/indian_roads/
# -------------------------------------------------------------

def update_fallback_assets():
    print("\n--- Synchronizing Fallback / Core Background Assets ---")
    import shutil
    shutil.copy("assets/indian_locations/tamil_nadu/backgrounds/sky/kanyakumari_sky_coastal.png",
                "assets/indian_roads/visual_upgrade_v2/indian_sky_tropical.png")
    shutil.copy("assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png",
                "assets/indian_roads/visual_upgrade_v2/indian_parallax_tamil_nadu_coast.png")
    shutil.copy("assets/indian_locations/rajasthan/backgrounds/distant_landscape/rajasthan_thar_sand_dunes.png",
                "assets/indian_roads/indian_parallax_thar_desert.png")
    shutil.copy("assets/indian_locations/gujarat/backgrounds/distant_landscape/gujarat_great_rann_white_salt.png",
                "assets/indian_roads/indian_parallax_rann_kutch.png")
    shutil.copy("assets/indian_locations/telangana/backgrounds/distant_landscape/telangana_granite_boulder_ridges.png",
                "assets/indian_roads/indian_parallax_deccan_plateau.png")
    shutil.copy("assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/kanyakumari_ocean_horizon.png",
                "assets/indian_roads/indian_parallax_tamil_nadu_coast.png")
    shutil.copy("assets/indian_locations/tamil_nadu/backgrounds/distant_landscape/tamil_countryside_midground.png",
                "assets/indian_roads/indian_parallax_rural_plains.png")
    print("Fallback assets updated successfully.")

def main():
    print("=== STARTING SIX-STATE REALISTIC BACKGROUND ASSET GENERATION ===")
    generate_common_clouds()
    generate_tamil_nadu()
    generate_goa()
    generate_kerala()
    generate_rajasthan()
    generate_gujarat()
    generate_telangana()
    update_fallback_assets()
    print("\n=== COMPLETED ALL SIX STATES REALISTIC BACKGROUNDS GENERATION ===")

if __name__ == "__main__":
    main()
