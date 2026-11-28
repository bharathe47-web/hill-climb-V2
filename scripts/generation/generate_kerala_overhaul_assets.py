#!/usr/bin/env python3
"""
Generate high-craft 2D vector-illustration assets for the Kerala (Kochi to Munnar) overhaul.
Matches the game's vector art style: bold dark-brown outlines (#3a2315) on landmarks/props,
atmospheric layered backgrounds, seamless 1920px horizontal tiling on all parallax strips.
"""

import math
import os
import random
import cairo

OUT_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "assets", "indian_locations", "kerala", "v3"
)

OUTLINE = (0.227, 0.137, 0.082, 1.0)  # #3a2315


def ensure_dirs():
    for sub in ["", "parallax", "landmarks", "props", "foreground"]:
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


def quad_to(ctx, cx, cy, ex, ey):
    x0, y0 = ctx.get_current_point()
    ctx.curve_to(
        x0 + 2.0 / 3.0 * (cx - x0), y0 + 2.0 / 3.0 * (cy - y0),
        ex + 2.0 / 3.0 * (cx - ex), ey + 2.0 / 3.0 * (cy - ey),
        ex, ey
    )


def stroke_fill(ctx, fill_col, stroke_col=OUTLINE, lw=2.8):
    ctx.set_source_rgba(*fill_col)
    ctx.fill_preserve()
    ctx.set_source_rgba(*stroke_col)
    ctx.set_line_width(lw)
    ctx.set_line_join(cairo.LINE_JOIN_ROUND)
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    ctx.stroke()


def draw_rounded_rect(ctx, x, y, w, h, r):
    r = min(r, w * 0.5, h * 0.5)
    ctx.new_sub_path()
    ctx.arc(x + w - r, y + r, r, -math.pi / 2, 0)
    ctx.arc(x + w - r, y + h - r, r, 0, math.pi / 2)
    ctx.arc(x + r, y + h - r, r, math.pi / 2, math.pi)
    ctx.arc(x + r, y + r, r, math.pi, 3 * math.pi / 2)
    ctx.close_path()


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


# =====================================================================
# 1. SKIES & CLOUDS
# =====================================================================

def gen_skies_and_clouds():
    w, h = 1920, 720
    # Coastal Kerala Sky
    surf, ctx = new_surf(w, h)
    grad = cairo.LinearGradient(0, 0, 0, h)
    grad.add_color_stop_rgba(0.00, *hex_rgba("#1b82d4"))
    grad.add_color_stop_rgba(0.28, *hex_rgba("#46b6f2"))
    grad.add_color_stop_rgba(0.55, *hex_rgba("#9ce6fa"))
    grad.add_color_stop_rgba(0.75, *hex_rgba("#e2f6ec"))
    grad.add_color_stop_rgba(1.00, *hex_rgba("#cbe6d4"))
    ctx.set_source(grad)
    ctx.rectangle(0, 0, w, h)
    ctx.fill()
    sgrad = cairo.RadialGradient(410, 152, 8, 410, 152, 150)
    sgrad.add_color_stop_rgba(0.0, 1.0, 0.99, 0.90, 0.96)
    sgrad.add_color_stop_rgba(0.24, 1.0, 0.97, 0.82, 0.55)
    sgrad.add_color_stop_rgba(0.55, 1.0, 0.96, 0.78, 0.16)
    sgrad.add_color_stop_rgba(1.0, 1.0, 0.96, 0.78, 0.0)
    ctx.set_source(sgrad)
    ctx.arc(410, 152, 150, 0, math.tau)
    ctx.fill()
    save_surf(surf, "parallax/sky_kerala_coastal.png")

    # Highland Munnar Misty Sky
    surf, ctx = new_surf(w, h)
    grad = cairo.LinearGradient(0, 0, 0, h)
    grad.add_color_stop_rgba(0.00, *hex_rgba("#277bc4"))
    grad.add_color_stop_rgba(0.28, *hex_rgba("#5cb4e6"))
    grad.add_color_stop_rgba(0.55, *hex_rgba("#b7e6f2"))
    grad.add_color_stop_rgba(0.78, *hex_rgba("#e8f4ee"))
    grad.add_color_stop_rgba(1.00, *hex_rgba("#d2e6dc"))
    ctx.set_source(grad)
    ctx.rectangle(0, 0, w, h)
    ctx.fill()
    hgrad = cairo.RadialGradient(1380, 148, 8, 1380, 148, 150)
    hgrad.add_color_stop_rgba(0.0, 1.0, 0.99, 0.93, 0.95)
    hgrad.add_color_stop_rgba(0.24, 1.0, 0.98, 0.88, 0.50)
    hgrad.add_color_stop_rgba(0.58, 1.0, 0.98, 0.86, 0.14)
    hgrad.add_color_stop_rgba(1.0, 1.0, 0.98, 0.86, 0.0)
    ctx.set_source(hgrad)
    ctx.arc(1380, 148, 150, 0, math.tau)
    ctx.fill()
    save_surf(surf, "parallax/sky_kerala_highlands.png")

    # Natural crisp vector clouds
    surf, ctx = new_surf(1920, 230)
    specs = [
        (170, 78, 0.85, 0.92), (480, 134, 0.58, 0.82), (790, 66, 1.02, 0.93),
        (1110, 118, 0.66, 0.86), (1410, 68, 0.92, 0.91), (1710, 128, 0.70, 0.84),
        (1910, 82, 0.60, 0.85), (-10, 82, 0.60, 0.85),
    ]
    for cx, cy, sc, al in specs:
        puffs = [
            (-58 * sc, 10 * sc, 26 * sc), (-30 * sc, -6 * sc, 34 * sc),
            (8 * sc, -14 * sc, 40 * sc), (46 * sc, -2 * sc, 30 * sc), (72 * sc, 12 * sc, 22 * sc),
        ]
        ctx.set_source_rgba(0.84, 0.94, 1.0, al)
        for px, py, r in puffs:
            ctx.arc(cx + px, cy + py + 4 * sc, r, 0, math.tau)
        ctx.rectangle(cx - 58 * sc, cy + 4 * sc, 130 * sc, 20 * sc)
        ctx.fill()
        ctx.set_source_rgba(1.0, 1.0, 1.0, al)
        for px, py, r in puffs:
            ctx.arc(cx + px, cy + py - 1 * sc, r * 0.95, 0, math.tau)
        draw_rounded_rect(ctx, cx - 64 * sc, cy + 4 * sc, 140 * sc, 18 * sc, 9 * sc)
        ctx.fill()
    save_surf(surf, "parallax/clouds_kerala.png")


# =====================================================================
# 2. DISTANT BACKGROUNDS (9 KERALA LOCATIONS - 1920x440 SEAMLESS)
# =====================================================================

def draw_sea_band(ctx, w, sea_top, sea_bot, col_top="#1683b4", col_bot="#3ec0dc", seed=1):
    rng = random.Random(seed)
    grad = cairo.LinearGradient(0, sea_top, 0, sea_bot)
    grad.add_color_stop_rgba(0.0, *hex_rgba(col_top))
    grad.add_color_stop_rgba(0.45, *hex_rgba("#22a1c9"))
    grad.add_color_stop_rgba(1.0, *hex_rgba(col_bot))
    ctx.set_source(grad)
    ctx.rectangle(0, sea_top, w, sea_bot - sea_top)
    ctx.fill()
    ctx.set_source_rgba(0.85, 0.97, 1.0, 0.55)
    ctx.rectangle(0, sea_top, w, 2.0)
    ctx.fill()
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    for _ in range(52):
        wx = rng.uniform(20, w - 70)
        wy = rng.uniform(sea_top + 6, sea_bot - 10)
        wl = rng.uniform(20, 56)
        ctx.set_source_rgba(0.88, 0.99, 1.0, rng.uniform(0.25, 0.52))
        ctx.set_line_width(rng.uniform(1.5, 2.4))
        ctx.move_to(wx, wy)
        ctx.line_to(wx + wl, wy)
        ctx.stroke()


def draw_distant_ship(ctx, x, y, sc=1.0):
    ctx.save()
    ctx.translate(x, y)
    ctx.scale(sc, sc)
    # Cargo ship hull
    ctx.move_to(-34, 0)
    ctx.line_to(34, 0)
    ctx.line_to(26, 10)
    ctx.line_to(-28, 10)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba("#7a3722"))
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#f5efe2"))
    ctx.rectangle(-20, -14, 14, 14)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#d15232"))
    ctx.rectangle(-4, -9, 12, 9)
    ctx.set_source_rgba(*hex_rgba("#2e7eb8"))
    ctx.rectangle(10, -9, 12, 9)
    ctx.fill()
    ctx.restore()


def gen_distant_locations():
    w, h = 1920, 440

    # 1. Kochi: Arabian Sea + distant ships + coastal palm island
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 224, 275, [22, 12], [1, 3], [0.4, 1.8], hex_rgba("#529699", 0.72))
    draw_sea_band(ctx, w, 255, h, "#1680b0", "#3bc1dd", 11)
    draw_periodic_ridge(ctx, w, 260, 272, [16, 8], [2, 5], [0.2, 1.5], hex_rgba("#2f704e", 0.92))
    draw_distant_ship(ctx, 360, 268, 0.95)
    draw_distant_ship(ctx, 1340, 266, 0.85)
    save_surf(surf, "parallax/dist_01_kochi.png")

    # 2. Muvattupuzha: Gentle green hills & sunlit village haze
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 200, h, [32, 16, 8], [1, 2, 4], [0.5, 1.4, 2.2], hex_rgba("#649f96", 0.72))
    draw_periodic_ridge(ctx, w, 236, h, [22, 14, 7], [2, 3, 5], [1.7, 0.4, 1.2], hex_rgba("#3e845c", 0.90))
    save_surf(surf, "parallax/dist_02_muvattupuzha.png")

    # 3. Kothamangalam: Forest mountains + Periyar tributary sheen
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 178, h, [44, 22, 10], [1, 2, 4], [0.2, 1.6, 0.7], hex_rgba("#528e8a", 0.78))
    draw_periodic_ridge(ctx, w, 218, h, [32, 18, 9], [2, 3, 5], [1.3, 0.8, 2.1], hex_rgba("#327252", 0.94))
    draw_sea_band(ctx, w, 268, h, "#228aa8", "#3cb1c4", 33)
    save_surf(surf, "parallax/dist_03_kothamangalam.png")

    # 4. Neriamangalam: Periyar River valley + misty Western Ghats mountains
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 155, h, [50, 26, 12], [1, 2, 4], [0.8, 2.0, 0.3], hex_rgba("#5a969c", 0.80))
    mist = cairo.LinearGradient(0, 140, 0, 235)
    mist.add_color_stop_rgba(0.0, 0.88, 0.96, 0.98, 0.0)
    mist.add_color_stop_rgba(0.6, 0.88, 0.96, 0.98, 0.34)
    mist.add_color_stop_rgba(1.0, 0.88, 0.96, 0.98, 0.0)
    ctx.set_source(mist)
    ctx.rectangle(0, 140, w, 95)
    ctx.fill()
    draw_periodic_ridge(ctx, w, 205, h, [36, 18, 10], [2, 3, 5], [1.9, 0.5, 1.7], hex_rgba("#2f6e52", 0.94))
    draw_sea_band(ctx, w, 264, h, "#1d85a6", "#31acc4", 44)
    save_surf(surf, "parallax/dist_04_neriamangalam.png")

    # 5. Valara Waterfalls: Steep green mountain gorge & distant waterfall valley
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 138, h, [56, 28, 14], [1, 2, 4], [0.3, 1.3, 2.5], hex_rgba("#4c848a", 0.82))
    draw_periodic_ridge(ctx, w, 185, h, [42, 22, 11], [2, 3, 5], [1.1, 2.2, 0.6], hex_rgba("#296348", 0.96))
    save_surf(surf, "parallax/dist_05_valara.png")

    # 6. Cheeyappara Waterfalls: Broad rocky gorge mountains + misty spray
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 144, h, [52, 25, 12], [1, 3, 5], [1.2, 0.4, 1.9], hex_rgba("#52888e", 0.82))
    draw_periodic_ridge(ctx, w, 192, h, [38, 20, 10], [2, 4, 6], [0.5, 1.7, 2.4], hex_rgba("#2d6648", 0.96))
    save_surf(surf, "parallax/dist_06_cheeyappara.png")

    # 7. Adimali: Cardamom Hills layered green mountains
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 146, h, [48, 26, 12], [1, 2, 4], [0.9, 1.5, 0.2], hex_rgba("#5a9690", 0.80))
    draw_periodic_ridge(ctx, w, 198, h, [36, 18, 9], [2, 3, 5], [2.1, 0.6, 1.4], hex_rgba("#387b53", 0.95))
    save_surf(surf, "parallax/dist_07_adimali.png")

    # 8. Pallivasal: Rolling tea-slope mountain valleys & mist
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 136, h, [56, 28, 12], [1, 2, 4], [0.4, 2.1, 0.9], hex_rgba("#5e9aa0", 0.80))
    mist = cairo.LinearGradient(0, 130, 0, 240)
    mist.add_color_stop_rgba(0.0, 0.92, 0.97, 0.98, 0.0)
    mist.add_color_stop_rgba(0.6, 0.92, 0.97, 0.98, 0.36)
    mist.add_color_stop_rgba(1.0, 0.92, 0.97, 0.98, 0.0)
    ctx.set_source(mist)
    ctx.rectangle(0, 130, w, 110)
    ctx.fill()
    draw_periodic_ridge(ctx, w, 192, h, [38, 20, 10], [2, 3, 5], [1.4, 0.3, 2.2], hex_rgba("#418951", 0.95))
    save_surf(surf, "parallax/dist_08_pallivasal.png")

    # 9. Munnar: Majestic Anamudi peaks + layered Western Ghats + highland cloud mist
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, 122, h, [64, 32, 16], [1, 2, 4], [0.2, 1.8, 0.6], hex_rgba("#649eb0", 0.82))
    draw_periodic_ridge(ctx, w, 166, h, [48, 24, 12], [2, 3, 5], [1.5, 0.4, 2.0], hex_rgba("#46857c", 0.90))
    mist = cairo.LinearGradient(0, 150, 0, 260)
    mist.add_color_stop_rgba(0.0, 0.94, 0.98, 1.0, 0.0)
    mist.add_color_stop_rgba(0.55, 0.94, 0.98, 1.0, 0.42)
    mist.add_color_stop_rgba(1.0, 0.94, 0.98, 1.0, 0.0)
    ctx.set_source(mist)
    ctx.rectangle(0, 150, w, 110)
    ctx.fill()
    draw_periodic_ridge(ctx, w, 210, h, [34, 18, 9], [2, 4, 6], [0.8, 1.9, 0.4], hex_rgba("#388749", 0.98))
    save_surf(surf, "parallax/dist_09_munnar.png")


# =====================================================================
# 3. MIDGROUND SCENERY (9 KERALA LOCATIONS - 1920x420 SEAMLESS)
# =====================================================================

def draw_mid_palm(ctx, bx, by, height, lean_x, frond_col="#348846"):
    tx, ty = bx + lean_x, by - height
    cx, cy = bx + lean_x * 0.35, by - height * 0.55
    ctx.move_to(bx - 5.5, by)
    quad_to(ctx, cx - 3.5, cy, tx - 2.2, ty)
    ctx.line_to(tx + 2.2, ty)
    quad_to(ctx, cx + 3.5, cy, bx + 5.5, by)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba("#7a5033"))
    ctx.fill()
    for a in [-2.6, -2.05, -1.35, -0.55, 0.15, 0.72, -3.05]:
        fl = height * 0.34
        ex, ey = tx + math.cos(a) * fl, ty + math.sin(a) * fl + fl * 0.32
        mx, my = tx + math.cos(a) * fl * 0.52, ty + math.sin(a) * fl * 0.42 - 8
        ctx.move_to(tx, ty)
        quad_to(ctx, mx, my - 7, ex, ey)
        quad_to(ctx, mx, my + 5, tx, ty)
        ctx.close_path()
        ctx.set_source_rgba(*hex_rgba(frond_col))
        ctx.fill()


def draw_mid_tree(ctx, bx, by, r, col_dark="#266438", col_light="#3f904b"):
    ctx.set_source_rgba(*hex_rgba("#67422a"))
    ctx.rectangle(bx - r * 0.13, by - r * 0.9, r * 0.26, r * 0.9)
    ctx.fill()
    for dx, dy, rr, c in [
        (-r * 0.55, -r * 0.95, r * 0.62, col_dark),
        (r * 0.55, -r * 0.92, r * 0.58, col_dark),
        (0, -r * 1.25, r * 0.72, col_light),
        (-r * 0.26, -r * 1.05, r * 0.54, col_light),
    ]:
        ctx.set_source_rgba(*hex_rgba(c))
        ctx.arc(bx + dx, by + dy, rr, 0, math.tau)
        ctx.fill()


def draw_mid_rubber_tree(ctx, bx, by, h_tree):
    # Tall slender pale-grey bark rubber trunk + natural airy foliage crown
    ctx.set_source_rgba(*hex_rgba("#8b8378"))
    ctx.rectangle(bx - 4, by - h_tree * 0.68, 8, h_tree * 0.68)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#3a281e"))
    ctx.rectangle(bx - 5, by - h_tree * 0.28, 10, 4)
    ctx.fill()
    ty = by - h_tree * 0.74
    lobes = [(-26, 8, 22, "#246636"), (25, 9, 21, "#246636"), (-14, -10, 23, "#2f7b40"), (15, -8, 22, "#358645"), (0, -20, 24, "#43994e")]
    for dx, dy, rr, col in lobes:
        ctx.set_source_rgba(*hex_rgba(col))
        ctx.arc(bx + dx, ty + dy, rr, 0, math.tau)
        ctx.fill()


def draw_mid_bamboo(ctx, bx, by, h_b):
    for off, lean, col in [(-12, -10, "#4f9a44"), (-4, -3, "#60ad4e"), (5, 4, "#4b9440"), (13, 12, "#62b050")]:
        ctx.set_source_rgba(*hex_rgba(col))
        ctx.set_line_width(4.2)
        ctx.move_to(bx + off, by)
        quad_to(ctx, bx + off + lean * 0.5, by - h_b * 0.5, bx + off + lean, by - h_b)
        ctx.stroke()
        # Leaf tufts
        tx, ty = bx + off + lean, by - h_b
        for a in [-2.3, -1.5, -0.7, 0.2]:
            ctx.move_to(tx, ty)
            ctx.line_to(tx + math.cos(a) * 22, ty + math.sin(a) * 14)
            ctx.line_to(tx + math.cos(a) * 10, ty + math.sin(a) * 8 + 4)
            ctx.close_path()
            ctx.fill()


def draw_mid_eucalyptus(ctx, bx, by, h_tree):
    # Tall slender white-grey eucalyptus trunk & airy asymmetric highland canopy
    ctx.set_source_rgba(*hex_rgba("#adb7b2"))
    ctx.move_to(bx - 5, by)
    quad_to(ctx, bx + 4, by - h_tree * 0.5, bx - 1.5, by - h_tree)
    ctx.line_to(bx + 2.5, by - h_tree)
    quad_to(ctx, bx + 7, by - h_tree * 0.5, bx + 4, by)
    ctx.close_path()
    ctx.fill()
    for dx, fy, rw, rh, col in [
        (-12, by - h_tree * 0.65, 22, 14, "#2d6f54"),
        (14, by - h_tree * 0.72, 24, 15, "#368061"),
        (-8, by - h_tree * 0.85, 26, 15, "#3f8e6b"),
        (6, by - h_tree * 0.96, 22, 13, "#499c75"),
    ]:
        ctx.save()
        ctx.translate(bx + dx, fy)
        ctx.scale(1.0, rh / rw)
        ctx.set_source_rgba(*hex_rgba(col))
        ctx.arc(0, 0, rw, 0, math.tau)
        ctx.fill()
        ctx.restore()


def gen_midground_locations():
    w, h = 1920, 420
    gy = 258

    # 1. Kochi: Harbour edge, fishing boats, coconut groves
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 2, h, [8, 4], [2, 5], [0.4, 1.6], hex_rgba("#3e8446"))
    draw_periodic_ridge(ctx, w, gy + 6, h, [5, 3], [3, 6], [1.1, 2.3], hex_rgba("#4c984b"))
    for bx in [250, 740, 1210, 1680]:
        ctx.set_source_rgba(*hex_rgba("#8a4b29"))
        ctx.move_to(bx - 36, gy - 6)
        ctx.line_to(bx + 36, gy - 6)
        ctx.line_to(bx + 24, gy + 6)
        ctx.line_to(bx - 24, gy + 6)
        ctx.close_path()
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#f5efe0"))
        ctx.rectangle(bx - 16, gy - 18, 28, 12)
        ctx.fill()
    for tx, th, lean in [(90, 165, 22), (140, 138, -16), (440, 175, 24), (620, 150, -18), (930, 170, 20), (1080, 145, -15), (1440, 172, 22), (1810, 158, -18)]:
        draw_mid_palm(ctx, tx, gy, th, lean)
    for tx, tr in [(340, 36), (840, 42), (1340, 38), (1580, 40)]:
        draw_mid_tree(ctx, tx, gy, tr)
    save_surf(surf, "parallax/mid_01_kochi.png")

    # 2. Muvattupuzha: Paddy fields, rubber plantations, coconut & banana
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 18, h, [10, 5], [2, 5], [0.2, 1.9], hex_rgba("#64b54a"))  # Bright paddy terrace
    draw_periodic_ridge(ctx, w, gy + 2, h, [6, 3], [3, 6], [1.4, 0.5], hex_rgba("#428e45"))
    for rx in range(110, w, 155):
        draw_mid_rubber_tree(ctx, rx, gy, 150 + (rx % 3) * 14)
    for tx, th, lean in [(60, 168, 20), (540, 160, -18), (1020, 174, 22), (1480, 162, -20)]:
        draw_mid_palm(ctx, tx, gy, th, lean)
    save_surf(surf, "parallax/mid_02_muvattupuzha.png")

    # 3. Kothamangalam: Dense forest, bamboo clusters, riverbanks
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 26, h, [22, 12], [2, 4], [0.5, 1.8], hex_rgba("#27623a"))
    draw_periodic_ridge(ctx, w, gy, h, [10, 5], [3, 6], [1.6, 0.4], hex_rgba("#388145"))
    for i in range(18):
        tx = 55 + i * 106
        if i % 3 == 1:
            draw_mid_bamboo(ctx, tx, gy, 155 + (i % 4) * 12)
        else:
            draw_mid_tree(ctx, tx, gy, 48 + (i % 3) * 10, "#215934", "#378844")
    save_surf(surf, "parallax/mid_03_kothamangalam.png")

    # 4. Neriamangalam: Rainforest + rocky Periyar riverbanks
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 20, h, [18, 9], [2, 5], [0.9, 2.0], hex_rgba("#255e38"))
    draw_periodic_ridge(ctx, w, gy + 4, h, [8, 4], [3, 7], [0.3, 1.5], hex_rgba("#3a7e44"))
    for i in range(18):
        tx = 60 + i * 104
        draw_mid_tree(ctx, tx, gy, 50 + (i % 3) * 12, "#1f5432", "#358042")
        if i % 4 == 0:
            draw_mid_palm(ctx, tx + 38, gy, 165, 18)
    save_surf(surf, "parallax/mid_04_neriamangalam.png")

    # 5. Valara Waterfalls Corridor: Lush misty Western Ghats forest cliffs + gorge stream (non-repetitive!)
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 68, h, [42, 18], [2, 5], [0.3, 1.7], hex_rgba("#225638"))
    draw_periodic_ridge(ctx, w, gy - 26, h, [26, 12], [3, 6], [1.1, 0.4], hex_rgba("#2b6a3e"))
    # Soft canyon mist blanket across lower forest slopes
    mgrad = cairo.LinearGradient(0, gy - 120, 0, gy + 20)
    mgrad.add_color_stop_rgba(0.0, 0.88, 0.96, 1.0, 0.0)
    mgrad.add_color_stop_rgba(0.55, 0.90, 0.97, 1.0, 0.28)
    mgrad.add_color_stop_rgba(1.0, 0.90, 0.97, 1.0, 0.0)
    ctx.set_source(mgrad)
    ctx.rectangle(0, gy - 120, w, 140)
    ctx.fill()
    draw_periodic_ridge(ctx, w, gy + 2, h, [12, 5], [3, 6], [1.2, 0.7], hex_rgba("#3b8747"))
    for i in range(18):
        tx = 55 + i * 106
        draw_mid_tree(ctx, tx, gy, 48 + (i % 3) * 11, "#1f5532", "#358543")
        if i % 5 == 0:
            draw_mid_bamboo(ctx, tx + 42, gy, 145)
    save_surf(surf, "parallax/mid_05_valara.png")

    # 6. Cheeyappara Waterfalls Corridor: Deep emerald Ghats rainforest canopy + mossy rock ridges
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 72, h, [40, 20], [2, 4], [0.8, 2.2], hex_rgba("#1f5335"))
    draw_periodic_ridge(ctx, w, gy - 28, h, [24, 11], [3, 6], [0.5, 1.4], hex_rgba("#29663d"))
    mgrad2 = cairo.LinearGradient(0, gy - 130, 0, gy + 20)
    mgrad2.add_color_stop_rgba(0.0, 0.90, 0.97, 1.0, 0.0)
    mgrad2.add_color_stop_rgba(0.60, 0.92, 0.98, 1.0, 0.30)
    mgrad2.add_color_stop_rgba(1.0, 0.92, 0.98, 1.0, 0.0)
    ctx.set_source(mgrad2)
    ctx.rectangle(0, gy - 130, w, 150)
    ctx.fill()
    draw_periodic_ridge(ctx, w, gy + 4, h, [10, 4], [3, 6], [0.5, 2.1], hex_rgba("#3b8847"))
    for i in range(18):
        tx = 45 + i * 106
        draw_mid_tree(ctx, tx, gy, 50 + (i % 3) * 12, "#1e5130", "#348341")
        if i % 4 == 2:
            draw_mid_rubber_tree(ctx, tx + 44, gy, 150)
        draw_mid_tree(ctx, tx, gy, 48, "#235c36", "#3a8c46")
    save_surf(surf, "parallax/mid_06_cheeyappara.png")

    # 7. Adimali: Cardamom & pepper spice gardens under lush shade trees
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 22, h, [16, 8], [2, 5], [0.7, 1.4], hex_rgba("#307041"))
    draw_periodic_ridge(ctx, w, gy + 4, h, [8, 4], [3, 7], [1.9, 0.6], hex_rgba("#44934a"))
    for i in range(16):
        tx = 65 + i * 118
        draw_mid_tree(ctx, tx, gy, 46 + (i % 3) * 10, "#245f36", "#3e8d47")
        # Pepper vine spirals on trunk
        ctx.set_source_rgba(*hex_rgba("#62b84c"))
        ctx.set_line_width(4.0)
        ctx.move_to(tx - 5, gy - 4)
        ctx.line_to(tx + 5, gy - 28)
        ctx.line_to(tx - 4, gy - 50)
        ctx.stroke()
    save_surf(surf, "parallax/mid_07_adimali.png")

    # 8. Pallivasal: Rolling terraced tea plantation hills!
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 54, h, [32, 16], [2, 4], [0.3, 1.5], hex_rgba("#3b8a47"))
    draw_periodic_ridge(ctx, w, gy - 28, h, [20, 10], [3, 5], [1.5, 0.4], hex_rgba("#52a84e"))
    draw_periodic_ridge(ctx, w, gy - 4, h, [12, 6], [2, 6], [0.8, 2.2], hex_rgba("#3c8c46"))
    # Seamless contoured tea rows
    for row_off, rcol in [(-38, "#67bd56"), (-22, "#4aa049"), (-8, "#6dc55a")]:
        ctx.set_source_rgba(*hex_rgba(rcol, 0.88))
        ctx.set_line_width(6.0)
        for i in range(65):
            x = i * (w / 64.0)
            y = gy + row_off - 12 * math.sin(i / 64.0 * math.tau * 2 + 0.5)
            if i == 0:
                ctx.move_to(x, y)
            else:
                ctx.line_to(x, y)
        ctx.stroke()
    for tx in [180, 620, 1080, 1520]:
        draw_mid_eucalyptus(ctx, tx, gy - 12, 152)
    save_surf(surf, "parallax/mid_08_pallivasal.png")

    # 9. Munnar: Endless rolling emerald tea gardens + eucalyptus + distant tea factory!
    surf, ctx = new_surf(w, h)
    draw_periodic_ridge(ctx, w, gy - 68, h, [38, 18, 8], [2, 4, 6], [0.6, 1.8, 0.3], hex_rgba("#368646"))
    draw_periodic_ridge(ctx, w, gy - 42, h, [26, 14], [3, 5], [1.9, 0.7], hex_rgba("#4ca64d"))
    draw_periodic_ridge(ctx, w, gy - 16, h, [16, 8], [2, 4], [0.2, 1.4], hex_rgba("#5ebc54"))
    draw_periodic_ridge(ctx, w, gy + 4, h, [8, 4], [3, 6], [1.2, 2.4], hex_rgba("#3e9347"))
    # Distant colonial tea factory on hillside at x=940
    ctx.set_source_rgba(*hex_rgba("#f5efe2"))
    ctx.rectangle(900, gy - 72, 92, 34)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#c6492b"))
    ctx.move_to(892, gy - 72)
    ctx.line_to(946, gy - 94)
    ctx.line_to(1000, gy - 72)
    ctx.close_path()
    ctx.fill()
    # Seamless contoured manicured tea bush rows + scalloped tea-bush domes
    for row_off, rcol in [(-48, "#6cc658"), (-30, "#4ea44a"), (-14, "#74cf5e")]:
        ctx.set_source_rgba(*hex_rgba(rcol, 0.90))
        ctx.set_line_width(7.0)
        for i in range(65):
            x = i * (w / 64.0)
            y = gy + row_off - 15 * math.sin(i / 64.0 * math.tau * 2 + 1.0)
            if i == 0:
                ctx.move_to(x, y)
            else:
                ctx.line_to(x, y)
        ctx.stroke()
    for tx, th in [(130, 175), (440, 158), (720, 170), (1180, 182), (1490, 160), (1810, 174)]:
        draw_mid_eucalyptus(ctx, tx, gy - 8, th)
    save_surf(surf, "parallax/mid_09_munnar.png")


# =====================================================================
# 4. AUTHENTIC KERALA LANDMARKS (OUTLINED VECTOR STYLE)
# =====================================================================

def draw_kerala_tiled_roof(ctx, x1, y1, x2, y2, xp, yp, col="#b84226"):
    ctx.move_to(x1, y1)
    ctx.line_to(xp, yp)
    ctx.line_to(x2, y2)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba(col), OUTLINE, 3.0)
    ctx.set_source_rgba(*hex_rgba("#8a2c16", 0.55))
    ctx.set_line_width(1.8)
    for k in range(1, 8):
        t = k / 8.0
        ctx.move_to(xp, yp)
        ctx.line_to(x1 + (x2 - x1) * t, y1 + (y2 - y1) * t)
        ctx.stroke()
    ctx.move_to(x1, y1)
    ctx.line_to(xp, yp)
    ctx.line_to(x2, y2)
    ctx.close_path()
    ctx.set_source_rgba(*OUTLINE)
    ctx.set_line_width(3.0)
    ctx.stroke()


def gen_landmarks():
    # 1. Fort Kochi Chinese Fishing Nets (Cheena Vala)
    surf, ctx = new_surf(540, 440)
    # Harbour water base
    ctx.rectangle(20, 370, 500, 54)
    stroke_fill(ctx, hex_rgba("#2396be"), OUTLINE, 3.0)
    # Timber jetty dock
    ctx.rectangle(28, 326, 220, 22)
    stroke_fill(ctx, hex_rgba("#9c6334"), OUTLINE, 2.8)
    for px in [52, 118, 198]:
        ctx.rectangle(px, 348, 16, 46)
        stroke_fill(ctx, hex_rgba("#7a4a24"), OUTLINE, 2.6)
    # Cantilevered teak poles (pivoted on jetty)
    ctx.set_source_rgba(*OUTLINE)
    ctx.set_line_width(14.0)
    ctx.move_to(110, 326)
    ctx.line_to(356, 72)
    ctx.move_to(210, 326)
    ctx.line_to(356, 72)
    ctx.stroke()
    ctx.set_source_rgba(*hex_rgba("#8c552c"))
    ctx.set_line_width(8.0)
    ctx.move_to(110, 326)
    ctx.line_to(356, 72)
    ctx.move_to(210, 326)
    ctx.line_to(356, 72)
    ctx.stroke()
    # Cross spreader arms
    ctx.set_source_rgba(*OUTLINE)
    ctx.set_line_width(9.0)
    ctx.move_to(356, 72)
    ctx.line_to(478, 178)
    ctx.move_to(356, 72)
    ctx.line_to(286, 194)
    ctx.stroke()
    ctx.set_source_rgba(*hex_rgba("#9e6234"))
    ctx.set_line_width(5.0)
    ctx.move_to(356, 72)
    ctx.line_to(478, 178)
    ctx.move_to(356, 72)
    ctx.line_to(286, 194)
    ctx.stroke()
    # Curved fishing net mesh
    ctx.move_to(286, 194)
    quad_to(ctx, 382, 265, 478, 178)
    ctx.line_to(436, 358)
    quad_to(ctx, 370, 368, 304, 358)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#9fd9e8", 0.58), OUTLINE, 2.4)
    # Counterweight stones hanging on ropes
    for sx, sy in [(84, 290), (118, 256), (154, 224)]:
        ctx.set_source_rgba(*OUTLINE)
        ctx.set_line_width(2.2)
        ctx.move_to(sx + 24, sy - 26)
        ctx.line_to(sx, sy)
        ctx.stroke()
        ctx.arc(sx, sy + 8, 12, 0, math.tau)
        stroke_fill(ctx, hex_rgba("#6c6f73"), OUTLINE, 2.4)
    save_surf(surf, "landmarks/lm_chinese_fishing_nets.png")

    # 2. Mattancherry Dutch Palace
    surf, ctx = new_surf(560, 390)
    ctx.rectangle(26, 344, 508, 30)
    stroke_fill(ctx, hex_rgba("#9c4f32"), OUTLINE, 3.0)
    ctx.rectangle(44, 186, 472, 158)
    stroke_fill(ctx, hex_rgba("#f6efe0"), OUTLINE, 3.2)
    # Central upper gable & Mangalore tiled roof
    draw_kerala_tiled_roof(ctx, 20, 188, 540, 188, 280, 74, "#be4727")
    ctx.rectangle(210, 118, 140, 70)
    stroke_fill(ctx, hex_rgba("#f6efe0"), OUTLINE, 2.8)
    draw_kerala_tiled_roof(ctx, 192, 120, 368, 120, 280, 60, "#c84f2c")
    # Wooden arched windows
    for wx in [82, 142, 202, 316, 376, 436]:
        ctx.rectangle(wx, 226, 32, 54)
        ctx.arc(wx + 16, 226, 16, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#5c331c"), OUTLINE, 2.4)
    ctx.rectangle(256, 242, 48, 102)
    ctx.arc(280, 242, 24, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#4c2915"), OUTLINE, 2.8)
    save_surf(surf, "landmarks/lm_mattancherry_palace.png")

    # 3. Santa Cruz Basilica & St. Francis Church (Kochi)
    surf, ctx = new_surf(520, 480)
    ctx.rectangle(24, 444, 472, 24)
    stroke_fill(ctx, hex_rgba("#a85234"), OUTLINE, 3.0)
    ctx.rectangle(104, 156, 312, 288)
    stroke_fill(ctx, hex_rgba("#fbf7ee"), OUTLINE, 3.2)
    # Twin side towers
    for tx in [76, 376]:
        ctx.rectangle(tx, 106, 68, 338)
        stroke_fill(ctx, hex_rgba("#fbf7ee"), OUTLINE, 3.0)
        ctx.move_to(tx - 6, 106)
        ctx.line_to(tx + 34, 46)
        ctx.line_to(tx + 74, 106)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#cc502c"), OUTLINE, 2.8)
    # Central ornate gable + golden cross
    ctx.move_to(170, 156)
    ctx.line_to(260, 74)
    ctx.line_to(350, 156)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#fbf7ee"), OUTLINE, 3.0)
    ctx.set_source_rgba(*OUTLINE)
    ctx.set_line_width(4.0)
    ctx.move_to(260, 74)
    ctx.line_to(260, 40)
    ctx.move_to(248, 54)
    ctx.line_to(272, 54)
    ctx.stroke()
    # Pastel blue trim arches & rose window
    ctx.arc(260, 210, 26, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#4c8ec4"), OUTLINE, 2.6)
    for dx in [186, 260, 334]:
        ctx.rectangle(dx - 22, 334, 44, 110)
        ctx.arc(dx, 334, 22, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#5c341c"), OUTLINE, 2.6)
    save_surf(surf, "landmarks/lm_santa_cruz_st_francis.png")

    # 4. Chottanikkara Bhagavathy Temple (Kerala Nalambalam style)
    surf, ctx = new_surf(560, 440)
    ctx.rectangle(24, 402, 512, 26)
    stroke_fill(ctx, hex_rgba("#9c492e"), OUTLINE, 3.0)
    # Outer whitewashed nalambalam wall with red & black bands
    ctx.rectangle(46, 276, 468, 126)
    stroke_fill(ctx, hex_rgba("#fbf5e8"), OUTLINE, 3.0)
    ctx.rectangle(46, 358, 468, 18)
    stroke_fill(ctx, hex_rgba("#c84a2a"), OUTLINE, 2.2)
    draw_kerala_tiled_roof(ctx, 28, 278, 532, 278, 280, 198, "#be4827")
    # Two-tier golden-copper gopuram sanctum rising behind
    ctx.rectangle(196, 146, 168, 132)
    stroke_fill(ctx, hex_rgba("#fbf5e8"), OUTLINE, 3.0)
    draw_kerala_tiled_roof(ctx, 170, 148, 390, 148, 280, 72, "#d4882a")
    # Golden kalasam finial
    ctx.arc(280, 58, 12, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#f5ca3e"), OUTLINE, 2.6)
    # Brass Deepastambham lamp pillar
    ctx.rectangle(268, 294, 24, 108)
    stroke_fill(ctx, hex_rgba("#e8b236"), OUTLINE, 2.6)
    for ly in [306, 330, 354]:
        ctx.rectangle(256, ly, 48, 8)
        stroke_fill(ctx, hex_rgba("#f7ce46"), OUTLINE, 2.0)
    save_surf(surf, "landmarks/lm_chottanikkara_temple.png")

    # 5. Sree Poornathrayeesa Temple
    surf, ctx = new_surf(560, 440)
    ctx.rectangle(26, 402, 508, 26)
    stroke_fill(ctx, hex_rgba("#9c492e"), OUTLINE, 3.0)
    ctx.rectangle(60, 264, 440, 138)
    stroke_fill(ctx, hex_rgba("#faf2de"), OUTLINE, 3.2)
    draw_kerala_tiled_roof(ctx, 40, 266, 520, 266, 280, 178, "#b84326")
    # Ornamental tiered gopuram tower
    ctx.rectangle(206, 136, 148, 128)
    stroke_fill(ctx, hex_rgba("#f5c244"), OUTLINE, 3.0)
    draw_kerala_tiled_roof(ctx, 184, 138, 376, 138, 280, 62, "#c84b29")
    ctx.arc(280, 48, 12, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#f7d44c"), OUTLINE, 2.5)
    # Grand arched gateway
    ctx.rectangle(246, 304, 68, 98)
    ctx.arc(280, 304, 34, math.pi, 0)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#4c2a16"), OUTLINE, 2.8)
    save_surf(surf, "landmarks/lm_poornathrayeesa_temple.png")

    # 6. Marthoma Cheriapally & St. George Forane Church (Kerala Christian Heritage)
    surf, ctx = new_surf(520, 460)
    ctx.rectangle(26, 424, 468, 24)
    stroke_fill(ctx, hex_rgba("#9c4a30"), OUTLINE, 3.0)
    ctx.rectangle(80, 166, 360, 258)
    stroke_fill(ctx, hex_rgba("#fdfbf5"), OUTLINE, 3.2)
    # Ornate curved Kerala Baroque pediment gable
    ctx.move_to(80, 166)
    quad_to(ctx, 170, 108, 260, 64)
    quad_to(ctx, 350, 108, 440, 166)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#fdfbf5"), OUTLINE, 3.2)
    # Golden trim & cross
    ctx.set_source_rgba(*OUTLINE)
    ctx.set_line_width(4.0)
    ctx.move_to(260, 64)
    ctx.line_to(260, 30)
    ctx.move_to(248, 44)
    ctx.line_to(272, 44)
    ctx.stroke()
    for dx in [168, 260, 352]:
        ctx.rectangle(dx - 20, 316, 40, 108)
        ctx.arc(dx, 316, 20, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#5c331b"), OUTLINE, 2.6)
    for wx in [168, 260, 352]:
        ctx.rectangle(wx - 14, 210, 28, 46)
        ctx.arc(wx, 210, 14, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#3870a6"), OUTLINE, 2.4)
    save_surf(surf, "landmarks/lm_st_george_forane.png")

    # 7. Aluva Mahadeva Temple (Periyar riverbank Shiva shrine)
    surf, ctx = new_surf(520, 420)
    # Stone ghat steps & water rim
    ctx.rectangle(20, 376, 480, 32)
    stroke_fill(ctx, hex_rgba("#248eb6"), OUTLINE, 2.8)
    ctx.rectangle(38, 344, 444, 34)
    stroke_fill(ctx, hex_rgba("#b89c78"), OUTLINE, 2.8)
    # Circular/conical copper-roofed srikovil
    ctx.rectangle(160, 206, 200, 138)
    stroke_fill(ctx, hex_rgba("#fbf4e4"), OUTLINE, 3.0)
    draw_kerala_tiled_roof(ctx, 118, 212, 402, 212, 260, 76, "#be5329")
    ctx.arc(260, 62, 13, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#f5ca3e"), OUTLINE, 2.6)
    ctx.rectangle(234, 256, 52, 88)
    stroke_fill(ctx, hex_rgba("#4e2b16"), OUTLINE, 2.8)
    save_surf(surf, "landmarks/lm_aluva_mahadeva_temple.png")

    # 8. Valara Waterfall Roadside Cliff Showcase (organic faceted rock & lush tropical hanging greenery)
    surf, ctx = new_surf(480, 520)
    ctx.move_to(24, 496)
    ctx.line_to(48, 320)
    ctx.line_to(38, 195)
    ctx.line_to(74, 62)
    ctx.line_to(146, 26)
    ctx.line_to(334, 28)
    ctx.line_to(408, 72)
    ctx.line_to(438, 210)
    ctx.line_to(426, 350)
    ctx.line_to(456, 496)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#465451"), OUTLINE, 3.2)
    # Rocky cliff highlight & moss facets
    ctx.move_to(56, 480)
    ctx.line_to(90, 115)
    ctx.line_to(162, 68)
    ctx.line_to(180, 480)
    ctx.close_path()
    ctx.set_source_rgba(*hex_rgba("#384543"))
    ctx.fill()
    # Cascading roaring water torrent
    wgrad_v = cairo.LinearGradient(0, 34, 0, 485)
    wgrad_v.add_color_stop_rgba(0.0, *hex_rgba("#e8faff"))
    wgrad_v.add_color_stop_rgba(0.55, *hex_rgba("#ffffff"))
    wgrad_v.add_color_stop_rgba(1.0, *hex_rgba("#b9effd"))
    ctx.set_source(wgrad_v)
    ctx.move_to(182, 34)
    ctx.line_to(298, 34)
    ctx.line_to(322, 482)
    ctx.line_to(158, 482)
    ctx.close_path()
    ctx.fill_preserve()
    ctx.set_source_rgba(*OUTLINE)
    ctx.set_line_width(2.4)
    ctx.stroke()
    for sx in [196, 224, 254, 282]:
        ctx.set_source_rgba(*hex_rgba("#76cce6", 0.72))
        ctx.set_line_width(3.2)
        ctx.move_to(sx, 50)
        ctx.line_to(sx + (sx - 240) * 0.14, 470)
        ctx.stroke()
    # Organic foliage clusters framing top and flanks
    for bx, by, br, col in [
        (92, 74, 42, "#2f783f"), (134, 46, 36, "#43994d"),
        (384, 80, 44, "#2f783f"), (342, 48, 36, "#43994d"),
        (68, 250, 38, "#296d38"), (410, 265, 40, "#296d38"),
        (56, 405, 44, "#3b8d47"), (422, 412, 44, "#3b8d47"),
    ]:
        ctx.arc(bx, by, br, 0, math.tau)
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.4)
    for mx, mr in [(152, 24), (192, 30), (240, 34), (288, 30), (328, 24)]:
        ctx.arc(mx, 486, mr, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#ffffff"), OUTLINE, 2.0)
    save_surf(surf, "landmarks/lm_valara_falls_showcase.png")

    # 9. Cheeyappara 7-Tier Stepped Waterfall Showcase (sculpted stepped rock outcrop + frothy tiers)
    surf, ctx = new_surf(560, 480)
    ctx.move_to(22, 456)
    ctx.line_to(48, 320)
    ctx.line_to(72, 165)
    ctx.line_to(112, 42)
    ctx.line_to(448, 42)
    ctx.line_to(490, 170)
    ctx.line_to(512, 325)
    ctx.line_to(538, 456)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#46524f"), OUTLINE, 3.2)
    for i in range(6):
        sy = 54 + i * 64
        sw = 138 + i * 46
        draw_rounded_rect(ctx, 280 - sw * 0.5, sy, sw, 48, 10)
        stroke_fill(ctx, hex_rgba("#effcff"), OUTLINE, 2.2)
        ctx.set_source_rgba(*hex_rgba("#87d4eb", 0.65))
        ctx.set_line_width(2.4)
        for vx in range(int(280 - sw * 0.38), int(280 + sw * 0.40), 26):
            ctx.move_to(vx, sy + 6)
            ctx.line_to(vx, sy + 42)
            ctx.stroke()
        draw_rounded_rect(ctx, 280 - sw * 0.52, sy + 45, sw * 1.04, 15, 5)
        stroke_fill(ctx, hex_rgba("#515c5a"), OUTLINE, 2.0)
    for bx, by, br, col in [
        (106, 78, 40, "#2c743d"), (454, 78, 40, "#2c743d"),
        (72, 220, 42, "#388844"), (488, 220, 42, "#388844"),
        (48, 385, 44, "#40944b"), (512, 385, 44, "#40944b"),
    ]:
        ctx.arc(bx, by, br, 0, math.tau)
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.4)
    save_surf(surf, "landmarks/lm_cheeyappara_falls_showcase.png")

    # 10. Adimali Spice & Cardamom Estate
    surf, ctx = new_surf(480, 360)
    ctx.rectangle(24, 326, 432, 22)
    stroke_fill(ctx, hex_rgba("#8e4c2e"), OUTLINE, 3.0)
    ctx.rectangle(54, 174, 372, 152)
    stroke_fill(ctx, hex_rgba("#f5ead2"), OUTLINE, 3.0)
    draw_kerala_tiled_roof(ctx, 32, 176, 448, 176, 240, 82, "#c24c2b")
    for sx, col in [(110, "#50a84c"), (190, "#d89c2e"), (280, "#b8442c"), (360, "#4e9444")]:
        ctx.arc(sx, 294, 24, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.4)
    ctx.rectangle(160, 198, 160, 42)
    stroke_fill(ctx, hex_rgba("#245e3e"), OUTLINE, 2.4)
    save_surf(surf, "landmarks/lm_adimali_spice_estate.png")

    # 11. Munnar Colonial Tea Estate Factory & Hills
    surf, ctx = new_surf(580, 400)
    # Contoured green tea hills behind factory
    ctx.move_to(20, 372)
    quad_to(ctx, 160, 210, 320, 270)
    quad_to(ctx, 440, 190, 560, 372)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#46a24b"), OUTLINE, 3.0)
    # Colonial red-roofed tea factory
    ctx.rectangle(116, 166, 348, 194)
    stroke_fill(ctx, hex_rgba("#faf4e6"), OUTLINE, 3.2)
    draw_kerala_tiled_roof(ctx, 94, 168, 486, 168, 290, 76, "#c44428")
    for wx in range(148, 440, 56):
        ctx.rectangle(wx, 206, 32, 46)
        stroke_fill(ctx, hex_rgba("#385866"), OUTLINE, 2.2)
    ctx.rectangle(262, 278, 56, 82)
    stroke_fill(ctx, hex_rgba("#5c341b"), OUTLINE, 2.6)
    save_surf(surf, "landmarks/lm_munnar_tea_factory.png")


# =====================================================================
# 5. ROADSIDE PROPS, HOUSES, TREES & FOREGROUND (KERALA V3 STYLE)
# =====================================================================

def gen_props_and_vegetation():
    # Houses (4 distinct Kerala architectural variants)
    # 1. Traditional Tharavadu
    surf, ctx = new_surf(360, 260)
    ctx.rectangle(24, 232, 312, 18)
    stroke_fill(ctx, hex_rgba("#8e4a2e"), OUTLINE, 2.8)
    ctx.rectangle(38, 114, 284, 118)
    stroke_fill(ctx, hex_rgba("#f5ecd8"), OUTLINE, 3.0)
    draw_kerala_tiled_roof(ctx, 18, 116, 342, 116, 180, 32, "#be4426")
    for wx in [74, 246]:
        ctx.rectangle(wx, 148, 40, 44)
        stroke_fill(ctx, hex_rgba("#5c331b"), OUTLINE, 2.4)
    ctx.rectangle(158, 148, 44, 84)
    stroke_fill(ctx, hex_rgba("#4a2815"), OUTLINE, 2.6)
    save_surf(surf, "props/house_kerala_tharavadu.png")

    # 2. Tea Estate Colonial Cottage
    surf, ctx = new_surf(340, 250)
    ctx.rectangle(24, 222, 292, 18)
    stroke_fill(ctx, hex_rgba("#6c6258"), OUTLINE, 2.8)
    ctx.rectangle(36, 108, 268, 114)
    stroke_fill(ctx, hex_rgba("#fdfaf0"), OUTLINE, 3.0)
    draw_kerala_tiled_roof(ctx, 18, 110, 322, 110, 170, 34, "#2f7848")
    for wx in [72, 234]:
        ctx.rectangle(wx, 138, 34, 42)
        stroke_fill(ctx, hex_rgba("#385d66"), OUTLINE, 2.4)
    ctx.rectangle(150, 146, 40, 76)
    stroke_fill(ctx, hex_rgba("#5a321b"), OUTLINE, 2.6)
    save_surf(surf, "props/house_tea_estate_cottage.png")

    # 3. Banana Chips & Village Tea Stall (Thattukada)
    surf, ctx = new_surf(260, 200)
    ctx.rectangle(26, 86, 208, 102)
    stroke_fill(ctx, hex_rgba("#f8eed6"), OUTLINE, 2.8)
    draw_kerala_tiled_roof(ctx, 14, 88, 246, 88, 130, 26, "#c24b2a")
    ctx.rectangle(42, 134, 176, 54)
    stroke_fill(ctx, hex_rgba("#8e522d"), OUTLINE, 2.6)
    for bx in [74, 130, 186]:
        ctx.arc(bx, 128, 16, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#f2c238"), OUTLINE, 2.2)
    save_surf(surf, "props/shop_kerala_banana_chips.png")

    # 4. Coconut Palm (curved trunk + coconuts + outlined fronds)
    for fname, bx_p, lean in [("tree_kerala_coconut_1.png", 110, 48), ("tree_kerala_coconut_2.png", 150, -52)]:
        surf, ctx = new_surf(260, 360)
        tx, ty = bx_p + lean, 94
        cx, cy = bx_p + lean * 0.35, 208
        ctx.move_to(bx_p - 10, 348)
        quad_to(ctx, cx - 7, cy, tx - 4, ty)
        ctx.line_to(tx + 4, ty)
        quad_to(ctx, cx + 7, cy, bx_p + 10, 348)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba("#8a5a38"), OUTLINE, 2.8)
        for dx, dy in [(-6, 7), (6, 8), (0, 12)]:
            ctx.arc(tx + dx, ty + dy, 6.5, 0, math.tau)
            stroke_fill(ctx, hex_rgba("#7fb238"), OUTLINE, 2.0)
        for idx, a in enumerate([-2.65, -2.05, -1.35, -0.55, 0.15, 0.72, -3.05]):
            fl = 104 if idx % 2 == 0 else 90
            ex, ey = tx + math.cos(a) * fl, ty + math.sin(a) * fl + fl * 0.34
            mx, my = tx + math.cos(a) * fl * 0.52, ty + math.sin(a) * fl * 0.40 - 10
            ctx.move_to(tx, ty)
            quad_to(ctx, mx, my - 10, ex, ey)
            quad_to(ctx, mx, my + 7, tx, ty)
            ctx.close_path()
            stroke_fill(ctx, hex_rgba("#42a048" if idx % 2 == 0 else "#31823e"), OUTLINE, 2.4)
        save_surf(surf, "props/" + fname)

    # 5. Rubber Tree (with tapping groove & cup!)
    surf, ctx = new_surf(280, 330)
    ctx.rectangle(126, 130, 28, 188)
    stroke_fill(ctx, hex_rgba("#8e857a"), OUTLINE, 2.8)
    ctx.arc(146, 250, 9, 0, math.pi)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#6c3b20"), OUTLINE, 2.0)
    for cx, cy, cr, col in [(92, 124, 52, "#2f7a3f"), (188, 124, 52, "#2f7a3f"), (140, 88, 64, "#43994a")]:
        ctx.arc(cx, cy, cr, 0, math.tau)
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.6)
    save_surf(surf, "props/tree_kerala_rubber.png")

    # 6. Banana Clump
    surf, ctx = new_surf(220, 210)
    for bx, h_p, lean in [(82, 138, -22), (114, 156, 4), (144, 134, 24)]:
        ctx.rectangle(bx - 7, 198 - h_p * 0.6, 14, h_p * 0.6)
        stroke_fill(ctx, hex_rgba("#528e3c"), OUTLINE, 2.4)
        tx, ty = bx, 198 - h_p * 0.6
        for a in [-2.4, -1.5, -0.6]:
            ctx.move_to(tx, ty)
            quad_to(ctx, tx + math.cos(a) * 44, ty - 28, tx + math.cos(a) * 66 + lean, ty + math.sin(a) * 28 + 18)
            quad_to(ctx, tx + math.cos(a) * 32, ty + 8, tx, ty)
            ctx.close_path()
            stroke_fill(ctx, hex_rgba("#5ab649"), OUTLINE, 2.2)
    save_surf(surf, "props/tree_kerala_banana.png")

    # 7. Bamboo Cluster
    surf, ctx = new_surf(240, 320)
    for bx, lean, col in [(88, -24, "#4fa044"), (116, -6, "#62b350"), (144, 12, "#4b9840"), (168, 28, "#5eae4c")]:
        ctx.move_to(bx - 6, 308)
        quad_to(ctx, bx + lean * 0.4, 180, bx + lean - 4, 48)
        ctx.line_to(bx + lean + 4, 48)
        quad_to(ctx, bx + lean * 0.4 + 10, 180, bx + 6, 308)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.2)
    save_surf(surf, "props/tree_kerala_bamboo.png")

    # 8. Eucalyptus Tree (Munnar highlands)
    surf, ctx = new_surf(260, 360)
    ctx.rectangle(120, 96, 20, 252)
    stroke_fill(ctx, hex_rgba("#b0bab6"), OUTLINE, 2.6)
    for cx, cy, cr, col in [(100, 140, 44, "#327a5d"), (162, 134, 42, "#327a5d"), (130, 86, 52, "#469b74")]:
        ctx.arc(cx, cy, cr, 0, math.tau)
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.6)
    save_surf(surf, "props/tree_kerala_eucalyptus.png")

    # 9. Tea Bush Row & Cardamom Bush
    surf, ctx = new_surf(240, 120)
    for cx, cy, cr, col in [(56, 84, 34, "#2f7c3c"), (184, 84, 34, "#2f7c3c"), (120, 74, 42, "#48a44c")]:
        ctx.arc(cx, cy, cr, math.pi, 0)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.6)
    save_surf(surf, "props/bush_kerala_tea_row.png")

    # 10. Munnar Finish Arch
    surf, ctx = new_surf(440, 320)
    for px in [38, 344]:
        ctx.rectangle(px, 76, 58, 232)
        stroke_fill(ctx, hex_rgba("#fbf5e6"), OUTLINE, 3.2)
        ctx.rectangle(px - 6, 62, 70, 20)
        stroke_fill(ctx, hex_rgba("#2f7e47"), OUTLINE, 2.8)
    ctx.rectangle(96, 68, 248, 62)
    stroke_fill(ctx, hex_rgba("#f2c23c"), OUTLINE, 3.2)
    draw_kerala_tiled_roof(ctx, 78, 70, 362, 70, 220, 22, "#c64a2a")
    ctx.rectangle(116, 82, 208, 34)
    stroke_fill(ctx, hex_rgba("#1f5e42"), OUTLINE, 2.4)
    save_surf(surf, "props/prop_kerala_arch_munnar.png")

    # Foreground grass, ferns & rocks
    surf, ctx = new_surf(180, 80)
    for bx, bh, lean, col in [(42, 48, -14, "#33803c"), (58, 56, 4, "#47a048"), (74, 42, 16, "#378940"), (126, 46, 10, "#4ea74c")]:
        ctx.move_to(bx - 6, 72)
        quad_to(ctx, bx + lean * 0.5, 72 - bh * 0.6, bx + lean, 72 - bh)
        quad_to(ctx, bx + lean * 0.5 + 8, 72 - bh * 0.4, bx + 6, 72)
        ctx.close_path()
        stroke_fill(ctx, hex_rgba(col), OUTLINE, 2.0)
    save_surf(surf, "foreground/fg_kerala_ferns_1.png")

    surf, ctx = new_surf(190, 75)
    ctx.move_to(26, 64)
    ctx.curve_to(32, 34, 70, 28, 88, 64)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#646a6e"), OUTLINE, 2.4)
    ctx.move_to(72, 64)
    ctx.curve_to(78, 42, 112, 42, 122, 64)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#82888c"), OUTLINE, 2.2)
    save_surf(surf, "foreground/fg_kerala_rocks_2.png")


if __name__ == "__main__":
    ensure_dirs()
    gen_skies_and_clouds()
    gen_distant_locations()
    gen_midground_locations()
    gen_landmarks()
    gen_props_and_vegetation()
    print("All Kerala overhaul assets generated in:", OUT_DIR)
