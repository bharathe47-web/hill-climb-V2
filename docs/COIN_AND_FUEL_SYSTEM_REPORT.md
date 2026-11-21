# COINS & PETROL RESOURCE SYSTEM REPORT
**Engine:** Godot 4.7  
**Module:** `IndianRoadTerrainV2.gd`, `IndianRoadsHUD.tscn`, `IndianRoadsController.gd`  
**Responsible Owner:** Joel (Indian Roads Pickups & HUD) & Bharath (Currency/SaveManager)  
**Status:** VERIFIED COMPLETE  

---

## 1. COIN PATTERNS & COLLECTION DYNAMICS (STEP 8A)

### Procedural Spawning Patterns
In `IndianRoadTerrainV2.gd` (`_populate_pickups_and_coins`):
- Coins spawn along the highway every $1800\text{ to }2600\text{ px}$ ($\approx 75\text{ to }105\text{ m}$) using seeded controlled randomness (`rng.seed = 20261114 + state_id.hash()`).
- Patterns generated:
  1. **Linear Group:** 3–5 coins in a straight line $26\text{ px}$ above asphalt at $45\text{ px}$ intervals.
  2. **Parabolic Arc:** 3–5 coins climbing smoothly over small crests and dips ($y = \text{road\_y} - 26.0 - \sin(\text{norm} \cdot \pi) \cdot 22.0$).
- Proximity checks guarantee no coins spawn inside the Kanyakumari ocean gap ($x = 26800\text{ to }45200\text{ px}$) or clipping landmark pedestals.

### Feedback & Economy Integration
- `Coin.tscn` uses `Area2D` on collision layer 4 (mask 2 for vehicle).
- Upon collision:
  - Disables collision immediately to prevent duplicate awards.
  - Spawns sparkle particle burst and plays `coin_collection_sound.wav`.
  - Animates a floating popup label (`+5`).
  - Emits `coin_collected(val)` which increments `session_coins` and calls `SaveManager.record_run()`.

---

## 2. PETROL / FUEL CONSUMPTION SYSTEM (STEP 8B)

### Fuel Mechanics
- **Capacity:** $100.0\text{ units}$.
- **Burn Rate:** $4.0\text{ units / sec}$ while accelerating (`consumes_fuel = true`).
- **Low Fuel Warning:** Physical engine sputtering and red warning label when fuel $< 20\%$.
- **Empty Fuel Response:** When fuel reaches $0.0$, engine power cuts off, vehicle coasts to a stop, and the HUD triggers an alert toast: *"OUT OF PETROL! Collect petrol to restore power"*.

### Petrol Canister Pickups
- Canisters spawn every $6500\text{ to }8500\text{ px}$ ($\approx 260\text{ to }340\text{ m}$) along the highway.
- `FuelPickup.tscn` displays a 6-frame animated canister with green vapor aura.
- On contact:
  - Invokes `veh.refuel(35.0)` to restore $35\%$ tank capacity.
  - Triggers vapor burst particles and plays `fuel_collection_sound.wav`.
  - Shows HUD announcement toast: *"PETROL COLLECTED! +35% Fuel Refilled"*.

---

## 3. SCREENSHOT VERIFICATION
- `docs/screenshots/petrol_collection.png` — Proves real gameplay pickup of a petrol canister with $+35\%$ fuel toast and updated gauge.
- `docs/screenshots/gameplay_tamil_nadu.png` — Proves gold coin arcs above asphalt and active coin counter in top bar.
