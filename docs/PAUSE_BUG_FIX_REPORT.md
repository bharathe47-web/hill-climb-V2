# Pause Functionality Bug Fix Report
**Developer:** Joel (Indian Roads, HUD, Pickups, Routes, Level Design, QA)  
**Project:** Hill Climb V2 (Godot 4.7)  
**Branch:** `feature/joel-roads-obstacles`  
**Date:** November 17, 2026  

---

## 1. Defect Description & Symptoms

**Reported Issue:**  
In Indian Roads mode, pressing the HUD pause button or pressing Escape caused the game screen to completely freeze. No pause menu appeared, player inputs were unresponsive, and the player was forced to forcefully terminate the game instance.

---

## 2. Root Cause Analysis

Investigation of `scripts/modes/indian_roads/IndianRoadsController.gd` and `scripts/ui/PauseMenuController.gd` identified the exact failure sequence:

### Defect 1: Visibility Logic Flaw in Controller
In `scripts/modes/indian_roads/IndianRoadsController.gd` (lines 355–366 prior to fix):
```gdscript
func _on_pause_requested() -> void:
    if current_state != ModeState.PLAYING:
        return
    current_state = ModeState.PAUSED
    get_tree().paused = true

    if not is_instance_valid(pause_menu):
        pause_menu = PauseMenuScene.instantiate()
        ui_layer.add_child(pause_menu)
        # Signal connections...
    else:
        pause_menu.visible = true   # <-- DEFECT: Only executed when pause_menu ALREADY existed!
```

### Defect 2: Initial Visibility State in PauseMenuController
In `scripts/ui/PauseMenuController.gd` (line 19):
```gdscript
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false                 # <-- Sets itself hidden on instantiation!
```

### The Freeze Mechanism:
1. On the **first** pause request, `pause_menu` was `null`.
2. `IndianRoadsController` instantiated `pause_menu` and added it to `ui_layer`.
3. `PauseMenuController._ready()` ran and set `visible = false`.
4. Because this was the first instantiation, the `if not is_instance_valid(pause_menu):` branch executed, completely bypassing the `else: pause_menu.visible = true` line!
5. `get_tree().paused = true` fired, suspending physics and normal game processing.
6. The pause menu remained invisible (`visible == false`).
7. **Result:** The player was presented with a frozen screen with zero interactive UI elements and no way to resume or exit.

### Secondary Defect: Vehicle Nitro Input Latching
If the player was holding the Nitro button or spacebar when pause was triggered, `active_vehicle.is_nitro_active` remained `true` during the paused state, causing unintended burst acceleration immediately upon unpausing.

---

## 3. Resolution & Code Changes

### 3.1 Unconditional Menu Visibility & Process Mode Enforcement
In `scripts/modes/indian_roads/IndianRoadsController.gd`:
```gdscript
func _on_pause_requested() -> void:
	if current_state != ModeState.PLAYING:
		return
	current_state = ModeState.PAUSED
	get_tree().paused = true

	# Deactivate vehicle nitro and clear active inputs upon pause
	if is_instance_valid(active_vehicle):
		if active_vehicle.get("is_nitro_active") != null:
			active_vehicle.is_nitro_active = false

	if not is_instance_valid(pause_menu):
		pause_menu = PauseMenuScene.instantiate()
		ui_layer.add_child(pause_menu)
		if pause_menu.has_signal("resume_pressed"):
			pause_menu.resume_pressed.connect(_on_resume_requested)
		if pause_menu.has_signal("restart_pressed"):
			pause_menu.restart_pressed.connect(_on_restart_from_pause)
		if pause_menu.has_signal("main_menu_pressed"):
			pause_menu.main_menu_pressed.connect(_on_main_menu_from_pause)

	# Crucial: Unconditionally display pause menu so first pause never freezes
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.visible = true
```

### 3.2 Robust Resume & Restart Clean-Up
```gdscript
func _on_resume_requested() -> void:
	if is_instance_valid(pause_menu):
		pause_menu.visible = false
	get_tree().paused = false
	current_state = ModeState.PLAYING

func _on_restart_from_pause() -> void:
	if is_instance_valid(pause_menu):
		pause_menu.visible = false
	get_tree().paused = false
	start_route(active_route)

func _on_main_menu_from_pause() -> void:
	if is_instance_valid(pause_menu):
		pause_menu.visible = false
	get_tree().paused = false
	return_to_main_menu_requested.emit()
```

### 3.3 Keyboard Shortcut Handling in HUD
In `scripts/modes/indian_roads/IndianRoadsHUD.gd`:
```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		pause_pressed.emit()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		pause_pressed.emit()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		get_viewport().set_input_as_handled()
		map_pressed.emit()
```

---

## 4. Test Verification & Regression Results

Automated test executed via `tests/test_gameplay_refinement.gd`:
- **First Pause Test:** `pause_menu` instantiated, `pause_menu.visible == true`, `paused == true`. PASSED.
- **Resume Test:** `pause_menu.visible == false`, `paused == false`, `current_state == ModeState.PLAYING`. PASSED.
- **Repeated Pause/Resume Cycles:** 5 consecutive cycles tested. PASSED.
- **Visual Capture:** `pause_menu_active.png` and `resume_gameplay.png` captured in live hardware environment. PASSED.
