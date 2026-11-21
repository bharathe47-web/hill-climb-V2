# INDIAN ROADS BACKGROUND KNOWN ISSUES & TECHNICAL OBSERVATIONS
**Author:** Joel (Lead Senior Godot Developer & Environment Artist)  
**Project:** Indian Roads Driving Experience (Godot 4.7)  
**Date:** November 17, 2026  

---

## 1. Current Observations & Technical Notes

### A. GPU Driver Compatibility Warning (Headless / OpenGL Fallback)
- **Observation:** When running on certain Linux sessions without Vulkan Wayland extensions (`VK_KHR_surface`), Godot prints:
  `WARNING: Your video card drivers seem not to support the required Vulkan version, switching to OpenGL 3.`
- **Impact:** Zero impact on runtime gameplay or visual fidelity. The engine seamlessly falls back to Mesa OpenGL 3 Core Profile on the AMD Radeon 610M GPU and renders all 6 parallax planes, shaders, and viewports at steady 60 FPS.
- **Action Required:** None; this is standard behavior on Linux Mesa drivers when Wayland Vulkan surface presentation is bypassed.

### B. Viewport Memory Management During Multi-State Batch Captures
- **Observation:** When rapidly instantiating and destroying multiple `SubViewport` nodes inside an automated capture loop across dozens of routes, Godot's SceneTree garbage collection requires a brief 2-frame delay (`await process_frame`) between teardown and setup to ensure complete cleanup of orphaned textures.
- **Resolution:** Implemented a single persistent `SubViewport` pattern in `scripts/capture_six_state_background_evidence.gd`.
- **Status:** Resolved.

### C. Glass Bridge Ocean Horizon Alignment (Tamil Nadu)
- **Observation:** The Kanyakumari Glass Bridge deck is elevated at $y \approx 242\text{px}$, raising the vehicle $\sim 105\text{px}$ above standard road level ($y \approx 382\text{px}$).
- **Resolution:** The Far Horizon ocean plane was calibrated to cover $y \in [330, 720]\text{px}$, while the earth embankment is cleanly split between $x=27,000$ and $x=45,000$, ensuring that animated ocean water waves are visible both directly beneath the transparent glass deck and stretching out to the horizon.
- **Status:** Verified working 100%.

---

## 2. Future Visual Enhancement Candidates (Non-Blocking Backlog)

1. **Dynamic Time-of-Day Weather Transitions:** In future milestone phases, subtle color modulation can transition skies dynamically (e.g., from morning coastal golden glow to afternoon heat in Tamil Nadu, or sudden monsoon rain particle effects in Kerala).
2. **Animated Distant Ambient Particles:** Adding faint sea-spray mist near Kanyakumari rocks and Athirappilly waterfall vapor using low-overhead GPU particle systems.
3. **Vehicle Tire Dust Particles:** Emitting dust particles tinted with the state-specific shoulder soil color (red laterite dust in Goa/TN, golden sand spray in Rajasthan, white salt dust in Gujarat).
