#!/usr/bin/env python3
"""
Generate high-craft 2D vector-illustration assets for the Goa map overhaul.
Art style matches Goa_2D_Assets/: bold dark-brown outlines (#3a2315),
warm laterite/terracotta/gold/teal/emerald palette, crisp shading, seamless
horizontal wrapping on all parallax layers.
"""

import math
import os
import random
import cairo

OUT_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "assets", "indian_locations", "goa", "v3"
)

OUTLINE = (0.227, 0.137, 0.082, 1.0)  # #3a2315


def ensure_dirs():
    for sub in ["", "parallax", "props", "foreground"]:
        os.makedirs(os.path.join(OUT_DIR, sub), exist_ok=True)


def hex_rgba(h, a=1.0):
    h = h.lstrip("#")
    return (int(h[0:2], 16) / 255.0, int(h[2:4], 16) / 255.0, int(h[4:6], 16) / 255.0, a)


def new_surf(w, h):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surf)
    ctx.set_antialias(cairo.ANTIALIAS_BEST)
    return surf, ctx


def save_surf(surf, rel_path):
    p = os.path.join(OUT_DIR, rel_path)
    surf.write_to_png(p)
    print("Generated:", rel_path)


def stroke_fill(ctx, fill_col, stroke_col=OUTLINE, lw=3.0):
    ctx.set_source_rgba(*fill_col)
    ctx.fill_preserve()
    ctx.set_source_rgba(*stroke_col)
    ctx.set_line_width(lw)
    ctx.set_line_join(cairo.LINE_JOIN_ROUND)
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    ctx.stroke()


def quad_to(ctx, cx, cy, ex, ey):
    x0, y0 = ctx.get_current_point()
    ctx.curve_to(x0 + 2.0/3.0*(cx - x0), y0 + 2.0/3.0*(cy - y0),
                 ex + 2.0/3.0*(cx - ex), ey + 2.0/3.0*(cy - ey),
                 ex, ey)

def draw_rounded_rect(ctx, x, y, w, h, r):
    r = min(r, w * 0.5, h * 0.5)
    ctx.new_sub_path()
    ctx.arc(x + w - r, y + r, r, -math.pi / 2, 0)
    ctx.arc(x + w - r, y + h - r, r, 0, math.pi / 2)
    ctx.arc(x + r, y + h - r, r, math.pi / 2, math.pi)
    ctx.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2)
    ctx.close_path()


# =====================================================================
# 1. SKY & NATURAL CLOUDS
# =====================================================================

def gen_sky():
    w, h = 1920, 720
    surf, ctx = new_surf(w, h)
    grad = cairo.LinearGradient(0, 0, 0, h)
    grad.add_color_stop_rgba(0.00, *hex_rgba("#167ad1"))
    grad.add_color_stop_rgba(0.24, *hex_rgba("#38a8f0"))
    grad.add_color_stop_rgba(0.50, *hex_rgba("#8ee0fb"))
    grad.add_color_stop_rgba(0.65, *hex_rgba("#daf6ff"))
    grad.add_color_stop_rgba(0.75, *hex_rgba("#f4f6e4"))
    grad.add_color_stop_rgba(1.00, *hex_rgba("#dfedd6"))
    ctx.set_source(grad)
    ctx.rectangle(0, 0, w, h)
    ctx.fill()

    # Warm tropical sun below TopBar HUD (y=150)
    sx, sy = 420, 152
    for rad, col in [
        (135, (1.0, 0.96, 0.78, 0.14)),
        (90, (1.0, 0.95, 0.72, 0.25)),
        (56, (1.0, 0.96, 0.80, 0.55)),
        (36, (1.0, 0.98, 0.88, 0.96)),
    ]:
        ctx.set_source_rgba(*col)
        ctx.arc(sx, sy, rad, 0, math.tau)
        ctx.fill()

    # Subtle distant seabirds (clean dark-teal arcs)
    ctx.set_source_rgba(*hex_rgba("#275d7d", 0.55))
    ctx.set_line_width(2.2)
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    for bx, by, bs in [(920, 140, 12), (955, 128, 9), (985, 148, 10), (1460, 155, 11), (1492, 144, 8)]:
        ctx.move_to(bx - bs, by + bs * 0.25)
        ctx.curve_to(bx - bs * 0.4, by - bs * 0.35, bx - bs * 0.1, by - bs * 0.1, bx, by + bs * 0.15)
        ctx.curve_to(bx + bs * 0.1, by - bs * 0.1, bx + bs * 0.4, by - bs * 0.35, bx + bs, by + bs * 0.25)
        ctx.stroke()

    save_surf(surf, "parallax/sky_goa_tropical.png")


def draw_vector_cloud(ctx, cx, cy, scale, alpha=0.95):
    puffs = [
        (-58 * scale, 10 * scale, 26 * scale),
        (-30 * scale, -6 * scale, 34 * scale),
        (8 * scale, -14 * scale, 40 * scale),
        (46 * scale, -2 * scale, 30 * scale),
        (72 * scale, 12 * scale, 22 * scale),
    ]
    base_y = cy + 20 * scale
    # Soft sky-blue belly shadow
    ctx.set_source_rgba(0.83, 0.93, 1.0, alpha)
    for px, py, r in puffs:
        ctx.arc(cx + px, cy + py + 4 * scale, r, 0, math.tau)
    ctx.rectangle(cx - 58 * scale, cy + 4 * scale, 130 * scale, 20 * scale)
    ctx.fill()

    # Crisp white upper puffs
    ctx.set_source_rgba(1.0, 1.0, 1.0, alpha)
    for px, py, r in puffs:
        ctx.arc(cx + px, cy + py - 1 * scale, r * 0.95, 0, math.tau)
    draw_rounded_rect(ctx, cx - 64 * scale, base_y - 16 * scale, 140 * scale, 18 * scale, 9 * scale)
    ctx.fill()


def gen_clouds():
    w, h = 1920, 230
    surf, ctx = new_surf(w, h)
    # Distributed natural clouds (wrap-safe at edges)
    cloud_specs = [
        (180, 75, 0.85, 0.92),
        (470, 132, 0.55, 0.82),
        (760, 68, 1.05, 0.94),
        (1090, 118, 0.65, 0.86),
        (1380, 62, 0.90, 0.92),
        (1690, 126, 0.72, 0.85),
        (1910, 82, 0.60, 0.85),
        (-10, 82, 0.60, 0.85),  # wrap match
    ]
    for cx, cy, sc, al in cloud_specs:
        draw_vector_cloud(ctx, cx, cy, sc, al)

    save_surf(surf, "parallax/clouds_goa_natural.png")


# =====================================================================
# 2. DISTANT ENVIRONMENT HORIZONS (LAYER 2 - SEAMLESS 1920x340)
# =====================================================================

def draw_periodic_ridge(ctx, w, base_y, h_max, amps, freqs, phases, fill_col):
    ctx.move_to(0, h_max)
    steps = 240
    for i in range(steps + 1):
        t = i / steps
        x = t * w
        ang = t * math.tau
        y = base_y
        for a, f, ph in zip(amps, freqs, phases):
            y -= a * math.sin(ang * f + ph)
        ctx.line_to(x, y)
    ctx.line_to(w, h_max)
    ctx.close_path()
    ctx.set_source_rgba(*fill_col)
    ctx.fill()


def draw_arabian_sea(ctx, w, sea_top, sea_bottom, rng):
    grad = cairo.LinearGradient(0, sea_top, 0, sea_bottom)
    grad.add_color_stop_rgba(0.0, *hex_rgba("#1886b8"))
    grad.add_color_stop_rgba(0.45, *hex_rgba("#23a6cf"))
    grad.add_color_stop_rgba(1.0, *hex_rgba("#4ecae3"))
    ctx.set_source(grad)
    ctx.rectangle(0, sea_top, w, sea_bottom - sea_top)
    ctx.fill()

    # Horizon crisp highlight
    ctx.set_source_rgba(0.82, 0.96, 1.0, 0.55)
    ctx.rectangle(0, sea_top, w, 2.0)
    ctx.fill()

    # Shimmering wave dashes (wrap-safe)
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    for _ in range(55):
        wx = rng.uniform(20, w - 60)
        wy = rng.uniform(sea_top + 6, sea_bottom - 8)
        wl = rng.uniform(18, 52)
        ctx.set_source_rgba(0.88, 0.98, 1.0, rng.uniform(0.28, 0.55))
        ctx.set_line_width(rng.uniform(1.5, 2.6))
        ctx.move_to(wx, wy)
        ctx.line_to(wx + wl, wy)
        ctx.stroke()


def draw_distant_sailboat(ctx, x, y, sc=1.0, col_sail="#fff6e0", col_hull="#8c4327"):
    ctx.save()
    ctx.translate(x, y)
    ctx.scale(sc, sc)
    # Hull
    ctx.move_to(-16, 0)
    ctx.line_to(16, 0)
    ctx.line_to(11, 7)
    ctx.line_to(-12, 7)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba(col_hull))
    ctx.fill()
    # Mast
    ctx.set_source_rgba(*hex_rgba("#4a2918"))
    ctx.set_line_width(1.6)
    ctx.move_to(0, 0)
    ctx.line_to(0, -24)
    ctx.stroke()
    # Main sail
    ctx.move_to(1, -22)
    ctx.line_to(13, -4)
    ctx.line_to(1, -3)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba(col_sail))
    ctx.fill()
    # Jib
    ctx.move_to(-1, -18)
    ctx.line_to(-10, -3)
    ctx.line_to(-1, -3)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba("#ffe09c"))
    ctx.fill()
    ctx.restore()


def gen_distant_horizons():
    w, h = 1920, 440
    rng = random.Random(2026)

    # A. North Goa: Western Ghats coastal headlands + Arabian Sea + sailboats
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 205, 275, [34, 18, 10], [1, 2, 4], [0.2, 1.1, 0.5], hex_rgba("#52939c", 0.72))
    draw_periodic_ridge(ctx, w, 232, 275, [24, 15, 8], [2, 3, 5], [1.4, 0.3, 2.1], hex_rgba("#38786e", 0.90))
    draw_arabian_sea(ctx, w, 260, h, rng)
    # Rocky coastal headland jutting from left-center
    ctx.move_to(380, 262)
    ctx.curve_to(450, 222, 560, 218, 645, 250)
    ctx.line_to(690, 265)
    ctx.line_to(350, 265)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba("#336e53"))
    ctx.fill()
    for bx, by, bs in [(240, 276, 1.0), (1080, 272, 0.85), (1560, 278, 1.1)]:
        draw_distant_sailboat(ctx, bx, by, bs)
    save_surf(surf, "parallax/dist_north_goa.png")

    # B. Central Goa: Mandovi hills + distant Panaji/Old Goa spires + Mandovi estuary
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 198, 285, [30, 16, 9], [1, 3, 5], [0.6, 2.0, 0.9], hex_rgba("#569693", 0.72))
    draw_periodic_ridge(ctx, w, 228, 285, [22, 12, 7], [2, 4, 6], [2.2, 0.7, 1.5], hex_rgba("#3b7d5d", 0.92))
    # Distant hazy white heritage spires on far river bank
    for tx in [410, 980, 1490]:
        ctx.set_source_rgba(*hex_rgba("#f5efe2", 0.80))
        ctx.rectangle(tx - 16, 236, 32, 26)
        ctx.fill()
        ctx.move_to(tx - 10, 236)
        ctx.line_to(tx, 212)
        ctx.line_to(tx + 10, 236)
        ctx.close_path()
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#c95a38", 0.78))
        ctx.rectangle(tx + 16, 244, 24, 18)
        ctx.fill()
    draw_arabian_sea(ctx, w, 262, h, rng)
    draw_distant_sailboat(ctx, 680, 280, 0.9, "#fff8e8", "#5c3924")
    draw_distant_sailboat(ctx, 1280, 276, 0.8, "#ffe7b5", "#7a3b28")
    save_surf(surf, "parallax/dist_central_goa.png")

    # C. East Goa: Multi-layered Western Ghats mountain ridges (no sea)
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 140, h, [52, 28, 12], [1, 2, 4], [0.4, 1.8, 0.2], hex_rgba("#5c989e", 0.78))
    # Subtle misty valley band
    mist = cairo.LinearGradient(0, 140, 0, 220)
    mist.add_color_stop_rgba(0.0, 0.85, 0.95, 0.97, 0.0)
    mist.add_color_stop_rgba(0.6, 0.85, 0.95, 0.97, 0.26)
    mist.add_color_stop_rgba(1.0, 0.85, 0.95, 0.97, 0.0)
    ctx.set_source(mist)
    ctx.rectangle(0, 140, w, 80)
    ctx.fill()
    draw_periodic_ridge(ctx, w, 195, h, [42, 22, 11], [2, 3, 5], [1.2, 0.4, 2.3], hex_rgba("#3b7a62", 0.92))
    draw_periodic_ridge(ctx, w, 242, h, [28, 16, 8], [1, 3, 6], [2.4, 1.5, 0.7], hex_rgba("#2b6647", 0.98))
    save_surf(surf, "parallax/dist_east_goa.png")

    # D. South Goa: Dramatic coastal laterite cliffs + crescent Arabian Sea bay
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 208, 270, [30, 16, 8], [1, 2, 4], [1.0, 0.5, 2.1], hex_rgba("#4c8c85", 0.75))
    draw_arabian_sea(ctx, w, 252, h, rng)
    # Laterite cliff headland on right & left (wraps smoothly)
    for cx_off in [0, w]:
        ctx.move_to(cx_off - 160, 272)
        ctx.line_to(cx_off - 120, 212)
        ctx.curve_to(cx_off, 198, cx_off + 110, 206, cx_off + 170, 265)
        ctx.close_path()
        ctx.set_source_rgba(*hex_rgba("#9c563c"))
        ctx.fill()
        ctx.move_to(cx_off - 126, 214)
        ctx.curve_to(cx_off, 196, cx_off + 95, 204, cx_off + 148, 232)
        ctx.curve_to(cx_off + 60, 224, cx_off - 40, 225, cx_off - 126, 214)
        ctx.set_source_rgba(*hex_rgba("#38784c"))
        ctx.fill()
    # Mid bay cliff island
    ctx.move_to(920, 256)
    ctx.curve_to(975, 216, 1080, 216, 1135, 256)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba("#346f53"))
    ctx.fill()
    for bx, by, bs in [(520, 276, 1.05), (1440, 270, 0.9)]:
        draw_distant_sailboat(ctx, bx, by, bs)
    save_surf(surf, "parallax/dist_south_goa.png")


# =====================================================================
# 3. MAIN SCENERY MIDGROUND (LAYER 3 - SEAMLESS 1920x280)
# =====================================================================

def draw_mid_palm(ctx, bx, by, height, lean_x, frond_col="#398a49", trunk_col="#7c5234"):
    tx = bx + lean_x
    ty = by - height
    cx = bx + lean_x * 0.35
    cy = by - height * 0.55

    # Tapered curved trunk
    ctx.move_to(bx - 6, by)
    quad_to(ctx, cx - 4, cy, tx - 2.5, ty)
    ctx.line_to(tx + 2.5, ty)
    quad_to(ctx, cx + 4, cy, bx + 6, by)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba(trunk_col))
    ctx.fill()

    # Lush drooping frond clusters (curved leaves, NOT straight sticks)
    angles = [-2.6, -2.05, -1.35, -0.55, 0.15, 0.72, -3.05]
    for a in angles:
        fl = height * 0.34
        ex = tx + math.cos(a) * fl
        ey = ty + math.sin(a) * fl + fl * 0.32
        mx = tx + math.cos(a) * fl * 0.52
        my = ty + math.sin(a) * fl * 0.42 - 8
        ctx.move_to(tx, ty)
        quad_to(ctx, mx, my - 7, ex, ey)
        quad_to(ctx, mx, my + 5, tx, ty)
        ctx.close_path()
        ctx.set_source_rgba(*hex_rgba(frond_col))
        ctx.fill()


def draw_mid_tree(ctx, bx, by, r, col_dark="#2b6b3c", col_light="#42914d"):
    ctx.set_source_rgba(*hex_rgba("#6b442b"))
    ctx.rectangle(bx - r * 0.14, by - r * 0.9, r * 0.28, r * 0.9)
    ctx.fill()

    for dx, dy, rr, c in [
        (-r * 0.55, -r * 0.95, r * 0.62, col_dark),
        (r * 0.55, -r * 0.92, r * 0.58, col_dark),
        (0, -r * 1.25, r * 0.72, col_light),
        (-r * 0.28, -r * 1.05, r * 0.55, col_light),
        (r * 0.32, -r * 1.02, r * 0.52, col_light),
    ]:
        ctx.set_source_rgba(*hex_rgba(c))
        ctx.arc(bx + dx, by + dy, rr, 0, math.tau)
        ctx.fill()


def draw_mid_portuguese_cottage(ctx, x, ground_y, w, h, wall_col="#f3c644", roof_col="#c94b2b", two_storey=False):
    top_y = ground_y - h
    # Wall
    ctx.set_source_rgba(*hex_rgba(wall_col))
    ctx.rectangle(x, top_y, w, h)
    ctx.fill()
    # White corner pilasters
    ctx.set_source_rgba(*hex_rgba("#f8f3e8"))
    ctx.rectangle(x, top_y, 5, h)
    ctx.rectangle(x + w - 5, top_y, 5, h)
    ctx.fill()
    # Sloped terracotta roof
    ctx.move_to(x - 8, top_y + 2)
    ctx.line_to(x + w * 0.5, top_y - h * 0.36)
    ctx.line_to(x + w + 8, top_y + 2)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba(roof_col))
    ctx.fill()
    # Arched windows / door
    ctx.set_source_rgba(*hex_rgba("#4c2d1b"))
    cols = 3 if two_storey else 2
    for c in range(cols):
        wx = x + (c + 0.5) * (w / cols) - 6
        wy = top_y + h * (0.22 if two_storey else 0.35)
        ctx.rectangle(wx, wy, 12, 16)
        ctx.arc(wx + 6, wy, 6, math.pi, 0)
        ctx.fill()
    if two_storey:
        for c in range(cols):
            wx = x + (c + 0.5) * (w / cols) - 6
            wy = ground_y - 24
            ctx.rectangle(wx, wy, 12, 24)
            ctx.fill()


def gen_midground_strips():
    w, h = 1920, 420
    ground_y = 258

    # A. North Goa: Coastal palms, varied foliage, scattered single/pair Portuguese villas
    surf, ctx = new_surf(w, h)
    # Thin coastal grassy verge behind road so Arabian Sea shines clearly through palms
    draw_periodic_ridge(ctx, w, ground_y - 2, h, [8, 5], [2, 5], [0.3, 1.5], hex_rgba("#3f8548"))
    draw_periodic_ridge(ctx, w, ground_y + 4, h, [5, 3], [3, 6], [1.1, 2.2], hex_rgba("#4d994c"))

    # Scattered varied coastal architecture (NOT 6 repeated houses!)
    draw_mid_portuguese_cottage(ctx, 210, ground_y - 2, 74, 54, "#f4c848", "#c94c2c", True)
    draw_mid_portuguese_cottage(ctx, 294, ground_y - 2, 48, 38, "#6db4e0", "#c94c2c", False)
    draw_mid_portuguese_cottage(ctx, 1140, ground_y - 2, 62, 44, "#f07c65", "#b84327", False)
    draw_mid_portuguese_cottage(ctx, 1640, ground_y - 2, 70, 50, "#f5efe0", "#c94c2c", True)

    # Organic coconut palm groves & lush trees (wrap-safe)
    for tx, th, lean, fc in [
        (75, 165, 22, "#358546"), (115, 138, -16, "#42964f"), (390, 172, 26, "#378a47"),
        (560, 152, -20, "#3f944d"), (720, 180, 18, "#2f7c41"), (760, 132, -14, "#4aa152"),
        (960, 168, 24, "#378a47"), (1260, 155, -22, "#3f944d"), (1430, 176, 20, "#318042"),
        (1780, 160, -18, "#3e924c"), (1860, 142, 16, "#489f52"),
    ]:
        draw_mid_palm(ctx, tx, ground_y, th, lean, fc)

    for tx, tr in [(165, 38), (470, 46), (650, 36), (860, 50), (1055, 42), (1345, 48), (1550, 40), (1735, 36)]:
        draw_mid_tree(ctx, tx, ground_y, tr)

    save_surf(surf, "parallax/mid_north_goa.png")

    # B. Central Goa: Panaji & Old Goa heritage villas, rain trees, church spires
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, ground_y - 10, h, [10, 6], [2, 5], [0.9, 1.9], hex_rgba("#3c7f49"))
    draw_periodic_ridge(ctx, w, ground_y, h, [6, 4], [3, 7], [0.4, 2.5], hex_rgba("#4c944c"))

    villas = [
        (120, 78, 58, "#f2c33d", "#c84928", True),
        (210, 54, 42, "#5ba4cf", "#b94225", False),
        (520, 68, 48, "#e6735a", "#c84928", False),
        (600, 82, 62, "#f6eedc", "#bf4526", True),
        (980, 72, 52, "#62b587", "#c84928", True),
        (1340, 66, 46, "#f2c33d", "#bf4526", False),
        (1420, 80, 56, "#e8826b", "#c84928", True),
        (1710, 58, 44, "#5ba4cf", "#c84928", False),
    ]
    for vx, vw, vh, wc, rc, ts in villas:
        draw_mid_portuguese_cottage(ctx, vx, ground_y, vw, vh, wc, rc, ts)

    for tx, tr in [(60, 44), (340, 56), (430, 42), (760, 58), (880, 45), (1140, 54), (1250, 40), (1570, 52), (1840, 46)]:
        draw_mid_tree(ctx, tx, ground_y, tr, "#286538", "#3f8d48")
    for tx, th, lean in [(290, 155, -18), (700, 168, 22), (1090, 160, 18), (1510, 170, -20), (1790, 150, 16)]:
        draw_mid_palm(ctx, tx, ground_y, th, lean)
    save_surf(surf, "parallax/mid_central_goa.png")

    # C. East Goa: Dense lush Mollem / Western Ghats jungle canopy & rocks
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, ground_y - 36, h, [28, 14, 7], [2, 4, 7], [0.5, 1.4, 2.2], hex_rgba("#29633c"))
    draw_periodic_ridge(ctx, w, ground_y - 14, h, [16, 9], [3, 6], [1.7, 0.3], hex_rgba("#377c46"))
    draw_periodic_ridge(ctx, w, ground_y, h, [8, 4], [4, 8], [0.2, 1.9], hex_rgba("#46924b"))

    for i in range(22):
        tx = 45 + i * 86 + (i % 3) * 12
        tr = 44 + (i % 4) * 11
        draw_mid_tree(ctx, tx, ground_y, tr, "#215734", "#378544" if i % 2 == 0 else "#4a9d4e")
    for tx, th, lean in [(180, 175, 20), (620, 185, -18), (1060, 170, 22), (1490, 180, -20)]:
        draw_mid_palm(ctx, tx, ground_y, th, lean, "#368c44")
    save_surf(surf, "parallax/mid_east_goa.png")

    # D. South Goa: Sweeping coconut plantations, golden beach dunes & fishing boats
    surf, ctx = new_surf(w, h)
    # Low golden coastal sand ridge & lush palm grass so crescent sea bay gleams behind palms
    draw_periodic_ridge(ctx, w, ground_y - 4, h, [7, 4], [2, 5], [0.2, 1.8], hex_rgba("#dfc07e"))
    draw_periodic_ridge(ctx, w, ground_y + 4, h, [5, 3], [3, 6], [1.2, 0.5], hex_rgba("#4a964c"))
    for i in range(18):
        tx = 50 + i * 105 + (i % 3) * 14
        th = 135 + (i % 4) * 18
        lean = 22 if i % 2 == 0 else -19
        draw_mid_palm(ctx, tx, ground_y, th, lean, "#388d48" if i % 2 == 0 else "#479f51")
    for tx, tr in [(160, 38), (580, 42), (990, 40), (1410, 44), (1810, 38)]:
        draw_mid_tree(ctx, tx, ground_y, tr)
    save_surf(surf, "parallax/mid_south_goa.png")


# =====================================================================
# 4. ROADSIDE VECTOR PROPS, HOUSES, TREES & LANDMARKS (OUTLINED STYLE)
# =====================================================================

def draw_roof_tiles(ctx, x1, y1, x2, y2, x_peak, y_peak, col_roof="#c44729", col_shade="#a23820"):
    ctx.move_to(x1, y1)
    ctx.line_to(x_peak, y_peak)
    ctx.line_to(x2, y2)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba(col_roof), OUTLINE, 3.2)

    # Subtle tile ridge ribs
    ctx.set_source_rgba(*hex_rgba(col_shade, 0.55))
    ctx.set_line_width(2.0)
    for k in range(1, 7):
        t = k / 7.0
        bx = x1 + (x2 - x1) * t
        by = y1 + (y2 - y1) * t
        ctx.move_to(x_peak, y_peak)
        ctx.line_to(bx, by)
        ctx.stroke()

    # Re-stroke roof outline cleanly
    ctx.move_to(x1, y1)
    ctx.line_to(x_peak, y_peak)
    ctx.line_to(x2, y2)
    ctx.close_path()
    ctx.set_source_rgba(*OUTLINE)
    ctx.set_line_width(3.2)
    ctx.stroke()


def draw_arched_window(ctx, cx, cy, w, h, shutter_col="#2b6e5f"):
    # White frame
    draw_rounded_rect(ctx, cx - w * 0.5 - 3, cy - h * 0.5 - 3, w + 6, h + 6, 4)
    stroke_fill(ctx, hex_rgba("#faf4e8"), OUTLINE, 2.2)
    # Dark interior + panes
    ctx.rectangle(cx - w * 0.5, cy - h * 0.5 + w * 0.35, w, h - w * 0.35)
    ctx.arc(cx, cy - h * 0.5 + w * 0.35, w * 0.5, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#2f4654"), OUTLINE, 2.0)
    # Shutters
    sw = w * 0.32
    ctx.rectangle(cx - w * 0.5 - sw - 2, cy - h * 0.45, sw, h * 0.9)
    stroke_fill(ctx, hex_rgba(shutter_col), OUTLINE, 1.8)
    ctx.rectangle(cx + w * 0.5 + 2, cy - h * 0.45, sw, h * 0.9)
    stroke_fill(ctx, hex_rgba(shutter_col), OUTLINE, 1.8)


def gen_portuguese_houses():
    # 1. Ochre 2-storey Fontainhas Villa
    w, h = 380, 290
    surf, ctx = new_surf(w, h)
    # Base plinth
    ctx.rectangle(26, 260, 328, 22)
    stroke_fill(ctx, hex_rgba("#a85234"), OUTLINE, 3.0)
    # Main wall
    ctx.rectangle(36, 94, 308, 166)
    stroke_fill(ctx, hex_rgba("#f0be38"), OUTLINE, 3.2)
    # White pilasters & belt course
    for px in [36, 128, 240, 332]:
        ctx.rectangle(px, 94, 12, 166)
        stroke_fill(ctx, hex_rgba("#f8f2e4"), OUTLINE, 2.2)
    ctx.rectangle(36, 174, 308, 10)
    stroke_fill(ctx, hex_rgba("#f8f2e4"), OUTLINE, 2.2)
    # Roof
    draw_roof_tiles(ctx, 18, 96, 362, 96, 190, 22, "#c84a2a", "#96331b")
    # Upper arched windows
    draw_arched_window(ctx, 86, 134, 24, 38, "#297466")
    draw_arched_window(ctx, 190, 134, 24, 38, "#297466")
    draw_arched_window(ctx, 294, 134, 24, 38, "#297466")
    # Wrought iron balcony
    ctx.rectangle(150, 152, 80, 24)
    stroke_fill(ctx, hex_rgba("#2c3842", 0.25), OUTLINE, 2.4)
    for bx in range(158, 226, 10):
        ctx.move_to(bx, 152)
        ctx.line_to(bx, 176)
        ctx.stroke()
    # Lower arched door & windows
    draw_arched_window(ctx, 86, 218, 24, 38, "#297466")
    draw_arched_window(ctx, 294, 218, 24, 38, "#297466")
    ctx.rectangle(172, 208, 36, 52)
    ctx.arc(190, 208, 18, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#5d331b"), OUTLINE, 2.8)
    save_surf(surf, "props/house_portuguese_ochre.png")

    # 2. Cobalt Blue Balcao Cottage
    w, h = 340, 250
    surf, ctx = new_surf(w, h)
    ctx.rectangle(24, 222, 292, 20)
    stroke_fill(ctx, hex_rgba("#9c4930"), OUTLINE, 3.0)
    ctx.rectangle(34, 96, 272, 126)
    stroke_fill(ctx, hex_rgba("#3878be"), OUTLINE, 3.2)
    # White corner bands
    for px in [34, 294]:
        ctx.rectangle(px, 96, 12, 126)
        stroke_fill(ctx, hex_rgba("#faf4e8"), OUTLINE, 2.2)
    draw_roof_tiles(ctx, 18, 98, 322, 98, 170, 24, "#cf522f", "#9e381d")
    draw_arched_window(ctx, 86, 152, 24, 40, "#f2c646")
    draw_arched_window(ctx, 254, 152, 24, 40, "#f2c646")
    # Balcao porch pillars & arch
    ctx.rectangle(136, 144, 68, 78)
    stroke_fill(ctx, hex_rgba("#faf4e8"), OUTLINE, 2.5)
    ctx.rectangle(152, 162, 36, 60)
    ctx.arc(170, 162, 18, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#5e341c"), OUTLINE, 2.6)
    save_surf(surf, "props/house_portuguese_cobalt.png")

    # 3. Coral Pink Coastal Villa with side veranda
    w, h = 360, 250
    surf, ctx = new_surf(w, h)
    ctx.rectangle(20, 222, 320, 20)
    stroke_fill(ctx, hex_rgba("#a85234"), OUTLINE, 3.0)
    ctx.rectangle(30, 96, 210, 126)
    stroke_fill(ctx, hex_rgba("#e56d53"), OUTLINE, 3.2)
    # Side shaded veranda
    ctx.rectangle(240, 124, 90, 98)
    stroke_fill(ctx, hex_rgba("#f7efe0"), OUTLINE, 2.8)
    draw_roof_tiles(ctx, 16, 98, 252, 98, 134, 24, "#c44729", "#933018")
    draw_roof_tiles(ctx, 240, 126, 344, 126, 240, 96, "#b84024", "#8a2b16")
    draw_arched_window(ctx, 82, 152, 24, 40, "#358068")
    draw_arched_window(ctx, 188, 152, 24, 40, "#358068")
    ctx.rectangle(118, 158, 34, 64)
    ctx.arc(135, 158, 17, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#5b331b"), OUTLINE, 2.6)
    # Veranda arches
    for ax in [264, 304]:
        ctx.rectangle(ax - 12, 156, 24, 66)
        ctx.arc(ax, 156, 12, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#405664"), OUTLINE, 2.2)
    save_surf(surf, "props/house_portuguese_coral.png")

    # 4. Laterite Heritage Stone Cottage
    w, h = 320, 230
    surf, ctx = new_surf(w, h)
    ctx.rectangle(22, 202, 276, 20)
    stroke_fill(ctx, hex_rgba("#8e4228"), OUTLINE, 3.0)
    ctx.rectangle(34, 92, 252, 110)
    stroke_fill(ctx, hex_rgba("#bd5838"), OUTLINE, 3.2)
    # Laterite stone courses
    ctx.set_source_rgba(*hex_rgba("#8f3c22", 0.65))
    ctx.set_line_width(1.8)
    for sy in [114, 136, 158, 180]:
        ctx.move_to(36, sy)
        ctx.line_to(284, sy)
        ctx.stroke()
    draw_roof_tiles(ctx, 18, 94, 302, 94, 160, 22, "#d15c30", "#a1411d")
    draw_arched_window(ctx, 84, 146, 22, 36, "#f4efd9")
    draw_arched_window(ctx, 236, 146, 22, 36, "#f4efd9")
    ctx.rectangle(142, 140, 36, 62)
    ctx.arc(160, 140, 18, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#59321b"), OUTLINE, 2.6)
    save_surf(surf, "props/house_laterite_heritage.png")


def gen_extra_landmarks():
    # 1. Cabo de Rama Fort & Coastal Cliff (South Goa)
    w, h = 640, 420
    surf, ctx = new_surf(w, h)
    # Sea splash base at cliff foot
    ctx.rectangle(18, 364, 604, 42)
    stroke_fill(ctx, hex_rgba("#299dc7"), OUTLINE, 3.0)
    ctx.set_source_rgba(1, 1, 1, 0.78)
    for fx in range(40, 600, 70):
        ctx.arc(fx, 368, 14, math.pi, 0)
        ctx.fill()
    # Dramatic red laterite coastal cliff
    ctx.move_to(26, 366)
    ctx.line_to(72, 215)
    ctx.line_to(568, 215)
    ctx.line_to(614, 366)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#b35535"), OUTLINE, 3.4)
    # Cliff geological laterite ridges & coastal shrubs
    ctx.set_source_rgba(*hex_rgba("#873b22", 0.55))
    ctx.set_line_width(2.2)
    for ry in [268, 304, 336]:
        ctx.move_to(66 - (ry - 215) * 0.25, ry)
        ctx.line_to(574 + (ry - 215) * 0.25, ry)
        ctx.stroke()
    for bx, by, br in [(140, 290, 14), (210, 325, 16), (430, 295, 15), (495, 330, 13)]:
        ctx.arc(bx, by, br, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#469448"), OUTLINE, 2.0)
    # Cliff grassy top strip
    ctx.move_to(72, 215)
    ctx.line_to(568, 215)
    ctx.line_to(558, 236)
    ctx.line_to(82, 236)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#469249"), OUTLINE, 2.8)
    # Fort bastions & crenellated wall
    ctx.rectangle(116, 126, 408, 90)
    stroke_fill(ctx, hex_rgba("#9c4529"), OUTLINE, 3.2)
    # Laterite stone courses on fort wall
    ctx.set_source_rgba(*hex_rgba("#76301a", 0.55))
    ctx.set_line_width(1.8)
    for fy in [150, 174, 198]:
        ctx.move_to(118, fy)
        ctx.line_to(522, fy)
        ctx.stroke()
    for bx in range(122, 510, 44):
        ctx.rectangle(bx, 108, 24, 18)
        stroke_fill(ctx, hex_rgba("#9c4529"), OUTLINE, 2.6)
    # Watchtower / turret
    ctx.rectangle(268, 62, 104, 154)
    stroke_fill(ctx, hex_rgba("#b05132"), OUTLINE, 3.2)
    ctx.arc(320, 62, 46, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#c85a36"), OUTLINE, 3.2)
    # Arched fort gateway
    ctx.rectangle(296, 144, 48, 72)
    ctx.arc(320, 144, 24, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#382014"), OUTLINE, 2.8)
    # Framing coconut palms on cliff
    draw_outlined_palm(ctx, 104, 215, 130, -24)
    draw_outlined_palm(ctx, 536, 215, 125, 22)
    save_surf(surf, "props/cabo_de_rama_cliff_fort.png")

    # 2. Our Lady of Immaculate Conception Church (Panaji)
    w, h = 500, 480
    surf, ctx = new_surf(w, h)
    # Base plinth
    ctx.rectangle(24, 444, 452, 24)
    stroke_fill(ctx, hex_rgba("#b55736"), OUTLINE, 3.0)
    # Lower terrace & zigzag Baroque stairs
    ctx.rectangle(46, 314, 408, 130)
    stroke_fill(ctx, hex_rgba("#f8f3e8"), OUTLINE, 3.0)
    # Stair flights
    for sx, sy, sw, sh in [(90, 390, 320, 54), (130, 344, 240, 46), (185, 314, 130, 30)]:
        ctx.rectangle(sx, sy, sw, sh)
        stroke_fill(ctx, hex_rgba("#ece4d2"), OUTLINE, 2.6)
    for st in range(324, 440, 12):
        ctx.set_source_rgba(*hex_rgba("#b8ac98"))
        ctx.set_line_width(1.6)
        ctx.move_to(140, st)
        ctx.line_to(360, st)
        ctx.stroke()
    # Main white Baroque church facade
    ctx.rectangle(108, 140, 284, 174)
    stroke_fill(ctx, hex_rgba("#fcf9f2"), OUTLINE, 3.2)
    # Twin side towers
    for tx in [108, 336]:
        ctx.rectangle(tx, 96, 56, 218)
        stroke_fill(ctx, hex_rgba("#fcf9f2"), OUTLINE, 3.0)
        ctx.move_to(tx - 4, 96)
        ctx.line_to(tx + 28, 62)
        ctx.line_to(tx + 60, 96)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#c9502c"), OUTLINE, 2.8)
    # Central bell gable
    ctx.rectangle(206, 68, 88, 72)
    stroke_fill(ctx, hex_rgba("#fcf9f2"), OUTLINE, 3.0)
    ctx.arc(250, 68, 44, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#fcf9f2"), OUTLINE, 3.0)
    # Cross at peak
    ctx.set_source_rgba(*OUTLINE)
    ctx.set_line_width(4.0)
    ctx.move_to(250, 24)
    ctx.line_to(250, 6)
    ctx.move_to(240, 14)
    ctx.line_to(260, 14)
    ctx.stroke()
    # Blue-trimmed arched doors & bell arch
    for dx in [190, 250, 310]:
        ctx.rectangle(dx - 16, 250, 32, 64)
        ctx.arc(dx, 250, 16, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#5c331b"), OUTLINE, 2.6)
    ctx.rectangle(236, 86, 28, 34)
    ctx.arc(250, 86, 14, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#386ea8"), OUTLINE, 2.4)
    save_surf(surf, "props/panaji_immaculate_conception.png")


def draw_outlined_palm(ctx, bx, by, height, lean_x):
    tx = bx + lean_x
    ty = by - height
    cx = bx + lean_x * 0.35
    cy = by - height * 0.55

    # Trunk with crisp outline
    ctx.move_to(bx - 10, by)
    quad_to(ctx, cx - 7, cy, tx - 4, ty)
    ctx.line_to(tx + 4, ty)
    quad_to(ctx, cx + 7, cy, bx + 10, by)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#8a5a38"), OUTLINE, 2.8)

    # Coconuts
    for dx, dy in [(-6, 7), (6, 8), (0, 12)]:
        ctx.set_source_rgba(*hex_rgba("#7a4a24"))
        ctx.arc(tx + dx, ty + dy, 6.5, 0, math.tau)
        stroke_fill(ctx, hex_rgba("#9c622c"), OUTLINE, 2.0)

    # Drooping lush outlined fronds
    angles = [-2.65, -2.05, -1.35, -0.55, 0.15, 0.72, -3.05]
    for idx, a in enumerate(angles):
        fl = height * (0.42 if idx % 2 == 0 else 0.36)
        ex = tx + math.cos(a) * fl
        ey = ty + math.sin(a) * fl + fl * 0.34
        mx = tx + math.cos(a) * fl * 0.52
        my = ty + math.sin(a) * fl * 0.40 - 10
        ctx.move_to(tx, ty)
        quad_to(ctx, mx, my - 10, ex, ey)
        quad_to(ctx, mx, my + 7, tx, ty)
        ctx.close_path()
        col = "#46a34c" if idx % 2 == 0 else "#348441"
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.4)


def gen_vegetation():
    # 1. Coconut palm leaning right
    surf, ctx = new_surf(260, 360)
    draw_outlined_palm(ctx, 110, 348, 255, 48)
    save_surf(surf, "props/tree_coconut_lean_right.png")

    # 2. Coconut palm leaning left
    surf, ctx = new_surf(260, 360)
    draw_outlined_palm(ctx, 150, 348, 260, -52)
    save_surf(surf, "props/tree_coconut_lean_left.png")

    # 3. Double coconut palm grove
    surf, ctx = new_surf(320, 380)
    draw_outlined_palm(ctx, 130, 368, 268, -42)
    draw_outlined_palm(ctx, 186, 368, 228, 46)
    save_surf(surf, "props/tree_coconut_double.png")

    # 4. Spreading Goan Rain / Banyan Tree
    surf, ctx = new_surf(380, 300)
    ctx.move_to(165, 290)
    quad_to(ctx, 178, 210, 166, 145)
    ctx.line_to(214, 145)
    quad_to(ctx, 202, 210, 216, 290)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#7a4e32"), OUTLINE, 3.0)
    for cx, cy, cr, col in [
        (106, 148, 62, "#2f783e"),
        (274, 148, 60, "#2f783e"),
        (152, 114, 68, "#3e9148"),
        (228, 114, 66, "#3e9148"),
        (190, 88, 72, "#51a852"),
    ]:
        ctx.arc(cx, cy, cr, 0, math.tau)
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.8)
    save_surf(surf, "props/tree_banyan_rain.png")

    # 5. Flowering Gulmohar / Cashew Tree
    surf, ctx = new_surf(300, 280)
    ctx.rectangle(136, 145, 28, 125)
    stroke_fill(ctx, hex_rgba("#75482e"), OUTLINE, 2.8)
    for cx, cy, cr, col in [
        (96, 136, 48, "#368344"),
        (204, 136, 48, "#368344"),
        (150, 102, 62, "#469c4c"),
    ]:
        ctx.arc(cx, cy, cr, 0, math.tau)
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.6)
    # Bright orange-red gulmohar flower clusters
    for fx, fy, fr in [(105, 115, 14), (146, 78, 18), (185, 108, 15), (128, 135, 12), (172, 136, 13)]:
        ctx.arc(fx, fy, fr, 0, math.tau)
        stroke_fill(ctx, hex_rgba("#ef592e"), OUTLINE, 2.0)
    save_surf(surf, "props/tree_cashew_gulmohar.png")

    # 6. Tropical Hibiscus Bush
    surf, ctx = new_surf(200, 140)
    for cx, cy, cr, col in [(56, 98, 34, "#2f783e"), (144, 98, 34, "#2f783e"), (100, 80, 44, "#449b4a")]:
        ctx.arc(cx, cy, cr, 0, math.tau)
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.6)
    for fx, fy in [(52, 88), (88, 66), (118, 76), (144, 92), (98, 102)]:
        ctx.arc(fx, fy, 8.5, 0, math.tau)
        stroke_fill(ctx, hex_rgba("#eb4655"), OUTLINE, 1.8)
        ctx.set_source_rgba(*hex_rgba("#ffcf40"))
        ctx.arc(fx, fy, 3.0, 0, math.tau)
        ctx.fill()
    save_surf(surf, "props/bush_hibiscus_cluster.png")


def gen_shops_and_props():
    # 1. Goa Beach Shack
    w, h = 320, 220
    surf, ctx = new_surf(w, h)
    # Wooden deck
    ctx.rectangle(20, 188, 280, 20)
    stroke_fill(ctx, hex_rgba("#c9985a"), OUTLINE, 2.8)
    # Bamboo posts
    for px in [46, 148, 266]:
        ctx.rectangle(px - 6, 92, 12, 96)
        stroke_fill(ctx, hex_rgba("#a8743e"), OUTLINE, 2.4)
    # Counter bar
    ctx.rectangle(46, 140, 164, 48)
    stroke_fill(ctx, hex_rgba("#8f5a30"), OUTLINE, 2.8)
    ctx.rectangle(40, 134, 176, 12)
    stroke_fill(ctx, hex_rgba("#f0be4a"), OUTLINE, 2.4)
    # Surfboard leaning on right
    ctx.save()
    ctx.translate(242, 135)
    ctx.rotate(0.18)
    draw_rounded_rect(ctx, -14, -52, 28, 104, 14)
    stroke_fill(ctx, hex_rgba("#3bbbe3"), OUTLINE, 2.4)
    ctx.set_source_rgba(*hex_rgba("#f6cc46"))
    ctx.rectangle(-4, -46, 8, 92)
    ctx.fill()
    ctx.restore()
    # Thatched palm roof
    ctx.move_to(14, 96)
    ctx.line_to(160, 26)
    ctx.line_to(306, 96)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#c89b44"), OUTLINE, 3.2)
    # Festive bunting triangles
    colors = ["#ef5340", "#3cb6de", "#f5ca3e", "#4eb565"]
    for i, bx in enumerate(range(36, 268, 32)):
        ctx.move_to(bx, 96)
        ctx.line_to(bx + 14, 114)
        ctx.line_to(bx + 28, 96)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(colors[i % len(colors)]), OUTLINE, 1.8)
    save_surf(surf, "props/prop_beach_shack.png")

    # 2. Goan Fishing Boat / Outrigger Canoe
    w, h = 280, 130
    surf, ctx = new_surf(w, h)
    ctx.move_to(18, 66)
    ctx.curve_to(40, 108, 240, 108, 262, 62)
    ctx.line_to(220, 56)
    ctx.line_to(56, 56)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#2789b8"), OUTLINE, 3.0)
    # Decorative orange-yellow gunwale stripe
    ctx.move_to(26, 66)
    ctx.line_to(254, 64)
    ctx.line_to(246, 76)
    ctx.line_to(34, 76)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#f2b636"), OUTLINE, 2.2)
    # Wooden thwarts & mast
    ctx.set_source_rgba(*hex_rgba("#7a4526"))
    ctx.set_line_width(4.0)
    ctx.move_to(138, 60)
    ctx.line_to(138, 16)
    ctx.stroke()
    ctx.move_to(140, 18)
    ctx.line_to(196, 48)
    ctx.line_to(140, 52)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#faf4e4"), OUTLINE, 2.2)
    save_surf(surf, "props/prop_fishing_boat.png")

    # 3. Goan Pao Bakery Stall
    w, h = 260, 200
    surf, ctx = new_surf(w, h)
    ctx.rectangle(26, 78, 208, 110)
    stroke_fill(ctx, hex_rgba("#faf2de"), OUTLINE, 3.0)
    # Striped red-cream awning
    for i in range(6):
        ax = 16 + i * 38
        ctx.rectangle(ax, 54, 38, 30)
        stroke_fill(ctx, hex_rgba("#d14b2d" if i % 2 == 0 else "#fff6e5"), OUTLINE, 2.2)
    # Wooden counter & warm pao loaves
    ctx.rectangle(38, 126, 184, 62)
    stroke_fill(ctx, hex_rgba("#8e542e"), OUTLINE, 2.6)
    for lx in [70, 100, 130, 160, 190]:
        ctx.arc(lx, 122, 11, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#de9545"), OUTLINE, 2.0)
    # Roof
    draw_roof_tiles(ctx, 18, 56, 242, 56, 130, 18, "#c24528", "#912d16")
    save_surf(surf, "props/prop_pao_bakery.png")

    # 4. Coastal Laterite Boulders
    w, h = 220, 130
    surf, ctx = new_surf(w, h)
    ctx.move_to(24, 116)
    ctx.curve_to(24, 52, 74, 32, 112, 48)
    ctx.curve_to(142, 24, 194, 46, 198, 116)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#9c5238"), OUTLINE, 3.0)
    ctx.move_to(90, 116)
    ctx.curve_to(96, 74, 148, 66, 174, 116)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#b86646"), OUTLINE, 2.6)
    # Mossy green patch
    ctx.arc(76, 58, 14, math.pi, 0)
    stroke_fill(ctx, hex_rgba("#4c9646"), OUTLINE, 2.0)
    save_surf(surf, "props/prop_coastal_cliff_rock.png")

    # 5. Low Laterite Culvert Wall
    w, h = 240, 110
    surf, ctx = new_surf(w, h)
    ctx.rectangle(16, 48, 208, 50)
    stroke_fill(ctx, hex_rgba("#aa4e32"), OUTLINE, 3.0)
    ctx.rectangle(10, 38, 220, 14)
    stroke_fill(ctx, hex_rgba("#d98b54"), OUTLINE, 2.6)
    for gx in [52, 120, 188]:
        ctx.arc(gx, 98, 16, math.pi, 0)
        stroke_fill(ctx, hex_rgba("#449346"), OUTLINE, 2.0)
    save_surf(surf, "props/prop_stone_culvert.png")

    # 6. Goan Heritage Arch (Victory / Section Welcome)
    w, h = 440, 320
    surf, ctx = new_surf(w, h)
    # Twin laterite/cream pillars
    for px in [38, 344]:
        ctx.rectangle(px, 76, 58, 232)
        stroke_fill(ctx, hex_rgba("#f6efe0"), OUTLINE, 3.2)
        ctx.rectangle(px - 6, 62, 70, 20)
        stroke_fill(ctx, hex_rgba("#c84d2d"), OUTLINE, 2.8)
    # Overhead arch span
    ctx.rectangle(96, 68, 248, 62)
    stroke_fill(ctx, hex_rgba("#f2c23c"), OUTLINE, 3.2)
    draw_roof_tiles(ctx, 78, 70, 362, 70, 220, 22, "#c84d2d", "#99341b")
    ctx.rectangle(116, 82, 208, 34)
    stroke_fill(ctx, hex_rgba("#1e5b4e"), OUTLINE, 2.4)
    save_surf(surf, "props/prop_goa_arch_welcome.png")


def gen_foreground_verge():
    # 1. Coastal grass & wildflowers
    w, h = 180, 75
    surf, ctx = new_surf(w, h)
    for bx, bh, lean, col in [
        (36, 42, -12, "#3a8840"), (46, 52, 4, "#4aa449"), (58, 38, 14, "#3e9244"),
        (114, 46, -10, "#3a8840"), (126, 54, 6, "#50ad4e"), (138, 40, 15, "#3e9244"),
    ]:
        ctx.move_to(bx - 5, 68)
        quad_to(ctx, bx + lean * 0.4, 68 - bh * 0.5, bx + lean, 68 - bh)
        quad_to(ctx, bx + lean * 0.4 + 6, 68 - bh * 0.4, bx + 5, 68)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.0)
    for fx, fy, fc in [(44, 24, "#ff6872"), (128, 20, "#ffd23f"), (84, 52, "#ff7d95")]:
        ctx.arc(fx, fy, 6.5, 0, math.tau)
        stroke_fill(ctx, hex_rgba(fc), OUTLINE, 1.8)
    save_surf(surf, "foreground/fg_grass_flowers_1.png")

    # 2. Tropical ferns & pebbles
    w, h = 180, 80
    surf, ctx = new_surf(w, h)
    for bx, bh, lean, col in [
        (48, 48, -18, "#337f3b"), (62, 56, 2, "#439947"), (76, 44, 18, "#378940"),
        (124, 42, 12, "#4ea74c"),
    ]:
        ctx.move_to(bx - 6, 72)
        quad_to(ctx, bx + lean * 0.5, 72 - bh * 0.6, bx + lean, 72 - bh)
        quad_to(ctx, bx + lean * 0.5 + 8, 72 - bh * 0.4, bx + 6, 72)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.0)
    for rx, ry, rr in [(104, 64, 11), (144, 66, 9)]:
        ctx.arc(rx, ry, rr, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#9c5a3f"), OUTLINE, 2.0)
    save_surf(surf, "foreground/fg_grass_ferns_2.png")

    # 3. Coastal rocks & sea grass
    w, h = 190, 70
    surf, ctx = new_surf(w, h)
    ctx.move_to(26, 62)
    ctx.curve_to(32, 32, 70, 28, 86, 62)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#9b553b"), OUTLINE, 2.4)
    ctx.move_to(68, 62)
    ctx.curve_to(74, 40, 108, 40, 116, 62)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#b86b4c"), OUTLINE, 2.2)
    for bx, bh, lean in [(132, 38, -8), (144, 46, 4), (156, 36, 12)]:
        ctx.move_to(bx - 4, 62)
        quad_to(ctx, bx + lean * 0.4, 62 - bh * 0.5, bx + lean, 62 - bh)
        quad_to(ctx, bx + lean * 0.4 + 5, 62 - bh * 0.4, bx + 4, 62)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#469d49"), OUTLINE, 1.8)
    save_surf(surf, "foreground/fg_coastal_rocks_3.png")


if __name__ == "__main__":
    ensure_dirs()
    gen_sky()
    gen_clouds()
    gen_distant_horizons()
    gen_midground_strips()
    gen_portuguese_houses()
    gen_extra_landmarks()
    gen_vegetation()
    gen_shops_and_props()
    gen_foreground_verge()
    print("All Goa overhaul assets generated in:", OUT_DIR)
