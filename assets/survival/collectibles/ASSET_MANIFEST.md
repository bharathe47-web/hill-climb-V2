# Survival Mode — Coin & Fuel Asset Collection Manifest

**Asset Collection Path:** `/home/johnwick/1level asset/coin -asset`  
**Checklist Source:** `/home/johnwick/Downloads/survival_coin_fuel_asset_checklist.html`  
**Workspace Copy:** `/home/johnwick/1level asset/coin -asset/survival_coin_fuel_asset_checklist.html`  
**Showcase Preview:** `/home/johnwick/1level asset/coin -asset/collectibles_composite_preview.png`  
**Target Engine:** Godot Engine 4.x / GDScript  
**Art Direction:** Polished cartoon 2D game-art style matching reference art. Golden yellow face, orange-gold bevel edge, shiny highlights, consistent coin thickness. Red rectangular jerry-can fuel tank with dark grey/black cap, visible top handle, embossed fuel symbol, and soft 3D cartoon shading. True RGBA alpha transparency (no baked checkerboard).  
**Licence:** CC0 Public Domain / Game Asset  
**Total Checklist Items:** 31 / 31 Completed (100%)  
**Total RGBA PNG Assets:** 64 PNG files + Multi-frame Sprite Sheets + Composite Showcase  

---

## Folder Structure

```
coin -asset/
├── survival_collectibles/
│   ├── coins/
│   │   ├── coin_idle.png                        # (256x256) Front-facing golden coin idle sprite
│   │   ├── coin_idle_512.png                    # (512x512) Ultra-crisp high-res idle sprite
│   │   ├── coin_idle_raw.png                    # (2233x2243) Original master high-res sprite
│   │   ├── coin_rotation_spritesheet.png        # (1536x256) 6-frame 360° rotation sprite sheet (Hframes=6)
│   │   ├── coin_pickup_animation.png            # (1536x256) 6-frame collection shimmer/shine sprite sheet
│   │   ├── coin_glow.png                        # (256x256) Radial golden amber ambient glow layer
│   │   ├── coin_sparkle.png                     # (256x256) Standalone multi-point sparkle star glint
│   │   ├── coin_sparkle_spritesheet.png         # (1536x256) 6-frame sparkle burst particle sequence
│   │   ├── coin_collection_pop.png              # (1536x256) 6-frame disappearing pop & shockwave burst
│   │   ├── coin_pop_effect.png                  # (1536x256) Disappearing animation strip alias
│   │   ├── coin_shadow.png                      # (256x256) Soft feathered oval ground/drop shadow
│   │   ├── individual_frames/                   # Centered 256x256 single frames (coin_rotate_01..06, pop_01..06)
│   │   ├── pickup_animation_frames/             # Centered 256x256 single frames (coin_pickup_01..06)
│   │   └── sparkle_frames/                      # Centered 256x256 single frames (coin_sparkle_01..06)
│   └── fuel/
│       ├── fuel_can_idle.png                    # (256x256) Front-facing red jerry-can fuel tank sprite
│       ├── fuel_can_idle_raw.png                # (128x144) Canonical native HUD/gameplay jerry-can
│       ├── fuel_can_floating.png                # (256x256) Floating in-world placement pose with hover tilt
│       ├── fuel_pickup_animation.png            # (1536x256) 6-frame floating/bobbing rotation cycle sheet
│       ├── fuel_glow.png                        # (256x256) Radial warm red/amber ambient aura layer
│       ├── fuel_sparkle.png                     # (256x256) Standalone warm amber fuel collection glints
│       ├── fuel_sparkle_spritesheet.png         # (1536x256) 6-frame fuel sparkle cycle sheet
│       ├── fuel_collection_pop.png              # (256x256) High-energy flash pop burst asset
│       ├── fuel_collection_pop_spritesheet.png  # (1536x256) 6-frame energy ring & droplet burst sheet
│       ├── fuel_pop_effect.png                  # (256x256) Disappearing burst alias
│       ├── fuel_shadow.png                      # (256x256) Soft feathered ground placement shadow
│       ├── individual_frames/                   # Centered 256x256 single frames (fuel_frame_01..06, pop_01..06)
│       └── sparkle_frames/                      # Centered 256x256 single frames (fuel_sparkle_01..06)
├── coins/                                       # Root-level mirror for direct engine path resolution
├── fuel/                                        # Root-level mirror for direct engine path resolution
├── collectibles_composite_preview.png           # (1920x1080) Visual showcase preview of all collectibles
└── survival_coin_fuel_asset_checklist.html      # Marked HTML checklist (31/31 completed, 100%)
```

---

## 1. Coin Assets (`survival_collectibles/coins/`)

| File Name | Resolution | Format | Checklist Requirement & Visual Description |
|---|---|---|---|
| `coin_idle.png` | 256 × 256 | RGBA PNG | **Coin idle sprite — front-facing coin**. Rich golden yellow face (`#F5C103`), dark orange-gold rim (`#D68400`), central star emblem, and specular top highlight. |
| `coin_idle_512.png` | 512 × 512 | RGBA PNG | High-resolution version for 2K/4K displays and HD UI popups. |
| `coin_rotation_spritesheet.png` | 1536 × 256 | RGBA PNG | **Coin rotation sprite sheet**. 6 horizontal 256×256 frames showing 360° spin: 0°, 30°, 60°, 90° (narrow edge-on), 120°, 150°. Cleanly separated and centered for `hframes = 6, vframes = 1`. |
| `coin_pickup_animation.png` | 1536 × 256 | RGBA PNG | **Coin pickup animation**. 6 horizontal 256×256 frames showing bright diagonal light glint sweep across coin surface on collect. |
| `coin_glow.png` | 256 × 256 | RGBA PNG | **Coin glow**. Subtle golden amber radial halo (`#FFD700` to `#FF8C00`) with smooth quadratic alpha falloff. |
| `coin_sparkle.png` | 256 × 256 | RGBA PNG | **Coin sparkle effect**. 4-point and diamond star glints with white core and warm golden edges. |
| `coin_collection_pop.png` | 1536 × 256 | RGBA PNG | **Coin collection/pop effect**. 6-frame disappearing animation: flash burst -> expanding gold shockwave ring -> 8 outward starburst sparkles -> fadeout. |
| `coin_shadow.png` | 256 × 256 | RGBA PNG | **Coin shadow**. Soft feathered elliptical dark drop shadow for terrain/ground depth. |

---

## 2. Fuel Tank Assets (`survival_collectibles/fuel/`)

| File Name | Resolution | Format | Checklist Requirement & Visual Description |
|---|---|---|---|
| `fuel_can_idle.png` | 256 × 256 | RGBA PNG | **Fuel can idle sprite — front-facing can**. Red rectangular jerry-can (`#C63121`) with dark graphite cap, molded top handle, embossed fuel droplet/gas symbol, and soft cartoon 3D shading. |
| `fuel_can_floating.png` | 256 × 256 | RGBA PNG | **Fuel can floating sprite**. Dynamic in-world placement pose with slight perspective tilt and hover posture. |
| `fuel_pickup_animation.png` | 1536 × 256 | RGBA PNG | **Fuel pickup animation**. 6 horizontal 256×256 frames showing subtle bobbing, tilt, and perspective float cycle (`hframes = 6, vframes = 1`). |
| `fuel_glow.png` | 256 × 256 | RGBA PNG | **Fuel glow**. Radiant warm red-orange and amber ambient aura layer for visibility against dark backgrounds. |
| `fuel_sparkle.png` | 256 × 256 | RGBA PNG | **Fuel sparkle effect**. Clustered amber and gold sparkle stars. |
| `fuel_collection_pop.png` | 256 × 256 | RGBA PNG | **Fuel collection/pop effect**. High-intensity collection feedback flash burst (`#FDE695`). |
| `fuel_collection_pop_spritesheet.png` | 1536 × 256 | RGBA PNG | 6-frame collection disappearing animation: flash blast -> expanding orange fuel ring -> dissolving red droplets and sparkles. |
| `fuel_shadow.png` | 256 × 256 | RGBA PNG | **Fuel shadow**. Soft feathered elliptical ground shadow matched to jerry-can footprint. |

---

## 3. Checklist Verification (31 / 31 Items Completed)

### 1. Coin Assets
- [x] Coin idle sprite — front-facing coin (`coin_idle.png`)
- [x] Coin rotation sprite sheet — multiple angles, including narrow edge-on frames (`coin_rotation_spritesheet.png`)
- [x] Coin pickup animation — collection frames (`coin_pickup_animation.png`)
- [x] Coin glow — subtle golden glow (`coin_glow.png`)
- [x] Coin sparkle effect — small collection sparkles (`coin_sparkle.png`)
- [x] Coin collection/pop effect — disappearing animation (`coin_collection_pop.png`)
- [x] Coin shadow — optional subtle gameplay shadow (`coin_shadow.png`)
- [x] Golden yellow and orange-gold palette (`#F5C103`, `#D68400`)
- [x] Cartoon 2D game-art style; polished rounded look
- [x] Clear coin marking (star / currency emblem)
- [x] Consistent coin thickness and proportions across all rotation steps
- [x] Transparent background; no checkerboard baked into image
- [x] Sprite-sheet frames cleanly separated and aligned

### 2. Fuel Tank Assets
- [x] Fuel can idle sprite — front-facing can (`fuel_can_idle.png`)
- [x] Fuel can floating sprite — for in-world placement (`fuel_can_floating.png`)
- [x] Fuel pickup animation — collection frames (`fuel_pickup_animation.png`)
- [x] Fuel glow — subtle red/orange or warm yellow glow (`fuel_glow.png`)
- [x] Fuel sparkle effect — collection sparkles (`fuel_sparkle.png`)
- [x] Fuel collection/pop effect — disappearing animation (`fuel_collection_pop.png`)
- [x] Fuel shadow — optional soft placement shadow (`fuel_shadow.png`)
- [x] Red fuel can with dark grey/black cap
- [x] Visible top handle
- [x] Embossed fuel symbol
- [x] Rounded corners and soft 3D cartoon shading
- [x] Transparent background; no background scene or extra objects
- [x] Not photorealistic; maintain a clean 2D game-asset style

### 3. Collection Guidelines
- [x] Coin and fuel assets look like they belong to the same game
- [x] PNG files have real transparency (not a fake checkerboard background)
- [x] Assets are clean, readable at small gameplay sizes
- [x] Original files are kept; avoid overwriting existing game assets
- [x] Asset collection is complete before requesting implementation

---

## 4. Godot Engine 4.x Integration Guide

### Coin Setup (Sprite2D / AnimatedSprite2D)
```gdscript
# Example Godot 4.x Coin Pickup Node:
# Area2D
#   ├── Sprite2D (Texture = coin_rotation_spritesheet.png, Hframes = 6, Vframes = 1)
#   ├── Sprite2D_Glow (Texture = coin_glow.png, Modulate.a = 0.6)
#   ├── Sprite2D_Shadow (Texture = coin_shadow.png, Position = Vector2(0, 32))
#   └── CollisionShape2D (CircleShape2D, Radius = 20)
```

### Fuel Tank Setup
```gdscript
# Example Godot 4.x Fuel Pickup Node:
# Area2D
#   ├── Sprite2D (Texture = fuel_pickup_animation.png, Hframes = 6, Vframes = 1)
#   ├── Sprite2D_Glow (Texture = fuel_glow.png, Modulate.a = 0.5)
#   ├── Sprite2D_Shadow (Texture = fuel_shadow.png, Position = Vector2(0, 36))
#   └── CollisionShape2D (RectangleShape2D, Size = Vector2(36, 44))
```

---

## Next Phase Readiness

The asset collection phase is **100% complete and fully verified**.  
All files are organized in the requested directory structure, tested for clean transparency, aligned into uniform sprite sheets, and marked off in the HTML checklist.  
Ready for the user's review and subsequent Survival Mode integration prompt.
