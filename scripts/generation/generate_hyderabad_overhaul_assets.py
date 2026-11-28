#!/usr/bin/env python3
"""
generate_hyderabad_overhaul_assets.py
Generates cohesive, high-detail stylized 2D Cairo vector assets for
Telangana — Hyderabad City Explorer (1,000m) under:
res://assets/indian_locations/telangana/v3/
  - parallax/  (3 time-of-day skies, clouds+birds, 5 distant skylines, 5 midground cityscapes)
  - landmarks/ (All 15 Hyderabad landmarks with transparent backgrounds & flush bases)
  - props/     (Hyderabad Old City & Heritage buildings, Golconda wall, Irani chai, lamps, Deccan flora, Finish Arch)
  - foreground/(Roadside pavement/stone verge)
"""

import os
import math
import cairo

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
OUT = os.path.join(ROOT, "assets/indian_locations/telangana/v3")

OUTLINE = (0.14, 0.11, 0.10, 0.92)


def hex_rgba(h: str, a: float = 1.0):
    h = h.lstrip("#")
    return (int(h[0:2], 16) / 255.0, int(h[2:4], 16) / 255.0, int(h[4:6], 16) / 255.0, a)


def new_surf(w: int, h: int):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surf)
    ctx.set_antialias(cairo.ANTIALIAS_BEST)
    ctx.set_line_join(cairo.LINE_JOIN_ROUND)
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    return surf, ctx


def save_surf(surf, rel_path: str):
    full = os.path.join(OUT, rel_path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    surf.write_to_png(full)
    print(f"Generated: {rel_path}")


def stroke_fill(ctx, fill_rgba, stroke_rgba=OUTLINE, lw=2.6):
    ctx.set_source_rgba(*fill_rgba)
    ctx.fill_preserve()
    ctx.set_source_rgba(*stroke_rgba)
    ctx.set_line_width(lw)
    ctx.stroke()


def draw_arch(ctx, cx, by, w, h):
    """Draws a graceful Indo-Islamic pointed cusped arch bottom-up from (cx, by)."""
    hw = w * 0.5
    spring_y = by - h * 0.62
    ctx.move_to(cx - hw, by)
    ctx.line_to(cx - hw, spring_y)
    ctx.curve_to(cx - hw, spring_y - h * 0.24, cx - hw * 0.35, by - h * 0.92, cx, by - h)
    ctx.curve_to(cx + hw * 0.35, by - h * 0.92, cx + hw, spring_y - h * 0.24, cx + hw, spring_y)
    ctx.line_to(cx + hw, by)
    ctx.close_path()


def draw_onion_dome(ctx, cx, by, r, h, fill_rgba, finial=True, lw=2.4):
    """Draws a classic Qutb Shahi / Hyderabadi onion dome seated at (cx, by)."""
    ctx.move_to(cx - r * 0.85, by)
    ctx.curve_to(cx - r * 1.18, by - h * 0.42, cx - r * 0.45, by - h * 0.85, cx, by - h)
    ctx.curve_to(cx + r * 0.45, by - h * 0.85, cx + r * 1.18, by - h * 0.42, cx + r * 0.85, by)
    ctx.close_path()
    stroke_fill(ctx, fill_rgba, lw=lw)
    if finial:
        ctx.set_source_rgba(*hex_rgba("#d9a938"))
        ctx.set_line_width(2.4)
        ctx.move_to(cx, by - h)
        ctx.line_to(cx, by - h - 14)
        ctx.stroke()
        ctx.arc(cx, by - h - 9, 2.5, 0, math.tau)
        ctx.fill()


def draw_periodic_hill(ctx, w, base_y, h, amps, freqs, phases, fill_rgba):
    ctx.move_to(0, h)
    ctx.line_to(0, base_y)
    for x in range(0, w + 8, 8):
        y = base_y
        for a, f, p in zip(amps, freqs, phases):
            y -= a * math.sin((x / float(w)) * math.tau * f + p)
        ctx.line_to(x, y)
    ctx.line_to(w, h)
    ctx.close_path()
    ctx.set_source_rgba(*fill_rgba)
    ctx.fill()


# =====================================================================
# 1. SKIES & CLOUDS (3 SKIES + 1 NATURAL CLOUDS - 1920x720 / 1920x230)
# =====================================================================

def gen_skies_and_clouds():
    w, h = 1920, 720
    configs = [
        ("sky_hyd_01_morning.png", [(0.0, "#356ba8"), (0.45, "#74a5cc"), (0.78, "#eab67c"), (1.0, "#f7d49c")], (380, 210), "#fff3c8"),
        ("sky_hyd_02_lake_afternoon.png", [(0.0, "#2c74bd"), (0.50, "#6eb3df"), (0.85, "#cbe6f4"), (1.0, "#f2dec0")], (960, 175), "#fff8da"),
        ("sky_hyd_03_golconda_sunset.png", [(0.0, "#393461"), (0.38, "#7e5570"), (0.74, "#d77c48"), (1.0, "#f5c76e")], (1480, 220), "#ffe292"),
    ]
    for fname, stops, sun_xy, sun_c in configs:
        surf, ctx = new_surf(w, h)
        pat = cairo.LinearGradient(0, 0, 0, h)
        for pos, col in stops:
            pat.add_color_stop_rgba(pos, *hex_rgba(col))
        ctx.set_source(pat)
        ctx.paint()

        # Soft atmospheric sun disc
        sx, sy = sun_xy
        for r, a in [(130, 0.10), (85, 0.18), (48, 0.34), (26, 0.85)]:
            g = cairo.RadialGradient(sx, sy, 2, sx, sy, r)
            g.add_color_stop_rgba(0, *hex_rgba(sun_c, a))
            g.add_color_stop_rgba(1, *hex_rgba(sun_c, 0.0))
            ctx.set_source(g)
            ctx.arc(sx, sy, r, 0, math.tau)
            ctx.fill()
        save_surf(surf, f"parallax/{fname}")

    # Clouds & birds layer (1920x230 seamless)
    surf, ctx = new_surf(1920, 230)
    clouds = [
        (220, 108, 1.0), (590, 78, 0.85), (970, 118, 1.15), (1380, 82, 0.92), (1730, 110, 1.05),
    ]
    for cx, cy, sc in clouds:
        ctx.save()
        ctx.translate(cx, cy)
        ctx.scale(sc, sc)
        ctx.set_source_rgba(1.0, 0.98, 0.94, 0.84)
        for dx, dy, rx, ry in [(-36, 8, 34, 16), (34, 8, 36, 15), (-10, -4, 40, 22), (18, -2, 32, 18), (0, 10, 62, 15)]:
            ctx.save()
            ctx.translate(dx, dy)
            ctx.scale(rx, ry)
            ctx.arc(0, 0, 1.0, 0, math.tau)
            ctx.fill()
            ctx.restore()
        ctx.restore()

    # Subtle city birds V silhouettes
    ctx.set_source_rgba(0.18, 0.16, 0.18, 0.55)
    ctx.set_line_width(2.0)
    for bx, by in [(420, 68), (446, 76), (1190, 56), (1216, 65), (1238, 52)]:
        ctx.move_to(bx - 8, by + 3)
        ctx.curve_to(bx - 4, by - 4, bx - 1, by - 2, bx, by + 2)
        ctx.curve_to(bx + 1, by - 2, bx + 4, by - 4, bx + 8, by + 3)
        ctx.stroke()
    save_surf(surf, "parallax/clouds_hyd_natural.png")


# =====================================================================
# 2. DISTANT SKYLINE LAYERS (5 ZONES - 1920x440 SEAMLESS)
# =====================================================================

def draw_dist_charminar_silhouette(ctx, cx, by, sc, col):
    ctx.save()
    ctx.translate(cx, by)
    ctx.scale(sc, sc)
    ctx.set_source_rgba(*col)
    ctx.rectangle(-38, -58, 76, 58)
    ctx.fill()
    for mx in [-36, -14, 14, 36]:
        ctx.rectangle(mx - 5, -96, 10, 96)
        ctx.arc(mx, -96, 6, math.pi, 0)
        ctx.fill()
    ctx.restore()


def draw_dist_buddha_silhouette(ctx, cx, by, sc, col):
    ctx.save()
    ctx.translate(cx, by)
    ctx.scale(sc, sc)
    ctx.set_source_rgba(*col)
    # Gibraltar rock base
    ctx.move_to(-34, 0)
    ctx.curve_to(-26, -24, -14, -26, 0, -24)
    ctx.curve_to(16, -26, 28, -22, 36, 0)
    ctx.close_path()
    ctx.fill()
    # Monolithic Buddha standing silhouette
    ctx.rectangle(-9, -98, 18, 76)
    ctx.arc(0, -104, 10, 0, math.tau)
    ctx.fill()
    ctx.restore()


def gen_distant_layers():
    w, h = 1920, 440

    # 1. Old Hyderabad Skyline
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, 240, h, [14, 6], [2, 5], [0.2, 1.4], hex_rgba("#8e92aa", 0.55))
    for sx in [140, 420, 760, 1120, 1490, 1810]:
        ctx.set_source_rgba(*hex_rgba("#7a7992", 0.72))
        ctx.rectangle(sx - 44, 198, 88, 52)
        ctx.fill()
        ctx.arc(sx, 198, 20, math.pi, 0)
        ctx.fill()
    draw_dist_charminar_silhouette(ctx, 560, 242, 0.95, hex_rgba("#6c6b84", 0.78))
    draw_dist_charminar_silhouette(ctx, 1340, 242, 0.85, hex_rgba("#6c6b84", 0.72))
    draw_periodic_hill(ctx, w, 248, h, [8, 4], [3, 6], [0.9, 0.2], hex_rgba("#77758e"))
    save_surf(surf, "parallax/dist_01_old_hyderabad.png")

    # 2. City Heritage Skyline
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, 232, h, [18, 7], [2, 4], [0.5, 1.2], hex_rgba("#7d93ae", 0.58))
    # Modern & heritage skyline silhouettes
    for x, bw, bh, dome in [
        (110, 62, 68, False), (180, 84, 52, True), (320, 56, 86, False), (490, 96, 58, True),
        (720, 68, 92, False), (880, 92, 56, True), (1120, 60, 80, False), (1290, 102, 62, True),
        (1510, 64, 88, False), (1680, 88, 54, True),
    ]:
        ctx.set_source_rgba(*hex_rgba("#697d96", 0.82))
        ctx.rectangle(x, 238 - bh, bw, bh + 12)
        ctx.fill()
        if dome:
            ctx.arc(x + bw * 0.5, 238 - bh, 18, math.pi, 0)
            ctx.fill()
    draw_periodic_hill(ctx, w, 246, h, [6, 3], [2, 5], [1.1, 0.7], hex_rgba("#60738b"))
    save_surf(surf, "parallax/dist_02_city_heritage.png")

    # 3. Hussain Sagar Lake Skyline (Water reservoir expanse + Buddha silhouette!)
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, 198, h, [14, 5], [2, 4], [0.3, 1.8], hex_rgba("#7495b3", 0.62))
    for x, bw, bh in [(160, 72, 46), (340, 58, 62), (760, 68, 54), (1180, 76, 48), (1560, 64, 60)]:
        ctx.set_source_rgba(*hex_rgba("#62809d", 0.72))
        ctx.rectangle(x, 204 - bh, bw, bh)
        ctx.fill()
    draw_dist_buddha_silhouette(ctx, 960, 224, 0.92, hex_rgba("#526b84", 0.88))
    # Shimmering lake water filling lower half cleanly
    pat = cairo.LinearGradient(0, 202, 0, h)
    pat.add_color_stop_rgba(0.0, *hex_rgba("#4e8ec4"))
    pat.add_color_stop_rgba(0.45, *hex_rgba("#3878b0"))
    pat.add_color_stop_rgba(1.0, *hex_rgba("#295c8c"))
    ctx.set_source(pat)
    ctx.rectangle(0, 202, w, h - 202)
    ctx.fill()
    ctx.set_source_rgba(1.0, 0.98, 0.92, 0.25)
    for rx in range(40, w, 140):
        ctx.rectangle(rx, 218 + (rx % 3) * 14, 54, 3)
        ctx.fill()
    save_surf(surf, "parallax/dist_03_hussain_sagar.png")

    # 4. Golconda Heritage Rocky Hills & Fort Ramparts
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, 212, h, [32, 14], [2, 5], [0.4, 1.1], hex_rgba("#7c687c", 0.62))
    draw_periodic_hill(ctx, w, 232, h, [24, 11], [3, 6], [1.5, 0.4], hex_rgba("#6a5865", 0.85))
    # Distant Golconda battlements & Qutb Shahi dome crests
    for fx in [310, 960, 1590]:
        ctx.set_source_rgba(*hex_rgba("#5a4a54"))
        ctx.rectangle(fx - 70, 186, 140, 56)
        ctx.fill()
        for cx in range(fx - 64, fx + 65, 16):
            ctx.rectangle(cx, 178, 10, 8)
            ctx.fill()
    for dx in [620, 1280]:
        ctx.set_source_rgba(*hex_rgba("#63525c"))
        ctx.arc(dx, 204, 22, math.pi, 0)
        ctx.fill()
    draw_periodic_hill(ctx, w, 248, h, [10, 4], [2, 5], [0.7, 2.0], hex_rgba("#594950"))
    save_surf(surf, "parallax/dist_04_golconda.png")

    # 5. Golconda Destination Sunset Hills
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, 208, h, [34, 15], [2, 4], [0.8, 1.5], hex_rgba("#8a606c", 0.65))
    for fx in [420, 1180]:
        ctx.set_source_rgba(*hex_rgba("#63444f"))
        ctx.rectangle(fx - 90, 178, 180, 68)
        ctx.fill()
        for cx in range(fx - 84, fx + 84, 18):
            ctx.rectangle(cx, 168, 11, 10)
            ctx.fill()
    draw_periodic_hill(ctx, w, 244, h, [14, 6], [3, 6], [1.9, 0.3], hex_rgba("#5b3f47"))
    save_surf(surf, "parallax/dist_05_golconda_dest.png")


# =====================================================================
# 3. MIDGROUND LAYERS (5 ZONES - 1920x420 SEAMLESS)
# =====================================================================

def draw_mid_hyd_tree(ctx, cx, by, sc, leaf_hex, flowers=False):
    ctx.save()
    ctx.translate(cx, by)
    ctx.scale(sc, sc)
    ctx.set_source_rgba(*hex_rgba("#4c3626"))
    ctx.set_line_width(6.0)
    ctx.move_to(0, 0)
    ctx.curve_to(-3, -24, 3, -44, 0, -58)
    ctx.stroke()
    for dx, dy, rx, ry, c in [(-18, -58, 22, 12, leaf_hex), (18, -56, 20, 11, leaf_hex), (0, -68, 28, 14, leaf_hex)]:
        ctx.save()
        ctx.translate(dx, dy)
        ctx.scale(rx, ry)
        ctx.set_source_rgba(*hex_rgba(c))
        ctx.arc(0, 0, 1.0, 0, math.tau)
        ctx.fill()
        ctx.restore()
    if flowers:
        ctx.set_source_rgba(*hex_rgba("#e25132", 0.9))
        for fx, fy in [(-14, -62), (8, -68), (18, -58), (-4, -56)]:
            ctx.arc(fx, fy, 3.2, 0, math.tau)
            ctx.fill()
    ctx.restore()


def draw_mid_city_haveli(ctx, cx, by, w, h, wall_hex, trim_hex, dome=False):
    ctx.set_source_rgba(*hex_rgba(wall_hex))
    ctx.rectangle(cx - w * 0.5, by - h, w, h)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba(trim_hex))
    ctx.rectangle(cx - w * 0.54, by - h - 5, w * 1.08, 6)
    ctx.fill()
    if dome:
        ctx.set_source_rgba(*hex_rgba(wall_hex))
        ctx.arc(cx, by - h - 4, w * 0.18, math.pi, 0)
        ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#382b27", 0.72))
    cols = 2 if w < 90 else 3
    span = w * 0.56
    for i in range(cols):
        wx = cx - span * 0.5 + (span / max(1, cols - 1)) * i
        draw_arch(ctx, wx, by - h * 0.25, 13, 24)
        ctx.fill()


def gen_midground_layers():
    w, h = 1920, 420
    gy = 238

    # 1. Old Hyderabad
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, gy - 6, h, [10, 4], [2, 5], [0.3, 1.2], hex_rgba("#b7a189"))
    for idx, (hx, bw, bh, dome) in enumerate([
        (130, 108, 72, True), (255, 86, 56, False), (580, 114, 76, True), (710, 88, 60, False),
        (1060, 104, 70, False), (1185, 96, 62, True), (1560, 112, 74, True), (1700, 84, 58, False),
    ]):
        wc = "#dfcfb7" if idx % 2 == 0 else "#d6bfa0"
        draw_mid_city_haveli(ctx, hx, gy, bw, bh, wc, "#a98c6e", dome)
    for tx in [405, 885, 1380, 1845]:
        draw_mid_hyd_tree(ctx, tx, gy + 2, 0.98, "#4b7b44", flowers=(tx % 2 == 0))
    draw_periodic_hill(ctx, w, gy + 8, h, [6, 3], [2, 4], [0.6, 1.1], hex_rgba("#8a7e72"))
    save_surf(surf, "parallax/mid_01_old_hyderabad.png")

    # 2. City Heritage
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, gy - 8, h, [12, 5], [2, 4], [0.9, 0.4], hex_rgba("#9c9f9e"))
    for idx, (hx, bw, bh, dome) in enumerate([
        (145, 126, 76, True), (320, 96, 64, False), (740, 128, 78, True), (920, 94, 62, False),
        (1340, 124, 76, True), (1530, 96, 66, False),
    ]):
        draw_mid_city_haveli(ctx, hx, gy, bw, bh, "#e5d5bc" if idx % 2 == 0 else "#d39c7d", "#b57a5b", dome)
    for tx in [510, 585, 1120, 1730]:
        draw_mid_hyd_tree(ctx, tx, gy + 2, 1.04, "#4b7b44", flowers=True)
    draw_periodic_hill(ctx, w, gy + 8, h, [5, 2], [2, 5], [0.1, 1.7], hex_rgba("#7c7a74"))
    save_surf(surf, "parallax/mid_02_city_heritage.png")

    # 3. Hussain Sagar Lake Promenade (Necklace Road)
    surf, ctx = new_surf(w, h)
    # Sparkling blue Hussain Sagar reservoir above & below Tank Bund promenade
    pat = cairo.LinearGradient(0, gy - 32, 0, h)
    pat.add_color_stop_rgba(0.0, *hex_rgba("#4b8ec4", 0.45))
    pat.add_color_stop_rgba(0.25, *hex_rgba("#3878b0", 0.90))
    pat.add_color_stop_rgba(1.0, *hex_rgba("#295c8c", 1.0))
    ctx.set_source(pat)
    ctx.rectangle(0, gy - 28, w, h - (gy - 28))
    ctx.fill()
    # Tank Bund promenade stone parapet strip
    ctx.set_source_rgba(*hex_rgba("#d8ccb8"))
    ctx.rectangle(0, gy - 12, w, 16)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#8e8373"))
    for px in range(24, w, 48):
        ctx.rectangle(px, gy - 20, 6, 9)
        ctx.fill()
    # Necklace Road lamps & lakeside gulmohars sitting neatly along promenade strip
    for lx in range(120, w, 240):
        ctx.set_source_rgba(*hex_rgba("#3b434d"))
        ctx.rectangle(lx - 2, gy - 68, 4, 56)
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#ffe79b", 0.94))
        ctx.arc(lx, gy - 70, 5.5, 0, math.tau)
        ctx.fill()
        tx = lx + 110
        for wx in (tx - w, tx, tx + w):
            if -60 <= wx <= w + 60:
                draw_mid_hyd_tree(ctx, wx, gy, 0.96, "#4d8246", flowers=(lx % 480 == 120))
    draw_periodic_hill(ctx, w, gy + 18, h, [4, 2], [2, 4], [0.5, 1.4], hex_rgba("#67696c"))
    save_surf(surf, "parallax/mid_03_hussain_sagar.png")

    # 4. Golconda Heritage
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, gy - 16, h, [24, 10], [2, 5], [0.4, 1.6], hex_rgba("#87786f"))
    # Golconda stone fort wall spans + Qutb Shahi domes + Deccan boulder tors
    for fx in [210, 820, 1440]:
        ctx.set_source_rgba(*hex_rgba("#6b5c52"))
        ctx.rectangle(fx - 120, gy - 44, 240, 48)
        ctx.fill()
        for cx in range(fx - 114, fx + 116, 18):
            ctx.rectangle(cx, gy - 52, 11, 8)
            ctx.fill()
        # Qutb Shahi pavilion dome nearby
        draw_mid_city_haveli(ctx, fx + 240, gy, 74, 46, "#c7b194", "#8a755f", True)
        draw_mid_hyd_tree(ctx, fx - 170, gy, 0.95, "#59753c", flowers=False)
    draw_periodic_hill(ctx, w, gy + 8, h, [7, 3], [2, 6], [1.2, 0.3], hex_rgba("#726256"))
    save_surf(surf, "parallax/mid_04_golconda.png")

    # 5. Golconda Destination
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, gy - 14, h, [20, 9], [2, 4], [0.7, 1.8], hex_rgba("#7f665d"))
    for fx in [280, 960, 1620]:
        ctx.set_source_rgba(*hex_rgba("#634d46"))
        ctx.rectangle(fx - 130, gy - 54, 260, 58)
        ctx.fill()
        for cx in range(fx - 124, fx + 124, 18):
            ctx.rectangle(cx, gy - 63, 11, 9)
            ctx.fill()
        draw_mid_hyd_tree(ctx, fx + 210, gy, 1.0, "#50783f", flowers=True)
    draw_periodic_hill(ctx, w, gy + 8, h, [6, 3], [3, 5], [0.2, 1.1], hex_rgba("#6c564c"))
    save_surf(surf, "parallax/mid_05_golconda_dest.png")


# =====================================================================
# 4. ALL 15 HYDERABAD LANDMARKS (CRISP TRANSPARENT SPRITES)
# =====================================================================

def gen_hyderabad_landmarks():
    # 1. Charminar (Monumental 4-minaret icon of Hyderabad)
    surf, ctx = new_surf(460, 420)
    by = 412
    # Plinth
    ctx.rectangle(70, by - 14, 320, 14)
    stroke_fill(ctx, hex_rgba("#b9a489"))
    # Central square granite facade
    ctx.rectangle(116, by - 220, 228, 206)
    stroke_fill(ctx, hex_rgba("#dfd0b6"))
    # Upper cornice & arcade frieze
    ctx.rectangle(108, by - 232, 244, 16)
    stroke_fill(ctx, hex_rgba("#c8b294"))
    ctx.set_source_rgba(*hex_rgba("#382b24"))
    for ax in range(132, 332, 24):
        draw_arch(ctx, ax, by - 168, 15, 34)
        ctx.fill()
    # Grand central pointed arch + clock medallion
    draw_arch(ctx, 230, by - 14, 118, 134)
    stroke_fill(ctx, hex_rgba("#302824"))
    ctx.arc(230, by - 188, 16, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#f5f0e2"))
    ctx.set_source_rgba(*OUTLINE)
    ctx.set_line_width(2.0)
    ctx.move_to(230, by - 188); ctx.line_to(230, by - 197)
    ctx.move_to(230, by - 188); ctx.line_to(238, by - 188)
    ctx.stroke()
    # 4 corner soaring minarets (2 front prominent, 2 back slightly inset & taller depth)
    for mx, mw, mh, col in [
        (146, 22, 340, "#cbb89b"), (314, 22, 340, "#cbb89b"),
        (112, 30, 368, "#e6d8c0"), (348, 30, 368, "#e6d8c0"),
    ]:
        ctx.rectangle(mx - mw * 0.5, by - mh, mw, mh)
        stroke_fill(ctx, hex_rgba(col))
        for gy_off in [150, 226, 294, 346]:
            ctx.rectangle(mx - mw * 0.68, by - gy_off, mw * 1.36, 9)
            stroke_fill(ctx, hex_rgba("#cdb99d"), lw=2.0)
        draw_onion_dome(ctx, mx, by - mh, mw * 0.65, 34, hex_rgba("#e8d9bd"))
    save_surf(surf, "landmarks/charminar.png")

    # 2. Mecca Masjid (Grand Makkah-stone arches & twin minarets)
    surf, ctx = new_surf(460, 320)
    by = 312
    ctx.rectangle(42, by - 14, 376, 14)
    stroke_fill(ctx, hex_rgba("#a8947d"))
    ctx.rectangle(76, by - 178, 308, 164)
    stroke_fill(ctx, hex_rgba("#c8b195"))
    # Five deep granite prayer arches
    for ax in [120, 175, 230, 285, 340]:
        ah = 110 if ax == 230 else 88
        aw = 44 if ax == 230 else 36
        draw_arch(ctx, ax, by - 14, aw, ah)
        stroke_fill(ctx, hex_rgba("#2f2622"))
    # Ornamental cornice & kangura parapet
    ctx.rectangle(70, by - 190, 320, 14)
    stroke_fill(ctx, hex_rgba("#b89d7f"))
    for kx in range(82, 382, 22):
        ctx.arc(kx, by - 190, 7, math.pi, 0)
        stroke_fill(ctx, hex_rgba("#d8c2a5"), lw=1.8)
    # Flanking octagonal granite minarets + central chhatri
    for mx in [76, 384]:
        ctx.rectangle(mx - 16, by - 252, 32, 238)
        stroke_fill(ctx, hex_rgba("#d2bc9f"))
        ctx.rectangle(mx - 21, by - 220, 42, 8)
        stroke_fill(ctx, hex_rgba("#b59a7a"), lw=2.0)
        draw_onion_dome(ctx, mx, by - 252, 20, 32, hex_rgba("#efe4cf"))
    draw_onion_dome(ctx, 230, by - 190, 30, 42, hex_rgba("#efe4cf"))
    save_surf(surf, "landmarks/mecca_masjid.png")

    # 3. Laad Bazaar (Traditional arched Old City bangle market facade)
    surf, ctx = new_surf(460, 300)
    by = 292
    ctx.rectangle(36, by - 12, 388, 12)
    stroke_fill(ctx, hex_rgba("#9c876e"))
    ctx.rectangle(50, by - 198, 360, 186)
    stroke_fill(ctx, hex_rgba("#ebd8b7"))
    # Ornate arched upper gallery & bazaar sign
    ctx.rectangle(136, by - 224, 188, 28)
    stroke_fill(ctx, hex_rgba("#7a2d34"))
    ctx.set_source_rgba(*hex_rgba("#f5d77a"))
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(14.5)
    ctx.move_to(164, by - 205)
    ctx.show_text("LAAD BAZAAR")
    # Colorful arched market bays filled with bangle racks & striped awnings
    bay_cols = ["#d94e4e", "#e59f2c", "#2d939c", "#b5428a"]
    for idx, bx in enumerate([102, 188, 274, 360]):
        draw_arch(ctx, bx, by - 12, 66, 108)
        stroke_fill(ctx, hex_rgba("#3c2620"))
        # Hanging bangle garlands
        for row_y, col in [(by - 92, bay_cols[idx]), (by - 72, "#f2cf4e"), (by - 52, bay_cols[(idx + 1) % 4])]:
            ctx.set_source_rgba(*hex_rgba(col))
            ctx.arc(bx - 12, row_y, 7, 0, math.tau); ctx.fill()
            ctx.arc(bx + 12, row_y, 7, 0, math.tau); ctx.fill()
            ctx.arc(bx, row_y + 4, 7, 0, math.tau); ctx.fill()
        # Striped awning
        ctx.rectangle(bx - 36, by - 134, 72, 18)
        stroke_fill(ctx, hex_rgba(bay_cols[idx]), lw=2.0)
    save_surf(surf, "landmarks/laad_bazaar.png")

    # 4. Chowmahalla Palace (Nizam's Yellow-Ivory Palace & Khilwat Clock)
    surf, ctx = new_surf(480, 320)
    by = 312
    ctx.rectangle(26, by - 12, 428, 12)
    stroke_fill(ctx, hex_rgba("#bda88b"))
    # Long neoclassical yellow-cream colonnade wing
    ctx.rectangle(46, by - 154, 388, 142)
    stroke_fill(ctx, hex_rgba("#f3e3b4"))
    ctx.rectangle(40, by - 166, 400, 14)
    stroke_fill(ctx, hex_rgba("#d4be86"))
    # Central Clock Tower Pavilion
    ctx.rectangle(192, by - 244, 96, 90)
    stroke_fill(ctx, hex_rgba("#f7e8be"))
    draw_onion_dome(ctx, 240, by - 244, 24, 34, hex_rgba("#e8d094"))
    ctx.arc(240, by - 202, 18, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#ffffff"))
    ctx.set_source_rgba(*OUTLINE); ctx.set_line_width(2.0)
    ctx.move_to(240, by - 202); ctx.line_to(240, by - 213)
    ctx.move_to(240, by - 202); ctx.line_to(248, by - 202)
    ctx.stroke()
    # Ground colonnade arches
    for ax in range(74, 412, 42):
        draw_arch(ctx, ax, by - 12, 26, 92)
        stroke_fill(ctx, hex_rgba("#4e4236"))
    save_surf(surf, "landmarks/chowmahalla_palace.png")

    # 5. Salar Jung Museum (Grand civic riverside museum facade)
    surf, ctx = new_surf(460, 290)
    by = 282
    ctx.rectangle(30, by - 14, 400, 14)
    stroke_fill(ctx, hex_rgba("#a89a88"))
    ctx.rectangle(46, by - 156, 368, 142)
    stroke_fill(ctx, hex_rgba("#ede3d2"))
    ctx.rectangle(166, by - 194, 128, 180)
    stroke_fill(ctx, hex_rgba("#f6efe2"))
    draw_onion_dome(ctx, 230, by - 194, 40, 44, hex_rgba("#d4a472"))
    # Museum arched gallery bays
    for wx in [78, 114, 150, 310, 346, 382]:
        ctx.rectangle(wx - 10, by - 124, 20, 38)
        stroke_fill(ctx, hex_rgba("#526b82"), lw=1.8)
        ctx.rectangle(wx - 10, by - 68, 20, 38)
        stroke_fill(ctx, hex_rgba("#526b82"), lw=1.8)
    draw_arch(ctx, 230, by - 14, 62, 108)
    stroke_fill(ctx, hex_rgba("#3b3532"))
    save_surf(surf, "landmarks/salar_jung_museum.png")

    # 6. Telangana State Archaeology Museum (Public Gardens Indo-Saracenic facade)
    surf, ctx = new_surf(460, 300)
    by = 292
    ctx.rectangle(36, by - 14, 388, 14)
    stroke_fill(ctx, hex_rgba("#9c7e68"))
    ctx.rectangle(58, by - 156, 344, 142)
    stroke_fill(ctx, hex_rgba("#e2ac8c"))
    ctx.rectangle(50, by - 168, 360, 14)
    stroke_fill(ctx, hex_rgba("#bf7c59"))
    for dx, dr, dh in [(100, 20, 32), (230, 38, 52), (360, 20, 32)]:
        draw_onion_dome(ctx, dx, by - 168, dr, dh, hex_rgba("#f3e3cd"))
    for ax in [94, 140, 230, 320, 366]:
        draw_arch(ctx, ax, by - 14, 34 if ax == 230 else 24, 98 if ax == 230 else 78)
        stroke_fill(ctx, hex_rgba("#462c22"))
    save_surf(surf, "landmarks/state_archaeology_museum.png")

    # 7. Osmania University (Arts College Monumental Granite Indo-Saracenic Edifice)
    surf, ctx = new_surf(480, 320)
    by = 312
    ctx.rectangle(26, by - 14, 428, 14)
    stroke_fill(ctx, hex_rgba("#9b8772"))
    ctx.rectangle(46, by - 162, 388, 148)
    stroke_fill(ctx, hex_rgba("#d8b997"))
    # Central monumental pishtaq portal
    ctx.rectangle(174, by - 216, 132, 202)
    stroke_fill(ctx, hex_rgba("#e5c8a6"))
    draw_arch(ctx, 240, by - 14, 72, 140)
    stroke_fill(ctx, hex_rgba("#382b24"))
    for cx in [184, 296]:
        draw_onion_dome(ctx, cx, by - 216, 16, 30, hex_rgba("#e9d2b5"))
    draw_onion_dome(ctx, 240, by - 216, 26, 42, hex_rgba("#f0dcbe"))
    for wx in range(74, 160, 30):
        draw_arch(ctx, wx, by - 14, 16, 56)
        stroke_fill(ctx, hex_rgba("#49382e"), lw=1.8)
    for wx in range(320, 412, 30):
        draw_arch(ctx, wx, by - 14, 16, 56)
        stroke_fill(ctx, hex_rgba("#49382e"), lw=1.8)
    save_surf(surf, "landmarks/osmania_university.png")

    # 8. Hussain Sagar Lake (Tank Bund balustrade & sparkling reservoir panorama)
    surf, ctx = new_surf(480, 260)
    by = 252
    # Sparkling lake water
    pat = cairo.LinearGradient(0, by - 130, 0, by - 34)
    pat.add_color_stop_rgba(0, *hex_rgba("#5aa6dc"))
    pat.add_color_stop_rgba(1, *hex_rgba("#2f6ea8"))
    ctx.set_source(pat)
    ctx.rectangle(24, by - 136, 432, 102)
    ctx.fill()
    ctx.set_source_rgba(*OUTLINE); ctx.set_line_width(2.2)
    ctx.rectangle(24, by - 136, 432, 102); ctx.stroke()
    # Sailboats & water sparkles
    for bx in [135, 340]:
        ctx.set_source_rgba(*hex_rgba("#ffffff", 0.92))
        ctx.move_to(bx, by - 118); ctx.line_to(bx + 20, by - 78); ctx.line_to(bx - 12, by - 78); ctx.close_path(); ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#6e3d24"))
        ctx.rectangle(bx - 16, by - 78, 38, 9); ctx.fill()
    # Tank Bund foreground stone railing & ornamental lamps
    ctx.rectangle(16, by - 36, 448, 36)
    stroke_fill(ctx, hex_rgba("#ccb89c"))
    for lx in [72, 240, 408]:
        ctx.rectangle(lx - 3, by - 118, 6, 82)
        stroke_fill(ctx, hex_rgba("#2f3842"), lw=1.8)
        ctx.arc(lx, by - 122, 9, 0, math.tau)
        stroke_fill(ctx, hex_rgba("#ffe99a"), lw=1.8)
    save_surf(surf, "landmarks/hussain_sagar_lake.png")

    # 9. Buddha Statue, Hussain Sagar (Monolithic 18m granite Buddha on lotus & Gibraltar Rock)
    surf, ctx = new_surf(380, 440)
    by = 432
    # Lake water band at bottom
    ctx.rectangle(20, by - 48, 340, 48)
    stroke_fill(ctx, hex_rgba("#3878b0"))
    # Gibraltar granite island
    ctx.move_to(72, by - 34)
    ctx.curve_to(90, by - 102, 148, by - 116, 190, by - 114)
    ctx.curve_to(232, by - 116, 290, by - 102, 308, by - 34)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#645a53"))
    # Pink sculpted lotus pedestal
    ctx.rectangle(128, by - 134, 124, 22)
    stroke_fill(ctx, hex_rgba("#d97184"))
    # Monolithic pale grey-white granite Buddha robe & rounded shoulders
    ctx.move_to(146, by - 134)
    ctx.line_to(152, by - 300)
    ctx.curve_to(154, by - 320, 168, by - 326, 190, by - 326)
    ctx.curve_to(212, by - 326, 226, by - 320, 228, by - 300)
    ctx.line_to(234, by - 134)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#ece9e0"))
    # Graceful robe drape arcs
    ctx.set_source_rgba(*hex_rgba("#aba59a"))
    ctx.set_line_width(2.2)
    for dy in range(158, 294, 26):
        ctx.move_to(154, by - dy)
        ctx.curve_to(176, by - dy + 14, 204, by - dy + 14, 226, by - dy)
        ctx.stroke()
    # Raised abhaya mudra right hand + serene head & ushnisha halo
    ctx.arc(232, by - 256, 12, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#ece9e0"), lw=2.0)
    ctx.arc(190, by - 352, 24, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#ece9e0"))
    # Serene facial features
    ctx.set_source_rgba(*hex_rgba("#6e685f")); ctx.set_line_width(1.8)
    ctx.arc(182, by - 354, 3, 0.2, math.pi - 0.2); ctx.stroke()
    ctx.arc(198, by - 354, 3, 0.2, math.pi - 0.2); ctx.stroke()
    ctx.arc(190, by - 344, 5, 0.3, math.pi - 0.3); ctx.stroke()
    ctx.arc(190, by - 380, 11, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#e5e1d6"))
    save_surf(surf, "landmarks/buddha_statue_hussain_sagar.png")

    # 10. Necklace Road (Scenic lakefront arch gateway & Eat Street pavilion)
    surf, ctx = new_surf(460, 270)
    by = 262
    ctx.rectangle(24, by - 16, 412, 16)
    stroke_fill(ctx, hex_rgba("#8e8376"))
    # Stylish cantilevered waterfront pavilion & welcome sign
    for px in [92, 368]:
        ctx.rectangle(px - 8, by - 178, 16, 162)
        stroke_fill(ctx, hex_rgba("#d5d8dc"))
    ctx.rectangle(64, by - 196, 332, 34)
    stroke_fill(ctx, hex_rgba("#1f4d78"))
    ctx.set_source_rgba(*hex_rgba("#ffdf73"))
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(16.0)
    ctx.move_to(146, by - 173)
    ctx.show_text("NECKLACE ROAD")
    # Lakeside palms behind
    for px in [165, 295]:
        draw_mid_hyd_tree(ctx, px, by - 16, 1.35, "#4c8646", flowers=(px == 295))
    save_surf(surf, "landmarks/necklace_road.png")

    # 11. Birla Mandir (Radiant white Makrana marble shrine atop Naubat Pahad)
    surf, ctx = new_surf(440, 400)
    by = 392
    # Naubat Pahad granite hillock
    ctx.move_to(30, by)
    ctx.line_to(96, by - 118)
    ctx.line_to(344, by - 118)
    ctx.line_to(410, by)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#6e655d"))
    # White marble base terrace & mandapa
    ctx.rectangle(94, by - 134, 252, 18)
    stroke_fill(ctx, hex_rgba("#f5f4f0"))
    ctx.rectangle(116, by - 212, 208, 78)
    stroke_fill(ctx, hex_rgba("#fcfcfa"))
    for ax in [148, 220, 292]:
        draw_arch(ctx, ax, by - 134, 24, 52)
        stroke_fill(ctx, hex_rgba("#bcc5d0"), lw=2.0)
    # Towering curved white marble Utkal-Dravidian Shikhara & golden Kalasha
    ctx.move_to(158, by - 212)
    ctx.curve_to(166, by - 294, 194, by - 344, 220, by - 362)
    ctx.curve_to(246, by - 344, 274, by - 294, 282, by - 212)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#ffffff"))
    for sy in [242, 272, 302, 330]:
        ctx.set_source_rgba(*hex_rgba("#d9dee5"))
        ctx.set_line_width(2.0)
        ctx.move_to(172 + (sy - 242) * 0.35, by - sy)
        ctx.line_to(268 - (sy - 242) * 0.35, by - sy)
        ctx.stroke()
    ctx.set_source_rgba(*hex_rgba("#e5b42b"))
    ctx.set_line_width(3.0)
    ctx.move_to(220, by - 362); ctx.line_to(220, by - 384); ctx.stroke()
    ctx.arc(220, by - 368, 6, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#f6d04d"), lw=2.0)
    save_surf(surf, "landmarks/birla_mandir.png")

    # 12. Qutb Shahi Tombs (Iconic Royal Granite Mausoleum & Bulbous Dome)
    surf, ctx = new_surf(460, 350)
    by = 342
    ctx.rectangle(46, by - 20, 368, 20)
    stroke_fill(ctx, hex_rgba("#9c8f7e"))
    ctx.rectangle(86, by - 172, 288, 152)
    stroke_fill(ctx, hex_rgba("#d4c5af"))
    # Ground & upper arcades
    for ax in [124, 178, 230, 282, 336]:
        draw_arch(ctx, ax, by - 20, 32 if ax == 230 else 26, 98 if ax == 230 else 78)
        stroke_fill(ctx, hex_rgba("#38312c"))
    ctx.rectangle(78, by - 186, 304, 16)
    stroke_fill(ctx, hex_rgba("#b5a38b"))
    # Corner ornamental minarets & iconic large bulbous granite dome
    for mx in [96, 364]:
        ctx.rectangle(mx - 8, by - 228, 16, 42)
        stroke_fill(ctx, hex_rgba("#dfcfb9"))
        draw_onion_dome(ctx, mx, by - 228, 11, 20, hex_rgba("#f0e4d2"))
    draw_onion_dome(ctx, 230, by - 186, 78, 118, hex_rgba("#e3d6c2"))
    save_surf(surf, "landmarks/qutb_shahi_tombs.png")

    # 13. Taramati Baradari (Historic 12-arched hilltop pavilion on steps)
    surf, ctx = new_surf(460, 310)
    by = 302
    # Stepped sandstone hill base
    ctx.move_to(28, by)
    ctx.line_to(72, by - 82)
    ctx.line_to(388, by - 82)
    ctx.line_to(432, by)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#8e7562"))
    ctx.rectangle(74, by - 102, 312, 22)
    stroke_fill(ctx, hex_rgba("#c9b092"))
    # Multi-arched open-air Baradari pavilion
    ctx.rectangle(104, by - 224, 252, 122)
    stroke_fill(ctx, hex_rgba("#e8d6b8"))
    for ax in [136, 184, 230, 276, 324]:
        draw_arch(ctx, ax, by - 102, 30, 82)
        stroke_fill(ctx, hex_rgba("#463932"))
    ctx.rectangle(94, by - 238, 272, 16)
    stroke_fill(ctx, hex_rgba("#c29f74"))
    for mx in [108, 352]:
        draw_onion_dome(ctx, mx, by - 238, 12, 22, hex_rgba("#ecdcc2"))
    save_surf(surf, "landmarks/taramati_baradari.png")

    # 14. Falaknuma Palace (Palladian hilltop white palace "Mirror of the Sky")
    surf, ctx = new_surf(480, 310)
    by = 302
    ctx.move_to(24, by)
    ctx.line_to(64, by - 44)
    ctx.line_to(416, by - 44)
    ctx.line_to(456, by)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#6e7e5e"))
    # Wide Palladian white palace facade
    ctx.rectangle(52, by - 178, 376, 134)
    stroke_fill(ctx, hex_rgba("#f8f6f0"))
    # Central triangular pediment portico & columns
    ctx.rectangle(170, by - 196, 140, 152)
    stroke_fill(ctx, hex_rgba("#ffffff"))
    ctx.move_to(162, by - 196); ctx.line_to(240, by - 244); ctx.line_to(318, by - 196); ctx.close_path()
    stroke_fill(ctx, hex_rgba("#e8e2d4"))
    for cx in [186, 212, 240, 268, 294]:
        ctx.rectangle(cx - 4, by - 188, 8, 144)
        stroke_fill(ctx, hex_rgba("#e4dfd5"), lw=1.6)
    for wx in [82, 114, 144, 336, 366, 398]:
        ctx.rectangle(wx - 8, by - 152, 16, 36)
        stroke_fill(ctx, hex_rgba("#7690aa"), lw=1.6)
        ctx.rectangle(wx - 8, by - 96, 16, 36)
        stroke_fill(ctx, hex_rgba("#7690aa"), lw=1.6)
    save_surf(surf, "landmarks/falaknuma_palace.png")

    # 15. Golconda Fort (Stepped granite hill, massive bastions & Bala Hissar citadel!)
    surf, ctx = new_surf(480, 380)
    by = 372
    # Iconic granite hill boulders at base & flanks
    ctx.move_to(24, by)
    ctx.line_to(64, by - 156)
    ctx.line_to(164, by - 252)
    ctx.line_to(316, by - 252)
    ctx.line_to(416, by - 156)
    ctx.line_to(456, by)
    ctx.close_path()
    stroke_fill(ctx, hex_rgba("#766a61"))
    # Upper Bala Hissar Pavilion Citadel
    ctx.rectangle(168, by - 322, 144, 82)
    stroke_fill(ctx, hex_rgba("#9c8d7d"))
    draw_arch(ctx, 240, by - 240, 44, 58)
    stroke_fill(ctx, hex_rgba("#2f2722"))
    for cx in range(174, 308, 18):
        ctx.rectangle(cx, by - 332, 10, 10)
        stroke_fill(ctx, hex_rgba("#ab9c8a"), lw=1.6)
    # Lower Fateh Darwaza / Outer Fort Ramparts & Bastions
    ctx.rectangle(46, by - 142, 388, 142)
    stroke_fill(ctx, hex_rgba("#645a52"))
    for bx in [74, 406]:
        ctx.rectangle(bx - 30, by - 164, 60, 164)
        stroke_fill(ctx, hex_rgba("#72665c"))
    for cx in range(44, 434, 22):
        ctx.arc(cx + 7, by - 142, 8, math.pi, 0)
        stroke_fill(ctx, hex_rgba("#7b6e64"), lw=1.8)
    # Grand pointed Fateh Darwaza arch
    draw_arch(ctx, 240, by, 92, 114)
    stroke_fill(ctx, hex_rgba("#2a221d"))
    # Saffron/Gold heritage banner on Citadel crest
    ctx.set_source_rgba(*OUTLINE); ctx.set_line_width(2.5)
    ctx.move_to(240, by - 332); ctx.line_to(240, by - 368); ctx.stroke()
    ctx.move_to(240, by - 368); ctx.line_to(268, by - 359); ctx.line_to(240, by - 350); ctx.close_path()
    stroke_fill(ctx, hex_rgba("#ea922e"), lw=1.8)
    save_surf(surf, "landmarks/golconda_fort.png")


# =====================================================================
# 5. HYDERABAD PROPS, BUILDINGS, TREES, FINISH ARCH & FOREGROUND
# =====================================================================

def gen_props_and_finish_arch():
    # 1. Custom Golconda Fort Hyderabad Finish Arch (1000m Victory Arch)
    surf, ctx = new_surf(460, 340)
    by = 334
    # Flanking granite fort gate pillars with octagonal domes
    for px in [100, 360]:
        ctx.rectangle(px - 28, by - 238, 56, 238)
        stroke_fill(ctx, hex_rgba("#8e7a67"))
        ctx.rectangle(px - 34, by - 246, 68, 12)
        stroke_fill(ctx, hex_rgba("#c8a878"))
        draw_onion_dome(ctx, px, by - 246, 24, 34, hex_rgba("#e2c79a"))
    # Ornate arched lintel & parapet between towers
    ctx.rectangle(128, by - 242, 204, 62)
    stroke_fill(ctx, hex_rgba("#a88e74"))
    for cx in range(136, 326, 20):
        ctx.arc(cx + 6, by - 242, 7, math.pi, 0)
        stroke_fill(ctx, hex_rgba("#c8a878"), lw=1.8)
    # Central dark crimson signboard for FinishArchV2 banner
    ctx.rectangle(148, by - 228, 164, 34)
    stroke_fill(ctx, hex_rgba("#7a222b"))
    save_surf(surf, "props/prop_hyd_arch_golconda.png")

    # 2. Old Hyderabad Heritage House (cream lime-plaster & arches)
    surf, ctx = new_surf(260, 200)
    by = 194
    ctx.rectangle(26, by - 122, 208, 122)
    stroke_fill(ctx, hex_rgba("#e6d5ba"))
    ctx.rectangle(20, by - 134, 220, 14)
    stroke_fill(ctx, hex_rgba("#b9956b"))
    for ax in [76, 130, 184]:
        draw_arch(ctx, ax, by, 32, 68)
        stroke_fill(ctx, hex_rgba("#3b2d26"))
    save_surf(surf, "props/house_hyd_oldcity_haveli.png")

    # 3. Indo-Saracenic City Heritage Mansion
    surf, ctx = new_surf(260, 210)
    by = 204
    ctx.rectangle(22, by - 136, 216, 136)
    stroke_fill(ctx, hex_rgba("#dfd2c0"))
    draw_onion_dome(ctx, 130, by - 136, 26, 36, hex_rgba("#c88462"))
    for wx in [66, 130, 194]:
        draw_arch(ctx, wx, by - 12, 26, 56)
        stroke_fill(ctx, hex_rgba("#46596e"))
    save_surf(surf, "props/house_hyd_heritage_mansion.png")

    # 4. Famous Hyderabadi Irani Chai & Osmania Biscuit Cafe
    surf, ctx = new_surf(250, 190)
    by = 184
    ctx.rectangle(24, by - 116, 202, 116)
    stroke_fill(ctx, hex_rgba("#f0e3c8"))
    ctx.rectangle(18, by - 134, 214, 22)
    stroke_fill(ctx, hex_rgba("#1f6454"))
    ctx.set_source_rgba(*hex_rgba("#ffd966"))
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(13.5)
    ctx.move_to(56, by - 118)
    ctx.show_text("IRANI CHAI CAFE")
    draw_arch(ctx, 84, by, 44, 72)
    stroke_fill(ctx, hex_rgba("#352820"))
    ctx.rectangle(142, by - 72, 62, 42)
    stroke_fill(ctx, hex_rgba("#8ac0d8"))
    save_surf(surf, "props/shop_hyd_irani_chai.png")

    # 5. Old City Arched Bazaar Gate / Stone Facade
    surf, ctx = new_surf(220, 170)
    by = 164
    ctx.rectangle(28, by - 110, 164, 110)
    stroke_fill(ctx, hex_rgba("#cdb492"))
    draw_arch(ctx, 110, by, 58, 78)
    stroke_fill(ctx, hex_rgba("#382b24"))
    save_surf(surf, "props/prop_hyd_oldcity_gate.png")

    # 6. Golconda Fort Stone Wall Segment
    surf, ctx = new_surf(240, 130)
    by = 124
    ctx.rectangle(14, by - 78, 212, 78)
    stroke_fill(ctx, hex_rgba("#6c6157"))
    for cx in range(20, 216, 24):
        ctx.rectangle(cx, by - 90, 14, 12)
        stroke_fill(ctx, hex_rgba("#7a6e63"), lw=1.8)
    save_surf(surf, "props/prop_hyd_golconda_wall.png")

    # 7. Deccan Granite Boulder Tor
    surf, ctx = new_surf(200, 150)
    by = 144
    ctx.arc(82, by - 36, 46, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#6a615c"))
    ctx.arc(130, by - 28, 34, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#7c716a"))
    ctx.arc(96, by - 78, 32, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#877c74"))
    save_surf(surf, "props/prop_hyd_granite_tor.png")

    # 8. Ornate Necklace Road Streetlight
    surf, ctx = new_surf(80, 200)
    by = 194
    ctx.rectangle(36, by - 156, 8, 156)
    stroke_fill(ctx, hex_rgba("#2b3642"), lw=2.0)
    ctx.rectangle(28, by - 14, 24, 14)
    stroke_fill(ctx, hex_rgba("#3d4a58"), lw=2.0)
    ctx.arc(40, by - 166, 13, 0, math.tau)
    stroke_fill(ctx, hex_rgba("#fff0a8"), lw=2.0)
    save_surf(surf, "props/prop_hyd_streetlight.png")

    # 9. Gulmohar / Flame of the Forest City Tree
    surf, ctx = new_surf(220, 220)
    by = 214
    ctx.set_source_rgba(*hex_rgba("#523a27"))
    ctx.set_line_width(12.0)
    ctx.move_to(110, by); ctx.line_to(110, by - 104); ctx.stroke()
    for dx, dy, r, c in [(-38, 122, 40, "#467a3e"), (38, 120, 38, "#467a3e"), (0, 148, 48, "#598c47")]:
        ctx.arc(110 + dx, by - dy, r, 0, math.tau)
        stroke_fill(ctx, hex_rgba(c), lw=2.2)
    for fx, fy in [(88, 144), (112, 168), (138, 138), (94, 118), (124, 116)]:
        ctx.arc(fx, by - fy, 9, 0, math.tau)
        stroke_fill(ctx, hex_rgba("#e24e2b"), lw=1.6)
    save_surf(surf, "props/tree_hyd_gulmohar.png")

    # 10. Neem Avenue Tree
    surf, ctx = new_surf(200, 220)
    by = 214
    ctx.set_source_rgba(*hex_rgba("#4c3625"))
    ctx.set_line_width(11.0)
    ctx.move_to(100, by); ctx.line_to(100, by - 110); ctx.stroke()
    for dx, dy, r, c in [(-32, 120, 36, "#3f6e3a"), (32, 118, 34, "#3f6e3a"), (0, 146, 44, "#4f8344")]:
        ctx.arc(100 + dx, by - dy, r, 0, math.tau)
        stroke_fill(ctx, hex_rgba(c), lw=2.2)
    save_surf(surf, "props/tree_hyd_neem.png")

    # 11. Lakeside Palm Tree (Hussain Sagar)
    surf, ctx = new_surf(180, 240)
    by = 234
    ctx.set_source_rgba(*hex_rgba("#6a503a"))
    ctx.set_line_width(10.0)
    ctx.move_to(90, by)
    ctx.curve_to(84, by - 76, 98, by - 134, 92, by - 186)
    ctx.stroke()
    for ang in [-2.6, -1.9, -1.0, -0.3, 0.3, 1.0]:
        ctx.save()
        ctx.translate(92, by - 186)
        ctx.rotate(ang)
        ctx.move_to(0, 0)
        ctx.curve_to(24, -14, 48, -6, 62, 10)
        ctx.curve_to(38, 6, 18, 8, 0, 0)
        stroke_fill(ctx, hex_rgba("#477c3e"), lw=1.8)
        ctx.restore()
    save_surf(surf, "props/tree_hyd_palm.png")

    # 12. Roadside Bougainvillea & Deccan Scrub Bushes
    surf, ctx = new_surf(130, 86)
    by = 80
    for dx, r, c in [(-24, 24, "#447338"), (22, 22, "#447338"), (0, 30, "#558744")]:
        ctx.arc(65 + dx, by - r + 4, r, 0, math.tau)
        stroke_fill(ctx, hex_rgba(c), lw=2.0)
    for fx, fy in [(46, 36), (68, 48), (84, 34)]:
        ctx.arc(fx, by - fy, 5.5, 0, math.tau)
        stroke_fill(ctx, hex_rgba("#c93d7a"), lw=1.4)
    save_surf(surf, "props/bush_hyd_bougainvillea.png")

    surf, ctx = new_surf(120, 76)
    by = 70
    for dx, r, c in [(-20, 20, "#667442"), (20, 18, "#667442"), (0, 24, "#79884e")]:
        ctx.arc(60 + dx, by - r + 4, r, 0, math.tau)
        stroke_fill(ctx, hex_rgba(c), lw=2.0)
    save_surf(surf, "props/bush_hyd_scrub.png")

    # 13. Foreground Stone Verge & Planter Shrub
    surf, ctx = new_surf(160, 68)
    by = 64
    ctx.rectangle(14, by - 16, 132, 16)
    stroke_fill(ctx, hex_rgba("#7a736b"))
    for dx, r in [(42, 18), (80, 22), (118, 18)]:
        ctx.arc(dx, by - 16 - r * 0.45, r, math.pi, 0)
        stroke_fill(ctx, hex_rgba("#4b7a42"), lw=1.8)
    save_surf(surf, "foreground/fg_hyd_road_verge.png")


if __name__ == "__main__":
    gen_skies_and_clouds()
    gen_distant_layers()
    gen_midground_layers()
    gen_hyderabad_landmarks()
    gen_props_and_finish_arch()
    print("All Hyderabad v3 assets generated in:", OUT)
