# AGY Builder Prompt — Endless Hill Climb Visual and Gameplay Verification

You are the implementation agent. Continue from this repaired project copy. Start by reading:

1. `AUDIT_AND_REPAIR_REPORT.md`
2. `docs/AUDIT_REPAIR_HANDOFF_2026-11-15.md`
3. The original phase reports in `docs/` and `phases docs/`

Do not merely summarize the reports. Import the project, run it, reproduce failures, make fixes, and return evidence.

## Hard technical requirements

- Use the project's Godot 4.7.x configuration and Mobile renderer.
- Keep the implementation GDScript-only. Do not add C++, GDExtension or a replacement engine architecture.
- Keep the `GroundPolygon` as the shallow surface crust, `SubsoilPolygon` as the lower material, and `CollisionPolygon2D` as the full collision body. Never “fix” a visual bug by reducing the collision body.
- Preserve the fixed 5,150 m default cycle. Test the separate branching mode without changing the default progression.
- Keep Skeleton Knight and Demon/Goblin animated characters in the Hell environment; they are background environmental actors, not the player driver.
- The Nitro bottle child icon must keep `mouse_filter = IGNORE`; the parent touch button owns the hit target.
- Preserve the original `.git` repository and branch. Do not reset, discard, clean or rewrite pre-existing user changes. Make a backup branch or patch before large refactors.

## Required repair targets

### Normal Land

Build a layered, lively countryside: an unbroken natural grass edge, readable earth below it, rolling green scenery, varied bushes and small flora, and occasional fences/signs/logs on gentle ground. Avoid a giant flat brown slab, obvious tiling, dense obstacle-like prop placement, or empty long stretches.

### Heaven

Keep the road readable as a slim ivory/gold marble surface with a clearly separate cloud/stone underside. Use distant palace layers, smaller elegant columns, cloud platforms, the angel monument, animated doves and restrained flowers. The sky should feel bright but not washed out; no monument or column should cover the vehicle/road.

### Hell

Keep the surface basalt-dark with a narrow molten rim and a clearly separate dark ash/rock underside. Use the narrow lava ribbon, volcanic rocks, atmospheric embers/ash, distant crags/portal/columns and readable animated Skeleton Knight + Demon/Goblin characters. The lava must not become a giant tiled rectangle, and props must not obscure the vehicle.

### Gameplay and UI

Verify continuous terrain joins and wheel contact after the rendering split. Verify coin/fuel/nitro pickups remain collectible and above the collision surface. Verify the Nitro button looks like the accelerator/brake button family and that its icon does not intercept input. Test keyboard and touch input. Check camera framing, HUD overlap, pause, results, restart, save data and vehicle selection.

## Required commands

Run the import first, then every test script. Capture the terminal output for each test:

```bash
godot --version
godot --headless --path . --editor --quit

for test_file in tests/test_*.gd; do
  echo "===== $test_file ====="
  godot --headless --path . --script "res://${test_file#./}" || exit 1
done

godot --path .
```

Run at least two complete fixed 5,150 m cycles and repeat with optional branching mode if that mode is in the test setup. Test the desktop 1280×720 layout and Android target layouts actually supported by the project. Do not alter orientation without a reproduced reason.

## Acceptance evidence — no unsupported pass claims

Return all of the following:

1. Godot version and complete clean import output.
2. Per-test command, pass/fail count, and full test log for **all 27 scripts**.
3. Fresh screenshots: main menu, Normal Land, Heaven, Hell, both biome transitions, both return merges, and the Nitro touch HUD.
4. A short manual-play video showing acceleration, braking, Nitro, pickups, crash, restart, pause/resume and progression.
5. A resource scan showing zero missing `res://` paths, plus any engine-generated import warnings.
6. Git status and itemized diff, separating the original archive's pre-existing working-tree changes from your new edits.
7. Remaining issues and measured performance/frame pacing on target hardware.

If a check cannot be run, name the exact blocker. Do not mark a test passed because a previous phase report claimed it passed. The repaired project is a candidate until it has fresh runtime evidence.
