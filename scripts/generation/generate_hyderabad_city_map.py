#!/usr/bin/env python3
"""
Generate a dedicated Hyderabad City Route Map vector illustration for RouteMapOverlay.
Matches RouteMapOverlay's dark-navy & cyan-gold HUD palette while depicting real
Hyderabad geography: Musi River, Old City (South-East), Nampally/Heritage Core,
heart-shaped Hussain Sagar Lake + Tank Bund / Necklace Road, and Golconda Citadel Hills (West).
"""

import math
import os
import cairo

W, H = 680, 760
OUT_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "assets", "indian_locations", "telangana", "v3", "maps"
)
os.makedirs(OUT_DIR, exist_ok=True)
OUT_PATH = os.path.join(OUT_DIR, "hyderabad_city_map.png")


def hex_rgba(h: str, a: float = 1.0):
    h = h.lstrip("#")
    return (
        int(h[0:2], 16) / 255.0,
        int(h[2:4], 16) / 255.0,
        int(h[4:6], 16) / 255.0,
        a,
    )


def nx(val: float) -> float:
    return val * W


def ny(val: float) -> float:
    return val * H


def draw_poly(ctx, pts):
    ctx.move_to(nx(pts[0][0]), ny(pts[0][1]))
    for px, py in pts[1:]:
        ctx.line_to(nx(px), ny(py))
    ctx.close_path()


def draw_curve_path(ctx, pts):
    ctx.move_to(nx(pts[0][0]), ny(pts[0][1]))
    for px, py in pts[1:]:
        ctx.line_to(nx(px), ny(py))


def draw_district_label(ctx, text: str, x_n: float, y_n: float, size: float = 13.0, color="#6EA4CC"):
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(size)
    ext = ctx.text_extents(text)
    px = nx(x_n) - ext.width * 0.5
    py = ny(y_n) + ext.height * 0.5
    ctx.set_source_rgba(*hex_rgba("#050B14", 0.75))
    ctx.move_to(px + 1.0, py + 1.0)
    ctx.show_text(text)
    ctx.set_source_rgba(*hex_rgba(color, 0.88))
    ctx.move_to(px, py)
    ctx.show_text(text)


def main():
    surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, W, H)
    ctx = cairo.Context(surf)

    # 1. Dark Navy Cartographic Base
    pat = cairo.LinearGradient(0, 0, W, H)
    pat.add_color_stop_rgba(0.0, *hex_rgba("#091322", 1.0))
    pat.add_color_stop_rgba(0.5, *hex_rgba("#0D1B2E", 1.0))
    pat.add_color_stop_rgba(1.0, *hex_rgba("#08101C", 1.0))
    ctx.set_source(pat)
    ctx.rectangle(0, 0, W, H)
    ctx.fill()

    # 2. Subtle Map Grid Lines
    ctx.set_line_width(1.0)
    ctx.set_source_rgba(*hex_rgba("#1C3B5C", 0.30))
    for i in range(1, 10):
        gx = W * (i / 10.0)
        ctx.move_to(gx, 0)
        ctx.line_to(gx, H)
        ctx.stroke()
    for j in range(1, 11):
        gy = H * (j / 11.0)
        ctx.move_to(0, gy)
        ctx.line_to(W, gy)
        ctx.stroke()

    # 3. Stylized Hyderabad Metropolitan Urban Area Silhouette
    metro_poly = [
        (0.28, 0.14), (0.50, 0.10), (0.76, 0.16), (0.88, 0.36),
        (0.90, 0.62), (0.84, 0.86), (0.64, 0.92), (0.36, 0.88),
        (0.18, 0.72), (0.10, 0.52), (0.14, 0.30),
    ]
    ctx.set_source_rgba(*hex_rgba("#132842", 0.78))
    draw_poly(ctx, metro_poly)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#2B638E", 0.55))
    ctx.set_line_width(2.0)
    draw_poly(ctx, metro_poly)
    ctx.stroke()

    # Urban Arterial Ring (inner metro road feel)
    ctx.set_source_rgba(*hex_rgba("#22496B", 0.45))
    ctx.set_line_width(1.6)
    ctx.set_dash([8, 6])
    ctx.save()
    ctx.translate(nx(0.50), ny(0.53))
    ctx.scale(nx(0.36), ny(0.34))
    ctx.arc(0, 0, 1.0, 0, math.tau)
    ctx.restore()
    ctx.stroke()
    ctx.set_dash([])

    # 4. Golconda & Banjara/Jubilee Western Granite Ridge Contours
    for rad_s, alpha in [(1.0, 0.28), (0.68, 0.36), (0.40, 0.42)]:
        ctx.save()
        ctx.translate(nx(0.21), ny(0.45))
        ctx.scale(rad_s, rad_s)
        ctx.set_source_rgba(*hex_rgba("#5A4A3A", alpha))
        ctx.begin_ellipse if False else None
        ctx.save()
        ctx.scale(nx(0.12), ny(0.14))
        ctx.arc(0, 0, 1.0, 0, math.tau)
        ctx.restore()
        ctx.fill()
        ctx.restore()

    # Subtle rocky ridge outlines around Golconda Fort (West)
    ctx.set_source_rgba(*hex_rgba("#A38462", 0.38))
    ctx.set_line_width(1.4)
    ctx.save()
    ctx.translate(nx(0.18), ny(0.44))
    ctx.scale(nx(0.085), ny(0.095))
    ctx.arc(0, 0, 1.0, 0, math.tau)
    ctx.restore()
    ctx.stroke()

    # Naubat Pahad Hillock south of Hussain Sagar (Birla Mandir rocky spur)
    ctx.set_source_rgba(*hex_rgba("#4E4B48", 0.52))
    ctx.save()
    ctx.translate(nx(0.45), ny(0.48))
    ctx.scale(nx(0.055), ny(0.042))
    ctx.arc(0, 0, 1.0, 0, math.tau)
    ctx.restore()
    ctx.fill()

    # 5. Secondary Road Arteries (subtle city streets grid in Old City & Central Hyderabad)
    ctx.set_line_width(1.2)
    ctx.set_source_rgba(*hex_rgba("#2B5578", 0.36))
    for rx0, ry0, rx1, ry1 in [
        (0.58, 0.70, 0.82, 0.72),
        (0.62, 0.84, 0.80, 0.82),
        (0.48, 0.54, 0.78, 0.52),
        (0.32, 0.24, 0.72, 0.24),
        (0.34, 0.62, 0.54, 0.56),
        (0.72, 0.38, 0.74, 0.85),
    ]:
        ctx.move_to(nx(rx0), ny(ry0))
        ctx.line_to(nx(rx1), ny(ry1))
        ctx.stroke()

    # 6. Musi River (winding West-to-East through southern Hyderabad, north of Charminar & Salar Jung/Old City split)
    musi_pts = [
        (0.06, 0.60), (0.18, 0.65), (0.31, 0.67), (0.44, 0.69),
        (0.57, 0.70), (0.71, 0.69), (0.83, 0.66), (0.94, 0.65),
    ]
    ctx.set_line_cap(cairo.LINE_CAP_ROUND)
    ctx.set_line_join(cairo.LINE_JOIN_ROUND)
    ctx.set_source_rgba(*hex_rgba("#1A4F7D", 0.35))
    ctx.set_line_width(22.0)
    draw_curve_path(ctx, musi_pts)
    ctx.stroke()
    ctx.set_source_rgba(*hex_rgba("#2675B5", 0.88))
    ctx.set_line_width(11.0)
    draw_curve_path(ctx, musi_pts)
    ctx.stroke()
    ctx.set_source_rgba(*hex_rgba("#52ACE8", 0.45))
    ctx.set_line_width(2.5)
    draw_curve_path(ctx, musi_pts)
    ctx.stroke()

    # 7. Hussain Sagar Lake (signature heart/pearl lake between twin cities Hyderabad & Secunderabad)
    lake_pts = [
        (0.49, 0.23), (0.57, 0.21), (0.61, 0.27), (0.60, 0.35),
        (0.57, 0.41), (0.51, 0.42), (0.45, 0.38), (0.43, 0.31),
        (0.45, 0.24),
    ]
    # Soft water glow halo
    ctx.set_source_rgba(*hex_rgba("#2988CC", 0.24))
    ctx.set_line_width(12.0)
    draw_poly(ctx, lake_pts)
    ctx.stroke()

    # Lake water fill
    l_pat = cairo.RadialGradient(nx(0.52), ny(0.32), 10, nx(0.52), ny(0.32), 95)
    l_pat.add_color_stop_rgba(0.0, *hex_rgba("#3CA4E6", 0.95))
    l_pat.add_color_stop_rgba(1.0, *hex_rgba("#1C5B94", 0.96))
    ctx.set_source(l_pat)
    draw_poly(ctx, lake_pts)
    ctx.fill()

    # Necklace Road / Tank Bund shore border
    ctx.set_source_rgba(*hex_rgba("#7BD2FF", 0.72))
    ctx.set_line_width(2.2)
    draw_poly(ctx, lake_pts)
    ctx.stroke()

    # Tank Bund causeway strip on eastern rim + Gibraltar Rock islet inside Hussain Sagar
    ctx.set_source_rgba(*hex_rgba("#CBD5E1", 0.85))
    ctx.set_line_width(3.0)
    ctx.move_to(nx(0.59), ny(0.24))
    ctx.line_to(nx(0.58), ny(0.39))
    ctx.stroke()

    ctx.set_source_rgba(*hex_rgba("#EAD9BD", 0.95))
    ctx.arc(nx(0.52), ny(0.33), 5.5, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#1C5B94", 0.95))
    ctx.set_line_width(1.5)
    ctx.arc(nx(0.52), ny(0.33), 5.5, 0, math.tau)
    ctx.stroke()

    # 8. Stylized Monument Silhouettes on Map (subtle architectural watermarks)
    # Charminar small icon hint near Old City
    cx, cy = nx(0.75), ny(0.80)
    ctx.set_source_rgba(*hex_rgba("#D8B878", 0.26))
    ctx.rectangle(cx - 12, cy - 10, 24, 16)
    ctx.rectangle(cx - 12, cy - 22, 4, 12)
    ctx.rectangle(cx + 8, cy - 22, 4, 12)
    ctx.fill()

    # Golconda Fort battlement hint near West Citadel
    gx, gy = nx(0.16), ny(0.41)
    ctx.set_source_rgba(*hex_rgba("#D8B878", 0.24))
    ctx.rectangle(gx - 18, gy - 8, 36, 14)
    for b in range(-18, 18, 8):
        ctx.rectangle(gx + b, gy - 13, 5, 5)
    ctx.fill()

    # 9. Clean Cartographic District & Landmark Context Labels
    draw_district_label(ctx, "HUSSAIN SAGAR LAKE", 0.52, 0.17, 12.5, "#7CD4FF")
    draw_district_label(ctx, "TANK BUND", 0.72, 0.30, 10.5, "#94B8D4")
    draw_district_label(ctx, "SECUNDERABAD", 0.68, 0.12, 11.0, "#6389AB")
    draw_district_label(ctx, "HERITAGE CORE", 0.74, 0.51, 10.5, "#83A8C7")
    draw_district_label(ctx, "MUSI RIVER", 0.24, 0.62, 11.0, "#59B3E8")
    draw_district_label(ctx, "OLD CITY", 0.76, 0.87, 12.0, "#E5C17B")
    draw_district_label(ctx, "IBRAHIM BAGH", 0.30, 0.57, 10.5, "#9DB8CE")
    draw_district_label(ctx, "GOLCONDA HILLS", 0.18, 0.33, 11.5, "#E0B680")

    # 10. Compass Rose & Map Header Stamp
    # Compass top-left
    rx, ry = 46.0, 52.0
    ctx.set_source_rgba(*hex_rgba("#162F4A", 0.85))
    ctx.arc(rx, ry, 22, 0, math.tau)
    ctx.fill()
    ctx.set_source_rgba(*hex_rgba("#38BDF8", 0.70))
    ctx.set_line_width(1.6)
    ctx.arc(rx, ry, 22, 0, math.tau)
    ctx.stroke()
    # North arrow
    ctx.set_source_rgba(*hex_rgba("#FACC15", 0.95))
    ctx.move_to(rx, ry - 15)
    ctx.line_to(rx - 5, ry + 3)
    ctx.line_to(rx, ry)
    ctx.line_to(rx + 5, ry + 3)
    ctx.close_path()
    ctx.fill()
    draw_district_label(ctx, "N", rx / W, (ry - 26) / H, 11.0, "#FACC15")

    # Cartographic corner badge bottom-left
    draw_district_label(ctx, "HYDERABAD URBAN HERITAGE MAP", 0.29, 0.96, 10.5, "#5A89B0")

    surf.write_to_png(OUT_PATH)
    print(f"Generated: {OUT_PATH} ({W}x{H})")


if __name__ == "__main__":
    main()
