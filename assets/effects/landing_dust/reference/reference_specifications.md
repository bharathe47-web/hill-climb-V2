# 2D Cartoon Mushroom Dust Impact — Reference Specifications & Visual Guide

## 1. Effect Architecture Overview

This reference document defines the visual standards, frame-by-frame timing, color palette breakdown, and spatial orientation for the 2D Cartoon Mushroom Dust Landing Effect designed for Godot 4.7.2.

The effect represents the impact of falling sky obstacles (such as Indian foods: Idli, Dosa, Vada, Samosa, Murukku, Pani Puri, Jalebi, Coconut) upon striking the terrain surface.

---

## 2. 12-Stage Visual Animation Sequence

The animation strictly executes the 12-stage evolution cycle matching cartoon physics principles (squash & stretch, anticipation, explosive burst, lateral rolling curls, dissolution):

| Stage | Frame | Phase | Description | Key Visual Elements |
|---|---|---|---|---|
| **01** | `frame_01.png` | Contact Impact | Immediate moment of ground impact | Flat ground flash puff, tiny radial amber sparklets ($2-4\text{px}$) |
| **02** | `frame_02.png` | Vertical Burst | High-velocity upward dust thrust | Vertical central plume rising to $y=400$, sharp lateral ground exhaust jets |
| **03** | `frame_03.png` | Mushroom Formation | Cap curl & stem delineation | Vertical stem rises to $h=75\text{px}$, bulbous cap forms with lateral roll |
| **04** | `frame_04.png` | Cloud Expansion | Volumetric inflation | Stem thickens ($46\text{px}$ radius), multi-lobed cap inflates, ground ring spreads |
| **05** | `frame_05.png` | Maximum Peak Volume | Maximum mushroom cloud scale | Full $150\text{px}$ stem height, massive multi-tier bulbous cap ($88\text{px}$ center radius), ground ring reaches $x=\pm 212\text{px}$ |
| **06** | `frame_06.png` | Lateral Spread | Mushroom cap flattens & spreads | Cap broadens horizontally, central stem thins and detaches from ground, ground ring thins |
| **07** | `frame_07.png` | Particle Separation | Cloud breaks into fragments | Floating specks & satellite puffs detach from main body, stem separates into distinct puffs |
| **08** | `frame_08.png` | Cloud Shrinking | Disintegration of central mass | Central cavity opens, main cap shrinks to $70\%$ volume, ground ring breaks into wisps |
| **09** | `frame_09.png` | Billowing Wisps | Secondary wisp drifting | Cap splits into 3-4 gentle puff clusters drifting upward with deceleration |
| **10** | `frame_10.png` | Dissolution | Atmospheric dispersion | Fading cream cloudlets ($35\%$ alpha), fine dust particles drifting apart |
| **11** | `frame_11.png` | Floating Specks | Lingering dust particles | Small suspended warm dust flecks ($20\%$ alpha), minimal ground presence |
| **12** | `frame_12.png` | Final Dispersal | Complete dissipation | Faint fading specks ($8\%$ alpha) vanishing into $100\%$ transparency |

---

## 3. Color Palette & Cel-Shading Standard

To seamlessly harmonize with the Survival Mode's **Destroyed City** environment (orange sunset, dusty brown ground, amber atmospheric haze), the asset utilizes a 5-tone warm cel-shading palette:

| Tone Role | Hex Code | RGB | Visual Purpose |
|---|---|---|---|
| **Contour Outline** | `#5A320C` | `(90, 50, 15)` | Crisp cartoon border; separates dust from background debris |
| **Shadow Base** | `#B4732D` | `(180, 115, 45)` | Volumetric depth under billowing lobes & underside curves |
| **Warm Midtone** | `#F0C878` | `(240, 200, 120)` | Golden-brown / pale ochre sun-drenched cartoon dust body |
| **Light Cream** | `#FFEBB9` | `(255, 235, 185)` | Soft cream puff surface receiving direct top-down ambient light |
| **Ivory Specular** | `#FFFAE6` | `(255, 250, 230)` | Crisp cartoon edge highlight on upper puff ridges |
| **Amber Debris** | `#D79641` | `(215, 150, 65)` | Ground impact pebble & particle fleck core |

---

## 4. Canvas & Alignment Dimensions

- **Frame Canvas:** $512 \times 512\text{ pixels}$ (Square RGBA PNG)
- **Impact Origin Point:** $(X=256, Y=445)$
- **Ground Offset:** $67\text{ pixels}$ from bottom of canvas (allows ground dust ring and underside shadows to render without clipping)
- **Orientation:** Side-scrolling 2D lateral view with natural depth cues.
