#!/usr/bin/env python3
"""
Generate complete stylized-realistic 2D vector art assets for the Rajasthan (Jaipur to Jaisalmer)
map overhaul, cohesive with the dark-brown outlined warm vector style in 'Rajasthan_2D_Assets(1)'.
Outputs to assets/indian_locations/rajasthan/v3/.
"""

import math
import os
import cairo

OUT_DIR = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "assets", "indian_locations", "rajasthan", "v3")
)

OUTLINE = (0.20, 0.12, 0.07, 1.0)


def ensure_dirs():
    for sub in ["parallax", "landmarks", "props", "foreground"]:
        os.makedirs(os.path.join(OUT_DIR, sub), exist_ok=True)


def hex_rgba(h: str, a: float = 1.0):
    h = h.lstrip("#")
    return (int(h[0:2], 16) / 255.0, int(h[2:4], 16) / 255.0, int(h[4:6], 16) / 255.0, a)


def new_surf(w: int, h: int):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surf)
    ctx.set_antialias(cairo.ANTIALIAS_BEST)
    return surf, ctx


def save_surf(surf, rel_path: str):
    full = os.path.join(OUT_DIR, rel_path)
    surf.write_to_png(full)
    print(f"Generated: {rel_path}")


def quad_to(ctx, cx, cy, ex, ey):
    x0, y0 = ctx.get_current_point()
    ctx.curve_to(x0 + 2.0 / 3.0 * (cx - x0), y0 + 2.0 / 3.0 * (cy - y0),
                 ex + 2.0 / 3.0 * (cx - ex), ey + 2.0 / 3.0 * (cy - ey), ex, ey)


def stroke_fill(ctx, fill_col, stroke_col=OUTLINE, lw=2.8):
    ctx.set_source_rgba(*fill_col)
    ctx.fill_preserve()
    ctx.set_source_rgba(*stroke_col)
    ctx.set_line_width(lw)
    ctx.set_line_join(cairo.LINE_JOIN_ROUND)
    ctx.stroke()


def draw_rounded_rect(ctx, x, y, w, h, r):
    ctx.new_sub_path()
    ctx.arc(x + w - r, y + r, r, -math.pi / 2, 0)
    ctx.arc(x + w - r, y + h - r, r, 0, math.pi / 2)
    ctx.arc(x + r, y + h - r, r, math.pi / 2, math.pi)
    ctx.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2)
    ctx.close_path()


def draw_periodic_ridge(ctx, w, base_y, h_max, amps, freqs, phases, fill_col, stroke_col=None, lw=2.0):
    ctx.new_path()
    ctx.move_to(0, h_max)
    for px in range(0, w + 1, 8):
        th = (px / float(w)) * math.tau
        y = base_y
        for a, f, ph in zip(amps, freqs, phases):
            y -= a * math.sin(th * f + ph)
        ctx.line_to(px, y)
    ctx.line_to(w, h_max)
    ctx.close_path()
    ctx.set_source_rgba(*fill_col)
    if stroke_col:
        ctx.fill_preserve()
        ctx.set_source_rgba(*stroke_col)
        ctx.set_line_width(lw)
        ctx.stroke()
    else:
        ctx.fill()


def draw_periodic_crags(ctx, w, base_y, h_max, amps, freqs, phases, fill_col):
    ctx.new_path()
    ctx.move_to(0, h_max)
    for px in range(0, w + 1, 10):
        th = (px / float(w)) * math.tau
        y = base_y
        for a, f, ph in zip(amps, freqs, phases):
            v = abs(math.sin(th * f + ph))
            y -= a * (0.4 + 0.6 * v)
        ctx.line_to(px, y)
    ctx.line_to(w, h_max)
    ctx.close_path()
    ctx.set_source_rgba(*fill_col)
    ctx.fill()


def draw_bird(ctx, bx, by, sc=1.0, col="#4f3526"):
    ctx.set_source_rgba(*hex_rgba(col, 0.72))
    ctx.set_line_width(2.0 * sc)
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    ctx.move_to(bx - 12 * sc, by + 3 * sc)
    quad_to(ctx, bx - 6 * sc, by - 6 * sc, bx, by)
    quad_to(ctx, bx + 6 * sc, by - 6 * sc, bx + 12 * sc, by + 3 * sc)
    ctx.stroke()


def draw_camel_silhouette(ctx, cx, by, sc=1.0, col="#7e4a2b"):
    ctx.save()
    ctx.translate(cx, by)
    ctx.scale(sc, sc)
    ctx.set_source_rgba(*hex_rgba(col, 0.92))
    # Legs
    for lx in [-16, -10, 8, 14]:
        ctx.rectangle(lx, -22, 3.5, 22)
    ctx.fill()
    # Body + single dromedary hump + neck + head
    ctx.move_to(-20, -18)
    ctx.curve_to(-22, -34, -10, -48, 0, -48)
    ctx.curve_to(10, -48, 16, -32, 24, -30)
    ctx.curve_to(30, -34, 34, -48, 37, -50)
    ctx.line_to(46, -48)
    ctx.line_to(45, -42)
    ctx.curve_to(37, -41, 35, -24, 24, -16)
    ctx.line_to(-16, -16)
    ctx.close_path()
    ctx.fill()
    ctx.restore()


# =====================================================================
# 1. SKIES & CLOUDS (4 Desert Lighting Variations + Warm Cloud/Dust Layer)
# =====================================================================

def gen_skies_and_clouds():
    w, h = 1920, 720
    sky_specs = [
        ("sky_rj_01_sunrise.png", "#2b79b8", "#6fb4d8", "#f4ca89", "#fae1b0", 420, 175, "#fff4d2"),
        ("sky_rj_02_daylight.png", "#2e89d1", "#76bee6", "#e4dcb4", "#efe3bf", 960, 145, "#fff7dc"),
        ("sky_rj_03_afternoon.png", "#357ab3", "#8bb2c9", "#edc888", "#f3d7a3", 1320, 162, "#ffeac0"),
        ("sky_rj_04_sunset.png", "#3b4e86", "#9f5d74", "#ea8648", "#f8be62", 1480, 195, "#fff0a8"),
    ]
    for fname, c0, c1, c2, c3, sx, sy, sun_c in sky_specs:
        surf, ctx = new_surf(w, h)
        g = cairo.LinearGradient(0, 0, 0, h)
        g.add_color_stop_rgba(0.00, *hex_rgba(c0))
        g.add_color_stop_rgba(0.32, *hex_rgba(c1))
        g.add_color_stop_rgba(0.64, *hex_rgba(c2))
        g.add_color_stop_rgba(1.00, *hex_rgba(c3))
        ctx.set_source(g)
        ctx.rectangle(0, 0, w, h)
        ctx.fill()
        sg = cairo.RadialGradient(sx, sy, 10, sx, sy, 165)
        sg.add_color_stop_rgba(0.0, *hex_rgba(sun_c, 0.96))
        sg.add_color_stop_rgba(0.24, *hex_rgba(sun_c, 0.55))
        sg.add_color_stop_rgba(0.60, *hex_rgba(c2, 0.18))
        sg.add_color_stop_rgba(1.0, *hex_rgba(c2, 0.0))
        ctx.set_source(sg)
        ctx.arc(sx, sy, 165, 0, math.tau)
        ctx.fill()
        save_surf(surf, f"parallax/{fname}")

    # Soft desert clouds with warm golden lower glow + soaring desert birds
    surf, ctx = new_surf(1920, 230)
    clouds = [
        (185, 86, 0.85, 0.88), (520, 142, 0.62, 0.78), (880, 74, 0.98, 0.90),
        (1230, 128, 0.68, 0.82), (1560, 80, 0.88, 0.88), (1895, 92, 0.55, 0.80), (-25, 92, 0.55, 0.80),
    ]
    for cx, cy, sc, al in clouds:
        puffs = [(-56 * sc, 10 * sc, 24 * sc), (-24 * sc, -6 * sc, 33 * sc), (12 * sc, -13 * sc, 38 * sc), (48 * sc, -2 * sc, 28 * sc)]
        ctx.set_source_rgba(0.99, 0.88, 0.72, al * 0.88)
        for px, py, r in puffs:
            ctx.arc(cx + px, cy + py + 5 * sc, r, 0, math.tau)
        draw_rounded_rect(ctx, cx - 64 * sc, cy + 5 * sc, 134 * sc, 16 * sc, 8 * sc)
        ctx.fill()
        ctx.set_source_rgba(1.0, 0.98, 0.92, al)
        for px, py, r in puffs:
            ctx.arc(cx + px, cy + py - 1 * sc, r * 0.94, 0, math.tau)
        draw_rounded_rect(ctx, cx - 64 * sc, cy + 3 * sc, 132 * sc, 15 * sc, 7 * sc)
        ctx.fill()
    for bx, by, bs in [(345, 58, 0.85), (370, 68, 0.7), (1055, 52, 0.9), (1085, 62, 0.72), (1685, 54, 0.8)]:
        draw_bird(ctx, bx, by, bs, "#5f4331")
    save_surf(surf, "parallax/clouds_rj_natural.png")


# =====================================================================
# 2. DISTANT HILLS & DESERT SILHOUETTES (5 ZONES - 1920x440 SEAMLESS)
# =====================================================================

def gen_distant_layers():
    w, h = 1920, 440
    horizon = 252

    # 1. Jaipur Heritage (Aravalli foothills + Pink City palace silhouettes)
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, horizon - 54, h, [32, 14], [2, 5], [0.4, 1.8], hex_rgba("#c89f8d", 0.75))
    draw_periodic_ridge(ctx, w, horizon - 20, h, [22, 10], [3, 6], [1.2, 0.5], hex_rgba("#ba826a", 0.88))
    # Distant Amber / Nahargarh silhouette domes along crest
    for sx in [380, 1280]:
        ctx.set_source_rgba(*hex_rgba("#9b6352", 0.78))
        ctx.rectangle(sx - 68, horizon - 54, 136, 44)
        ctx.arc(sx - 44, horizon - 54, 14, math.pi, 0)
        ctx.arc(sx, horizon - 62, 18, math.pi, 0)
        ctx.arc(sx + 44, horizon - 54, 14, math.pi, 0)
        ctx.fill()
    draw_periodic_ridge(ctx, w, horizon + 12, h, [8, 4], [2, 5], [0.9, 2.0], hex_rgba("#d8ad78"))
    save_surf(surf, "parallax/dist_01_jaipur.png")

    # 2. Aravalli Outskirts (Rocky granite crags & dry valleys)
    surf, ctx = new_surf(w, h)
    draw_periodic_crags(ctx, w, horizon - 60, h, [42, 20], [2, 5], [0.2, 1.3], hex_rgba("#b89578", 0.80))
    draw_periodic_crags(ctx, w, horizon - 22, h, [30, 14], [3, 7], [1.5, 0.4], hex_rgba("#9c7858", 0.92))
    draw_periodic_ridge(ctx, w, horizon + 16, h, [10, 5], [3, 6], [0.4, 1.9], hex_rgba("#c89f68"))
    save_surf(surf, "parallax/dist_02_aravalli.png")

    # 3. Thar Desert Heritage (Wind-carved golden sand dunes + distant camel train)
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, horizon - 38, h, [28, 12], [2, 4], [0.3, 1.9], hex_rgba("#e5be79", 0.88))
    # Dune shadow facet ridge
    draw_periodic_ridge(ctx, w, horizon - 10, h, [26, 11], [2, 5], [1.2, 0.6], hex_rgba("#d59c52"))
    for sx in [520, 1490]:
        draw_camel_silhouette(ctx, sx, horizon - 28, 0.45, "#875331")
        draw_camel_silhouette(ctx, sx + 34, horizon - 27, 0.42, "#875331")
    draw_periodic_ridge(ctx, w, horizon + 18, h, [12, 6], [3, 6], [2.1, 0.8], hex_rgba("#e3b267"))
    save_surf(surf, "parallax/dist_03_desert.png")

    # 4. Jodhpur Blue City (Rocky Marwar bluff & distant citadel ridge)
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, horizon - 46, h, [30, 15], [2, 5], [0.7, 1.4], hex_rgba("#9fa8c4", 0.72))
    draw_periodic_crags(ctx, w, horizon - 18, h, [26, 12], [3, 6], [0.9, 2.2], hex_rgba("#8e6c54", 0.90))
    for sx in [460, 1420]:
        ctx.set_source_rgba(*hex_rgba("#76533e", 0.85))
        ctx.rectangle(sx - 75, horizon - 68, 150, 52)
        ctx.rectangle(sx - 45, horizon - 84, 90, 20)
        ctx.fill()
    draw_periodic_ridge(ctx, w, horizon + 18, h, [9, 4], [2, 5], [1.4, 0.3], hex_rgba("#c89b62"))
    save_surf(surf, "parallax/dist_04_jodhpur.png")

    # 5. Jaisalmer Golden City (Glowing Sam dunes & Trikuta golden bastion silhouettes)
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, horizon - 44, h, [30, 12], [2, 4], [0.5, 1.8], hex_rgba("#e59d56", 0.88))
    draw_periodic_ridge(ctx, w, horizon - 14, h, [24, 10], [3, 5], [1.6, 0.7], hex_rgba("#cf833c"))
    for sx in [580, 1540]:
        ctx.set_source_rgba(*hex_rgba("#9c582b", 0.85))
        ctx.rectangle(sx - 82, horizon - 56, 164, 42)
        for bx in range(sx - 74, sx + 74, 24):
            ctx.arc(bx, horizon - 56, 10, math.pi, 0)
        ctx.fill()
    draw_periodic_ridge(ctx, w, horizon + 18, h, [10, 5], [2, 6], [0.2, 2.3], hex_rgba("#dfb05f"))
    save_surf(surf, "parallax/dist_05_jaisalmer.png")


# =====================================================================
# 3. MIDGROUND LAYERS (5 ZONES - 1920x420 SEAMLESS)
# =====================================================================

def draw_mid_khejri(ctx, bx, by, sc=1.0, leaf_c="#6a8244"):
    ctx.save()
    ctx.translate(bx, by)
    ctx.scale(sc, sc)
    ctx.set_source_rgba(*hex_rgba("#593a24"))
    ctx.set_line_width(6.0)
    ctx.move_to(0, 0)
    quad_to(ctx, -4, -30, 3, -60)
    ctx.stroke()
    ctx.set_line_width(3.5)
    ctx.move_to(1, -36)
    ctx.line_to(-18, -56)
    ctx.move_to(2, -40)
    ctx.line_to(18, -54)
    ctx.stroke()
    # Layered umbrella-like Khejri / Acacia crown rather than circular blobs
    for dx, dy, rx, ry, c in [
        (-20, -60, 22, 10, "#506a34"),
        (18, -58, 21, 9, "#506a34"),
        (0, -68, 30, 12, leaf_c),
        (-8, -74, 20, 8, leaf_c),
    ]:
        ctx.save()
        ctx.translate(dx, dy)
        ctx.scale(rx, ry)
        ctx.set_source_rgba(*hex_rgba(c))
        ctx.arc(0, 0, 1.0, 0, math.tau)
        ctx.fill()
        ctx.restore()
    ctx.restore()


def draw_mid_wall_and_haveli(ctx, x, gy, wall_c, trim_c, w=118, h=72, variant=0):
    # Subtle distant haze soften for background haveli clusters
    ctx.save()
    # Main facade with gentle step or side courtyard wall
    ctx.set_source_rgba(*hex_rgba(wall_c, 0.92))
    ctx.rectangle(x - w * 0.5, gy - h, w, h)
    ctx.fill()

    # Optional stepped upper pavilion / chhatri dome on variant 0 or 1
    if variant % 3 == 0:
        pw, ph = w * 0.52, h * 0.34
        ctx.set_source_rgba(*hex_rgba(wall_c, 0.95))
        ctx.rectangle(x - pw * 0.5, gy - h - ph, pw, ph)
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba(trim_c, 0.92))
        ctx.rectangle(x - pw * 0.56, gy - h - ph - 4, pw * 1.12, 5)
        ctx.fill()
        # Small chhatri cupola
        ctx.set_source_rgba(*hex_rgba(trim_c, 0.90))
        ctx.arc(x, gy - h - ph - 4, 10, math.pi, 0)
        ctx.fill()
    elif variant % 3 == 1:
        # Side fort bastion / gateway wall extending cleanly
        ctx.set_source_rgba(*hex_rgba(wall_c, 0.85))
        ctx.rectangle(x + w * 0.45, gy - h * 0.55, w * 0.42, h * 0.55)
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba(trim_c, 0.88))
        ctx.rectangle(x + w * 0.45, gy - h * 0.55 - 4, w * 0.44, 4)
        ctx.fill()

    # Chajja cornice + delicate Kangura frieze (no bulky bumps)
    ctx.set_source_rgba(*hex_rgba(trim_c, 0.92))
    ctx.rectangle(x - w * 0.53, gy - h - 5, w * 1.06, 6)
    ctx.fill()

    # Windows (varied spacing & arched silhouette)
    ctx.set_source_rgba(*hex_rgba("#4c2d1d", 0.72))
    n_win = 2 if w < 92 else 3
    span = w * 0.58
    for i in range(n_win):
        wx = x - span * 0.5 + (span / max(1, n_win - 1)) * i if n_win > 1 else x
        ctx.rectangle(wx - 5, gy - h * 0.62, 10, 18)
        ctx.arc(wx, gy - h * 0.62, 5, math.pi, 0)
        ctx.fill()
    ctx.restore()


def gen_midground_layers():
    w, h = 1920, 420
    gy = 236

    # 1. Jaipur Heritage: Varied pink sandstone haveli clusters, chhatris & umbrella Khejri trees
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 14, h, [16, 7], [2, 5], [0.4, 1.7], hex_rgba("#d9ab74"))
    for idx, (hx, bw, bh, var) in enumerate([
        (135, 108, 66, 0), (255, 86, 52, 2), (610, 112, 70, 1), (740, 82, 50, 0),
        (1080, 104, 64, 2), (1210, 92, 56, 0), (1615, 114, 72, 1), (1750, 88, 54, 2),
    ]):
        draw_mid_wall_and_haveli(ctx, hx, gy - 3, "#d88974", "#b55c47", bw, bh, var)
    for kx in [415, 495, 910, 1415, 1865]:
        draw_mid_khejri(ctx, kx, gy, 0.96 + (kx % 3) * 0.08, "#6f8346")
    draw_periodic_ridge(ctx, w, gy + 4, h, [8, 4], [3, 6], [0.8, 1.2], hex_rgba("#cf995a"))
    save_surf(surf, "parallax/mid_01_jaipur.png")

    # 2. Aravalli Outskirts: Rocky sandstone ridges, sparse acacia/khejri, stony outcrops
    surf, ctx = new_surf(w, h)
    draw_periodic_crags(ctx, w, gy - 26, h, [28, 13], [3, 6], [0.6, 2.0], hex_rgba("#a87b53"))
    for rx in [110, 390, 690, 1020, 1380, 1690]:
        ctx.set_source_rgba(*hex_rgba("#7f5b3f"))
        ctx.move_to(rx - 36, gy + 6)
        ctx.line_to(rx - 20, gy - 24)
        ctx.line_to(rx + 14, gy - 28)
        ctx.line_to(rx + 40, gy + 6)
        ctx.close_path()
        ctx.fill()
        draw_mid_khejri(ctx, rx + 115, gy, 0.95, "#6b8041")
    draw_periodic_ridge(ctx, w, gy + 4, h, [9, 4], [2, 5], [1.1, 0.3], hex_rgba("#c69254"))
    save_surf(surf, "parallax/mid_02_aravalli.png")

    # 3. Thar Desert Heritage: Sculpted golden dunes, scattered Bhunga huts, camel caravan
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 24, h, [24, 10], [2, 4], [0.2, 1.8], hex_rgba("#eab96e"))
    draw_periodic_ridge(ctx, w, gy - 4, h, [18, 8], [3, 5], [1.4, 0.5], hex_rgba("#dc9f50"))
    for bx in [210, 820, 1440]:
        ctx.set_source_rgba(*hex_rgba("#c48f5a"))
        ctx.rectangle(bx - 34, gy - 42, 68, 42)
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#b88e47"))
        ctx.move_to(bx - 46, gy - 40)
        ctx.line_to(bx, gy - 76)
        ctx.line_to(bx + 46, gy - 40)
        ctx.close_path()
        ctx.fill()
        draw_camel_silhouette(ctx, bx + 220, gy - 2, 0.68, "#7b492c")
        draw_camel_silhouette(ctx, bx + 275, gy - 2, 0.62, "#7b492c")
    draw_periodic_ridge(ctx, w, gy + 8, h, [9, 4], [2, 6], [0.9, 2.0], hex_rgba("#d89c4e"))
    save_surf(surf, "parallax/mid_03_desert.png")

    # 4. Jodhpur Blue City: Clustered cobalt-blue Marwar houses & open sandstone hill breaks
    surf, ctx = new_surf(w, h)
    draw_periodic_crags(ctx, w, gy - 20, h, [20, 9], [3, 5], [0.7, 1.5], hex_rgba("#a8835e"))
    for hx, bh, bw, var in [
        (120, 56, 86, 2), (218, 72, 96, 0), (324, 52, 80, 1),
        (760, 62, 90, 2), (866, 76, 98, 0), (972, 50, 78, 2),
        (1380, 58, 88, 1), (1488, 74, 94, 0), (1594, 54, 82, 2),
    ]:
        blue_c = "#568cd0" if (hx % 4 == 0) else "#6ca3e0"
        draw_mid_wall_and_haveli(ctx, hx, gy - 2, blue_c, "#e2e9f4", bw, bh, var)
    for kx in [515, 605, 1140, 1785]:
        draw_mid_khejri(ctx, kx, gy, 0.92, "#6c8044")
    draw_periodic_ridge(ctx, w, gy + 6, h, [8, 4], [3, 6], [1.2, 0.4], hex_rgba("#c89756"))
    save_surf(surf, "parallax/mid_04_jodhpur.png")

    # 5. Jaisalmer Golden City: Clustered honey-gold sandstone havelis, dunes & sunset camel silhouettes
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 22, h, [22, 9], [2, 4], [0.5, 1.9], hex_rgba("#e2a556"))
    for hx, bw, bh, var in [
        (145, 108, 66, 0), (268, 86, 52, 2),
        (715, 106, 68, 1), (840, 84, 54, 0),
        (1295, 110, 66, 2), (1422, 88, 56, 0),
    ]:
        draw_mid_wall_and_haveli(ctx, hx, gy - 3, "#dcac5a", "#bd8436", bw, bh, var)
    for cx in [490, 1060, 1680]:
        draw_camel_silhouette(ctx, cx, gy - 2, 0.72, "#744123")
        draw_camel_silhouette(ctx, cx + 52, gy - 2, 0.65, "#744123")
    draw_periodic_ridge(ctx, w, gy + 8, h, [8, 4], [2, 6], [0.3, 1.6], hex_rgba("#cf8f42"))
    save_surf(surf, "parallax/mid_05_jaisalmer.png")


# =====================================================================
# 4. CUSTOM VECTOR JANTAR MANTAR + PROPS + JAISALMER FINISH ARCH + FG
# =====================================================================

def gen_custom_landmarks_and_props():
    # 1. Jantar Mantar (Jaipur Samrat Yantra astronomical sundial)
    surf, ctx = new_surf(440, 320)
    # Stone plinth
    ctx.rectangle(24, 286, 392, 24)
    stroke_fill(ctx, hex_rgba("#c9946e"), OUTLINE, 3.0)
    # Curved white marble astronomical quadrant wings
    for sign in [-1, 1]:
        ctx.move_to(220 + sign * 24, 286)
        ctx.curve_to(220 + sign * 95, 280, 220 + sign * 155, 220, 220 + sign * 176, 152)
        ctx.line_to(220 + sign * 154, 152)
        ctx.curve_to(220 + sign * 134, 210, 220 + sign * 80, 256, 220 + sign * 20, 260)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#f5efe2"), OUTLINE, 2.8)
    # Towering Samrat Yantra pink sandstone triangle gnomon
    ctx.move_to(118, 286)
    ctx.line_to(296, 48)
    ctx.line_to(322, 48)
    ctx.line_to(322, 286)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#db836d"), OUTLINE, 3.2)
    # Staircase steps along hypotenuse face
    ctx.set_source_rgba(*hex_rgba("#f7e3ce"))
    ctx.set_line_width(2.2)
    for st in range(1, 10):
        t = st / 10.0
        sx = 128 + t * 168
        sy = 278 - t * 222
        ctx.move_to(sx, sy)
        ctx.line_to(sx + 16, sy)
        ctx.stroke()
    # Chhatri dome atop gnomon
    ctx.rectangle(288, 28, 34, 22)
    stroke_fill(ctx, hex_rgba("#f7ebd8"), OUTLINE, 2.6)
    ctx.arc(305, 28, 17, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#e8b648"), OUTLINE, 2.8)
    # Recessed pink arches along base wall
    for ax in [210, 254, 294]:
        ctx.rectangle(ax - 12, 226, 24, 60)
        ctx.arc(ax, 226, 12, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#763d2d"), OUTLINE, 2.4)
    save_surf(surf, "landmarks/jantar_mantar.png")

    # 2. Jaisalmer Golden Sandstone Victory Arch
    surf, ctx = new_surf(440, 320)
    for px in [38, 344]:
        ctx.rectangle(px, 78, 58, 232)
        stroke_fill(ctx, hex_rgba("#ecc072"), OUTLINE, 3.2)
        ctx.rectangle(px - 6, 62, 70, 18)
        stroke_fill(ctx, hex_rgba("#c87638"), OUTLINE, 2.8)
        # Chhatri side domes
        ctx.rectangle(px + 12, 34, 34, 28)
        stroke_fill(ctx, hex_rgba("#f4d692"), OUTLINE, 2.6)
        ctx.arc(px + 29, 34, 18, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#d8863c"), OUTLINE, 2.8)
    ctx.rectangle(96, 68, 248, 62)
    stroke_fill(ctx, hex_rgba("#e5a54b"), OUTLINE, 3.2)
    # Central scalloped battlement parapet
    for bx in range(114, 336, 28):
        ctx.arc(bx, 68, 11, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#c86f34"), OUTLINE, 2.4)
    ctx.rectangle(116, 82, 208, 34)
    stroke_fill(ctx, hex_rgba("#8e3924"), OUTLINE, 2.4)
    save_surf(surf, "props/prop_rajasthan_arch_jaisalmer.png")

    # 3. Zone Village Houses
    # a) Jaipur Pink Haveli
    surf, ctx = new_surf(260, 200)
    ctx.rectangle(26, 62, 208, 128)
    stroke_fill(ctx, hex_rgba("#e28b74"), OUTLINE, 3.0)
    ctx.rectangle(18, 48, 224, 18)
    stroke_fill(ctx, hex_rgba("#bd5844"), OUTLINE, 2.8)
    for ax in [64, 130, 196]:
        ctx.rectangle(ax - 16, 84, 32, 38)
        ctx.arc(ax, 84, 16, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#f9e8d2"), OUTLINE, 2.4)
    ctx.rectangle(108, 132, 44, 58)
    ctx.arc(130, 132, 22, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#5a321e"), OUTLINE, 2.6)
    save_surf(surf, "props/house_rj_pink_haveli.png")

    # b) Thar Desert Bhunga Mud & Thatch Hut
    surf, ctx = new_surf(230, 185)
    ctx.rectangle(42, 86, 146, 90)
    stroke_fill(ctx, hex_rgba("#d1a068"), OUTLINE, 3.0)
    ctx.move_to(22, 90)
    ctx.line_to(115, 22)
    ctx.line_to(208, 90)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#bfa056"), OUTLINE, 3.2)
    ctx.rectangle(94, 118, 42, 58)
    ctx.arc(115, 118, 21, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#56321e"), OUTLINE, 2.6)
    for wx in [64, 166]:
        ctx.arc(wx, 122, 11, 0, math.tau)
        stroke_fill(ctx, hex_rgba("#f6efe0"), OUTLINE, 2.2)
    save_surf(surf, "props/house_rj_desert_bhunga.png")

    # c) Jodhpur Blue City Sandstone House
    surf, ctx = new_surf(240, 195)
    ctx.rectangle(30, 56, 180, 130)
    stroke_fill(ctx, hex_rgba("#528fd4"), OUTLINE, 3.0)
    ctx.rectangle(22, 44, 196, 16)
    stroke_fill(ctx, hex_rgba("#e8eef7"), OUTLINE, 2.6)
    for wx in [68, 172]:
        ctx.rectangle(wx - 14, 78, 28, 36)
        ctx.arc(wx, 78, 14, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#23436e"), OUTLINE, 2.4)
    ctx.rectangle(98, 122, 44, 64)
    ctx.arc(120, 122, 22, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#4e2c1a"), OUTLINE, 2.6)
    save_surf(surf, "props/house_rj_jodhpur_blue.png")

    # d) Jaisalmer Golden Sandstone House
    surf, ctx = new_surf(250, 200)
    ctx.rectangle(26, 60, 198, 130)
    stroke_fill(ctx, hex_rgba("#e4b45c"), OUTLINE, 3.0)
    ctx.rectangle(18, 46, 214, 18)
    stroke_fill(ctx, hex_rgba("#c48a34"), OUTLINE, 2.8)
    for wx in [68, 182]:
        draw_rounded_rect(ctx, wx - 18, 78, 36, 42, 4)
        stroke_fill(ctx, hex_rgba("#a86f27"), OUTLINE, 2.4)
    ctx.rectangle(103, 126, 44, 64)
    ctx.arc(125, 126, 22, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#53301c"), OUTLINE, 2.6)
    save_surf(surf, "props/house_rj_golden_haveli.png")

    # e) Rajasthani Highway Chai Dhaba Stall
    surf, ctx = new_surf(190, 140)
    ctx.rectangle(24, 52, 142, 80)
    stroke_fill(ctx, hex_rgba("#dfb376"), OUTLINE, 2.8)
    ctx.move_to(14, 54)
    ctx.line_to(34, 24)
    ctx.line_to(156, 24)
    ctx.line_to(176, 54)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#c9593b"), OUTLINE, 2.8)
    ctx.rectangle(46, 66, 98, 36)
    stroke_fill(ctx, hex_rgba("#53311d"), OUTLINE, 2.4)
    save_surf(surf, "props/shop_rj_chai_dhaba.png")

    # 4. Desert Vegetation (Khejri, Umbrella Acacia, Oasis Date Palm, Thorn Scrub, Dry Grass)
    # Khejri tree
    surf, ctx = new_surf(220, 240)
    ctx.move_to(96, 232)
    quad_to(ctx, 102, 170, 94, 118)
    ctx.line_to(122, 118)
    quad_to(ctx, 116, 170, 124, 232)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#764d2f"), OUTLINE, 2.8)
    for cx, cy, cr, col in [(66, 104, 42, "#57753a"), (154, 104, 40, "#57753a"), (110, 74, 54, "#6f9148"), (92, 92, 42, "#7da052")]:
        ctx.arc(cx, cy, cr, 0, math.tau)
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.6)
    save_surf(surf, "props/tree_rj_khejri.png")

    # Flat-topped Umbrella Acacia (Babool)
    surf, ctx = new_surf(250, 210)
    ctx.move_to(114, 202)
    quad_to(ctx, 120, 145, 92, 94)
    ctx.line_to(102, 92)
    ctx.line_to(126, 138)
    ctx.line_to(150, 92)
    ctx.line_to(160, 94)
    quad_to(ctx, 130, 145, 134, 202)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#6b462c"), OUTLINE, 2.8)
    for cx, cy, rw, rh, col in [(125, 86, 108, 32, "#587236"), (92, 74, 72, 26, "#708e45"), (160, 76, 68, 24, "#65843e")]:
        draw_rounded_rect(ctx, cx - rw * 0.5, cy - rh * 0.5, rw, rh, rh * 0.45)
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.6)
    save_surf(surf, "props/tree_rj_acacia.png")

    # Oasis Date Palm
    surf, ctx = new_surf(190, 270)
    ctx.move_to(84, 262)
    quad_to(ctx, 94, 170, 90, 74)
    ctx.line_to(104, 74)
    quad_to(ctx, 108, 170, 106, 262)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#875938"), OUTLINE, 2.8)
    for a in [-2.6, -2.0, -1.2, -0.4, 0.25, 0.78, -3.0]:
        ex, ey = 97 + math.cos(a) * 74, 74 + math.sin(a) * 64 + 18
        mx, my = 97 + math.cos(a) * 38, 74 + math.sin(a) * 32 - 8
        ctx.move_to(97, 74)
        quad_to(ctx, mx, my - 9, ex, ey)
        quad_to(ctx, mx, my + 7, 97, 74)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#5d8a3f"), OUTLINE, 2.2)
    save_surf(surf, "props/tree_rj_date_palm.png")

    # Thorn scrub bush
    surf, ctx = new_surf(150, 95)
    for cx, cy, r, c in [(48, 66, 24, "#6f7d3d"), (102, 66, 24, "#6f7d3d"), (75, 52, 30, "#83934a")]:
        ctx.arc(cx, cy, r, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(c), OUTLINE, 2.4)
    save_surf(surf, "props/bush_rj_thorn_scrub.png")

    # Dry desert tussock grass
    surf, ctx = new_surf(140, 85)
    for bx, bh, lean, c in [(44, 52, -16, "#b8903e"), (68, 62, 2, "#cfa44b"), (92, 48, 16, "#b48a38")]:
        ctx.move_to(bx - 6, 76)
        quad_to(ctx, bx + lean * 0.5, 76 - bh * 0.6, bx + lean, 76 - bh)
        quad_to(ctx, bx + lean * 0.5 + 8, 76 - bh * 0.4, bx + 6, 76)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(c), OUTLINE, 2.2)
    save_surf(surf, "props/bush_rj_dry_grass.png")

    # Carved sandstone wall segment
    surf, ctx = new_surf(210, 90)
    ctx.rectangle(10, 26, 190, 56)
    stroke_fill(ctx, hex_rgba("#d9a268"), OUTLINE, 2.8)
    ctx.rectangle(6, 16, 198, 14)
    stroke_fill(ctx, hex_rgba("#be7c45"), OUTLINE, 2.6)
    save_surf(surf, "props/prop_rj_sandstone_wall.png")

    # Vector Camel Prop
    surf, ctx = new_surf(170, 125)
    for lx in [48, 60, 96, 108]:
        ctx.rectangle(lx, 74, 8, 42)
        stroke_fill(ctx, hex_rgba("#b87c42"), OUTLINE, 2.4)
    ctx.move_to(38, 78)
    ctx.curve_to(34, 46, 62, 22, 82, 22)
    ctx.curve_to(102, 22, 114, 46, 124, 52)
    ctx.curve_to(134, 44, 138, 22, 144, 18)
    ctx.line_to(160, 22)
    ctx.line_to(158, 34)
    ctx.curve_to(146, 36, 142, 66, 122, 80)
    ctx.line_to(44, 80)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#c88a4b"), OUTLINE, 2.8)
    save_surf(surf, "props/prop_rj_camel.png")

    # Foreground desert scrub & rough sandstone rocks (z_index = 2, lower verge only)
    surf, ctx = new_surf(175, 76)
    for bx, bh, lean, c in [(36, 44, -12, "#a9853b"), (52, 52, 4, "#c89f48"), (116, 46, 12, "#b58d3e")]:
        ctx.move_to(bx - 5, 68)
        quad_to(ctx, bx + lean * 0.5, 68 - bh * 0.6, bx + lean, 68 - bh)
        quad_to(ctx, bx + lean * 0.5 + 7, 68 - bh * 0.4, bx + 5, 68)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(c), OUTLINE, 2.0)
    save_surf(surf, "foreground/fg_rj_dry_scrub_1.png")

    surf, ctx = new_surf(185, 74)
    ctx.move_to(24, 64)
    ctx.curve_to(30, 32, 72, 26, 88, 64)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#9c724b"), OUTLINE, 2.4)
    ctx.move_to(74, 64)
    ctx.curve_to(82, 42, 118, 40, 128, 64)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#b88c62"), OUTLINE, 2.2)
    save_surf(surf, "foreground/fg_rj_sandstone_rocks_2.png")


if __name__ == "__main__":
    ensure_dirs()
    gen_skies_and_clouds()
    gen_distant_layers()
    gen_midground_layers()
    gen_custom_landmarks_and_props()
    print("All Rajasthan v3 environment assets generated in:", OUT_DIR)
