# PAUSE & RESUME FREEZE DEFECT REPORT & RESOLUTION
**Engine:** Godot 4.7  
**Module:** `PauseMenuController.gd` & `IndianRoadsController.gd`  
**Responsible Owner:** Joel & Bharath (Shared UI Coordination)  
**Status:** VERIFIED COMPLETE  

---

## 1. ORIGINAL PROBLEM

When the player paused gameplay during Indian Roads mode, clicking "Resume", pressing the Escape key, or tapping retry would leave the gameplay world permanently frozen. The vehicle was unmovable, the camera stopped following, and controls failed to respond.

---

## 2. ROOT CAUSE INVESTIGATION

A thorough trace through input propagation and signal trees revealed a dual root cause:

1. **Missing Signals in `PauseMenuController.gd`:**
   - `IndianRoadsController.gd` connected to `pause_menu.resume_pressed`, `pause_menu.restart_pressed`, and `pause_menu.main_menu_pressed`.
   - However, `PauseMenuController.gd` had only declared `signal menu_requested` and lacked declarations for `resume_pressed`, `restart_pressed`, and `main_menu_pressed`.
   - When "Resume" was pressed without an active `GameManager` (as in Indian Roads mode), `PauseMenuController` simply set its own `visible = false` and called `get_tree().paused = false`, but **never emitted `resume_pressed`**.
2. **Controller State Stuck in `ModeState.PAUSED`:**
   - In `IndianRoadsController.gd`, `_on_pause_requested()` set `current_state = ModeState.PAUSED`.
   - Because `resume_pressed` was never emitted, `_on_resume_requested()` was never invoked, leaving `current_state` permanently as `ModeState.PAUSED`.
   - In `IndianRoadsController._process()` and vehicle physics process, all progression logic early-exited due to `if current_state != ModeState.PLAYING: return`.
3. **UI Process Mode Inheritance:**
   - When `get_tree().paused = true`, nodes inheriting the default process mode were halted by the SceneTree, risking input drop on low-end touchscreens.

---

## 3. IMPLEMENTATION & RESOLUTION

1. **Declared & Emitted Signals in `PauseMenuController.gd`:**
   ```gdscript
   signal menu_requested
   signal resume_pressed
   signal restart_pressed
   signal main_menu_pressed

   func _on_resume_pressed() -> void:
       visible = false
       get_tree().paused = false
       if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("pause_run"):
           game_manager_ref.pause_run(false)
       resume_pressed.emit()

   func _on_retry_pressed() -> void:
       visible = false
       get_tree().paused = false
       if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("restart_run"):
           game_manager_ref.restart_run()
       restart_pressed.emit()

   func _on_main_menu_pressed() -> void:
       visible = false
       get_tree().paused = false
       if is_instance_valid(game_manager_ref) and game_manager_ref.has_method("pause_run"):
           game_manager_ref.pause_run(false)
       menu_requested.emit()
       main_menu_pressed.emit()
   ```
2. **Explicit Unpausing & State Reset in `IndianRoadsController.gd`:**
   - Added `ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS` in `_ready()`.
   - `_on_resume_requested()` authoritatively resets `current_state = ModeState.PLAYING` and restores viewport focus.
   - Connected both `main_menu_pressed` and fallback `menu_requested` to `_on_main_menu_from_pause()`.

---

## 4. REGRESSION VERIFICATION

- [x] Pausing during flat highway cruise: vehicle freezes instantly.
- [x] Resuming restores vehicle linear and angular velocity instantly without stuck inputs.
- [x] Pausing during active Nitro boost: exhaust particles and velocity hold until resume, then continue seamlessly.
- [x] Pausing mid-jump on Kanyakumari Glass Bridge: gravity holds mid-air, vehicle resumes flight on unpause.
- [x] Retrying from pause restarts the route cleanly.
- [x] Main menu returns to title screen cleanly without lingering paused SceneTree state.
- [x] Verified in runtime screenshot: `docs/screenshots/pause_menu.png`.
