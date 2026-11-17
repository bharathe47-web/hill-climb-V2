# Endless Map — Branching Heaven & Hell Gameplay Design

**Status:** Proposed gameplay design / implementation specification  
**Engine:** Godot 4.7.2, GDScript only, Vulkan Forward Mobile  
**Target:** Existing Endless-Hillclimb project  
**Primary goal:** Turn Heaven and Hell from fixed distance-based scenery zones into two playable 500m routes selected by the player's Nitro-assisted ramp attempt.

---

## 1. Executive Decision

Replace the previous fixed 5,150m schedule with a repeating **Normal Land → Heaven OR Hell → Normal Land** gameplay loop.

The player begins in Normal Land. At a special ramp encounter, the player can activate Nitro and use vehicle momentum to reach an upper Heaven route. If the launch is missed, Nitro is unavailable, or the vehicle does not have enough momentum, the vehicle descends into a lower Hell route. Neither outcome should automatically end the run. Heaven and Hell are both playable 500m routes, and both reconnect to the same Normal Land track.

The route is skill-based, not a menu choice and not a random biome swap. The ramp, vehicle physics, route geometry, effects, sound, and HUD must make the outcome understandable and satisfying.

### Recommended cadence

Each biome section is 500m long. A Normal section alternates with one selected realm section:

| World distance | Gameplay section | Result |
|---|---|---|
| 0–500m | Normal Land | Approach and prepare for the first ramp |
| 500–1,000m | Heaven **or** Hell | Selected by the ramp outcome; exactly 500m of realm gameplay |
| 1,000–1,500m | Normal Land | Shared return route and next approach |
| 1,500–2,000m | Heaven **or** Hell | Second ramp outcome; exactly 500m of realm gameplay |
| 2,000–2,500m | Normal Land | Shared return route and next approach |
| 2,500–3,000m | Heaven **or** Hell | Third ramp outcome |
| 3,000–3,500m | Normal Land | Shared return route and next approach |
| 3,500–4,000m | Heaven **or** Hell | Fourth ramp outcome |
| 4,000–4,500m | Normal Land | Shared return route and next approach |
| 4,500–5,000m | Heaven **or** Hell | Fifth ramp outcome |
| 5,000m onward | Repeat the same 1,000m encounter cycle | Continue endlessly |

**Boundary rule:** biome sections change at 500m boundaries. New ramp decisions occur at 500m, 1,500m, 2,500m, 3,500m, 4,500m, etc. The transition animations and ramp geometry are included inside the relevant 500m section; do not add hidden extra distance or silently extend the route.

This is a deliberate change from the earlier fixed schedule (Normal 0–1,000m, fixed Heaven 1,150–2,200m, fixed Hell 3,650–5,000m). Under the new design, a distance alone does not identify the active realm. The player's actual route outcome does.

---

## 2. Core Player Experience

### 2.1 The Normal Land approach

Normal Land is the familiar driving space and the setup for the next encounter.

- Keep the current vehicle, driving, fuel, Nitro, coin, HUD, camera, and terrain systems.
- During the final approach before a gate, introduce subtle visual foreshadowing: distant golden cloud light above the track and a faint volcanic fissure/glow below it.
- Make the upcoming ramp visible early enough for the player to understand what is coming. It must enter the gameplay camera frame naturally, not suddenly appear under the vehicle.
- Use existing Normal Land scenery and terrain profiles. Do not make every approach identical; vary safe scenery placement while preserving a readable launch area.
- Do not spawn a ramp directly underneath the car or hide the launch crest behind the HUD.

### 2.2 Ramp warning and Nitro indication

Recommended cue sequence (distances are starting values for playtesting, not immutable constants):

| Approx. distance before gate | Player feedback |
|---|---|
| 75–50m | Distant ramp/gateway becomes visible; subtle environmental audio cue |
| 50–30m | HUD banner: `RAMP AHEAD`; show a clear ramp/route marker |
| 30–10m | HUD prompt: `BOOST TO REACH HEAVEN`; pulse the existing Nitro gauge and existing Boost control |
| Launch zone | Strong but brief visual/audio timing cue; player can activate existing Boost action |
| Immediately after outcome | Show `HEAVEN ROUTE` or `HELL ROUTE` for a short period, without blocking driving |

The exact distances must be tuned against the actual vehicle speed, camera framing, and ramp length. Prefer a physical `Area2D`/launch trigger associated with the ramp over brittle checks scattered across scripts.

**Current control context:** the supplied gameplay screenshot already shows a Nitro meter and `BOOST: SHIFT / SPACE`. Reuse the existing boost InputMap action and current touch control. Do not add a second Nitro key or change the mobile control layout unnecessarily.

HUD rules:

- Briefly highlight the existing Nitro bar and Boost button during the launch window.
- Keep the prompt near the top/center safe area, away from the vehicle, road, distance display, fuel meter, coin counter, and pause control.
- If Nitro is empty or below the usable amount, show an honest cue such as `NITRO EMPTY — LOWER ROUTE` rather than telling the player to press an unavailable control.
- Do not display a countdown unless the timing is genuinely time-based and tested. A distance/visual ramp cue is more readable in a speed-variable driving game.
- Provide one short first-time tutorial: `USE BOOST AT THE RAMP TO REACH HEAVEN. MISS THE LAUNCH AND YOU'LL DROP INTO HELL.` After the first encounter, use only the compact prompt.
- Do not let HUD effects obscure the driving surface or reduce visibility.

### 2.3 Route selection must be physical and fair

The intended outcomes are:

**Heaven success:**
- The player activates the existing Nitro system in the launch window.
- Nitro adds its normal force/acceleration; do not apply an unrelated second Nitro impulse.
- The ramp angle, vehicle speed, and existing physics allow the vehicle to reach the upper cloud landing/track.
- A Heaven route trigger confirms the vehicle has actually landed on/reached the Heaven path.

**Hell fallback:**
- The player does not activate Nitro in time, has no usable Nitro, or does not generate enough momentum to reach the upper route.
- Gravity carries the vehicle down through a readable volcanic entrance.
- A lower basalt catch track safely receives the vehicle and confirms the Hell route.
- Missing the Heaven launch must not automatically kill the player. Hell is an alternate gameplay route, not a game-over screen.

**Critical implementation rule:** Do not teleport the vehicle to an arbitrary coordinate or select Heaven solely because a Boolean says `boost_pressed = true`. The intended physical design is an upper reachable route and a lower safe catch route. Record the Nitro attempt for HUD/tutorial/analytics, but confirm the actual route from a route landing/entry trigger. If the current terrain generator cannot safely build this with its existing segment/pooling architecture, stop and present a small technical proposal before changing or replacing the terrain system.

A player who presses Nitro too early, too late, or with insufficient momentum may still enter Hell. The cue and collision/route geometry must make that outcome feel fair and understandable.

### 2.4 Hell is a challenge, not punishment

Hell must be fun enough that missing Heaven does not feel like the run has been ruined.

- Give Hell more demanding terrain and hazards than Heaven, but keep the route fully playable.
- Use visible warning/telegraphing before fire vents, gaps, or moving hazards.
- Keep lava visually dramatic but outside the normal wheel-contact path unless a specific fair hazard is intentionally designed and tested.
- Place coins, fuel, and/or Nitro opportunities so players can recover and prepare for the next ramp.
- Environmental skeletons, demons, and the flying dragon remain scenery/ambient characters unless combat is explicitly approved later. The player remains seated in the vehicle.
- Do not make every Hell route a guaranteed death or empty punishment corridor.

### 2.5 Heaven is a rewarding route, not just a background

- Create a distinct playable cloud/marble road for the full 500m.
- Give Heaven a more graceful, airy feel: readable cloud platforms, palace architecture, golden arches, angel statue, animated doves, lilies, gold particles, and soft celestial lighting.
- Make the road feel physically supported and driveable. Decorative clouds and palace parts must not be mistaken for collision surfaces.
- Give the player a satisfying reward through pickups, clean jump opportunities, or a modest configured reward modifier after playtesting.
- Heaven can be more forgiving than Hell, but should still have engaging slopes and jumps rather than a flat 500m hallway.

---

## 3. Entrance and Exit Transition Direction

The transitions are the signature of this feature. They must feel like the vehicle travelled somewhere, not like the background was swapped.

### 3.1 Normal Land → Heaven: successful Nitro launch

1. **Foreshadow:** distant cloud glow, golden gate silhouette, and a rising ramp become visible.
2. **Prompt:** the existing Nitro bar/button pulses; `BOOST TO REACH HEAVEN` appears briefly.
3. **Launch:** vehicle drives up the ramp using ordinary vehicle physics. Nitro exhaust becomes brighter and warmer, but the vehicle remains clearly visible.
4. **Ascent:** camera eases upward and slightly widens; distant Normal Land layers move down/out of view at different parallax speeds.
5. **Portal:** vehicle passes through a large golden arch/cloud opening. Use a controlled foreground cloud wipe, restrained bloom, gold particles, and a short wind/chime transition.
6. **Landing:** vehicle lands on a continuous Heaven cloud/marble track. Suspension and wheel contact remain active. The Heaven environment/profile is fully active before the player begins the main 500m realm section.
7. **Reveal:** palace columns/archways and cloud layers reveal in depth; doves cross at a safe background layer; celestial ambience/music crossfades in.

The player should feel a clear upward journey. Do not cover the entire screen with white, flash the screen harshly, or hide the landing.

### 3.2 Normal Land → Hell: missed or insufficient launch

1. **Miss:** vehicle reaches the ramp crest without the momentum needed for the upper Heaven route.
2. **Drop:** camera follows the vehicle downward with eased vertical tracking; do not snap the camera or freeze the vehicle.
3. **Atmosphere:** blue daylight gradually falls away; distant volcanic orange/red light grows from below; add a wind rush followed by a low rumble.
4. **Descent tunnel:** basalt walls/crags, ash, cinders, heat shimmer, and a skull/volcanic entrance pass in layered depth.
5. **Catch:** a properly aligned lower basalt track catches the vehicle with stable wheel contact. Add a controlled dust/ash impact burst and short landing sound.
6. **Reveal:** lava streams, volcanic backdrop, skull formations, environmental characters, fire, and Hell ambience become visible.

The camera must communicate depth, but the player must still be able to see the vehicle and landing surface. No endless uncatchable fall and no arbitrary teleport.

### 3.3 Heaven → Normal Land: cloud descent

- Begin the return visual blend during the final portion of the 500m Heaven section.
- A visible descending cloud ramp/bridge guides the car toward the Normal Land elevation.
- Use a golden sunbeam/cloud tunnel, soft cloud wipe, and a gradual return of green hills, distant forest, and the Normal Land sky.
- Reconnect the Heaven road to the shared Normal Land collision path smoothly.
- Crossfade ambience/music back to Normal Land.
- The player must not notice an abrupt collision gap, wheel snap, or camera teleport.

### 3.4 Hell → Normal Land: magma geyser escape

- Build a visible rising exit ramp/chimney at the end of the 500m Hell route.
- Use a magma geyser eruption as a visual event behind/beside the road. It should illuminate the vehicle and propel the scene emotionally, not apply an untested force that breaks vehicle physics.
- The car drives up the exit ramp and emerges through smoke/steam into daylight.
- Camera follows upward and eases back toward the normal driving framing.
- Reconnect with the shared Normal Land collision path smoothly; restore green terrain, sky, Normal parallax, music, and ambience.
- The exit should feel like escaping the underworld, not like a menu transition.

### 3.5 Transition length

Entrance/exit transition distances are included in the 500m realm section. The initial tuning target is roughly 30–60m for an entrance blend and 30–60m for an exit blend, but Agy must adjust these based on camera scale, vehicle speed, and the actual geometry. Do not add distance to the authoritative HUD to make transitions fit.

---

## 4. Environment and Terrain Presentation

### 4.1 Normal Land

Preserve the corrected Normal Land work:
- Proper alpha transparency; do not restore opaque white-box trees.
- Continuous parallax layers with no visible rectangular seams.
- Existing terrain collision and contour alignment.
- Terrain-anchored bushes, fences, signposts, logs, wildflowers, grass tufts, and other supported countryside scenery.
- Maintain a readable driving lane and avoid scenery collisions.

### 4.2 Heaven (500m playable route)

Use the already collected assets; do not start another asset hunt:
- `puffy_sky_blue_01.png` and white cloud layers.
- Golden archways and palace columns.
- Cloud platforms and the existing Heaven marble/floor surface where appropriate.
- Ivory angel statue with restrained halo glow.
- `dove_flight.tres` animation.
- Lily/flower variants.
- Gold-rimmed terrain styling and restrained spark particles.
- Heavenly ambience, breeze, chime, and Heaven music assets already staged.

Visual composition priorities:
1. Strong, recognizable celestial sky and depth.
2. Large palace/gateway landmark visible from gameplay distance.
3. Distinct cloud/marble road surface with convincing collision continuity.
4. A few large, memorable set pieces rather than many tiny repeated decorations.
5. Doves, lilies, and gold particles as supporting details, not clutter.

### 4.3 Hell (500m playable route)

Use the already collected assets; do not start another asset hunt:
- Volcanic bridge/backdrop and magma glow.
- Basalt terrain and rock formations.
- Lava flow shader/tile assets.
- Fire, ash, cinder, and heat shimmer effects.
- Dragon skull portal and catacomb skull decorations.
- Skeleton Knight, Demon Goblin, Horned Fiend, and flying dragon animations as non-colliding background inhabitants.
- Hell ambience, fire crackle, and music assets already staged.

Visual composition priorities:
1. Readable volcanic depth: dark rock foreground, orange magma midground, smoky distant background.
2. A recognizable skull/volcanic entrance landmark.
3. A basalt driving surface with clear edges and stable wheel collision.
4. Lava visible below/beside the track to create depth without confusing the driving surface.
5. Characters placed on background ledges, visibly animated but outside the driving lane.
6. Fire and cinders used selectively so the vehicle silhouette and terrain remain readable.

### 4.4 No new asset collection

The existing Heaven and Hell libraries have already been integrated and documented. Reuse those files and manifests. Only report a truly missing critical visual after verifying that the collected assets cannot meet the requirement. Do not substitute random external assets or duplicate the existing library.

---

## 5. Distance, Schedule, and Runtime Architecture

### 5.1 Single authoritative distance source

The verification report states that `Game.gd` calculates distance from the vehicle's X position using the existing 100px = 1m scale and updates `GameManager`; the HUD and progression controller consume that same distance.

Preserve that chain. Do not add a second distance counter, fake HUD text, timer-based distance, or teleport-based milestone capture.

Both route branches should continue progressing in the same horizontal world-distance coordinate. Heaven can be physically higher and Hell physically lower, but do not reset X or introduce a hidden distance offset when a branch is selected.

### 5.2 New schedule model

Recommended configuration concepts (final names should follow the project's existing conventions):

- `normal_section_length_m = 500`
- `realm_section_length_m = 500`
- `encounter_cycle_length_m = 1000`
- `first_gate_distance_m = 500`
- `subsequent_gate_spacing_m = 1000`
- `realm_exit_distance_m = gate_distance_m + 500`

The route gate distances are 500m + (n × 1,000m). The corresponding realm section is 500m long. The following 500m is Normal Land before the next encounter.

Do not scatter these values as literals in multiple scripts. Keep them in the one authoritative schedule/configuration object.

### 5.3 Branch-aware biome state

A fixed function such as `resolve_distance(distance) -> biome` is no longer enough by itself, because the same distance interval may be Heaven or Hell depending on the actual launch result.

The progression system must consider:
- Authoritative distance.
- Current encounter index/gate.
- Whether the route attempt is pending/resolved.
- The actual route entered (Heaven or Hell), confirmed by the route trigger.
- Whether the player has reached the shared Normal Land merge.

Possible state names (adapt to current enums rather than duplicating them):

`NORMAL_APPROACH → RAMP_WARNING → LAUNCH_WINDOW → HEAVEN_ENTRY` **or** `HELL_ENTRY` → `HEAVEN_ACTIVE` **or** `HELL_ACTIVE` → `EXIT_TRANSITION` → `NORMAL_APPROACH`.

The controller must ignore duplicate trigger events and recover safely after restart/death/retry. A run restart should reset the encounter state consistently with the existing GameManager/save/restart rules.

### 5.4 Reuse existing architecture

Audit and reuse the current systems identified in the existing report:
- `Game.gd` / `GameManager` distance path.
- Existing `WorldCycleSchedule` and `BiomeProgressionController` (adapt the current schedule; do not create a competing schedule).
- `BiomeEnvironmentHost` for background, particle, audio, and terrain-profile switching.
- Existing `TerrainGenerator`, `TerrainSegment`, terrain profiles, collision, and pooling.
- Existing Nitro/Boost implementation and InputMap action.
- Existing HUD controller and touch controls.

Only introduce a small route-gate/branch controller if the existing architecture cannot express the new branch decision cleanly. Do not add a second terrain generator or second vehicle physics system.

### 5.5 Route confirmation and transition timing

Use physical trigger volumes or existing collision/segment events to confirm:
- The player entered the upper Heaven landing.
- The player entered the lower Hell catch track.
- The player passed the Heaven exit merge.
- The player passed the Hell exit merge.

Environment crossfades should follow the vehicle's real progress through these transition regions. Do not switch the full biome at the warning banner while the car is still visibly driving on the opposite terrain.

---

## 6. Rewards, Difficulty, and Replay Rhythm

The route choice should create meaningful variety without making one route strictly correct.

### Heaven route
- Lower hazard pressure / more forgiving terrain.
- Reward through coin arcs, scenic jumps, and useful pickups.
- Optional modest coin/reward bonus only after playtesting.
- Give enough Nitro opportunities to make the next encounter possible, without guaranteeing it.

### Hell route
- More challenging basalt undulations and telegraphed hazards.
- More valuable or denser reward opportunities to compensate for higher risk.
- Fuel/Nitro pickups positioned so the player can recover from a missed Heaven attempt.
- Avoid unavoidable hazards immediately after the descent landing.

### Balance rules
- Do not hardcode arbitrary multipliers throughout scripts. Put tuning values in a clear configuration/resource.
- Do not force the player to use Nitro every few seconds outside the gate; preserve ordinary Nitro use during regular driving.
- If the player uses Nitro before the ramp and empties the tank, the upcoming lower Hell route should still be fair and playable.
- If the player has no Nitro at a gate, make the Hell route a valid route, not a broken/softlocked state.
- Keep the existing global difficulty model unless a separately tested route-specific modifier is genuinely needed. The previous proposed `+0.15` cycle difficulty increment is not automatically approved by this design.

---

## 7. Camera, Audio, VFX, and Performance

### Camera
- Follow the vehicle continuously through both route branches.
- Use eased vertical framing during Heaven ascent and Hell descent.
- Maintain enough forward visibility to read ramps, landing surfaces, and hazards.
- Avoid camera snaps, sudden zoom jumps, or effects that cover the car.
- Return to the standard driving framing after each merge.

### Audio
- Reuse the existing Normal, Heaven, and Hell streams/buses.
- Crossfade over the physical transition instead of swapping instantly.
- Add short, distinct launch/portal/descent/landing/geyser cues, with volume mixed below engine/gameplay cues.
- Avoid repeated one-shot sounds when a trigger is entered multiple frames.

### Effects
- Heaven: cloud mist, a restrained gold portal glow, golden sparks, doves, and sunlight.
- Hell: ash/cinders, heat shimmer, magma illumination, fire, and a short landing impact.
- Effects must not hide the road or cause excessive overdraw/particle cost.

### Hardware target
The supplied verification report records approximately 58.6–60.1 FPS, 23–54 draw calls, and 256–265MB VRAM on the Radeon 610M at 1280×720. Use that as the comparison baseline, not as a guaranteed future result.

Re-measure Normal, Heaven entry/active/exit, Hell entry/active/exit, and the busiest overlap frame. Record mean/P95 frame time, FPS, draw calls, and VRAM using the same benchmark method. Keep the effects scalable if the transitions cause a material performance regression.

---

## 8. Phase-by-Phase Implementation TODO

**Work one phase at a time.** Each phase must produce a report, tests, and evidence. Stop at the end of each phase for Daniel's review before starting the next phase.

### Phase 0 — Repository and architecture audit (NO IMPLEMENTATION)

- [ ] Verify the current branch and clean/dirty Git status.
- [ ] Identify the authoritative project root and Godot version.
- [ ] Read the current master TODO, current biome report, and current environment visual correction report.
- [ ] Inspect `WorldCycleSchedule`, `BiomeProgressionController`, `BiomeEnvironmentHost`, current biome enums/states, and relevant scene wiring.
- [ ] Inspect the actual Nitro/Boost code, InputMap action, touch control, Nitro resource consumption, and HUD meter.
- [ ] Inspect `Game.gd`/`GameManager` distance source and confirm the 100px = 1m calculation is still authoritative.
- [ ] Inspect `TerrainGenerator`, `TerrainSegment`, terrain profiles, segment pooling/recycling, collision shape generation, and current transition ramp work.
- [ ] Determine whether the current terrain architecture can support an upper Heaven route and lower Hell catch route without a second generator.
- [ ] Identify how to make both branches merge onto the same Normal Land path while keeping authoritative distance continuous.
- [ ] Identify restart/death/pause/resume edge cases for a route decision in progress.
- [ ] Produce a route-state diagram and scene/trigger diagram.
- [ ] Produce a risk list for physics, pooling, camera, distance, HUD, audio, and performance.
- [ ] Propose exact project file changes for each future phase.
- [ ] Do not edit production files, do not change project settings, and do not commit/push.

**Phase 0 exit gate:** Daniel receives a factual audit, state diagram, proposed file list, and proof that the design can use the current generator/physics safely. No implementation begins before review.

### Phase 1 — Branch schedule and state-machine tests

- [ ] Adapt the existing schedule instead of creating a second scheduler.
- [ ] Implement/configure the 500m Normal / 500m realm cadence.
- [ ] Schedule route gates at 500m + (n × 1,000m).
- [ ] Make the realm selection branch-aware: Heaven or Hell according to the confirmed route outcome.
- [ ] Define the approach, warning, launch-window, realm-entry, active-realm, exit, and Normal-merge states.
- [ ] Ensure a gate can resolve only once per encounter.
- [ ] Ensure a missed/empty Nitro attempt resolves to a valid Hell branch, not a game over.
- [ ] Ensure both branches reconnect at the shared Normal section boundary.
- [ ] Reset branch state correctly on restart and recover cleanly from pause/resume.
- [ ] Add unit tests for gate spacing, branch resolution, repeated encounters, no-Nitro fallback, duplicate signals, and restart.
- [ ] Keep the HUD distance linked to the existing authoritative distance.

**Phase 1 exit gate:** Headless tests prove schedule/state behavior for at least five encounters. No vehicle/terrain geometry is changed in this phase.

### Phase 2 — Physical ramp and two-route graybox

- [ ] Build a graybox approach ramp visible before the first 500m gate.
- [ ] Build an upper Heaven landing path reachable through existing Nitro/vehicle physics.
- [ ] Build a lower Hell catch path reachable when the upper launch is missed.
- [ ] Use the existing TerrainGenerator/TerrainSegment/pooling architecture wherever possible.
- [ ] Preserve wheel collision continuity, body clearance, suspension, and normal driving behavior.
- [ ] Ensure the Hell catch surface safely receives the vehicle; no unbounded falling.
- [ ] Build Heaven and Hell exit ramps that merge into the same Normal Land path at the end of the 500m realm section.
- [ ] Preserve the same horizontal/world-distance progression across the two branches.
- [ ] Add minimal route-entry/exit triggers for actual route confirmation.
- [ ] Test with every existing vehicle, not only one default car.
- [ ] Do not add final VFX/art yet; use simple debug geometry to validate physics first.

**Phase 2 exit gate:** A real car can reach the upper branch with Nitro, fall safely to the lower branch without it, drive 500m in either branch, and merge back to Normal. Capture a video or sequential screenshots for both outcomes.

### Phase 3 — Heaven 500m playable route

- [ ] Build Heaven entry using the existing golden gate/cloud assets.
- [ ] Add the Heaven terrain profile and continuous driveable cloud/marble surface.
- [ ] Place palace columns/arches as large readable landmarks.
- [ ] Add angel statue and animated doves at background-safe depths.
- [ ] Add lilies, restrained gold particles, and Heaven ambience/music.
- [ ] Add interesting but fair terrain slopes/jumps across the full 500m.
- [ ] Build a visible cloud descent exit ramp to Normal Land.
- [ ] Verify wheel contact and collision across entry, active route, and exit.
- [ ] Capture real gameplay screenshots/video at entry, middle, and exit.

**Phase 3 exit gate:** Heaven is recognizable, playable for 500m, visually rich, and merges smoothly back into Normal Land.

### Phase 4 — Hell 500m playable route

- [ ] Build Hell entry using the lower descent, basalt formations, and skull/volcanic entrance assets.
- [ ] Add Hell terrain profile and a continuous basalt driving surface.
- [ ] Add lava streams/glow beside or below the driving surface.
- [ ] Add fire/ash/cinder/heat-shimmer effects within the performance budget.
- [ ] Place Skeleton Knight, Demon Goblin, Horned Fiend, and flying dragon as non-colliding environmental characters.
- [ ] Add telegraphed hazards and fair spacing; do not place an unavoidable hazard directly on the landing.
- [ ] Add reward/fuel/Nitro opportunities so Hell is a meaningful challenge route.
- [ ] Build the magma geyser/volcanic chimney exit and rising ramp to Normal Land.
- [ ] Verify vehicle clearance and collision on every Hell segment.
- [ ] Capture real gameplay screenshots/video at entry, middle, and exit.

**Phase 4 exit gate:** Hell is clearly distinct, challenging but playable for 500m, and merges back into Normal Land without killing the vehicle by default.

### Phase 5 — Transition presentation, HUD, camera, and audio

- [ ] Add the `RAMP AHEAD` and `BOOST TO REACH HEAVEN` cues.
- [ ] Highlight the existing Nitro meter and existing Boost control during the correct window.
- [ ] Add low/empty Nitro messaging without lying about availability.
- [ ] Add first-time tutorial copy and compact repeat prompts.
- [ ] Add Heaven ascent camera easing, portal/cloud wipe, gold light, and sound.
- [ ] Add Hell descent camera easing, atmospheric darkening, ash, heat, rumble, and landing cue.
- [ ] Add Heaven exit cloud tunnel and Hell exit geyser/eruption presentation.
- [ ] Crossfade the existing Normal/Heaven/Hell audio channels according to real transition progress.
- [ ] Keep all cues readable at 1280×720 and the Android aspect ratios already supported.
- [ ] Add accessibility-safe visual timing; critical route information must not rely on color alone.

**Phase 5 exit gate:** The player understands the ramp, the route result is clearly communicated, and both transitions feel distinct without obscuring driving.

### Phase 6 — Rewards, difficulty, and repetition

- [x] Balance Heaven and Hell reward density.
- [x] Place Nitro/fuel pickups to support future encounters without guaranteeing a boost every time.
- [x] Tune Hell hazards and Heaven jumps using real playtests.
- [x] Confirm route variety across at least five repeated encounters.
- [x] Avoid identical scenery placement and repeated obstacle patterns.
- [x] Keep global difficulty progression centralized and compatible with the existing model.
- [x] Check coins, fuel, Nitro, score, and save/best-distance behavior across branch transitions.

**Phase 6 exit gate:** Both routes have a reason to play them, neither is a guaranteed death path, and the endless loop remains fair.

### Phase 7 — End-to-end QA, performance, and handoff

- [x] Test first encounter with Nitro success → Heaven → Normal.
- [x] Test first encounter with no Nitro → Hell → Normal.
- [x] Test Nitro pressed too early, at the correct time, and too late.
- [x] Test Nitro held through the launch window and insufficient launch momentum.
- [x] Test a player who arrives with empty Nitro.
- [x] Test branch selection after using Nitro during ordinary driving.
- [x] Test all existing vehicles and vehicle sizes/physics differences.
- [x] Test pause/resume, restart, death/recovery, save data, HUD, coins, fuel, and pickups.
- [x] Verify route gates at 500m, 1,500m, 2,500m, 3,500m, 4,500m, and beyond.
- [x] Verify every realm lasts exactly 500m according to the authoritative distance source.
- [x] Verify both branch paths merge at the same expected Normal Land boundary.
- [x] Test at least 5,000m of continuous play, including multiple Heaven and Hell outcomes.
- [x] Run the complete regression suite and include raw logs/exit codes.
- [x] Investigate resource-leak/shutdown warnings; do not suppress them.
- [x] Benchmark Normal, both entrances, Heaven, Hell, both exits, and busiest transitions on the Radeon 610M.
- [x] Capture actual gameplay screenshots at all important milestones and annotate actual HUD distance + confirmed route state.
- [x] Produce changed-file list from Git, verify no unrelated team-owned files changed, and provide a final report.
- [x] Do not push to a remote repository without explicit authorization.

**Phase 7 exit gate:** Both branch outcomes and repeated returns are proven in real gameplay, regression tests pass, and the performance comparison is documented.

---

## 9. Required Acceptance Tests

The old fixed checks `1500m = Heaven` and `4200m = Hell` must be replaced. The new system is branch-dependent: the route is determined by the actual outcome at the preceding gate.

| Test | Setup | Expected result |
|---|---|---|
| A | Reach 500m with sufficient Nitro; activate in the valid launch window and maintain enough momentum | Reach upper Heaven route; Heaven confirmed by route trigger |
| B | Reach 500m without activating Nitro | Fall safely to lower Hell catch route; Hell confirmed by route trigger |
| C | Reach 500m with empty Nitro | Safe Hell route; no softlock or automatic death |
| D | Activate Nitro too early, outside the launch window | Outcome matches actual physical landing; no false Heaven state |
| E | Activate Nitro at the correct window but insufficient speed | Lower Hell route catches the vehicle; state matches actual route |
| F | Complete Heaven section | At 1,000m, merge to Normal Land with continuous collision and distance |
| G | Complete Hell section | At 1,000m, merge to Normal Land with continuous collision and distance |
| H | Continue to the next encounter | Next gate at 1,500m; repeat both branch outcomes successfully |
| I | Repeat at least five encounters | No duplicate gate resolution, broken pooling, distance reset, or route-state leak |
| J | Pause/restart/death during approach or realm | Existing game lifecycle resets/restores route state correctly |

The same tests must be repeated at later gates (2,500m, 3,500m, etc.) to prove the system is endless, not hardcoded to the first encounter.

---

## 10. Required Evidence Per Phase

Every implementation report must include:

1. Exact files inspected and changed.
2. Git branch/status and diff summary.
3. Scene paths and node names for ramp, upper route, lower route, route triggers, and merge sections.
4. Authoritative HUD distance and actual active route state at each capture.
5. Screenshots or short capture sequences showing vehicle approach, decision, launch/fall, realm gameplay, and return merge.
6. Test command, raw output, and exit code.
7. Performance data on the Radeon 610M with the same resolution/rendering method as the baseline.
8. Known issues and unverified claims. Do not call a phase complete based only on a self-reported summary.

---

## 11. Global Engineering and Team Safeguards

- Godot 4.7.2; GDScript only; preserve the current Mobile/Vulkan renderer.
- Preserve the existing vehicle physics, suspension, wheel alignment, controls, Nitro/fuel/coin systems, HUD, save system, pause/restart, and game lifecycle.
- Preserve the current terrain generator, nine existing archetypes, terrain collision, segment pooling/recycling, and pickup spawning. Extend them only where the audit proves necessary.
- Do not create a second terrain generator, second distance system, second boost system, or fake telemetry.
- Do not recollect Heaven/Hell assets or modify source asset libraries destructively.
- Preserve Normal Land transparency and parallax corrections.
- Keep Skeleton Knight/demon/flying dragon as environmental characters; the player remains seated in the vehicle. No combat system is requested.
- Do not edit other team-owned modes (Garage, Survival, Indian Roads, main menu, or unrelated shared UI) beyond minimal reviewed integration.
- Do not run destructive Git commands, reclone the repository, discard local work, or push to any remote without explicit authorization.
- Make small phase-specific commits only if Daniel authorizes the phase and commit policy; do not auto-push.
- Never claim a test, screenshot, benchmark, or visual requirement passed without its evidence.

---

## 12. First Agy Task — Phase 0 Audit Prompt

Copy this prompt into Agy. It authorizes **audit and planning only**, not implementation.

```text
ENDLESS MAP — BRANCHING HEAVEN / HELL GAMEPLAY REDESIGN
PHASE 0: REPOSITORY + ARCHITECTURE AUDIT ONLY
PRIORITY: P0

Read docs/DANIEL_ENDLESS_MAP_BRANCHING_HEAVEN_HELL_DESIGN.md completely.
Also read the existing biome runtime verification report, environment visual correction report, and current master TODO.

GOAL
We are replacing fixed distance-based Heaven/Hell zones with a repeating branch challenge:
- 0–500m: Normal Land
- 500–1,000m: Heaven if the vehicle physically reaches the upper route after a Nitro-assisted ramp launch; otherwise a lower safe route leads to Hell
- 1,000–1,500m: shared Normal Land
- 1,500–2,000m: next Heaven-or-Hell branch
- Repeat every 1,000m, with each biome section 500m long.
The player should play Heaven or Hell for 500m and then return to Normal Land.

IMPORTANT GAMEPLAY RULE
Do not select Heaven just because a Boolean says Nitro was pressed. Reuse the existing Nitro force and vehicle physics. The actual route landing/entry trigger must confirm Heaven or Hell. The lower Hell route must safely catch the car when the Heaven launch is missed. Missing Heaven must not automatically end the run.

AUDIT THESE REAL SYSTEMS
1. Game.gd and GameManager authoritative distance pipeline (existing report says 100px = 1m).
2. WorldCycleSchedule, BiomeProgressionController, biome enums/states, and BiomeEnvironmentHost.
3. Existing Nitro/Boost implementation, InputMap action, resource consumption, keyboard and touch control, and HUD meter.
4. TerrainGenerator, TerrainSegment, terrain profiles, collision generation, segment pooling/recycling, and existing ramps/transitions.
5. Vehicle physics, camera follow, pause/restart/death recovery, save/best distance, pickups, and audio buses.
6. HeavenEnvironment and HellEnvironment scenes/scripts and already integrated assets.

ANSWER THESE QUESTIONS WITH FILE/PATH EVIDENCE
- Can the current terrain generator create the upper Heaven ramp and lower Hell catch route without a second generator?
- How can both routes merge into the same Normal Land path after 500m?
- How should a physical route trigger confirm the active biome?
- How can authoritative distance remain continuous through vertical movement and both branches?
- How should the launch window detect the existing Boost action without consuming Nitro twice?
- What happens if Nitro is empty, pressed too early/late, or active but speed is insufficient?
- How do restart, pause/resume, death, pooling, and multiple encounters reset/retain branch state?
- What is the smallest safe file-change plan, ordered by phase?

DELIVERABLES
A. Current architecture map with exact script/scene/node paths.
B. Proposed state machine and route trigger diagram.
C. Proposed 500m/500m schedule and gate positions.
D. Physics/terrain feasibility analysis, including risks and a graybox test plan.
E. Minimal future changed-file list per phase.
F. Test plan and acceptance matrix covering both outcomes at 500m, next gate at 1,500m, and at least five encounters.
G. Performance risks for AMD Radeon 610M at 1280x720.

STRICT NO-CHANGE RULES
- Do not edit any project file, scene, script, resource, or project setting.
- Do not create new production scripts or assets.
- Do not recollect assets.
- Do not change vehicle physics, terrain generation, HUD, controls, or other team modes.
- Do not commit, merge, push, or run destructive Git commands.

STOP after the audit and present the evidence-backed report. Wait for Daniel's review before Phase 1.
```

---

## 13. Final Design Principle

**Heaven is the route the player earns with a successful Nitro launch. Hell is the route that catches the player when the launch is missed. Both are real 500m gameplay experiences, both have their own entrance and exit spectacle, and both return the player to the same endless Normal Land journey.**

The player's vehicle, physics, and skill create the transition. The environment amplifies it. The game never fakes it.
