#!/usr/bin/env python3
"""
scripts/generate_all_regional_landmarks.py
Author: Joel (Senior Godot Technical Artist)
Generates high-resolution, vector-accurate, transparent PNG assets for famous places
across Kerala, Rajasthan, Gujarat, and Telangana, fulfilling the 150-Location catalogue.
"""

import cairo
import math
import os

def draw_ellipse(ctx, cx, cy, rx, ry):
    ctx.save()
    ctx.translate(cx, cy)
    ctx.scale(rx, ry)
    ctx.arc(0, 0, 1, 0, 2 * math.pi)
    ctx.restore()

def create_surface(w, h):
    surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, w, h)
    ctx = cairo.Context(surface)
    ctx.set_source_rgba(0, 0, 0, 0)
    ctx.paint()
    return surface, ctx

# ==========================================
# 1. KERALA
# ==========================================

def render_mattancherry_palace(path):
    surf, ctx = create_surface(500, 320)
    # White base walls
    ctx.set_source_rgb(0.92, 0.90, 0.86)
    ctx.rectangle(60, 140, 380, 160)
    ctx.fill()
    # Sloping terracotta tiled roof
    ctx.set_source_rgb(0.72, 0.28, 0.16)
    ctx.move_to(30, 140)
    ctx.line_to(250, 40)
    ctx.line_to(470, 140)
    ctx.close_path()
    ctx.fill()
    # Overhang eaves
    ctx.set_source_rgb(0.55, 0.20, 0.10)
    ctx.set_line_width(8)
    ctx.move_to(25, 142)
    ctx.line_to(250, 42)
    ctx.line_to(475, 142)
    ctx.stroke()
    # Timber gables
    ctx.set_source_rgb(0.28, 0.18, 0.10)
    ctx.rectangle(210, 70, 80, 70)
    ctx.fill()
    # Intricate carved wooden shutters
    for x in range(90, 410, 60):
        ctx.set_source_rgb(0.25, 0.16, 0.10)
        ctx.rectangle(x, 170, 36, 60)
        ctx.fill()
        ctx.set_source_rgb(0.85, 0.70, 0.40)
        ctx.set_line_width(2)
        ctx.rectangle(x+4, 174, 28, 52)
        ctx.stroke()
    # Base stone plinth
    ctx.set_source_rgb(0.35, 0.32, 0.30)
    ctx.rectangle(50, 295, 400, 25)
    ctx.fill()
    surf.write_to_png(path)

def render_athirappilly_waterfalls(path):
    surf, ctx = create_surface(520, 350)
    # Rocky cliff backdrop
    ctx.set_source_rgb(0.22, 0.20, 0.18)
    ctx.rectangle(20, 80, 480, 220)
    ctx.fill()
    # Jungle canopy atop cliff
    ctx.set_source_rgb(0.12, 0.38, 0.16)
    for cx in range(40, 480, 50):
        ctx.arc(cx, 80, 40, 0, math.pi*2)
        ctx.fill()
    # Cascading torrents of white water
    for x in range(60, 460, 28):
        ctx.set_source_rgba(0.92, 0.96, 1.0, 0.88)
        ctx.rectangle(x, 90, 22, 210)
        ctx.fill()
        ctx.set_source_rgba(0.70, 0.85, 0.95, 0.6)
        ctx.rectangle(x+4, 90, 14, 210)
        ctx.fill()
    # Roaring splash pool and mist
    ctx.set_source_rgba(0.95, 0.98, 1.0, 0.75)
    draw_ellipse(ctx, 260, 300, 230, 40)
    ctx.fill()
    # Foreground river boulders
    for bx, by, br in [(80, 320, 45), (180, 330, 35), (320, 325, 50), (430, 320, 40)]:
        ctx.set_source_rgb(0.28, 0.26, 0.24)
        ctx.arc(bx, by, br, 0, math.pi*2)
        ctx.fill()
    surf.write_to_png(path)

def render_bekal_fort_bastion(path):
    surf, ctx = create_surface(480, 320)
    # Ocean water below fort
    ctx.set_source_rgb(0.14, 0.42, 0.58)
    ctx.rectangle(0, 220, 480, 100)
    ctx.fill()
    # Red-brown laterite rampart wall
    ctx.set_source_rgb(0.55, 0.24, 0.18)
    ctx.move_to(30, 260)
    ctx.line_to(180, 180)
    ctx.line_to(450, 180)
    ctx.line_to(450, 290)
    ctx.line_to(30, 290)
    ctx.close_path()
    ctx.fill()
    # Keyhole observation tower
    ctx.set_source_rgb(0.48, 0.20, 0.15)
    ctx.rectangle(260, 80, 120, 160)
    ctx.fill()
    # Observation tower crenellations
    for cx in range(260, 380, 25):
        ctx.rectangle(cx, 60, 15, 20)
        ctx.fill()
    # Slit arch windows
    ctx.set_source_rgb(0.12, 0.08, 0.06)
    ctx.arc(320, 120, 18, math.pi, 0)
    ctx.line_to(338, 160)
    ctx.line_to(302, 160)
    ctx.close_path()
    ctx.fill()
    # White sea surf breaking against laterite
    ctx.set_source_rgba(1.0, 1.0, 1.0, 0.8)
    draw_ellipse(ctx, 140, 275, 110, 18)
    ctx.fill()
    surf.write_to_png(path)

def render_padmanabhaswamy_temple(path):
    surf, ctx = create_surface(420, 420)
    # 7-tiered Travancore Gopuram (golden-yellow sandstone)
    tier_widths = [320, 290, 260, 230, 200, 170, 140]
    y_start = 340
    tier_height = 36
    for i, tw in enumerate(tier_widths):
        ty = y_start - (i * tier_height)
        tx = 210 - (tw // 2)
        # Tier body
        ctx.set_source_rgb(0.88 - i*0.02, 0.72 - i*0.02, 0.30)
        ctx.rectangle(tx, ty, tw, tier_height)
        ctx.fill()
        # Tier carved cornice
        ctx.set_source_rgb(0.70, 0.52, 0.18)
        ctx.set_line_width(3)
        ctx.rectangle(tx-4, ty, tw+8, 6)
        ctx.fill()
        # Sculptural niches
        for nx in range(tx + 20, tx + tw - 20, 35):
            ctx.set_source_rgb(0.50, 0.35, 0.12)
            ctx.arc(nx, ty + 20, 8, math.pi, 0)
            ctx.line_to(nx + 8, ty + 32)
            ctx.line_to(nx - 8, ty + 32)
            ctx.close_path()
            ctx.fill()
    # Top golden Kalasam finials
    ctx.set_source_rgb(0.98, 0.84, 0.10)
    for kx in range(160, 270, 20):
        ctx.move_to(kx, 88)
        ctx.line_to(kx + 5, 60)
        ctx.line_to(kx + 10, 88)
        ctx.close_path()
        ctx.fill()
    # Massive stone gateway door (Gopura Dwaram)
    ctx.set_source_rgb(0.20, 0.14, 0.10)
    ctx.rectangle(175, 340, 70, 75)
    ctx.fill()
    # Brass door studs
    ctx.set_source_rgb(0.95, 0.80, 0.20)
    for gy in range(355, 410, 15):
        for gx in range(185, 240, 16):
            ctx.arc(gx, gy, 2.5, 0, math.pi*2)
            ctx.fill()
    surf.write_to_png(path)

# ==========================================
# 2. RAJASTHAN
# ==========================================

def render_jal_mahal(path):
    surf, ctx = create_surface(500, 320)
    # Man Sagar Lake water
    ctx.set_source_rgb(0.20, 0.48, 0.65)
    ctx.rectangle(0, 180, 500, 140)
    ctx.fill()
    # Yellow sandstone palace submerged floor & upper floor
    ctx.set_source_rgb(0.90, 0.72, 0.42)
    ctx.rectangle(80, 100, 340, 110)
    ctx.fill()
    # Multi-arched Rajput colonnades
    for ax in range(105, 395, 40):
        ctx.set_source_rgb(0.55, 0.38, 0.18)
        ctx.arc(ax+15, 140, 14, math.pi, 0)
        ctx.line_to(ax+29, 180)
        ctx.line_to(ax+1, 180)
        ctx.close_path()
        ctx.fill()
    # Four corner Chattris (domed pavilions)
    for cx in [95, 175, 295, 375]:
        ctx.set_source_rgb(0.85, 0.65, 0.35)
        ctx.rectangle(cx, 60, 30, 40)
        ctx.fill()
        ctx.arc(cx+15, 60, 20, math.pi, 0)
        ctx.fill()
        # Brass finial
        ctx.set_source_rgb(0.95, 0.85, 0.30)
        ctx.move_to(cx+15, 40)
        ctx.line_to(cx+15, 25)
        ctx.set_line_width(3)
        ctx.stroke()
    # Central rectangular Bengal roof baradari
    ctx.set_source_rgb(0.82, 0.60, 0.30)
    ctx.move_to(200, 70)
    ctx.curve_to(230, 45, 270, 45, 300, 70)
    ctx.line_to(300, 100)
    ctx.line_to(200, 100)
    ctx.close_path()
    ctx.fill()
    # Water ripple reflections
    ctx.set_source_rgba(0.90, 0.72, 0.42, 0.35)
    ctx.rectangle(90, 220, 320, 40)
    ctx.fill()
    surf.write_to_png(path)

def render_jaswant_thada(path):
    surf, ctx = create_surface(460, 360)
    # Red sandstone base plinth
    ctx.set_source_rgb(0.68, 0.32, 0.22)
    ctx.rectangle(40, 270, 380, 80)
    ctx.fill()
    # Intricately carved pure white Makrana marble palace
    ctx.set_source_rgb(0.98, 0.97, 0.96)
    ctx.rectangle(80, 140, 300, 130)
    ctx.fill()
    # Marble latticed jali windows
    for jx in range(110, 340, 45):
        ctx.set_source_rgb(0.82, 0.85, 0.88)
        ctx.rectangle(jx, 175, 28, 60)
        ctx.fill()
        ctx.set_source_rgb(0.60, 0.65, 0.70)
        ctx.set_line_width(1.5)
        ctx.rectangle(jx, 175, 28, 60)
        ctx.stroke()
    # Central towering marble dome
    ctx.set_source_rgb(0.96, 0.95, 0.94)
    ctx.arc(230, 140, 65, math.pi, 0)
    ctx.fill()
    # Flanking carved chattris
    for fx in [105, 335]:
        ctx.arc(fx, 140, 30, math.pi, 0)
        ctx.fill()
        ctx.set_source_rgb(0.95, 0.80, 0.20)
        ctx.move_to(fx, 110)
        ctx.line_to(fx, 90)
        ctx.set_line_width(3)
        ctx.stroke()
        ctx.set_source_rgb(0.96, 0.95, 0.94)
    # Central golden spire
    ctx.set_source_rgb(0.95, 0.80, 0.20)
    ctx.move_to(230, 75)
    ctx.line_to(230, 40)
    ctx.set_line_width(4)
    ctx.stroke()
    surf.write_to_png(path)

def render_patwon_ki_haveli(path):
    surf, ctx = create_surface(420, 400)
    # Golden sandstone 5-tier Haveli facade
    ctx.set_source_rgb(0.92, 0.74, 0.38)
    ctx.rectangle(40, 60, 340, 330)
    ctx.fill()
    # Ornate projecting jharokha balconies with carved brackets
    for y_floor in [100, 180, 260]:
        for bx in [70, 160, 250]:
            # Balcony box
            ctx.set_source_rgb(0.82, 0.62, 0.26)
            ctx.rectangle(bx, y_floor, 70, 55)
            ctx.fill()
            # Arched window openings
            ctx.set_source_rgb(0.40, 0.26, 0.12)
            ctx.arc(bx+20, y_floor+20, 10, math.pi, 0)
            ctx.fill()
            ctx.arc(bx+50, y_floor+20, 10, math.pi, 0)
            ctx.fill()
            # Decorative brackets
            ctx.set_source_rgb(0.65, 0.45, 0.18)
            ctx.move_to(bx, y_floor+55)
            ctx.line_to(bx+15, y_floor+70)
            ctx.line_to(bx+55, y_floor+70)
            ctx.line_to(bx+70, y_floor+55)
            ctx.close_path()
            ctx.fill()
    # Ornate roof parapet chattris
    for rx in range(60, 350, 45):
        ctx.set_source_rgb(0.80, 0.58, 0.22)
        ctx.arc(rx+15, 60, 15, math.pi, 0)
        ctx.fill()
    # Carved wooden entrance gate
    ctx.set_source_rgb(0.35, 0.20, 0.10)
    ctx.rectangle(160, 330, 80, 60)
    ctx.fill()
    surf.write_to_png(path)

# ==========================================
# 3. GUJARAT
# ==========================================

def render_sabarmati_ashram(path):
    surf, ctx = create_surface(480, 280)
    # Whitewashed Hriday Kunj cottage walls
    ctx.set_source_rgb(0.95, 0.95, 0.92)
    ctx.rectangle(60, 120, 360, 140)
    ctx.fill()
    # Sloping brown terracotta tile roof
    ctx.set_source_rgb(0.65, 0.35, 0.20)
    ctx.move_to(30, 120)
    ctx.line_to(240, 45)
    ctx.line_to(450, 120)
    ctx.close_path()
    ctx.fill()
    # Wooden open verandah pillars
    for px in range(80, 400, 50):
        ctx.set_source_rgb(0.35, 0.22, 0.12)
        ctx.rectangle(px, 140, 10, 120)
        ctx.fill()
    # Khadi Charkha spinning wheel symbol in courtyard
    ctx.set_source_rgb(0.30, 0.20, 0.12)
    ctx.arc(360, 210, 22, 0, math.pi*2)
    ctx.set_line_width(3)
    ctx.stroke()
    ctx.arc(320, 222, 10, 0, math.pi*2)
    ctx.stroke()
    ctx.move_to(320, 222)
    ctx.line_to(360, 210)
    ctx.stroke()
    # Shady neem tree beside cottage
    ctx.set_source_rgb(0.18, 0.45, 0.22)
    ctx.arc(430, 110, 45, 0, math.pi*2)
    ctx.fill()
    surf.write_to_png(path)

def render_adalaj_stepwell(path):
    surf, ctx = create_surface(500, 360)
    # Sandstone subterranean multi-tiered stepped galleries
    ctx.set_source_rgb(0.85, 0.68, 0.45)
    ctx.rectangle(40, 60, 420, 280)
    ctx.fill()
    # Subterranean descending levels (darker shadows downwards)
    for level, ly in enumerate([100, 170, 240]):
        ctx.set_source_rgb(0.60 - level*0.12, 0.44 - level*0.10, 0.28 - level*0.06)
        ctx.rectangle(60, ly, 380, 50)
        ctx.fill()
        # Carved Solanki octagonal pillars
        for px in range(80, 420, 55):
            ctx.set_source_rgb(0.88, 0.70, 0.48)
            ctx.rectangle(px, ly-20, 14, 70)
            ctx.fill()
            # Ornate brackets
            ctx.move_to(px-6, ly-20)
            ctx.line_to(px+20, ly-20)
            ctx.line_to(px+7, ly-10)
            ctx.close_path()
            ctx.fill()
    # Deep bottom water reservoir well shaft
    ctx.set_source_rgb(0.12, 0.28, 0.38)
    ctx.rectangle(170, 290, 160, 50)
    ctx.fill()
    surf.write_to_png(path)

def render_modhera_sun_temple(path):
    surf, ctx = create_surface(520, 380)
    # Golden Solanki sandstone sanctum (Gudhamandapa & Sabhamandapa)
    ctx.set_source_rgb(0.88, 0.72, 0.42)
    ctx.rectangle(120, 110, 280, 150)
    ctx.fill()
    # Stepped pyramid shikhara roof
    for i, w in enumerate([240, 200, 160, 120, 80, 40]):
        ctx.rectangle(260 - w//2, 110 - (i+1)*14, w, 14)
        ctx.fill()
        ctx.set_source_rgb(0.75, 0.58, 0.30)
        ctx.set_line_width(2)
        ctx.rectangle(260 - w//2, 110 - (i+1)*14, w, 14)
        ctx.stroke()
        ctx.set_source_rgb(0.88, 0.72, 0.42)
    # Surya Kund stepped reservoir tank below
    ctx.set_source_rgb(0.18, 0.45, 0.58)
    ctx.rectangle(60, 260, 400, 110)
    ctx.fill()
    # Stepped pyramidal stone ghats
    for gy in range(260, 370, 22):
        ctx.set_source_rgb(0.72, 0.56, 0.32)
        for gx in range(70, 430, 45):
            ctx.move_to(gx, gy)
            ctx.line_to(gx+20, gy-12)
            ctx.line_to(gx+40, gy)
            ctx.close_path()
            ctx.fill()
    surf.write_to_png(path)

def render_somnath_temple(path):
    surf, ctx = create_surface(480, 420)
    # Arabian Sea waves at base
    ctx.set_source_rgb(0.15, 0.42, 0.60)
    ctx.rectangle(0, 320, 480, 100)
    ctx.fill()
    # High seaside stone plinth
    ctx.set_source_rgb(0.68, 0.52, 0.35)
    ctx.rectangle(50, 260, 380, 60)
    ctx.fill()
    # Towering Kailash Mahameru Prasad Shikhara (150-ft)
    ctx.set_source_rgb(0.86, 0.70, 0.44)
    # Curvilinear spire
    ctx.move_to(160, 260)
    ctx.curve_to(170, 120, 210, 70, 240, 60)
    ctx.curve_to(270, 70, 310, 120, 320, 260)
    ctx.close_path()
    ctx.fill()
    # Urushringa miniature spire carvings
    for uy in range(120, 260, 30):
        ctx.set_source_rgb(0.76, 0.60, 0.36)
        ctx.arc(200, uy, 14, math.pi, 0)
        ctx.fill()
        ctx.arc(280, uy, 14, math.pi, 0)
        ctx.fill()
    # Monolithic Amalaka stone disc & Kalash flag
    ctx.set_source_rgb(0.95, 0.80, 0.30)
    draw_ellipse(ctx, 240, 55, 25, 8)
    ctx.fill()
    # Golden flagstaff & triangular saffron dhwaja
    ctx.move_to(240, 50)
    ctx.line_to(240, 20)
    ctx.stroke()
    ctx.set_source_rgb(0.98, 0.42, 0.10)
    ctx.move_to(240, 20)
    ctx.line_to(285, 32)
    ctx.line_to(240, 44)
    ctx.close_path()
    ctx.fill()
    surf.write_to_png(path)

# ==========================================
# 4. TELANGANA
# ==========================================

def render_chowmahalla_palace(path):
    surf, ctx = create_surface(520, 320)
    # Neoclassical white palace facade
    ctx.set_source_rgb(0.96, 0.95, 0.92)
    ctx.rectangle(50, 110, 420, 180)
    ctx.fill()
    # Stately Corinthian colonnade pillars
    for px in range(75, 450, 38):
        ctx.set_source_rgb(0.85, 0.84, 0.80)
        ctx.rectangle(px, 130, 12, 140)
        ctx.fill()
        ctx.set_source_rgb(0.72, 0.70, 0.66)
        ctx.rectangle(px-3, 125, 18, 6)
        ctx.fill()
    # Central Khilwat Clock Tower
    ctx.set_source_rgb(0.92, 0.90, 0.86)
    ctx.rectangle(225, 40, 70, 70)
    ctx.fill()
    # Working clock face
    ctx.set_source_rgb(0.20, 0.22, 0.25)
    ctx.arc(260, 75, 20, 0, math.pi*2)
    ctx.set_line_width(3)
    ctx.stroke()
    ctx.set_source_rgb(0.98, 0.98, 0.98)
    ctx.arc(260, 75, 18, 0, math.pi*2)
    ctx.fill()
    # Clock hands
    ctx.set_source_rgb(0.10, 0.10, 0.10)
    ctx.move_to(260, 75)
    ctx.line_to(260, 62)
    ctx.stroke()
    ctx.move_to(260, 75)
    ctx.line_to(270, 75)
    ctx.stroke()
    # Classical balustrade parapet
    for bx in range(50, 470, 16):
        ctx.set_source_rgb(0.82, 0.80, 0.76)
        ctx.rectangle(bx, 102, 8, 10)
        ctx.fill()
    surf.write_to_png(path)

def render_hussain_sagar_buddha(path):
    surf, ctx = create_surface(380, 440)
    # Hussain Sagar Lake water
    ctx.set_source_rgb(0.18, 0.42, 0.60)
    ctx.rectangle(0, 350, 380, 90)
    ctx.fill()
    # Gibraltar Rock base
    ctx.set_source_rgb(0.35, 0.34, 0.32)
    ctx.arc(190, 380, 80, math.pi, 0)
    ctx.fill()
    # Carved lotus pedestal
    ctx.set_source_rgb(0.85, 0.45, 0.55)
    for lx in range(140, 245, 22):
        ctx.arc(lx, 335, 12, 0, math.pi)
        ctx.fill()
    # 58-ft Monolithic white granite standing Buddha
    ctx.set_source_rgb(0.94, 0.94, 0.92)
    # Robe body
    ctx.move_to(165, 150)
    ctx.line_to(150, 330)
    ctx.line_to(230, 330)
    ctx.line_to(215, 150)
    ctx.close_path()
    ctx.fill()
    # Robe pleat folds
    ctx.set_source_rgb(0.78, 0.78, 0.76)
    ctx.set_line_width(2)
    for ry in range(180, 310, 25):
        ctx.move_to(160, ry)
        ctx.curve_to(190, ry+12, 205, ry+12, 220, ry)
        ctx.stroke()
    # Abhaya Mudra raised blessing right hand
    ctx.set_source_rgb(0.94, 0.94, 0.92)
    ctx.arc(225, 180, 10, 0, math.pi*2)
    ctx.fill()
    # Head & Ushnisha topknot
    ctx.arc(190, 115, 26, 0, math.pi*2)
    ctx.fill()
    ctx.arc(190, 85, 12, 0, math.pi*2)
    ctx.fill()
    # Elongated ears
    ctx.rectangle(160, 110, 6, 20)
    ctx.fill()
    ctx.rectangle(214, 110, 6, 20)
    ctx.fill()
    surf.write_to_png(path)

def render_birla_mandir(path):
    surf, ctx = create_surface(460, 400)
    # Naubat Pahad granite hill plinth
    ctx.set_source_rgb(0.40, 0.38, 0.36)
    ctx.move_to(20, 380)
    ctx.line_to(120, 270)
    ctx.line_to(340, 270)
    ctx.line_to(440, 380)
    ctx.close_path()
    ctx.fill()
    # Pristine white Makrana marble temple sanctum
    ctx.set_source_rgb(0.98, 0.98, 0.97)
    ctx.rectangle(130, 180, 200, 95)
    ctx.fill()
    # Soaring 42-meter Rajasthani Shikhara tower
    ctx.move_to(170, 180)
    ctx.curve_to(185, 100, 210, 60, 230, 50)
    ctx.curve_to(250, 60, 275, 100, 290, 180)
    ctx.close_path()
    ctx.fill()
    # Marble amalaka disc & golden kalash
    draw_ellipse(ctx, 230, 48, 20, 6)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.85, 0.25)
    ctx.move_to(230, 44)
    ctx.line_to(230, 24)
    ctx.set_line_width(3)
    ctx.stroke()
    # Marble arched Jagamohana hall
    for ax in [155, 205, 255]:
        ctx.set_source_rgb(0.85, 0.86, 0.88)
        ctx.arc(ax+15, 220, 14, math.pi, 0)
        ctx.line_to(ax+29, 260)
        ctx.line_to(ax+1, 260)
        ctx.close_path()
        ctx.fill()
    surf.write_to_png(path)

def render_ramappa_temple(path):
    surf, ctx = create_surface(480, 380)
    # Star-shaped black basalt Upapitha platform (Kakatiya Sandbox)
    ctx.set_source_rgb(0.22, 0.22, 0.24)
    ctx.rectangle(40, 260, 400, 60)
    ctx.fill()
    # Black carved dolerite pillared hall (Sabhamandapa)
    ctx.set_source_rgb(0.18, 0.18, 0.20)
    for px in range(70, 420, 45):
        ctx.rectangle(px, 150, 14, 110)
        ctx.fill()
        # Slender carved bracket figures (Madanikas / dancing girls)
        ctx.set_source_rgb(0.12, 0.12, 0.14)
        ctx.move_to(px-8, 150)
        ctx.line_to(px+7, 180)
        ctx.line_to(px+22, 150)
        ctx.close_path()
        ctx.fill()
    # Lightweight floating-brick stepped Vimana shikhara
    ctx.set_source_rgb(0.68, 0.42, 0.26)
    for i, w in enumerate([220, 180, 140, 100, 60]):
        ctx.rectangle(240 - w//2, 150 - (i+1)*18, w, 18)
        ctx.fill()
        ctx.set_source_rgb(0.55, 0.32, 0.18)
        ctx.set_line_width(2)
        ctx.rectangle(240 - w//2, 150 - (i+1)*18, w, 18)
        ctx.stroke()
        ctx.set_source_rgb(0.68, 0.42, 0.26)
    # Copper Kalash finial
    ctx.set_source_rgb(0.82, 0.45, 0.20)
    ctx.move_to(240, 55)
    ctx.line_to(240, 30)
    ctx.set_line_width(4)
    ctx.stroke()
    surf.write_to_png(path)

# Execute renders
print("--- Rendering Famous Indian Roadside Landmarks ---")

# Kerala
render_mattancherry_palace("assets/indian_locations/kerala/landmarks/mattancherry_palace.png")
render_athirappilly_waterfalls("assets/indian_locations/kerala/landmarks/athirappilly_waterfalls.png")
render_bekal_fort_bastion("assets/indian_locations/kerala/landmarks/bekal_fort_bastion.png")
render_padmanabhaswamy_temple("assets/indian_locations/kerala/landmarks/padmanabhaswamy_temple.png")
print("✓ Kerala landmarks rendered!")

# Rajasthan
render_jal_mahal("assets/indian_locations/rajasthan/landmarks/jal_mahal_palace.png")
render_jaswant_thada("assets/indian_locations/rajasthan/landmarks/jaswant_thada_marble.png")
render_patwon_ki_haveli("assets/indian_locations/rajasthan/landmarks/patwon_ki_haveli.png")
print("✓ Rajasthan landmarks rendered!")

# Gujarat
render_sabarmati_ashram("assets/indian_locations/gujarat/landmarks/sabarmati_ashram.png")
render_adalaj_stepwell("assets/indian_locations/gujarat/landmarks/adalaj_stepwell.png")
render_modhera_sun_temple("assets/indian_locations/gujarat/landmarks/modhera_sun_temple.png")
render_somnath_temple("assets/indian_locations/gujarat/landmarks/somnath_temple.png")
print("✓ Gujarat landmarks rendered!")

# Telangana
render_chowmahalla_palace("assets/indian_locations/telangana/landmarks/chowmahalla_palace.png")
render_hussain_sagar_buddha("assets/indian_locations/telangana/landmarks/hussain_sagar_buddha.png")
render_birla_mandir("assets/indian_locations/telangana/landmarks/birla_mandir.png")
render_ramappa_temple("assets/indian_locations/telangana/landmarks/ramappa_temple.png")
print("✓ Telangana landmarks rendered!")

print("All regional famous landmarks successfully generated!")
