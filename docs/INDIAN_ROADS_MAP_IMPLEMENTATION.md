# Indian Roads — In-Game Tourism Route Map Implementation
**Developer:** Joel (Indian Roads, HUD, Pickups, Routes, Level Design, QA)  
**Project:** Hill Climb V2 (Godot 4.7)  
**Branch:** `feature/joel-roads-obstacles`  
**Date:** November 17, 2026  

---

## 1. Overview & Architectural Purpose

Prior to this implementation, players had no way of viewing their current geographical location, upcoming tourist attractions, or overall progress within the active Indian state without quitting the session or relying solely on the single "NEXT WAYPOINT" text snippet in the top bar.

The newly created **Route Map System** introduces an in-game modal dialog accessible at any time during gameplay via the HUD `MapButton` or keyboard shortcut `[M]`.

### Core Design Requirements Met:
1. **Zero Progress Loss:** Opening the map pauses the scene tree (`get_tree().paused = true`), freezing vehicle velocity, timers, and animations, without reloading the scene or resetting coins/fuel.
2. **State Geography:** Renders the authentic vector state SVG map thumbnail (Tamil Nadu, Goa, Kerala, Rajasthan, Gujarat, Telangana).
3. **Milestone Progression:** Lists all waypoints along the route with dynamic status tags:
   - `[✓]` **Completed** (Green accent) for passed landmarks.
   - `[★]` **Current Target** (Vibrant cyan/yellow glowing) for the active upcoming waypoint.
   - `[•]` **Upcoming** (Muted grey) for locked future attractions.
4. **Distance Telemetry:** Shows total distance, traversed meters, percentage completed, and remaining distance to the destination finish arch.
5. **Seamless Dismissal:** Dismissable via the top-right `✕` button, the bottom `RESUME DRIVING` button, or pressing `[ESC]` / `[M]`.

---

## 2. Component Hierarchy & File Structure

```
scenes/modes/indian_roads/
└── RouteMapOverlay.tscn             <-- Visual scene definition
scripts/modes/indian_roads/
└── RouteMapOverlay.gd               <-- Interactive logic controller
assets/ui/buttons/
├── button_map.png                   <-- 64x64 vector map button (folded map + pin)
└── button_map_pressed.png           <-- 64x64 pressed button state
```

### Scene Tree Node Breakdown:
```
RouteMapOverlay (Control, process_mode = PROCESS_MODE_ALWAYS)
├── Backdrop (ColorRect, semi-transparent black #050a14d2)
└── CenterContainer
    └── ModalPanel (PanelContainer, cyan border & dark slate body)
        └── Margin (MarginContainer)
            └── MainVBox
                ├── HeaderHBox
                │   ├── TitleVBox
                │   │   ├── StateTitleLabel ("TAMIL NADU HIGHWAY ROUTE MAP")
                │   │   └── RouteSubtitleLabel ("KANYAKUMARI → CHENNAI • 1100m (1.1 KM)")
                │   └── CloseButton ("✕", custom red badge)
                ├── HSeparator
                ├── ContentHBox
                │   ├── MapContainer (PanelContainer, width 340px)
                │   │   └── StateMapRect (TextureRect, SVG map preview)
                │   └── RightVBox (size_flags_horizontal = EXPAND_FILL)
                │       ├── ProgressStatsVBox
                │       │   ├── StatsHBox (ProgressLabel & RemainingLabel)
                │       │   └── ProgressBar (Visual journey fill)
                │       ├── WaypointsTitle ("ROUTE WAYPOINTS & LANDMARKS:")
                │       └── ScrollContainer
                │           └── WaypointsVBox (Dynamically populated waypoint rows)
                └── FooterHBox
                    └── ResumeButton ("RESUME DRIVING", blue action button)
```

---

## 3. Script Logic & Signal Flow

```
[User clicks MapButton / presses 'M']
               │
               ▼
   IndianRoadsHUD.map_pressed
               │
               ▼
IndianRoadsController._on_map_requested()
  ├── current_state = ModeState.PAUSED
  ├── get_tree().paused = true
  ├── active_vehicle.is_nitro_active = false (clear throttle/boost)
  └── route_map_overlay.open_map(active_route, session_distance_m)
               │
               ▼
       [RouteMapOverlay Displayed]
  ├── Loads active state SVG map
  ├── Calculates distance percentages
  ├── Dynamically populates waypoint checklist rows
  └── Fades in with quad easing
               │
   [User clicks 'RESUME' / '✕' / 'M' / 'ESC']
               │
               ▼
    RouteMapOverlay.map_closed
               │
               ▼
IndianRoadsController._on_map_closed()
  ├── get_tree().paused = false
  └── current_state = ModeState.PLAYING
```

---

## 4. Multi-State SVG Map Assets Referenced

| State | Vector SVG Map Path | Start Point | Destination |
| :--- | :--- | :--- | :--- |
| **Tamil Nadu** | `res://assets/indian_locations/tamil_nadu_state_map.svg` | Kanyakumari | Chennai |
| **Goa** | `res://assets/indian_locations/goa_state_map.svg` | Panaji | Margao |
| **Kerala** | `res://assets/indian_locations/kerala_state_map.svg` | Kochi | Munnar |
| **Rajasthan** | `res://assets/indian_locations/rajasthan_state_map.svg` | Jaipur | Jaisalmer |
| **Gujarat** | `res://assets/indian_locations/gujarat_state_map.svg` | Ahmedabad | Rann of Kutch |
| **Telangana** | `res://assets/indian_locations/telangana_state_map.svg` | Hyderabad | Warangal |

---

## 5. Verification Results

- Verified via `tests/test_gameplay_refinement.gd` running in engine:
  - Map opens smoothly on request.
  - Scene tree pauses immediately (`tree.paused == true`).
  - Waypoints accurately classified as passed vs. current target.
  - Dismissal restores gameplay instantly with vehicle position and physics preserved without any reset.
