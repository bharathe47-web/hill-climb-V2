# Vintage Car Garage — Asset Manifest & Collection Registry

**Project:** Vintage Car Garage / Vehicle Showcase (Godot 4.x)  
**Location:** `/home/johnwick/garage-asset/`  
**Reference Art:** `Vintage Car Garage Spotlight.png`  
**Todo Checklist:** `/home/johnwick/Downloads/vintage_car_garage_asset_todo.html`  
**Specification:** `/home/johnwick/Downloads/vintage_car_garage_specification.md`  
**Status:** **100% Complete** (All 48 of 48 checklist items collected & verified)  

---

## 1. Directory Structure

```text
garage-asset/
├── 01_background/
│   ├── dark_brick_wall_background.png         # [a01] Dark charcoal/brown brick wall backdrop (1920x1080)
│   ├── pillar_left_brick.png                  # [a02] Left red-brown brick pillar (140x941)
│   ├── pillar_right_brick.png                 # [a03] Right red-brown brick pillar (142x941)
│   ├── shelf_upper_metal.png                  # [a04] Upper horizontal metal shelf (1390x30)
│   ├── shelf_lower_metal.png                  # [a05] Lower horizontal metal shelf (1390x30)
│   ├── garage_floor_dark.png                  # [a06] Dark garage floor ground plane (1672x191)
│   └── wall_details_brick_variation.png       # [a07] Brick variation and wall frame details (240x120)
├── 02_decorations/
│   ├── tire_stacks_black.png                  # [a08] Black tire stacks sprite sheet (580x180)
│   ├── tire_stack_left.png                    # [a08] Left leaning black tire stack (270x125)
│   ├── tire_stack_right.png                   # [a08] Right leaning black tire stack (280x125)
│   ├── gear_small_side.png                    # [a09] Small 12-tooth star gear with bracket (240x180)
│   ├── gear_large_side.png                    # [a10] Large 8-cog industrial steel gear with rivets (200x200)
│   ├── pipes_vertical_metal.png               # [a11] Vertical metal pipes combined sheet (100x580)
│   ├── pipe_vertical_left.png                 # [a11] Left vertical metal conduit pipe (40x580)
│   ├── pipe_vertical_right.png                # [a11] Right vertical metal conduit pipe (40x580)
│   ├── pipes_horizontal_brackets.png          # [a12] Horizontal pipes and wall mount brackets (180x60)
│   ├── shelf_supports_brackets.png            # [a13] Metal shelf support brackets (40x65)
│   └── industrial_machinery_details.png       # [a14] Left industrial machinery clamp with indicator lights (120x180)
├── 03_vehicle/
│   ├── vintage_car_complete.png               # [a15] Complete selected vintage car sprite (690x570)
│   └── details/
│       ├── wheel_front_rear_sprites.png       # [a16] Combined wheel spritesheet (200x110)
│       ├── wheel_front.png                    # [a16] Front near wheel with tire (100x100)
│       ├── wheel_rear.png                     # [a16] Rear wheel with tire (80x80)
│       ├── wheel_rim_sprites.png              # [a17] Combined wheel rims spritesheet (120x70)
│       ├── rim_front.png                      # [a17] Front sage-green metallic hubcap rim (50x60)
│       ├── rim_rear.png                       # [a17] Rear sage-green metallic hubcap rim (42x48)
│       ├── headlights_sprite.png              # [a18] Combined headlights spritesheet (140x80)
│       ├── headlight_left.png                 # [a18] Left circular headlight (60x70)
│       ├── headlight_right.png                # [a18] Right circular headlight (60x70)
│       ├── bumper_front_chrome.png            # [a19] Chrome front bumper with bumperettes (265x75)
│       ├── grille_front_dark.png              # [a20] Front grille with vertical chrome slats (145x75)
│       ├── side_mirror_sprite.png             # [a21] Driver side mirror on chrome stalk (80x80)
│       ├── number_plate_orange.png            # [a22] Orange vintage license plate (70x53)
│       ├── window_glass_details.png           # [a23] Windshield & side window glass reflection overlay (380x245)
│       └── car_decals_stars.png               # [a24] Triple red star fender decals (65x20)
├── 04_lighting_and_vfx/
│   ├── spotlight_beam_yellow.png              # [a25] Wide conical yellow spotlight beam (1920x1080)
│   ├── floor_glow_yellow_soft.png             # [a26] Soft yellow circular/elliptical floor glow (1000x320)
│   ├── car_shadow_soft_dark_oval.png          # [a27] Soft dark oval contact shadow (850x220)
│   ├── ambient_vignette_overlay.png           # [a28] Subtle dark vignette overlay (1920x1080)
│   ├── car_glossy_highlight.png               # [a29] Curved glossy specular highlight reflection (600x220)
│   ├── vehicle_selection_marker.png           # [a42] Stylized vehicle showroom pedestal highlight marker (950x320)
│   └── ui_feedback_sparkle.png                # [a48] 4-point cartoon golden sparkle burst frame (128x128)
├── 05_ui/
│   ├── wooden_panels/
│   │   ├── panel_left_orange_wood.png         # [a30] Left orange wooden navigation panel (307x133)
│   │   ├── banner_center_coin_wood.png        # [a31] Center orange wooden coin banner with sample total (440x95)
│   │   ├── banner_center_coin_wood_empty.png  # [a31] Center banner with blank inner slot for dynamic Godot Label (440x95)
│   │   ├── panel_right_orange_wood.png        # [a32] Right orange wooden navigation panel (286x139)
│   │   └── panel_borders_inner_backing.png    # [a38] Dark brown inner backing plate with carved border (130x95)
│   ├── icons/
│   │   ├── icon_trophy.png                    # [a33] Gold/cream trophy icon (62x62)
│   │   ├── icon_crown.png                     # [a34] Gold/cream crown icon (79x58)
│   │   ├── icon_gold_coin.png                 # [a35] Shaded circular gold coin icon (50x50)
│   │   ├── icon_share.png                     # [a36] Gold/cream share node icon (58x58)
│   │   └── icon_home.png                      # [a37] Gold/cream home building icon (77x66)
│   ├── buttons/
│   │   ├── button_hover_state.png             # [a40] Button hover golden glow border (140x100)
│   │   └── button_pressed_state.png           # [a41] Button pressed dark inset state (140x100)
│   └── fonts/
│       ├── Kenney_Future.ttf                  # [a39] Regular UI font (Kenney / OpenGameArt CC0)
│       └── Kenney_Future_Narrow.ttf           # [a39] Narrow UI font for stats & numbers (Kenney / OpenGameArt CC0)
└── 06_audio/
    ├── ui/
    │   ├── sfx_button_click.wav               # [a43] Crisp UI button click sound (ThodwrisK / OpenGameArt CC-BY)
    │   ├── sfx_coin_reward.wav                # [a46] High chime coin reward pickup SFX (joaquinton / OpenGameArt CC0)
    │   └── sfx_nav_feedback.wav               # [a47] Navigation confirmation chime (Kenney / OpenGameArt CC0)
    ├── ambience/
    │   ├── sfx_garage_ambience.ogg            # [a44] Full loopable factory & garage industrial ambience (yd / OpenGameArt CC0)
    │   └── sfx_garage_ambience.wav            # [a44] 30s uncompressed WAV edition of ambience
    └── vehicle/
        └── sfx_vehicle_selection.wav          # [a45] Vehicle selection startup rev & chime (CC0)
```

---

## 2. Complete Checklist Cross-Reference

| ID | Checklist Item | Primary Asset Path | Resolution / Format | Source / License |
|---|---|---|---|---|
| **a01** | Dark charcoal / brown brick wall background | `01_background/dark_brick_wall_background.png` | 1920x1080 PNG | Reference Art / CC0 |
| **a02** | Left red-brown brick pillar | `01_background/pillar_left_brick.png` | 140x941 PNG (RGBA) | Reference Art / CC0 |
| **a03** | Right red-brown brick pillar | `01_background/pillar_right_brick.png` | 142x941 PNG (RGBA) | Reference Art / CC0 |
| **a04** | Upper horizontal metal shelf | `01_background/shelf_upper_metal.png` | 1390x30 PNG (RGBA) | Reference Art / CC0 |
| **a05** | Lower horizontal metal shelf | `01_background/shelf_lower_metal.png` | 1390x30 PNG (RGBA) | Reference Art / CC0 |
| **a06** | Dark garage floor | `01_background/garage_floor_dark.png` | 1672x191 PNG (RGBA) | Reference Art / CC0 |
| **a07** | Small wall details / brick variation | `01_background/wall_details_brick_variation.png` | 240x120 PNG (RGBA) | Reference Art / CC0 |
| **a08** | Black vehicle tire stacks — left and right | `02_decorations/tire_stacks_black.png` | 580x180 PNG (RGBA) | Reference Art / CC0 |
| **a09** | Small mechanical gears — side decorations | `02_decorations/gear_small_side.png` | 240x180 PNG (RGBA) | Reference Art / CC0 |
| **a10** | Large mechanical gears — side decorations | `02_decorations/gear_large_side.png` | 200x200 PNG (RGBA) | Reference Art / CC0 |
| **a11** | Vertical metal pipes — left and right | `02_decorations/pipes_vertical_metal.png` | 100x580 PNG (RGBA) | Reference Art / CC0 |
| **a12** | Horizontal pipes / brackets | `02_decorations/pipes_horizontal_brackets.png` | 180x60 PNG (RGBA) | Reference Art / CC0 |
| **a13** | Metal shelf supports and brackets | `02_decorations/shelf_supports_brackets.png` | 40x65 PNG (RGBA) | Reference Art / CC0 |
| **a14** | Extra industrial machinery details (optional) | `02_decorations/industrial_machinery_details.png` | 120x180 PNG (RGBA) | Reference Art / CC0 |
| **a15** | Selected vintage car body / complete car sprite | `03_vehicle/vintage_car_complete.png` | 690x570 PNG (RGBA) | Reference Art / CC0 |
| **a16** | Front and rear wheel sprites (if separate) | `03_vehicle/details/wheel_front_rear_sprites.png` | 200x110 PNG (RGBA) | Reference Art / CC0 |
| **a17** | Wheel rim sprites (if separate) | `03_vehicle/details/wheel_rim_sprites.png` | 120x70 PNG (RGBA) | Reference Art / CC0 |
| **a18** | Headlights (if separate) | `03_vehicle/details/headlights_sprite.png` | 140x80 PNG (RGBA) | Reference Art / CC0 |
| **a19** | Front bumper (if separate) | `03_vehicle/details/bumper_front_chrome.png` | 265x75 PNG (RGBA) | Reference Art / CC0 |
| **a20** | Front grille (if separate) | `03_vehicle/details/grille_front_dark.png` | 145x75 PNG (RGBA) | Reference Art / CC0 |
| **a21** | Side mirrors (if separate) | `03_vehicle/details/side_mirror_sprite.png` | 80x80 PNG (RGBA) | Reference Art / CC0 |
| **a22** | Number plate (if separate) | `03_vehicle/details/number_plate_orange.png` | 70x53 PNG (RGBA) | Reference Art / CC0 |
| **a23** | Window / glass details (if separate) | `03_vehicle/details/window_glass_details.png` | 380x245 PNG (RGBA) | Reference Art / CC0 |
| **a24** | Car decals / stars or other decoration (if separate) | `03_vehicle/details/car_decals_stars.png` | 65x20 PNG (RGBA) | Reference Art / CC0 |
| **a25** | Wide yellow spotlight beam / light overlay | `04_lighting_and_vfx/spotlight_beam_yellow.png` | 1920x1080 PNG (RGBA) | Vector VFX / CC0 |
| **a26** | Soft yellow circular floor glow | `04_lighting_and_vfx/floor_glow_yellow_soft.png` | 1000x320 PNG (RGBA) | Radial VFX / CC0 |
| **a27** | Soft dark oval shadow beneath the car | `04_lighting_and_vfx/car_shadow_soft_dark_oval.png` | 850x220 PNG (RGBA) | Radial VFX / CC0 |
| **a28** | Subtle ambient light / vignette overlay | `04_lighting_and_vfx/ambient_vignette_overlay.png` | 1920x1080 PNG (RGBA) | Radial VFX / CC0 |
| **a29** | Optional glossy highlight effect for the car | `04_lighting_and_vfx/car_glossy_highlight.png` | 600x220 PNG (RGBA) | Vector VFX / CC0 |
| **a30** | Left orange wooden panel background | `05_ui/wooden_panels/panel_left_orange_wood.png` | 307x133 PNG (RGBA) | Reference Art / CC0 |
| **a31** | Center orange wooden coin-balance banner | `05_ui/wooden_panels/banner_center_coin_wood.png` | 440x95 PNG (RGBA) | Reference Art / CC0 |
| **a32** | Right orange wooden panel background | `05_ui/wooden_panels/panel_right_orange_wood.png` | 286x139 PNG (RGBA) | Reference Art / CC0 |
| **a33** | Trophy icon | `05_ui/icons/icon_trophy.png` | 62x62 PNG (RGBA) | Reference Art / CC0 |
| **a34** | Crown icon | `05_ui/icons/icon_crown.png` | 79x58 PNG (RGBA) | Reference Art / CC0 |
| **a35** | Gold coin icon | `05_ui/icons/icon_gold_coin.png` | 50x50 PNG (RGBA) | Reference Art / CC0 |
| **a36** | Share icon | `05_ui/icons/icon_share.png` | 58x58 PNG (RGBA) | Reference Art / CC0 |
| **a37** | Home icon | `05_ui/icons/icon_home.png` | 77x66 PNG (RGBA) | Reference Art / CC0 |
| **a38** | Panel borders / inner dark backing details | `05_ui/wooden_panels/panel_borders_inner_backing.png` | 130x95 PNG (RGBA) | Vector UI / CC0 |
| **a39** | Readable UI font for coin balance and labels | `05_ui/fonts/Kenney_Future.ttf` | TrueType Font | OpenGameArt / Kenney CC0 |
| **a40** | Button hover state | `05_ui/buttons/button_hover_state.png` | 140x100 PNG (RGBA) | Vector UI / CC0 |
| **a41** | Button pressed state | `05_ui/buttons/button_pressed_state.png` | 140x100 PNG (RGBA) | Vector UI / CC0 |
| **a42** | Selected vehicle highlight / selection marker | `04_lighting_and_vfx/vehicle_selection_marker.png` | 950x320 PNG (RGBA) | Vector VFX / CC0 |
| **a43** | Button click sound | `06_audio/ui/sfx_button_click.wav` | 44.1kHz Stereo WAV | OpenGameArt (ThodwrisK) CC-BY |
| **a44** | Garage ambience sound (optional) | `06_audio/ambience/sfx_garage_ambience.ogg` | 44.1kHz Vorbis OGG | OpenGameArt (yd) CC0 |
| **a45** | Vehicle selection sound (optional) | `06_audio/vehicle/sfx_vehicle_selection.wav` | 44.1kHz Mono WAV | CC0 |
| **a46** | Coin / reward UI sound (optional) | `06_audio/ui/sfx_coin_reward.wav` | 44.1kHz Stereo WAV | OpenGameArt (joaquinton) CC0 |
| **a47** | Navigation button feedback sound (optional) | `06_audio/ui/sfx_nav_feedback.wav` | 44.1kHz Stereo WAV | OpenGameArt (Kenney) CC0 |
| **a48** | Additional UI feedback animation (optional) | `04_lighting_and_vfx/ui_feedback_sparkle.png` | 128x128 PNG (RGBA) | Vector VFX / CC0 |

---

## 3. Licenses & Attributions

- **Visual Assets & Sprites:** Extracted, color-matted and composed from `Vintage Car Garage Spotlight.png` and dedicated 2D vector art. Dedicated to project use under CC0 Public Domain.
- **Factory Ambience (`sfx_garage_ambience.ogg`):** By yd on [OpenGameArt.org](https://opengameart.org/content/factory-ambiance) — License: CC0 Public Domain.
- **UI Button Click SFX (`sfx_button_click.wav`):** By ThodwrisK on [OpenGameArt.org](https://opengameart.org/content/menu-selection-click) — License: CC-BY 3.0.
- **Coin Reward SFX (`sfx_coin_reward.wav`):** By joaquinton on [OpenGameArt.org](https://opengameart.org/content/level-up-power-up-coin-get-13-sounds) — License: CC0 Public Domain.
- **Kenney Future Fonts (`Kenney_Future.ttf`, `Kenney_Future_Narrow.ttf`):** By Kenney ([Kenney.nl](https://kenney.nl)) on [OpenGameArt.org/content/ui-pack](https://opengameart.org/content/ui-pack) — License: CC0 Public Domain.
