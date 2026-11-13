class_name SurvivalRewardProvider
extends RefCounted

## SurvivalRewardProvider: Decoupled interface for rewarded actions (e.g. Extra Life).
## Isolates gameplay logic from external third-party ad networks (AdMob, Unity Ads, etc.).
## In Phase 2, functions as a deterministic mock and test seam.

var mock_should_succeed: bool = false
var mock_delay_seconds: float = 0.0

## Requests a reward. Invokes callback with Dictionary: {"success": bool, "reward_type": String}
func request_reward(reward_type: String, callback: Callable) -> void:
	if not callback.is_valid():
		push_error("SurvivalRewardProvider: Provided callback is invalid!")
		return

	if mock_delay_seconds > 0.0:
		var tree := Engine.get_main_loop() as SceneTree
		if is_instance_valid(tree):
			await tree.create_timer(mock_delay_seconds).timeout

	var result: Dictionary = {
		"success": mock_should_succeed,
		"reward_type": reward_type
	}
	callback.call(result)
