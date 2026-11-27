# Hill Climb V2 — Fix Guide for Agy

By Claude, diagnostic pass only — no code or scenes were edited. Physics bodies, forces, torque, and masses were not touched. Each item below names the exact file/line where the problem lives and what is actually wrong, so Agy can go straight to the fix without re-diagnosing.

---

## 1. Nitro feels unlimited

File: scripts/vehicle/VehicleController.gd, lines 75-93 (exported values) and 239-258 (\_update\_nitro)

Cause: nitro\_consumption\_rate = 25.0 and nitro\_recharge\_rate = 14.0 against max\_nitro = 100.0. A full bar drains in 4 seconds but refills from empty in about 7 seconds with no gate at all — it just climbs back up the moment the button is released. On top of that, scenes/pickups/NitroPickup.tscn exists but is never spawned by scripts/terrain/TerrainGenerator.gd — nitro in normal/endless mode is pure passive regen, there is no scarcity mechanic at all. That combination is why it reads as unlimited.

Guidance for Agy: lower nitro\_recharge\_rate (try something in the 4-6 range instead of 14) and/or add a short delay after the button is released before regen starts (a cooldown timer before the else branch at line 253 begins adding back). Leave nitro\_consumption\_rate, nitro\_boost\_force, nitro\_torque\_multiplier alone — those are the feel of the boost itself, not the scarcity problem.

---

## 2. Fuel is spaced wrong / runs out between cans

Files:

- scripts/terrain/TerrainGenerator.gd, line 42: fuel\_interval\_distance = 8500.0 (px, about 85 m between canisters)
- scripts/core/GameManager.gd, lines 58-61: \_process calls consume\_fuel(fuel\_drain\_rate \* delta) every frame the run is in PLAYING state — regardless of whether the player is accelerating, braking, or sitting still.

Cause: a full tank (max\_fuel = 100, drain 4.0/s) only lasts 25 seconds of real time no matter what the player is doing, because fuel burns on a clock, not on throttle use. 8500 px between cans is only safely reachable if the vehicle is moving near top speed the whole way — on any slower stretch (hills, obstacles) the tank runs dry before the next canister. The two numbers were never checked against each other or against real travel speed.

Guidance for Agy: scripts/modes/survival/SurvivalController.gd lines 551-552 already does this the right way — it only calls consume\_fuel while Input.is\_action\_pressed("accelerate"). Make GameManager.gd's drain loop match that (gate it on the accelerate input instead of just RunState.PLAYING). Once drain is input-gated, re-check fuel\_interval\_distance against actual average travel speed and tighten it if cans are still too far apart.

---

## 3. Front wheel looks detached from the car body at speed

Files:

- scenes/vehicle/Vehicle.tscn, lines \~203-221 (RearJoint / FrontJoint, both PinJoint2D, softness = 0.6) — same pattern in every other vehicle scene (TrophyTruck.tscn 0.7, MonsterTruck.tscn 0.75, BlueFlameTruck.tscn 0.65, DuneBuggy.tscn 0.55, OrcRacer.tscn 0.58)
- scripts/vehicle/VehicleController.gd, lines 533-534 (nitro force applied straight to the chassis) and 551-556 (motor torque applied straight to the wheel bodies, front wheel included)

Cause: each wheel is its own RigidBody2D, held to the chassis only by a PinJoint2D with built-in give (softness). Chassis and wheel are two independently-simulated bodies connected by a spring-like pin, not a rigid weld. Under high forward torque — especially the front wheel, since it is the forward-most mount — combined with the nitro force hitting the chassis directly, the soft joint lets the wheel's position drift ahead of where the chassis attachment point is, which reads as the wheel running ahead while the car follows.

I am flagging this rather than prescribing a fix since you asked not to touch physics, and joint softness sits right on that line — it is not the core RigidBody2D simulation, but it is a physics parameter. Options Agy can weigh: lower that softness value (less give, tighter visual lock, slightly stiffer suspension feel), or keep softness but add a joint distance/bias clamp so the wheel cannot drift past a fixed offset from its mount point. Either is a small, local change — neither touches mass, torque, or force values.

---

## 4 and 5. Wrong coin/fuel art plus the rotation not being smooth (same root cause)

Endless/normal mode coin — scenes/pickups/Coin.tscn + scripts/pickups/Coin.gd: Uses one static texture, assets/pickups/coins/coin\_gold\_static.png. The spin is not a rotation animation at all — line 48 of Coin.gd does visual.scale.x = sin(\_elapsed \* 3.0), which flips the sprite's X-scale back and forth as a cheap fake-3D-spin trick. That is both the wrong-asset complaint and the not-smooth-rotation complaint in one line.

Endless/normal mode fuel can — scenes/pickups/FuelPickup.tscn + scripts/pickups/FuelPickup.gd: This one does use an AnimatedSprite2D, but its frames come from assets/pickups/fuel/fuel\_can\_animation\_frames/fuel\_can\_frame\_01-06.png — a different, older art set than Survival mode's can.

Survival mode already does this right — scripts/modes/survival/collectibles/SurvivalCollectible.gd, lines 81-98 (\_get\_frames): Builds a real SpriteFrames resource from true rotation art: assets/survival/collectibles/coins/coin\_rotate\_01-06.png (9 fps) for coins and assets/survival/collectibles/fuel/fuel\_frame\_01-06.png (6 fps) for fuel, cached once and played on an AnimatedSprite2D. This is genuine frame-by-frame animation, timed in real seconds via set\_animation\_speed, which is exactly why it already looks correct and smooth in Survival.

Guidance for Agy: point Coin.tscn/Coin.gd and FuelPickup.tscn/FuelPickup.gd at the same two asset folders (coin\_rotate\_01-06.png, fuel\_frame\_01-06.png) and the same AnimatedSprite2D plus cached SpriteFrames pattern SurvivalCollectible.gd already uses, instead of the static coin texture and the scale.x sine trick. One asset/approach swap resolves both complaints — the wrong can (#4) and the not-smooth rotation (#5) — for both pickups at once, and it is proven to already work since it is literally what Survival mode ships today.

---

## Summary for Agy

| # | Symptom | File(s) | Fix category |
| --- | --- | --- | --- |
| 1 | Nitro feels unlimited | VehicleController.gd L75-93, L239-258 | Tuning values only |
| 2 | Fuel runs dry between cans | GameManager.gd L58-61, TerrainGenerator.gd L42 | Gate drain on input, then re-tune spacing |
| 3 | Front wheel detaches visually at speed | Vehicle.tscn (and other vehicle scenes), PinJoint2D.softness | Joint parameter — flagged, not changed |
| 4 | Endless coin/fuel use wrong assets | Coin.tscn, FuelPickup.tscn | Swap asset source folder |
| 5 | Coin/fuel rotation not smooth | Coin.gd L48 (fake spin), FuelPickup.gd | Replace fake spin / old frames with Survival's AnimatedSprite2D pattern |

Nothing above requires touching vehicle mass, motor torque magnitude, nitro force magnitude, or the RigidBody2D/joint simulation itself — except #3, which is called out explicitly as a judgment call since it is a physics-adjacent joint parameter.
