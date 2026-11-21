#!/usr/bin/env python3
"""
v2_common.py
Author: Joel (Senior Godot 4.7 Developer, Technical Artist & Level Designer)
Common vector drawing primitives, shading utilities, and file handlers for
the Asset Collection V2 generation suite.
"""

import cairo
import math
import os
import random

BASE_V2_DIR = "assets/indian_locations/asset_collection_v2"

def ensure_dir(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)

def create_surface(w, h):
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, int(w), int(h))
    ctx = cairo.Context(surface)
    ctx.set_source_rgba(0, 0, 0, 0)
    ctx.paint()
    return surface, ctx

def save_surface(surf, rel_path):
    full_path = os.path.join(BASE_V2_DIR, rel_path)
    ensure_dir(full_path)
    surf.write_to_png(full_path)
    print(f"  ✓ V2 Asset Saved: {rel_path} ({surf.get_width()}x{surf.get_height()})")

# ==============================================================================
# VECTOR DRAWING PRIMITIVES
# ==============================================================================

def draw_ground_shadow(ctx, cx, ground_y, width, height=18, alpha=0.35):
    """Draws a soft ground contact shadow beneath monuments, buildings, and trees."""
    ctx.save()
    pat = cairo.RadialGradient(cx, ground_y, 5, cx, ground_y, width / 2)
    pat.add_color_stop_rgba(0.0, 0.0, 0.0, 0.0, alpha)
    pat.add_color_stop_rgba(0.7, 0.0, 0.0, 0.0, alpha * 0.5)
    pat.add_color_stop_rgba(1.0, 0.0, 0.0, 0.0, 0.0)
    ctx.set_source(pat)
    ctx.scale(1.0, height / (width / 2))
    ctx.arc(cx, ground_y * (width / 2) / height, width / 2, 0, 2 * math.pi)
    ctx.fill()
    ctx.restore()

def draw_stone_steps(ctx, x, y, width, height, steps_count, color_top, color_face):
    """Draws multi-tiered architectural stone plinth steps."""
    step_h = height / steps_count
    step_inset = width / (steps_count * 2.5)
    for i in range(steps_count):
        curr_w = width - (i * step_inset * 2)
        curr_x = x + (i * step_inset)
        curr_y = y - ((i + 1) * step_h)
        # Face (shadowed)
        ctx.set_source_rgb(*color_face)
        ctx.rectangle(curr_x, curr_y, curr_w, step_h)
        ctx.fill()
        # Top ledge (highlighted)
        ctx.set_source_rgb(*color_top)
        ctx.rectangle(curr_x, curr_y, curr_w, max(2, step_h * 0.3))
        ctx.fill()

def draw_pillared_veranda(ctx, x, y, w, h, pillars_count, pillar_w, pillar_col, capital_col):
    """Draws traditional Dravidian / Indo-Portuguese / Haveli pillared corridor."""
    spacing = (w - (pillars_count * pillar_w)) / max(1, pillars_count - 1)
    for i in range(pillars_count):
        px = x + i * (pillar_w + spacing)
        # Base
        ctx.set_source_rgb(*capital_col)
        ctx.rectangle(px - 2, y + h - 8, pillar_w + 4, 8)
        ctx.fill()
        # Shaft
        ctx.set_source_rgb(*pillar_col)
        ctx.rectangle(px, y + 8, pillar_w, h - 16)
        ctx.fill()
        # Capital
        ctx.set_source_rgb(*capital_col)
        ctx.rectangle(px - 3, y, pillar_w + 6, 8)
        ctx.fill()

def draw_sloping_roof(ctx, x, y, w, h, overhang, tile_color, shadow_color, ridge_color=None):
    """Draws terracotta or clay tiled sloping roof with eave shadow and ridge cap."""
    # Main roof triangle / trapezoid
    ctx.set_source_rgb(*tile_color)
    ctx.move_to(x - overhang, y + h)
    ctx.line_to(x + w + overhang, y + h)
    ctx.line_to(x + w * 0.8, y)
    ctx.line_to(x + w * 0.2, y)
    ctx.close_path()
    ctx.fill()

    # Eave shadow strip underneath
    ctx.set_source_rgb(*shadow_color)
    ctx.rectangle(x - overhang, y + h - 6, w + (overhang * 2), 6)
    ctx.fill()

    # Ridge cap
    if ridge_color:
        ctx.set_source_rgb(*ridge_color)
        ctx.rectangle(x + w * 0.18, y - 4, w * 0.64, 5)
        ctx.fill()

def draw_chhatri_dome(ctx, cx, cy, radius, height, dome_col, finial_col):
    """Draws classical Rajasthani / Mughal chhatri dome with finial (kalasam/amla)."""
    ctx.set_source_rgb(*dome_col)
    ctx.save()
    ctx.scale(1.0, height / radius)
    ctx.arc(cx, cy * radius / height, radius, math.pi, 2 * math.pi)
    ctx.fill()
    ctx.restore()

    # Kalasam / Lotus Finial
    ctx.set_source_rgb(*finial_col)
    ctx.rectangle(cx - 2, cy - height - 12, 4, 12)
    ctx.fill()
    ctx.arc(cx, cy - height - 12, 4, 0, 2 * math.pi)
    ctx.fill()
    ctx.arc(cx, cy - height - 18, 2, 0, 2 * math.pi)
    ctx.fill()

def draw_archway(ctx, x, y, w, h, arch_col, void_col=None):
    """Draws Indian pointed / horseshoe / multifoil arch opening."""
    if void_col:
        ctx.set_source_rgb(*void_col)
        ctx.rectangle(x, y + w / 2, w, h - w / 2)
        ctx.fill()
        ctx.arc(x + w / 2, y + w / 2, w / 2, math.pi, 2 * math.pi)
        ctx.fill()

    # Arch molding border
    ctx.set_source_rgb(*arch_col)
    ctx.set_line_width(4)
    ctx.move_to(x, y + h)
    ctx.line_to(x, y + w / 2)
    ctx.arc(x + w / 2, y + w / 2, w / 2, math.pi, 2 * math.pi)
    ctx.line_to(x + w, y + h)
    ctx.stroke()
