class_name HUDController
extends "res://scripts/ui/game_hud.gd"

## HUDController: Backward-compatible wrapper extending GameHUD.
## Preserves the HUDController class name and full interface for existing scenes,
## scripts, and regression test suites while delegating core shared HUD functionality
## to the unified GameHUD implementation.
