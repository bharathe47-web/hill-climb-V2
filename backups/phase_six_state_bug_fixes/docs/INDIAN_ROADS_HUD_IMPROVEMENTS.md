# Indian Roads — HUD Improvements & Touch Controls Specification
**Developer:** Joel (Indian Roads, HUD, Pickups, Routes, Level Design, QA)  
**Project:** Hill Climb V2 (Godot 4.7)  
**Branch:** `feature/joel-roads-obstacles`  
**Date:** November 17, 2026  

---

## 1. Executive Summary

The previous in-game HUD featured a 340px-wide blue nitrogen oxide canister texture (`nitro_bottle.png`) scaled at 0.85, which covered an excessive portion of the left-hand screen area, obscured incoming terrain undulations, and lacked proper tactile touch feedback states.

In this update, the nitro control has been redesigned into a **compact 80×80 pixel circular mobile touch button** positioned ergonomically above the brake pedal on the left side of the screen. In addition, the HUD has been enhanced with dynamic visual state modulation, keyboard shortcut handlers, and an integrated Route Map access button.

---

## 2. Nitro Button Redesign

### 2.1 Visual Specification
- **Native Resolution:** 80 × 80 pixels.
- **Aspect Ratio:** 1:1 circular badge with anti-aliased gradient rims.
- **Design Elements:**
  - Radial metallic blue background with translucent glass depth.
  - High-intensity cyan outer rim with 3px stroke.
  - Central stylized dual-chevron lightning boost glyph.
  - Bold "NITRO" label cleanly embossed at the bottom of the disc.
  - Position: `Vector2(50, 460)` on screen (directly above `BrakeButton` at `Vector2(40, 560)`).

### 2.2 Three-State Interactive Graphic Assets
All textures generated via high-precision vector rendering into `assets/ui/controls/`:
1. `nitro_btn_normal.png`: Vibrant cyan radial glow with bright yellow/gold flame core. Used during active, charged gameplay.
2. `nitro_btn_pressed.png`: High-flare bloom state with expanded neon-cyan rim and luminous white energy core. Displayed during active touch contact.
3. `nitro_btn_disabled.png`: Desaturated slate-grey disc with dimmed silhouette glyph. Signifies empty or depleted nitro reservoir.

```
+--------------------------------------------------------------+
|                     HUD TOP BAR (60px)                       |
| [TN: KANYAKUMARI -> CHENNAI]  [COINS: 120]  [FUEL]  [MAP] [||]
+--------------------------------------------------------------+
|                                                              |
|                     GAMEPLAY VIEWPORT                        |
|                                                              |
|                                                              |
|   ( [BOOST] Hint )                                           |
|   +--------------+                                           |
|   |  (★ NITRO)   |  <-- Compact 80x80 Button (pos: 50, 460)  |
|   +--------------+                                           |
|   +--------------+                         +--------------+  |
|   |    BRAKE     |                         |     GAS      |  |
|   +--------------+                         +--------------+  |
|   (pos: 40, 560)                            (pos: 1110, 560) |
+--------------------------------------------------------------+
```

---

## 3. Dynamic Modulation & Script Integration

In `scripts/modes/indian_roads/IndianRoadsHUD.gd`:
- `update_nitro(current: float, max_val: float) -> void`:
  - When `current <= 0.05` (nitro tank exhausted), the button modulate alpha is reduced to `Color(0.5, 0.5, 0.5, 0.5)` to clearly communicate an empty charge without cluttering the screen.
  - When charged, full opacity `Color(1.0, 1.0, 1.0, 1.0)` is restored.
  - Top bar `nitro_label` smoothly updates percentage `0% – 100%` and switches font color from vibrant cyan (`Color(0.2, 0.9, 1.0)`) to muted steel grey (`Color(0.6, 0.7, 0.8, 0.6)`) when under 15%.

---

## 4. Multi-Platform Input Handlers

In addition to touch inputs, standard desktop keyboard controls are wired:
- **Boost / Nitro:** `[SPACE]` key or touch `NitroButton`.
- **Brake / Reverse:** `[A]` / `[LEFT ARROW]` or touch `BrakeButton`.
- **Accelerate / Gas:** `[D]` / `[RIGHT ARROW]` or touch `GasButton`.
- **Map:** `[M]` key or click `MapButton`.
- **Pause:** `[ESCAPE]` key or click `PauseButton`.

---

## 5. Screen Layout & Ergonomics Verification

| HUD Component | Type | Position | Size | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| `TopBar` | PanelContainer | `(0, 0)` | `1280 × 56` | Persistent navigation & status |
| `RouteTitleLabel` | Label | Top Left | Flexible | State and route departure/destination |
| `RouteProgressBar` | ProgressBar | Top Left Sub | `200 × 10` | Real-time distance traversal bar |
| `CoinsHBox` | HBoxContainer | Center-Right | `80 × 30` | Gold coin tally with animated icon |
| `FuelHBox` | HBoxContainer | Center-Right | `120 × 20` | Fuel gauge bar & percentage indicator |
| `NitroHBox` | HBoxContainer | Center-Right | `120 × 20` | Nitro energy gauge & percentage |
| `MapButton` | Button | Top Right | `44 × 44` | In-game Route Map modal dialog trigger |
| `PauseButton` | Button | Top Right | `44 × 44` | Pause menu overlay trigger |
| `NitroButton` | TouchScreenButton | `(50, 460)` | **`80 × 80`** | Compact left-hand thumb nitro activation |
| `BrakeButton` | TouchScreenButton | `(40, 560)` | `90 × 90` | Left-hand thumb braking & reversing |
| `GasButton` | TouchScreenButton | `(1110, 560)` | `100 × 100`| Right-hand thumb acceleration pedal |
