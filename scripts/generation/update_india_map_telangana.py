#!/usr/bin/env python3
"""
update_india_map_telangana.py
Updates assets/indian_locations/india_map_states.png (720x800) with the complete,
geographically accurate Telangana state boundary extracted from
assets/indian_locations/telangana_state_map.svg (Telangana_in_India.svg),
splitting undivided Andhra Pradesh along the official interstate border while
leaving Rajasthan, Gujarat, Goa, Kerala, Tamil Nadu, and all other map states
at their exact existing coordinates and artwork.
"""

import os
import re
import math
import cairo
import xml.etree.ElementTree as ET

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "../.."))
SRC_MAP = os.path.join(ROOT, "assets/indian_locations/india_map_states.png")
TG_SVG = os.path.join(ROOT, "assets/indian_locations/telangana_state_map.svg")


def parse_svg_path(d: str):
    tokens = re.findall(r"[A-Za-z]|[-+]?\d*\.?\d+(?:[eE][-+]?\d+)?", d)
    cx = cy = sx = sy = 0.0
    last_cx2 = last_cy2 = None
    subpaths = []
    cur = []
    cmd = ""
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if t.isalpha():
            cmd = t
            i += 1
            if cmd in ("Z", "z"):
                if cur:
                    subpaths.append(cur)
                    cur = []
                cx, cy = sx, sy
                last_cx2 = last_cy2 = None
            continue
        if cmd == "M":
            if cur:
                subpaths.append(cur)
                cur = []
            cx, cy = float(tokens[i]), float(tokens[i + 1])
            sx, sy = cx, cy
            i += 2
            cmd = "L"
            last_cx2 = last_cy2 = None
            cur.append(("M", (cx, cy)))
        elif cmd == "m":
            if cur:
                subpaths.append(cur)
                cur = []
            cx += float(tokens[i])
            cy += float(tokens[i + 1])
            sx, sy = cx, cy
            i += 2
            cmd = "l"
            last_cx2 = last_cy2 = None
            cur.append(("M", (cx, cy)))
        elif cmd == "L":
            cx, cy = float(tokens[i]), float(tokens[i + 1])
            i += 2
            last_cx2 = last_cy2 = None
            cur.append(("L", (cx, cy)))
        elif cmd == "l":
            cx += float(tokens[i])
            cy += float(tokens[i + 1])
            i += 2
            last_cx2 = last_cy2 = None
            cur.append(("L", (cx, cy)))
        elif cmd == "H":
            cx = float(tokens[i])
            i += 1
            last_cx2 = last_cy2 = None
            cur.append(("L", (cx, cy)))
        elif cmd == "h":
            cx += float(tokens[i])
            i += 1
            last_cx2 = last_cy2 = None
            cur.append(("L", (cx, cy)))
        elif cmd == "V":
            cy = float(tokens[i])
            i += 1
            last_cx2 = last_cy2 = None
            cur.append(("L", (cx, cy)))
        elif cmd == "v":
            cy += float(tokens[i])
            i += 1
            last_cx2 = last_cy2 = None
            cur.append(("L", (cx, cy)))
        elif cmd == "C":
            x1, y1, x2, y2, x3, y3 = map(float, tokens[i : i + 6])
            i += 6
            last_cx2, last_cy2 = x2, y2
            cx, cy = x3, y3
            cur.append(("C", (x1, y1, x2, y2, x3, y3)))
        elif cmd == "c":
            x1, y1, x2, y2, x3, y3 = map(float, tokens[i : i + 6])
            i += 6
            ax2, ay2 = cx + x2, cy + y2
            last_cx2, last_cy2 = ax2, ay2
            cur.append(("C", (cx + x1, cy + y1, ax2, ay2, cx + x3, cy + y3)))
            cx += x3
            cy += y3
        elif cmd == "S":
            x2, y2, x3, y3 = map(float, tokens[i : i + 4])
            i += 4
            if last_cx2 is not None:
                x1, y1 = 2.0 * cx - last_cx2, 2.0 * cy - last_cy2
            else:
                x1, y1 = cx, cy
            last_cx2, last_cy2 = x2, y2
            cx, cy = x3, y3
            cur.append(("C", (x1, y1, x2, y2, x3, y3)))
        elif cmd == "s":
            x2, y2, x3, y3 = map(float, tokens[i : i + 4])
            i += 4
            if last_cx2 is not None:
                x1, y1 = 2.0 * cx - last_cx2, 2.0 * cy - last_cy2
            else:
                x1, y1 = cx, cy
            ax2, ay2 = cx + x2, cy + y2
            last_cx2, last_cy2 = ax2, ay2
            cur.append(("C", (x1, y1, ax2, ay2, cx + x3, cy + y3)))
            cx += x3
            cy += y3
        else:
            last_cx2 = last_cy2 = None
            i += 1
    if cur:
        subpaths.append(cur)
    return subpaths


def solve_affine(pairs):
    def solve3(M, v):
        aug = [M[r][:] + [v[r]] for r in range(3)]
        for c in range(3):
            piv = max(range(c, 3), key=lambda r: abs(aug[r][c]))
            aug[c], aug[piv] = aug[piv], aug[c]
            d = aug[c][c]
            for j in range(c, 4):
                aug[c][j] /= d
            for r in range(3):
                if r != c:
                    f = aug[r][c]
                    for j in range(c, 4):
                        aug[r][j] -= f * aug[c][j]
        return [aug[r][3] for r in range(3)]

    ata = [[0.0] * 3 for _ in range(3)]
    atbx = [0.0] * 3
    atby = [0.0] * 3
    for (sx, sy), (dx, dy) in pairs:
        row = [sx, sy, 1.0]
        for r in range(3):
            atbx[r] += row[r] * dx
            atby[r] += row[r] * dy
            for c in range(3):
                ata[r][c] += row[r] * row[c]
    return solve3(ata, atbx), solve3(ata, atby)


def build_combined_mask(w, h, data, stride):
    # Identify interior + text/grid pixels of the undivided yellow AP/TG region on india_map_states.png
    # Yellow AP fill in source PNG is approx RGB (245, 240, 169) -> R>215, G>210, B<205
    raw = bytearray(w * h)
    for y in range(455, 640):
        for x in range(218, 420):
            o = y * stride + x * 4
            b, g, r, _ = data[o], data[o + 1], data[o + 2], data[o + 3]
            if r > 215 and g > 210 and b < 205:
                raw[y * w + x] = 1

    # Dilate by 4px to cover dark letters ("Andhra Pradesh", "Hyderabad", "o") & subtle graticule inside AP/TG
    # while checking that target pixel is NOT an adjacent state's distinct color (blue sea/Mah, green Kar/Ori, pink Chh/TN)
    # Clean any stray dark text/symbol pixels inside the old label boxes ("Andhra Pradesh" & "Hyderabad")
    # specifically within interior non-neighbor region (AP coastline ends east of x=316 at y=550, Karnataka border is left of x=240)
    clean = bytearray(raw)
    for y in range(458, 636):
        for x in range(220, 415):
            if raw[y * w + x]:
                clean[y * w + x] = 1
                continue
            o = y * stride + x * 4
            b, g, r, _ = data[o], data[o + 1], data[o + 2], data[o + 3]
            is_blue = (b > r + 15)
            is_green = (g > r + 8 and b < g)
            is_pink = (r > g + 10 and b > g + 5)
            if is_blue or is_green or is_pink:
                continue
            hits = 0
            for dy in range(-7, 8):
                for dx in range(-7, 8):
                    if 0 <= x + dx < w and 0 <= y + dy < h and raw[(y + dy) * w + (x + dx)]:
                        hits += 1
            if hits >= 36:
                clean[y * w + x] = 1
    # Explicit erase inside old interior "Andhra Pradesh" text bounding region (245..324, 524..575) safely inside border
    for y in range(524, 575):
        for x in range(245, 325):
            o = y * stride + x * 4
            b, g, r, _ = data[o], data[o + 1], data[o + 2], data[o + 3]
            if not (b > r + 12) and not (g > r + 8 and b < g):
                # Do not erase coastal sea border (only clean dark text when not right next to ocean blue)
                near_sea = False
                for dy in range(-1, 2):
                    for dx in range(-1, 2):
                        no = (y + dy) * stride + (x + dx) * 4
                        nb, ng, nr = data[no], data[no + 1], data[no + 2]
                        if nb > nr + 25:
                            near_sea = True
                            break
                if not near_sea:
                    clean[y * w + x] = 1
    # Clean remaining dark "Pradesh" letter fragment ("h") near Krishna coast (303..322, 555..570)
    # Sea blue here has b >= 180, whereas black/grey letter strokes have b < 175
    for y in range(554, 571):
        for x in range(303, 323):
            o = y * stride + x * 4
            b, g, r, _ = data[o], data[o + 1], data[o + 2], data[o + 3]
            if r < 160 and g < 160 and b < 175:
                clean[y * w + x] = 1
    return clean


def generate_updated_map(out_path: str):
    tree = ET.parse(TG_SVG)
    tg_d = ap_d = None
    for elem in tree.getroot().iter():
        eid = elem.attrib.get("id", "")
        if eid == "Telangana.10m-admin-1-states-provinces-shp.3541":
            tg_d = elem.attrib["d"]
        elif eid == "Andra_Pradesh.10m-admin-1-states-provinces-shp.3541":
            ap_d = elem.attrib["d"]

    if not tg_d or not ap_d:
        raise RuntimeError("Missing Telangana or Andhra Pradesh path in telangana_state_map.svg")

    # Tight regional correspondence pairs (SVG 1500x1614.84 -> PNG 720x800)
    # Anchored onto the exact Adilabad / Maharashtra / Karnataka / Chhattisgarh / AP borders in india_map_states.png
    pairs = [
        ((531.1, 874.9), (266.0, 461.8)),    # Adilabad North tip
        ((689.7, 975.3), (336.5, 518.5)),    # Bhadradri East tip (Chhattisgarh/AP/TG)
        ((480.8, 1046.0), (239.0, 540.5)),   # Narayanpet West border (Karnataka/TG)
        ((520.3, 1076.7), (255.0, 558.0)),   # Jogulamba/Alampur South tip (TG/AP/Karnataka)
        ((833.4, 914.7), (412.0, 485.0)),    # Ichchapuram NE AP tip
        ((533.8, 1183.8), (256.0, 633.0)),   # Chittoor S AP tip
    ]
    cx, cy = solve_affine(pairs)

    def xform(x, y):
        return (cx[0] * x + cx[1] * y + cx[2], cy[0] * x + cy[1] * y + cy[2])

    src = cairo.ImageSurface.create_from_png(SRC_MAP)
    w, h = src.get_width(), src.get_height()
    dst = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(dst)
    ctx.set_source_surface(src, 0, 0)
    ctx.paint()
    dst.flush()

    stride = dst.get_stride()
    raw_bytes = bytearray(dst.get_data())
    ap_mask = build_combined_mask(w, h, raw_bytes, stride)

    # Create Cairo surface with clean pale AP yellow (#F5F0AA) replacing old undivided labels inside AP/TG region
    for y in range(458, 636):
        for x in range(220, 415):
            if ap_mask[y * w + x]:
                o = y * stride + x * 4
                # Keep original dark outer border stroke (~1px around edges) untouched; replace interior & old labels
                b, g, r, a = raw_bytes[o], raw_bytes[o + 1], raw_bytes[o + 2], raw_bytes[o + 3]
                # Faint blue gridlines on Wikimedia map are slightly bluish-grey; preserve subtle grid or uniformize
                raw_bytes[o] = 170     # B
                raw_bytes[o + 1] = 240 # G
                raw_bytes[o + 2] = 245 # R
                raw_bytes[o + 3] = 255 # A

    clean_surf = cairo.ImageSurface.create_for_data(raw_bytes, cairo.FORMAT_ARGB32, w, h, stride)
    ctx = cairo.Context(clean_surf)

    # Restore faint Wikimedia graticule lines inside the cleared area for visual consistency
    ctx.save()
    ctx.set_source_rgba(0.65, 0.72, 0.78, 0.25)
    ctx.set_line_width(0.8)
    # Approximate faint meridian/parallel lines matching src
    ctx.move_to(296, 460); ctx.line_to(296, 635)
    ctx.move_to(220, 560); ctx.line_to(390, 560)
    ctx.stroke()
    ctx.restore()

    # Trace Telangana complete polygon clipped cleanly within India's interior borders
    tg_subpaths = parse_svg_path(tg_d)

    def trace_subpaths(c, sps):
        c.new_path()
        for sp in sps:
            for op, v in sp:
                if op == "M":
                    c.move_to(*xform(*v))
                elif op == "L":
                    c.line_to(*xform(*v))
                elif op == "C":
                    x1, y1 = xform(v[0], v[1])
                    x2, y2 = xform(v[2], v[3])
                    x3, y3 = xform(v[4], v[5])
                    c.curve_to(x1, y1, x2, y2, x3, y3)
            c.close_path()

    # Fill Telangana with clear rose-coral state highlight matching cartography palette
    # while painting ONLY over cleared AP_mask or interior region
    # Create an alpha mask from ap_mask so Telangana never spills outside onto Maharashtra/Karnataka/Chhattisgarh
    mask_bytes = bytearray(w * h * 4)
    for y in range(458, 636):
        for x in range(220, 415):
            if ap_mask[y * w + x]:
                o = (y * w + x) * 4
                mask_bytes[o + 3] = 255
    mask_surf = cairo.ImageSurface.create_for_data(mask_bytes, cairo.FORMAT_ARGB32, w, h, w * 4)

    # Render Telangana fill into a temp surface masked by ap_mask so neighboring states' borders stay crisp
    tg_layer = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    tctx = cairo.Context(tg_layer)
    trace_subpaths(tctx, tg_subpaths)
    tctx.set_source_rgba(0.95, 0.65, 0.67, 1.0)  # Clear warm rose/coral playable state highlight (#F2A6AB)
    tctx.fill()

    ctx.save()
    ctx.set_source_surface(tg_layer, 0, 0)
    ctx.mask_surface(mask_surf, 0, 0)
    ctx.restore()

    # Stroke crisp Telangana boundary masked inside AP/TG region so outer Maharashtra/Karnataka borders stay razor clean
    tg_stroke_layer = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    sctx = cairo.Context(tg_stroke_layer)
    trace_subpaths(sctx, tg_subpaths)
    sctx.set_source_rgba(0.28, 0.25, 0.25, 0.95)
    sctx.set_line_width(1.5)
    sctx.set_line_join(cairo.LINE_JOIN_ROUND)
    sctx.stroke()

    ctx.save()
    ctx.set_source_surface(tg_stroke_layer, 0, 0)
    ctx.mask_surface(mask_surf, 0, 0)
    ctx.restore()

    # Re-render the crisp Hyderabad symbol (circle-dot) inside Telangana (~(263.5, 519.5))
    hx, hy = 263.5, 519.5
    ctx.save()
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.arc(hx, hy, 3.6, 0, math.tau)
    ctx.fill_preserve()
    ctx.set_source_rgb(0.12, 0.12, 0.12)
    ctx.set_line_width(1.2)
    ctx.stroke()
    ctx.arc(hx, hy, 1.5, 0, math.tau)
    ctx.fill()
    ctx.restore()

    # Crisp label: Telangana (fit cleanly inside interior) & Hyderabad
    ctx.save()
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    ctx.set_font_size(11.5)
    ctx.set_source_rgb(0.14, 0.04, 0.05)
    ctx.move_to(249.5, 505.5)
    ctx.show_text("Telangana")

    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    ctx.set_font_size(9.5)
    ctx.set_source_rgb(0.12, 0.10, 0.10)
    ctx.move_to(hx + 5.5, hy + 3.2)
    ctx.show_text("Hyderabad")

    # Crisp label: Andhra Pradesh neatly in southern/coastal Andhra Pradesh
    ctx.select_font_face("Sans", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    ctx.set_font_size(11.5)
    ctx.set_source_rgb(0.10, 0.10, 0.10)
    ctx.move_to(255, 584)
    ctx.show_text("Andhra")
    ctx.move_to(252, 597)
    ctx.show_text("Pradesh")
    ctx.restore()

    clean_surf.write_to_png(out_path)
    print(f"Wrote updated India map to: {out_path} ({w}x{h})")


if __name__ == "__main__":
    import sys
    target = sys.argv[1] if len(sys.argv) > 1 else SRC_MAP
    generate_updated_map(target)
