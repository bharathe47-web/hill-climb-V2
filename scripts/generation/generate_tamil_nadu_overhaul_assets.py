#!/usr/bin/env python3
"""
Generate Tamil Nadu v3 regional vector artwork for Hill Climb V2:
- 3 regional sky gradients (1920x720) + natural clouds (1920x230)
- 6 seamless distant skyline panoramas (1920x440)
- 6 seamless midground panoramas (1920x420)
- Brand-new Dravidian landmark PNGs (Brihadeeswarar Temple, Kapaleeshwarar Temple,
  Vivekananda Rock Memorial, Marina Lighthouse, Chennai Finish Arch)
- Zone-specific regional props (Wind turbine, Paddy canal, Traffic signal, Flyover pier,
  Stone mandapam, Granite outcrop, Banana grove cluster, Palmyra cluster)
All generated with pycairo for razor-sharp mobile 2D vector style.
"""

import math
import os
import cairo

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
V3_DIR = os.path.join(ROOT, "assets", "indian_locations", "tamil_nadu", "v3")
for sub in ("parallax", "landmarks", "props"):
    os.makedirs(os.path.join(V3_DIR, sub), exist_ok=True)


def hex_rgba(h: str, a: float = 1.0):
    h = h.lstrip("#")
    return (
        int(h[0:2], 16) / 255.0,
        int(h[2:4], 16) / 255.0,
        int(h[4:6], 16) / 255.0,
        a,
    )


def new_surf(w: int, h: int):
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    return surf, cairo.Context(surf)


def save_surf(surf, rel_path: str):
    out = os.path.join(V3_DIR, rel_path)
    surf.write_to_png(out)
    print(f"Generated: {rel_path}")


def draw_periodic_hill(ctx, w: int, base_y: float, h: int, amps, freqs, phases, col):
    ctx.set_source_rgba(*col)
    ctx.move_to(0, h)
    steps = 160
    for i in range(steps + 1):
        t = i / steps
        ang = t * math.tau
        y = base_y
        for a, f, ph in zip(amps, freqs, phases):
            y -= a * math.sin(ang * f + ph)
        ctx.line_to(t * w, y)
    ctx.line_to(w, h)
    ctx.close_path()
    ctx.fill()


def draw_dravidian_gopuram(ctx, cx: float, by: float, base_w: float, tot_h: float, tiers: int,
                           stone_col: str, body_cols: list, outline_alpha: float = 0.0):
    # Base adhishthana stone plinth
    plinth_h = tot_h * 0.22
    ctx.set_source_rgba(*hex_rgba(stone_col))
    ctx.rectangle(cx - base_w * 0.52, by - plinth_h, base_w * 1.04, plinth_h)
    ctx.fill()
    # Dark entrance portal
    ctx.set_source_rgba(*hex_rgba("#231C19", 0.90))
    ctx.rectangle(cx - base_w * 0.14, by - plinth_h * 0.78, base_w * 0.28, plinth_h * 0.78)
    ctx.fill()

    tier_area_h = tot_h * 0.72
    tier_h = tier_area_h / tiers
    cur_y = by - plinth_h
    for t in range(tiers):
        frac = t / max(1, tiers - 1)
        tw = base_w * (0.94 - frac * 0.56)
        col = body_cols[t % len(body_cols)]
        ctx.set_source_rgba(*hex_rgba(col))
        ctx.move_to(cx - tw * 0.5, cur_y)
        ctx.line_to(cx - tw * 0.45, cur_y - tier_h * 0.85)
        ctx.line_to(cx + tw * 0.45, cur_y - tier_h * 0.85)
        ctx.line_to(cx + tw * 0.5, cur_y)
        ctx.close_path()
        ctx.fill()
        if outline_alpha > 0.0:
            ctx.set_source_rgba(*hex_rgba("#2A1E17", outline_alpha))
            ctx.set_line_width(1.4)
            ctx.stroke()
        # Cornice ledge
        ctx.set_source_rgba(*hex_rgba("#F4E1BE", 0.65))
        ctx.rectangle(cx - tw * 0.52, cur_y - tier_h * 0.92, tw * 1.04, tier_h * 0.14)
        ctx.fill()
        # Miniature kudu arched windows
        if tw > 22:
            n_win = max(2, int(tw / 16))
            for wi in range(n_win):
                wx = cx - tw * 0.36 + (wi / max(1, n_win - 1)) * (tw * 0.72) if n_win > 1 else cx
                ctx.set_source_rgba(*hex_rgba("#3B281E", 0.55))
                ctx.rectangle(wx - 2.5, cur_y - tier_h * 0.72, 5.0, tier_h * 0.48)
                ctx.fill()
        cur_y -= tier_h

    # Crown shala barrel roof + golden kalasams
    crown_w = base_w * 0.40
    crown_h = tot_h * 0.10
    ctx.set_source_rgba(*hex_rgba("#C85D38"))
    ctx.move_to(cx - crown_w * 0.5, cur_y)
    ctx.curve_to(cx - crown_w * 0.45, cur_y - crown_h * 1.1,
                 cx + crown_w * 0.45, cur_y - crown_h * 1.1,
                 cx + crown_w * 0.5, cur_y)
    ctx.close_path()
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#F3C242"))
    for k in (-1, 0, 1):
        kx = cx + k * crown_w * 0.28
        ctx.arc(kx, cur_y - crown_h * 0.92, 2.8, 0, math.tau)
        ctx.fill()


def draw_palm(ctx, x: float, gy: float, scale: float, bend: float, palmyra: bool, tint: str):
    ctx.save()
    ctx.translate(x, gy)
    ctx.scale(scale, scale)
    trunk_h = 112.0 if palmyra else 92.0
    ctx.set_source_rgba(*hex_rgba("#4C382A"))
    ctx.set_line_width(6.5 if not palmyra else 5.2)
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    ctx.move_to(0, 0)
    ctx.curve_to(bend * 0.3, -trunk_h * 0.35, bend * 0.8, -trunk_h * 0.7, bend, -trunk_h)
    ctx.stroke()

    tx, ty = bend, -trunk_h
    ctx.set_source_rgba(*hex_rgba(tint))
    n_fronds = 9 if palmyra else 7
    for i in range(n_fronds):
        ang = -math.pi * 0.12 - (i / max(1, n_fronds - 1)) * math.pi * 0.76
        if palmyra:
            # Stiff fan-shaped palmyra fronds radiating cleanly
            ang = math.pi + (i / max(1, n_fronds - 1) - 0.5) * math.pi * 1.25 - math.pi * 0.5
            ctx.move_to(tx, ty)
            fx = tx + math.cos(ang) * 28.0
            fy = ty + math.sin(ang) * 24.0
            ctx.line_to(fx + math.cos(ang + 0.32) * 14, fy + math.sin(ang + 0.32) * 14)
            ctx.line_to(fx + math.cos(ang - 0.32) * 14, fy + math.sin(ang - 0.32) * 14)
            ctx.close_path()
            ctx.fill()
        else:
            # Graceful arching coconut fronds
            side = -1 if i < 3 else 1
            ang_f = (-2.6 + i * 0.52)
            ex = tx + math.cos(ang_f) * 38.0
            ey = ty + math.sin(ang_f) * 26.0 + 12.0
            ctx.set_line_width(3.4)
            ctx.move_to(tx, ty)
            ctx.curve_to(tx + math.cos(ang_f) * 18, ty + math.sin(ang_f) * 18 - 8,
                         ex - side * 4, ey - 8, ex, ey)
            ctx.stroke()
    ctx.restore()


def draw_banana_clump(ctx, cx: float, gy: float, scale: float):
    ctx.save()
    ctx.translate(cx, gy)
    ctx.scale(scale, scale)
    for stem_dx, leaf_col in [(-8, "#4A8A36"), (0, "#5DA442"), (9, "#3F782E")]:
        ctx.set_source_rgba(*hex_rgba("#648D44"))
        ctx.rectangle(stem_dx - 3, -36, 6, 36)
        ctx.fill()
        for ang, lw in [(-2.35, 34), (-1.9, 32), (-1.2, 32), (-0.7, 34)]:
            ctx.set_source_rgba(*hex_rgba(leaf_col))
            ctx.move_to(stem_dx, -34)
            lx = stem_dx + math.cos(ang) * lw
            ly = -34 + math.sin(ang) * 20 + 6
            ctx.curve_to(stem_dx + math.cos(ang) * lw * 0.5, -34 + math.sin(ang) * 24 - 10,
                         lx + 4, ly - 9, lx, ly)
            ctx.curve_to(lx - 3, ly + 8, stem_dx + math.cos(ang) * 10, -28, stem_dx, -31)
            ctx.close_path()
            ctx.fill()
    ctx.restore()


def draw_tamil_house(ctx, cx: float, gy: float, bw: float, bh: float, wall_col: str, roof_col: str):
    # Plinth
    ctx.set_source_rgba(*hex_rgba("#76685C"))
    ctx.rectangle(cx - bw * 0.54, gy - 7, bw * 1.08, 7)
    ctx.fill()
    # Limestone wall with traditional kaavi red-white temple strip along lower wall
    ctx.set_source_rgba(*hex_rgba(wall_col))
    ctx.rectangle(cx - bw * 0.5, gy - bh, bw, bh - 7)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#A8412F"))
    ctx.rectangle(cx - bw * 0.5, gy - 17, bw, 10)
    ctx.fill()
    # Mangalore terracotta pitched roof
    ctx.set_source_rgba(*hex_rgba(roof_col))
    ctx.move_to(cx - bw * 0.58, gy - bh + 2)
    ctx.line_to(cx - bw * 0.42, gy - bh - bh * 0.44)
    ctx.line_to(cx + bw * 0.42, gy - bh - bh * 0.44)
    ctx.line_to(cx + bw * 0.58, gy - bh + 2)
    ctx.close_path()
    ctx.fill()
    # Verandah pillars & door
    ctx.set_source_rgba(*hex_rgba("#3A251B"))
    ctx.rectangle(cx - 7, gy - bh * 0.65, 14, bh * 0.65 - 7)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#523C2D"))
    for pd in (-0.34, 0.34):
        ctx.rectangle(cx + bw * pd - 2, gy - bh + 2, 4, bh - 9)
        ctx.fill()


def draw_wind_turbine(ctx, cx: float, gy: float, scale: float, alpha: float = 0.85):
    ctx.save()
    ctx.translate(cx, gy)
    ctx.scale(scale, scale)
    ctx.set_source_rgba(*hex_rgba("#EBF2F7", alpha))
    ctx.move_to(-4.5, 0)
    ctx.line_to(-1.8, -110)
    ctx.line_to(1.8, -110)
    ctx.line_to(4.5, 0)
    ctx.close_path()
    ctx.fill()
    ctx.arc(0, -110, 4.5, 0, math.tau)
    ctx.fill()
    ctx.set_line_width(3.0)
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    for b in range(3):
        ang = -math.pi * 0.35 + b * (math.tau / 3.0)
        ctx.move_to(0, -110)
        ctx.line_to(math.cos(ang) * 44.0, -110 + math.sin(ang) * 44.0)
        ctx.stroke()
    ctx.restore()


# ==============================================================================
# 1. SKIES & CLOUDS
# ==============================================================================
def build_skies_and_clouds():
    skies = [
        ("sky_tn_01_sunrise.png", [
            (0.00, "#2B74B8"), (0.48, "#5DAAD8"), (0.80, "#F4CA8A"), (1.00, "#F9B176")
        ], (1480, 320, "#FFF4CE")),
        ("sky_tn_02_warm_day.png", [
            (0.00, "#2E78BE"), (0.55, "#6BB4E0"), (0.85, "#CBE5F3"), (1.00, "#F7E6BE")
        ], (1380, 220, "#FFF8DF")),
        ("sky_tn_03_golden_hour.png", [
            (0.00, "#3D558B"), (0.42, "#7C7BA8"), (0.76, "#E0976E"), (1.00, "#F6C97D")
        ], (1420, 300, "#FFE29A")),
    ]
    w, h = 1920, 720
    for fname, stops, (sx, sy, sun_col) in skies:
        surf, ctx = new_surf(w, h)
        pat = cairo.LinearGradient(0, 0, 0, h)
        for offset, hx in stops:
            pat.add_color_stop_rgba(offset, *hex_rgba(hx))
        ctx.set_source(pat)
        ctx.rectangle(0, 0, w, h)
        ctx.fill()

        # Soft atmospheric warm sun glow
        g = cairo.RadialGradient(sx, sy, 10, sx, sy, 230)
        g.add_color_stop_rgba(0.0, *hex_rgba(sun_col, 0.92))
        g.add_color_stop_rgba(0.22, *hex_rgba(sun_col, 0.42))
        g.add_color_stop_rgba(1.0, *hex_rgba(sun_col, 0.0))
        ctx.set_source(g)
        ctx.arc(sx, sy, 230, 0, math.tau)
        ctx.fill()
        save_surf(surf, f"parallax/{fname}")

    # Soft natural clouds
    cw, ch = 1920, 230
    surf, ctx = new_surf(cw, ch)
    clusters = [
        (210, 92, 1.0), (620, 128, 0.85), (1080, 82, 1.15), (1540, 120, 0.92)
    ]
    for cx, cy, sc in clusters:
        for dx, dy, r in [(-42, 8, 26), (-18, -8, 34), (18, -4, 30), (46, 10, 22), (0, 12, 36)]:
            ctx.set_source_rgba(*hex_rgba("#FFFFFF", 0.56))
            ctx.save()
            ctx.translate(cx + dx * sc, cy + dy * sc)
            ctx.scale(1.45 * sc, 0.72 * sc)
            ctx.arc(0, 0, r, 0, math.tau)
            ctx.fill()
            ctx.restore()
    save_surf(surf, "parallax/clouds_tn_natural.png")


# ==============================================================================
# 2. SIX REGIONAL DISTANT PANORAMAS (1920x440)
# ==============================================================================
def build_distant_panoramas():
    w, h = 1920, 440

    # Zone 1: Kanyakumari Coast (Ocean horizon + cliffs + distant sailing vessels + birds)
    surf, ctx = new_surf(w, h)
    # Distant misty headland silhouette on far right/left wrapped smoothly
    draw_periodic_hill(ctx, w, 250, h, [32, 16], [1, 3], [0.4, 1.2], hex_rgba("#5285A0", 0.55))
    # Shimmering Indian Ocean band
    sea = cairo.LinearGradient(0, 235, 0, h)
    sea.add_color_stop_rgba(0.0, *hex_rgba("#1A7BA6", 0.92))
    sea.add_color_stop_rgba(0.45, *hex_rgba("#116085", 0.96))
    sea.add_color_stop_rgba(1.0, *hex_rgba("#C29D63", 1.0))
    ctx.set_source(sea)
    ctx.rectangle(0, 235, w, h - 235)
    ctx.fill()
    # Gentle surf crests & distant catamarans
    ctx.set_source_rgba(*hex_rgba("#E0F6FF", 0.55))
    for wx in range(60, w, 175):
        ctx.rectangle(wx, 268 + (wx % 23), 72, 3)
        ctx.fill()
    for bx in (320, 960, 1610):
        ctx.set_source_rgba(*hex_rgba("#2D4F63", 0.75))
        ctx.move_to(bx - 22, 248)
        ctx.line_to(bx + 22, 248)
        ctx.line_to(bx + 14, 256)
        ctx.line_to(bx - 16, 256)
        ctx.close_path()
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#FFF5E1", 0.75))
        ctx.move_to(bx - 2, 246)
        ctx.line_to(bx - 2, 214)
        ctx.line_to(bx + 14, 242)
        ctx.close_path()
        ctx.fill()
    draw_periodic_hill(ctx, w, 348, h, [14, 8], [2, 5], [0.2, 1.4], hex_rgba("#4E8859", 0.95))
    draw_periodic_hill(ctx, w, 392, h, [10, 6], [3, 6], [0.8, 0.3], hex_rgba("#B38C56", 1.0))
    save_surf(surf, "parallax/dist_01_kanyakumari.png")

    # Zone 2: Tirunelveli Countryside (Western Ghats + Muppandal Wind Turbines + Red-brown Scrub)
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, 245, h, [68, 28, 12], [2, 4, 7], [0.2, 1.3, 0.5], hex_rgba("#4D758F", 0.65))
    for tx in (260, 410, 560, 1080, 1240, 1680, 1810):
        draw_wind_turbine(ctx, tx, 275, 0.78, 0.78)
    draw_periodic_hill(ctx, w, 285, h, [34, 18], [3, 6], [1.1, 2.2], hex_rgba("#637D5E", 0.88))
    draw_periodic_hill(ctx, w, 360, h, [18, 10], [2, 5], [0.7, 1.8], hex_rgba("#8C5338", 1.0))
    save_surf(surf, "parallax/dist_02_tirunelveli.png")

    # Zone 3: Madurai Heritage City (Warm Sandstone Skyline + Colorful Gopuram Silhouettes + Samanar Ridge)
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, 280, h, [32, 16], [2, 4], [0.4, 2.0], hex_rgba("#7D6B7D", 0.58))
    for gx, bh, col_set in [
        (320, 150, ["#B8624D", "#C88E4B", "#4B7F78"]),
        (420, 185, ["#C85842", "#D49B4E", "#48867C"]),
        (530, 155, ["#B8624D", "#C88E4B", "#4B7F78"]),
        (1240, 165, ["#C45B46", "#D0954A", "#4A8177"]),
        (1355, 195, ["#C85842", "#D49B4E", "#48867C"]),
        (1465, 150, ["#B8624D", "#C88E4B", "#4B7F78"]),
    ]:
        draw_dravidian_gopuram(ctx, gx, 330, bh * 0.45, bh, 5, "#6E5A52", col_set, 0.0)
    draw_periodic_hill(ctx, w, 335, h, [18, 8], [3, 6], [0.9, 1.4], hex_rgba("#597D49", 0.94))
    draw_periodic_hill(ctx, w, 382, h, [12, 6], [2, 5], [0.2, 2.1], hex_rgba("#8E5D44", 1.0))
    save_surf(surf, "parallax/dist_03_madurai.png")

    # Zone 4: Trichy Heritage (Rockfort Citadel Hill + Srirangam Gopurams + Cauvery River Horizon)
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, 290, h, [22, 10], [2, 5], [0.5, 1.3], hex_rgba("#768696", 0.58))
    # Rockfort twin granite outcrops wrapped neatly
    for rx in (440, 1420):
        ctx.set_source_rgba(*hex_rgba("#7A523B", 0.90))
        ctx.move_to(rx - 140, 325)
        ctx.curve_to(rx - 110, 200, rx - 30, 130, rx + 25, 132)
        ctx.curve_to(rx + 85, 134, rx + 125, 220, rx + 150, 325)
        ctx.close_path()
        ctx.fill()
        # Crown pillared temple silhouette
        ctx.set_source_rgba(*hex_rgba("#D8AE76", 0.92))
        ctx.rectangle(rx - 22, 112, 48, 22)
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#B34C32", 0.92))
        ctx.move_to(rx - 6, 112)
        ctx.line_to(rx + 4, 86)
        ctx.line_to(rx + 14, 112)
        ctx.close_path()
        ctx.fill()
    for sx in (880, 1780):
        draw_dravidian_gopuram(ctx, sx, 315, 58, 125, 4, "#7C6D63", ["#D8C3A4", "#C8955A", "#7A9890"], 0.0)
    # Sparkling Cauvery River strip
    ctx.set_source_rgba(*hex_rgba("#3885AD", 0.90))
    ctx.rectangle(0, 312, w, 46)
    ctx.fill()
    draw_periodic_hill(ctx, w, 368, h, [12, 7], [3, 6], [0.2, 1.1], hex_rgba("#527C47", 1.0))
    save_surf(surf, "parallax/dist_04_trichy.png")

    # Zone 5: Thanjavur Cultural Landscape (Chola Brihadeeswarar Skyline + Fertile Emerald & Gold Paddy)
    surf, ctx = new_surf(w, h)
    draw_periodic_hill(ctx, w, 285, h, [18, 9], [2, 5], [0.4, 1.9], hex_rgba("#8A8E7A", 0.55))
    # Distant towering Chola Brihadeeswarar vimana silhouette
    for tx in (540, 1520):
        draw_dravidian_gopuram(ctx, tx, 318, 74, 165, 6, "#A87C4F", ["#B88854", "#9E7042", "#C49762"], 0.0)
    # Lush terraced green & ripe harvest-gold paddy plain
    draw_periodic_hill(ctx, w, 318, h, [10, 5], [2, 4], [0.2, 1.5], hex_rgba("#649C3D", 0.94))
    draw_periodic_hill(ctx, w, 355, h, [8, 4], [3, 6], [1.2, 0.8], hex_rgba("#B3A53A", 0.96))
    draw_periodic_hill(ctx, w, 392, h, [6, 3], [2, 5], [0.6, 1.7], hex_rgba("#4C7E32", 1.0))
    save_surf(surf, "parallax/dist_05_thanjavur.png")

    # Zone 6: Chennai City (Modern Skyline + Coromandel Bay Horizon + Marina Lighthouse Beacon)
    surf, ctx = new_surf(w, h)
    # Distant Coromandel Bay blue band
    ctx.set_source_rgba(*hex_rgba("#2B74A0", 0.72))
    ctx.rectangle(0, 260, w, 65)
    ctx.fill()
    # Varied modern Chennai highrises & heritage domes wrapped across 1920px
    buildings = [
        (120, 62, 130, "#4F6782"), (200, 48, 96, "#5C7590"), (290, 74, 155, "#425B78"),
        (410, 56, 118, "#6A829D"), (530, 82, 170, "#3D5570"), (660, 58, 108, "#58708A"),
        (820, 66, 142, "#4B6480"), (940, 48, 92, "#657E99"), (1060, 78, 165, "#3E5672"),
        (1210, 55, 116, "#5A738D"), (1350, 70, 148, "#47607C"), (1490, 52, 104, "#617A94"),
        (1640, 84, 174, "#3A526D"), (1790, 60, 125, "#536C87"),
    ]
    for bx, bw, bh, bcol in buildings:
        ctx.set_source_rgba(*hex_rgba(bcol, 0.88))
        ctx.rectangle(bx, 318 - bh, bw, bh)
        ctx.fill()
        # Subtle lit glass window stripes
        ctx.set_source_rgba(*hex_rgba("#C5E6FA", 0.35))
        for ry in range(int(326 - bh), 308, 14):
            ctx.rectangle(bx + 7, ry, bw - 14, 5)
            ctx.fill()
    # Urban green boulevard belt
    draw_periodic_hill(ctx, w, 348, h, [8, 4], [2, 5], [0.5, 1.3], hex_rgba("#4A6E50", 0.96))
    draw_periodic_hill(ctx, w, 386, h, [5, 3], [3, 6], [0.8, 0.2], hex_rgba("#525864", 1.0))
    save_surf(surf, "parallax/dist_06_chennai.png")


# ==============================================================================
# 3. SIX REGIONAL MIDGROUND PANORAMAS (1920x420)
# ==============================================================================
def build_midground_panoramas():
    w, h = 1920, 420
    gy = 300.0

    # 1. Kanyakumari Coast: Fishing village cottages, boats/nets, coconut palms, sandy berm
    surf, ctx = new_surf(w, h)
    for hx, bw, bh, wc, rc in [
        (180, 92, 56, "#EFE0C6", "#A95035"), (680, 108, 62, "#E8D4B4", "#8D432C"),
        (1190, 96, 58, "#EFE0C6", "#B35B3A"), (1660, 104, 60, "#E5CFAF", "#94462E"),
    ]:
        draw_tamil_house(ctx, hx, gy + 8, bw, bh, wc, rc)
    for bx in (420, 940, 1440):
        # Resting wooden catamaran boat on golden sand shore
        ctx.set_source_rgba(*hex_rgba("#6E4427"))
        ctx.move_to(bx - 38, gy + 4)
        ctx.line_to(bx + 38, gy + 4)
        ctx.line_to(bx + 28, gy + 18)
        ctx.line_to(bx - 28, gy + 18)
        ctx.close_path()
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#E07E3C"))
        ctx.rectangle(bx - 22, gy + 4, 44, 5)
        ctx.fill()
    for px, sc, bnd in [(95, 0.85, -14), (290, 0.98, 18), (540, 0.90, -10),
                        (820, 1.02, 16), (1070, 0.88, -16), (1320, 0.95, 14),
                        (1550, 0.90, -12), (1820, 0.96, 15)]:
        for wx in (px - w, px, px + w):
            if -80 <= wx <= w + 80:
                draw_palm(ctx, wx, gy + 8, sc, bnd, False, "#3B7A3B")
    draw_periodic_hill(ctx, w, gy + 14, h, [12, 6], [2, 5], [0.3, 1.2], hex_rgba("#D6B67D"))
    save_surf(surf, "parallax/mid_01_kanyakumari.png")

    # 2. Tirunelveli Countryside: Tall Palmyras, wind turbines, red laterite scrub, rural huts
    surf, ctx = new_surf(w, h)
    for tx in (220, 860, 1480):
        draw_wind_turbine(ctx, tx, gy + 6, 1.05, 0.90)
    for hx, bw, bh in [(460, 86, 52), (1140, 96, 58), (1720, 88, 54)]:
        draw_tamil_house(ctx, hx, gy + 8, bw, bh, "#E8D3B0", "#9E462C")
    for px, sc, bnd in [(120, 0.96, 5), (340, 1.05, -6), (620, 0.92, 4),
                        (740, 1.02, -4), (990, 0.98, 6), (1300, 1.04, -5),
                        (1600, 0.94, 4), (1850, 1.00, -5)]:
        for wx in (px - w, px, px + w):
            if -80 <= wx <= w + 80:
                draw_palm(ctx, wx, gy + 10, sc, bnd, True, "#4A7D3C")
    draw_periodic_hill(ctx, w, gy + 14, h, [14, 7], [3, 5], [0.9, 1.8], hex_rgba("#9E5133"))
    save_surf(surf, "parallax/mid_02_tirunelveli.png")

    # 3. Madurai Heritage City: Traditional Tamil street facades, mandapams, market awnings, trees
    surf, ctx = new_surf(w, h)
    for hx, bw, bh, wc, rc in [
        (160, 125, 78, "#F2DFBF", "#9C462D"), (310, 110, 68, "#E8C698", "#B35434"),
        (590, 130, 82, "#EFE2CA", "#8F3E28"), (920, 120, 74, "#EED4AE", "#A84E32"),
        (1240, 136, 86, "#F2DFBF", "#94422B"), (1560, 118, 72, "#EAD0AA", "#AD5234"),
        (1780, 112, 70, "#EFE2CA", "#94422B"),
    ]:
        draw_tamil_house(ctx, hx, gy + 6, bw, bh, wc, rc)
    # Pillared stone mandapam + gopuram accents
    for mx in (455, 1085, 1410):
        ctx.set_source_rgba(*hex_rgba("#76685C"))
        ctx.rectangle(mx - 48, gy - 68, 96, 14)
        ctx.fill()
        for p in (-36, -12, 12, 36):
            ctx.rectangle(mx + p - 4, gy - 54, 8, 60)
            ctx.fill()
    for tx in (760, 1690):
        draw_palm(ctx, tx, gy + 8, 0.92, -10, False, "#3F7D3E")
    draw_periodic_hill(ctx, w, gy + 12, h, [8, 4], [2, 6], [0.4, 1.1], hex_rgba("#876953"))
    save_surf(surf, "parallax/mid_03_madurai.png")

    # 4. Trichy Heritage: Cauvery riverfront stone arch bridge + ghats + banyan/coconut palms
    surf, ctx = new_surf(w, h)
    # River water bed behind stone arches
    ctx.set_source_rgba(*hex_rgba("#2D769E", 0.90))
    ctx.rectangle(0, gy - 18, w, h - (gy - 18))
    ctx.fill()
    # Stone bridge parapets across riverfront
    ctx.set_source_rgba(*hex_rgba("#BA9F7B"))
    ctx.rectangle(0, gy - 32, w, 14)
    ctx.fill()
    for ax in range(60, w, 160):
        ctx.set_source_rgba(*hex_rgba("#9C8262"))
        ctx.rectangle(ax - 12, gy - 20, 24, 34)
        ctx.fill()
    for gx, sc in [(310, 0.96), (950, 1.04), (1560, 0.94)]:
        draw_dravidian_gopuram(ctx, gx, gy - 32, 46, 98, 4, "#857463", ["#D8BA88", "#BF6545", "#56857D"], 0.0)
    for px in (150, 560, 740, 1180, 1380, 1790):
        draw_palm(ctx, px, gy - 28, 0.85, 10 if px % 3 == 0 else -10, False, "#3D7A3C")
    draw_periodic_hill(ctx, w, gy + 16, h, [8, 4], [2, 5], [0.7, 1.5], hex_rgba("#5C7A46"))
    save_surf(surf, "parallax/mid_04_trichy.png")

    # 5. Thanjavur Cultural Landscape: Paddy fields + Irrigation canal + Banana groves + Tiled houses
    surf, ctx = new_surf(w, h)
    # Irrigation canal water channel along mid-plane (extends behind paddy crest cleanly)
    ctx.set_source_rgba(*hex_rgba("#4392B8", 0.92))
    ctx.rectangle(0, gy - 16, w, 36)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#B7A58A"))
    ctx.rectangle(0, gy - 18, w, 5)
    ctx.fill()
    for hx, bw, bh in [(260, 108, 64), (880, 118, 68), (1510, 104, 62)]:
        draw_tamil_house(ctx, hx, gy - 16, bw, bh, "#F5E7CE", "#A4482D")
    for bx in (110, 420, 640, 1040, 1260, 1680, 1840):
        for wx in (bx - w, bx, bx + w):
            if -60 <= wx <= w + 60:
                draw_banana_clump(ctx, wx, gy - 14, 1.15)
    for px in (530, 760, 1380):
        draw_palm(ctx, px, gy - 16, 0.92, -12, False, "#3E7D3C")
    draw_periodic_hill(ctx, w, gy + 10, h, [7, 4], [2, 5], [0.2, 1.4], hex_rgba("#6E9E3C"))
    save_surf(surf, "parallax/mid_05_thanjavur.png")

    # 6. Chennai City: Flyovers, streetlights, modern apartments, urban trees & Marina promenade
    surf, ctx = new_surf(w, h)
    # Modern urban commercial blocks
    for cx, bw, bh, col in [
        (150, 120, 105, "#CBD5E1"), (310, 95, 130, "#94A3B8"), (520, 130, 112, "#E2E8F0"),
        (780, 115, 145, "#9FB3C8"), (1020, 125, 118, "#CBD5E1"), (1290, 110, 138, "#94A3B8"),
        (1540, 135, 122, "#E2E8F0"), (1760, 105, 115, "#B0C4D8"),
    ]:
        ctx.set_source_rgba(*hex_rgba(col, 0.92))
        ctx.rectangle(cx, gy - bh, bw, bh)
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#38BDF8", 0.45))
        for ry in range(int(gy - bh + 12), int(gy - 16), 16):
            ctx.rectangle(cx + 10, ry, bw - 20, 7)
            ctx.fill()
    # Continuous Chennai metro / flyover deck + concrete piers
    ctx.set_source_rgba(*hex_rgba("#64748B", 0.95))
    ctx.rectangle(0, gy - 54, w, 14)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#475569", 0.95))
    for px in range(80, w, 190):
        ctx.rectangle(px - 8, gy - 40, 16, 46)
        ctx.fill()
    # Streetlights along urban promenade
    for lx in range(110, w, 220):
        ctx.set_source_rgba(*hex_rgba("#334155"))
        ctx.rectangle(lx - 2, gy - 98, 4, 44)
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#FEF08A"))
        ctx.arc(lx, gy - 99, 4.5, 0, math.tau)
        ctx.fill()
    draw_periodic_hill(ctx, w, gy + 8, h, [5, 2], [2, 4], [0.1, 1.1], hex_rgba("#3B4554"))
    save_surf(surf, "parallax/mid_06_chennai.png")


# ==============================================================================
# 4. DEDICATED DRAVIDIAN LANDMARKS & ARCH & REGIONAL PROPS
# ==============================================================================
def build_landmarks_and_props():
    # A. Brihadeeswarar Temple (Thanjavur Big Temple - LOC-TN-21)
    bw, bh = 480, 400
    surf, ctx = new_surf(bw, bh)
    gy = bh - 4.0
    # Granite courtyard plinth
    ctx.set_source_rgba(*hex_rgba("#9A754E"))
    ctx.rectangle(36, gy - 34, bw - 72, 34)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#68492C"))
    ctx.set_line_width(2.0)
    ctx.rectangle(36, gy - 34, bw - 72, 34)
    ctx.stroke()
    # Tall 13-tier Chola pyramidal Sri Vimana in warm ochre sandstone
    vimana_cx = bw * 0.42
    tiers = 11
    start_w = 210.0
    vim_y = gy - 34
    tier_h = 20.0
    for i in range(tiers):
        frac = i / (tiers - 1)
        tw = start_w * (1.0 - frac * 0.68)
        ctx.set_source_rgba(*hex_rgba("#D8A66C" if i % 2 == 0 else "#C69156"))
        ctx.rectangle(vimana_cx - tw * 0.5, vim_y - tier_h, tw, tier_h)
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#523620", 0.72))
        ctx.stroke_preserve()
        # Sandstone pilasters
        n_p = max(3, int(tw / 24))
        for j in range(n_p):
            px = vimana_cx - tw * 0.40 + (j / max(1, n_p - 1)) * tw * 0.80
            ctx.set_source_rgba(*hex_rgba("#8A5B34", 0.75))
            ctx.rectangle(px - 2.5, vim_y - tier_h + 3, 5, tier_h - 6)
            ctx.fill()
        vim_y -= tier_h
    # Iconic monolithic octagonal granite Kumbham / Sikhara cupola
    ctx.set_source_rgba(*hex_rgba("#B97E46"))
    ctx.move_to(vimana_cx - 40, vim_y)
    ctx.curve_to(vimana_cx - 46, vim_y - 46, vimana_cx + 46, vim_y - 46, vimana_cx + 40, vim_y)
    ctx.close_path()
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#3B2818"))
    ctx.stroke()
    # Gold Stupi pinnacle
    ctx.set_source_rgba(*hex_rgba("#F5C842"))
    ctx.rectangle(vimana_cx - 3, vim_y - 68, 6, 28)
    ctx.fill()
    ctx.arc(vimana_cx, vim_y - 72, 6, 0, math.tau)
    ctx.fill()
    # Nandi Mandapam pillared pavilion to the right
    mcx = bw * 0.78
    ctx.set_source_rgba(*hex_rgba("#C9975F"))
    ctx.rectangle(mcx - 56, gy - 102, 112, 16)
    ctx.fill()
    for p in (-42, -16, 16, 42):
        ctx.rectangle(mcx + p - 4, gy - 86, 8, 52)
        ctx.fill()
    # Seated Nandi silhouette inside pavilion
    ctx.set_source_rgba(*hex_rgba("#4A3F3B"))
    ctx.arc(mcx, gy - 48, 16, 0, math.tau)
    ctx.fill()
    ctx.arc(mcx - 14, gy - 58, 8, 0, math.tau)
    ctx.fill()
    save_surf(surf, "landmarks/brihadeeswarar_temple.png")

    # B. Kapaleeshwarar Temple (Mylapore Chennai - LOC-TN-22)
    kw, kh = 420, 420
    surf, ctx = new_surf(kw, kh)
    gy = kh - 4.0
    draw_dravidian_gopuram(
        ctx, kw * 0.5, gy, 240.0, 385.0, 7, "#63554E",
        ["#E36846", "#E8B63E", "#489C68", "#3C87D4", "#D85E8F", "#DF843A", "#5BA65B"],
        outline_alpha=0.80
    )
    save_surf(surf, "landmarks/kapaleeshwarar_temple.png")

    # C. Chennai Finish Arch (Destination 1200m - Coromandel Heritage & Marina Banner)
    aw, ah = 540, 320
    surf, ctx = new_surf(aw, ah)
    gy = ah - 4.0
    # Twin Dravidian sandstone pillars
    for px in (95, aw - 95):
        ctx.set_source_rgba(*hex_rgba("#DFC5A0"))
        ctx.rectangle(px - 24, gy - 210, 48, 210)
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#4A3728"))
        ctx.set_line_width(2.0)
        ctx.stroke()
        # Crown mini-gopuram dome
        ctx.set_source_rgba(*hex_rgba("#D66843"))
        ctx.move_to(px - 28, gy - 210)
        ctx.line_to(px, gy - 256)
        ctx.line_to(px + 28, gy - 210)
        ctx.close_path()
        ctx.fill()
        ctx.set_source_rgba(*hex_rgba("#F5C842"))
        ctx.arc(px, gy - 262, 6, 0, math.tau)
        ctx.fill()
    # Connecting lintel + crimson signboard plaque
    ctx.set_source_rgba(*hex_rgba("#E4CCA6"))
    ctx.rectangle(80, gy - 224, aw - 160, 56)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#4A3728"))
    ctx.stroke()
    ctx.set_source_rgba(*hex_rgba("#8E251F"))
    ctx.rectangle(124, gy - 210, aw - 248, 30)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#F3C242"))
    ctx.set_line_width(2.0)
    ctx.rectangle(124, gy - 210, aw - 248, 30)
    ctx.stroke()
    save_surf(surf, "props/prop_tn_arch_chennai.png")

    # D. Roadside Wind Turbine Prop (Tirunelveli Zone)
    surf, ctx = new_surf(180, 260)
    draw_wind_turbine(ctx, 90, 256, 2.0, 0.96)
    save_surf(surf, "props/prop_tn_wind_turbine.png")

    # E. Urban Traffic Signal & Streetlight Prop (Chennai Zone)
    surf, ctx = new_surf(90, 220)
    ctx.set_source_rgba(*hex_rgba("#374151"))
    ctx.rectangle(41, 22, 8, 194)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#1E293B"))
    ctx.rectangle(29, 14, 32, 74)
    ctx.fill()
    for y_l, lc in [(28, "#EF4444"), (50, "#FACC15"), (72, "#22C55E")]:
        ctx.set_source_rgba(*hex_rgba(lc))
        ctx.arc(45, y_l, 7, 0, math.tau)
        ctx.fill()
    save_surf(surf, "props/prop_tn_traffic_signal.png")

    # F. Stone Mandapam Roadside Prop (Madurai / Trichy / Thanjavur Zones)
    surf, ctx = new_surf(260, 180)
    gy = 176.0
    ctx.set_source_rgba(*hex_rgba("#8C735B"))
    ctx.rectangle(16, gy - 22, 228, 22)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#B39778"))
    ctx.rectangle(24, gy - 118, 212, 18)
    ctx.fill()
    for px in (44, 100, 160, 216):
        ctx.rectangle(px - 6, gy - 100, 12, 78)
        ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#C86D44"))
    ctx.move_to(48, gy - 118)
    ctx.line_to(130, gy - 158)
    ctx.line_to(212, gy - 118)
    ctx.close_path()
    ctx.fill()
    save_surf(surf, "props/prop_tn_mandapam.png")

    # G. Banana Clump Prop (Thanjavur & Kanyakumari Zones)
    surf, ctx = new_surf(180, 160)
    draw_banana_clump(ctx, 90, 156, 2.2)
    save_surf(surf, "props/prop_tn_banana_clump.png")


if __name__ == "__main__":
    build_skies_and_clouds()
    build_distant_panoramas()
    build_midground_panoramas()
    build_landmarks_and_props()
    print("All Tamil Nadu v3 vector assets generated in:", V3_DIR)
